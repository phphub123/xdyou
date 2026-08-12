# Energy, library and campus-card live-data wiring — 2026-08-11

## Scope

The implementation follows `source_2.0` and the paired real-account screenshots. It contains no fixed account values, balance values, loan records, transaction rows, cookies or response bodies.

## Implemented request boundaries

- Energy: existing IDS session → energy OAuth code → `GetSignature` → fixed-protocol AES-128-CBC → user/node/meter/history endpoints.
- Library: existing IDS session → Chaoxing CAS → OPAC JWT → authenticated `/find/loanInfo/loanList`; public catalog search remains available on the second tab.
- Campus card: captures intermediate redirect cookies and OpenID, retains balance/QR requests, and queries transactions even when the separate overview endpoint fails.
- Campus home: uses controller results for electricity balance/read date, loan count, and campus-card balance instead of permanent loading labels.

## UI result

- Energy page now has the source-style electricity header, real balance/read date, history rows and the existing independent air-conditioner query.
- Library opens on the source-style borrow-status tab with due-state cards and summary, while catalog search is retained.
- Campus-card page uses the source title, previous-calendar-month range and real merchant/amount/time rows.

## Verification

- `git diff --check`: pass before handoff.
- x86_64 direct Cangjie compilation: `cjpm build success` twice.
- Full HAP packaging/runtime: pending local DevEco/Hvigor build because the managed sandbox denied creation of Hvigor's external cache symlink after the approval channel disconnected.
- Live values remain `IN_PROGRESS`/`BLOCKED_EXTERNAL` until the newly built HAP is run with the user's existing authenticated session and appropriate campus-network reachability.