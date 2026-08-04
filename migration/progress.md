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

## Settings simulator alignment (2026-08-04)

- Captured the emulator-installed Traintime PDA `1.6.3+47` settings page from top to bottom and preserved the reference/reference-scroll component trees and screenshots.
- Aligned the Cangjie page to the five blue-header/lavender-body cards, reference row order, dividers, chevrons, brightness selector, switches and fixed selected settings navigation capsule.
- Persisted the already-supported visual preferences and retained real logout; unsupported child pages show an explicit migration message and remain `IN_PROGRESS`.
- Final HAP reports `BUILD SUCCESSFUL in 7 s 853 ms`, installed on `127.0.0.1:5555`, and launched as PID 15098.
- `acceptance/runtime/2026-08-04-settings-traditional-final/` passed 9/9 steps and 4/4 assertions. Bounded target app logging contains 0 FATAL, 0 ERROR and 0 WARN.
- Follow-up: all settings copy now uses the source `zh_TW` wording, the selected language is persisted as Traditional Chinese, and `acceptance/runtime/2026-08-04-settings-traditional-final/` again passes 9/9 steps and 4/4 assertions with clean target-app logging.
## Phase 2 academic features

- Implemented real Ehall request boundaries for timetable (xskcb), scores (cjcx/xscjcx) and examinations (wdksap), with session gating, timeouts, HTTP/error handling and stdx JSON parsing.
- Added authenticated Tools pages with refresh, loading, empty/error state and scrollable course, score and examination list layouts.
- Build, x86_64 installation, launch, screenshots, component trees and bounded hilog are recorded under evidence/phase2-*.
- Status is BLOCKED_EXTERNAL: no real IDS slider verification succeeded, so no cookie, response data, paired Android screenshot or fake-success test was used.
## Phase C campus-card slice (2026-08-04)

- Added real SSO/OpenID balance transaction and payment-QR chain plus a stable-ID campus page entry.
- Dual-ABI build and x86_64 offline error-boundary scenario pass; QR payload was not requested or captured.
- Genuine account data and Flutter pairing remain `BLOCKED_EXTERNAL`; see `evidence/phase-c-school-card-slice.md`.
## Phase C sports slice (2026-08-04)

- Added the real independent sport login protocol, HUKS-encrypted password storage, physical-test summary/year details and sport-class chain.
- The campus sport card now opens a stable-ID score/class page with loading, empty and explicit error states.
- User reported DevEco Studio build and HarmonyOS emulator launch success for the current tree; genuine sport data parity remains `BLOCKED_EXTERNAL`.
- Evidence: `evidence/phase-c-sport-slice.md`.
## Toolbox Web and experiment slice (2026-08-04)

- Added real ArkWeb load state, Web-history back, explicit list return, timeout, retry and visible controller-error handling for all seven source URLs; 4/4 runtime assertions passed.
- Added the physics experiment source chain with encrypted independent password, dynamic ASP.NET login fields, real schedule parsing and chronological ongoing/upcoming/finished groups.
- Added the real report-service event chain and source-identical RGBA pixel FNV-1a score-image recognition; no score or schedule data is fabricated.
- Dual-ABI build passed in 4 min 30 s; x86_64 install/launch and experiment-page 4/4 assertions passed with zero app-line FATAL/ERROR entries.
- Physics live data and other-experiment IDS OAuth remain `BLOCKED_EXTERNAL`/`IN_PROGRESS`; next implementation boundary is `migration/phase-cd-handoff.md`.

## Phase D Sysj other-experiment slice (2026-08-04)

- Added `SysjSession`, which accepts only the HUKS-restored genuine IDS cookie, follows Sysj SSO/OAuth redirects, receives the callback credential in memory, logs into Sysj, and requests weeks 1–25 from `StudentCurrWeekTimetable`.
- The parser validates the second timetable table and seven dates, accepts only the source course/lab/teacher markers, merges contiguous time cells and duplicate experiment/lab/teacher records, then orders groups by first start time. It fails explicitly on malformed responses rather than treating them as an empty timetable.
- `ExperimentController` now keeps independent physics/other request guards; the other-experiment tab invokes the real data chain and retains stable status and boundary IDs.
- x86_64-only build, install, launch and interaction validation passed on `127.0.0.1:5557`: `BUILD SUCCESSFUL in 1 min 30 s 590 ms`, PID `16982`, and experiment scenario assertions passed 4/4. The configured SDK had no `6.1.1(24)` target, so the root target SDK is aligned to installed compatible SDK `6.1.0(23)`.
- No genuine IDS cookie, campus network, Sysj response body or Flutter paired data was available. C11 is therefore `BLOCKED_EXTERNAL`, not PASS. Evidence: `evidence/phase-d-sysj-other-experiment-slice.md` and `acceptance/runtime/2026-08-04-sysj-other-experiment-x86_64/`.

## Phase C energy slice (2026-08-04)

- Added pure-Cangjie air-conditioner energy model, NetworkKit session, controller and page; the existing campus energy card now reaches it through stable `homeEnergyInfo` navigation.
- The page accepts a transient, format-validated IMEI and issues the real independent air-conditioner state request. Electricity/water retain an explicit real IDS/campus-network gate and no balance or usage data is fabricated.
- Final x86_64 build completed in 47 s 681 ms. The unsigned HAP installed and foreground PID 21096 was confirmed on `127.0.0.1:5557`; `acceptance/runtime/2026-08-04-energy-x86_64/` passed 3/3 boundary assertions.
- Live campus meters, air-conditioner device data and Flutter pairing remain `BLOCKED_EXTERNAL`; see `evidence/phase-c-energy-slice.md`.

## Phase C empty-classroom defaults (2026-08-04)

- Replaced stale static date/term values with current-date defaults, automatically loads buildings on first appearance, and offers loaded teaching-building selection while keeping the manual code fallback.
- Current x86_64 HAP built in 48 s 353 ms and `acceptance/runtime/2026-08-04-empty-classroom-defaults-x86_64/` passed 3/3 assertions on PID 4488.
- Live building/room results and Flutter comparison still require a genuine IDS/Ehall session, so C02 remains `BLOCKED_EXTERNAL`; see `evidence/phase-c-empty-classroom-defaults.md`.

## Phase C dorm-water favorite completion (2026-08-04)

- Added the real authenticated favorite-device add endpoint and a format-validated manual device-ID entry beside the existing device removal/control flows.
- QR scanning is explicitly deferred pending a Scan Kit pure-Cangjie probe; no scan result or favorite is manufactured.
- Latest x86_64 HAP built successfully in 1 min 1 s 909 ms. Runtime service interaction stays `BLOCKED_EXTERNAL` until an independent SMS login is supplied; see `evidence/phase-c-dorm-water-favorite.md`.
