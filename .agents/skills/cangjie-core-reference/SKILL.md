---
name: cangjie-core-reference
description: "Use this skill for Cangjie language, syntax, type-system, macro, package-management, std, and stdx reference lookup during implementation or debugging. Use it when code fails because of Cangjie language semantics, missing std APIs, collection/String behavior, concurrency, regex, IO, networking, JSON, HTTP, TLS, crypto, or stdx configuration."
---

# Cangjie Core Reference

Curated Cangjie handbooks: language features, std, and stdx — the routed deep-read companion to the searchable RAG.

## Quick Route

| Need | Read |
| --- | --- |
| Syntax, type system, functions, classes, generics, macros, packages, cjpm | `references/cangjie-lang-features/REFERENCE.md` |
| String, collection, time, fs, io, net, process, regex, sync, random, unittest | `references/cangjie-std/REFERENCE.md` |
| json, encoding, log, compress, HTTP client/server, websocket, TLS, crypto | `references/cangjie-stdx/REFERENCE.md` |

## Workflow

1. Open the routed `REFERENCE.md` first, then the specific README it points to.
2. Prefer documented Cangjie APIs over JS/ArkTS habits.
3. For HarmonyOS component signatures, combine with `cangjie-harmonyos-knowledge`.
4. After changing code or dependency config, build with `harmonyos-build-run-diagnose` (under Portage management the platform builds instead — see that skill's Scope).
