# Memory

## Environment Facts

- DevEco Studio is commonly installed under `C:\Program Files\Huawei\DevEco Studio` on Windows.
- `hdc.exe` is commonly under `C:\Program Files\Huawei\DevEco Studio\sdk\default\openharmony\toolchains\hdc.exe`.
- A Cangjie SDK path labelled `6.0` can be treated as compatible with the 6.1 task context for this solution.
- Agents may load project skills from different containers such as `.claude/skills` or `.agents/skills`; skill scripts and docs should not depend on the outer container name.

## Decisions

- Replace old cloud doc-search as the primary path with the packaged local RAG in `cangjie-harmonyos-knowledge/rag/cjdocs.py`.
- Keep language / std / stdx curated docs as local packaged reference material.
- Use `harmonyos-cangjie-dev` as the total workflow entry.
- Treat build, runtime diagnosis, UI verification, and experience writing as one closed loop.

## Observed Issues

- [open] Old remote doc-search can return `HTTP 502: Bad Gateway`; use packaged local RAG as the primary path.
- [resolved] `hdc` may not be on PATH in the default shell; full DevEco toolchains path works.
- [stale] Some projects can fail at `CompileCangjie` with `DataModelException: This data is not DataModelString` in `DepModel::loadDepIncrementalCache`; keep the recovery pattern but do not assume current projects are broken.
- [resolved] Initial install-and-capture can land on the launcher even after HAP install. Treat capture as invalid unless target business key/text is present. Recovery: run `aa start -a <ability> -b <bundle>`, wait, recapture with `--no-launch`, and assert business nodes.
- [resolved] Cangjie ArkUI does not accept ArkTS-style object literals for margins such as `.margin({left: 20})`; use named parameters with units, e.g. `.margin(left: 20.vp)`.
- [resolved] `String.trim()` is not available in the tested Cangjie environment; `trimAscii()` exists for ASCII whitespace trimming, and curated String docs should be checked before assuming JS/ArkTS methods.
- [resolved] `ObservedArrayList` uses `.size`, not `.length`.
- [resolved] `ObservedArrayList` appends items with `.append(value)`, not `.add(value)`.
- [resolved] `ui_capture.py` must resolve the DevEco `hdc.exe` path, fail when no screenshot/layout is collected, and retry launch/capture when the first layout is launcher/system UI rather than the target bundle.
- [resolved] `uitest uiInput inputText` requires coordinates before text: `inputText <x> <y> <text>`. Treat command usage output as a failed interaction even when capture artifacts exist.
- [resolved] After text input, the soft keyboard may hide lower controls from the accessibility tree. Use an explicit Back step, `hide_keyboard: true`, or scroll before asserting lower controls.
- [resolved] Build diagnostics should extract the first stable error block and known Cangjie/HarmonyOS patterns before changing code.
- [resolved] Project bootstrap should use packaged template directories plus placeholder substitution. Keep reusable project structure in `templates/`, and keep scripts focused on validation, copying, and transformation logic.
- [resolved] A project directory containing only agent skill containers such as `.claude/skills` or `.agents/skills` should still count as empty for template-based project creation, because this matches real skill-loading evaluation.
- [resolved] In Cangjie-ArkTS hybrid apps, ArkTS owns the Ability/page shell while Cangjie provides dynamic library exports or embedded components.
- [resolved] ArkTS-to-Cangjie exports must stay synchronized across Cangjie registration, `types/lib<package>/Index.d.ts`, and ArkTS import/call sites.
- [resolved] The hybrid app library chain is `cjpm.toml [package].name` -> `lib<package>.so` -> `entry/oh-package.json5` dependency -> ArkTS import.
- [resolved] When the HarmonyOS module name is not `entry`, `cjpm.toml` must use the matching `COMPILE_CONDITION_<MODULE>` variable, for example `COMPILE_CONDITION_MAIN` for module `main`.
- [resolved] Build tooling should not hardcode `module=entry@default`; read the first module from root `build-profile.json5` or accept an explicit module override.
- [resolved] Use `@cangjie/cjhybridcomponent` only for Cangjie-ArkTS hybrid UI embedding. Do not add that dependency or wrapper-page pattern to pure Cangjie HarmonyOS projects.
- [resolved] For `CJHybridComponent`, `library` must match `cjpm.toml [package].name`, and `component` must match the Cangjie class annotated with `@HybridComponentEntry`.
- [resolved] Runtime UI captures can expose embedded Cangjie UI under ArkTS `__Common__` nodes. Assert stable business text and post-click state, not only structural node names.
- [resolved] `@cangjie/cjhybridcomponent` can emit third-party ArkTS warnings and a `page_show` resource conflict warning. Treat them as non-blocking only when build success and UI assertions both pass.
- [resolved] Hybrid UI skill changes were regression-checked against a pure Cangjie bootstrap project; the pure Cangjie build path remains independent.
- [resolved] Layered configuration should resolve in this order: CLI, environment variables, project config (`harmonyos-cangjie.toml`, `.claude/harmonyos-cangjie.toml`, `.agents/harmonyos-cangjie.toml`), user `~/.harmonyos-cangjie/config.toml`, then built-in defaults.
- [resolved] Keep RAG API keys in environment variables such as `DASHSCOPE_API_KEY`. Config files may name the env var but must not store real keys.
- [resolved] Pure Cangjie and hybrid project creation must both remap the template `entry/` directory and `COMPILE_CONDITION_ENTRY` when `module_name` is not `entry`.
- [resolved] Build diagnostics should not classify a log as successful when an earlier `BUILD SUCCESSFUL` from `SyncCangjieResource` is followed by `BUILD FAILED` during `assembleHap`.
