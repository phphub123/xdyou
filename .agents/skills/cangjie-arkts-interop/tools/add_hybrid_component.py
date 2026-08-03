#!/usr/bin/env python3
"""add_hybrid_component.py — add a Cangjie UI component plus its ArkTS CJHybridComponent wrapper page.

Usage:
    python add_hybrid_component.py --component <ClassName> [--page <pages-ref>] [--title <text>]
    python add_hybrid_component.py --project-root <dir> --component MetricsPanel --force
Exit codes: 0 成功 · 1 业务失败 · 2 参数/环境错误
"""

from __future__ import annotations

import argparse
import json
import re
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
        from config_loader import detect_project_runtime, first_value, load_harmony_config
        return detect_project_runtime, first_value, load_harmony_config
    except Exception:
        print("warn: config_loader unavailable (need Python>=3.11); layered config ignored", file=sys.stderr)
        return (
            lambda *_, **__: None,
            lambda *values: next((v for v in values if v is not None and v != ""), None),
            lambda **_: None,
        )


detect_project_runtime, first_value, load_harmony_config = _load_config_helpers()


# ── 常量 ──────────────────────────────────────────────────────

HYBRID_DEP_NAME = "@cangjie/cjhybridcomponent"
HYBRID_DEP_VERSION = "1.0.0"


# ── 纯函数 ────────────────────────────────────────────────────


def skill_root() -> Path:
    return Path(__file__).resolve().parents[1]


def template_dir() -> Path:
    return skill_root() / "templates" / "cjhybridcomponent"


def validate_identifier(value: str, label: str) -> None:
    if not re.match(r"^[A-Za-z_][A-Za-z0-9_]*$", value):
        raise ValueError(f"{label} must be a valid identifier")


def snake_name(name: str) -> str:
    out = re.sub(r"(?<!^)([A-Z])", r"_\1", name).lower()
    return re.sub(r"[^a-z0-9_]+", "_", out).strip("_") or "component"


def resolve_page_refs(page_stem: str) -> tuple[str, str]:
    """归一化 --page 输入，返回 (相对 pages/ 的文件 stem, main_pages 路由引用)。"""
    page_stem = page_stem.replace("\\", "/").strip("/")
    if page_stem.startswith("pages/"):
        return page_stem.removeprefix("pages/"), page_stem
    return page_stem, f"pages/{page_stem}"


def strip_json5_comments(text: str) -> str:
    text = re.sub(r"//.*", "", text)
    text = re.sub(r"/\*.*?\*/", "", text, flags=re.S)
    text = re.sub(r",\s*([}\]])", r"\1", text)
    return text


# ── 副作用函数（文件系统读写） ────────────────────────────────


def read_text(path: Path) -> str:
    return path.read_text(encoding="utf-8", errors="replace") if path.exists() else ""


def write_text(path: Path, text: str) -> None:
    path.parent.mkdir(parents=True, exist_ok=True)
    path.write_text(text, encoding="utf-8", newline="\n")


def parse_cjpm_package(cjpm: Path) -> str:
    in_package = False
    for line in read_text(cjpm).splitlines():
        stripped = line.strip()
        if stripped == "[package]":
            in_package = True
            continue
        if stripped.startswith("[") and stripped != "[package]":
            in_package = False
        if in_package:
            match = re.match(r'name\s*=\s*"([^"]+)"', stripped)
            if match:
                return match.group(1)
    raise ValueError(f"cannot find [package].name in {cjpm}")


def render_template(name: str, replacements: dict[str, str]) -> str:
    path = template_dir() / name
    text = path.read_text(encoding="utf-8")
    for token, value in replacements.items():
        text = text.replace(token, value)
    unresolved = sorted(set(re.findall(r"__[A-Z0-9_]+__", text)))
    if unresolved:
        raise ValueError(f"unresolved template tokens: {', '.join(unresolved)}")
    return text


def add_dependency(oh_package: Path) -> bool:
    """在 <module>/oh-package.json5 的 dependencies 里登记混合组件依赖；定位失败给出手工步骤。"""
    text = read_text(oh_package)
    if f'"{HYBRID_DEP_NAME}"' in text:
        return False
    match = re.search(r'"dependencies"\s*:\s*\{', text)
    if not match:
        raise ValueError(
            f'cannot locate a "dependencies" object in {oh_package}; '
            f'add "{HYBRID_DEP_NAME}": "{HYBRID_DEP_VERSION}" to its dependencies manually, then re-run'
        )
    idx = match.end()
    head = text[idx:].split("}", 1)[0]
    comma = "," if re.search(r'"[^"]+"\s*:', head) else ""
    text = text[:idx] + f'\n    "{HYBRID_DEP_NAME}": "{HYBRID_DEP_VERSION}"{comma}' + text[idx:]
    write_text(oh_package, text)
    return True


