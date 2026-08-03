#!/usr/bin/env python3
"""build_analyzer.py — Analyze HarmonyOS/Cangjie build logs and summarize actionable failures.

Usage:
    python build_analyzer.py [--project-root <dir>] [--log <file>] [--json]
Exit codes: 0 成功（日志无失败证据） · 1 业务失败（日志含构建失败证据） · 2 参数/环境错误（日志缺失）
"""

from __future__ import annotations

import argparse
import json
import re
import sys
from dataclasses import dataclass, asdict
from pathlib import Path

# UTF-8 stdio 防线（Windows GBK 控制台必备；家族标准片段，逐字复用）
for _stream in (sys.stdout, sys.stderr):
    try:
        _stream.reconfigure(encoding="utf-8", errors="replace")  # type: ignore[attr-defined]
    except (AttributeError, OSError):
        pass


# ── 常量 ──────────────────────────────────────────────────────

ANSI_RE = re.compile(r"\x1b\[[0-9;]*[A-Za-z]")
FAILED_TASK_RE = re.compile(r"Failed\s+(:[^\s.]+)")
FILE_LOC_RE = re.compile(r"==>\s+(.+?):(\d+):(\d+):")
HINT_ON_FAILURE = "fix the findings at the listed locations; cjpm incremental cache failures: build_recovery.py --retry"
HINT_ON_SUCCESS = "no failure evidence in the log; proceed to runtime/UI validation when the task changes behavior"


@dataclass
class Finding:
    code: str
    severity: str
    title: str
    evidence: str
    suggestion: str


# ── 纯函数 ────────────────────────────────────────────────────


def clean_text(raw: str) -> str:
    return ANSI_RE.sub("", raw).replace("\ufeff", "").replace("\r\n", "\n").replace("\r", "\n")


def first_error_block(lines: list[str]) -> list[str]:
    start = None
    for i, line in enumerate(lines):
        lower = line.lower()
        if "error:" in lower or "error code:" in lower or "failed :" in lower:
            start = i
            break
    if start is None:
        return []

    end = min(len(lines), start + 80)
    for i in range(start + 1, min(len(lines), start + 120)):
        lower = lines[i].lower()
        if "try the following" in lower or "* try:" in lower or "> hvigor error: build failed" in lower:
            end = i
            break
    return lines[start:end]


def collect_locations(lines: list[str]) -> list[dict[str, object]]:
    locations = []
    for line in lines:
        match = FILE_LOC_RE.search(line)
        if match:
            locations.append({
                "file": match.group(1),
                "line": int(match.group(2)),
                "column": int(match.group(3)),
            })
    return locations


def detect_findings(text: str) -> list[Finding]:
    lower = text.lower()
    findings: list[Finding] = []

    def add(code: str, title: str, evidence: str, suggestion: str, severity: str = "error") -> None:
        findings.append(Finding(code, severity, title, evidence, suggestion))

    if "datamodelexception: this data is not datamodelstring" in lower or "depmodel::loaddepincrementalcache" in lower:
        add(
            "cjpm_incremental_cache",
            "cjpm incremental dependency cache is likely corrupted or incompatible",
            "DataModelException / DepModel::loadDepIncrementalCache",
            "Use build_recovery.py --retry to clean project-local Hvigor/Cangjie intermediates. If it repeats, try [profile.build] incremental = false.",
        )

    if "expected type name after ':'" in lower:
        add(
            "arkts_object_literal_in_cangjie",
            "ArkTS-style object literal was used in Cangjie ArkUI code",
            "expected type name after ':'",
            "Replace calls such as .margin({left: 20}) with Cangjie named parameters and units, for example .margin(left: 20.vp).",
        )

    if "'trim' is not a member" in lower or '"trim" is not a member' in lower:
        add(
            "string_trim_missing",
            "Cangjie String does not provide JS/ArkTS trim() in this environment",
            "trim is not a member of String",
            "Check Cangjie String docs. Use trimAscii() for ASCII whitespace when appropriate.",
        )

    if "'length' is not a member" in lower and "observedarraylist" in lower:
        add(
            "observed_array_list_length",
            "ObservedArrayList uses size, not length",
            "length is not a member of ObservedArrayList",
            "Replace .length with .size.",
        )

    if "'add' is not a member" in lower and "observedarraylist" in lower:
        add(
            "observed_array_list_add",
            "ObservedArrayList appends with append(), not add()",
            "add is not a member of ObservedArrayList",
            "Replace .add(value) with .append(value).",
        )

    if "no signingconfigs" in lower:
        add(
            "missing_signing_config",
            "Signing config is missing but unsigned local build may still be usable",
            "No signingConfigs profile is configured",
            "Treat as non-blocking for local unsigned HAP validation unless the task requires signed release output.",
            severity="warning",
        )

    failed_markers = ("build failed", "failed :", "error code:", "tools execution failed", "invalid options")
    if "build successful" in lower and not any(marker in lower for marker in failed_markers) and not any(f.severity == "error" for f in findings):
        add(
            "build_successful",
            "Build completed successfully",
            "BUILD SUCCESSFUL",
            "Proceed to runtime/UI validation when the task changes behavior.",
            severity="info",
        )

    return findings


