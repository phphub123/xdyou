# Phase B exam slice

Date: 2026-07-31

## Implemented

- Real arranged endpoint: `wdksap.do`.
- Real unarranged endpoint: `cxyxkwapkwdkc.do`.
- Source-aligned `ExamItem` model with course id, arrangement state and parsed start time.
- `ExamController` groups into upcoming, unarranged and finished.
- Upcoming exams sort by start time ascending; finished exams sort descending.
- Simplified-Chinese sections and stable ids: `examUpcomingSection`, `examUnarrangedSection`, `examFinishedSection`.

## Verification

- Hvigor: `BUILD SUCCESSFUL in 1 min 2 s 760 ms`.
- HAP: `entry/build/default/outputs/default/entry-default-unsigned.hap`, 3128644 bytes.
- x86_64 emulator install and cold launch passed; PID 25398.
- UI capture: `evidence/phase-b-exam-runtime-v2/`.
- Bounded target hilog: `evidence/phase-b-exam-runtime/hilog/`.

## Gate

Live exam counts, field equality and authenticated section screenshots remain `BLOCKED_EXTERNAL` until a genuine IDS/Ehall session succeeds. No sample data, fabricated cookie or empty-list success is used.
