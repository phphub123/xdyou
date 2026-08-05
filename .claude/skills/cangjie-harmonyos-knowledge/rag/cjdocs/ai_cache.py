from __future__ import annotations

import datetime as dt
import sqlite3
from dataclasses import dataclass
from pathlib import Path
from typing import Any

from .ai import EnhancedSection
from .util import json_dumps, json_loads, sha256_text


CACHE_SCHEMA = """
pragma journal_mode=WAL;
pragma synchronous=NORMAL;

create table if not exists summary_cache (
  cache_key text primary key,
  provider text not null,
  model text not null,
  prompt_version text not null,
  source_hash text not null,
  summary text not null,
  keywords_json text not null,
  aliases_json text not null,
  search_boost_text text not null,
  structured_json text not null,
  created_at text not null
);

create table if not exists vector_cache (
  cache_key text primary key,
  provider text not null,
  model text not null,
  source_hash text not null,
  dimensions integer not null,
  vector_json text not null,
  created_at text not null
);
"""


SUMMARY_PROMPT_VERSION = "summary-v1"


@dataclass(slots=True)
class CachedVector:
    dimensions: int
    vector: list[float]


class AICache:
    def __init__(self, path: Path) -> None:
        path.parent.mkdir(parents=True, exist_ok=True)
        self.path = path
        self.con = sqlite3.connect(path)
        self.con.row_factory = sqlite3.Row
        self.con.executescript(CACHE_SCHEMA)
        self.con.commit()

    def close(self) -> None:
        self.con.close()

    def summary_key(self, *, provider: str, model: str, section_text: str) -> str:
        return sha256_text("|".join([SUMMARY_PROMPT_VERSION, provider, model, sha256_text(section_text)]))

    def vector_key(self, *, provider: str, model: str, vector_text: str) -> str:
        return sha256_text("|".join(["vector-v1", provider, model, sha256_text(vector_text)]))

    def get_summary(self, *, provider: str, model: str, section_text: str) -> EnhancedSection | None:
        key = self.summary_key(provider=provider, model=model, section_text=section_text)
        row = self.con.execute("select * from summary_cache where cache_key = ?", (key,)).fetchone()
        if not row:
            return None
        return EnhancedSection(
            summary=row["summary"],
            keywords=json_loads(row["keywords_json"], []),
            aliases=json_loads(row["aliases_json"], []),
            search_boost_text=row["search_boost_text"],
            structured=json_loads(row["structured_json"], {}),
        )

    def put_summary(self, *, provider: str, model: str, section_text: str, enhanced: EnhancedSection) -> None:
        key = self.summary_key(provider=provider, model=model, section_text=section_text)
        self.con.execute(
            """
            insert or replace into summary_cache(
              cache_key, provider, model, prompt_version, source_hash, summary,
              keywords_json, aliases_json, search_boost_text, structured_json, created_at
            )
            values (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)
            """,
            (
                key,
                provider,
                model,
                SUMMARY_PROMPT_VERSION,
                sha256_text(section_text),
                enhanced.summary,
                json_dumps(enhanced.keywords),
                json_dumps(enhanced.aliases),
                enhanced.search_boost_text,
                json_dumps(enhanced.structured),
                dt.datetime.now(dt.UTC).isoformat(),
            ),
        )
        self.con.commit()

    def get_vector(self, *, provider: str, model: str, vector_text: str) -> CachedVector | None:
        key = self.vector_key(provider=provider, model=model, vector_text=vector_text)
        row = self.con.execute("select * from vector_cache where cache_key = ?", (key,)).fetchone()
        if not row:
            return None
        vector = json_loads(row["vector_json"], [])
        if not isinstance(vector, list):
            return None
        return CachedVector(dimensions=int(row["dimensions"]), vector=vector)

    def put_vector(self, *, provider: str, model: str, vector_text: str, vector: list[float]) -> None:
        key = self.vector_key(provider=provider, model=model, vector_text=vector_text)
        self.con.execute(
            """
            insert or replace into vector_cache(cache_key, provider, model, source_hash, dimensions, vector_json, created_at)
            values (?, ?, ?, ?, ?, ?, ?)
            """,
            (
                key,
                provider,
                model,
                sha256_text(vector_text),
                len(vector),
                json_dumps(vector),
                dt.datetime.now(dt.UTC).isoformat(),
            ),
        )
        self.con.commit()

    def stats(self) -> dict[str, Any]:
        return {
            "summary_cache": self.con.execute("select count(*) c from summary_cache").fetchone()["c"],
            "vector_cache": self.con.execute("select count(*) c from vector_cache").fetchone()["c"],
        }

