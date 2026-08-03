#!/usr/bin/env python3
"""build_recovery.py — Build wrapper with safe recovery for known Cangjie/HarmonyOS cache failures.

Usage:
    python build_recovery.py --project-root <dir> [--retry] [--module <name>] [--json]
    python build_recovery.py --project-root <dir> --clean-only
Exit codes: 0 成功 · 1 业务失败（构建失败） · 2 参数/环境错误
"""

from __future__ import annotations

import argparse
import json
import shutil
import subprocess
import sys
import traceback
from pathlib import Path

# UTF-8 stdio 防线（Windows GBK 控制台必备；家族标准片段，逐字复用）
for _stream in (sys.stdout, sys.stderr):
    try:
        _stream.reconfigure(encoding="utf-8", errors="replace")  # type: ignore[attr-defined]
    except (AttributeError, OSError):
        pass


# ── 常量 ──────────────────────────────────────────────────────

KNOWN_CACHE_FAILURES = (
    "DataModelException: This data is not DataModelString",
    "DepModel::loadDepIncrementalCache",
)
HINT_ON_FAILURE = "inspect build.log via build_analyzer.py; if a known cache marker appears, re-run with --retry"


# ── 纯函数 ────────────────────────────────────────────────────


def is_relative_to(child: Path, parent: Path) -> bool:
    try:
        child.relative_to(parent)
        return True
    except ValueError:
        return False


def cache_paths(project: Path, module: str = "entry") -> list[Path]:
    return [
        project / ".hvigor" / "cache",
        project / ".hvigor" / "dependencyMap",
        project / module / "build" / "default" / "intermediates" / "cj",
        project / module / "build" / "default" / "intermediates" / "loader",
        project / module / "build" / "default" / "intermediates" / "source_map",
    ]


def has_known_cache_failure(log: str) -> bool:
    return any(marker in log for marker in KNOWN_CACHE_FAILURES)


def newest_hap(project: Path, module: str) -> str | None:
    """Newest built .hap under <module>/build (best effort, mirrors runtime_fallback)."""
    try:
        haps = sorted((project / module / "build").glob("**/*.hap"), key=lambda p: p.stat().st_mtime)
    except OSError:
        haps = []
    return str(haps[-1]) if haps else None


def contract_rc(rc: int) -> int:
    """将子进程退出码压回 0/1/2 契约（0 成功 · 2 参数/环境 · 其余一律 1 业务失败）。"""
    return rc if rc in (0, 2) else 1


# ── 副作用函数 ────────────────────────────────────────────────

_HUMAN = sys.stdout  # --json 时切至 stderr，保证 stdout 只输出 JSON


def info(msg: str) -> None:
    print(msg, file=_HUMAN, flush=True)


def _child_stdout():
    """--json 模式下子进程（build.py / build_analyzer.py）的输出改道 stderr。"""
    return None if _HUMAN is sys.stdout else sys.stderr


def remove_inside_project(project: Path, target: Path) -> Path | None:
    resolved = target.resolve()
    if not is_relative_to(resolved, project):
        raise RuntimeError(f"Refusing to remove path outside project: {resolved}")
    if not resolved.exists():
        return None
    if resolved.is_dir():
        shutil.rmtree(resolved)
    else:
        resolved.unlink()
    info(f"removed: {resolved}")
    return resolved


def clean_caches(project: Path, module: str) -> list[str]:
    cleaned: list[str] = []
    for path in cache_paths(project, module):
        removed = remove_inside_project(project, path)
        if removed is not None:
            cleaned.append(str(removed))
    return cleaned


def run_build(project: Path, build_script: Path, extra_args: list[str]) -> int:
    cmd = [sys.executable, str(build_script), "--project-root", str(project)]
    cmd.extend(extra_args)
    info(">>> " + " ".join(cmd))
    return subprocess.call(cmd, stdout=_child_stdout())


def read_build_log(project: Path) -> str:
    log = project / "build.log"
    if not log.exists():
        return ""
    return log.read_text(encoding="utf-8", errors="replace")


def print_analysis(project: Path) -> None:
    analyzer = Path(__file__).resolve().parent / "build_analyzer.py"
    if not analyzer.exists():
        return
    info("build log analysis:")
    subprocess.call([sys.executable, str(analyzer), "--project-root", str(project)], stdout=_child_stdout())


def emit_json(payload: dict[str, object]) -> None:
    print(json.dumps(payload, ensure_ascii=False))


# ── main ──────────────────────────────────────────────────────


