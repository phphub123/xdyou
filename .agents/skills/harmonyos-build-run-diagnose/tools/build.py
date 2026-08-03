#!/usr/bin/env python3
"""build.py — Build a Cangjie HarmonyOS project (ohpm install → SyncCangjieResource → assembleHap).

Usage:
    python build.py --project-root <dir> [--module <name>] [--json]
    python build.py --project-root <dir> --deveco-home <dir> --cangjie-sdk <dir> [--no-strict-ssl]
Exit codes: 0 成功 · 1 业务失败（依赖安装/构建失败） · 2 参数/环境错误
"""

from __future__ import annotations

import argparse
import json
import os
import platform
import re
import subprocess
import sys
import traceback
from dataclasses import dataclass
from pathlib import Path
from typing import NoReturn

# UTF-8 stdio 防线（Windows GBK 控制台必备；家族标准片段，逐字复用）
for _stream in (sys.stdout, sys.stderr):
    try:
        _stream.reconfigure(encoding="utf-8", errors="replace")  # type: ignore[attr-defined]
    except (AttributeError, OSError):
        pass


def _load_config_helpers():
    """跨技能导入 harmonyos-cangjie-dev 的分层配置；失败降级为本地 runtime_fallback 并在 stderr 声明降级面。"""
    skills_dir = Path(__file__).resolve().parents[2]
    helper_dir = skills_dir / "harmonyos-cangjie-dev" / "tools"
    if helper_dir.exists():
        sys.path.insert(0, str(helper_dir))
    try:
        from config_loader import detect_project_runtime, first_value, load_harmony_config, path_value
        return detect_project_runtime, first_value, load_harmony_config, path_value
    except Exception:
        print(
            "warn: config_loader unavailable; layered config ignored, "
            "using local app.json5/module.json5 detection",
            file=sys.stderr,
        )
        local_dir = str(Path(__file__).resolve().parent)
        if local_dir not in sys.path:
            sys.path.insert(0, local_dir)
        try:
            from runtime_fallback import detect_project_runtime as fallback_detect
        except Exception:
            fallback_detect = lambda *_, **__: None  # noqa: E731
        return (
            fallback_detect,
            lambda *values: next((v for v in values if v is not None and v != ""), None),
            lambda **_: None,
            lambda value: Path(value).expanduser() if value else None,
        )


detect_project_runtime, first_value, load_harmony_config, path_value = _load_config_helpers()


# ── 常量 ──────────────────────────────────────────────────────

DEVECO_HOME_WINDOWS = r"C:/Program Files/Huawei/DevEco Studio"
DEVECO_HOME_LINUX = "/opt/DevEco-Studio"
DEVECO_HOME_MACOS = "/Applications/DevEco-Studio.app/Contents"
DEFAULT_PROJECT_ROOT = Path.cwd()
DEFAULT_CANGJIE_SDK_ROOT = Path.home() / ".cangjie-sdk"
LEGACY_CANGJIE_SDK_VERSION = "6.0"
DEFAULT_OHPM_REGISTRY = "https://ohpm.openharmony.cn/ohpm/"
BUILD_LOG = "build.log"
HINT_CONFIG = "configure it with CLI options, environment variables, or ~/.harmonyos-cangjie/config.toml"
HINT_BUILD_FAILURE = "inspect build.log via build_analyzer.py; known cjpm cache failures: build_recovery.py --retry"

_ANSI_RE = re.compile(r"\x1b\[[0-9;]*[A-Za-z]")


@dataclass(frozen=True)
class PlatformSpec:
    deveco_home: Path
    runtime_dir: str
    lib_var: str | None


PLATFORMS: dict[str, PlatformSpec] = {
    "Windows": PlatformSpec(Path(DEVECO_HOME_WINDOWS), "windows_x86_64_cjnative", None),
    "Linux": PlatformSpec(Path(DEVECO_HOME_LINUX), "linux_{arch}_cjnative", "LD_LIBRARY_PATH"),
    "Darwin": PlatformSpec(Path(DEVECO_HOME_MACOS), "darwin_{arch}_cjnative", "DYLD_LIBRARY_PATH"),
}


class ToolError(Exception):
    """受控失败。code: 1 业务失败 · 2 参数/环境错误。"""

    def __init__(self, message: str, code: int = 1, hint: str | None = None) -> None:
        super().__init__(message)
        self.code = code
        self.hint = hint


# ── 纯函数 ────────────────────────────────────────────────────


