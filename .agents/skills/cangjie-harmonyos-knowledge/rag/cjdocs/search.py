from __future__ import annotations

import json
import math
import re
import sqlite3
import sys
from dataclasses import dataclass, field
from pathlib import Path
from typing import Any

from .ai import AIEnhancer
from .ai_cache import AICache
from .config import AI_ALL, AI_RUNTIME, AppConfig
from .db import connect, init_db
from .util import has_cjk, json_loads, normalize_symbol


ASCII_TOKEN_RE = re.compile(r"[A-Za-z_][A-Za-z0-9_]*|[0-9]{2,}")
CJK_TOKEN_RE = re.compile(r"[\u3400-\u9fff]{2,}")
CJK_STOP_TERMS = {
    "如何",
    "怎么",
    "怎样",
    "什么",
    "一个",
    "这个",
    "那个",
    "里面",
    "时候",
    "可以",
    "需要",
}
CJK_BAD_GRAM_CHARS = set("如何怎么怎样什么或和与的了在里")
DOMAIN_TERMS = [
    "数据库",
    "持久化",
    "结构化",
    "本地",
    "保存",
    "存储",
    "创建",
    "打开",
    "获取",
    "查询",
    "插入",
    "更新",
    "删除",
    "配置",
    "上传",
    "下载",
    "生成",
    "关闭",
    "释放",
    "错误码",
    "权限",
    "日志",
    "示例",
    "步骤",
    "限制",
    "数据",
]


def _z(text: str) -> str:
    return text.encode("ascii").decode("unicode_escape")


HOWTO_TERMS = tuple(
    _z(item)
    for item in (
        r"\u5982\u4f55",
        r"\u600e\u4e48",
        r"\u600e\u6837",
        r"\u4f7f\u7528",
        r"\u5f00\u53d1",
        r"\u6b65\u9aa4",
        r"\u6d41\u7a0b",
        r"\u793a\u4f8b",
        r"\u914d\u7f6e",
        r"\u8bbe\u7f6e",
    )
) + ("how", "use", "usage", "guide", "example", "configure", "setup")
GUIDE_HEADING_TERMS = tuple(
    _z(item)
    for item in (
        r"\u5f00\u53d1\u6b65\u9aa4",
        r"\u6b65\u9aa4",
        r"\u793a\u4f8b",
        r"\u793a\u4f8b\u4ee3\u7801",
        r"\u4f7f\u7528\u8bf4\u660e",
        r"\u5feb\u901f\u5f00\u59cb",
        r"\u7ea6\u675f\u4e0e\u9650\u5236",
        r"\u6ce8\u610f",
        r"\u5904\u7406\u6b65\u9aa4",
    )
) + ("example", "usage", "quickstart", "steps", "guide", "tutorial", "troubleshooting")
ERROR_TERMS = tuple(_z(item) for item in (r"\u9519\u8bef\u7801", r"\u5f02\u5e38", r"\u5931\u8d25", r"\u539f\u56e0", r"\u5904\u7406")) + ("error", "exception", "failed", "cause", "solution")
LIMIT_TERMS = tuple(_z(item) for item in (r"\u9650\u5236", r"\u5927\u5c0f", r"\u6700\u5927", r"\u6700\u5c0f", r"\u591a\u5c11", r"\u5bb9\u91cf")) + ("limit", "size", "maximum", "minimum", "max", "min")
LIFECYCLE_TERMS = tuple(_z(item) for item in (r"\u5173\u95ed", r"\u91ca\u653e", r"\u9500\u6bc1", r"\u6e05\u7406")) + ("close", "closed", "release", "dispose", "destroy", "cleanup")
CONFIG_TERMS = tuple(_z(item) for item in (r"\u914d\u7f6e", r"\u4fdd\u5b58", r"\u5199\u5165", r"\u6301\u4e45\u5316", r"\u5b58\u50a8")) + ("config", "option", "options", "save", "write", "put", "flush", "persist")
TRANSFER_TERMS = tuple(_z(item) for item in (r"\u4e0a\u4f20", r"\u4e0b\u8f7d", r"\u7f51\u7edc\u8d44\u6e90", r"\u6587\u4ef6")) + ("upload", "download", "file", "resource", "transfer")
PERMISSION_TERMS = tuple(_z(item) for item in (r"\u6743\u9650", r"\u6388\u6743", r"\u7533\u8bf7")) + ("permission", "authorization", "authorize", "grant")
LOG_TERMS = tuple(_z(item) for item in (r"\u65e5\u5fd7", r"\u8f93\u51fa")) + ("log", "logger", "debug", "info", "warn", "error", "fatal")
UNIT_RE = re.compile(r"\b\d+(?:\.\d+)?\s?(?:b|kb|mb|gb|k|m|g|bytes?|rows?|items?)\b", re.IGNORECASE)
GENERIC_QUERY_TERMS = {
    "如何",
    "怎么",
    "怎样",
    "使用",
    "开发",
    "步骤",
    "示例",
    "配置",
    "设置",
    "创建",
    "打开",
    "获取",
    "查询",
    "数据",
    "保存",
    "存储",
    "本地",
    "how",
    "use",
    "usage",
    "guide",
    "example",
    "configure",
    "setup",
    "steps",
}


@dataclass(slots=True)
class Candidate:
    section_id: int
    score: float = 0.0
    reasons: list[str] = field(default_factory=list)

    def add(self, score: float, reason: str) -> None:
        self.score += score
        if reason not in self.reasons:
            self.reasons.append(reason)


