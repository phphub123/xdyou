# Phase A authentication re-baseline

Date: 2026-07-31

## Implemented

- The current IDS login form is parsed from the live response, including dynamic hidden inputs and password encryption salt.
- Username/password is submitted first. A slider branch is entered only when the response explicitly marks a captcha as required.
- HTTP redirects, the IDS continue form, cookie merging, error-account responses, and Ehall landing detection are handled without manufacturing a session.
- A dummy invalid account test reached the live IDS password endpoint and returned `IDS rejected the account or password.` without opening the slider UI.
- The login page was rebuilt against `acceptance/reference/login-reference.png`. Stable component IDs are present for both inputs, password visibility, submit, clear cache, and network interaction.
- Ehall cookies are encrypted with an app HUKS AES-128-GCM key and a fresh 12-byte secure random nonce. Preferences stores only the version, nonce, and authenticated ciphertext. A legacy plaintext cookie is migrated once and then deleted.
- Clearing all local data deletes the encrypted session record and the HUKS key.

## Verification

- Build: `BUILD SUCCESSFUL in 15 s 458 ms`.
- HAP: `entry/build/default/outputs/default/entry-default-unsigned.hap`, 2732484 bytes.
- x86_64 emulator install, launch, and process check passed on `127.0.0.1:5557`.
- UI/runtime evidence: `evidence/phase-a-huks-runtime/`.
- Hilog evidence: `evidence/phase-a-huks-hilog/`; app-line FATAL=0 and ERROR=0.
- Empty validation: `evidence/phase-a-login-empty-validation/`, 2/2 assertions passed.
- Direct invalid login: `evidence/phase-a-invalid-login-direct-v3/`, 3/3 assertions passed and no slider/session appeared.

## Honest gates

- A valid student login, restart restoration, role detection, and authenticated Ehall data still require one manual no-echo credential entry. They remain `BLOCKED_EXTERNAL` until that run succeeds.
- The pure-Cangjie SDK TextInput has no password input type member. The current visual mask hides the field on screen, but the underlying TextInput value can be present in the accessibility tree while typing. Therefore no component-tree or screenshot capture is permitted while a real password is populated.
- No account, password, cookie, token, captcha payload, or payment QR value is retained in repository evidence.

## Next slice

Use the repaired session path to finish the complete timetable vertical slice: source-chain parity, week/day switching, course/exam/custom schedule layout, cache states, then x86_64 build/install/UI evidence. Live data checks remain gated on manual authentication while offline and error-state work continues.
