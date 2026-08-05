# Runtime, UI, and hilog Diagnosis

> 示例中的 `<target>` 来自层叠配置 [device].target（真机 USB 单设备可省略 -t）。

## Foreground Validation

After launch or capture, verify the app reached the foreground:

```powershell
& "C:\Program Files\Huawei\DevEco Studio\sdk\default\openharmony\toolchains\hdc.exe" -t <target> shell aa dump -a
```

Accept foreground evidence such as `state #FOREGROUND` or `app state #FOREGROUND` for the target bundle.

If capture shows launcher or desktop:

```powershell
& "C:\Program Files\Huawei\DevEco Studio\sdk\default\openharmony\toolchains\hdc.exe" -t <target> shell aa start -a <abilityName> -b <bundleName>
Start-Sleep 2
python <harmonyos-build-run-diagnose-skill>/tools/ui_capture.py --project <project> --bundle <bundleName> --ability <abilityName> --no-launch --out <out>
```

## UI Assertion Rules

- Assert business keys/text, not status bar or window-manager nodes.
- Prefer `key` targets for interactions and state checks.
- Use page diffs only as supporting evidence; time, battery, and system overlays can change.
- Conditional controls must be asserted only after the action that should create them. For example, empty-state text may not exist before clearing a list.
- If a business assertion fails, mark validation failed even if screenshot and layout capture succeeded.
- For text input through `uitest`, use `uiInput inputText <x> <y> <text>`. If the command prints usage or parameter errors, treat the interaction step as failed.
- After text input, the soft keyboard can resize the app window and remove lower controls from the accessibility tree. Add a `back` step, use `hide_keyboard: true` on the input step, or scroll before asserting controls below the keyboard.

## hilog Triage

Read `hilog_summary.md` first.

Priority:

1. Target bundle/process FATAL or ERROR.
2. Crash stack.
3. Ability not found or launch failure.
4. Permission, resource, or SysCap errors.
5. System service noise.

Do not treat every full-system ERROR line as an app bug. If business UI assertions pass and hilog contains only unrelated system noise, report that no fatal target-app runtime error was found.
