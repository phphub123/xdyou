# XDYou 仓颉 HarmonyOS 工程最小集项目结构说明

> 说明对象：`C:\Users\21768\Desktop\xdyou_cangjie`
>
> 检查日期：2026-08-18
>
> 工程形态：DevEco Studio Stage 模型、单 `entry` 模块、纯仓颉业务与 ArkUI 界面

## 1. 工程概况

该目录是从 XDYou 主工作区抽取出的可独立打开、构建和运行的 HarmonyOS 工程。核心业务位于 `entry/src/main/cangjie/`，资源位于 `entry/src/main/resources/`，应用级配置位于 `AppScope/`。

当前关键配置如下：

| 项目 | 当前值 |
| --- | --- |
| Bundle Name | `io.github.benderblog.traintime_pda.harmonyos` |
| 应用版本 | `1.0.0`，versionCode `1000000` |
| 模块 | `entry` |
| Ability | `EntryAbility` / `MainAbility` |
| SDK | target/compatible `6.1.0(23)` |
| 仓颉编译器 | `1.1.3` |
| 仓颉包名 | `ohos_app_cangjie_entry` |
| 当前模块 ABI | `x86_64`，面向模拟器 |
| 声明权限 | 网络、读取日历、写入日历 |
| 仓颉源码数量 | 88 个 `.cj` 文件 |
| 模块资源数量 | 43 个文件 |

## 2. 顶层目录结构

```text
xdyou_cangjie/
├─ AppScope/                    # 应用级配置、名称和桌面图标
├─ entry/                       # 主业务模块
│  ├─ src/main/cangjie/         # 仓颉源码
│  ├─ src/main/resources/       # 模块资源
│  ├─ src/main/module.json5     # Ability、权限和设备类型配置
│  ├─ build-profile.json5       # entry 模块构建及 ABI 配置
│  ├─ cjpm.toml                 # 仓颉包、编译目标和 stdx 路径
│  ├─ cjpm.lock                 # 仓颉依赖锁定文件
│  ├─ oh-package.json5          # entry 模块 OHPM 配置
│  └─ hvigorfile.ts             # entry 模块 Hvigor 入口
├─ hvigor/hvigor-config.json5   # Hvigor 配置
├─ build-profile.json5          # 应用产品、SDK 和模块清单
├─ oh-package.json5             # 根 OHPM 配置
├─ oh-package-lock.json5        # 根依赖锁定文件
├─ hvigorfile.ts                # 根构建脚本入口
├─ code-linter.json5            # 代码检查配置
└─ .gitignore                   # 构建缓存和 IDE 文件忽略规则
```

## 3. 应用启动链

```text
HarmonyOS 启动应用
  → module_entry_entry.cj 注册 MyAbilityStage
  → ability_mainability_entry.cj 注册 EntryAbility
  → MainAbility.onCreate()
  → 初始化 AppContext
  → MainAbility.onWindowStageCreate()
  → 初始化 AppTheme
  → windowStage.loadContent("LoginWindow")
  → LoginWindow 恢复登录态或展示登录页
  → AlignedHomePage 及各业务页面
```

相关文件：

| 文件 | 作用 |
| --- | --- |
| `ability_stage.cj` | 定义应用模块的 `MyAbilityStage` 生命周期。 |
| `main_ability.cj` | 定义 `MainAbility`，初始化上下文、主题并加载根页面。 |
| `ability_mainability_entry.cj` | 将 `EntryAbility` 注册到 `MainAbility`。 |
| `module_entry_entry.cj` | 注册 `entry` 模块的 AbilityStage。 |
| `common/app_context.cj` | 保存并向仓颉业务层提供 HarmonyOS Context。 |
| `page/login/login_page.cj` | `@Entry` 根组件 `LoginWindow`，负责登录态与首页切换。 |

`ability_mainability_entry.cj` 和 `module_entry_entry.cj` 属于注册胶水文件，已被 `.gitignore` 规则标记为可生成文件，不建议手工修改。