def update_main_pages(path: Path, page_ref: str) -> bool:
    """把 page_ref 登记进 main_pages.json 的 src 数组。

    文本级插入，保留原有格式与 json5 注释；插入后回验可解析且已登记，
    定位/回验失败一律不落盘，报错并给出手工步骤。
    """
    raw = read_text(path)
    if not raw.strip():
        write_text(path, json.dumps({"src": [page_ref]}, ensure_ascii=False, indent=2) + "\n")
        return True

    manual_hint = ValueError(
        f'cannot safely register "{page_ref}" in {path}; '
        f'add it to the "src" array manually, then re-run hybrid_project_check.py'
    )

    def parsed_src(text: str) -> list[str] | None:
        try:
            data = json.loads(strip_json5_comments(text))
        except Exception:
            return None
        if isinstance(data, dict) and isinstance(data.get("src"), list):
            return [str(item) for item in data["src"]]
        return None

    src = parsed_src(raw)
    if src is not None:
        if page_ref in src:
            return False
    elif f'"{page_ref}"' in raw:
        return False

    match = re.search(r'("src"\s*:\s*\[)(.*?)(\])', raw, re.S)
    if not match:
        raise manual_hint
    inner = match.group(2)
    entries = list(re.finditer(r'"(?:[^"\\]|\\.)*"', inner))
    if not entries:
        if inner.strip():
            raise manual_hint  # 有内容但非双引号条目（如单引号 json5），不冒险改写
        new_inner = f'\n    "{page_ref}"\n  '
    else:
        # 逗号补在末条目引号后（行尾注释之前），新条目插在该行之后
        last = entries[-1]
        comma = re.match(r"\s*,", inner[last.end():])
        anchor = last.end() + (comma.end() if comma else 0)
        newline = inner.find("\n", anchor)
        line_end = newline if newline >= 0 else len(inner)
        sep = "" if comma else ","
        new_inner = (
            inner[: last.end()] + sep + inner[last.end():line_end]
            + f'\n    "{page_ref}"' + inner[line_end:]
        )
    updated = raw[: match.start(2)] + new_inner + raw[match.end(2):]

    check = parsed_src(updated)
    if check is None or page_ref not in check:
        raise manual_hint
    write_text(path, updated)
    return True


# ── main ──────────────────────────────────────────────────────


def parse_args(argv: list[str]) -> argparse.Namespace:
    parser = argparse.ArgumentParser(description="Add a Cangjie HybridComponent and ArkTS wrapper page.")
    parser.add_argument("--project-root", default=".", help="project root")
    parser.add_argument("--config", action="append", default=None, help="Path to harmonyos-cangjie config TOML.")
    parser.add_argument("--module", default=None, help="HarmonyOS module")
    parser.add_argument("--component", required=True, help="Cangjie component class name")
    parser.add_argument("--page", default=None, help="ArkTS page file stem/ref, default is component name in lower snake case")
    parser.add_argument("--title", default=None, help="initial Cangjie component title")
    parser.add_argument("--button-text", default="Tap Cangjie Component")
    parser.add_argument("--clicked-title", default=None, help="title after clicking the Cangjie button")
    parser.add_argument("--force", action="store_true", help="overwrite existing generated component/page files")
    return parser.parse_args(argv)


def main(argv: list[str]) -> int:
    args = parse_args(argv)

    # 参数校验；失败退 2
    try:
        validate_identifier(args.component, "component")
        page_file_stem, page_ref = resolve_page_refs(args.page or snake_name(args.component))
        wrapper_struct = re.sub(r"[^A-Za-z0-9_]", "_", page_file_stem.title().replace("_", ""))
        validate_identifier(wrapper_struct, "wrapper struct")
    except ValueError as exc:
        print(f"error: {exc}", file=sys.stderr)
        return 2

    # 业务执行；失败退 1
    try:
        project = Path(args.project_root).expanduser().resolve()
        cfg = load_harmony_config(project_root=project, config_paths=args.config)
        runtime_cfg = getattr(cfg, "runtime", None)
        detected = detect_project_runtime(project, module=args.module or (getattr(runtime_cfg, "module", None) if runtime_cfg else None))
        args.module = first_value(args.module, getattr(runtime_cfg, "module", None) if runtime_cfg else None, getattr(detected, "module", None), "entry")
        module = project / args.module
        package_name = parse_cjpm_package(module / "cjpm.toml")

        replacements = {
            "__PACKAGE_NAME__": package_name,
            "__COMPONENT_NAME__": args.component,
            "__WRAPPER_STRUCT__": wrapper_struct,
            "__TITLE__": args.title or f"{args.component} Panel",
            "__BUTTON_TEXT__": args.button_text,
            "__CLICKED_TITLE__": args.clicked_title or f"{args.component} Clicked",
        }

        component_path = module / "src/main/cangjie" / f"{snake_name(args.component)}.cj"
        wrapper_path = module / "src/main/ets/pages" / f"{page_file_stem}.ets"
        for path in (component_path, wrapper_path):
            if path.exists() and not args.force:
                raise ValueError(f"refusing to overwrite existing file without --force: {path}")

        write_text(component_path, render_template("Component.cj.tpl", replacements))
        write_text(wrapper_path, render_template("Wrapper.ets.tpl", replacements))
        dep_added = add_dependency(module / "oh-package.json5")
        route_added = update_main_pages(module / "src/main/resources/base/profile/main_pages.json", page_ref)
    except Exception as exc:
        print(f"error: {exc}", file=sys.stderr)
        return 1

    print(f"component: {component_path}")
    print(f"wrapper: {wrapper_path}")
    print(f"page_ref: {page_ref}")
    print(f"dependency_added: {dep_added}")
    print(f"route_added: {route_added}")
    return 0


if __name__ == "__main__":
    raise SystemExit(main(sys.argv[1:]))
