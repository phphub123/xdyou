# Campus query live-data verification (2026-08-11)

- Target: `127.0.0.1:5557`, bundle `io.github.benderblog.traintime_pda.harmonyos`, single emulator ABI.
- Build: `BUILD SUCCESSFUL in 1 min 21 s 333 ms`; HAP installed with `hdc install -r` and cold-launched successfully.
- Empty classroom: current semester/building chain automatically loaded 12 real rooms and rendered the 11-period matrix. Evidence: `acceptance/runtime/2026-08-11-campus-query-live/empty-classroom/`.
- Class table: current semester chain loaded 34 real arrangements, rendered 14 visible week cards and reported 3 courses without arranged time. Evidence: `acceptance/runtime/2026-08-11-campus-query-live/classtable/`.
- Attendance: Learning SSO succeeded. Semester `20261` returned an authentic empty table; fallback over 29 server semester options reached `semesternum=0` and parsed 57 real course rows. Four cards are visible in the initial viewport. Evidence: `acceptance/runtime/2026-08-11-campus-query-live/attendance/`.
- Attendance detail remains incomplete: the course-list page returned no `myde_course_item` entries, so the attendance rows cannot currently be joined to Chaoxing `courseId`/`clazzId`; detail requests therefore show the explicit missing-identifier error instead of fabricated data.
- UI was compared with `UI真实数据展示截图/空闲教室.png`, `考勤查询.png`, and `日程表.png`. This is preliminary alignment only, not Phase F pixel-equivalence PASS.
- No response body, cookie, account, password, token, or QR content was persisted in evidence.
