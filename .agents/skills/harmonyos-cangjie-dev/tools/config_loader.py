#!/usr/bin/env python3
from __future__ import annotations

import os
import re
import tomllib
from dataclasses import dataclass, field
from pathlib import Path
from typing import Any


CONFIG_ENV = "HARMONYOS_CANGJIE_CONFIG"
USER_CONFIG = Path.home() / ".harmonyos-cangjie" / "config.toml"
PROJECT_CONFIGS = (
    Path("harmonyos-cangjie.toml"),
    Path(".claude") / "harmonyos-cangjie.toml",
    Path(".agents") / "harmonyos-cangjie.toml",
)


@dataclass(slots=True)
class ToolchainConfig:
    deveco_home: str | None = None
    cangjie_sdk: str | None = None
    hdc: str | None = None
    ohpm_registry: str | None = None
    strict_ssl: bool | None = None


@dataclass(slots=True)
class DeviceConfig:
    target: str | None = None
    emulator: str | None = None


@dataclass(slots=True)
class RuntimeConfig:
    bundle: str | None = None
    ability: str | None = None
    module: str | None = None
    hap: str | None = None


@dataclass(slots=True)
class NewProjectConfig:
    app_name: str | None = None
    bundle_name: str | None = None
    package_name: str | None = None
    module_name: str | None = None
    vendor: str | None = None
    sdk_version: str | None = None
    model_version: str | None = None


@dataclass(slots=True)
class RagConfig:
    config: str | None = None
    version: str | None = None
    ai_provider: str | None = None
    api_key_env: str | None = None
    api_key: str | None = None
    llm_provider: str | None = None
    llm_model: str | None = None
    llm_base_url: str | None = None
    llm_api_key_env: str | None = None
    llm_api_key: str | None = None
    embedding_provider: str | None = None
    embedding_model: str | None = None
    embedding_base_url: str | None = None
    embedding_api_key_env: str | None = None
    embedding_api_key: str | None = None
    embedding_batch_size: int | None = None


@dataclass(slots=True)
class HarmonyConfig:
    toolchain: ToolchainConfig = field(default_factory=ToolchainConfig)
    device: DeviceConfig = field(default_factory=DeviceConfig)
    runtime: RuntimeConfig = field(default_factory=RuntimeConfig)
    new_project: NewProjectConfig = field(default_factory=NewProjectConfig)
    rag: RagConfig = field(default_factory=RagConfig)
    loaded_files: list[Path] = field(default_factory=list)


@dataclass(slots=True)
class DetectedRuntime:
    bundle: str | None = None
    ability: str | None = None
    module: str | None = None
    hap: str | None = None
    warnings: list[str] = field(default_factory=list)


def find_project_root(start: str | Path | None = None) -> Path:
    cur = Path(start or Path.cwd()).expanduser().resolve()
    if cur.is_file():
        cur = cur.parent
    for candidate in (cur, *cur.parents):
        if (
            (candidate / ".claude").exists()
            or (candidate / ".agents").exists()
            or (candidate / "build-profile.json5").exists()
            or (candidate / "AppScope").exists()
        ):
            return candidate
    return cur


def default_config_paths(project_root: str | Path | None = None) -> list[Path]:
    paths: list[Path] = []
    paths.append(USER_CONFIG)
    project = find_project_root(project_root)
    paths.extend(project / path for path in PROJECT_CONFIGS)
    env_path = os.getenv(CONFIG_ENV)
    if env_path:
        paths.append(Path(env_path).expanduser())
    return paths


def _assign(obj: Any, data: dict[str, Any]) -> None:
    for key, value in data.items():
        if hasattr(obj, key):
            setattr(obj, key, value)


def _load_toml(path: Path) -> dict[str, Any]:
    text = path.read_text(encoding="utf-8-sig")
    data = tomllib.loads(text)
    return data if isinstance(data, dict) else {}


def _section(data: dict[str, Any], name: str) -> dict[str, Any]:
    value = data.get(name)
    return value if isinstance(value, dict) else {}


def load_harmony_config(
    *,
    project_root: str | Path | None = None,
    config_paths: list[str | Path] | None = None,
) -> HarmonyConfig:
    cfg = HarmonyConfig()
    paths = [Path(p).expanduser() for p in config_paths] if config_paths else default_config_paths(project_root)
    for path in paths:
        if not path.exists():
            continue
        data = _load_toml(path)
        _assign(cfg.toolchain, _section(data, "toolchain"))
        _assign(cfg.device, _section(data, "device"))
        _assign(cfg.runtime, _section(data, "runtime"))
        _assign(cfg.new_project, _section(data, "new_project"))
        _assign(cfg.rag, _section(data, "rag"))
        cfg.loaded_files.append(path.resolve())
    return cfg


