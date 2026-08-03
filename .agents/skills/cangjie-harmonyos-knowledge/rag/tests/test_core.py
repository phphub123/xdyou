from __future__ import annotations

import json
import os
import tempfile
import unittest
from http.server import BaseHTTPRequestHandler, ThreadingHTTPServer
from pathlib import Path
from threading import Thread
from unittest import mock

from cjdocs.admin import ADMIN_HTML
from cjdocs.ai import AIEnhancer, EmbeddingClient, LLMClient, parse_json_object
from cjdocs.config import AppConfig, DEFAULT_DOCS_ROOT, DEFAULT_INDEX_DIR, load_config
from cjdocs.http_server import sanitize_payload
import cjdocs.indexer as indexer
from cjdocs.indexer import build_index, compact_index, format_console_event, remove_version
from cjdocs.search import Searcher


SAMPLE_API = """# ohos.data.relational_store（关系型数据库）

## func getRdbStore(UIAbilityContext, StoreConfig)

```cangjie
public func getRdbStore(context: UIAbilityContext, config: StoreConfig): RdbStore
```

**功能：** 创建或打开已有的关系型数据库。

**异常：**

| 错误码ID | 错误信息 |
| :---- | :--- |
| 14800011 | Failed to open the database because it is corrupted. |

**示例：**

```cangjie
import kit.ArkData.*
let store = getRdbStore(context, StoreConfig(RelationalStoreSecurityLevel.S1, name: "RdbTest.db"))
```

## class RdbPredicates

```cangjie
public class RdbPredicates {
    public init(name: String)
}
```

**功能：** 表示关系型数据库的谓词。

### func equalTo(String, RelationalStoreValueType)

```cangjie
public func equalTo(field: String, value: RelationalStoreValueType): RdbPredicates
```
"""


SAMPLE_GUIDE = """# 通过关系型数据库实现数据持久化

## 场景介绍

关系型数据库适用于存储包含复杂关系数据的场景，此时需要使用关系型数据库来持久化保存数据。

## 开发步骤

调用 getRdbStore 获取 RdbStore，然后执行增删改查。
"""