class Searcher:
    def __init__(self, cfg: AppConfig) -> None:
        self.cfg = cfg
        self.con = connect(Path(cfg.index_path))
        init_db(self.con)
        self.ai = AIEnhancer(cfg) if cfg.ai_enabled else None
        self.ai_cache = AICache(Path(cfg.ai_cache_path)) if cfg.ai_enabled else None

    def close(self) -> None:
        if self.ai_cache:
            self.ai_cache.close()
        self.con.close()

    def __enter__(self) -> "Searcher":
        return self

    def __exit__(self, exc_type: object, exc: object, tb: object) -> None:
        self.close()

    def status(self) -> dict[str, Any]:
        manifest = self.con.execute("select value from metadata where key='manifest'").fetchone()
        totals = self._totals()
        vector_count = totals["vectors"]
        version = normalize_query_version(self.cfg.docs_version)
        version_sql, version_params = version_where("r", version)
        version_vector_count = self.con.execute(
            f"select count(*) c from vectors r where 1 = 1 {version_sql}",
            version_params,
        ).fetchone()["c"]
        embedding_configured = bool(self.ai and self.ai.can_embed)
        mode = "deterministic-only"
        if self.cfg.ai_runtime and embedding_configured:
            mode = "embedding-runtime" if version_vector_count else "ai-degraded"
        return {
            "ok": True,
            "mode": mode,
            "index_path": str(Path(self.cfg.index_path)),
            "default_version": self.cfg.docs_version,
            "versions": self.versions(),
            "ai_enabled": self.cfg.ai_enabled,
            "ai_runtime": self.cfg.ai_runtime,
            "runtime_llm_default": False,
            "llm_configured": bool(self.ai and self.ai.can_llm),
            "embedding_configured": embedding_configured,
            **totals,
            "version_vectors": version_vector_count,
            "manifest": json_loads(manifest["value"], {}) if manifest else None,
        }

    def versions(self) -> list[dict[str, Any]]:
        rows = self.con.execute(
            """
            select
              v.version,
              v.docs_root,
              v.display_name,
              v.status,
              (select count(*) from documents d where d.version = v.version) documents,
              (select count(*) from sections s where s.version = v.version) sections,
              (select count(*) from symbols y where y.version = v.version) symbols,
              (select count(*) from examples e where e.version = v.version) examples,
              (select count(*) from vectors r where r.version = v.version) vectors,
              v.created_at,
              v.updated_at
            from versions v
            where v.status = 'ready'
            order by case when version = ? then 0 else 1 end, updated_at desc, version
            """,
            (self.cfg.docs_version,),
        ).fetchall()
        if rows:
            return [dict(row) for row in rows]
        return []

    def _totals(self) -> dict[str, int]:
        row = self.con.execute(
            """
            select
              (select count(*) from documents d where exists (select 1 from versions v where v.version = d.version and v.status = 'ready')) documents,
              (select count(*) from sections s where exists (select 1 from versions v where v.version = s.version and v.status = 'ready')) sections,
              (select count(*) from symbols y where exists (select 1 from versions v where v.version = y.version and v.status = 'ready')) symbols,
              (select count(*) from examples e where exists (select 1 from versions v where v.version = e.version and v.status = 'ready')) examples,
              (select count(*) from vectors r where exists (select 1 from versions v where v.version = r.version and v.status = 'ready')) vectors
            """
        ).fetchone()
        return {key: int(row[key]) for key in ("documents", "sections", "symbols", "examples", "vectors")}

    def search(self, query: str, *, top_k: int = 8, scope: str = "all", ai_mode: str | None = None, version: str | None = None) -> list[dict[str, Any]]:
        query = (query or "").strip()
        if not query:
            return []
        version_filter = normalize_query_version(version if version is not None else self.cfg.docs_version)
        if not self._has_active_version(version_filter):
            ready = [str(r["version"]) for r in self.con.execute("select version from versions where status = 'ready'").fetchall()]
            if version_filter and ready:
                # 配置的 SDK 版本不在索引里（平台设置页写入的 version 与索引不匹配是常见集成地雷）
                # — 静默空结果会让知识库整体"变哑"，回退到全部 ready 版本并出声
                print(f"cjdocs: index has no ready version '{version_filter}' (available: {', '.join(ready)}); falling back to all ready versions", file=sys.stderr)
                version_filter = None
            else:
                print("cjdocs: index is empty or has no ready version - run: python cjdocs.py build", file=sys.stderr)
                return []
        runtime_ai = self._runtime_ai_enabled(ai_mode)
        queries = expand_query(query)

        candidates: dict[int, Candidate] = {}
        for idx, q in enumerate(queries):
            weight = 1.0 if idx == 0 else 0.62
            self._symbol_candidates(candidates, q, scope, weight, version_filter)
            if idx <= 3:
                self._fts_candidates(candidates, q, scope, weight, version_filter)
            self._substring_candidates(candidates, q, scope, weight, version_filter)
            if idx == 0 and scope in {"all", "examples"}:
                self._example_candidates(candidates, q, weight, version_filter)

        self._numeric_candidates(candidates, query, scope, version_filter)
        self._structural_seed_candidates(candidates, query, scope, version_filter)
        self._coverage_candidates(candidates, query, scope, version_filter)

        if runtime_ai and self.ai and self.ai.can_embed and self._vectors_available():
            try:
                self._vector_candidates(candidates, query, scope, version_filter)
            except Exception as exc:
                # 查询期向量只是可选加成信号 — 网络故障不许变成每条查询数十秒的静默等待：
                # 本进程内立即禁用并出声，词法检索本身已达标（2026-07-05 实测 7/7 hit@1）
                self._embed_failed = True
                print(f"cjdocs: runtime embedding unavailable ({type(exc).__name__}); lexical-only for this process", file=sys.stderr)

        self._drop_inactive_candidates(candidates)
        self._quality_adjustments(candidates, query)
        ordered = sorted(candidates.values(), key=lambda item: item.score, reverse=True)
        return [self._hydrate_candidate(item, query) for item in ordered[: max(top_k, 1)]]

    def _vectors_available(self) -> bool:
        """索引里没有当前 provider/model 的向量时（如重建索引未跑 AI 预处理），
        查询期 embedding 纯属白付网络与延迟 — 直接跳过（实测发行索引 vectors=0 案）。"""
        if getattr(self, "_embed_failed", False):
            return False
        cached = getattr(self, "_vector_count", None)
        if cached is None:
            row = self.con.execute(
                "select count(*) c from vectors where provider = ? and model = ?",
                (self.cfg.embedding.provider, self.cfg.embedding.model),
            ).fetchone()
            cached = int(row["c"])
            self._vector_count = cached
        return cached > 0

    def _has_active_version(self, version: str | None) -> bool:
        if version:
            row = self.con.execute("select 1 from versions where version = ? and status = 'ready' limit 1", (version,)).fetchone()
        else:
            row = self.con.execute("select 1 from versions where status = 'ready' limit 1").fetchone()
        return bool(row)

    def _drop_inactive_candidates(self, candidates: dict[int, Candidate]) -> None:
        if not candidates:
            return
        ids = list(candidates)
        active: set[int] = set()
        for start in range(0, len(ids), 500):
            chunk = ids[start : start + 500]
            placeholders = ",".join("?" for _ in chunk)
            rows = self.con.execute(
                f"""
                select s.id
                from sections s
                join versions v on v.version = s.version and v.status = 'ready'
                where s.id in ({placeholders})
                """,
                chunk,
            ).fetchall()
            active.update(int(row["id"]) for row in rows)
        for section_id in ids:
            if section_id not in active:
                candidates.pop(section_id, None)

    def lookup_symbol(self, name: str, *, include_members: bool = True, include_examples: bool = True, version: str | None = None) -> dict[str, Any] | None:
        norm = normalize_symbol(name)
        version_filter = normalize_query_version(version if version is not None else self.cfg.docs_version)
        if version_filter and not self._has_active_version(version_filter):
            ready = [str(r["version"]) for r in self.con.execute("select version from versions where status = 'ready'").fetchall()]
            if ready:
                print(f"cjdocs: index has no ready version '{version_filter}' (available: {', '.join(ready)}); falling back", file=sys.stderr)
                version_filter = None
        version_sql, version_params = version_where("s", version_filter)
        row = self.con.execute(
            f"""
            select s.*, sec.body, sec.breadcrumb, sec.kit, sec.doc_type
            from symbols s join sections sec on sec.id = s.section_id
            where s.normalized = ? {version_sql}
            order by case when s.name = ? then 0 else 1 end, length(s.name)
            limit 1
            """,
            (norm, *version_params, name),
        ).fetchone()
        if not row:
            rows = self.con.execute(
                f"""
                select s.*, sec.body, sec.breadcrumb, sec.kit, sec.doc_type
                from symbols s join sections sec on sec.id = s.section_id
                where s.normalized like ? {version_sql}
                order by length(s.name)
                limit 1
                """,
                (f"%{norm}%", *version_params),
            ).fetchall()
            row = rows[0] if rows else None
        if not row:
            return None
        result = dict(row)
        result["ref"] = f"{row['path']}#{row['anchor']}"
        result["members"] = []
        result["examples"] = []
        if include_members:
            member_version = row["version"] if version_filter is None else version_filter
            result["members"] = [
                dict(item)
                for item in self.con.execute(
                    """
                    select name, kind, signature, path, anchor, start_line, end_line
                    from symbols
                    where parent = ? and id != ? and (? is null or version = ?)
                    order by start_line
                    limit 80
                    """,
                    (row["name"], row["id"], member_version, member_version),
                ).fetchall()
            ]
        if include_examples:
            result["examples"] = self.find_examples(row["name"], top_k=5, version=row["version"] if version_filter is None else version_filter)
        return result

    def read_doc(self, ref: str, *, mode: str = "section", max_chars: int = 12000, version: str | None = None) -> dict[str, Any] | None:
        path, anchor = split_ref(ref)
        version_filter = normalize_query_version(version if version is not None else self.cfg.docs_version)
        version_sql, version_params = version_where("s", version_filter)
        if mode == "full" or not anchor:
            rows = self.con.execute(
                f"""
                select s.title, s.version, s.path, s.start_line, s.end_line, s.body
                from sections s
                where s.path = ? {version_sql}
                order by s.start_line
                """,
                (path, *version_params),
            ).fetchall()
            if not rows:
                return None
            if version_filter is None:
                chosen_version = rows[0]["version"]
                rows = [row for row in rows if row["version"] == chosen_version]
            text = "\n\n".join(row["body"] for row in rows)
            return {
                "path": path,
                "version": rows[0]["version"],
                "title": rows[0]["title"],
                "start_line": rows[0]["start_line"],
                "end_line": rows[-1]["end_line"],
                "content": text[:max_chars],
                "truncated": len(text) > max_chars,
            }
        row = self.con.execute(
            f"select s.* from sections s where s.path = ? and s.anchor = ? {version_sql} limit 1",
            (path, anchor, *version_params),
        ).fetchone()
        if not row:
            return None
        body = row["body"]
        return {
            "path": row["path"],
            "version": row["version"],
            "title": row["title"],
            "breadcrumb": row["breadcrumb"],
            "anchor": row["anchor"],
            "start_line": row["start_line"],
            "end_line": row["end_line"],
            "content": body[:max_chars],
            "truncated": len(body) > max_chars,
        }

    def find_examples(self, query_or_symbol: str, *, top_k: int = 5, version: str | None = None) -> list[dict[str, Any]]:
        version_filter = normalize_query_version(version if version is not None else self.cfg.docs_version)
        version_sql, version_params = version_where("e", version_filter)
        terms = make_fts_query(query_or_symbol)
        rows: list[sqlite3.Row] = []
        if terms:
            try:
                rows = self.con.execute(
                    f"""
                    select e.*, bm25(fts_examples) rank
                    from fts_examples join examples e on e.id = fts_examples.rowid
                    where fts_examples match ? {version_sql}
                    order by rank limit ?
                    """,
                    (terms, *version_params, top_k),
                ).fetchall()
            except sqlite3.OperationalError:
                rows = []
        if not rows:
            rows = self.con.execute(
                f"""
                select e.* from examples e
                where (e.code like ? or e.nearby_symbol like ? or e.imports like ?) {version_sql}
                order by e.start_line limit ?
                """,
                (f"%{query_or_symbol}%", f"%{query_or_symbol}%", f"%{query_or_symbol}%", *version_params, top_k),
            ).fetchall()
        return [
            {
                "path": row["path"],
                "version": row["version"],
                "anchor": row["anchor"],
                "ref": f"{row['path']}#{row['anchor']}",
                "start_line": row["start_line"],
                "end_line": row["end_line"],
                "language": row["language"],
                "imports": json_loads(row["imports"], []),
                "nearby_symbol": row["nearby_symbol"],
                "code": row["code"][:3000],
            }
            for row in rows
        ]

    def related_docs(self, ref: str, *, top_k: int = 8, version: str | None = None) -> list[dict[str, Any]]:
        path, anchor = split_ref(ref)
        version_filter = normalize_query_version(version if version is not None else self.cfg.docs_version)
        version_sql, version_params = version_where("s", version_filter)
        sec = self.con.execute(
            f"select s.* from sections s where s.path = ? and s.anchor = ? {version_sql} limit 1",
            (path, anchor, *version_params),
        ).fetchone()
        if not sec:
            return []
        rows = self.con.execute(
            """
            select distinct s.*
            from links l join sections s
              on s.version = l.version and (s.path = l.target_path or s.path = l.path)
            where l.version = ? and (l.section_id = ? or l.target_path = ?)
            order by case when s.kit = ? then 0 else 1 end, s.start_line
            limit ?
            """,
            (sec["version"], sec["id"], path, sec["kit"], top_k),
        ).fetchall()
        return [section_to_result(row, 0.0, ["related"]) for row in rows if row["id"] != sec["id"]]

    def answer_question(self, question: str, *, top_k: int = 6, ai_mode: str | None = None, synthesize: bool = False, version: str | None = None) -> dict[str, Any]:
        results = self.search(question, top_k=top_k, ai_mode=ai_mode, version=version)
        if synthesize and self._runtime_ai_enabled(ai_mode) and self.ai and self.ai.can_llm:
            try:
                return {"answer": self.ai.answer(question, results), "citations": results, "degraded": False, "synthesized": True, "llm_used": True}
            except Exception:
                return {
                    "answer": "LLM 答案合成失败，已返回排序后的检索片段。",
                    "citations": results,
                    "degraded": True,
                    "synthesized": False,
                    "llm_used": False,
                }
        return {
            "answer": "LLM 答案合成未启用，已返回排序后的检索片段。",
            "citations": results,
            "degraded": False,
            "synthesized": False,
            "llm_used": False,
        }

    def _runtime_ai_enabled(self, ai_mode: str | None) -> bool:
        if ai_mode == "off":
            return False
        if ai_mode in {AI_RUNTIME, AI_ALL}:
            return bool(self.ai)
        return bool(self.cfg.ai_enabled and self.cfg.ai_runtime and self.ai)

    def _candidate(self, candidates: dict[int, Candidate], section_id: int) -> Candidate:
        if section_id not in candidates:
            candidates[section_id] = Candidate(section_id)
        return candidates[section_id]

    def _symbol_candidates(self, candidates: dict[int, Candidate], query: str, scope: str, weight: float, version: str | None) -> None:
        if scope not in {"all", "api"}:
            return
        version_sql, version_params = version_where("s", version)
        symbol_terms = [query, *fallback_terms(query)]
        seen: set[str] = set()
        for term in symbol_terms:
            norm = normalize_symbol(term)
            if not norm or norm in seen:
                continue
            seen.add(norm)
            rows = self.con.execute(
                f"""
                select s.section_id, s.name, s.normalized from symbols s
                where (s.normalized = ? or s.normalized like ? or s.name like ?) {version_sql}
                limit 80
                """,
                (norm, f"{norm}%", f"%{term}%", *version_params),
            ).fetchall()
            for row in rows:
                if row["normalized"] == norm:
                    score = 120.0
                elif row["normalized"].startswith(norm):
                    score = 85.0
                else:
                    score = 55.0
                self._candidate(candidates, row["section_id"]).add(score * weight, "symbol")

    def _fts_candidates(self, candidates: dict[int, Candidate], query: str, scope: str, weight: float, version: str | None) -> None:
        if scope == "examples":
            return
        doc_filter = ""
        params_tail: list[Any] = []
        if scope in {"api", "guide"}:
            doc_filter = " and s.doc_type = ?"
            params_tail.append(scope)
        version_sql, version_params = version_where("s", version)
        doc_filter += version_sql
        params_tail.extend(version_params)
        lex = make_fts_query(query)
        if lex:
            try:
                rows = self.con.execute(
                    f"""
                    select s.id, bm25(fts_sections_lex, 4.0, 2.0, 1.0, 2.5) rank
                    from fts_sections_lex join sections s on s.id = fts_sections_lex.rowid
                    where fts_sections_lex match ? {doc_filter}
                    order by rank limit 80
                    """,
                    [lex, *params_tail],
                ).fetchall()
                for row in rows:
                    self._candidate(candidates, row["id"]).add((35.0 / (1.0 + abs(row["rank"]))) * weight, "fts")
            except sqlite3.OperationalError:
                pass
        tri = make_trigram_query(query)
        if tri:
            try:
                rows = self.con.execute(
                    f"""
                    select s.id, bm25(fts_sections_tri, 4.0, 2.0, 1.0, 2.5) rank
                    from fts_sections_tri join sections s on s.id = fts_sections_tri.rowid
                    where fts_sections_tri match ? {doc_filter}
                    order by rank limit 80
                    """,
                    [tri, *params_tail],
                ).fetchall()
                for row in rows:
                    self._candidate(candidates, row["id"]).add((42.0 / (1.0 + abs(row["rank"]))) * weight, "trigram")
            except sqlite3.OperationalError:
                pass

    def _substring_candidates(self, candidates: dict[int, Candidate], query: str, scope: str, weight: float, version: str | None) -> None:
        tokens = fallback_terms(query)
        if not tokens:
            return
        clauses = []
        params: list[Any] = []
        for token in tokens[:4]:
            like = f"%{token}%"
            clauses.append("(title like ? or breadcrumb like ? or body like ? or search_boost_text like ?)")
            params.extend([like, like, like, like])
        doc_filter = ""
        if scope in {"api", "guide"}:
            doc_filter = " and s.doc_type = ?"
            params.append(scope)
        version_sql, version_params = version_where("s", version)
        doc_filter += version_sql
        params.extend(version_params)
        rows = self.con.execute(
            f"""
            select s.id, s.title, s.breadcrumb from sections s
            where ({' or '.join(clauses)}) {doc_filter}
            limit 100
            """,
            params,
        ).fetchall()
        for row in rows:
            score = 18.0
            lowered = (row["title"] + " " + row["breadcrumb"]).lower()
            if query.lower() in lowered:
                score += 20.0
            self._candidate(candidates, row["id"]).add(score * weight, "substring")

    def _example_candidates(self, candidates: dict[int, Candidate], query: str, weight: float, version: str | None) -> None:
        examples = self.find_examples(query, top_k=30, version=version)
        for rank, item in enumerate(examples, 1):
            version_sql, version_params = version_where("e", version)
            row = self.con.execute(
                f"select e.section_id from examples e where e.path = ? and e.start_line = ? {version_sql} limit 1",
                (item["path"], item["start_line"], *version_params),
            ).fetchone()
            if row:
                self._candidate(candidates, row["section_id"]).add((28.0 / rank) * weight, "example")

    def _numeric_candidates(self, candidates: dict[int, Candidate], query: str, scope: str, version: str | None) -> None:
        numbers = [item for item in re.findall(r"\d{5,}", query) if item]
        if not numbers:
            return
        doc_filter = ""
        params_tail: list[Any] = []
        if scope in {"api", "guide"}:
            doc_filter = " and doc_type = ?"
            params_tail.append(scope)
        version_sql, version_params = version_where("", version)
        doc_filter += version_sql
        params_tail.extend(version_params)
        for number in numbers[:4]:
            rows = self.con.execute(
                f"""
                select id, title, breadcrumb, path, anchor, body
                from sections
                where (title like ? or breadcrumb like ? or anchor like ? or body like ?) {doc_filter}
                limit 120
                """,
                [f"%{number}%", f"%{number}%", f"%{number}%", f"%{number}%", *params_tail],
            ).fetchall()
            for row in rows:
                score = 140.0
                if number in (row["title"] or "") or number in (row["anchor"] or ""):
                    score += 110.0
                if "errorcode" in (row["path"] or "").lower():
                    score += 80.0
                self._candidate(candidates, row["id"]).add(score, "number-exact")

    def _structural_seed_candidates(self, candidates: dict[int, Candidate], query: str, scope: str, version: str | None) -> None:
        intents = detect_intents(query)
        if not (intents & {"howto", "limit", "lifecycle", "config", "transfer", "permission", "logging"}):
            return
        clauses = []
        params: list[Any] = []
        seed_terms = structural_seed_terms(query, intents)
        for term in seed_terms[:10]:
            clauses.append("(title like ? or breadcrumb like ? or body like ?)")
            like = f"%{term}%"
            params.extend([like, like, like])
        if not clauses:
            return
        doc_filter = ""
        if scope in {"api", "guide"}:
            doc_filter = " and s.doc_type = ?"
            params.append(scope)
        elif "howto" in intents:
            doc_filter = " and s.doc_type in ('guide', 'api')"
        version_sql, version_params = version_where("s", version)
        doc_filter += version_sql
        params.extend(version_params)
        rows = self.con.execute(
            f"""
            select s.id, s.path, s.title, s.breadcrumb, s.doc_type
            from sections s
            where ({' or '.join(clauses)}) {doc_filter}
            order by s.start_line
            limit 160
            """,
            params,
        ).fetchall()
        for row in rows:
            score = 28.0
            focused_l = f"{row['title']} {row['breadcrumb']}".lower()
            if row["doc_type"] == "guide" and "howto" in intents:
                score += 35.0
            if contains_any(focused_l, GUIDE_HEADING_TERMS):
                score += 35.0
            if query.lower() in focused_l:
                score += 35.0
            self._candidate(candidates, row["id"]).add(score, "structure-seed")

    def _coverage_candidates(self, candidates: dict[int, Candidate], query: str, scope: str, version: str | None) -> None:
        terms = informative_query_terms(query)
        if len(terms) < 2:
            return
        clauses = []
        params: list[Any] = []
        for term in terms[:8]:
            clauses.append("(title like ? or breadcrumb like ? or body like ? or search_boost_text like ?)")
            like = f"%{term}%"
            params.extend([like, like, like, like])
        doc_filter = ""
        if scope in {"api", "guide"}:
            doc_filter = " and s.doc_type = ?"
            params.append(scope)
        version_sql, version_params = version_where("s", version)
        doc_filter += version_sql
        params.extend(version_params)
        rows = self.con.execute(
            f"""
            select s.id, s.title, s.breadcrumb, s.body, s.search_boost_text
            from sections s
            where ({' or '.join(clauses)}) {doc_filter}
            limit 360
            """,
            params,
        ).fetchall()
        total_weight = sum(term_weight(term) for term in terms[:8]) or 1.0
        for row in rows:
            haystack = f"{row['title']}\n{row['breadcrumb']}\n{row['body'][:5000]}\n{row['search_boost_text']}".lower()
            focused = f"{row['title']}\n{row['breadcrumb']}".lower()
            matched = [term for term in terms[:8] if term.lower() in haystack]
            if not matched:
                continue
            match_weight = sum(term_weight(term) for term in matched)
            coverage = match_weight / total_weight
            score = 18.0 + (90.0 * coverage)
            if len(matched) >= 2:
                score += 35.0
            focused_matched = [term for term in matched if term.lower() in focused]
            if focused_matched:
                score += 35.0 * (sum(term_weight(term) for term in focused_matched) / total_weight)
            if query.lower() in haystack:
                score += 45.0
            self._candidate(candidates, row["id"]).add(score, "term-coverage")

    def _vector_candidates(self, candidates: dict[int, Candidate], query: str, scope: str, version: str | None) -> None:
        if not self.ai:
            return
        qvec = self._embed_runtime_query(query)
        if not qvec:
            return
        doc_filter = ""
        params: list[Any] = [self.cfg.embedding.provider, self.cfg.embedding.model]
        if scope in {"api", "guide"}:
            doc_filter = " and s.doc_type = ?"
            params.append(scope)
        version_sql, version_params = version_where("s", version)
        doc_filter += version_sql
        params.extend(version_params)
        candidate_filter = ""
        ranked_pool = sorted(candidates.values(), key=lambda item: item.score, reverse=True)
        pool_ids = [item.section_id for item in ranked_pool[:300]]
        if len(pool_ids) >= 20:
            placeholders = ",".join("?" for _ in pool_ids)
            candidate_filter = f" and v.section_id in ({placeholders})"
            params.extend(pool_ids)
        rows = self.con.execute(
            f"""
            select v.section_id, v.vector_json
            from vectors v join sections s on s.id = v.section_id
            where v.provider = ? and v.model = ? {doc_filter} {candidate_filter}
            """,
            params,
        ).fetchall()
        scored: list[tuple[int, float]] = []
        for row in rows:
            vec = json_loads(row["vector_json"], [])
            if isinstance(vec, list):
                sim = cosine(qvec, vec)
                if sim > 0:
                    scored.append((row["section_id"], sim))
        for rank, (section_id, sim) in enumerate(sorted(scored, key=lambda item: item[1], reverse=True)[:50], 1):
            self._candidate(candidates, section_id).add((45.0 * sim) + (12.0 / rank), "vector")

    def _embed_runtime_query(self, query: str) -> list[float]:
        if not self.ai:
            return []
        if self.ai_cache:
            cached = self.ai_cache.get_vector(provider=self.cfg.embedding.provider, model=self.cfg.embedding.model, vector_text=f"query:{query}")
            if cached:
                return cached.vector
        # 查询期收紧网络预算：5s 单次、零重试（构建期共享同一 client，用完即恢复）
        http = getattr(getattr(self.ai, "embedding", None), "http", None)
        saved = (http.timeout, http.max_retries) if http is not None else None
        if http is not None:
            http.timeout, http.max_retries = min(http.timeout, 5.0), 0
        try:
            vector = self.ai.embed_query(query)
        finally:
            if http is not None and saved is not None:
                http.timeout, http.max_retries = saved
        if vector and self.ai_cache:
            self.ai_cache.put_vector(provider=self.cfg.embedding.provider, model=self.cfg.embedding.model, vector_text=f"query:{query}", vector=vector)
        return vector

    def _quality_adjustments(self, candidates: dict[int, Candidate], query: str) -> None:
        query_l = query.lower().strip()
        terms = [term.lower() for term in fallback_terms(query) if len(term.strip()) >= 2]
        informative = informative_query_terms(query)
        informative_total = sum(term_weight(term) for term in informative[:8]) or 0.0
        identifiers = [item.lower() for item in ASCII_TOKEN_RE.findall(query) if len(item) >= 3 and not item.isdigit()]
        numeric = query_l.isdigit() and len(query_l) >= 5
        intents = detect_intents(query)
        howto = is_howto_query(query)
        numbers = re.findall(r"\d{5,}", query)
        ids = [c.section_id for c in candidates.values()]
        rows_by_id: dict[int, Any] = {}
        for i in range(0, len(ids), 900):  # 每候选一条 select 的 N+1 是中文查询 2s 的主要成分；900 防变量数上限
            chunk = ids[i : i + 900]
            marks = ",".join("?" for _ in chunk)
            for r in self.con.execute(f"select id, title, breadcrumb, path, doc_type, body, start_line, end_line from sections where id in ({marks})", chunk).fetchall():
                rows_by_id[int(r["id"])] = r
        for candidate in list(candidates.values()):
            row = rows_by_id.get(candidate.section_id)
            if not row:
                continue
            title_l = row["title"].lower()
            breadcrumb_l = row["breadcrumb"].lower()
            path_l = row["path"].lower()
            body_l = row["body"].lower()
            haystack_l = f"{title_l}\n{breadcrumb_l}\n{body_l[:5000]}"
            if numbers and any(number in haystack_l for number in numbers):
                candidate.add(160.0 if "errorcode" in path_l else 90.0, "number-match")
            if query_l and title_l == query_l:
                candidate.add(90.0, "exact-title")
            elif query_l and title_l.startswith(query_l):
                candidate.add(70.0 if numeric else 35.0, "title-prefix")
            elif query_l and query_l in title_l:
                candidate.add(38.0 if numeric else 22.0, "title-contains")
            if query_l and query_l in breadcrumb_l:
                candidate.add(12.0, "breadcrumb")
            if howto and row["doc_type"] == "guide":
                candidate.add(34.0, "guide-intent")
            self._intent_boost(candidate, row, intents)
            if identifiers:
                matched_ids = [item for item in identifiers if identifier_in_text(item, haystack_l)]
                focused_ids = [item for item in matched_ids if identifier_in_text(item, f"{title_l}\n{breadcrumb_l}")]
                if len(set(matched_ids)) == len(set(identifiers)):
                    candidate.add(95.0, "identifier-match")
                elif matched_ids:
                    candidate.add(35.0, "partial-identifier-match")
                elif not {"symbol", "number-exact", "vector"} & set(candidate.reasons):
                    candidate.score *= 0.72
                    candidate.reasons.append("identifier-miss-downrank")
                if focused_ids:
                    candidate.add(35.0, "focused-identifier-match")
            if informative_total:
                focused = f"{title_l}\n{breadcrumb_l}"
                matched = [term for term in informative[:8] if term.lower() in haystack_l]
                focused_matched = [term for term in matched if term.lower() in focused]
                coverage = sum(term_weight(term) for term in matched) / informative_total
                focused_coverage = sum(term_weight(term) for term in focused_matched) / informative_total
                if coverage >= 0.85:
                    candidate.add(95.0, "high-term-coverage")
                elif coverage >= 0.55:
                    candidate.add(55.0, "term-coverage")
                elif coverage >= 0.3:
                    candidate.add(20.0, "partial-term-coverage")
                if focused_coverage >= 0.45:
                    candidate.add(45.0, "focused-term-coverage")
                if coverage < 0.22 and not {"symbol", "number-exact", "vector"} & set(candidate.reasons):
                    candidate.score *= 0.62
                    candidate.reasons.append("low-coverage-downrank")
            if len(terms) >= 2:
                matched = sum(1 for term in terms[:5] if term in haystack_l)
                if matched == min(len(terms), 5):
                    candidate.add(36.0, "all-terms")
                elif matched >= 2:
                    candidate.add(12.0, "multi-term")
                focused = f"{title_l}\n{breadcrumb_l}"
                focused_matches = sum(1 for term in terms[:5] if term in focused)
                if focused_matches >= 2:
                    candidate.add(24.0, "focused-terms")
            # Top-level generated table-of-contents pages are useful, but should not outrank
            # focused content pages for ordinary topic searches.
            if row["path"].endswith("/website.md") and query_l not in title_l:
                candidate.score *= 0.35
                candidate.reasons.append("toc-downrank")
            if (row["end_line"] - row["start_line"]) > 650 and query_l not in title_l:
                candidate.score *= 0.75

    def _intent_boost(self, candidate: Candidate, row: sqlite3.Row, intents: set[str]) -> None:
        if not intents:
            return
        title_l = row["title"].lower()
        breadcrumb_l = row["breadcrumb"].lower()
        path_l = row["path"].lower()
        body_l = row["body"][:6000].lower()
        focused = f"{title_l}\n{breadcrumb_l}"
        haystack = f"{focused}\n{path_l}\n{body_l}"

        def add_if(intent: str, condition: bool, score: float, reason: str) -> None:
            if intent in intents and condition:
                candidate.add(score, reason)

        guide_like = row["doc_type"] == "guide" or contains_any(focused, GUIDE_HEADING_TERMS)
        add_if("howto", guide_like, 45.0, "intent-howto-guide")
        add_if("howto", contains_any(focused, GUIDE_HEADING_TERMS), 55.0, "intent-howto-heading")
        add_if("error_code", contains_any(haystack, ERROR_TERMS), 90.0, "intent-error")
        add_if("limit", contains_any(haystack, LIMIT_TERMS) or bool(UNIT_RE.search(haystack)), 95.0, "intent-limit")
        add_if("lifecycle", contains_any(haystack, LIFECYCLE_TERMS), 105.0, "intent-lifecycle")
        add_if("config", contains_any(haystack, CONFIG_TERMS), 80.0, "intent-config")
        add_if("transfer", contains_any(haystack, TRANSFER_TERMS), 85.0, "intent-transfer")
        add_if("permission", contains_any(haystack, PERMISSION_TERMS), 85.0, "intent-permission")
        add_if("logging", contains_any(haystack, LOG_TERMS), 80.0, "intent-logging")

        if guide_like and intents & {"howto", "config", "transfer", "permission", "logging", "lifecycle"}:
            candidate.add(25.0, "workflow-guide")

    def _hydrate_candidate(self, candidate: Candidate, query: str) -> dict[str, Any]:
        row = self.con.execute("select * from sections where id = ?", (candidate.section_id,)).fetchone()
        result = section_to_result(row, candidate.score, candidate.reasons)
        result["snippet"] = make_snippet(row["body"], query)
        symbols = self.con.execute(
            "select name, kind, signature from symbols where section_id = ? order by id limit 10",
            (candidate.section_id,),
        ).fetchall()
        result["symbols"] = [dict(item) for item in symbols]
        return result


