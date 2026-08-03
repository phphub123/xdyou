from __future__ import annotations

import argparse
import json
from dataclasses import asdict
from pathlib import Path

from .config import AI_CHOICES, apply_overrides, load_config
from .db import connect, init_db
from .http_server import run_http
from .indexer import build_index, compact_index, remove_version
from .mcp_server import run_mcp
from .search import Searcher
from .util import configure_stdio


def _die(kind: str, message: str, fix: str) -> int:
    print(json.dumps({"error": kind, "message": message, "fix": fix}, ensure_ascii=False))
    return 1


def main(argv: list[str] | None = None) -> int:
    try:
        return _main(argv)
    except Exception as exc:  # 出口统一可操作化（tomllib/sqlite3 常见故障优先归类）
        name = type(exc).__name__
        text = str(exc)
        if "TOMLDecodeError" in name:
            return _die("config_invalid", f"cjdocs.toml 解析失败: {text}", "检查当前目录 cjdocs.toml 的 TOML 语法（引号/分区/等号）")
        if "DatabaseError" in name or "database disk image" in text or "malformed" in text:
            return _die("index_corrupt", f"索引损坏: {text}", "重建索引: python cjdocs.py build")
        return _die("internal", f"{name}: {text}", "带上完整命令与该 JSON 反馈给平台维护者")