## 4. 仓颉源码分层

```text
entry/src/main/cangjie/
├─ common/          # 全局上下文等公共基础设施
├─ components/      # 跨页面复用的 ArkUI 组件
├─ controller/      # 页面状态、业务编排和 Repository 调用
├─ external/        # 日历等系统能力封装
├─ model/           # 按业务域划分的数据模型
├─ page/            # 页面与 ArkUI 组件
├─ repository/      # 网络、认证、存储和业务数据访问
├─ themes/          # 主题、颜色和显示偏好
└─ *.cj             # Ability、Stage 和模块注册入口
```

推荐依赖方向为：

```text
page → controller → repository → model
  │          │            │
  ├──── components        └─ HarmonyOS/网络/存储 API
  └──── themes/common
```

- `page/` 不直接保存网络协议细节。
- `controller/` 把异步结果转换为页面需要的状态。
- `repository/` 负责真实接口、Cookie、加密、本地存储和响应解析。
- `model/` 只表达业务数据结构，避免依赖 UI。
- `model/package.cj`、`repository/package.cj` 和 `page/package.cj` 是跨子包统一导出的门面文件。

## 5. 主要源码目录

### 5.1 公共组件

| 路径 | 内容 |
| --- | --- |
| `components/page_header.cj` | 页面标题栏、刷新动作和搜索框。 |
| `components/service_auth_web.cj` | 业务系统 Web/SSO 授权组件。 |
| `components/single_date_calendar_dialog.cj` | 可复用的单日期日历对话框。 |
| `themes/app_theme.cj` | 应用主题初始化、调色板和显示偏好。 |
| `external/system_capability_bridge.cj` | 系统能力调用边界，如日历同步。 |

### 5.2 业务模块对应关系

| 业务 | 页面 | Controller | Model | Repository |
| --- | --- | --- | --- | --- |
| 登录与会话 | `page/login/` | `login_controller.cj` | `model/auth/` | `repository/auth/` |
| 校园首页 | `page/homepage/` | 调用多个业务 Controller | 各业务模型 | 各业务 Repository |
| 课表 | `page/classtable/` | `classtable_controller.cj` | `model/classtable/` | `repository/classtable/` |
| 成绩 | `page/score/` | `score_controller.cj` | `model/score/` | `repository/academic/` |
| 考试 | `page/exam/` | `exam_controller.cj` | `model/exam/` | `repository/academic/` |
| 空闲教室 | `page/empty_classroom/` | `empty_classroom_controller.cj` | `model/empty_classroom/` | `repository/empty_classroom/` |
| 考勤 | `page/class_attendance/` | `class_attendance_controller.cj` | `model/class_attendance/` | `repository/class_attendance/` |
| 自定义课程 | `page/custom_class/` | `custom_class_controller.cj` | `model/custom_class/` | `repository/custom_class/` |
| 水电信息 | `page/energy/` | `energy_controller.cj` | `model/energy/` | `repository/energy/` |
| 宿舍水费 | `page/dorm_water/` | `dorm_water_controller.cj` | `model/dorm_water/` | `repository/dorm_water/` |
| 图书馆 | `page/library/` | `library_controller.cj` | `model/library/` | `repository/library/` |
| 校园卡 | `page/schoolcard/` | `school_card_controller.cj` | `model/school_card/` | `repository/school_card/` |
| 校园网 | `page/schoolnet/` | `schoolnet_controller.cj` | `model/schoolnet/` | `repository/schoolnet/` |
| 实验信息 | `page/experiment/` | `experiment_controller.cj` | `model/experiment/` | `repository/experiment/` |
| 体育信息 | `page/sport/` | `sport_controller.cj` | `model/sport/` | `repository/sport/` |
| 猪图鉴 | `page/pig/` | 页面内状态 | Repository 返回模型 | `repository/pig/` |
| 工具箱与设置 | `page/toolbox/`、`page/setting/` | 页面内状态 | — | Web/本地配置 |

### 5.3 认证与安全模块

