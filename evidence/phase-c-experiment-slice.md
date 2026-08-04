# Phase C experiment slice evidence

Date: 2026-08-04

Implemented source-aligned Cangjie files for the experiment model, controller, physics repository, report repository, pixel-hash recognizer and page.

## Real-data boundaries

- Physics login first GETs the ASP.NET form, preserves dynamic hidden inputs, then posts the student account and independent physics password.
- The independent password is stored only as `SecureSessionCipher` HUKS-authenticated ciphertext; it is never logged or written to evidence.
- Schedule parsing reads the real `PhyEws/student/select.aspx` rows and classifies entries by current time.
- Score recognition reproduces the Flutter algorithm: decode the downloaded image as RGBA8888, scan 50x20 pixels, include RGB only when alpha is 255, compute unsigned 32-bit FNV-1a, and match the checked-in 15-label hash table.
- The report flow sends the source application's UniGUI login events and downloads each real score image. Unknown hashes remain `found=false` and retain the original URL; no score is inferred.
- Other-experiment UI keeps the genuine `sysj.xidian.edu.cn` IDS/OAuth dependency visible. Mock preview cannot supply a real IDS cookie, so it is `BLOCKED_EXTERNAL`, not an empty success.

## Verification

- RAG query failed with `OperationalError: unable to open database file`; complete packaged ImageKit decoding/PixelMap operation docs and Cangjie std time/regex/collection references were used instead.
- Hvigor dual-ABI build: initial `BUILD SUCCESSFUL in 4 min 30 s 121 ms`; final stable-ID rebuild `BUILD SUCCESSFUL in 4 min 5 s 348 ms`.
- HAP: `entry/build/default/outputs/default/entry-default-unsigned.hap`, 12,311,219 bytes.
- x86_64 install and `EntryAbility` launch passed on `127.0.0.1:5557`.
- `acceptance/runtime/2026-08-04-experiment-page-stable-id/` passed 4/4 assertions for both tabs, explicit state and IDS-dependent boundary.
- `evidence/runtime/2026-08-04-experiment-page-hilog/` reports zero application-line FATAL and ERROR entries.

## Open acceptance gates

- Real physics password and campus network are required to compare schedule count, teacher/reference fields and score-image labels with Flutter.
- Real IDS OAuth is required to implement and validate the full other-experiment 25-week timetable chain.
- Android/Flutter paired screenshots remain unavailable.