def _main(argv: list[str] | None = None) -> int:
    configure_stdio()
    parser = argparse.ArgumentParser(prog="cjdocs", description="Cangjie HarmonyOS docs knowledge service")
    parser.add_argument("--config", help="Path to cjdocs.toml")
    parser.add_argument("--index-dir", help="Index directory, defaults to .cjdocs")
    parser.add_argument("--ai-provider", help="Simplified AI provider alias, for example: aliyun")
    parser.add_argument("--api-key-env", help="Environment variable used for both LLM and embedding API keys")
    parser.add_argument("--api-key", help="API key used for both LLM and embedding services")
    parser.add_argument("--llm-provider")
    parser.add_argument("--llm-model")
    parser.add_argument("--llm-base-url")
    parser.add_argument("--llm-api-key-env")
    parser.add_argument("--llm-api-key")
    parser.add_argument("--embedding-provider")
    parser.add_argument("--embedding-model")
    parser.add_argument("--embedding-base-url")
    parser.add_argument("--embedding-api-key-env")
    parser.add_argument("--embedding-api-key")
    parser.add_argument("--embedding-batch-size", type=int)

    sub = parser.add_subparsers(dest="cmd", required=True)
    p_build = sub.add_parser("build", help="Build the local index")
    p_build.add_argument("docs_root", nargs="?", default=None)
    p_build.add_argument("--version", default=None, help="SDK/docs version stored in the index, for example 6.1.1.345")
    p_build.add_argument("--incremental", action="store_true", help="Update only changed files for this version and preserve other versions")
    p_build.add_argument("--no-remove-missing", action="store_true", help="In incremental mode, keep indexed docs that no longer exist on disk")
    p_build.add_argument("--ai", choices=AI_CHOICES, default="off")
    p_build.add_argument("--no-ai-summary", action="store_true", help="Skip LLM summaries/aliases during AI preprocessing")
    p_build.add_argument("--no-ai-embedding", action="store_true", help="Skip embedding generation during AI preprocessing")
    p_build.add_argument("--progress-interval", type=int, default=10, help="Log AI progress every N sections/batches")
    p_build.add_argument("--quiet", action="store_true")

    p_query = sub.add_parser("query", help="Search docs from CLI")
    p_query.add_argument("query")
    p_query.add_argument("--version", default=None, help="Version to search; use 'all' to search every version")
    p_query.add_argument("--ai", choices=("off", "runtime", "all"), default=None)
    p_query.add_argument("--scope", choices=("all", "api", "guide", "examples"), default="all")
    p_query.add_argument("--top-k", type=int, default=8)

    p_symbol = sub.add_parser("symbol", help="Look up an API symbol")
    p_symbol.add_argument("name")
    p_symbol.add_argument("--version", default=None)

    p_doc = sub.add_parser("read", help="Read doc by ref")
    p_doc.add_argument("ref")
    p_doc.add_argument("--version", default=None)
    p_doc.add_argument("--mode", choices=("section", "full"), default="section")
    p_doc.add_argument("--max-chars", type=int, default=12000)

    p_answer = sub.add_parser("answer", help="Return ranked citations for a question, with optional LLM synthesis")
    p_answer.add_argument("question")
    p_answer.add_argument("--version", default=None)
    p_answer.add_argument("--ai", choices=("off", "runtime", "all"), default=None)
    p_answer.add_argument("--top-k", type=int, default=6)
    p_answer.add_argument("--synthesize", action="store_true", help="Explicitly enable LLM answer synthesis after retrieval")

    p_serve = sub.add_parser("serve", help="Run HTTP server")
    p_serve.add_argument("--host", default="127.0.0.1")
    p_serve.add_argument("--port", type=int, default=8765)
    p_serve.add_argument("--ai", choices=AI_CHOICES, default=None)

    p_mcp = sub.add_parser("mcp", help="Run MCP stdio server")
    p_mcp.add_argument("--ai", choices=AI_CHOICES, default=None)

    p_versions = sub.add_parser("versions", help="List or remove indexed document versions")
    versions_sub = p_versions.add_subparsers(dest="versions_cmd", required=True)
    versions_sub.add_parser("list", help="List indexed versions")
    p_versions_remove = versions_sub.add_parser("remove", help="Remove one indexed version")
    p_versions_remove.add_argument("version")
    p_versions_remove.add_argument("--physical", action="store_true", help="Physically delete rows and rebuild FTS; slower, mainly for offline maintenance")
    versions_sub.add_parser("compact", help="Physically compact the index by keeping ready versions only")

    sub.add_parser("doctor", help="Check local index and SQLite capabilities")

    args = parser.parse_args(argv)
    cfg = load_config(args.config)
    cfg = apply_overrides(
        cfg,
        docs_root=getattr(args, "docs_root", None),
        index_dir=args.index_dir,
        docs_version=getattr(args, "version", None),
        ai_mode=getattr(args, "ai", None),
        ai_provider=args.ai_provider,
        api_key_env=args.api_key_env,
        api_key=args.api_key,
        preprocess_llm=False if getattr(args, "no_ai_summary", False) else None,
        preprocess_embedding=False if getattr(args, "no_ai_embedding", False) else None,
        llm_provider=args.llm_provider,
        llm_model=args.llm_model,
        llm_base_url=args.llm_base_url,
        llm_api_key_env=args.llm_api_key_env,
        llm_api_key=args.llm_api_key,
        embedding_provider=args.embedding_provider,
        embedding_model=args.embedding_model,
        embedding_base_url=args.embedding_base_url,
        embedding_api_key_env=args.embedding_api_key_env,
        embedding_api_key=args.embedding_api_key,
        embedding_batch_size=args.embedding_batch_size,
    )

    if args.cmd == "build":
        stats = build_index(
            cfg,
            quiet=args.quiet,
            progress_interval=args.progress_interval,
            incremental=args.incremental,
            remove_missing=not args.no_remove_missing,
        )
        print(json.dumps(asdict(stats), ensure_ascii=False, indent=2))
        return 0

    if args.cmd == "versions":
        if args.versions_cmd == "remove":
            print(json.dumps(remove_version(cfg, args.version, physical=args.physical), ensure_ascii=False, indent=2))
            return 0
        if args.versions_cmd == "compact":
            print(json.dumps(compact_index(cfg), ensure_ascii=False, indent=2))
            return 0
        searcher = Searcher(cfg)
        try:
            print(json.dumps(searcher.versions(), ensure_ascii=False, indent=2))
        finally:
            searcher.close()
        return 0

    if args.cmd == "doctor":
        doctor(cfg)
        return 0

    if args.cmd == "serve":
        run_http(cfg, host=args.host, port=args.port)
        return 0

    if args.cmd == "mcp":
        run_mcp(cfg)
        return 0

    searcher = Searcher(cfg)
    try:
        if args.cmd == "query":
            print(json.dumps(searcher.search(args.query, top_k=args.top_k, scope=args.scope, ai_mode=args.ai, version=args.version), ensure_ascii=False, indent=2))
        elif args.cmd == "symbol":
            found = searcher.lookup_symbol(args.name, version=args.version)
            if found is None:
                found = {
                    "error": "not_found",
                    "name": args.name,
                    "hint": f'符号索引未收录该名 — 改用全文检索: python cjdocs.py query "{args.name} <意图>" --top-k 8',
                }
            print(json.dumps(found, ensure_ascii=False, indent=2))
        elif args.cmd == "read":
            print(json.dumps(searcher.read_doc(args.ref, mode=args.mode, max_chars=args.max_chars, version=args.version), ensure_ascii=False, indent=2))
        elif args.cmd == "answer":
            print(json.dumps(searcher.answer_question(args.question, top_k=args.top_k, ai_mode=args.ai, synthesize=args.synthesize, version=args.version), ensure_ascii=False, indent=2))
    finally:
        searcher.close()
    return 0


