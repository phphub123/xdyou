# User-approved Mock home UI preview

Date: 2026-08-03
Branch: `main`

## Boundary

- The login page exposes `mockHomePreviewButton` only to preview already-migrated UI while IDS is unavailable.
- Preview state exists only in `LoginWindow` memory. It does not save an account, cookie, token, authenticated flag, or synthetic business response.
- The real `loginSubmitButton` and IDS flow are unchanged.
- The home header always shows `mockPreviewBanner` and account marker `Mock UI`; `mockPreviewExit` returns to the real login page.
- This is an explicit user-approved temporary acceptance aid and is not authentication PASS.

## Verification

- Dual ABI build: `BUILD SUCCESSFUL in 3 min 12 s 564 ms`.
- HAP: `entry/build/default/outputs/default/entry-default-unsigned.hap`.
- Mock entry/home component scenario: `evidence/runtime/2026-08-04-mock-home-preview-pass/interaction_report.md` (4/4 PASS).
- Exit and restore real login scenario: `evidence/runtime/2026-08-04-mock-home-exit/interaction_report.md` (3/3 PASS).
- Bounded hilog: `evidence/runtime/2026-08-04-mock-home-preview-pass/hilog/hilog_summary.md`; target app has no fatal line. Counted errors are SceneBoard/icon feature-map messages from system processes.
