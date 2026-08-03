#!/usr/bin/env python3
"""hilog_capture.py — Bounded HarmonyOS hilog capture with severity summary (clear → launch → capture → summarize).

Usage:
    python hilog_capture.py --out <dir> [--project-root <dir>] [--seconds 8] [--target <sn>]
    python hilog_capture.py --out <dir> --bundle <bundle> --ability <ability> [--no-launch] [--no-clear]
Exit codes: 0 成功 · 1 业务失败（设备不可用/进程未拉起） · 2 参数/环境错误
"""

from __future__ import annotations

import argparse
import shutil
import subprocess
import sys
import time
from pathlib import Path

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
        from config_loader import detect_project_runtime, first_value, load_harmony_config
        return detect_project_runtime, first_value, load_harmony_config
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
        )


detect_project_runtime, first_value, load_harmony_config = _load_config_helpers()


# ── 常量 ──────────────────────────────────────────────────────

DEFAULT_HDC = Path(r"C:\Program Files\Huawei\DevEco Studio\sdk\default\openharmony\toolchains\hdc.exe")
EMULATOR_TCONN_PORTS = (5555, 5557, 5554, 5559)


# ── 纯函数 ────────────────────────────────────────────────────


def hdc_cmd(hdc: Path, target: str | None, *args: str) -> list[str]:
    cmd = [str(hdc)]
    if target:
        cmd.extend(["-t", target])
    cmd.extend(args)
    return cmd


def summarize(log_file: Path) -> dict[str, int]:
    counts = {"FATAL": 0, "ERROR": 0, "WARN": 0, "INFO": 0}
    if not log_file.exists():
        return counts
    for line in log_file.read_text(encoding="utf-8", errors="replace").splitlines():
        upper = line.upper()
        if " F " in upper or "FATAL" in upper:
            counts["FATAL"] += 1
        elif " E " in upper or "ERROR" in upper:
            counts["ERROR"] += 1
        elif " W " in upper or "WARN" in upper:
            counts["WARN"] += 1
        elif " I " in upper or "INFO" in upper:
            counts["INFO"] += 1
    return counts


# ── 副作用函数（hdc 交互） ────────────────────────────────────


def resolve_hdc(explicit: str | None = None) -> Path:
    if explicit:
        return Path(explicit).expanduser()
    found = shutil.which("hdc")
    if found:
        return Path(found)
    return DEFAULT_HDC


def run(cmd: list[str], timeout: int = 30) -> str:
    try:
        proc = subprocess.run(cmd, capture_output=True, text=True, errors="replace", timeout=timeout)
    except subprocess.TimeoutExpired:
        return f"[timeout after {timeout}s] {' '.join(cmd)}"
    return (proc.stdout + proc.stderr).strip()


def list_online_targets(hdc: Path) -> list[str]:
    out = run([str(hdc), "list", "targets"], timeout=15)
    return [
        t.strip() for t in out.splitlines()
        if t.strip() and "Empty" not in t and "not recognized" not in t and "[Fail]" not in t
    ]


def discover_emulator_targets(hdc: Path) -> list[str]:
    """No target online: probe common local emulator ports via hdc tconn."""
    for port in EMULATOR_TCONN_PORTS:
        addr = f"127.0.0.1:{port}"
        print(f"no hdc target online; trying emulator at {addr} ...")
        run([str(hdc), "tconn", addr], timeout=10)
        targets = list_online_targets(hdc)
        if targets:
            return targets
    return []


def wait_for_process(hdc: Path, target: str | None, bundle: str, attempts: int = 10, interval: float = 1.0) -> str:
    """Poll pidof until the bundle process exists; aa start success alone does not guarantee spawn."""
    for i in range(attempts):
        out = run(hdc_cmd(hdc, target, "shell", "pidof", bundle), timeout=10)
        first = out.split()[0] if out.split() else ""
        if first.isdigit():
            return first
        if i + 1 < attempts:
            time.sleep(interval)
    return ""


def capture_process(cmd: list[str], out_file: Path, seconds: int) -> None:
    with out_file.open("w", encoding="utf-8", errors="replace") as fh:
        proc = subprocess.Popen(cmd, stdout=fh, stderr=subprocess.STDOUT, text=True, errors="replace")
        try:
            proc.wait(timeout=seconds)
        except subprocess.TimeoutExpired:
            proc.terminate()
            try:
                proc.wait(timeout=3)
            except subprocess.TimeoutExpired:
                proc.kill()
                proc.wait(timeout=3)


# ── main ──────────────────────────────────────────────────────


def _error(message: str, hint: str) -> None:
    print(f"error: {message}", file=sys.stderr)
    print(f"hint: {hint}", file=sys.stderr)


def parse_args(argv: list[str]) -> argparse.Namespace:
    parser = argparse.ArgumentParser(description="Bounded HarmonyOS hilog capture for Agent diagnostics.")
    parser.add_argument("--bundle", default=None)
    parser.add_argument("--ability", default=None)
    parser.add_argument("--module", default=None)
    parser.add_argument("--project-root", default=".")
    parser.add_argument("--out", required=True)
    parser.add_argument("--target", default=None)
    parser.add_argument("--hdc", default=None)
    parser.add_argument("--config", action="append", default=None, help="Path to harmonyos-cangjie config TOML.")
    parser.add_argument("--seconds", type=int, default=8)
    parser.add_argument("--no-launch", action="store_true")
    parser.add_argument("--no-clear", action="store_true")
    return parser.parse_args(argv)


