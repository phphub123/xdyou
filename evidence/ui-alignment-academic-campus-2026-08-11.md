# Academic and campus UI alignment (2026-08-11)

- Scope: score, examination, attendance, empty-classroom and class-table pages.
- Reference: paired source/HarmonyOS captures under `UI真实数据展示截图/` and the six comparison images supplied in the task.
- Build: the single-emulator-ABI Hvigor build completed with `BUILD SUCCESSFUL in 1 min 29 s 57 ms`; HAP: `entry/build/default/outputs/default/app/entry-default.hap`.
- Score: the live 36-record chain is retained. The page now has the source-style back/title/refresh header, search, working semester/type filters, blue-header result cards and a compact three-column body. Runtime tree evidence includes both filters, the summary and seven initially visible real cards.
- Examination: the live 18-record chain and chronological grouping are retained. Runtime evidence reached all three groups: 0 upcoming, 10 unarranged and 8 finished; the top tree contains six visible unarranged cards and the scrolled tree contains the finished section/card.
- Attendance: the header is aligned to `考勤查询`; redundant loaded-count copy was removed while loading/error states remain. Learning SSO completed after about 25 seconds and rendered 57 real course rows; eight were present in the captured viewport tree.
- Empty classroom: the real 11-period matrix is retained. Building selection now opens a non-looping `TextPicker` wheel with cancel/confirm instead of cycling one building per tap. Runtime tree confirms the picker dialog, wheel and both actions.
- Class table: the live 34-arrangement chain is retained. The seven-day grid now includes the vertical 1-8 period/time axis and positions cards by start/stop period in a 512vp schedule canvas. Runtime tree contains 28 course-card nodes after loading and the unarranged section.
- Shared header: all five pages use `PageHeader`, with a 38vp back control, 22vp medium title and 64x36vp refresh control.
- Runtime evidence: `acceptance/runtime/2026-08-11-ui-alignment/`; bounded log evidence: `evidence/runtime/2026-08-11-ui-alignment-hilog/`.
- The target remained alive and no target-process crash was observed. Two bundle-name ERROR lines are SceneBoard/launcher feature-map diagnostics, not application faults.
- Status remains `IN_PROGRESS`: this pass is rough alignment and functional-control acceptance, not Phase F masked SSIM or <=8vp pixel equivalence.
- No response body, Cookie, account, password, token or QR content was written to evidence.