class CoreTests(unittest.TestCase):
    def make_index(self):
        tmp = tempfile.TemporaryDirectory()
        root = Path(tmp.name)
        api_dir = root / "docs" / "API" / "ArkData"
        guide_dir = root / "docs" / "Guide" / "database"
        api_dir.mkdir(parents=True)
        guide_dir.mkdir(parents=True)
        (api_dir / "cj-apis-relational_store.md").write_text(SAMPLE_API, encoding="utf-8")
        (guide_dir / "cj-data-persistence-by-rdb-store.md").write_text(SAMPLE_GUIDE, encoding="utf-8")
        cfg = AppConfig(docs_root=str(root / "docs"), index_dir=str(root / ".cjdocs"))
        stats = build_index(cfg, quiet=True)
        return tmp, cfg, stats

    def test_build_and_search_without_ai(self):
        tmp, cfg, stats = self.make_index()
        self.addCleanup(tmp.cleanup)
        self.assertEqual(stats.documents, 2)
        self.assertGreaterEqual(stats.symbols, 3)
        searcher = Searcher(cfg)
        self.addCleanup(searcher.close)

        results = searcher.search("getRdbStore", top_k=3)
        self.assertTrue(results)
        self.assertEqual(results[0]["title"], "func getRdbStore(UIAbilityContext, StoreConfig)")
        self.assertIn("docs/API/ArkData", results[0]["path"])

        symbol = searcher.lookup_symbol("RdbPredicates")
        self.assertIsNotNone(symbol)
        self.assertTrue(any(member["name"] == "equalTo" for member in symbol["members"]))

        guide = searcher.search("关系型数据库 持久化", scope="guide", top_k=1)
        self.assertTrue(guide)
        self.assertIn("cj-data-persistence", guide[0]["path"])

        natural = searcher.search("如何创建或打开关系型数据库", top_k=3)
        self.assertTrue(natural)
        self.assertTrue(any("关系型数据库" in item["breadcrumb"] or "关系型数据库" in item["snippet"] for item in natural))
        self.assertTrue(any(item["doc_type"] in {"api", "guide"} for item in natural))

        semantic = searcher.search("仓颉里怎么保存本地结构化数据", top_k=3)
        self.assertTrue(semantic)
        self.assertTrue(any("持久化" in item["breadcrumb"] or "持久化" in item["snippet"] for item in semantic))

        err = searcher.search("14800011", top_k=1)
        self.assertTrue(err)
        self.assertIn("14800011", err[0]["snippet"])

    def test_default_config_uses_packaged_rag_paths(self):
        old_cwd = Path.cwd()
        with tempfile.TemporaryDirectory() as d:
            os.chdir(d)
            try:
                cfg = load_config()
            finally:
                os.chdir(old_cwd)
        self.assertEqual(Path(cfg.docs_root), DEFAULT_DOCS_ROOT)
        self.assertEqual(Path(cfg.index_dir), DEFAULT_INDEX_DIR)

    def test_unified_rag_config_does_not_override_packaged_paths(self):
        with tempfile.TemporaryDirectory() as d:
            root = Path(d)
            project = root / "project"
            project.mkdir()
            (project / ".claude").mkdir()
            (project / ".claude" / "harmonyos-cangjie.toml").write_text(
                '[rag]\nversion = "6.1.1.345"\ndocs_root = "wrong-docs"\nindex_dir = "wrong-index"\n',
                encoding="utf-8",
            )
            old_cwd = Path.cwd()
            os.chdir(project)
            try:
                cfg = load_config()
            finally:
                os.chdir(old_cwd)
        self.assertEqual(cfg.docs_version, "6.1.1.345")
        self.assertEqual(Path(cfg.docs_root), DEFAULT_DOCS_ROOT)
        self.assertEqual(Path(cfg.index_dir), DEFAULT_INDEX_DIR)

    def test_local_cjdocs_toml_only_overrides_version(self):
        with tempfile.TemporaryDirectory() as d:
            path = Path(d) / "cjdocs.toml"
            path.write_text(
                '[docs]\nversion = "7.0.0"\ndocs_root = "wrong-docs"\nindex_dir = "wrong-index"\n',
                encoding="utf-8",
            )
            cfg = load_config(path)
        self.assertEqual(cfg.docs_version, "7.0.0")
        self.assertEqual(Path(cfg.docs_root), DEFAULT_DOCS_ROOT)
        self.assertEqual(Path(cfg.index_dir), DEFAULT_INDEX_DIR)

    def test_ai_runtime_degrades_without_key(self):
        tmp, cfg, _ = self.make_index()
        self.addCleanup(tmp.cleanup)
        cfg.ai_enabled = True
        cfg.ai_runtime = True
        cfg.llm.api_key = None
        cfg.embedding.api_key = None
        searcher = Searcher(cfg)
        self.addCleanup(searcher.close)
        results = searcher.search("getRdbStore", ai_mode="runtime", top_k=1)
        self.assertEqual(results[0]["title"], "func getRdbStore(UIAbilityContext, StoreConfig)")
        answer = searcher.answer_question("怎么打开关系型数据库？", ai_mode="runtime")
        self.assertFalse(answer["degraded"])
        self.assertFalse(answer["llm_used"])
        self.assertTrue(answer["citations"])

    def test_runtime_search_does_not_call_llm_rewrite(self):
        tmp, cfg, _ = self.make_index()
        self.addCleanup(tmp.cleanup)
        cfg.ai_enabled = True
        cfg.ai_runtime = True
        cfg.llm.api_key = "test-key"
        cfg.embedding.api_key = None
        searcher = Searcher(cfg)
        self.addCleanup(searcher.close)
        with mock.patch.object(AIEnhancer, "rewrite_query", side_effect=AssertionError("LLM rewrite must not run at query time")):
            results = searcher.search("getRdbStore", ai_mode="runtime", top_k=1)
        self.assertEqual(results[0]["title"], "func getRdbStore(UIAbilityContext, StoreConfig)")

    def test_runtime_answer_synthesis_requires_explicit_flag(self):
        tmp, cfg, _ = self.make_index()
        self.addCleanup(tmp.cleanup)
        cfg.ai_enabled = True
        cfg.ai_runtime = True
        cfg.llm.api_key = "test-key"
        cfg.embedding.api_key = None
        searcher = Searcher(cfg)
        self.addCleanup(searcher.close)
        with mock.patch.object(AIEnhancer, "answer", side_effect=AssertionError("LLM answer must be explicitly enabled")):
            answer = searcher.answer_question("如何创建或打开关系型数据库？", ai_mode="runtime", top_k=3)
        self.assertFalse(answer["llm_used"])
        self.assertFalse(answer["synthesized"])
        self.assertTrue(answer["citations"])