`repository/auth/` 是共享认证基础设施：

- `ids_session.cj`：西电 IDS、Ehall、滑块和二次认证链路。
- `ids_password_cipher.cj`：IDS 登录协议要求的密码加密。
- `slider_captcha_solver.cj`：滑块验证码自动识别与轨迹生成。
- `secure_session_cipher.cj`：本地敏感会话加密。
- `session_store.cj`：账号、Cookie、主题等持久化状态。

业务 Repository 应复用此模块，不应各自复制 IDS 登录实现。

## 6. 资源结构

```text
AppScope/resources/base/
├─ element/string.json       # 应用级名称
└─ media/                    # 桌面图标前景、背景和分层图标

entry/src/main/resources/base/
├─ element/
│  ├─ color.json             # 模块颜色资源
│  └─ string.json            # 模块文案和权限说明
├─ media/                    # 页面、导航、功能入口 SVG/PNG
└─ profile/main_pages.json   # 页面配置资源
```

业务图标已按用途命名，例如：

- `action_*`：返回、刷新、搜索、保存等页面动作。
- `home_*`：首页业务卡片图标。
- `nav_*`：底部导航图标。
- `exam_*`：考试时间、地点、座位图标。
- `toolbox_*`：工具箱入口图标。

## 7. 构建配置说明

### 根 `build-profile.json5`

- 定义 `default` 产品和 `entry` 模块。
- target/compatible SDK 均为 `6.1.0(23)`。
- 启用大小写和规范化 OHM URL 检查。
- 当前没有签名配置，因此默认产出 unsigned HAP。

### `entry/build-profile.json5`

- 使用 Stage 模型。
- `cangjieOptions.path` 指向 `entry/cjpm.toml`。
- 当前 `abiFilters` 只有 `x86_64`，适用于 HarmonyOS 模拟器。

### `entry/cjpm.toml`

- 源码根目录为 `./src/main/cangjie`。
- 输出类型为动态库。
- 同时声明 `aarch64-linux-ohos` 和 `x86_64-linux-ohos` 编译目标。
- 使用 `stdx` 的 JSON、加密、编码等动态库。

注意：虽然 `cjpm.toml` 声明了 aarch64，但 `entry/build-profile.json5` 当前只过滤 `x86_64`。如果交付目标包含真机，需要在 `abiFilters` 中补充对应 ARM ABI，并重新验证构建。

### `entry/src/main/module.json5`

- 主入口为 `EntryAbility`。
- 设备类型为手机。
- 声明 `INTERNET`、`READ_CALENDAR`、`WRITE_CALENDAR` 权限。
- Ability 的仓颉入口为 `ohos_app_cangjie_entry.MainAbility`。

## 8. 跨机器交付注意事项

1. `entry/cjpm.toml` 中的 `stdx` 路径包含本机绝对路径：
   `C:/Users/21768/.portage/stdx/1.1.0.1/...`。接收方机器若没有相同目录，构建会失败，应改为接收方 SDK/Portage 的实际 stdx 路径或统一的环境变量配置。
2. 当前只打包 `x86_64`，可直接面向模拟器；真机交付需补充 ARM ABI。
3. 根配置没有 `signingConfigs`，产物是 `entry-default-unsigned.hap`；真机或正式发布需要配置签名。
4. 校园网、水电、IDS、校园卡等真实数据依赖网络环境、有效账号和服务端会话，工程能构建不代表外部服务一定可访问。
5. 不应把真实账号、密码、Cookie、验证码或签名材料写入源码和交付文档。

## 9. 维护约定

- 新业务页面放入 `page/<feature>/`。
- 页面状态和业务编排放入 `controller/<feature>_controller.cj`。
- 数据模型放入 `model/<feature>/`。
- 网络和存储实现放入 `repository/<feature>/`。
- 跨业务复用组件放入 `components/`，系统能力边界放入 `external/`。
- 仓颉文件的 `package` 必须与目录对应；跨包使用的符号必须声明为 `public` 并显式 `import`。
