# Phase 3 handoff: campus queries and toolbox

## Phase 2 closure

- Phase 2 status is `BLOCKED_EXTERNAL`, not PASS. Timetable, score and examination source paths were ported as pure Cangjie request boundaries with session gating, timeouts, HTTP/error classification, stdx JSON parsing, refresh, loading, empty/error states and scrollable views.
- Latest build: `BUILD SUCCESSFUL` on 2026-07-29. HAP: `entry/build/default/outputs/default/entry-default-unsigned.hap`.
- Device evidence: `evidence/phase2-classtable-runtime/`, `evidence/phase2-classtable-hilog/`, `evidence/phase2-score-exam-runtime/`, `evidence/phase2-score-exam-hilog/`.
- The x86_64 emulator `127.0.0.1:5557` installed and launched the bundle `io.github.benderblog.traintime_pda.harmonyos`; no target-process fatal error was accepted as a pass condition.
- A genuine IDS/Ehall login remains blocked by slider verification. Never create a cookie, response fixture, static success state, or artificial home navigation to bypass it. Real-data checks and Android/Harmony paired comparisons stay `BLOCKED_EXTERNAL` until this changes.

## Current Cangjie layout

- App entry and authenticated shell: `entry/src/main/cangjie/page/login/login_page.cj` and `entry/src/main/cangjie/page/homepage/aligned_home_page.cj`.
- Real IDS/session persistence: `entry/src/main/cangjie/repository/ids_session.cj`, `repository/session_store.cj`.
- Phase 2 models and Ehall client: `model/xidian_ids/academic.cj`, `repository/xidian_ids/academic_session.cj`.
- Phase 2 UI: `classtable_page.cj`, `academic_pages.cj`; the existing **Tools** tab opens `AcademicHub`.
- `entry/cjpm.toml` includes both Ohos ABIs and local stdx `1.1.0.1` dynamic library paths. Preserve both ABI targets.

## Mandatory process carried forward

1. Read `AGENTS.md`, `migration/progress.md`, `migration/file-name-map.csv`, `acceptance/acceptance-matrix.csv` and `evidence/skill-and-rag-usage.md`.
2. Read all skills mandated by `AGENTS.md`; inspect source model/controller/repository/page before each vertical slice.
3. Run the required RAG doctor and query. In this workspace both commands currently fail with `OperationalError: unable to open database file`; record the exact command/error, then read matching raw packaged docs before implementation.
4. Each slice needs a separate build, HAP, install, foreground confirmation, screenshot/component tree, bounded hilog, source mapping, evidence and matrix update. After two same-signature build errors, use `build_analyzer.py` and the relevant reference.
5. Do not retain accounts, passwords, cookies, tokens, payment codes, QR payloads, server response bodies or captcha data in source, evidence, filenames or logs.

## Phase 3 source routing

| Requested slice | Start with source paths |
| --- | --- |
| Attendance | `controller/class_attendance_controller.dart`, `repository/xidian_ids/class_attendance_session.dart`, `page/class_attendance/**` |
| Empty rooms | `controller/empty_classroom_controller.dart`, `repository/xidian_ids/empty_classroom_session.dart`, `page/empty_classroom/**` |
| Dorm energy/water | `controller/energy_controller.dart`, `repository/aircon_session.dart`, `repository/dorm_water_session.dart`, `page/energy/**`, `page/dorm_water/**` |
| Library | `controller/library_controller.dart`, `repository/xidian_ids/library_session.dart`, `page/library/**` |
| Campus card | `controller/school_card_controller.dart`, `repository/xidian_ids/school_card_session.dart`, `page/schoolcard/**` |
| Campus network | `repository/schoolnet_session.dart`, `page/schoolnet/**` |
| Sport | `repository/xidian_sport_session.dart`, `page/sport/**`, sport password settings dialog |
| Physics/experiment | `controller/physics_experiment_controller.dart`, `controller/other_experiment_controller.dart`, `repository/physics_experiment_session.dart`, `repository/experiment_score/**`, `page/experiment/**` |
| Custom courses/clubs/tools | `controller/custom_class_controller.dart`, `page/classtable/class_add/**`, `page/club_suggestion/**`, `page/homepage/toolbox/**` |

## Phase 3 capability lookup guidance

- Query raw/knowledge docs before network or HTML parsing, QR rendering, charting, permissions, files, calendar, Web, storage or UI-state choices.
- For campus-network-only services, preserve the request stage and classified failure in evidence. Mark `BLOCKED_EXTERNAL` when inaccessible; do not treat it as an empty successful response.
- Payment QR and campus-card data are sensitive. Render only a live authorized value; never persist or screenshot the payload in project evidence.
- Charts need real calculated series from live/cache data; no hard-coded sample points.

## Remaining Phase 2 gaps

- Missing real IDS/Ehall session means real refresh success, data quantity/order/key-field comparison, details, Android paired screenshots and UI closeness remain unverified for timetable, scores and examinations.
- Phase 2 has no claim of feature equivalence. Re-open its `BLOCKED_EXTERNAL` rows immediately if a successful real session becomes available.