def section_to_result(row: sqlite3.Row, score: float, reasons: list[str]) -> dict[str, Any]:
    return {
        "version": row["version"],
        "title": row["title"],
        "kind": row["kind"],
        "doc_type": row["doc_type"],
        "kit": row["kit"],
        "path": row["path"],
        "anchor": row["anchor"],
        "ref": f"{row['path']}#{row['anchor']}",
        "start_line": row["start_line"],
        "end_line": row["end_line"],
        "breadcrumb": row["breadcrumb"],
        "score": round(score, 4),
        "reasons": reasons,
        "snippet": make_snippet(row["body"], row["title"]),
    }


def split_ref(ref: str) -> tuple[str, str | None]:
    if "#" not in ref:
        return ref, None
    path, anchor = ref.split("#", 1)
    return path, anchor or None


def normalize_query_version(version: str | None) -> str | None:
    version = (version or "").strip()
    if not version:
        return None
    if version.lower() in {"all", "*"}:
        return None
    return version


def version_where(alias: str, version: str | None, *, active_only: bool = True) -> tuple[str, list[Any]]:
    prefix = f"{alias}." if alias else ""
    clauses: list[str] = []
    params: list[Any] = []
    if version:
        clauses.append(f"{prefix}version = ?")
        params.append(version)
    if active_only:
        clauses.append(f"exists (select 1 from versions __cjdocs_v where __cjdocs_v.version = {prefix}version and __cjdocs_v.status = 'ready')")
    if not clauses:
        return "", []
    return " and " + " and ".join(clauses), params


