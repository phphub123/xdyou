# Phase B timetable vertical slice

Date: 2026-07-31

## Source chain read

- `source/lib/controller/classtable_controller.dart`
- `source/lib/controller/semester_controller.dart`
- `source/lib/model/xidian_ids/classtable.dart`
- `source/lib/repository/xidian_ids/classtable_session.dart`
- `source/lib/page/classtable/` page, state, week selector, organized-data and table-view files

## Implemented in this slice

- Split timetable model, repository, controller, and page into source-aligned Cangjie packages.
- Added course code/number, week bitmap, semester start date, semester length, and unarranged-course transport models.
- Added real Ehall calls for semester start (`cxjcs`), arranged classes (`xskcb`) and unarranged classes (`cxxsllsywpk`).
- Added the required student account field to timetable requests; it comes only from a restored real session.
- Added stable week/day filtering and start-period sorting in `ClassTableController`.
- Added previous/next week, Monday-Sunday selection, term metadata, empty state, course cards and unarranged-course list with stable IDs and simplified-Chinese default copy.
- No sample rows, fabricated cookie, empty-success path, or navigation bypass was added.

## Verification

- `BUILD SUCCESSFUL in 18 s 878 ms`.
- HAP: `entry/build/default/outputs/default/entry-default-unsigned.hap`, 2943828 bytes.
- Latest HAP installed and EntryAbility started on x86_64 emulator; process confirmed.
- Cold-start UI: `evidence/phase-b-classtable-runtime/`.
- Bounded hilog: `evidence/phase-b-classtable-hilog/`.

## Remaining timetable gaps

- Authenticated UI interaction, row counts and Android pairing are `BLOCKED_EXTERNAL` until manual real login.
- Cache serialization/fallback, class-change merge, exam/custom/experiment overlays, current-time indicator, background image, arrangement details and add/edit custom course remain required before P20 can pass.
- Graduate timetable routing remains pending role detection from a real session.
