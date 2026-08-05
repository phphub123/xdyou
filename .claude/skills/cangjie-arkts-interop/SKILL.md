---
name: cangjie-arkts-interop
description: "Use this skill for Cangjie and ArkTS interoperation in HarmonyOS projects: creating Cangjie-ArkTS hybrid app templates, ArkTS importing Cangjie .so functions, JSModule.registerModule exports, @Interop macro exports, Cangjie calling ArkTS APIs through JSRuntime, CJHybridComponent UI embedding, mixed build/config diagnosis, .d.ts synchronization, and runtime validation of cross-language UI behavior."
---

# Cangjie ArkTS Interop

Everything for mixed Cangjie-ArkTS apps: hybrid project creation, both call directions, UI embedding, and boundary validation.

## Scope

- Hybrid projects only — never apply these scripts to a pure Cangjie project created by `harmonyos-project-bootstrap`; use this skill when ArkTS files, `module.json5` pages, and Cangjie dynamic-library wiring are present or intentionally being created.
- Portage-managed project (root `CLAUDE.md` contains a 「工程铁律」 section): the platform owns builds and build configs — implement the code change, do not run builds or edit `cjpm.toml`/`module.json5`, and report instead. Standalone project: the full workflow below applies.

## Quick Route

| Scenario | Read or Run |
| --- | --- |
| Create a mixed Cangjie-ArkTS app from an empty directory | `tools/create_hybrid_project.py` |
| Add a Cangjie UI component with an ArkTS wrapper page | `tools/add_hybrid_component.py` |
| Validate mixed project wiring | `tools/hybrid_project_check.py` |
| ArkTS imports Cangjie functions from `lib*.so` | `references/arkts-call-cangjie.md` |
| Cangjie calls ArkTS/system APIs | `references/cangjie-call-arkts.md`; generated-wrapper flow: `references/cangjie-arkts-interop/cangjie-invoke-arkts/README.md` |
| Type mapping and `.d.ts` synchronization | `references/type-mapping.md` |
| Mixed app structure, build files, runtime validation | `references/hybrid-projects.md` |
| Cangjie component embedded in an ArkTS page | `references/cjhybridcomponent-ui.md` |
| `@Interop` macro constraints; `JSRuntime` singleton/threading/`thisArg` | `references/cangjie-arkts-interop/interop-macro/README.md`; `references/cangjie-arkts-interop/interop-lib/README.md` |
| Legacy deep-dive index (incl. generated bridge workflow) | `references/cangjie-arkts-interop/REFERENCE.md` |

## Workflow

1. Identify the boundary direction: ArkTS→Cangjie, Cangjie→ArkTS, or UI embedding.
2. Keep the package/library chain aligned: `cjpm.toml [package].name` → `lib<package>.so` → `entry/oh-package.json5` dependency → ArkTS import.
3. When exporting Cangjie APIs to ArkTS, update the Cangjie export code and `src/main/cangjie/types/lib<package>/Index.d.ts` together.
4. Keep ArkTS Ability and page routing in ArkTS for the hybrid template; Cangjie provides the dynamic library and exported functions/components.
5. Build after every boundary change, then run `hybrid_project_check.py`.
6. For user-visible behavior: install/launch/capture with `harmonyos-build-run-diagnose` and assert the UI text/key produced after the cross-language call.
7. For UI component mixing, assert both that the Cangjie component appears under the ArkTS page and that Cangjie-side click/state behavior works.

## Commands

```powershell
# create hybrid project, validate, build
python <cangjie-arkts-interop-skill>/tools/create_hybrid_project.py --target-dir . --app-name "Hybrid App" --bundle-name "com.example.hybrid"
python <cangjie-arkts-interop-skill>/tools/hybrid_project_check.py
python <harmonyos-build-run-diagnose-skill>/tools/build_recovery.py --retry

# add a Cangjie UI component with ArkTS wrapper page
python <cangjie-arkts-interop-skill>/tools/add_hybrid_component.py --component MetricsPanel --page metrics --title "Cangjie Metrics"
```

`add_hybrid_component.py` creates `entry/src/main/cangjie/<component>.cj`, `entry/src/main/ets/pages/<page>.ets`, the `@cangjie/cjhybridcomponent` dependency when missing, and the `pages/<page>` registration in `main_pages.json`. Use `--repair` on either tool only when overwriting template-owned files is intended.

## Guardrails

- Prefer simple value boundaries (`string`, `number`, `boolean`) or DTO/JSON for complex data.
- Keep generated/type declaration files single-source and synchronized with actual Cangjie exports.
- A successful Cangjie compile is not sufficient; ArkTS import/type errors may appear later in `CompileArkTS`.
- Use `JSRuntime` only with explicit lifetime and thread decisions.
- Treat the unsigned-HAP warning as non-blocking for local validation unless a signed release is requested.
