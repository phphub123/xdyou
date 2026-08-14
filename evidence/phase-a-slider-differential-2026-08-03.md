# Phase A slider differential, 2026-08-03

## Scope and data handling

- Compared the current Flutter slider implementation with the Cangjie port on the same host and network.
- The probe did not accept, read, print, or persist an account, password, cookie, image, signed payload, or response body.
- Only the final boolean result was emitted.

## Result

- An initial probe was invalid because it omitted the Flutter source's image-pixel to 280-canvas scaling; its result was discarded.
- The corrected probe mirrored `SliderCaptchaClientProvider.solveOffset`, AES signing, track generation, delays, six rounds, and neighboring deltas.
- Corrected Flutter-source result: `dart-source-auto-slider=ACCEPTED` in 10.4 seconds.
- The prior Cangjie build reached manual fallback under the same network, proving a port differential rather than an unavoidable manual IDS step.

## Corrective changes

`entry/src/main/cangjie/repository/auth/slider_captcha_solver.cj` now matches the Flutter image package and source behavior for:

- luminance coefficients: `0.299 R + 0.587 G + 0.114 B`;
- opaque-pixel test: alpha equals 255;
- conversion from image offset to the 280-wide canvas: floating-point scale followed by rounding.

## Build and launch

- `BUILD SUCCESSFUL in 2 min 33 s 536 ms`.
- HAP: `entry/build/default/outputs/default/entry-default-unsigned.hap`, 5,671,116 bytes.
- Installed successfully to x86_64 emulator `127.0.0.1:5557`.
- Cold launch succeeded with PID 21293.
- Target-process log inspection found no FATAL entry.

## Remaining gate

Real authentication remains `IN_PROGRESS` until a fresh manual credential entry confirms that automatic slider verification proceeds to the home page. Credentials are intentionally excluded from automation and evidence.