def _sdk_version_key(name: str) -> tuple[tuple[int, ...], str]:
    """Semantic-ish version key: '6.10' > '6.2' > '6.0'; non-numeric names sort lowest."""
    return tuple(int(part) for part in re.findall(r"\d+", name)), name


def discover_cangjie_sdk(explicit: str | os.PathLike | None = None, root: Path | None = None) -> Path:
    """Resolve the Cangjie SDK path.

    Priority: explicit value (CLI/env/config) if given; otherwise scan
    ~/.cangjie-sdk/<version>/cangjie and pick the highest version; if none
    exists, fall back to the legacy 6.0 default (for a clear error message).
    """
    if explicit:
        return Path(explicit).expanduser()
    base = root if root is not None else DEFAULT_CANGJIE_SDK_ROOT
    try:
        candidates = [entry for entry in base.iterdir() if (entry / "cangjie").is_dir()]
    except OSError:
        candidates = []
    if candidates:
        best = max(candidates, key=lambda entry: _sdk_version_key(entry.name))
        return best / "cangjie"
    return base / LEGACY_CANGJIE_SDK_VERSION / "cangjie"


def host_arch() -> str:
    machine = platform.machine().lower()
    if machine in ("", "amd64", "x86_64"):
        return "x86_64"
    if machine in ("arm64", "aarch64"):
        return "aarch64"
    return machine


def detect_default_module(project: Path) -> str:
    profile = project / "build-profile.json5"
    if not profile.exists():
        return "entry"
    text = profile.read_text(encoding="utf-8", errors="replace")
    match = re.search(r'"modules"\s*:\s*\[\s*\{\s*"name"\s*:\s*"([^"]+)"', text, re.S)
    return match.group(1) if match else "entry"


def find_haps(project: Path, module: str) -> list[Path]:
    """Built .hap files under <module>/build, oldest→newest (mirrors runtime_fallback)."""
    try:
        return sorted((project / module / "build").glob("**/*.hap"), key=lambda p: p.stat().st_mtime)
    except OSError:
        return []


# ── 副作用函数（日志/环境/子进程） ────────────────────────────

_HUMAN = sys.stdout  # --json 时切至 stderr，保证 stdout 只输出 JSON


def fail(msg: str, code: int = 1, hint: str | None = None) -> NoReturn:
    raise ToolError(msg, code=code, hint=hint)


def log(msg: str, color: int = 0) -> None:
    print(f"\033[{color}m{msg}\033[0m" if color else msg, file=_HUMAN, flush=True)


def ensure(path: Path, label: str) -> Path:
    if not path.exists():
        fail(f"{label} not found: {path}", code=2, hint=HINT_CONFIG)
    return path


def detect_platform() -> tuple[str, PlatformSpec]:
    name = platform.system()
    if name not in PLATFORMS:
        fail(f"unsupported platform: {name}", code=2, hint="supported platforms: Windows / Linux / Darwin")
    return name, PLATFORMS[name]


def run(cmd: list[str], env: dict[str, str]) -> None:
    log(f">>> {' '.join(cmd)}", 90)
    # Windows: .bat/.cmd (ohpm.bat) must go through the shell as a fully quoted
    # command string; list-form Popen is rejected by the CVE-2024-27980
    # hardening or loses quoting for paths with spaces (DevEco install dir).
    use_shell = os.name == "nt" and Path(cmd[0]).suffix.lower() in (".bat", ".cmd")
    popen_cmd: str | list[str] = subprocess.list2cmdline(cmd) if use_shell else cmd
    proc = subprocess.Popen(popen_cmd, shell=use_shell, env=env, stdout=subprocess.PIPE, stderr=subprocess.STDOUT, text=True, errors="replace")
    with open(BUILD_LOG, "a", encoding="utf-8") as fh:
        for line in proc.stdout:  # type: ignore[union-attr]
            _HUMAN.write(line)
            fh.write(_ANSI_RE.sub("", line))
    rc = proc.wait()
    if rc:
        fail(f"command failed with exit code {rc}", code=1, hint=HINT_BUILD_FAILURE)


def run_quiet(cmd: list[str]) -> str:
    try:
        proc = subprocess.run(cmd, capture_output=True, text=True, check=False)
        return proc.stdout.strip() if proc.returncode == 0 else ""
    except FileNotFoundError:
        return ""


