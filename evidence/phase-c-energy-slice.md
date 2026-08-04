# Energy service slice evidence

Date: 2026-08-04

## Implemented scope

- Added a pure-Cangjie energy vertical slice: air-conditioner IMEI model, NetworkKit session, controller and `EnergyPage`.
- The source-aligned independent endpoint is `https://gxkt.juhaolian.cn/api/device/direct/state?imei=...`. The IMEI is format-validated before network traffic, remains in page memory only, and is never persisted or logged.
- Electricity and water are not fabricated: the page explicitly states that they require a genuine IDS session and campus network. No fake balance, meter reading or cache was introduced.
- The aligned campus energy card now opens the new page through the existing Cangjie home shell and stable `homeEnergyInfo` ID.

## Verification

- First x86_64 build exposed three Cangjie issues (missing regex/convert imports and invalid timestamp construction); the first stable compiler blocks were repaired using the existing Cangjie std time/regex/convert conventions.
- Final build: `BUILD SUCCESSFUL in 47 s 681 ms`.
- HAP installed and launched on x86_64 emulator `127.0.0.1:5557`; target process PID `21096` was confirmed.
- `acceptance/scenarios/energy-page.json` passed 3/3 assertions. The capture is at `acceptance/runtime/2026-08-04-energy-x86_64/` and covers the campus-data boundary, the IMEI entry control and the explicit invalid-IMEI error.
- Bounded hilog is at `evidence/runtime/2026-08-04-energy-x86_64-hilog/`. No target-app FATAL occurred. The one target-name ERROR is the known emulator SCB `featureMap` diagnostic, not an application exception or process exit.

## Remaining acceptance gates

- C12 remains `BLOCKED_EXTERNAL`: electricity/water OAuth, meter history and Flutter data comparison require a genuine IDS session and campus network.
- Air-conditioner live device data needs a user-supplied valid IMEI; only its input validation and real request path were exercised here.
