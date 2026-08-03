# Phase 2 timetable acceptance

- Build: `assembleApp --no-daemon` completed with `BUILD SUCCESSFUL` on 2026-07-29.
- Artifact: `entry/build/default/outputs/default/entry-default-unsigned.hap`.
- Device: emulator `127.0.0.1:5557`; install, launch, screenshot and component-tree capture passed.
- Runtime evidence: `evidence/phase2-classtable-runtime/`; target-process hilog: `evidence/phase2-classtable-hilog/`.
- Real Ehall verification: `BLOCKED_EXTERNAL`. The existing real IDS flow is blocked by slider verification, so no authenticated cookie, API response, academic data, Android paired screenshot, or fake-success path was used.
- Implemented request boundary: real Ehall timetable endpoint, session-cookie gate, timeouts, HTTP/error handling, stdx JSON parsing and a scrollable day/course layout.
