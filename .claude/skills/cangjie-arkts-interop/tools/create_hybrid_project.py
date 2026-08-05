#!/usr/bin/env python3
"""create_hybrid_project.py — create or repair a Cangjie-ArkTS hybrid HarmonyOS project from templates.

Usage:
    python create_hybrid_project.py --target-dir <dir> [--app-name <name>] [--bundle-name <id>] [--repair]
    python create_hybrid_project.py --list-templates
Exit codes: 0 成功 · 1 业务失败 · 2 参数/环境错误
"""

from __future__ import annotations

import argparse
import json
import re
import shutil
import sys
from pathlib import Path

# UTF-8 stdio 防线（Windows GBK 控制台必备；家族标准片段，逐字复用）
for _stream in (sys.stdout, sys.stderr):
    try:
        _stream.reconfigure(encoding="utf-8", errors="replace")  # type: ignore[attr-defined]
    except (AttributeError, OSError):
        pass


def _load_config_helpers():
    """跨技能导入 harmonyos-cangjie-dev 的分层配置；失败降级为 CLI+默认值并在 stderr 声明降级面。"""
    skills_dir = Path(__file__).resolve().parents[2]
    helper_dir = skills_dir / "harmonyos-cangjie-dev" / "tools"
    if helper_dir.exists():
        sys.path.insert(0, str(helper_dir))
    try:
        from config_loader import first_value, load_harmony_config
        return first_value, load_harmony_config
    except Exception:
        print("warn: config_loader unavailable (need Python>=3.11); layered config ignored", file=sys.stderr)
        return (
            lambda *values: next((v for v in values if v is not None and v != ""), None),
            lambda **_: None,
        )


first_value, load_harmony_config = _load_config_helpers()


# ── 常量 ──────────────────────────────────────────────────────

DEFAULT_TEMPLATE = "cangjie-arkts-hybrid-app"
DEFAULT_APP_NAME = "Cangjie ArkTS Hybrid"
DEFAULT_BUNDLE_NAME = "com.example.hybrid"
DEFAULT_PACKAGE_NAME = "ohos_app_cangjie_entry"
DEFAULT_MODULE_NAME = "entry"
DEFAULT_SDK_VERSION = "6.1.0(23)"
DEFAULT_MODEL_VERSION = "6.1.0"
TEXT_SUFFIXES = {
    "",
    ".cj",
    ".ets",
    ".gitignore",
    ".json",
    ".json5",
    ".lock",
    ".md",
    ".toml",
    ".txt",
    ".ts",
}


# ── 纯函数 ────────────────────────────────────────────────────


def skill_root() -> Path:
    return Path(__file__).resolve().parents[1]


def templates_root() -> Path:
    return skill_root() / "templates"


def json_string_body(value: str) -> str:
    return json.dumps(value, ensure_ascii=False)[1:-1]


def validate_bundle_name(value: str) -> None:
    if not re.match(r"^[A-Za-z][A-Za-z0-9_]*(\.[A-Za-z][A-Za-z0-9_]*)+$", value):
        raise ValueError("bundle name must look like com.example.app")


def validate_identifier(value: str, label: str) -> None:
    if not re.match(r"^[A-Za-z_][A-Za-z0-9_]*$", value):
        raise ValueError(f"{label} must be a valid identifier")


def validate_module_name(value: str) -> None:
    if not re.match(r"^[A-Za-z][A-Za-z0-9_-]*$", value):
        raise ValueError("module name must contain letters, numbers, '_' or '-'")


def validate_sdk_version(value: str) -> None:
    if not re.match(r"^\d+\.\d+\.\d+\(\d+\)$", value):
        raise ValueError("sdk version must look like 6.1.0(23)")


def validate_model_version(value: str) -> None:
    if not re.match(r"^\d+\.\d+\.\d+$", value):
        raise ValueError("model version must look like 6.1.0")