def merge_path(env: dict[str, str], var: str, *dirs: Path, prepend: bool = True) -> None:
    existing = [p for p in env.get(var, "").split(os.pathsep) if p]
    new = [str(d) for d in dirs if d.exists()]
    ordered = (new + existing) if prepend else (existing + new)
    seen: set[str] = set()
    result: list[str] = []
    for entry in ordered:
        key = os.path.normcase(os.path.normpath(entry))
        if key not in seen:
            seen.add(key)
            result.append(entry)
    env[var] = os.pathsep.join(result)


def setup_cangjie_env(env: dict[str, str], sdk: Path, plat: str, spec: PlatformSpec) -> None:
    home = ensure(sdk / "build-tools", "CANGJIE_HOME")
    env["CANGJIE_HOME"] = str(home)

    rt_dir = spec.runtime_dir.format(arch=host_arch())
    rt_lib = home / "runtime" / "lib" / rt_dir
    tools_lib = home / "tools" / "lib"

    if spec.lib_var is None:
        merge_path(env, "PATH", tools_lib, home / "bin", home / "tools" / "bin", home / "lib" / rt_dir, rt_lib)
    else:
        merge_path(env, "PATH", home / "bin", home / "tools" / "bin")
        merge_path(env, spec.lib_var, rt_lib, tools_lib)

    merge_path(env, "PATH", Path.home() / ".cjpm" / "bin", prepend=False)

    if plat == "Darwin":
        setup_macos_extras(env, home)


def setup_macos_extras(env: dict[str, str], build_tools: Path) -> None:
    if not env.get("SDKROOT"):
        sdkroot = run_quiet(["xcrun", "--sdk", "macosx", "--show-sdk-path"])
        if sdkroot:
            env["SDKROOT"] = sdkroot
    run_quiet(["xattr", "-dr", "com.apple.quarantine", str(build_tools)])
    debugserver = build_tools / "third_party" / "llvm" / "bin" / "debugserver"
    if debugserver.exists():
        run_quiet([
            "codesign",
            "-s",
            "-",
            "-f",
            "--preserve-metadata=entitlements,requirements,flags,runtime",
            str(debugserver),
        ])


def resolve_build_tools(deveco: Path, plat: str) -> tuple[Path, Path, Path]:
    win_exe = {"ohpm": "ohpm.bat", "node": "node.exe"}
    exe = win_exe.get if plat == "Windows" else lambda _name, default: default
    ohpm = ensure(deveco / "tools" / "ohpm" / "bin" / exe("ohpm", "ohpm"), "ohpm")
    node = ensure(deveco / "tools" / "node" / exe("node", "node"), "Node")
    hvigorw = ensure(deveco / "tools" / "hvigor" / "bin" / "hvigorw.js", "hvigorw")
    return ohpm, node, hvigorw


