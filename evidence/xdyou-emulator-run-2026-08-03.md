# XDYOU emulator run — 2026-08-03

- App label: `XDYOU` in AppScope `app_name` and EntryAbility label resources.
- Build: `BUILD SUCCESSFUL in 18 s 620 ms`.
- HAP: `entry/build/default/outputs/default/entry-default-unsigned.hap`.
- Emulator target: `127.0.0.1:5555` (x86_64).
- Install: `install bundle successfully`.
- Launch: `EntryAbility` started and bundle PID `30985` confirmed.
- UI: `evidence/runtime/2026-08-03-xdyou-launch/screenshot.png` and `layout.json`; the target window contains text `XDYOU` and key `loginLogo`.
- Hilog: `evidence/runtime/2026-08-03-xdyou-hilog/hilog_summary.md`; target app-line FATAL=0 and ERROR=0 during the bounded capture.

The initial baseline failed because `entry/cjpm.toml` still referenced Windows stdx paths. Both aarch64 and x86_64 OHOS dependency paths were corrected to the installed macOS host locations before the successful build.