def build_replacements(args: argparse.Namespace) -> dict[str, str]:
    validate_bundle_name(args.bundle_name)
    validate_identifier(args.package_name, "Cangjie package name")
    validate_module_name(args.module_name)
    validate_sdk_version(args.sdk_version)
    validate_model_version(args.model_version)

    return {
        "com.example.myapplication": args.bundle_name,
        "MyApplication": json_string_body(args.app_name),
        "ohos_app_cangjie_entry": args.package_name,
        "libohos_app_cangjie_entry.so": f"lib{args.package_name}.so",
        "libohos_app_cangjie_entry": f"lib{args.package_name}",
        '"name": "entry"': f'"name": "{args.module_name}"',
        '"srcPath": "./entry"': f'"srcPath": "./{args.module_name}"',
        '"modelVersion": "6.1.0"': f'"modelVersion": "{args.model_version}"',
        '"targetSdkVersion": "6.1.0(23)"': f'"targetSdkVersion": "{args.sdk_version}"',
        '"compatibleSdkVersion": "6.1.0(23)"': f'"compatibleSdkVersion": "{args.sdk_version}"',
        "COMPILE_CONDITION_ENTRY": f"COMPILE_CONDITION_{args.module_name.upper().replace('-', '_')}",
    }


def is_text_template(path: Path) -> bool:
    return path.suffix in TEXT_SUFFIXES or path.name in TEXT_SUFFIXES


def render_text(text: str, replacements: dict[str, str]) -> str:
    for old, new in replacements.items():
        text = text.replace(old, new)
    return text


def destination_for(relative: Path, module_name: str, package_name: str) -> Path:
    parts = list(relative.parts)
    if parts and parts[0] == "entry":
        parts[0] = module_name
    mapped = Path(*parts)
    return Path(str(mapped).replace("libohos_app_cangjie_entry", f"lib{package_name}"))


# ── 副作用函数（文件系统读写） ────────────────────────────────


def list_templates() -> list[str]:
    root = templates_root()
    if not root.exists():
        return []
    return sorted(item.name for item in root.iterdir() if item.is_dir())


def ensure_writable_target(target: Path, repair: bool) -> None:
    if target.exists() and target.is_file():
        raise ValueError(f"target path is a file: {target}")
    allowed_existing = {".claude", ".agents"}
    existing = []
    if target.exists():
        existing = [item.name for item in target.iterdir() if item.name not in allowed_existing]
    if existing and not repair:
        raise ValueError(
            f"target directory is not empty: {target}. Use --repair to overwrite template files."
        )


def copy_template(template_dir: Path, target: Path, replacements: dict[str, str], args: argparse.Namespace) -> list[Path]:
    written: list[Path] = []
    for source in sorted(template_dir.rglob("*")):
        if source.is_dir():
            continue
        relative = source.relative_to(template_dir)
        destination = target / destination_for(relative, args.module_name, args.package_name)
        destination.parent.mkdir(parents=True, exist_ok=True)
        if is_text_template(source):
            text = source.read_text(encoding="utf-8")
            destination.write_text(render_text(text, replacements), encoding="utf-8", newline="\n")
        else:
            shutil.copy2(source, destination)
        written.append(destination)
    return written


def verify_project(target: Path, module_name: str, package_name: str) -> list[str]:
    lib_name = f"lib{package_name}"
    required = [
        "build-profile.json5",
        "oh-package.json5",
        "hvigorfile.ts",
        "hvigor/hvigor-config.json5",
        "AppScope/app.json5",
        f"{module_name}/build-profile.json5",
        f"{module_name}/cjpm.toml",
        f"{module_name}/oh-package.json5",
        f"{module_name}/src/main/module.json5",
        f"{module_name}/src/main/cangjie/index.cj",
        f"{module_name}/src/main/cangjie/types/{lib_name}/Index.d.ts",
        f"{module_name}/src/main/cangjie/types/{lib_name}/oh-package.json5",
        f"{module_name}/src/main/ets/entryability/EntryAbility.ets",
        f"{module_name}/src/main/ets/pages/Index.ets",
        f"{module_name}/src/main/resources/base/profile/main_pages.json",
    ]
    return [item for item in required if not (target / item).exists()]