def analyze(log_path: Path) -> dict[str, object]:
    raw = log_path.read_text(encoding="utf-8", errors="replace") if log_path.exists() else ""
    text = clean_text(raw)
    lines = text.splitlines()
    failed_tasks = []
    for line in lines:
        match = FAILED_TASK_RE.search(line)
        if match and match.group(1) not in failed_tasks:
            failed_tasks.append(match.group(1))

    block = first_error_block(lines)
    findings = detect_findings(text)
    return {
        "log": str(log_path),
        "exists": log_path.exists(),
        "failed_tasks": failed_tasks,
        "locations": collect_locations(lines),
        "first_error_block": block,
        "findings": [asdict(f) for f in findings],
    }


def build_failed(result: dict[str, object]) -> bool:
    """业务判定：日志是否包含构建失败证据（failed task / error 级 finding / 首个错误块）。"""
    if result.get("failed_tasks"):
        return True
    if any(f.get("severity") == "error" for f in result.get("findings") or []):
        return True
    return bool(result.get("first_error_block"))


def render_text(result: dict[str, object]) -> str:
    lines = ["# Build Log Analysis", ""]
    lines.append(f"- log: `{result['log']}`")
    lines.append(f"- exists: {result['exists']}")
    failed_tasks = result.get("failed_tasks") or []
    lines.append(f"- failed_tasks: {', '.join(failed_tasks) if failed_tasks else 'none detected'}")

    locations = result.get("locations") or []
    if locations:
        lines.extend(["", "## Locations"])
        for loc in locations[:10]:
            lines.append(f"- `{loc['file']}:{loc['line']}:{loc['column']}`")

    findings = result.get("findings") or []
    if findings:
        lines.extend(["", "## Findings"])
        for item in findings:
            lines.append(f"- [{item['severity']}] `{item['code']}`: {item['title']}")
            lines.append(f"  evidence: {item['evidence']}")
            lines.append(f"  suggestion: {item['suggestion']}")

    block = result.get("first_error_block") or []
    if block:
        lines.extend(["", "## First Error Block", "", "```text"])
        lines.extend(block[:80])
        lines.append("```")

    return "\n".join(lines)


# ── main ──────────────────────────────────────────────────────


def emit_json(payload: dict[str, object]) -> None:
    print(json.dumps(payload, ensure_ascii=False, indent=2))


def parse_args(argv: list[str]) -> argparse.Namespace:
    parser = argparse.ArgumentParser(description="Analyze a HarmonyOS/Cangjie build log.")
    parser.add_argument("--project-root", default=".", help="Project root containing build.log.")
    parser.add_argument("--log", default=None, help="Explicit build log path.")
    parser.add_argument("--format", choices=["text", "json"], default="text",
                        help="Output format; 'json' is equivalent to --json.")
    parser.add_argument("--json", action="store_true",
                        help='machine-readable stdout only: {"ok": bool, "data"|"error": ..., "hint": ...}')
    return parser.parse_args(argv)


def main(argv: list[str]) -> int:
    args = parse_args(argv)
    as_json = args.json or args.format == "json"

    project = Path(args.project_root).expanduser().resolve()
    log_path = Path(args.log).expanduser().resolve() if args.log else project / "build.log"

    if not log_path.exists():
        message = f"build log not found: {log_path}"
        hint = "run build.py (it writes build.log to the project root) or pass --log <file>"
        if as_json:
            emit_json({"ok": False, "error": message, "hint": hint})
        else:
            print(f"error: {message}", file=sys.stderr)
            print(f"hint: {hint}", file=sys.stderr)
        return 2

    result = analyze(log_path)
    failed = build_failed(result)

    if as_json:
        if failed:
            emit_json({"ok": False, "error": result, "hint": HINT_ON_FAILURE})
        else:
            emit_json({"ok": True, "data": result, "hint": HINT_ON_SUCCESS})
    else:
        print(render_text(result))
    return 1 if failed else 0


if __name__ == "__main__":
    raise SystemExit(main(sys.argv[1:]))