def doctor(cfg) -> None:
    import sqlite3

    con = connect(Path(cfg.index_path))
    init_db(con)
    checks = {"sqlite_version": sqlite3.sqlite_version}
    try:
        con.execute("create virtual table if not exists temp.__cjdocs_tri using fts5(x, tokenize='trigram')")
        checks["fts5_trigram"] = True
    except Exception as exc:
        checks["fts5_trigram"] = f"failed:{type(exc).__name__}"
    try:
        active = con.execute(
            """
            select
              (select count(*) from documents d where exists (select 1 from versions v where v.version = d.version and v.status = 'ready')) documents,
              (select count(*) from sections s where exists (select 1 from versions v where v.version = s.version and v.status = 'ready')) sections,
              (select count(*) from symbols y where exists (select 1 from versions v where v.version = y.version and v.status = 'ready')) symbols,
              (select count(*) from examples e where exists (select 1 from versions v where v.version = e.version and v.status = 'ready')) examples,
              (select count(*) from vectors r where exists (select 1 from versions v where v.version = r.version and v.status = 'ready')) vectors
            """
        ).fetchone()
        physical = con.execute(
            """
            select
              (select count(*) from documents) documents,
              (select count(*) from sections) sections,
              (select count(*) from symbols) symbols,
              (select count(*) from examples) examples,
              (select count(*) from vectors) vectors
            """
        ).fetchone()
        checks["documents"] = active["documents"]
        checks["sections"] = active["sections"]
        checks["symbols"] = active["symbols"]
        checks["examples"] = active["examples"]
        checks["vectors"] = active["vectors"]
        checks["physical_counts"] = {key: physical[key] for key in ("documents", "sections", "symbols", "examples", "vectors")}
        checks["versions"] = [
            dict(row)
            for row in con.execute(
                """
                select version, status, docs_root, documents, sections, symbols, examples, vectors, updated_at
                from versions
                order by updated_at desc, version
                """
            ).fetchall()
        ]
    finally:
        con.close()
    cache_path = Path(cfg.ai_cache_path)
    if cache_path.exists():
        cache_con = connect(cache_path)
        try:
            checks["ai_summary_cache"] = cache_con.execute("select count(*) c from summary_cache").fetchone()["c"]
            checks["ai_vector_cache"] = cache_con.execute("select count(*) c from vector_cache").fetchone()["c"]
        except Exception:
            checks["ai_cache"] = "unavailable"
        finally:
            cache_con.close()
    else:
        checks["ai_summary_cache"] = 0
        checks["ai_vector_cache"] = 0
    print(json.dumps(checks, ensure_ascii=False, indent=2))