def main(argv: list[str]) -> int:
    args = parse_args(argv)

    project = Path(args.project_root).expanduser().resolve()
    cfg = load_harmony_config(project_root=project, config_paths=args.config)
    toolchain_cfg = getattr(cfg, "toolchain", None)
    device_cfg = getattr(cfg, "device", None)
    runtime_cfg = getattr(cfg, "runtime", None)

    configured_module = getattr(runtime_cfg, "module", None) if runtime_cfg else None
    if not args.module:
        args.module = configured_module
    detected = detect_project_runtime(project, module=args.module)
    for warning in getattr(detected, "warnings", []) or []:
        print(f"WARN: {warning}")
    args.bundle = first_value(args.bundle, getattr(runtime_cfg, "bundle", None) if runtime_cfg else None, getattr(detected, "bundle", None))
    args.ability = first_value(args.ability, getattr(runtime_cfg, "ability", None) if runtime_cfg else None, getattr(detected, "ability", None))
    args.module = first_value(args.module, getattr(detected, "module", None))
    if not args.target:
        args.target = getattr(device_cfg, "target", None) if device_cfg else None

    if not args.bundle:
        _error("bundle not detected", "pass --bundle, run inside the project (--project-root), or set [runtime].bundle as an advanced override")
        return 2
    if not args.ability:
        _error("ability not detected", "pass --ability, run inside the project (--project-root), or set [runtime].ability as an advanced override")
        return 2

    hdc = resolve_hdc(args.hdc or (getattr(toolchain_cfg, "hdc", None) if toolchain_cfg else None))
    if not hdc.exists():
        _error(f"hdc not found: {hdc}", "install DevEco Studio toolchains, configure [toolchain].hdc, or pass --hdc")
        return 2

    # Device routing priority: --target > [device].target > sole online device.
    # With nothing online, probe common local emulator ports before giving up.
    targets = list_online_targets(hdc)
    if not targets:
        targets = discover_emulator_targets(hdc)
    if not args.target:
        if len(targets) == 1:
            args.target = targets[0]
            print(f"hdc target resolved: {args.target}")
        elif len(targets) > 1:
            _error("multiple hdc targets online: " + ", ".join(targets),
                   "pass --target <sn> or set [device].target")
            return 2
        else:
            ports = "/".join(str(p) for p in EMULATOR_TCONN_PORTS)
            _error(f"no hdc device/emulator online (also tried hdc tconn 127.0.0.1:{{{ports}}})",
                   "connect a USB device or start the emulator, then re-run; or pass --target <sn>")
            return 1
    elif targets and args.target not in targets:
        print(f"warn: requested target {args.target} not in online list: {', '.join(targets)}")

    out_dir = Path(args.out)
    out_dir.mkdir(parents=True, exist_ok=True)

    if not args.no_clear:
        print(run(hdc_cmd(hdc, args.target, "shell", "hilog", "-r"), timeout=20))

    if not args.no_launch:
        launch_args = ["shell", "aa", "start", "-a", args.ability, "-b", args.bundle]
        if args.module:
            launch_args.extend(["-m", args.module])
        pid = ""
        for attempt in range(1, 4):  # initial launch + up to 2 relaunches
            print(run(hdc_cmd(hdc, args.target, *launch_args), timeout=20))
            pid = wait_for_process(hdc, args.target, args.bundle)
            if pid:
                print(f"app process confirmed: {args.bundle} pid={pid}")
                break
            print(f"warn: aa start reported success but no {args.bundle} process found (attempt {attempt}/3)")
        if not pid:
            _error(f"{args.bundle} process did not spawn after 3 aa start attempts "
                   "(aa start success does not imply process spawn)",
                   "check hilog output or launch the app manually, then re-run with --no-launch")
            return 1
        time.sleep(1)

    full_log = out_dir / "hilog_full.txt"
    err_log = out_dir / "hilog_error.txt"
    app_log = out_dir / "hilog_app.txt"

    capture_process(hdc_cmd(hdc, args.target, "shell", "hilog"), full_log, args.seconds)
    capture_process(hdc_cmd(hdc, args.target, "shell", "hilog", "-L", "E"), err_log, max(3, min(args.seconds, 8)))

    lines = []
    if full_log.exists():
        for line in full_log.read_text(encoding="utf-8", errors="replace").splitlines():
            if args.bundle in line:
                lines.append(line)
    app_log.write_text("\n".join(lines), encoding="utf-8")

    counts = summarize(full_log)
    app_counts = summarize(app_log)
    summary = out_dir / "hilog_summary.md"
    summary.write_text(
        "\n".join([
            "# hilog Summary",
            "",
            f"- bundle: `{args.bundle}`",
            f"- ability: `{args.ability}`",
            f"- target: `{args.target}`",
            f"- capture_seconds: {args.seconds}",
            f"- full_log: `{full_log}`",
            f"- error_log: `{err_log}`",
            f"- app_log: `{app_log}`",
            "",
            "## Level Counts (full log)",
            "",
            f"- FATAL: {counts['FATAL']}",
            f"- ERROR: {counts['ERROR']}",
            f"- WARN: {counts['WARN']}",
            f"- INFO: {counts['INFO']}",
            "",
            "## App Lines",
            "",
            f"- Lines containing bundle name: {len(lines)}",
            f"- App-line FATAL: {app_counts['FATAL']}",
            f"- App-line ERROR: {app_counts['ERROR']}",
            f"- App-line WARN: {app_counts['WARN']}",
            f"- App-line INFO: {app_counts['INFO']}",
        ]),
        encoding="utf-8",
    )
    print(summary)
    return 0


if __name__ == "__main__":
    raise SystemExit(main(sys.argv[1:]))
