from __future__ import annotations

import json
import re
import time
import urllib.error
import urllib.request
from dataclasses import dataclass
from typing import Any

from .config import AppConfig
from .util import json_loads


class AIUnavailable(RuntimeError):
    """Raised when an optional AI component cannot be used."""


@dataclass(slots=True)
class EnhancedSection:
    summary: str
    keywords: list[str]
    aliases: list[str]
    search_boost_text: str
    structured: dict[str, Any]


class HTTPJsonClient:
    def __init__(self, *, timeout: float, max_retries: int) -> None:
        self.timeout = timeout
        self.max_retries = max_retries

    def post(self, url: str, headers: dict[str, str], payload: dict[str, Any]) -> dict[str, Any]:
        body = json.dumps(payload, ensure_ascii=False).encode("utf-8")
        request = urllib.request.Request(url, data=body, method="POST")
        for key, value in headers.items():
            request.add_header(key, value)
        request.add_header("Content-Type", "application/json")

        last_error: Exception | None = None
        for attempt in range(self.max_retries + 1):
            try:
                with urllib.request.urlopen(request, timeout=self.timeout) as response:
                    raw = response.read().decode("utf-8")
                    return json.loads(raw)
            except (urllib.error.HTTPError, urllib.error.URLError, TimeoutError, json.JSONDecodeError) as exc:
                last_error = exc
                if isinstance(exc, urllib.error.HTTPError) and 400 <= exc.code < 500 and exc.code != 429:
                    break
                if attempt < self.max_retries:
                    time.sleep(min(2.0 * (attempt + 1), 6.0))
        raise AIUnavailable(f"AI request failed: {type(last_error).__name__}")


class LLMClient:
    def __init__(self, cfg: AppConfig) -> None:
        self.cfg = cfg.llm
        self.http = HTTPJsonClient(timeout=self.cfg.timeout, max_retries=self.cfg.max_retries)

    @property
    def available(self) -> bool:
        return bool(self.cfg.api_key and self.cfg.model and self.cfg.base_url)

    def chat(self, messages: list[dict[str, str]], *, temperature: float = 0.1, json_mode: bool = False) -> str:
        if not self.available:
            raise AIUnavailable("LLM is not configured")
        url = self.cfg.base_url.rstrip("/") + "/chat/completions"
        payload: dict[str, Any] = {
            "model": self.cfg.model,
            "messages": messages,
            "temperature": temperature,
        }
        if json_mode:
            payload["response_format"] = {"type": "json_object"}
        data = self.http.post(
            url,
            headers={"Authorization": f"Bearer {self.cfg.api_key}"},
            payload=payload,
        )
        try:
            return data["choices"][0]["message"]["content"]
        except Exception as exc:
            raise AIUnavailable(f"Unexpected LLM response: {type(exc).__name__}") from exc


class EmbeddingClient:
    def __init__(self, cfg: AppConfig) -> None:
        self.cfg = cfg.embedding
        self.http = HTTPJsonClient(timeout=self.cfg.timeout, max_retries=self.cfg.max_retries)

    @property
    def available(self) -> bool:
        return bool(self.cfg.api_key and self.cfg.model and self.cfg.base_url)

    def embed_texts(self, texts: list[str]) -> list[list[float]]:
        if not self.available:
            raise AIUnavailable("Embedding service is not configured")
        if not texts:
            return []
        provider = self.cfg.provider.lower()
        if provider in {"openai-compatible", "openai"}:
            return self._embed_openai_compatible(texts)
        return self._embed_dashscope(texts)

    def _embed_openai_compatible(self, texts: list[str]) -> list[list[float]]:
        url = self.cfg.base_url.rstrip("/") + "/embeddings"
        payload: dict[str, Any] = {"model": self.cfg.model, "input": texts}
        if self.cfg.dimensions:
            payload["dimensions"] = self.cfg.dimensions
        data = self.http.post(url, {"Authorization": f"Bearer {self.cfg.api_key}"}, payload)
        try:
            return [item["embedding"] for item in sorted(data["data"], key=lambda row: row.get("index", 0))]
        except Exception as exc:
            raise AIUnavailable(f"Unexpected embedding response: {type(exc).__name__}") from exc

    def _embed_dashscope(self, texts: list[str]) -> list[list[float]]:
        payload: dict[str, Any] = {
            "model": self.cfg.model,
            "input": {"texts": texts},
        }
        if self.cfg.dimensions:
            payload["parameters"] = {"dimension": self.cfg.dimensions}
        data = self.http.post(
            self.cfg.base_url,
            {"Authorization": f"Bearer {self.cfg.api_key}"},
            payload,
        )
        try:
            rows = data["output"]["embeddings"]
            rows = sorted(rows, key=lambda row: row.get("text_index", 0))
            return [row["embedding"] for row in rows]
        except Exception as exc:
            raise AIUnavailable(f"Unexpected DashScope embedding response: {type(exc).__name__}") from exc