class EmbeddingClientTests(unittest.TestCase):
    def test_dashscope_embedding_response(self):
        class Handler(BaseHTTPRequestHandler):
            def do_POST(self):  # noqa: N802
                _ = self.rfile.read(int(self.headers.get("Content-Length", "0")))
                body = json.dumps({"output": {"embeddings": [{"text_index": 0, "embedding": [0.1, 0.2]}]}}).encode()
                self.send_response(200)
                self.send_header("Content-Type", "application/json")
                self.send_header("Content-Length", str(len(body)))
                self.end_headers()
                self.wfile.write(body)

            def log_message(self, *args):
                return

        server = ThreadingHTTPServer(("127.0.0.1", 0), Handler)
        thread = Thread(target=server.serve_forever, daemon=True)
        thread.start()
        self.addCleanup(server.shutdown)

        cfg = AppConfig()
        cfg.embedding.api_key = "test-key"
        cfg.embedding.base_url = f"http://127.0.0.1:{server.server_address[1]}"
        client = EmbeddingClient(cfg)
        self.assertEqual(client.embed_texts(["hello"]), [[0.1, 0.2]])


class AIUtilityTests(unittest.TestCase):
    def test_parse_json_object_accepts_fenced_json(self):
        self.assertEqual(parse_json_object("```json\n{\"queries\":[\"a\"]}\n```"), {"queries": ["a"]})
        self.assertEqual(parse_json_object("prefix {\"summary\":\"ok\"} suffix"), {"summary": "ok"})
        self.assertEqual(parse_json_object("not json"), {})

    def test_admin_html_contains_core_controls(self):
        self.assertIn("cjdocs 管理面板", ADMIN_HTML)
        self.assertIn("id=\"start-build\"", ADMIN_HTML)
        self.assertIn("id=\"physical_remove\"", ADMIN_HTML)
        self.assertIn("id=\"compact-index\"", ADMIN_HTML)
        self.assertIn("id=\"versions\"", ADMIN_HTML)
        self.assertIn("id=\"query_out\"", ADMIN_HTML)
        self.assertIn("/api/build", ADMIN_HTML)
        self.assertIn("/api/versions/remove", ADMIN_HTML)
        self.assertIn("/api/compact", ADMIN_HTML)

    def test_http_payload_sanitizes_api_key(self):
        payload = sanitize_payload({"api_key": "secret", "version": "6.1"})
        self.assertEqual(payload["api_key"], "***")
        self.assertEqual(payload["version"], "6.1")

    def test_console_event_format_is_readable(self):
        plain = format_console_event("embed", "vectors=10", 65, use_color=False)
        self.assertIn("1m05s", plain)
        self.assertIn("EMBED", plain)
        self.assertIn("vectors=10", plain)
        self.assertNotIn("\x1b[", plain)
        colored = format_console_event("done", "ok", 1, use_color=True)
        self.assertIn("\x1b[", colored)


