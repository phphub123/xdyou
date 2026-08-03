# Phase C-F local-features slice: custom courses

Date: 2026-08-03
Branch: `feature/owner/local-features`

## Implemented

- Source-aligned `CustomClass` and exact-date time-range models with 08:30-21:25 validation.
- Preferences-backed JSON repository; no IDS session is required and no account data is stored.
- Add, edit, delete, clear-all, multiple time ranges, stable component IDs, and explicit error state.
- Custom occurrences are merged into `ClassTablePage` by term start date, selected week, and weekday, then stably sorted by start time and name.
- Login remains real-only. A temporary offline test route never set authenticated state or cookies and was removed after runtime evidence was captured; production navigation is through the academic hub.

## Verification

- Final production dual ABI Hvigor build after removing the temporary offline harness: `BUILD SUCCESSFUL in 2 min 1 s 219 ms`.
- HAP: `entry/build/default/outputs/default/entry-default-unsigned.hap`.
- Final install/cold-launch capture: `evidence/runtime/2026-08-03-custom-class-final-launch` with target PID 7024.
- Add/save UI scenario: `evidence/runtime/2026-08-03-custom-class-flow-2/interaction_report.md` (2/2 assertions).
- Reinstall/restart persistence: `evidence/runtime/2026-08-03-custom-class-restart/interaction_report.md` (2/2 assertions).
- Synthetic record cleanup: `evidence/runtime/2026-08-03-custom-class-cleanup/interaction_report.md` (2/2 assertions).
- Target hilog: `evidence/runtime/2026-08-03-custom-class-cleanup/hilog/hilog_summary.md`; no target-process fatal line. Two counted errors are SceneBoard/icon feature-map messages from system processes.

## Remaining acceptance gap

- The timetable card path compiles but a live UI assertion still needs valid term metadata from the real timetable response. This remains part of B20 and is not marked PASS.
- Android/HarmonyOS paired screenshots and picker-level visual parity remain Phase F work.
