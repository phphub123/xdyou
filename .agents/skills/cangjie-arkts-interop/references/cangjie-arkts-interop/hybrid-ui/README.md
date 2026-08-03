# Hybrid UI

Prefer the top-level references in this skill:

- `references/hybrid-projects.md`
- `references/cjhybridcomponent-ui.md`
- `references/arkts-call-cangjie.md`

Key rules:

- ArkTS owns Ability lifecycle and routing in the packaged hybrid app template.
- Cangjie exports dynamic-library functions or components.
- For `CJHybridComponent`, `library` equals the Cangjie package name from `cjpm.toml`, and `component` equals the Cangjie component class name.
- Register ArkTS wrapper pages in `main_pages.json`.
- Use callbacks or exported bridge functions for cross-language router behavior.