class AIEnhancer:
    def __init__(self, cfg: AppConfig) -> None:
        self.cfg = cfg
        self.llm = LLMClient(cfg)
        self.embedding = EmbeddingClient(cfg)
        self.degraded_reasons: list[str] = []

    @property
    def can_llm(self) -> bool:
        return self.llm.available

    @property
    def can_embed(self) -> bool:
        return self.embedding.available

    @property
    def embedding_provider(self) -> str:
        return self.cfg.embedding.provider

    @property
    def embedding_model(self) -> str:
        return self.cfg.embedding.model

    def enhance_section(self, parsed_doc, section) -> EnhancedSection | None:
        if not self.can_llm:
            return None
        prompt = (
            "你是仓颉 HarmonyOS 文档知识库预处理器。请只基于给定 Markdown 片段输出 JSON，"
            "字段为 summary, keywords, aliases, search_boost_text, structured。"
            "summary 不超过 80 字；keywords/aliases 每个最多 12 个；"
            "structured 可包含 signature, params, returns, throws, permissions, syscap, since。"
        )
        body = section.body[:6000]
        content = (
            f"文档: {parsed_doc.rel_path}\n"
            f"Kit: {parsed_doc.kit}\n"
            f"章节: {section.breadcrumb}\n"
            f"Markdown:\n{body}"
        )
        raw = self.llm.chat(
            [{"role": "system", "content": prompt}, {"role": "user", "content": content}],
            temperature=0.0,
            json_mode=True,
        )
        data = parse_json_object(raw)
        if not isinstance(data, dict):
            return None
        keywords = _string_list(data.get("keywords"))
        aliases = _string_list(data.get("aliases"))
        summary = str(data.get("summary") or "").strip()
        structured = data.get("structured") if isinstance(data.get("structured"), dict) else {}
        boost = str(data.get("search_boost_text") or " ".join([summary, *keywords, *aliases])).strip()
        return EnhancedSection(
            summary=summary,
            keywords=keywords,
            aliases=aliases,
            search_boost_text=boost,
            structured=structured,
        )

    def embed_text(self, text: str) -> list[float]:
        return self.embedding.embed_texts([text])[0]

    def embed_texts(self, texts: list[str]) -> list[list[float]]:
        return self.embedding.embed_texts(texts)

    def embed_query(self, text: str) -> list[float]:
        return self.embed_text(text)

    def rewrite_query(self, query: str) -> list[str]:
        if not self.can_llm:
            return [query]
        prompt = (
            "你是仓颉 HarmonyOS 文档查询改写器。基于用户问题生成 3 到 8 个检索查询，"
            "覆盖 API 名、Kit 名、中文关键词、英文关键词。"
            "特别注意：保存本地结构化/关系数据通常对应 关系型数据库、RdbStore、getRdbStore、ArkData、持久化；"
            "打开/创建关系型数据库通常对应 getRdbStore；数据库损坏通常对应 14800011。"
            "只输出 JSON: {\"queries\": [...]}"
        )
        raw = self.llm.chat(
            [{"role": "system", "content": prompt}, {"role": "user", "content": query}],
            temperature=0.0,
            json_mode=True,
        )
        data = parse_json_object(raw)
        queries = _string_list(data.get("queries") if isinstance(data, dict) else None)
        result = [query]
        for item in queries:
            if item not in result:
                result.append(item)
        return result[:8]

    def answer(self, question: str, contexts: list[dict[str, Any]]) -> str:
        if not self.can_llm:
            raise AIUnavailable("LLM is not configured")
        context_text = "\n\n".join(
            f"[{idx}] {item.get('title')} {item.get('path')}:{item.get('start_line')}\n{item.get('snippet')}"
            for idx, item in enumerate(contexts, 1)
        )
        prompt = (
            "你是仓颉 HarmonyOS 文档助手。只能依据给定检索片段回答；"
            "如果证据不足，明确说未在文档中找到依据。回答必须包含引用编号。"
        )
        return self.llm.chat(
            [
                {"role": "system", "content": prompt},
                {"role": "user", "content": f"问题：{question}\n\n检索片段：\n{context_text}"},
            ],
            temperature=0.1,
            json_mode=False,
        )


def _string_list(value: Any) -> list[str]:
    if not isinstance(value, list):
        return []
    result: list[str] = []
    for item in value:
        text = str(item).strip()
        if text and text not in result:
            result.append(text)
    return result


def parse_json_object(raw: str) -> dict[str, Any]:
    data = json_loads(raw, None)
    if isinstance(data, dict):
        return data
    text = raw.strip()
    fence = re.search(r"```(?:json)?\s*(\{.*?\})\s*```", text, re.DOTALL | re.IGNORECASE)
    if fence:
        data = json_loads(fence.group(1), None)
        if isinstance(data, dict):
            return data
    start = text.find("{")
    end = text.rfind("}")
    if start >= 0 and end > start:
        data = json_loads(text[start : end + 1], None)
        if isinstance(data, dict):
            return data
    return {}
