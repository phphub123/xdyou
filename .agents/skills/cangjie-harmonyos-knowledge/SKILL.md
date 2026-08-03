---
name: cangjie-harmonyos-knowledge
description: "Use this skill to search the packaged local HarmonyOS/Cangjie documentation index (RAG) for ArkUI components, HarmonyOS kit APIs, system capabilities, permissions, cjpm/build error terms, and toolchain facts. Use it whenever implementation or debugging depends on API signatures, component behavior, or Cangjie/ArkTS differences. For curated Cangjie language/std/stdx handbooks prefer cangjie-core-reference; this skill is also the fallback full-text searcher across all packaged docs."
---

# Local Knowledge Retrieval

Offline RAG over the packaged HarmonyOS/Cangjie docs: query before coding whenever an API signature, component behavior, or error term is uncertain.

## Scope

- Fully offline by default (lexical search). `doctor` showing `vectors: 0` is the expected default state, fully functional — never rebuild the index because of it.
- The tool resolves `docs/` and `.cjdocs/` relative to its own `rag` directory; it works from any current directory. Do not assume the skills container is named `.claude/skills` or `.agents/skills` — use the actual installed path.
- Curated Cangjie language/std/stdx handbooks: prefer `cangjie-core-reference`; this skill is the full-text fallback across all packaged docs.

## Quick Route

| Need | Use |
| --- | --- |
| Exact API/component/class name known | `symbol <Name>` — returns the symbol with full member list (no `--top-k`) |
| Natural language, combined terms, error text, uncertain names | `query "<words>"` (`--top-k N`, `--scope api\|guide\|examples`) |
| Full text of a section after getting its `ref` | `read "<ref>"` — the natural follow-up before writing code |
| Aggregated citations for a question | `answer "<question>"` (LLM only with `--synthesize`, off by default) |
| Index health check | `doctor` |
| cjpm/build/toolchain workflow (not just terms) | `harmonyos-build-run-diagnose` |
| ArkTS ↔ Cangjie boundary work | `cangjie-arkts-interop` |

## Workflow

1. In a coding task, read `../cangjie-essentials.md` once before your first query — it answers the highest-frequency traps (JSON/stdx choice, threading, argument passing) faster than searching.
2. Run `doctor` before the first query in a new project. If `documents` is 0, verify the package includes `rag/.cjdocs/index.sqlite` before concluding docs are missing.
3. Query with concrete API names, component names, error classes, SysCap names, task names, or config fields; combine English symbols with short intent words (`Button onClick tap event`).
4. Read `ref`, `breadcrumb`, and `snippet` from results — not titles alone; follow up with `read "<ref>"` for the full section.
5. If nothing matches, rewrite the query once; still nothing → the topic may live in `cangjie-core-reference` (Cangjie language/std/stdx manuals are NOT in this index). Do not fall back to remote doc search.
6. If the index is unavailable, read raw docs under `rag/docs/API` or `rag/docs/Guide` and state that fallback.

## Commands

```powershell
cd <cangjie-harmonyos-knowledge-skill>/rag
python cjdocs.py doctor
python cjdocs.py query "Button onClick TextInput @State" --top-k 8
python cjdocs.py query "HUKS generateKeyItem" --version all --top-k 8
python cjdocs.py symbol Button
python cjdocs.py read "docs/API/arkui-cj/cj-button-picker-button.md#func-stateeffect-bool"
python cjdocs.py answer "Web component dark mode" --top-k 8
python cjdocs.py serve --port 8765   # long-lived HTTP, only when a task needs it
python cjdocs.py mcp                 # MCP mode, same condition
```

## Symptom Checks (Cangjie vs ArkTS habits)

| Symptom | Prefer |
| --- | --- |
| `.margin({left: 20})` or `expected type name after ':'` | Named parameters with units: `.margin(left: 20.vp)` |
| Raw number passed to size/spacing APIs | Explicit units such as `.vp` or `.percent` |
| `String.trim()` missing | Cangjie String docs; `trimAscii()` for ASCII whitespace |
| `ObservedArrayList.length` / `.add(...)` missing | Use `.size` / `.append(...)` |
| Object-literal style copied from ArkTS | Query the Cangjie ArkUI signature; use options classes or named parameters |
| JSON parsing needed, or `package 'ohos.encoding.json' is 'protected'` | `import stdx.encoding.json.*` (`JsonValue.fromStr`); manual: `cangjie-core-reference` stdx json README |
| URL encoding / query-string building | `import stdx.encoding.url.*`; manual: `cangjie-core-reference` stdx encoding README §4 |
| UI not updating from async callback, or crash writing state off-thread | Update `@State` on the main thread (`kit.ArkUI` `launch {}`); rule in `../cangjie-essentials.md` |

## Guardrails

- Live AI (Aliyun embedding/LLM) only via environment variables or layered config (`api_key_env`); never write API keys to repository files, logs, MCP config, prompts, or reports.
- When explaining a fix, cite the retrieval `ref`, for example `docs/API/arkui-cj/cj-button-picker-button.md#func-stateeffect-bool`.
