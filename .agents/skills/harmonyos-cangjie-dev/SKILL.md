---
name: harmonyos-cangjie-dev
description: "Use this skill as the main workflow for Cangjie HarmonyOS app work: new feature development, incremental changes, project creation, build repair, runtime debugging, UI verification, ArkUI/API lookup, ArkTS interop, std/stdx usage, and experience recording."
---

# Cangjie HarmonyOS Development

Workflow hub for the skill family: inspect, route to the narrowest skill, make the smallest change, verify with evidence, record lessons.

## Scope

Portage-managed project (root `CLAUDE.md` contains a 「工程铁律」 section): the platform
owns builds, scaffolding, and build configs — implement the code change, do not run builds
or edit `cjpm.toml`/`module.json5`/`build-profile.json5`, and report instead.
Standalone project: the full workflow below applies.

## Quick Route

| Need | Use |
| --- | --- |
| New or broken pure-Cangjie project | `harmonyos-project-bootstrap` |
| New mixed Cangjie-ArkTS project | `cangjie-arkts-interop` |
| HarmonyOS API, ArkUI, permission, toolchain lookup | `cangjie-harmonyos-knowledge` |
| Cangjie syntax, std, stdx handbook | `cangjie-core-reference` |
| Build, install, launch, capture, hilog triage | `harmonyos-build-run-diagnose` |
| ArkTS ↔ Cangjie boundary work | `cangjie-arkts-interop` |
| Read/write verified lessons | `harmonyos-evolution` |

## Workflow

1. Inspect the request, project structure, `entry/cjpm.toml`, `entry/src/main`, `module.json5`, and existing `Evolution.md`.
2. Read `../cangjie-essentials.md` before writing Cangjie code — survival rules with error signatures and evidence; when a rule conflicts with instinct, the rule wins.
3. Route lookups and subtasks via Quick Route; query unfamiliar APIs before coding.
4. Implement the smallest coherent change.
5. Build after each meaningful change (`harmonyos-build-run-diagnose`; skipped under Portage per Scope).
6. For UI or runtime behavior: install, launch, capture, and assert business keys/text.
7. Record verified reusable lessons (`harmonyos-evolution`) only after evidence passes.

## Guardrails

- Prefer Cangjie ArkUI signatures over ArkTS assumptions.
- Arguments follow the Cangjie declaration: parameters declared with `!` take named form (for example `itemGenerator:`); everything else is positional — doc parameter names are NOT named-argument labels. Always use explicit length units (`.vp`, `.percent`).
- Keep stable ids/keys on interactive components for testing, for example `countDisplay`, `submitButton`.
- No unrelated refactors while fixing build/runtime issues.

## Configuration

Layered config is optional; all layers load and **later layers override earlier ones**:
built-in defaults → `~/.harmonyos-cangjie/config.toml` → `<project>/harmonyos-cangjie.toml` → `<project>/.claude/harmonyos-cangjie.toml` → `<project>/.agents/harmonyos-cangjie.toml` → file pointed to by `HARMONYOS_CANGJIE_CONFIG` → CLI arguments. Without config files, tools use default DevEco/Cangjie/hdc paths and the RAG stays offline-capable. Details: `references/configuration.md`.

## Completion Evidence

Report: changed files; build result and HAP path when applicable; runtime/UI/hilog evidence when applicable; remaining blockers only when backed by logs or tool output.
