# Academic live-data repair — 2026-08-11

## Scope

- Baseline: current `source_2.0/` and `UI真实数据展示截图/` inventory.
- Target: real Ehall timetable, score and examination data after a genuine IDS login.
- No credential, cookie, token, response body, course name, grade value, examination name, room or seat is persisted in this evidence.

## Root cause and implementation

`AcademicSession` called each Ehall business endpoint with the general IDS/Ehall cookie but did not first open that application's `appShow?appId=...` SSO entry. The Flutter implementation performs that bootstrap for each business app. The Cangjie repository now initializes and retains an application-specific cookie jar before each API request, merges redirect cookies, and rejects a returned login page as session expiry.

Auto-load was added to score and examination pages. Examination refresh first resolves the current semester, then combines arranged and unarranged endpoints before the existing three-way grouping and time ordering. The campus home schedule card now reads the same real timetable controller. The campus-card card now exposes a real loading/success/error state instead of remaining indefinitely on static loading text; its current separate OAuth chain still ends in HTTP 404 and remains external/unaccepted.

## Runtime verification

- Hvigor `assembleApp`: `BUILD SUCCESSFUL`.
- HAP: `entry/build/default/outputs/default/app/entry-default.hap`.
- x86_64 emulator: overwrite install, launch and real session restoration succeeded.
- Campus schedule: 34 real course arrangements loaded.
- Scores: 36 real score records loaded.
- Examinations: 18 real records loaded; current data grouped as 10 unarranged, 8 completed and 0 arranged.
- Ehall app-session bootstrap was observed for timetable app `4770397878132218`, score app `4768574631264620`, and examination app `4768687067472349`.

## Remaining acceptance gaps

- The supplied source screenshots remain the visual reference, but no new HarmonyOS screenshot containing private academic data is persisted. Pixel-level paired-image acceptance is therefore still `IN_PROGRESS`.
- Current-semester arranged-exam field and ordering acceptance cannot pass with zero arranged records in the account response; unarranged/completed grouping is verified.
- Library borrowing and campus energy homepage summaries are not yet connected to real account repositories.
- Campus-card OAuth currently returns HTTP 404 during the independent service redirect chain; it is shown as a real error, not a successful or demo balance.
