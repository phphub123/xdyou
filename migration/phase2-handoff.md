# Phase 2 handoff: timetable, scores, examinations

## Current state

- Workspace: `C:\Users\21768\Desktop\XDYou-Cangjie-Codex-Workspace`.
- Phase 1 is `BLOCKED_EXTERNAL`: the live school IDS rejected two manual slider-verification attempts. Do not claim real login, session restoration, logout, clear-data-after-login, or any real academic data as PASS unless a real IDS login succeeds.
- Never recover credentials from prior screenshots; no account, password, Cookie, token, or captcha payload is stored in the workspace.
- Existing Cangjie entry: `entry/src/main/cangjie/page/login/login_page.cj`; sessions: `repository/auth/ids_session.cj`, `repository/auth/ids_password_cipher.cj`, `repository/auth/session_store.cj`.
- Existing HomePage is only an authenticated five-tab shell.

## Read before coding

1. `AGENTS.md`, `migration/progress.md`, `migration/file-name-map.csv`, `acceptance/acceptance-matrix.csv`, `evidence/skill-and-rag-usage.md`.
2. Every SKILL.md mandated by AGENTS.md.
3. Run mandatory `cjdocs.py doctor` and Button/TextInput query. Previous task received `OperationalError: unable to open database file`; if repeated, record it and read the matching packaged raw docs instead.
4. Record all skills, queries, refs, fallback docs, builds, captures, and acceptance conclusions in evidence.

## Source slices

### 1. Timetable

Read fully:

- `source/lib/controller/classtable_controller.dart`
- `source/lib/model/xidian_ids/classtable.dart` plus generated-companion semantics
- `source/lib/repository/xidian_ids/classtable_session.dart`
- `source/lib/page/classtable/**`, including `class_table_view/**`, `class_page/**`, `arrangement_detail/**`, `class_add/**`
- `source/lib/page/homepage/info_widget/classtable_card.dart`

Preserve names where practical under `entry/src/main/cangjie/controller/`, feature-grouped `model/` and `repository/` directories, and `page/classtable/`.

### 2. Scores

Read fully:

- `source/lib/controller/semester_controller.dart`
- `source/lib/model/xidian_ids/score.dart` plus generated-companion semantics
- `source/lib/repository/xidian_ids/score_session.dart`
- `source/lib/page/score/**`
- `source/lib/page/homepage/toolbox/score_card.dart`

### 3. Examinations

Read fully:

- `source/lib/controller/exam_controller.dart`
- `source/lib/model/xidian_ids/exam.dart` plus generated-companion semantics
- `source/lib/repository/xidian_ids/exam_session.dart`
- `source/lib/page/exam/**`
- `source/lib/page/homepage/toolbox/exam_card.dart`

## Non-negotiable implementation rules

- Cangjie business code only. No Flutter, static login, manufactured session Cookie, demo JSON, or empty-list PASS.
- Port real URLs, headers, cookies, parameters, parsing, cache/invalidation, sorting, and error classification.
- Implement loading, empty, timeout/network/server errors, refresh, details, and main-thread state updates.
- Timetable: semester/week/day selection, time-grid placement, scrolling, course/exam/custom arrangements, current-time indicator and detail navigation where source provides them.
- Scores: semester choice, list ordering, statistics/aggregation, detail and refresh.
- Exams: arranged/not-arranged paths, ordering, detail and refresh.
- Do not write response bodies, credentials, Cookies, tokens, or captcha data to evidence or filenames.

## Authentication gate

Real-data verification requires a genuine IDS/Ehall session. If live authentication is still blocked, implement and test non-authenticated/local/error paths but mark affected real-data cases `BLOCKED_EXTERNAL`, with exact command and non-sensitive error evidence. Do not replace them with a fake-success test. If login succeeds later, immediately complete restoration, logout and clear-data checks before using the session for the three slices.

## Known toolchain

```powershell
$env:HVIGOR_USER_HOME='C:\Users\21768\.hvigor'
$env:DEVECO_SDK_HOME='C:\Users\21768\Desktop\devecostudio\DevEco Studio\sdk'
$env:DEVECO_CANGJIE_HOME='C:\Users\21768\.cangjie-sdk\6.1\cangjie'
$env:DEVECO_CANGJIE_PATH='C:\Users\21768\.cangjie-sdk\6.1\cangjie'
$env:DEVECO_OH_NATIVE_HOME='C:\Users\21768\Desktop\devecostudio\DevEco Studio\sdk\default\openharmony'
& 'C:\Users\21768\Desktop\devecostudio\DevEco Studio\tools\hvigor\bin\hvigorw.bat' assembleApp --no-daemon
```

- HAP: `entry/build/default/outputs/default/entry-default-unsigned.hap`
- Emulator: `127.0.0.1:5557`
- Bundle: `io.github.benderblog.traintime_pda.harmonyos`; ability: `EntryAbility`
- Use `harmonyos-build-run-diagnose/tools/ui_capture.py` and `hilog_capture.py`.
- On build failure: save full log, run `build_analyzer.py`, inspect first stable error, read the relevant ref, make minimal repair, rebuild.

## Gate for each slice

Do not start the next slice until the current slice has source review, API refs, implementation (or explicit external blocker), build/HAP, install/foreground/screenshot/component-tree/hilog, Android/HarmonyOS paired evidence when authenticated, and updated mapping/progress/evidence/matrix.

Phase 2 is PASS only if all three slices and all real-data assertions PASS. Otherwise finish as `BLOCKED_EXTERNAL`, never as feature-equivalent.
