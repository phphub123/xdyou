# Phase C campus-card slice

Date: 2026-08-04
Branch: `main`

## Implemented source-aligned chain

- Model: balance overview and paid-record fields (`place`, `date`, `money`).
- Repository: genuine IDS-session gate, campus-card SSO redirect chain, OpenID extraction, cookie merge, balance parsing, date-range transaction JSON parsing, virtual-card id discovery and real base64 QR image extraction.
- Controller: non-reentrant overview, transaction and QR actions.
- Page: current-month date range, balance, transaction summary/list, loading/empty/error states, refresh, sensitive QR warning, QR refresh/close and in-memory payload clearing on close/disappear.
- Navigation: stable `homeSchoolCard` entry from the existing five-tab campus page.

No account, cookie, OpenID, response body or QR payload is logged or written to repository evidence. The automated scenario deliberately does not open the QR dialog.

## Knowledge and build repair

- `cjdocs.py doctor/query` reproduced `OperationalError: unable to open database file`; raw packaged NetworkKit, TextInput and ArkUI documentation was used as the documented fallback.
- Stable compiler errors repaired: enum `RequestMethod` has no `==`; `std.collection.Stack` collided with ArkUI `Stack`; `Row.minHeight` is unavailable in SDK 6.1.
- Final merged-tree dual-ABI build: `BUILD SUCCESSFUL in 3 min 35 s 945 ms`.
- HAP: `entry/build/default/outputs/default/entry-default-unsigned.hap`.

## Runtime evidence

- Emulator: `127.0.0.1:5557`.
- Install, foreground launch and target PID confirmation passed.
- Offline/mock boundary scenario: `evidence/runtime/2026-08-04-school-card-rebased-final/interaction_report.md` (4/4 PASS).
- Assertions cover page rendering, transaction query, payment-QR action and the exact real-session error gate.
- Bounded hilog: `evidence/runtime/2026-08-04-school-card-rebased-final/hilog/hilog_summary.md`; no target-process fatal is present. The single bundle-matching error is a SceneBoard feature-map system-process message.

## Acceptance boundary

Implementation, dual-ABI build and unauthenticated error behavior pass. Genuine balance, records, QR freshness and Flutter-paired output remain `BLOCKED_EXTERNAL` until a valid IDS/campus-card SSO session is available.