def parse_args(argv: list[str]) -> argparse.Namespace:
    parser = argparse.ArgumentParser(description="Build with safe recovery for known Cangjie/HarmonyOS cache failures.")
    parser.add_argument(
        "--project-root",
        default=".",
        help="HarmonyOS project root. Defaults to the current working directory.",
    )
    parser.add_argument(
        "--build-script",
        default=None,
        help="Path to the existing build.py, relative to workspace or absolute.",
    )
    parser.add_argument(
        "--workspace-root",
        default=None,
        help="Workspace root used to resolve relative build-script paths. Defaults to the current working directory.",
    )
    parser.add_argument(
        "--retry",
        action="store_true",
        help="Retry automatically after cleaning known project-local caches.",
    )
    parser.add_argument(
        "--clean-only",
        action="store_true",
        help="Only clean project-local caches; do not run a build.",
    )
    parser.add_argument("--config", action="append", default=None, help="Path to harmonyos-cangjie config TOML.")
    parser.add_argument("--module", default=None, help="HarmonyOS module override passed to build.py.")
    parser.add_argument("--deveco-home", default=None, help="DevEco Studio install root passed to build.py.")
    parser.add_argument("--cangjie-sdk", default=None, help="Cangjie SDK root passed to build.py.")
    parser.add_argument("--ohpm-registry", default=None, help="ohpm registry URL passed to build.py.")
    ssl = parser.add_mutually_exclusive_group()
    ssl.add_argument("--strict-ssl", dest="strict_ssl", action="store_true", default=None)
    ssl.add_argument("--no-strict-ssl", dest="strict_ssl", action="store_false", default=None)
    parser.add_argument("--json", action="store_true",
                        help='machine-readable stdout only: {"ok": bool, "data"|"error": ..., "hint": ...}; human/build text goes to stderr')
    return parser.parse_args(argv)


def _error(as_json: bool, message: str, hint: str) -> None:
    print(f"error: {message}", file=sys.stderr)
    print(f"hint: {hint}", file=sys.stderr)
    if as_json:
        emit_json({"ok": False, "error": message, "hint": hint})


def main(argv: list[str]) -> int:
    global _HUMAN
    args = parse_args(argv)
    if args.json:
        _HUMAN = sys.stderr

    default_workspace = Path.cwd()
    workspace = Path(args.workspace_root).expanduser().resolve() if args.workspace_root else default_workspace
    project = Path(args.project_root).expanduser().resolve()
    if args.build_script:
        build_script = Path(args.build_script)
        if not build_script.is_absolute():
            build_script = (workspace / build_script).resolve()
    else:
        local_build_script = Path(__file__).resolve().parent / "build.py"
        if local_build_script.exists():
            build_script = local_build_script
        else:
            _error(args.json,
                   "build.py not found next to this script (the legacy skills/harmonyos-build layout is gone)",
                   "pass --build-script <path-to-build.py>")
            return 2

    if not project.exists():
        _error(args.json, f"project root not found: {project}", "pass --project-root pointing at the HarmonyOS project")
        return 2
    if not build_script.exists():
        _error(args.json, f"build script not found: {build_script}", "pass --build-script <path-to-build.py>")
        return 2

    module_for_cache = args.module or "entry"

    try:
        if args.clean_only:
            cleaned = clean_caches(project, module_for_cache)
            if args.json:
                emit_json({
                    "ok": True,
                    "data": {"project_root": str(project), "cleaned": cleaned},
                    "hint": "caches cleaned; re-run the build (build.py or build_recovery.py)",
                })
            return 0

        extra: list[str] = []
        for config_path in args.config or []:
            extra.extend(["--config", config_path])
        for flag in ("module", "deveco_home", "cangjie_sdk", "ohpm_registry"):
            value = getattr(args, flag)
            if value:
                extra.extend(["--" + flag.replace("_", "-"), value])
        if args.strict_ssl is True:
            extra.append("--strict-ssl")
        elif args.strict_ssl is False:
            extra.append("--no-strict-ssl")

        data: dict[str, object] = {
            "project_root": str(project),
            "build_script": str(build_script),
            "build_log": str(project / "build.log"),
            "cleaned": [],
            "retried": False,
        }

        first = run_build(project, build_script, extra)
        data["first_exit_code"] = first
        data["final_exit_code"] = first
        if first == 0:
            data["hap"] = newest_hap(project, module_for_cache)
            if args.json:
                emit_json({"ok": True, "data": data,
                           "hint": "next: install/launch and validate via ui_capture.py"})
            return 0
        print_analysis(project)
        if not args.retry:
            if args.json:
                emit_json({"ok": False, "error": data, "hint": HINT_ON_FAILURE})
            return contract_rc(first)

        log = read_build_log(project)
        if not has_known_cache_failure(log):
            info("build failed, but no known cache failure marker was found; not cleaning automatically")
            if args.json:
                emit_json({"ok": False, "error": data,
                           "hint": "no known cache marker in build.log; fix the reported compile/config errors (build_analyzer.py)"})
            return contract_rc(first)

        info("known cjpm incremental cache failure detected; cleaning project-local caches")
        data["cleaned"] = clean_caches(project, module_for_cache)
        data["retried"] = True

        second = run_build(project, build_script, extra)
        data["final_exit_code"] = second
        if second == 0:
            data["hap"] = newest_hap(project, module_for_cache)
            if args.json:
                emit_json({"ok": True, "data": data,
                           "hint": "recovered after cache clean; next: install/launch and validate via ui_capture.py"})
            return 0
        if args.json:
            emit_json({"ok": False, "error": data, "hint": HINT_ON_FAILURE})
        return contract_rc(second)
    except Exception as exc:  # 意外异常也维持输出契约：stdout 仅 JSON，堆栈走 stderr
        traceback.print_exc(file=sys.stderr)
        if args.json:
            emit_json({"ok": False, "error": f"unexpected error: {exc}", "hint": HINT_ON_FAILURE})
        return 1


if __name__ == "__main__":
    raise SystemExit(main(sys.argv[1:]))