def build_pipeline(args: argparse.Namespace) -> dict[str, object]:
    plat, spec = detect_platform()
    project = ensure(Path(args.project_root).expanduser().resolve(), "Project root")
    os.chdir(project)
    log(f"Project: {project}", 35)

    cfg = load_harmony_config(project_root=project, config_paths=args.config)
    toolchain = getattr(cfg, "toolchain", None)
    runtime_cfg = getattr(cfg, "runtime", None)

    deveco = ensure(
        path_value(first_value(args.deveco_home, os.getenv("DEVECO_HOME"), getattr(toolchain, "deveco_home", None))) or spec.deveco_home,
        "DevEco Studio",
    )
    cangjie = ensure(
        discover_cangjie_sdk(path_value(first_value(args.cangjie_sdk, os.getenv("CANGJIE_SDK_HOME"), getattr(toolchain, "cangjie_sdk", None)))),
        "Cangjie SDK",
    )
    ohpm_registry = first_value(args.ohpm_registry, getattr(toolchain, "ohpm_registry", None), DEFAULT_OHPM_REGISTRY)
    strict_config = getattr(toolchain, "strict_ssl", None)
    strict_ssl = args.strict_ssl if args.strict_ssl is not None else (strict_config if strict_config is not None else True)
    detected = detect_project_runtime(project, module=getattr(runtime_cfg, "module", None) if runtime_cfg else None)
    for warning in getattr(detected, "warnings", []) or []:
        log(f"WARN: {warning}", 33)
    module_name = (
        args.module
        or getattr(runtime_cfg, "module", None)
        or getattr(detected, "module", None)
        or detect_default_module(project)
    )

    log(f"DevEco: {deveco}", 36)
    log(f"Cangjie: {cangjie}", 36)
    log(f"Module: {module_name}", 36)

    env = os.environ.copy()
    env.update({
        "DEVECO_HOME": str(deveco),
        "DEVECO_SDK_HOME": str(ensure(deveco / "sdk", "DevEco SDK")),
        "CANGJIE_SDK_HOME": str(cangjie),
        "DEVECO_CANGJIE_PATH": str(cangjie),
    })
    setup_cangjie_env(env, cangjie, plat, spec)

    java = ensure(deveco / "jbr", "Java Runtime")
    env["JAVA_HOME"] = str(java)
    merge_path(env, "PATH", java / "bin")
    log(f"Java: {java}", 36)

    ohpm, node, hvigorw = resolve_build_tools(deveco, plat)
    hv = [str(node), str(hvigorw)]
    hv_opts = ["--analyze=normal", "--parallel", "--incremental", "--no-daemon"]

    open(BUILD_LOG, "w", encoding="utf-8").close()

    log("Installing dependencies...", 35)
    run([str(ohpm), "install", "--all", "--registry", str(ohpm_registry), "--strict_ssl", "true" if strict_ssl else "false"], env=env)

    log("Syncing Cangjie resources...", 35)
    run([*hv, "--mode", "module", "-p", f"module={module_name}@default", "SyncCangjieResource", *hv_opts], env=env)

    log("Building HAP...", 35)
    run([*hv, "--mode", "module", "-p", "product=default", "assembleHap", *hv_opts], env=env)

    log("Build complete", 32)

    haps = find_haps(project, module_name)
    return {
        "project_root": str(project),
        "module": module_name,
        "hap": str(haps[-1]) if haps else None,
        "haps": [str(hap) for hap in haps],
        "build_log": str(project / BUILD_LOG),
    }


def emit_json(payload: dict[str, object]) -> None:
    print(json.dumps(payload, ensure_ascii=False))


def parse_args(argv: list[str]) -> argparse.Namespace:
    parser = argparse.ArgumentParser(description="Build a Cangjie HarmonyOS project")
    parser.add_argument("--project-root", default=str(DEFAULT_PROJECT_ROOT), help="Project root path")
    parser.add_argument("--module", default=None, help="HarmonyOS module name. Defaults to config or first module in build-profile.json5.")
    parser.add_argument("--config", action="append", default=None, help="Path to harmonyos-cangjie config TOML. Can be passed multiple times.")
    parser.add_argument("--deveco-home", default=None, help="DevEco Studio install root. Overrides config and built-in default.")
    parser.add_argument("--cangjie-sdk", default=None, help="Cangjie SDK root. Overrides config and built-in default.")
    parser.add_argument("--ohpm-registry", default=None, help="ohpm registry URL. Overrides config and built-in default.")
    ssl = parser.add_mutually_exclusive_group()
    ssl.add_argument("--strict-ssl", dest="strict_ssl", action="store_true", default=None)
    ssl.add_argument("--no-strict-ssl", dest="strict_ssl", action="store_false", default=None)
    parser.add_argument("--json", action="store_true",
                        help='machine-readable stdout only: {"ok": bool, "data"|"error": ..., "hint": ...}; human text goes to stderr')
    return parser.parse_args(argv)


def main(argv: list[str]) -> int:
    global _HUMAN
    args = parse_args(argv)
    if args.json:
        _HUMAN = sys.stderr

    try:
        data = build_pipeline(args)
    except ToolError as exc:
        print(f"\033[31mERROR: {exc}\033[0m", file=sys.stderr, flush=True)
        if exc.hint:
            print(f"hint: {exc.hint}", file=sys.stderr)
        if args.json:
            emit_json({"ok": False, "error": str(exc), "hint": exc.hint or HINT_BUILD_FAILURE})
        return exc.code
    except Exception as exc:  # 意外异常也维持输出契约：stdout 仅 JSON，堆栈走 stderr
        traceback.print_exc(file=sys.stderr)
        if args.json:
            emit_json({"ok": False, "error": f"unexpected error: {exc}", "hint": HINT_BUILD_FAILURE})
        return 1

    if args.json:
        emit_json({
            "ok": True,
            "data": data,
            "hint": "next: install/launch and validate via ui_capture.py; capture runtime logs via hilog_capture.py",
        })
    return 0


if __name__ == "__main__":
    raise SystemExit(main(sys.argv[1:]))