def contains_any(text: str, terms: tuple[str, ...] | list[str]) -> bool:
    text_l = text.lower()
    return any(term.lower() in text_l for term in terms)


def identifier_in_text(identifier: str, text: str) -> bool:
    identifier = identifier.lower().strip()
    if not identifier:
        return False
    if "_" in identifier or len(identifier) > 4:
        return identifier in text
    return re.search(rf"(?<![a-z0-9_]){re.escape(identifier)}(?![a-z0-9_])", text) is not None


def detect_intents(query: str) -> set[str]:
    query_l = query.lower()
    intents: set[str] = set()
    if is_howto_query(query):
        intents.add("howto")
    if re.search(r"\d{4,}", query) and contains_any(query, ERROR_TERMS):
        intents.add("error_code")
    if contains_any(query, LIMIT_TERMS) or UNIT_RE.search(query_l):
        intents.add("limit")
    if contains_any(query, LIFECYCLE_TERMS):
        intents.add("lifecycle")
    if contains_any(query, CONFIG_TERMS):
        intents.add("config")
    if contains_any(query, TRANSFER_TERMS):
        intents.add("transfer")
    if contains_any(query, PERMISSION_TERMS):
        intents.add("permission")
    if contains_any(query, LOG_TERMS):
        intents.add("logging")
    return intents