class AtomicAndCacheTests(unittest.TestCase):
    def make_single_doc_config(self):
        tmp = tempfile.TemporaryDirectory()
        root = Path(tmp.name)
        api_dir = root / "docs" / "API" / "ArkData"
        api_dir.mkdir(parents=True)
        (api_dir / "cj-apis-relational_store.md").write_text(SAMPLE_API, encoding="utf-8")
        cfg = AppConfig(docs_root=str(root / "docs"), index_dir=str(root / ".cjdocs"))
        return tmp, cfg

    def test_failed_rebuild_preserves_previous_main_index(self):
        tmp, cfg = self.make_single_doc_config()
        self.addCleanup(tmp.cleanup)
        first = build_index(cfg, quiet=True)
        self.assertEqual(first.documents, 1)

        def boom(*args, **kwargs):
            raise RuntimeError("simulated build interruption")

        with mock.patch.object(indexer, "insert_document", side_effect=boom):
            with self.assertRaises(RuntimeError):
                build_index(cfg, quiet=True)

        searcher = Searcher(cfg)
        self.addCleanup(searcher.close)
        results = searcher.search("getRdbStore", top_k=1)
        self.assertTrue(results)
        self.assertEqual(results[0]["title"], "func getRdbStore(UIAbilityContext, StoreConfig)")

    def test_ai_cache_reuses_summary_and_vectors(self):
        calls = {"llm": 0, "embedding": 0}

        class Handler(BaseHTTPRequestHandler):
            def do_POST(self):  # noqa: N802
                _ = self.rfile.read(int(self.headers.get("Content-Length", "0")))
                if self.path.endswith("/chat/completions"):
                    calls["llm"] += 1
                    content = json.dumps(
                        {
                            "summary": "create or open relational database",
                            "keywords": ["getRdbStore", "RdbStore"],
                            "aliases": ["open database"],
                            "search_boost_text": "getRdbStore RdbStore relational database",
                            "structured": {"signature": "getRdbStore"},
                        }
                    )
                    body = json.dumps({"choices": [{"message": {"content": content}}]}).encode()
                else:
                    calls["embedding"] += 1
                    body = json.dumps(
                        {
                            "output": {
                                "embeddings": [
                                    {"text_index": 0, "embedding": [1.0, 0.0]},
                                    {"text_index": 1, "embedding": [0.0, 1.0]},
                                    {"text_index": 2, "embedding": [0.5, 0.5]},
                                    {"text_index": 3, "embedding": [0.2, 0.8]},
                                ]
                            }
                        }
                    ).encode()
                self.send_response(200)
                self.send_header("Content-Type", "application/json")
                self.send_header("Content-Length", str(len(body)))
                self.end_headers()
                self.wfile.write(body)

            def log_message(self, *args):
                return

        server = ThreadingHTTPServer(("127.0.0.1", 0), Handler)
        thread = Thread(target=server.serve_forever, daemon=True)
        thread.start()
        self.addCleanup(server.shutdown)

        tmp, cfg = self.make_single_doc_config()
        self.addCleanup(tmp.cleanup)
        cfg.ai_enabled = True
        cfg.ai_preprocess = True
        cfg.llm.api_key = "test-key"
        cfg.llm.base_url = f"http://127.0.0.1:{server.server_address[1]}"
        cfg.embedding.api_key = "test-key"
        cfg.embedding.base_url = f"http://127.0.0.1:{server.server_address[1]}/embedding"
        cfg.embedding.batch_size = 10

        first = build_index(cfg, quiet=True)
        first_calls = dict(calls)
        self.assertGreater(first.ai_summaries, 0)
        self.assertGreater(first.vectors, 0)
        self.assertGreater(first_calls["llm"], 0)
        self.assertGreater(first_calls["embedding"], 0)

        second = build_index(cfg, quiet=True)
        self.assertEqual(calls, first_calls)
        self.assertGreater(second.ai_summary_cache_hits, 0)
        self.assertGreater(second.vector_cache_hits, 0)


