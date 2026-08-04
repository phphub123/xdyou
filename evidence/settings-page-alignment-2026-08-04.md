# Settings page alignment — 2026-08-04

## Reference capture

- Device: HarmonyOS emulator `127.0.0.1:5555`.
- Reference bundle: `io.github.benderblog.traintime_pda`, version `1.6.3+47`.
- Initial screen: `acceptance/runtime/2026-08-04-settings-reference-initial/`.
- Four lower-page captures: `acceptance/runtime/2026-08-04-settings-reference-scroll/`.
- Captured order: 关于 → 界面设置 → 账号设置 → 课表相关设置 → 缓存登录设置.

The reference uses a fixed five-item bottom bar, 17-vp-equivalent horizontal page inset, blue centered section headers, pale lavender card bodies, inset dividers, chevrons, a three-part brightness selector and switch controls.

## Implemented alignment

- Reworked `AlignedSettingsPage` in `entry/src/main/cangjie/aligned_home_page.cj` around the captured card hierarchy, spacing, colors, typography and controls.
- Added the missing reference-visible rows for low-electricity warning/threshold, language, account credentials, air-conditioner source, timetable background/cleanup/refresh/offset/semester, logs, cache cleanup and logout.
- Kept real persistence for color, theme, simplified timeline, low-electricity warning/threshold and language through `SessionStore`.
- Kept the real logout callback. Settings subpages not yet migrated respond with an explicit `功能迁移中` message and remain `IN_PROGRESS`; this visual slice does not claim those business flows as complete.
- Added stable IDs for the timeline, low-electricity and timetable-background switches and all three brightness choices.

## Verification

- Baseline before modification: `BUILD SUCCESSFUL` and HAP present.
- Final build: `BUILD SUCCESSFUL in 7 s 853 ms`.
- HAP: `entry/build/default/outputs/default/entry-default-unsigned.hap`.
- Final install/launch PID: `15098` on `127.0.0.1:5555`.
- Scenario: `acceptance/scenarios/settings-alignment.json`.
- Final runtime evidence: `acceptance/runtime/2026-08-04-settings-traditional-final/`.
- Interaction: 9/9 steps and 4/4 assertions passed; all five settings groups are reachable while the fixed settings navigation item remains visible.
- Bounded target-process log: 0 app-line FATAL, 0 ERROR, 0 WARN.

## Status boundary

The settings page visual hierarchy and scroll coverage are `PASS`. Global theme/localization application, update checking, password dialogs, timetable background picking, cache restart and log viewer remain `IN_PROGRESS` and are not represented as completed.

## Traditional Chinese follow-up

- Converted every visible settings-page label, subtitle and migration notice to the checked-in `zh_TW` wording.
- Entering the settings page now persists `Traditional Chinese`; legacy simplified color names are normalized to their traditional display values.
- Final follow-up build: `BUILD SUCCESSFUL in 7 s 842 ms`.
- Runtime evidence: `acceptance/runtime/2026-08-04-settings-traditional-final/`.
- The full scroll scenario again passed 9/9 steps and 4/4 assertions, and bounded target-app logging contains 0 FATAL, 0 ERROR and 0 WARN app lines.
