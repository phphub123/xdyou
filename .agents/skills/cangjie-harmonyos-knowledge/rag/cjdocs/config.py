from __future__ import annotations

import os
import sys
import tomllib
from dataclasses import dataclass, field
from pathlib import Path
from typing import Any


AI_OFF = "off"
AI_PREPROCESS = "preprocess"
AI_RUNTIME = "runtime"
AI_ALL = "all"
AI_CHOICES = (AI_OFF, AI_PREPROCESS, AI_RUNTIME, AI_ALL)
RAG_ROOT = Path(__file__).resolve().parents[1]
DEFAULT_DOCS_ROOT = RAG_ROOT / "docs"
DEFAULT_INDEX_DIR = RAG_ROOT / ".cjdocs"


def apply_provider_defaults(cfg: "AppConfig", provider: str) -> None:
    provider_l = provider.lower()
    if provider_l in {"aliyun", "dashscope", "alibaba"}:
        cfg.llm.provider = "openai-compatible"
        cfg.llm.base_url = "https://dashscope.aliyuncs.com/compatible-mode/v1"
        cfg.llm.api_key_env = "DASHSCOPE_API_KEY"
        cfg.llm.model = cfg.llm.model or "deepseek-v4-pro"
        cfg.embedding.provider = "dashscope"
        cfg.embedding.base_url = "https://dashscope.aliyuncs.com/api/v1/services/embeddings/text-embedding/text-embedding"
        cfg.embedding.api_key_env = "DASHSCOPE_API_KEY"
        cfg.embedding.model = cfg.embedding.model or "text-embedding-v4"


@dataclass(slots=True)
class LLMConfig:
    provider: str = "openai-compatible"
    base_url: str = "https://dashscope.aliyuncs.com/compatible-mode/v1"
    api_key_env: str = "DASHSCOPE_API_KEY"
    api_key: str | None = None
    model: str = "deepseek-v4-pro"
    timeout: float = 45.0
    max_retries: int = 2


@dataclass(slots=True)
class EmbeddingConfig:
    provider: str = "dashscope"
    base_url: str = "https://dashscope.aliyuncs.com/api/v1/services/embeddings/text-embedding/text-embedding"
    api_key_env: str = "DASHSCOPE_API_KEY"
    api_key: str | None = None
    model: str = "text-embedding-v4"
    dimensions: int | None = None
    timeout: float = 60.0
    max_retries: int = 2
    batch_size: int = 10


@dataclass(slots=True)
class RerankConfig:
    provider: str = "none"


@dataclass(slots=True)
class AppConfig:
    docs_root: str = str(DEFAULT_DOCS_ROOT)
    index_dir: str = str(DEFAULT_INDEX_DIR)
    docs_version: str = "default"
    ai_enabled: bool = False
    ai_preprocess: bool = False
    ai_runtime: bool = False
    preprocess_llm: bool = True
    preprocess_embedding: bool = True
    llm: LLMConfig = field(default_factory=LLMConfig)
    embedding: EmbeddingConfig = field(default_factory=EmbeddingConfig)
    rerank: RerankConfig = field(default_factory=RerankConfig)

    @property
    def index_path(self) -> Path:
        return Path(self.index_dir) / "index.sqlite"

    @property
    def ai_cache_path(self) -> Path:
        return Path(self.index_dir) / "ai_cache.sqlite"


def _deep_get(data: dict[str, Any], *keys: str) -> dict[str, Any]:
    cur: Any = data
    for key in keys:
        if not isinstance(cur, dict):
            return {}
        cur = cur.get(key, {})
    return cur if isinstance(cur, dict) else {}


def _assign_dataclass(obj: Any, data: dict[str, Any]) -> None:
    for key, value in data.items():
        if hasattr(obj, key):
            setattr(obj, key, value)


def _load_unified_config() -> Any | None:
    skills_dir = RAG_ROOT.parent.parent
    helper_dir = skills_dir / "harmonyos-cangjie-dev" / "tools"
    if helper_dir.exists():
        sys.path.insert(0, str(helper_dir))
    try:
        from config_loader import load_harmony_config
        return load_harmony_config(project_root=Path.cwd())
    except Exception:
        return None


def _apply_unified_rag_config(cfg: AppConfig, unified: Any | None) -> None:
    rag = getattr(unified, "rag", None)
    if not rag:
        return
    mapping = {
        "version": ("docs_version",),
        "ai_provider": ("provider",),
        "api_key_env": ("api_key_env",),
        "api_key": ("api_key",),
        "llm_provider": ("llm", "provider"),
        "llm_model": ("llm", "model"),
        "llm_base_url": ("llm", "base_url"),
        "llm_api_key_env": ("llm", "api_key_env"),
        "llm_api_key": ("llm", "api_key"),
        "embedding_provider": ("embedding", "provider"),
        "embedding_model": ("embedding", "model"),
        "embedding_base_url": ("embedding", "base_url"),
        "embedding_api_key_env": ("embedding", "api_key_env"),
        "embedding_api_key": ("embedding", "api_key"),
        "embedding_batch_size": ("embedding", "batch_size"),
    }
    for source, target in mapping.items():
        value = getattr(rag, source, None)
        if value is None or value == "":
            continue
        if source == "ai_provider":
            apply_provider_defaults(cfg, str(value))
            continue
        if len(target) == 1:
            setattr(cfg, target[0], value)
        else:
            setattr(getattr(cfg, target[0]), target[1], value)


