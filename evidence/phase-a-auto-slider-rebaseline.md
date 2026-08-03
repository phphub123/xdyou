# IDS automatic slider rebaseline — 2026-08-03

## Source behavior

The Flutter login always opens the IDS slider before posting credentials. `SliderCaptchaClientProvider.solve()` performs up to six image challenges and seven neighboring offsets per challenge; the manual page is only its fallback. Therefore the usual source UI appears to be account/password-only when the invisible solver succeeds.

## Corrections made

- Login order is now login form → invisible slider → credential POST.
- Added ImageKit decoding and source-aligned NCC offset matching.
- Removed the trailing 16-byte AES key before decoding the small image.
- Fixed captcha AES plaintext from an incorrect 80-character prefix to the source-aligned 64-character nonce; the final 16 characters are IV only.
- Matched the Flutter sigmoid trajectory, point count, neighboring offsets, and per-track delay.
- Made `errorCode` parsing insensitive to JSON whitespace/string representation.
- Manual slider remains only after all invisible attempts fail.

## Verification

- Latest build: `BUILD SUCCESSFUL in 2 min 32 s 839 ms`.
- HAP: `entry/build/default/outputs/default/entry-default-unsigned.hap`, 5,671,100 bytes.
- Install/cold launch passed; final PID 31869.
- Clean login UI: `evidence/phase-a-auto-slider-final-clean/`.
- Target hilog: `evidence/phase-a-auto-slider-final-hilog/`; no app FATAL reported.
- Two-second synthetic probe proved the solver no longer falls into the manual page immediately after real delay placement.
- The complete synthetic attempt still reached manual fallback after IDS rejected every automatic attempt.
- An independent ephemeral reference implementation of the Flutter algorithm, using no account and persisting no image/cookie/payload, was also rejected by the current IDS endpoint.

## Acceptance boundary

Build/runtime and the corrected source-aligned flow are verified. Current server acceptance and genuine account redirect remain `BLOCKED_EXTERNAL`; no cookie or success state was fabricated. A real-account retry must be performed only in the emulator and must not be screenshotted with credentials visible.
