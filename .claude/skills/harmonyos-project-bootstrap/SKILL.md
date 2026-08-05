---
name: harmonyos-project-bootstrap
description: "Use this skill to create or repair a Cangjie HarmonyOS project from an empty directory, including template-based project creation, bundleName/package/module wiring, resources, Cangjie Ability entry files, and first build validation."
---

# Project Bootstrap

Creates or repairs a pure-Cangjie HarmonyOS project from the packaged template.

## Scope

- Pure Cangjie projects in an empty or standalone directory.
- Mixed Cangjie-ArkTS app → use `cangjie-arkts-interop` (`create_hybrid_project.py`) instead.
- Portage-managed project (root `CLAUDE.md` contains a 「工程铁律」 section): the platform owns scaffolding — never bootstrap inside one.

## Workflow

1. Determine app name, bundle name, target directory, Cangjie package name, and module name.
2. Create or repair the project (see Commands); use `--repair` only when overwriting template-owned files in a partially generated project is intended.
3. Implement requested features in `entry/src/main/cangjie/index.cj` and related Cangjie files.
4. Build with `harmonyos-build-run-diagnose`.
5. If a device or emulator is available, install, launch, capture UI, and verify interactions with `harmonyos-build-run-diagnose`.

## Commands

```powershell
python <harmonyos-project-bootstrap-skill>/tools/create_project.py --target-dir . --app-name "<app name>" --bundle-name "<bundle name>"
```

## Guardrails

- Use reverse-domain `bundleName`, for example `com.example.todo`.
- Keep `entry/cjpm.toml` `src-dir` as `./src/main/cangjie`.
- Keep `module.json5` `mainElement` aligned with `EntryAbility` and `srcEntry` aligned with the Cangjie package.
- Include `x86_64` and `arm64-v8a` ABI filters for emulator and device coverage.
- Add `stdx` dependencies only when the app uses stdx APIs.
- Reusable project structure lives in the template directory, not in script string literals.

## References

- Project template: `templates/cangjie-harmonyos-app/`
- Creation tool: `tools/create_project.py` (owns parameter validation, file copying, placeholder replacement)
- Template summary: `references/project-init/project-template.md`
