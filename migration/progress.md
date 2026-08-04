# Migration progress

| Phase | Status | Evidence / next gate |
| --- | --- | --- |
| 0 Bootstrap | PASS | x86_64 HAP build, install, launch, UI capture, and hilog recorded. |
| 1 Login, session, home, settings | BLOCKED_EXTERNAL | Current IDS direct password flow and invalid-account response pass. Cookie persistence now uses HUKS AES-GCM. Valid login, restart restoration and role checks still require one manual secure credential entry. |
| 2 Academic features | BLOCKED_EXTERNAL | Builds, install, launch, UI capture and hilog passed; real academic data and Android comparison await a real IDS/Ehall session. |

## Phase 1 implemented

- HTTPS IDS page loading, dynamic hidden-field parsing, AES-CBC/Base64 password and slider payload encryption, cookie merge/persistence, and login POST wiring.
- Direct credential submission is now the default. Slider UI is conditional on an explicit server challenge; script references in the IDS HTML no longer trigger a false captcha branch.
- Session cookies are persisted only as HUKS AES-GCM authenticated ciphertext with a random nonce; legacy plaintext values migrate once and are deleted.
- Input validation, password-visibility control, loading/error states, real-login-only session persistence, session clearing, five-tab shell, and settings language/theme persistence.
- Final offline evidence: `evidence/phase1-offline-final-build.log`, `evidence/phase1-offline-final-runtime/`, and `evidence/phase1-offline-final-hilog/`.

## External blocker

Valid IDS/Ehall acceptance still needs one manual no-echo credential entry. Automation evidence may not capture the component tree while a real password is populated. No account, password, cookie, token, or captcha payload is stored in repository evidence.

## Five bottom destinations UI alignment (2026-08-04)

- Added a source-ordered Cangjie shell for Campus, Ruisi, Toolbox, Pig gallery and Settings in `aligned_home_page.cj`.
- Kept existing real feature pages reachable from the campus cards; toolbox list items open their real source URLs through ArkWeb; local navigation, edit-state, forum-tab, pig-state and settings interactions are wired.
- Two final Hvigor passes reported `BUILD SUCCESSFUL`; the HAP was installed and launched on `127.0.0.1:5555`.
- `acceptance/runtime/2026-08-04-five-tabs-final/` contains five screenshots, five filtered component trees and a 3/3 interaction report.
- Android/iOS original-app runtime capture is `BLOCKED_EXTERNAL` because no Android or iOS device is available. The checked-in Flutter source is the visual/semantic reference; paired screenshot parity is not marked PASS.

## Campus home screenshot alignment (2026-08-04)

- Aligned `AlignedCampusPage` and `AlignedNavItem` directly to `UI截图/0.png`: Traditional Chinese labels, beta banner, schedule loading/failure chips, energy/library/campus-card rows, QR affordance, two four-column tool rows and the five-item selected blue capsule.
- Added tintable local SVG resources for all visible campus and bottom-navigation icons; existing feature callbacks and stable navigation IDs remain connected.
- Final dual-ABI HAP build succeeded, installed on `127.0.0.1:5555`, and launched as PID 4243.
- `acceptance/runtime/2026-08-04-home-nav-aligned-final/` contains the final screenshot, filtered component tree and a 5/5 reference-key interaction report.
- Bounded target logging contains 0 FATAL. One non-fatal UIAbility continuation diagnostic was emitted during emulator startup and did not terminate or hide the app.

## Pig gallery screenshot alignment (2026-08-04)

- Aligned `AlignedPigPage` to `UI截图/6.png`: Traditional Chinese header and hint, refresh action, centered 300vp rounded image, title, outlined `Change A Pig` / `Save this Pig` actions, and selected Pig bottom-navigation capsule.
- Added a real Cangjie `PigHubSession` using the source endpoint, explicit NetworkKit timeouts, stdx JSON parsing, in-memory caching, random selection and immediate-repeat avoidance. Loading, transport, parse and image failures remain visible and retryable.
- Final HAP reports `BUILD SUCCESSFUL in 6 s 985 ms`, installed on `127.0.0.1:5555`, and launched as PID 25113.
- The combined scenario passed 4/4 assertions. In one session `Change A Pig` changed `猪猪我呀` to `猪思考(猪撅猪)` and replaced the image; before/after captures are under `acceptance/runtime/2026-08-04-pig-aligned-change-final/`.
- Bounded target logging contains 0 FATAL, 0 ERROR and 0 WARN app lines.

## Toolbox screenshot alignment (2026-08-04)

- Aligned `AlignedToolboxPage` and `AlignedToolRow` to `UI截图/2.png`: Traditional Chinese title/copy, seven borderless rows, reference-like vertical rhythm, monochrome line icons and the selected blue Toolbox navigation capsule.
- Added seven tintable SVG resources and removed the placeholder text badges, row borders, chevrons and unselected white navigation capsules.
- Preserved the seven real source URLs and ArkWeb opening boundary; stable IDs cover each row.
- Final HAP reports `BUILD SUCCESSFUL in 7 s 148 ms`, installed on `127.0.0.1:5555`, and launched as PID 30731.
- `acceptance/runtime/2026-08-04-toolbox-aligned-final/` contains the final screenshot and component tree; all 8 assertions passed. Bounded target app logging contains 0 FATAL, 0 ERROR and 0 WARN.
## Phase 2 academic features

- Implemented real Ehall request boundaries for timetable (xskcb), scores (cjcx/xscjcx) and examinations (wdksap), with session gating, timeouts, HTTP/error handling and stdx JSON parsing.
- Added authenticated Tools pages with refresh, loading, empty/error state and scrollable course, score and examination list layouts.
- Build, x86_64 installation, launch, screenshots, component trees and bounded hilog are recorded under evidence/phase2-*.
- Status is BLOCKED_EXTERNAL: no real IDS slider verification succeeded, so no cookie, response data, paired Android screenshot or fake-success test was used.
## Phase C campus-card slice (2026-08-04)

- Added real SSO/OpenID balance transaction and payment-QR chain plus a stable-ID campus page entry.
- Dual-ABI build and x86_64 offline error-boundary scenario pass; QR payload was not requested or captured.
- Genuine account data and Flutter pairing remain `BLOCKED_EXTERNAL`; see `evidence/phase-c-school-card-slice.md`.
