# Phase C-F continuous handoff - 2026-07-31

## Latest verified build/runtime boundary

- IDS returned-login-page fallback, notification bridge, calendar permission/write bridge, classroom attendance and public library search all reached `BUILD SUCCESSFUL`.
- Last fully built HAP before the schoolnet addition: `entry/build/default/outputs/default/entry-default-unsigned.hap`.
- Classroom-attendance build: `BUILD SUCCESSFUL in 1 min 49 s 785 ms`; install/cold launch passed and PID 22453 was captured under `evidence/runtime/attendance-launch/`.
- Library build: `BUILD SUCCESSFUL in 1 min 51 s 414 ms`.
- The following schoolnet files were added after that build and have not been compiled because the platform rejected the required external Hvigor-cache permission after its escalation quota was exhausted:
  - `model/network_usage.cj`
  - `repository/schoolnet_session.cj`
  - `controller/schoolnet_controller.cj`
  - `schoolnet_page.cj`
  - their `index.cj` navigation wiring
- Static follow-up repaired UTF-8 corruption in `string.json` and all new schoolnet user-facing/error strings; both JSON resource files now parse strictly and the schoolnet slice has no mojibake or placeholder markers.
- Existing HAP is 5,314,604 bytes, timestamp 2026-07-31 19:27:44, and predates the schoolnet slice; it must not be cited as schoolnet build evidence.

## Authentication change requiring one manual check

`IDSSession.submitCredentials` now receives `captchaVerified`. A direct POST that returns an IDS login form enters the slider exactly once even when the HTML does not advertise slider endpoints. After successful slider verification, another returned login page is treated as the real credential error and cannot loop.

The installed build containing this change should be tested by manually entering credentials without screenshots or command-line arguments. Expected result: the slider appears instead of immediate `IDS rejected...`. Report only `出现滑块` or `仍直接报错`.

## System capability interoperation

- `external/system_capability_bridge.cj` is the only runtime bridge.
- Notification calls `@ohos.notificationManager.publish` through Cangjie `JSRuntime`.
- Calendar uses the native Cangjie `AbilityAccessCtrl.requestPermissionsFromUser`, then calls `@ohos.calendarManager` through `JSRuntime` and adds a real event.
- No `.ets` business page or ArkTS main Ability was retained.
- Desktop card still requires an independent minimal ArkTS `FormExtensionAbility`; do not change the Cangjie module or UIAbility entry merely to make the form compile.
- Exact boundaries are in `migration/arkts-interop-map.csv`.

## Phase C slices now present

### Classroom attendance

- Source-aligned model/controller/repository/page split.
- Real Chaoxing SSO entry, service cookies, `courseId|clazzId` deduplication, current-semester extraction, 17-column table parsing, four status groups, and 10-row detail pagination.
- Live data remains gated by a genuine IDS/Chaoxing session.

### Library

- Real public OPAC search and physical holding endpoints.
- Keyword/title/author/ISBN fields, pagination, book metadata, availability and holding-location detail UI.
- Authenticated OPAC JWT, borrow list, overdue and renewal remain unfinished.

### School network

- Campus-network detection and real `rad_user_info` JSONP parsing are implemented.
- Current account, plan, balance, traffic, IP and online-device UI is wired.
- Compile/runtime verification is pending; independent-password RSA/captcha usage query remains unfinished.

## First continuation actions

1. Re-run the standard Hvigor build when external-cache permission is available; fix only the first stable Cangjie error, then install and cold-launch.
2. Have the user perform the one-time login check and, if a slider appears, complete it; never capture or persist credentials.
3. Exercise `homeClassAttendance`, `homeLibrary`, `homeSchoolnet`, `testCourseNotification`, and `testSystemCalendar`; capture only post-login screens with sensitive regions masked.
4. Continue Phase C with OPAC borrow/JWT, schoolnet RSA/captcha, energy/aircon/water, campus card QR, sports and experiments.
5. Keep all unverified rows `IN_PROGRESS`/`BLOCKED_EXTERNAL`; no current evidence supports a full Phase C-F completion claim.

## 2026-08-03 IDS automatic-verification rebaseline

- The earlier forced-slider assumption was wrong. Flutter always performs the slider invisibly before credential POST and opens the manual page only after automatic retries fail.
- Added `repository/slider_captcha_solver.cj` with ImageKit decoding and source-aligned NCC matching.
- Fixed captcha AES nonce/IV layout: 64 random plaintext characters plus a separate 16-character IV.
- Matched Flutter sigmoid tracks, six challenge rounds, seven neighboring offsets, and actual per-track wait.
- Small-image decode strips the appended 16-byte AES key; response parsing accepts JSON whitespace/string-number variants.
- Latest HAP is 5,671,100 bytes; build/install/cold launch passed and clean PID 31869 was captured.
- Synthetic fast and complete scenarios are under `evidence/phase-a-auto-slider-*`.
- Current IDS rejects every automatic attempt. A separate ephemeral no-account reference implementation of the Flutter algorithm was also rejected. Do not claim authenticated PASS.
- Manual slider is retained only as a truthful fallback; it is not a fixed pre-login step.
- Full details: `evidence/phase-a-auto-slider-rebaseline.md`.
- Next manual action: enter the genuine account only in the emulator and report whether it reaches home or falls back to manual verification. Never capture the credential fields.

## 2026-08-03 login crash fix and dorm-water slice

- Diagnosed the post-Login process exit from the device faultlogger: ArkWeb AsyncCallback mutated `@State` outside the main thread. The callback now enters `launch {}` before all login state changes.
- Post-fix HAP installed and cold-launched on `127.0.0.1:5557`; PID 6745 and the full login component tree were captured under `evidence/runtime/2026-08-03-login-crash-fix/`. This proves the crash repair at cold launch, not genuine authentication.
- The Flutter reference currently also reports an unknown server error. Genuine IDS redirect and data remain `BLOCKED_EXTERNAL` until the school service is healthy; no static success or fabricated cookie was added.
- Added the dorm-water model/repository/controller/page vertical slice. It uses the real captcha, SMS login, favorite-device, start, stop and status endpoints and stores the returned token encrypted at rest.
- The new slice is wired as `homeDormWater` and passed the full dual-ABI build: `BUILD SUCCESSFUL in 3 min 1 s 609 ms`; x86_64 installation and EntryAbility launch passed.
- Dorm-water remains `IN_PROGRESS`: IDS currently prevents normal home navigation; QR device scan is still unfinished.

### Next independent slice

Continue Phase C with campus card balance/transactions/QR while keeping QR payloads out of screenshots and logs. Do not mark authentication-dependent runtime rows PASS until a genuine session is available.
- Follow-up synthetic Login click reached `Working...`; PID 8697 remained alive and no newer target cjerror appeared. Evidence: `evidence/runtime/2026-08-03-login-click-no-crash/`. Genuine login is still externally unverified.

### Timer-repeat completion

- Dorm-water now polls the active device every 60 seconds, requires three consecutive idle responses before ending monitoring, and cancels the Timer on manual stop, logout and page disappearance.
- Final rebuild: `BUILD SUCCESSFUL in 1 min 48 s 780 ms`; latest HAP installed and EntryAbility PID 11752 confirmed. QR device scanning is the remaining source behavior for this slice.