def first_value(*values: Any) -> Any:
    for value in values:
        if value is not None and value != "":
            return value
    return None


def path_value(value: str | None) -> Path | None:
    return Path(value).expanduser() if value else None


def strip_json5_comments(text: str) -> str:
    text = re.sub(r"//.*", "", text)
    text = re.sub(r"/\*.*?\*/", "", text, flags=re.S)
    return text


def _read(path: Path) -> str:
    return path.read_text(encoding="utf-8", errors="replace") if path.exists() else ""


def _string_value(text: str, key: str) -> str | None:
    match = re.search(rf'["\']{re.escape(key)}["\']\s*:\s*["\']([^"\']+)["\']', text)
    return match.group(1) if match else None


def detect_bundle(project_root: str | Path) -> str | None:
    app_json = Path(project_root) / "AppScope" / "app.json5"
    return _string_value(strip_json5_comments(_read(app_json)), "bundleName")


def detect_modules(project_root: str | Path) -> list[str]:
    project = Path(project_root)
    profile = strip_json5_comments(_read(project / "build-profile.json5"))
    modules_block = re.search(r'["\']modules["\']\s*:\s*\[(?P<body>.*?)\]\s*,', profile, re.S)
    if modules_block:
        names = re.findall(r'["\']name["\']\s*:\s*["\']([^"\']+)["\']', modules_block.group("body"))
        if names:
            return list(dict.fromkeys(names))
    found = [
        path.parent.parent.parent.name
        for path in sorted(project.glob("*/src/main/module.json5"))
        if path.is_file()
    ]
    return list(dict.fromkeys(found))


def detect_ability(project_root: str | Path, module: str | None = None) -> str | None:
    project = Path(project_root)
    module_names = [module] if module else detect_modules(project)
    for name in [item for item in module_names if item]:
        text = strip_json5_comments(_read(project / name / "src/main/module.json5"))
        if not text:
            continue
        abilities = re.search(r'["\']abilities["\']\s*:\s*\[(?P<body>.*?)\]', text, re.S)
        if abilities:
            ability = _string_value(abilities.group("body"), "name")
            if ability:
                return ability
        ability = _string_value(text, "name")
        if ability and "Ability" in ability:
            return ability
    return None


def detect_hap(project_root: str | Path, module: str | None = None) -> tuple[str | None, list[str]]:
    project = Path(project_root)
    module_names = [module] if module else detect_modules(project)
    candidates: list[Path] = []
    for name in [item for item in module_names if item]:
        candidates.extend(sorted((project / name / "build").glob("**/*.hap")))
    if not candidates:
        candidates = sorted(project.glob("*/build/**/*.hap"))
    candidates = [path for path in candidates if path.is_file()]
    if not candidates:
        return None, []
    candidates.sort(key=lambda path: path.stat().st_mtime, reverse=True)
    rel = str(candidates[0].relative_to(project))
    warnings: list[str] = []
    if len(candidates) > 1:
        warnings.append(
            "multiple HAP outputs detected; using newest. Pass --hap or set [runtime].hap to override."
        )
    return rel.replace("\\", "/"), warnings


def detect_project_runtime(
    project_root: str | Path | None = None,
    *,
    module: str | None = None,
) -> DetectedRuntime:
    project = find_project_root(project_root)
    modules = detect_modules(project)
    warnings: list[str] = []

    selected_module = module
    if not selected_module:
        if len(modules) == 1:
            selected_module = modules[0]
        elif "entry" in modules:
            selected_module = "entry"
            warnings.append("multiple modules detected; using entry. Pass --module or set [runtime].module to override.")
        elif modules:
            selected_module = modules[0]
            warnings.append(
                f"multiple modules detected; using {selected_module}. Pass --module or set [runtime].module to override."
            )

    hap, hap_warnings = detect_hap(project, selected_module)
    warnings.extend(hap_warnings)
    return DetectedRuntime(
        bundle=detect_bundle(project),
        ability=detect_ability(project, selected_module),
        module=selected_module,
        hap=hap,
        warnings=warnings,
    )


def warn_if_secret_in_config(cfg: HarmonyConfig) -> list[str]:
    warnings: list[str] = []
    if cfg.rag.api_key:
        warnings.append("rag.api_key is set in a config file; prefer rag.api_key_env for secrets.")
    if cfg.rag.llm_api_key:
        warnings.append("rag.llm_api_key is set in a config file; prefer rag.llm_api_key_env for secrets.")
    if cfg.rag.embedding_api_key:
        warnings.append("rag.embedding_api_key is set in a config file; prefer rag.embedding_api_key_env for secrets.")
    return warnings
