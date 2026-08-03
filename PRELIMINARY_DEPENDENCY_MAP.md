# Flutter 依赖初步裁决方向

这不是最终 API 结论。Codex 必须使用 `cangjie-core-reference` 与 `cangjie-harmonyos-knowledge` 查询当前 SDK 6.1.0(23) 的仓颉签名后，填写 `migration/dependency-map.csv`。下表用于防止漏功能。

| Flutter 依赖/能力 | 原用途 | 仓颉迁移方向 |
| --- | --- | --- |
| `signals`、`provider`、`get_it` | 响应式状态、依赖注入 | ArkUI 仓颉状态宏 + 明确的 controller/service 装配 |
| `dio`、`dio_cookie_manager`、`cookie_jar` | HTTP、拦截器、Cookie 会话 | 查询仓颉 HTTP/TLS API；实现同语义 Session、CookieJar 和重定向 |
| `crypto`、`pointycastle`、`encrypter_plus` | 摘要、加解密 | 优先查 std/stdx crypto；系统密钥能力需查本地 HarmonyOS RAG |
| `shared_preferences` | 账号设置、主题、学期和缓存键值 | 查询 HarmonyOS 仓颉持久化/首选项 API；保持原 key |
| `path_provider`、`file_picker` | 应用目录和文件选择 | 查询 Core File Kit/文件选择能力 |
| `json_annotation`、`json_serializable` | DTO JSON 映射 | `stdx.encoding.json` 或已检索到的当前 SDK JSON API；显式字段映射 |
| `html`、`charset_converter` | 校园网页解析和编码转换 | 保留解析语义；优先 std/stdx，缺失时移植最小解析器，禁止删接口 |
| `flutter_i18n`、`intl`、`timezone`、`time` | 三语、日期格式、时区 | HarmonyOS 资源国际化 + 仓颉时间/时区 API |
| `flex_color_scheme`、图标/UI 包 | Material 主题与 UI | ArkUI 仓颉组件、资源和自建主题 token；不保留 Flutter 运行时 |
| `cached_network_image` | 网络图与缓存 | 查询 Image/网络/文件缓存能力，保留占位和错误态 |
| `infinite_scroll_pagination` | 论坛分页 | 仓颉状态 + 分页仓储 + ArkUI 列表，保持加载更多语义 |
| `url_launcher`、`share_plus` | 外链和分享 | 查询 HarmonyOS 跳转/分享能力 |
| `device_calendar_plus` | 课程写入系统日历 | 查询日历 Kit；保持新增、更新、删除和权限处理 |
| `flutter_local_notifications` | 上课提醒 | 查询通知 Kit；保留调度、取消、点击跳转和权限 |
| `home_widget` | 课程表桌面小组件 | 查询 HarmonyOS 卡片/服务能力，结合 Android widget 参考实现 |
| `permission_handler` | 通知、日历、文件权限 | 映射到 `module.json5` 与运行时授权流程 |
| `flutter_zxing` | 二维码 | 查询仓颉可用二维码能力；无直接能力时提交有证据的最小方案 |
| `flutter_html` | HTML 内容渲染 | 优先仓颉 ArkUI 结构化渲染；Web 能力须先查询本地 RAG |
| `restart_app`、`package_info_plus`、`device_info_plus` | 重启、版本、设备信息 | 查询对应 HarmonyOS 仓颉系统 API |
| `catcher_2`、`talker_*` | 错误捕获和日志 | 仓颉异常边界 + Hilog，禁止静默吞异常 |

对每个依赖最终只能选择以下一种裁决：

- `DIRECT_STDLIB`
- `DIRECT_HARMONY_KIT`
- `REWRITE`
- `RESOURCE_REPLACEMENT`
- `MINIMAL_INTEROP_PROPOSED`

`DROP` 不适用于验收矩阵中的 Must 功能。