def is_howto_query(query: str) -> bool:
    return contains_any(query, HOWTO_TERMS)


def raw_query_terms(query: str) -> list[str]:
    result: list[str] = []

    def add(term: str) -> None:
        term = term.strip()
        if term and term not in result and term not in CJK_STOP_TERMS:
            result.append(term)

    for item in ASCII_TOKEN_RE.findall(query):
        add(item)
    for run in CJK_TOKEN_RE.findall(query):
        if len(run) <= 10:
            add(run)
        if len(run) > 2:
            for size in (4, 3, 2):
                for idx in range(0, max(0, len(run) - size + 1)):
                    gram = run[idx : idx + size]
                    if gram not in CJK_STOP_TERMS and not any(ch in CJK_BAD_GRAM_CHARS for ch in gram):
                        add(gram)
    return result[:16]


def is_generic_query_term(term: str) -> bool:
    term_l = term.strip().lower()
    if not term_l or term_l in CJK_STOP_TERMS or term_l in GENERIC_QUERY_TERMS:
        return True
    if has_cjk(term_l) and len(term_l) > 4 and any(stop in term_l for stop in CJK_STOP_TERMS):
        return True
    return has_cjk(term_l) and len(term_l) <= 1


def term_weight(term: str) -> float:
    term = term.strip()
    if not term:
        return 0.0
    if term.lower() in GENERIC_QUERY_TERMS:
        return 0.55
    if has_cjk(term):
        if len(term) == 3:
            return 1.9
        if len(term) == 4:
            return 1.75
        if len(term) == 2:
            return 1.25
        return 1.0 + min(len(term), 8) * 0.12
    if term.isdigit():
        return 2.2
    return 1.0 + min(len(term), 16) * 0.08


