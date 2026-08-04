# Dorm-water favorite-device completion evidence

Date: 2026-08-04

- Added the source-equivalent favorite-device add operation alongside the existing remove operation. It sends the real authenticated `/api/v1/dev/favo?did=...&remove=false` request and accepts only a bounded device-ID format.
- Added a logged-in page entry for manual device ID addition. The source QR scanner remains deferred pending a Scan Kit pure-Cangjie feasibility probe; the manual path does not simulate a scan or fabricate a favorite.
- Final x86_64 build: `BUILD SUCCESSFUL in 1 min 1 s 909 ms`.
- Runtime add/remove needs an independent SMS session. It remains `BLOCKED_EXTERNAL`; no device ID, token, phone number, captcha, or service response was recorded.
