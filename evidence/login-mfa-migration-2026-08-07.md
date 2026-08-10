## 2026-08-07 后台登录调整

根据用户要求，登录流程不再跳转或展开 IDS 官网：

- 移除了登录提交后展示官方 ArkWeb 页面的逻辑；登录页面不展示滑块。
- `LoginViewModel` 现在直接按 Python/Dart 顺序在后台请求登录页、解析隐藏字段、注册指纹、请求滑块、ImageKit NCC 自动计算位移、生成轨迹、调用滑块验证接口，再提交加密账号密码。
- 后台收到 IDS 的二次认证重定向后，创建 `IDSReAuthSession`；界面只显示应用内短信验证码弹窗。
- 短信切换、发送、倒计时、验证码提交和最终登录请求均通过 NetworkKit 后台完成。
- 真实账号密码、滑块服务器响应和短信验证码未在本次环境中使用，端到端真实登录保持外部凭据门禁。

## 构建安装证据

- 命令：`python .agents/skills/harmonyos-build-run-diagnose/tools/build_recovery.py --retry`
- 结果：`BUILD SUCCESSFUL in 6 s 608 ms`
- HAP：`entry/build/default/outputs/default/entry-default-unsigned.hap`
- SHA-256：`1166ddc2f1b68d03a86f3200c4143441dd3e97acd6181855b8b01ea3b695f1a6`
- 模拟器：`127.0.0.1:5555`
- 安装成功，最新进程 PID：`27644`
- 基础登录场景：3/3 通过
- UI 产物：`acceptance/runtime/2026-08-07-login-backend-only/`
- 日志产物：`evidence/runtime/2026-08-07-login-backend-only-hilog/`


## 迁移范围

- 源账号密码入口：`source_2.0/lib/page/login/login_window.dart`
- 源二次认证弹窗：`source_2.0/lib/page/login/ids_reauth_dialog.dart`
- 源二次认证协议：`source_2.0/lib/repository/ids_session/ids_auth_protocol.dart`
- 源二次认证请求链：`source_2.0/lib/repository/ids_session/ids_reauth_client.dart`
- 目标实现：`entry/src/main/cangjie/page/login/login_page.cj`

## 已实现

1. 保留现有自定义仓颉账号、密码输入与密码可见性控制，通过隐藏 ArkWeb 提交官方 IDS 表单。
2. 监听页面导航，识别 `/authserver/reAuthCheck/reAuthLoginView.do` 后显示不可点背景关闭的短信二次认证叠层。
3. 弹层包含验证码输入、获取/重发验证码、服务端倒计时、脱敏手机号提示、错误提示、信任设备开关、取消和确认按钮。
4. 获取验证码前调用 `changeReAuthType.do` 切换短信类型，然后调用 `getDynamicCodeByReauth.do`。
5. 确认时调用 `reAuthSubmit.do`，区分 `reAuth_success`、`reAuth_failed`、`reAuth_unauthorized`，成功后继续原 service 登录。
6. 密码与验证码仅存在组件内存和 ArkWeb JavaScript 调用中；密码在初次提交后清空，验证码在关闭、拒绝或完成后清空，均不写入证据或普通持久化。

7. 修复账号密码提交后无限 `Working...`：每 2 秒检查官方 IDS DOM；检测到滑块立即把同一个 ArkWeb 展开为全屏供用户操作，12 秒仍未跳转也会展开并显示服务端提示；完成滑块后继续识别二次认证 URL 并切换到短信弹窗。

## 构建证据

- 命令：`python .agents/skills/harmonyos-build-run-diagnose/tools/build_recovery.py --retry`
- 结果：`BUILD SUCCESSFUL in 6 s 150 ms`
- HAP：`entry/build/default/outputs/default/entry-default-unsigned.hap`
- SHA-256：`12fde5a4967ab22679042d783edf57f5a30a9c07a44356a87cb3a4e81cc3629a`

## 运行证据

- 设备：`127.0.0.1:5555`
- Bundle：`io.github.benderblog.traintime_pda.harmonyos`
- Ability：`EntryAbility`
- 最终安装启动 PID：`327`
- UI 场景：`acceptance/scenarios/login-validation-2026-08-07.json`
- 产物：`acceptance/runtime/2026-08-07-login-mfa-final-v2/`
- 断言：3/3 PASS（账号输入、密码输入、空账号校验）
- 日志：`evidence/runtime/2026-08-07-login-mfa-final-v2-hilog/`
- 目标应用行：未发现 FATAL；2 条 ERROR 和 46 条 WARN 为系统/窗口生命周期诊断，未对应应用崩溃；应用进程保持可启动。

## 外部阻塞

真实账号密码、服务端是否触发短信二次认证、短信实际送达、错误验证码拒绝、挑战过期和正确验证码完成登录，都需要用户的合法 IDS 凭据及一次性验证码。未制造、持久化或绕过这些凭据，因此相关验收状态保持 `IN_PROGRESS` / `BLOCKED_EXTERNAL`，不宣称端到端 PASS。