def informative_query_terms(query: str) -> list[str]:
    raw_terms = raw_query_terms(query)
    specific = [term for term in raw_terms if not is_generic_query_term(term)]
    source = specific if specific else raw_terms
    result: list[str] = []
    for term in sorted(source, key=lambda item: (term_weight(item), len(item)), reverse=True):
        term = term.strip()
        term_l = term.lower()
        if not term_l or term_l in {item.lower() for item in result}:
            continue
        if has_cjk(term) and len(term) > 12:
            continue
        result.append(term)
    return result[:12]


def structural_seed_terms(query: str, intents: set[str]) -> list[str]:
    result = raw_query_terms(query)[:6]

    def add_many(items: tuple[str, ...]) -> None:
        for item in items:
            if item and item not in result:
                result.append(item)

    # How-to headings are useful ranking hints, but too broad for recall.
    # Keep them out of seed queries so generic words like "steps" do not
    # retrieve unrelated symbols in other document sets.
    if "limit" in intents:
        add_many(LIMIT_TERMS)
    if "lifecycle" in intents:
        add_many(LIFECYCLE_TERMS)
    if "config" in intents:
        add_many(CONFIG_TERMS)
    if "transfer" in intents:
        add_many(TRANSFER_TERMS)
    if "permission" in intents:
        add_many(PERMISSION_TERMS)
    if "logging" in intents:
        add_many(LOG_TERMS)
    if "error_code" in intents:
        add_many(ERROR_TERMS)
    return result[:24]


