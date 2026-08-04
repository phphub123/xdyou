# Phase D Sysj other-experiment slice evidence

Date: 2026-08-04

## Implemented boundary

- Added `repository/xidian_ids/sysj_session.cj`, porting the Flutter Sysj entry chain without manufacturing a session: it requires the HUKS-restored IDS Cookie, follows redirect responses with merged in-memory cookies, recognizes an expired IDS login page, completes the Sysj OAuth callback, and posts the short-lived callback credential to the Sysj login endpoint.
- The session requests `StudentCurrWeekTimetable` for weeks 1–25. It validates the second timetable table and all seven dates, recognizes only the source `course`/`lab`/`teacher` markers, merges contiguous periods and records with equal experiment/lab/teacher fields, then orders groups by their first start time.
- `ExperimentController` now has separate physics and other-experiment request guards. `ExperimentPage` invokes the real other-experiment chain, preserves stable IDs, and renders authentic loading, empty and failure states. No static success or timetable data was added.

## Verification

- Required local-doc RAG check passed: 649 documents / 12,575 sections. NetworkKit references read: `docs/API/NetworkKit/cj-apis-net-http.md#func-request-string-httprequestoptions-asynccallback` and `#class-httprequestoptions`.
- Initial build was stopped and diagnosed at the first stable error: installed DevEco SDK lacked `targetSdkVersion 6.1.1(24)`. The root profile now targets installed compatible SDK `6.1.0(23)`; the module keeps only the user-required `x86_64` ABI filter.
- Final x86_64 build: `BUILD SUCCESSFUL in 1 min 30 s 590 ms`.
- HAP: `entry/build/default/outputs/default/entry-default-unsigned.hap`.
- x86_64 emulator: `127.0.0.1:5557`; unsigned HAP installed and launched as `io.github.benderblog.traintime_pda.harmonyos/EntryAbility`, PID `16982`.
- Scenario: `acceptance/scenarios/experiment-page.json`; output: `acceptance/runtime/2026-08-04-sysj-other-experiment-x86_64/`; all 4/4 assertions passed. The post-refresh component tree shows the actual missing-session error `其他实验需要真实 IDS 会话，请先完成正式登录。`, so no fake session or empty-success result was accepted.
- Bounded target hilog is at `evidence/runtime/2026-08-04-sysj-other-experiment-x86_64-hilog/`. It contains no target-app FATAL. Its one matching ERROR is an emulator scene-category diagnostic (`isSupportFullScreenInForceSplit`) from the system compositor, not an app exception or process failure.

## Acceptance state

`C11` is `BLOCKED_EXTERNAL`, not PASS. A manual genuine IDS login and campus-network Sysj access are still required to verify live OAuth redirects, all 25 response bodies, parsed fields, ordering and a Flutter comparison. Credentials, Cookies, temporary OAuth data, response HTML and score images were not saved to repository evidence.

## Deliberately deferred parity

- Flutter's local JSON cache and semester-change invalidation are not implemented in this narrow network slice.
- The Cangjie home arrangement does not yet consume other-experiment today/tomorrow entries.
- The source's 13-period loop exceeds its 11-period time mapping; the Cangjie parser deliberately confines mapping to the available 11 periods instead of indexing past the time list.