# ── main ──────────────────────────────────────────────────────


def parse_args(argv: list[str]) -> argparse.Namespace:
    parser = argparse.ArgumentParser(
        description="Create or repair a Cangjie-ArkTS hybrid HarmonyOS project."
    )
    parser.add_argument("target", nargs="?", help="project directory")
    parser.add_argument("--target-dir", dest="target_dir", help="project directory")
    parser.add_argument("--template", default=DEFAULT_TEMPLATE, help="template name under templates/")
    parser.add_argument("--list-templates", action="store_true", help="list available templates and exit")
    parser.add_argument("--repair", action="store_true", help="overwrite template-owned files")
    parser.add_argument("--config", action="append", default=None, help="Path to harmonyos-cangjie config TOML.")
    parser.add_argument("--app-name", default=None, help="display name")
    parser.add_argument("--bundle-name", default=None, help="HarmonyOS bundle name")
    parser.add_argument("--package-name", default=None, help="Cangjie package/library name")
    parser.add_argument("--module-name", default=None, help="HarmonyOS module directory/name")
    parser.add_argument("--sdk-version", default=None, help="target and compatible SDK version")
    parser.add_argument("--model-version", default=None, help="oh-package/hvigor model version")
    return parser.parse_args(argv)


def main(argv: list[str]) -> int:
    args = parse_args(argv)
    if args.list_templates:
        for name in list_templates():
            print(name)
        return 0

    target_arg = args.target_dir or args.target
    if not target_arg:
        print("error: target directory is required", file=sys.stderr)
        return 2

    # 参数/环境解析：四级链 CLI > 分层配置 > 默认值；失败退 2
    try:
        target = Path(target_arg).resolve()
        cfg = load_harmony_config(project_root=target, config_paths=args.config)
        new_project = getattr(cfg, "new_project", None)
        args.app_name = first_value(args.app_name, getattr(new_project, "app_name", None), DEFAULT_APP_NAME)
        args.bundle_name = first_value(args.bundle_name, getattr(new_project, "bundle_name", None), DEFAULT_BUNDLE_NAME)
        args.package_name = first_value(args.package_name, getattr(new_project, "package_name", None), DEFAULT_PACKAGE_NAME)
        args.module_name = first_value(args.module_name, getattr(new_project, "module_name", None), DEFAULT_MODULE_NAME)
        args.sdk_version = first_value(args.sdk_version, getattr(new_project, "sdk_version", None), DEFAULT_SDK_VERSION)
        args.model_version = first_value(args.model_version, getattr(new_project, "model_version", None), DEFAULT_MODEL_VERSION)
        template_dir = (templates_root() / args.template).resolve()
        base = templates_root().resolve()
        if not template_dir.is_dir() or base not in template_dir.parents:
            raise ValueError(f"template not found: {args.template}")
        replacements = build_replacements(args)
    except Exception as exc:
        print(f"error: {exc}", file=sys.stderr)
        return 2

    # 业务执行：复制模板并校验产物；失败退 1
    try:
        ensure_writable_target(target, args.repair)
        target.mkdir(parents=True, exist_ok=True)
        written = copy_template(template_dir, target, replacements, args)
        missing = verify_project(target, args.module_name, args.package_name)
        if missing:
            raise ValueError("hybrid project creation verification failed: " + ", ".join(missing))
    except Exception as exc:
        print(f"error: {exc}", file=sys.stderr)
        return 1

    print(f"project: {target}")
    print(f"template: {args.template}")
    print(f"bundle: {args.bundle_name}")
    print(f"package: {args.package_name}")
    print(f"module: {args.module_name}")
    print(f"files_written: {len(written)}")
    print("next: run cangjie-arkts-interop/tools/hybrid_project_check.py from your installed skills directory")
    return 0


if __name__ == "__main__":
    raise SystemExit(main(sys.argv[1:]))
