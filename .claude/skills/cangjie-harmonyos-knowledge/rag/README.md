# cjdocs

> 注：文中出现的 provider/model/base_url 均为示例值 — 实际以平台设置页（RAG 分区）生成的 cjdocs.toml 为准；[llm]/[embedding] 段还支持 timeout/max_retries/batch_size 调优。

Local Cangjie/HarmonyOS documentation retrieval for coding agents.

The packaged `docs/` directory and `.cjdocs/index.sqlite` make offline retrieval work out of the box from any current directory. Paths are resolved relative to this `rag/` directory, not relative to `.claude/skills`, `.agents/skills`, or the project root. AI features are optional. Do not store API keys in this directory or in MCP configuration files.

## Quick Start

```powershell
python cjdocs.py doctor
python cjdocs.py query "TextInput onChange" --top-k 5
python cjdocs.py symbol Button
python cjdocs.py answer "Web component dark mode" --top-k 8
```

Run a local HTTP service only when needed:

```powershell
python cjdocs.py serve --port 8765
```

Run the MCP stdio server:

```powershell
python cjdocs.py mcp
```

## Rebuild Index

```powershell
python cjdocs.py build --ai off
```

Build a named version:

```powershell
python cjdocs.py build --version 6.1.1.345 --ai off
```

Use an explicit docs path only for package maintenance, for example `python cjdocs.py build <docs-root> --ai off`. Use `--incremental` only for updating an existing version from changed source docs.

## Optional AI

Offline search is the default. For live Aliyun embedding or LLM calls, pass keys through environment variables:

```powershell
$env:DASHSCOPE_API_KEY = "<secure value>"
python cjdocs.py --ai-provider aliyun --api-key-env DASHSCOPE_API_KEY query "TextInput onChange" --ai runtime
```

Runtime AI query uses embedding for retrieval. `answer` returns ranked citations by default and uses LLM synthesis only when `--synthesize` is explicitly passed.

Default Aliyun model settings:

- LLM: `deepseek-v4-pro`
- Embedding: `text-embedding-v4`

## Useful Commands

```powershell
python cjdocs.py versions list
python cjdocs.py read "docs/API/arkui-cj/cj-text-input-textinput.md#textinput"
python cjdocs.py query "HUKS generateKeyItem" --version all --top-k 8
python run_tests.py
```

## HTTP API

```text
GET  /admin
GET  /health
GET  /api/versions
GET  /api/jobs
GET  /search?q=...&version=default&scope=api&top_k=8&ai=off|runtime
GET  /symbol/{name}?version=default
GET  /doc?ref=docs/API/...md#anchor&version=default
GET  /examples?q=...&version=default
POST /answer
POST /api/build
POST /api/versions/remove
```
