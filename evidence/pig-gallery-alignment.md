# Pig gallery alignment and interaction evidence

- Date: 2026-08-04
- Reference: `UI截图/6.png`
- Source: `source/lib/page/pig/pig_page.dart`, `source/lib/repository/pighub_session.dart`
- Implementation: `entry/src/main/cangjie/aligned_home_page.cj`, `entry/src/main/cangjie/repository/pighub_session.cj`
- Real endpoint: `https://www.pighub.top/api/images?sort=0`

## Build and deployment

- `build.log` records `BUILD SUCCESSFUL in 6 s 985 ms`.
- Generated HAP: `entry/build/default/outputs/default/entry-default-unsigned.hap` (6,434,581 bytes, 2026-08-04 11:31:12).
- The HAP installed successfully on emulator `127.0.0.1:5555`; `EntryAbility` launched with PID 25113.

## UI and Change A Pig verification

- Scenario: `acceptance/scenarios/pig-alignment-change-final.json`.
- Runtime output: `acceptance/runtime/2026-08-04-pig-aligned-change-final/`.
- UI assertions: 4/4 PASS (title, real image, image title, clickable Change A Pig).
- Before click: title `猪猪我呀`; screenshot SHA-256 `d8fb2baf9ec801d6296b4b14c7b4fee38ce62232fe257cff55fc4e790b363edc`.
- After click: title `猪思考(猪撅猪)`; screenshot SHA-256 `faf39b62958a4e00778686dfe9abcfc5d5918100dc8ba0226dbcc45e77d36f16`.
- Visual inspection confirms the image changed together with the title and the Pig bottom-navigation item is the selected blue capsule.

## Runtime health

- Bounded log: `evidence/runtime/2026-08-04-pig-aligned-hilog/`.
- Target app lines: FATAL 0, ERROR 0, WARN 0; no target crash was observed.
