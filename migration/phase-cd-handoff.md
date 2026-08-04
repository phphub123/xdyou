# Phase C-D handoff — 2026-08-04

## Latest verified tree

- Branch: `main`.
- Dual ABI build passed; x86_64 HAP installed and launched on `127.0.0.1:5557`.
- Toolbox Web boundary passed 4/4 runtime assertions.
- Physics experiment / report-image boundary passed 4/4 runtime assertions without credentials.

## Implemented in this slice

- Seven toolbox destinations now have real ArkWeb loading, Web-history back, explicit list return, timeout, retry and visible error handling in `toolbox_web_page.cj`.
- Physics experiment has source-structured model/controller/repositories/page, encrypted independent password, dynamic ASP.NET login form parsing, schedule request and time grouping.
- Experiment score images use the real UniGUI report request chain and source-identical pixel FNV-1a hash recognition.
- Home experiment card opens the new page; every interactive experiment control has a stable ID.

## First unfinished independent slice

Implement `SysjSession` for other experiments: follow `xidian/test` redirects, reuse only a genuine persisted IDS cookie, complete the OAuth callback, request 25 weekly timetables, merge identical lab/teacher records and sort their time ranges. Do not change the settings page while the UI collaborator owns it.

## External gates

- Genuine IDS/Ehall OAuth, campus network and physics experiment credentials are unavailable to repository automation. Keep those acceptance rows `BLOCKED_EXTERNAL`.
- Never persist or log student credentials, cookies, tokens, score response bodies or score images.

## Evidence

- `evidence/toolbox-web-boundary.md`
- `evidence/phase-c-experiment-slice.md`
- `acceptance/runtime/2026-08-04-toolbox-web-boundary/`
- `acceptance/runtime/2026-08-04-experiment-page-stable-id/`
- `evidence/runtime/2026-08-04-experiment-page-hilog/`
