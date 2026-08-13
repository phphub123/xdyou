# SMS verification UI alignment — 2026-08-13

## Scope

Aligned the existing Cangjie IDS SMS second-factor overlay in `entry/src/main/cangjie/page/login/login_page.cj` to `UI真实数据展示截图/验证码.png` while retaining the real `IDSReAuthSession` send, countdown, submit, cancel, validation, and credential-gated navigation logic.

## Adopted visual changes

- Added a full-screen `idsReAuthScrim` dim layer behind the non-dismissible card.
- Changed copy to the supplied Traditional Chinese strings: `短信二次認證`, `學校要求完成二次認證。請先獲取短信驗證碼，再輸入驗證碼繼續登錄。`, `短信驗證碼`, `獲取驗證碼`, `信任此設備`, the two-line device hint, `取消`, and `確定`.
- Changed the trust control from a switch to a square `ToggleType.Checkbox`.
- Added a floating label over the outlined code input using a Stack, preserving `idsReAuthCodeInput` and error coloring.
- Changed send-code to a transparent outlined primary action and changed the bottom action row to textual Cancel plus filled Confirm.
- Used the existing ThemePalette and explicit vp/percent units; no ArkTS boundary or authentication bypass was introduced.

## Verification

- Build command: `python .agents/skills/harmonyos-build-run-diagnose/tools/build_recovery.py --retry`
- Result: `BUILD SUCCESSFUL in 6 s 912 ms`
- HAP: `entry/build/default/outputs/default/entry-default-unsigned.hap`
- HAP SHA-256: `c264e32302fbb1ba7df2ff9ef202fbeca87d7e4db09fce24b039e37eb3727099`
- HAP size: `14656992 bytes`
- Emulator: `127.0.0.1:5555`
- Installation and foreground launch: passed, PID `15338`
- Final shell capture: `acceptance/runtime/2026-08-13-captcha-ui-final-shell/`
- Runtime log: `evidence/runtime/2026-08-13-captcha-ui-hilog/`; app-line FATAL count `0`.

A temporary in-memory `showReAuthDialog = true` preview was used to capture the modified dialog and was reverted before the final build. Preview capture: `acceptance/runtime/2026-08-13-captcha-ui-preview/`; it contains the expected dialog keys/text and checkbox. The final HAP was built with the normal credential-gated initial state (`showReAuthDialog = false`), so no fake authentication or SMS acceptance is claimed.

## Remaining boundary

Real account credentials, server-triggered re-authentication, SMS delivery, and one-time-code acceptance remain externally credential-gated. This evidence verifies the UI structure/build/launch boundary only, not end-to-end IDS authentication.
