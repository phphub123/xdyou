# Continuous migration handoff - 2026-07-31

## Verified latest baseline

- Latest build: `BUILD SUCCESSFUL in 15 s 328 ms`.
- Latest HAP: `entry/build/default/outputs/default/entry-default-unsigned.hap`, 3001492 bytes.
- x86_64 HAP install and cold launch passed; latest confirmed PID was 6584.
- No ArkTS business implementation was introduced.

## Completed in this run

1. Repaired IDS direct password submission and made captcha conditional on an explicit server challenge.
2. Rebuilt the login page against `acceptance/reference/login-reference.png`.
3. Replaced plaintext cookie persistence with HUKS AES-GCM authenticated encryption and legacy migration.
4. Split and expanded the timetable model/repository/controller/page; added real term-date, arranged and unarranged requests, week/day filtering and Chinese UI.
5. Split and expanded the score model/controller; added complete Ehall fields, GPA mapping, weighted statistics and richer Chinese cards.

## External gate

Valid login, authenticated page interaction, restart restoration, role detection, live counts and Android paired screenshots require one manual no-echo credential entry. Never capture a component tree while the password field contains a real password.

## First unfinished slice

Exam migration. Read source files already identified in `source/lib/model/xidian_ids/exam.dart`, `source/lib/controller/exam_controller.dart`, `source/lib/repository/xidian_ids/exam_session.dart`, and `source/lib/page/exam/`. Next implementation must split `ExamItem` into `model/exam/exam.cj`, add the `cxyxkwapkwdkc` unarranged endpoint, implement arranged/unarranged/completed grouping and time sorting, then rebuild/install/capture.

## Later required work

Timetable cache/class-change/custom/exam/experiment overlays; score cache/filter selection/composition details; all Phase C-E services; system API probes; nine-screen UI alignment; aarch64 build; final full audit. Do not mark these complete from this handoff.

## Continuation update: exam and Phase C-E foundation

- Fixed password masking so the native input is fully hidden in masked mode; dummy-only UI assertions passed.
- IDS direct login now falls back to slider only when the returned login HTML explicitly exposes both slider endpoints.
- Exam now uses arranged and unarranged endpoints, three-way grouping, upcoming ascending order and finished descending order. Build/install/cold-launch passed; live data remains gated by IDS.
- Empty classroom now has its real three-request Ehall chain and 11-period matrix. Build passed; live query is gated by IDS.
- Toolbox now has seven source ArkWeb destinations, load state and guarded Web history return.
- Settings now persist language, theme, color, timeline, semester, week and low-electricity threshold while refusing sensitive session key names.
- Notification, system calendar and desktop-card imports all failed minimal SDK 6.1 Cangjie probes and are `BLOCKED_EXTERNAL`; see `evidence/phase-e-system-capability-probes.md`.

Latest verified normal build: `BUILD SUCCESSFUL in 1 min 53 s 958 ms`.
Latest normal HAP: `entry/build/default/outputs/default/entry-default-unsigned.hap`, 3767060 bytes.
Latest HAP installed and cold-started successfully on the x86_64 emulator; PID 6240. The latest captured target-app tree/log set is `evidence/phase-c-d-e-runtime/` and contains no app-process fatal line.

## First unfinished slice after this update

Class attendance. It requires the Chaoxing secondary SSO redirect/cookie jar and HTML table parser from `source/lib/repository/xidian_ids/learning_session.dart`; do not substitute Ehall data or static rows. Continue with:

1. service-scoped redirect/cookie merging without persisting response bodies;
2. course-list HTML parsing and deduplication by `courseId|clazzId`;
3. 17-column attendance table parsing and warning/status grouping;
4. detail pagination from `getActiveList`;
5. build/install/runtime evidence and authenticated comparison.

Remaining major Phase C-F work is still substantial: energy/water/aircon, library, card/QR, network, sports, experiments, custom courses/clubs, home registry editing, Pig/Planet/notices, full Ruisi, remaining settings, global theme/i18n, screenshots/SSIM, and final audit. None of these may be inferred complete from the passing build.
