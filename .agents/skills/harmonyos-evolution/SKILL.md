---
name: harmonyos-evolution
description: "Use this skill to read, match, and write verified Cangjie HarmonyOS development lessons in project Evolution.md or packaged references/memory.md after build, runtime, UI, interop, or retrieval issues are proven and fixed."
---

# Evolution Memory

Verified-lesson store for the skill family: read it before repeating a known mistake, write to it only after evidence passes.

## Scope

- Project-local behavior → project root `Evolution.md`.
- Lessons that generalize across projects → `<harmonyos-evolution-skill>/references/memory.md` (packaged).
- Cangjie syntax/API traps with compiler-error signatures belong to the rules library (`../cangjie-essentials.md`, rendered from `cangjie-rules.json`) — do NOT duplicate them here. This store keeps workflow, toolchain, device, and process lessons.

## Workflow

1. Read project `Evolution.md`, then packaged `references/memory.md`.
2. Compare with current evidence: `build.log`, hilog summary, UI capture or interaction report.
3. Before writing, search both stores for an existing entry on the same symptom; update that entry in place — never append a duplicate.
4. Pick the store by Scope above, write in one of the two formats below.

## Entry Formats

Full block — for lessons with non-trivial diagnosis:

```markdown
## <issue title>

- Date: YYYY-MM-DD
- Status: open | resolved | stale
- Scenario: build | runtime | UI | interop | retrieval
- Symptom:
- Root cause:
- Fix:
- Verification:
- Keywords:
```

Single line — for simple, already-verified facts:

```markdown
- [resolved YYYY-MM-DD] <symptom> → <fix> (keywords: a, b)
```

Status meaning: `open` reproducible/unfixed · `resolved` fix verified by evidence · `stale` historical, not currently reproducible.

## Guardrails

- Verified facts only — no guesses, hypotheses, or one-off observations.
- Every entry needs a date and searchable keywords (error text fragments preferred).
- On conflict between the two stores, the newer dated, evidence-backed entry wins; mark the loser `stale` instead of deleting it silently.
