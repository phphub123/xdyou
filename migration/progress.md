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
## Phase 2 academic features

- Implemented real Ehall request boundaries for timetable (xskcb), scores (cjcx/xscjcx) and examinations (wdksap), with session gating, timeouts, HTTP/error handling and stdx JSON parsing.
- Added authenticated Tools pages with refresh, loading, empty/error state and scrollable course, score and examination list layouts.
- Build, x86_64 installation, launch, screenshots, component trees and bounded hilog are recorded under evidence/phase2-*.
- Status is BLOCKED_EXTERNAL: no real IDS slider verification succeeded, so no cookie, response data, paired Android screenshot or fake-success test was used.
