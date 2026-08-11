# IDS login POST redirect 405 fix — 2026-08-11

## Symptom

After credential submission the login page displayed `IDS login failed with HTTP 405` and the
raw server body `Request method 'POST' not supported`.

## Root cause and repair

`kit.NetworkKit` automatically follows HTTP redirects, while the SDK 23 Cangjie
`HttpRequestOptions` surface has no redirect-disable option. The IDS credential POST could
therefore be replayed at the redirected Ehall route, which only accepts GET. The final callback
saw Ehall's 405 response and previously labelled it as an IDS failure.

The repair in `entry/src/main/cangjie/repository/ids_session.cj`:

- percent-encodes the nested IDS `service` query parameter;
- captures and merges `Set-Cookie` values from every response header event in the automatic
  redirect chain;
- recognizes only the specific HTTP 405 / POST-not-supported signature;
- resumes the Ehall landing flow with an explicit GET and the merged session cookies;
- preserves the existing re-authentication-page detection and error handling on the GET path;
- logs no credential or cookie values.

## Verification

- `python .agents/skills/harmonyos-build-run-diagnose/tools/build_recovery.py --retry`
- `SyncCangjieResource`: `BUILD SUCCESSFUL in 824 ms`
- `assembleHap`: `BUILD SUCCESSFUL in 21 s 96 ms`
- HAP: `entry/build/default/outputs/default/entry-default-unsigned.hap` (about 13 MB)
- `git diff --check`: passed
- Installed successfully on emulator `127.0.0.1:5555`.
- `EntryAbility` launched and target process was confirmed as PID `9639`.
- Login-page screenshot, component tree, and summary are under
  `evidence/login-redirect-fix-2026-08-11/runtime/`.
- The bounded baseline hilog summary reports zero bundle-name app-line FATAL, ERROR, and WARN.

## Remaining runtime gate

Install, launch, foreground UI, and target-process baseline checks pass. Replaying the repaired
405 branch remains `BLOCKED_EXTERNAL` because it requires a genuine IDS password/captcha flow.
No credential, password, full cookie, or manufactured authenticated session was recorded.
