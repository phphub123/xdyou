#!/usr/bin/env python3
"""runtime_fallback.py — Local project-runtime detection fallback (no config_loader required).

Usage:
    from runtime_fallback import detect_project_runtime  # import-only library, no CLI
Exit codes: 不适用（纯导入模块，无 CLI 入口，不触碰 stdio）

Parses AppScope/app.json5 and <module>/src/main/module.json5 with regex so the
harmonyos-build-run-diagnose tools keep detecting bundleName/ability/module
even when the sibling harmonyos-cangjie-dev skill (config_loader.py) is
missing. Keep this module dependency-free and importable on any Python 3.x.
"""

from __future__ import annotations

import re
from pathlib import Path
from types import SimpleNamespace


def _read_text(path: Path, warnings: list) -> str | None:
    try:
        return path.read_text(encoding="utf-8", errors="replace")
    except OSError as exc:
        warnings.append(f"cannot read {path}: {exc}")
        return None


def detect_project_runtime(project_root, module=None, **_ignored):
    """Best-effort bundle/ability/module/hap detection from project json5 files.

    Mirrors the attribute surface of config_loader.detect_project_runtime
    (bundle / ability / module / hap / warnings) so callers need no branching.
    """
    root = Path(project_root).expanduser()
    warnings: list[str] = []
    bundle = None
    ability = None
    resolved_module = module

    app_json = root / "AppScope" / "app.json5"
    if app_json.is_file():
        text = _read_text(app_json, warnings)
        if text:
            match = re.search(r'"bundleName"\s*:\s*"([^"]+)"', text)
            if match:
                bundle = match.group(1)

    candidates: list[str] = [module] if module else []
    profile = root / "build-profile.json5"
    if profile.is_file():
        text = _read_text(profile, warnings)
        if text:
            match = re.search(r'"modules"\s*:\s*\[\s*\{\s*"name"\s*:\s*"([^"]+)"', text, re.S)
            if match and match.group(1) not in candidates:
                candidates.append(match.group(1))
    if "entry" not in candidates:
        candidates.append("entry")

    for candidate in candidates:
        module_json = root / candidate / "src" / "main" / "module.json5"
        if not module_json.is_file():
            continue
        text = _read_text(module_json, warnings)
        if not text:
            continue
        match = re.search(r'"module"\s*:\s*\{.*?"name"\s*:\s*"([^"]+)"', text, re.S)
        if match:
            resolved_module = match.group(1)
        match = re.search(r'"name"\s*:\s*"(\w*Ability\w*)"', text)
        if match:
            ability = match.group(1)
        break

    hap = None
    if resolved_module:
        try:
            haps = sorted(
                (root / resolved_module / "build").glob("**/*.hap"),
                key=lambda p: p.stat().st_mtime,
            )
        except OSError:
            haps = []
        if haps:
            hap = str(haps[-1])

    if bundle is None and ability is None:
        warnings.append(
            "local fallback found no bundle/ability under "
            f"{root} (checked AppScope/app.json5 and modules {candidates})"
        )
    return SimpleNamespace(
        bundle=bundle,
        ability=ability,
        module=resolved_module,
        hap=hap,
        warnings=warnings,
    )
