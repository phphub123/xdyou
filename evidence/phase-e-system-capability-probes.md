# Phase E system capability probes

SDK: HarmonyOS/Cangjie 6.1, compatible API 23. User authorized minimal ArkTS interoperation on 2026-07-31.

The direct Cangjie kit probes remain valid: SDK declarations contain no Cangjie NotificationKit, CalendarKit or FormKit dependency. The implementation therefore keeps the app shell and business code in Cangjie and uses `ohos.ark_interop.JSRuntime` only at the unavailable system boundary.

| Capability | Boundary | Result | Evidence |
| --- | --- | --- | --- |
| Course notification | Cangjie `JSRuntime.requireArkModule("@ohos.notificationManager")` | `IN_PROGRESS` | Bridge and settings test action compile; runtime publication awaits authenticated settings access. |
| System calendar synchronization | Cangjie permission API plus `JSRuntime.requireArkModule("@ohos.calendarManager")` | `IN_PROGRESS` | Permission declaration/request and real `addEvent` callback compile; emulator permission/write confirmation pending. |
| Desktop timetable card | ArkTS `FormExtensionAbility` is required; no Cangjie declaration exists | `BLOCKED_EXTERNAL` | Direct probe log is `evidence/phase-e-form-probe.log`; independent minimal extension still needs a build/runtime probe. |

Direct probe logs remain:

- `evidence/phase-e-notification-probe.log`
- `evidence/phase-e-calendar-probe.log`
- `evidence/phase-e-form-probe.log`

The notification and calendar bridges produced `BUILD SUCCESSFUL` HAPs before the runtime permission gate. No `.ets` business page, Flutter plugin, mock notification, fake calendar record or placeholder card was introduced. The first attempt to add an `.ets` runtime source was removed because it changed the pure-Cangjie module entry contract.

## Runtime permission reference

The packaged `cj-request-user-authorization.md`, `cj-apis-ability_access_ctrl.md`, and `cj-permissions-for-all-user.md` were read completely. The implementation declares `READ_CALENDAR` and `WRITE_CALENDAR`, requests both only from the user-triggered test action, and proceeds only when every result is granted.

## ArkWeb

The packaged `cj-web-page-loading-with-web-components.md` and ArkWeb `WebviewController` references for `loadUrl`, `canGoBack` and `goBack` were read. The seven source toolbox URLs use the pure-Cangjie `Web` component, page begin/end state and guarded back navigation.