def load_config(path: str | Path | None = None) -> AppConfig:
    cfg = AppConfig()
    _apply_unified_rag_config(cfg, _load_unified_config())
    config_path = Path(path) if path else Path("cjdocs.toml")
    if config_path.exists():
        data = tomllib.loads(config_path.read_text(encoding="utf-8-sig"))
        if isinstance(data.get("docs"), dict):
            docs = data["docs"]
            if docs.get("version"):
                cfg.docs_version = str(docs["version"])
            if docs.get("docs_version"):
                cfg.docs_version = str(docs["docs_version"])
        if isinstance(data.get("ai"), dict):
            ai = data["ai"]
            cfg.ai_enabled = bool(ai.get("enabled", cfg.ai_enabled))
            cfg.ai_preprocess = bool(ai.get("preprocess", cfg.ai_preprocess))
            cfg.ai_runtime = bool(ai.get("runtime", cfg.ai_runtime))
            cfg.preprocess_llm = bool(ai.get("preprocess_llm", cfg.preprocess_llm))
            cfg.preprocess_embedding = bool(ai.get("preprocess_embedding", cfg.preprocess_embedding))
            if ai.get("provider"):
                apply_provider_defaults(cfg, str(ai["provider"]))
            if ai.get("api_key_env"):
                cfg.llm.api_key_env = str(ai["api_key_env"])
                cfg.embedding.api_key_env = str(ai["api_key_env"])
            if ai.get("api_key"):
                cfg.llm.api_key = str(ai["api_key"])
                cfg.embedding.api_key = str(ai["api_key"])
        _assign_dataclass(cfg.llm, _deep_get(data, "llm"))
        _assign_dataclass(cfg.embedding, _deep_get(data, "embedding"))
        _assign_dataclass(cfg.rerank, _deep_get(data, "rerank"))

    cfg.llm.api_key = os.getenv(cfg.llm.api_key_env) or cfg.llm.api_key
    cfg.embedding.api_key = os.getenv(cfg.embedding.api_key_env) or cfg.embedding.api_key
    return cfg


def apply_ai_mode(cfg: AppConfig, mode: str | None) -> AppConfig:
    if not mode:
        return cfg
    if mode not in AI_CHOICES:
        raise ValueError(f"Unsupported AI mode: {mode}")
    cfg.ai_enabled = mode != AI_OFF
    cfg.ai_preprocess = mode in (AI_PREPROCESS, AI_ALL)
    cfg.ai_runtime = mode in (AI_RUNTIME, AI_ALL)
    return cfg


def apply_overrides(
    cfg: AppConfig,
    *,
    docs_root: str | None = None,
    index_dir: str | None = None,
    docs_version: str | None = None,
    ai_mode: str | None = None,
    ai_provider: str | None = None,
    api_key_env: str | None = None,
    api_key: str | None = None,
    preprocess_llm: bool | None = None,
    preprocess_embedding: bool | None = None,
    llm_provider: str | None = None,
    llm_model: str | None = None,
    llm_base_url: str | None = None,
    llm_api_key_env: str | None = None,
    llm_api_key: str | None = None,
    embedding_provider: str | None = None,
    embedding_model: str | None = None,
    embedding_base_url: str | None = None,
    embedding_api_key_env: str | None = None,
    embedding_api_key: str | None = None,
    embedding_batch_size: int | None = None,
) -> AppConfig:
    if docs_root:
        cfg.docs_root = docs_root
    if index_dir:
        cfg.index_dir = index_dir
    if docs_version:
        cfg.docs_version = docs_version
    apply_ai_mode(cfg, ai_mode)
    if ai_provider:
        apply_provider_defaults(cfg, ai_provider)
    if api_key_env:
        cfg.llm.api_key_env = api_key_env
        cfg.embedding.api_key_env = api_key_env
        cfg.llm.api_key = os.getenv(api_key_env)
        cfg.embedding.api_key = os.getenv(api_key_env)
    if api_key:
        cfg.llm.api_key = api_key
        cfg.embedding.api_key = api_key
    if preprocess_llm is not None:
        cfg.preprocess_llm = preprocess_llm
    if preprocess_embedding is not None:
        cfg.preprocess_embedding = preprocess_embedding
    if llm_provider:
        cfg.llm.provider = llm_provider
    if llm_model:
        cfg.llm.model = llm_model
    if llm_base_url:
        cfg.llm.base_url = llm_base_url
    if llm_api_key_env:
        cfg.llm.api_key_env = llm_api_key_env
        cfg.llm.api_key = os.getenv(llm_api_key_env)
    if llm_api_key:
        cfg.llm.api_key = llm_api_key
    if embedding_provider:
        cfg.embedding.provider = embedding_provider
    if embedding_model:
        cfg.embedding.model = embedding_model
    if embedding_base_url:
        cfg.embedding.base_url = embedding_base_url
    if embedding_api_key_env:
        cfg.embedding.api_key_env = embedding_api_key_env
        cfg.embedding.api_key = os.getenv(embedding_api_key_env)
    if embedding_api_key:
        cfg.embedding.api_key = embedding_api_key
    if embedding_batch_size:
        cfg.embedding.batch_size = embedding_batch_size
    return cfg