def expand_query(query: str) -> list[str]:
    result = [query]
    for item in raw_query_terms(query):
        if item not in result:
            result.append(item)
    if re.search(r"\d{5,}", query):
        for item in re.findall(r"\d{5,}", query):
            if item not in result:
                result.append(item)
    return result[:18]


def make_fts_query(query: str) -> str:
    tokens = []
    for token in ASCII_TOKEN_RE.findall(query):
        token = token.replace('"', '""')
        if len(token) > 2 and not token.isdigit():
            tokens.append(f'"{token}"*')
        else:
            tokens.append(f'"{token}"')
    for token in [term for term in fallback_terms(query) if has_cjk(term)]:
        tokens.append(f'"{token.replace(chr(34), chr(34) * 2)}"')
    return " OR ".join(tokens[:12])


def make_trigram_query(query: str) -> str:
    query = query.strip()
    if len(query) < 3:
        return ""
    if has_cjk(query):
        return f'"{query.replace(chr(34), chr(34) * 2)}"'
    return make_fts_query(query)


def fallback_terms(query: str) -> list[str]:
    terms = []
    query = query.strip()
    def add(term: str) -> None:
        if term and term not in terms and term not in CJK_STOP_TERMS:
            terms.append(term)

    for item in expand_query(query)[1:]:
        add(item)

    for domain in DOMAIN_TERMS:
        if domain in query:
            add(domain)
    for item in re.split(r"\s+", query.strip()):
        item = item.strip(" ，。！？；：、/\\|()（）[]【】{}")
        if has_cjk(item) and len(item) > 8:
            continue
        add(item)
    for item in ASCII_TOKEN_RE.findall(query):
        add(item)
    for run in CJK_TOKEN_RE.findall(query):
        if len(run) <= 8:
            add(run)
        if len(run) > 2:
            for size in (4, 3, 2):
                for idx in range(0, max(0, len(run) - size + 1)):
                    gram = run[idx : idx + size]
                    if gram in CJK_STOP_TERMS or any(ch in CJK_BAD_GRAM_CHARS for ch in gram):
                        continue
                    if gram in query and (gram in DOMAIN_TERMS or size == 2):
                        add(gram)
    # Avoid letting generic UI words drown out domain terms.
    terms = [term for term in terms if term not in CJK_STOP_TERMS]
    return terms[:16]


def make_snippet(text: str, query: str, *, max_chars: int = 700) -> str:
    text = re.sub(r"\n{3,}", "\n\n", text or "").strip()
    if len(text) <= max_chars:
        return text
    terms = fallback_terms(query)
    lower = text.lower()
    pos = -1
    for term in terms:
        pos = lower.find(term.lower())
        if pos >= 0:
            break
    if pos < 0:
        return text[:max_chars].rstrip() + "..."
    start = max(0, pos - max_chars // 3)
    end = min(len(text), start + max_chars)
    prefix = "..." if start else ""
    suffix = "..." if end < len(text) else ""
    return prefix + text[start:end].strip() + suffix


def cosine(a: list[float], b: list[float]) -> float:
    if len(a) != len(b) or not a:
        return 0.0
    dot = sum(float(x) * float(y) for x, y in zip(a, b))
    na = math.sqrt(sum(float(x) * float(x) for x in a))
    nb = math.sqrt(sum(float(y) * float(y) for y in b))
    if not na or not nb:
        return 0.0
    return dot / (na * nb)