class VersioningTests(unittest.TestCase):
    def write_doc(self, root: Path, name: str, symbol: str, desc: str) -> Path:
        api_dir = root / "docs" / "API" / "Kit"
        api_dir.mkdir(parents=True, exist_ok=True)
        path = api_dir / name
        path.write_text(
            f"""# Kit API

## func {symbol}()

```cangjie
public func {symbol}(): Unit
```

**Function:** {desc}
""",
            encoding="utf-8",
        )
        return path

    def test_multiple_versions_share_one_index(self):
        with tempfile.TemporaryDirectory() as d:
            root = Path(d)
            cfg = AppConfig(docs_root=str(root / "docs"), index_dir=str(root / ".cjdocs"), docs_version="6.0.2.636")

            self.write_doc(root, "same-path.md", "oldFunc", "available only in 6.0")
            first = build_index(cfg, quiet=True)
            self.assertEqual(first.documents, 1)

            self.write_doc(root, "same-path.md", "newFunc", "available only in 6.1")
            cfg.docs_version = "6.1.1.345"
            second = build_index(cfg, quiet=True)
            self.assertEqual(second.documents, 1)

            searcher = Searcher(cfg)
            try:
                versions = {item["version"] for item in searcher.versions()}
                self.assertEqual(versions, {"6.0.2.636", "6.1.1.345"})

                self.assertEqual(searcher.search("newFunc", top_k=1)[0]["version"], "6.1.1.345")
                self.assertFalse(searcher.search("oldFunc", top_k=1))
                self.assertEqual(searcher.search("oldFunc", version="6.0.2.636", top_k=1)[0]["version"], "6.0.2.636")
                self.assertEqual(searcher.search("oldFunc", version="all", top_k=1)[0]["version"], "6.0.2.636")
            finally:
                searcher.close()

    def test_incremental_build_updates_and_removes_missing_docs(self):
        with tempfile.TemporaryDirectory() as d:
            root = Path(d)
            cfg = AppConfig(docs_root=str(root / "docs"), index_dir=str(root / ".cjdocs"), docs_version="7.0.0")

            alpha = self.write_doc(root, "alpha.md", "alphaFunc", "first version")
            beta = self.write_doc(root, "beta.md", "betaFunc", "removed later")
            build_index(cfg, quiet=True)

            alpha.write_text(
                """# Kit API

## func alphaRenamed()

```cangjie
public func alphaRenamed(): Unit
```

**Function:** updated incrementally
""",
                encoding="utf-8",
            )
            beta.unlink()
            stats = build_index(cfg, quiet=True, incremental=True)
            self.assertEqual(stats.documents, 1)
            self.assertEqual(stats.documents_removed, 1)
            self.assertEqual(stats.documents_updated, 1)

            searcher = Searcher(cfg)
            try:
                self.assertTrue(searcher.search("alphaRenamed", top_k=1))
                self.assertFalse(searcher.search("alphaFunc", top_k=1))
                self.assertFalse(searcher.search("betaFunc", top_k=1))
            finally:
                searcher.close()

    def test_incremental_build_can_keep_missing_docs(self):
        with tempfile.TemporaryDirectory() as d:
            root = Path(d)
            cfg = AppConfig(docs_root=str(root / "docs"), index_dir=str(root / ".cjdocs"), docs_version="7.1.0")
            beta = self.write_doc(root, "beta.md", "betaFunc", "kept when missing")
            build_index(cfg, quiet=True)
            beta.unlink()

            stats = build_index(cfg, quiet=True, incremental=True, remove_missing=False)
            self.assertEqual(stats.documents_skipped, 0)
            self.assertEqual(stats.documents_removed, 0)

            searcher = Searcher(cfg)
            try:
                self.assertTrue(searcher.search("betaFunc", top_k=1))
            finally:
                searcher.close()

    def test_remove_version_removes_only_that_version(self):
        with tempfile.TemporaryDirectory() as d:
            root = Path(d)
            cfg = AppConfig(docs_root=str(root / "docs"), index_dir=str(root / ".cjdocs"), docs_version="8.0.0")
            self.write_doc(root, "api.md", "oldOnly", "old")
            build_index(cfg, quiet=True)
            self.write_doc(root, "api.md", "newOnly", "new")
            cfg.docs_version = "8.1.0"
            build_index(cfg, quiet=True)

            removed = remove_version(cfg, "8.0.0")
            self.assertEqual(removed["mode"], "logical")
            self.assertIn("tombstone_version", removed)
            self.assertEqual(removed["documents"], 1)

            searcher = Searcher(cfg)
            try:
                self.assertFalse(searcher.search("oldOnly", version="all", top_k=1))
                self.assertTrue(searcher.search("newOnly", version="8.1.0", top_k=1))
                self.assertEqual({item["version"] for item in searcher.versions()}, {"8.1.0"})
            finally:
                searcher.close()

            compacted = compact_index(cfg)
            self.assertEqual(compacted["before_active"]["documents"], 1)
            self.assertGreater(compacted["before_physical"]["documents"], compacted["before_active"]["documents"])
            self.assertEqual(compacted["after_physical"]["documents"], 1)
            searcher = Searcher(cfg)
            try:
                self.assertFalse(searcher.search("oldOnly", version="all", top_k=1))
                self.assertTrue(searcher.search("newOnly", version="8.1.0", top_k=1))
            finally:
                searcher.close()

    def test_build_progress_callback_receives_events(self):
        with tempfile.TemporaryDirectory() as d:
            root = Path(d)
            cfg = AppConfig(docs_root=str(root / "docs"), index_dir=str(root / ".cjdocs"), docs_version="9.0.0")
            self.write_doc(root, "api.md", "progressFunc", "progress")
            events = []
            build_index(cfg, quiet=True, progress_callback=events.append)
            stages = [event["stage"] for event in events]
            self.assertIn("start", stages)
            self.assertIn("done", stages)
            self.assertTrue(all("elapsed_text" in event for event in events))


