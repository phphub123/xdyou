# Phase B score vertical slice

Date: 2026-07-31

## Implemented

- Read the Flutter score model, Ehall score session, score state, list/card and composition-detail source chain.
- Split the Cangjie score model and controller from the previous combined academic model.
- Parse mark, course name, semester, numeric/level score, credit, course category, course nature, retake status, score type, pass state and teaching-class ID from real `xscjcx` rows.
- Implemented the Flutter GPA thresholds for numeric, three-level and five-level results.
- Added semester/kind/search filtering contract plus credit-weighted average and GPA summary.
- Wired the richer fields and summary into the simplified-Chinese score page.
- No fabricated scores, empty-success response, or fake authenticated state was added.

## Verification

- `BUILD SUCCESSFUL in 15 s 328 ms`.
- HAP: `entry/build/default/outputs/default/entry-default-unsigned.hap`, 3001492 bytes.
- Latest HAP installed and EntryAbility cold-started on x86_64 emulator; process 6584 confirmed.

## Remaining score gaps

- Real row counts, filters, sorting, composition detail and Android pairing remain `BLOCKED_EXTERNAL` pending manual authenticated login.
- Cache serialization/fallback and selection-mode calculation persistence remain required before P21 can pass.
