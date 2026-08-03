---
name: harmonyos-build-run-diagnose
description: "Use this skill to build, repair, install, launch, capture UI, interact with, and diagnose Cangjie HarmonyOS apps. Use it for .hap generation, build failures, cjpm/Hvigor cache recovery, hdc discovery, emulator or device validation, screenshots, component-tree assertions, hilog runtime triage, white screens, crashes, and interaction bugs."
---

# Build, Run, and Diagnose

Build pipeline plus on-device validation for Cangjie HarmonyOS apps: compile, recover caches, install, launch, capture, and triage.

## Scope

Portage-managed project (root `CLAUDE.md` contains a 「工程铁律」 section): the platform
owns builds and build configs — do not run builds yourself; the platform builds after your
change and feeds errors back. Device/diagnosis tools below remain usable in both modes.
Standalone project: the full workflow below applies.

## Quick Route

| Scenario | Run |
| --- | --- |
| Build (preferred: with cache recovery + retry) | `tools/build_recovery.py --retry` |
| Build, raw single pass | `tools/build.py --project-root <project>` |
| Parse a failed `build.log` into the first stable error block | `tools/build_analyzer.py` |
| Install, launch, screenshot, dump component tree, interact, assert | `tools/ui_capture.py` |
| Bounded hilog capture with severity summary | `tools/hilog_capture.py` |
| Known failure patterns | `references/build-failures.md` |
| Foreground/UI/interaction/hilog judgment rules | `references/runtime-ui-diagnosis.md` |

## Workflow (build failure)

1. Read `<project>/build.log`.
2. Run `tools/build_analyzer.py` (from elsewhere pass `--project-root <project>`); extract the first stable error block, not the last noisy warning.
3. Check project `Evolution.md`, then `<harmonyos-evolution-skill>/references/memory.md`.
4. Match `references/build-failures.md` patterns; for API signatures, cjpm fields, and error terms query `cangjie-harmonyos-knowledge`.
5. Make the smallest code/config fix and rebuild.
6. After two repeated failures with the same signature, widen cleanup scope (`build_recovery.py`) or report the exact blocker.

## Commands

```powershell
python <harmonyos-build-run-diagnose-skill>/tools/build_recovery.py --retry
python <harmonyos-build-run-diagnose-skill>/tools/build.py --project-root <project>

# install + launch + capture after a successful build
python <harmonyos-build-run-diagnose-skill>/tools/ui_capture.py `
  --project <project> `
  --hap "<project>/entry/build/default/outputs/default/entry-default-unsigned.hap" `
  --out <out>

# bounded runtime log when launch/crash/white-screen/assertion fails
python <harmonyos-build-run-diagnose-skill>/tools/hilog_capture.py --project-root <project> --out <out> --seconds 8

# locate hdc if needed
& "C:\Program Files\Huawei\DevEco Studio\sdk\default\openharmony\toolchains\hdc.exe" list targets
```

## Toolchain & Device Resolution

- `build.py` auto-discovers the Cangjie SDK under `~/.cangjie-sdk/<version>/cangjie` (highest version wins). Override with `--cangjie-sdk` / `--deveco-home` or `[toolchain]` config only when paths are non-standard.
- Module: the build reads the first module from root `build-profile.json5`; pass `--module <name>` only to override.
- Config layering follows the family convention (later layers override earlier); details in `../harmonyos-cangjie-dev/references/configuration.md`.
- `ui_capture.py` and `hilog_capture.py` route every hdc call to one resolved device (`--target` > `[device].target` > sole online device; with several devices online you must pick one), probe emulator ports `5555/5557/5554/5559` via `hdc tconn` when nothing is online, and confirm the app process via `pidof` after `aa start` (relaunch up to 2 times) — `aa start` success does not imply process spawn.
- `hilog_capture.py` auto-detects bundle/module/ability from the project; pass `--bundle`/`--ability`/`--module` only when detection is ambiguous.

## Guardrails

Build success requires all of: `ohpm install` ok · `SyncCangjieResource` ok · `assembleHap` logs `BUILD SUCCESSFUL` · `<module>/build/default/outputs/default/*-unsigned.hap` exists.

- A build success is not enough for UI work; verify foreground state and business key/text.
- A screenshot or layout capture showing launcher, status bar, or unrelated windows proves nothing.
- Prefer stable `key` assertions (`countDisplay == "1"`) over visual diffs.
- Treat full-system hilog `ERROR` lines as noise unless they match the target bundle/process or explain the symptom.

## Recording

Record only verified lessons: task-specific notes → project `Evolution.md`; reusable lessons → `<harmonyos-evolution-skill>/references/memory.md` (formats in that skill).