@unittest.skipUnless(os.getenv("CJDOCS_RUN_LIVE_AI") == "1" and os.getenv("DASHSCOPE_API_KEY"), "live AI test disabled")
class LiveAliyunAITests(unittest.TestCase):
    @classmethod
    def setUpClass(cls):
        cls.api_key = os.environ["DASHSCOPE_API_KEY"]

    def live_cfg(self, tmp_root: Path | None = None) -> AppConfig:
        cfg = AppConfig(ai_enabled=True, ai_preprocess=True, ai_runtime=True)
        cfg.llm.api_key = self.api_key
        cfg.embedding.api_key = self.api_key
        cfg.embedding.batch_size = 3
        if tmp_root:
            cfg.docs_root = str(tmp_root / "docs")
            cfg.index_dir = str(tmp_root / ".cjdocs")
        return cfg

    def test_live_llm_chat(self):
        cfg = self.live_cfg()
        llm = LLMClient(cfg)
        text = llm.chat(
            [
                {"role": "system", "content": "你是严格的测试机器人。"},
                {"role": "user", "content": "请只输出 OK 两个字母，不要输出其它内容。"},
            ],
            temperature=0,
        )
        self.assertTrue(text.strip())

    def test_live_embedding_batch(self):
        cfg = self.live_cfg()
        client = EmbeddingClient(cfg)
        vectors = client.embed_texts(["getRdbStore 关系型数据库", "RdbPredicates 谓词"])
        self.assertEqual(len(vectors), 2)
        self.assertEqual(len(vectors[0]), 1024)
        self.assertEqual(len(vectors[1]), 1024)
        for vector in vectors:
            norm = sum(float(x) * float(x) for x in vector) ** 0.5
            self.assertGreater(norm, 0.9)
            self.assertLess(norm, 1.1)

    def test_live_preprocess_vector_runtime_answer(self):
        with tempfile.TemporaryDirectory() as d:
            root = Path(d)
            api_dir = root / "docs" / "API" / "ArkData"
            guide_dir = root / "docs" / "Guide" / "database"
            api_dir.mkdir(parents=True)
            guide_dir.mkdir(parents=True)
            (api_dir / "cj-apis-relational_store.md").write_text(SAMPLE_API, encoding="utf-8")
            (guide_dir / "cj-data-persistence-by-rdb-store.md").write_text(SAMPLE_GUIDE, encoding="utf-8")
            cfg = self.live_cfg(root)
            stats = build_index(cfg, quiet=True)
            self.assertEqual(stats.documents, 2)
            self.assertGreaterEqual(stats.vectors, stats.sections)
            self.assertEqual(stats.ai_failures, 0)

            searcher = Searcher(cfg)
            try:
                status = searcher.status()
                self.assertEqual(status["mode"], "embedding-runtime")
                self.assertGreaterEqual(status["vectors"], stats.sections)

                semantic = searcher.search("仓颉里怎么保存本地结构化数据", ai_mode="runtime", top_k=3)
                self.assertTrue(semantic)
                self.assertTrue(any("关系型数据库" in item["breadcrumb"] or "持久化" in item["breadcrumb"] for item in semantic))

                answer = searcher.answer_question("如何创建或打开关系型数据库？", ai_mode="runtime", top_k=3)
                self.assertFalse(answer["degraded"])
                self.assertFalse(answer["llm_used"])
                self.assertTrue(answer["answer"].strip())
                self.assertGreaterEqual(len(answer["citations"]), 1)
            finally:
                searcher.close()

    def test_live_bad_key_degrades_cleanly(self):
        with tempfile.TemporaryDirectory() as d:
            root = Path(d)
            api_dir = root / "docs" / "API" / "ArkData"
            api_dir.mkdir(parents=True)
            (api_dir / "cj-apis-relational_store.md").write_text(SAMPLE_API, encoding="utf-8")
            cfg = self.live_cfg(root)
            cfg.llm.api_key = "bad-key"
            cfg.embedding.api_key = "bad-key"
            stats = build_index(cfg, quiet=True)
            self.assertEqual(stats.documents, 1)
            self.assertGreater(stats.ai_failures, 0)
            self.assertEqual(stats.vectors, 0)

            cfg.ai_preprocess = False
            searcher = Searcher(cfg)
            try:
                results = searcher.search("getRdbStore", ai_mode="runtime", top_k=1)
                self.assertEqual(results[0]["title"], "func getRdbStore(UIAbilityContext, StoreConfig)")
            finally:
                searcher.close()


if __name__ == "__main__":
    unittest.main()
