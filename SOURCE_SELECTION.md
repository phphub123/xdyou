# 迁移最小源集说明

## 结论

Flutter 工程的 Android 目录不是业务源代码主体。XDYou 的真实业务逻辑、页面、状态、接口与模型都在 `lib/`，因此 `source/lib/` 必须完整保留，不能只拿 `android/` 给 Codex。

本最小集约 7.5 MB，保留 279 个 Dart 文件、约 4.9 万行 Dart。这里的“最小”是指满足最终功能等价所需的最小集合，不是只做登录页或演示版的 MVP。

## 必须保留

| 路径 | 用途 | 迁移方式 |
| --- | --- | --- |
| `lib/main.dart` | 初始化、登录态、主题、国际化、通知入口 | 映射为 `index.cj` + `main.cj` |
| `lib/controller/` | 页面状态与业务编排 | 同目录前缀迁为 `controller/*.cj` |
| `lib/model/` | DTO、枚举、会话状态、JSON 模型 | 同名 `.cj`；`*.g.dart` 作为序列化字段证据 |
| `lib/repository/` | 登录、Cookie、校园接口、缓存、通知、日历等 | 同名 `.cj`，优先 std/stdx 与 HarmonyOS Kit |
| `lib/page/` | 全部页面、组件、交互与布局 | 同路径前缀迁为 ArkUI 仓颉组件 |
| `lib/routing/` | 路由常量和页面映射 | 保留 `Routes`、路由常量和语义 |
| `lib/themes/` | 明暗主题与色彩种子 | 映射为仓颉主题模型 |
| `lib/external/ruisi_flutter/` | 睿思论坛完整功能 | 作为独立功能域迁移，不能当三方依赖删掉 |
| `lib/generated/`、`lib/bridge/` | 生成字段、桥接契约 | 不原样运行，但用于生成等价仓颉实现 |
| `assets/` | 实际被 `pubspec.yaml` 声明的图标、插画、三语文本、论坛表情 | 转入 HarmonyOS `resources`/`rawfile` |
| `pubspec.yaml`、`pubspec.lock` | 依赖、资产、版本和能力清单 | 生成依赖裁决表，不能直接复制 Flutter 包 |
| `reference/docs/` | 数据模型和状态管理设计 | 用于核对 DTO 和业务语义 |
| `reference/android/AndroidManifest.xml` | 权限、Activity、通知、桌面小组件能力 | 映射到 `module.json5` 与 HarmonyOS 能力 |
| `reference/android/widget/`、`model/` | Android 课程表桌面小组件 | 迁为 HarmonyOS 卡片/服务能力 |
| `reference/android/res/xml/`、`drawable/` | 网络策略、小组件配置与图标语义 | 作为配置和视觉参考 |

## 已排除

| 原目录/文件 | 排除理由 |
| --- | --- |
| `.flutter/` | Flutter SDK 子模块，不是应用业务代码 |
| `.github/`、`fastlane/`、`.vscode/` | CI、发布和编辑器配置，不参与仓颉业务实现 |
| `ios/`、`macos/`、`linux/`、`windows/` | 其他平台宿主壳；本次目标是 HarmonyOS |
| Android Gradle wrapper、大部分启动图和 launcher 密度资源 | Flutter/Android 构建专属，已有必要权限和小组件证据 |
| `blobs/` | 桌面平台 TensorFlow Lite 动态库，不适用于 HarmonyOS |
| `assets/guide/`、`assets/random/`、未声明的 art 素材 | 未被当前 `pubspec.yaml` 作为运行时资产声明 |
| 两个 `captcha-solver-*.tflite` | 在 `pubspec.yaml` 中已注释，当前版本未启用 |
| `tool/`、`tools/`、`pigeon_bridge` 生成工具链主体 | Flutter 代码生成/维护工具；仅保留桥接契约参考 |

## 命名保持规则

1. 目录前缀保持：`controller/model/repository/page/routing/themes/external` 不改语义。
2. 文件基名尽量保持：`classtable_session.dart` → `classtable_session.cj`。
3. 类、枚举、公开函数优先原名：`IDSSession`、`LoginWindow`、`Routes`、`loginEhall` 等不随意重命名。
4. Flutter Widget 可映射为仓颉 ArkUI Component，但保留业务类名；确因仓颉命名限制调整时写入 `migration/file-name-map.csv`。
5. `*.g.dart` 不机械生成同名空壳；把字段解析合并入主体模型或建 `*_codec.cj`，并在映射表中解释。
6. `main.dart` 因仓颉工程入口约束映射为 `index.cj`，同时用 `main.cj` 承载应用初始化，保留 `main` 前缀。

