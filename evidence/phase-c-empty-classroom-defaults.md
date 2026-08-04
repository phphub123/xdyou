# Empty-classroom default usability evidence

Date: 2026-08-04

- Replaced the stale hardcoded date/semester defaults with the current local date and a date-derived academic-term default.
- Building data now loads automatically when the page opens; loaded buildings render as selectable stable-ID buttons while manual entry remains available.
- x86_64 rebuild passed: `BUILD SUCCESSFUL in 48 s 353 ms`.
- `acceptance/scenarios/empty-classroom-defaults.json` passed 3/3 on emulator `127.0.0.1:5557`, foreground PID 4488. Evidence: `acceptance/runtime/2026-08-04-empty-classroom-defaults-x86_64/`.
- Live building and room results remain `BLOCKED_EXTERNAL` because their Ehall requests require a genuine IDS session; no room data was fabricated.
