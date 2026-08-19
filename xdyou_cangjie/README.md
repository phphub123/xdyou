# XDYou 仓颉 HarmonyOS 工程

XDYou 是从 Traintime PDA/XDYou 迁移而来的 HarmonyOS 应用。本目录是可以使用
DevEco Studio 独立打开、构建和运行的 Stage 模型工程，业务与 ArkUI 界面主要使用仓颉实现。

## 1. 工程概况

| 项目 | 当前值 |
| --- | --- |
| Bundle Name | `io.github.benderblog.traintime_pda.harmonyos` |
| 应用版本 | `1.0.0`，versionCode `1000000` |
| 模块 | `entry` |
| Ability | `EntryAbility` / `MainAbility` |
| SDK | target/compatible `6.1.0(23)` |
| 仓颉编译器 | `1.1.3` |
| 仓颉包名 | `ohos_app_cangjie_entry` |
| 当前打包 ABI | `x86_64`，面向模拟器 |
| 声明权限 | 网络、读取日历、写入日历 |
| 仓颉源码 | 88 个 `.cj` 文件 |
| 模块资源 | 43 个文件 |

核心业务位于 `entry/src/main/cangjie/`，资源位于 `entry/src/main/resources/`，
应用级配置位于 `AppScope/`。

## 2. 顶层目录结构

```text
xdyou_cangjie/
├─ AppScope/                    # 应用级配置、名称和桌面图标
├─ entry/                       # 主业务模块
│  ├─ src/main/cangjie/         # 仓颉源码
│  ├─ src/main/resources/       # 模块资源
│  ├─ src/main/module.json5     # Ability、权限和设备类型
│  ├─ build-profile.json5       # entry 模块构建和 ABI 配置
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

| 文件 | 作用 |
| --- | --- |
| `ability_stage.cj` | 定义 `MyAbilityStage` 生命周期。 |
| `main_ability.cj` | 定义 `MainAbility`，初始化上下文、主题并加载根页面。 |
| `ability_mainability_entry.cj` | 将 `EntryAbility` 注册到 `MainAbility`。 |
| `module_entry_entry.cj` | 注册 `entry` 模块的 AbilityStage。 |
| `common/app_context.cj` | 保存并向业务层提供 HarmonyOS Context。 |
| `page/login/login_page.cj` | `@Entry` 根组件 `LoginWindow`，负责登录态和首页切换。 |

`ability_mainability_entry.cj` 和 `module_entry_entry.cj` 是注册胶水文件，已被 `.gitignore`
规则标记为可生成文件，不建议手工修改。

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

推荐依赖方向：

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
- `model/package.cj`、`repository/package.cj` 和 `page/package.cj` 是跨子包导出门面。

## 5. 主要源码与业务模块

### 5.1 公共组件

| 路径 | 内容 |
| --- | --- |
| `components/page_header.cj` | 页面标题栏、刷新动作和搜索框。 |
| `components/service_auth_web.cj` | 业务系统 Web/SSO 授权组件。 |
| `components/single_date_calendar_dialog.cj` | 可复用的单日期日历对话框。 |
| `themes/app_theme.cj` | 应用主题初始化、调色板和显示偏好。 |
| `external/system_capability_bridge.cj` | 日历同步等系统能力调用边界。 |

### 5.2 业务对应关系

| 业务 | 页面 | Controller | Model | Repository |
| --- | --- | --- | --- | --- |
| 登录与会话 | `page/login/` | `login_controller.cj` | `model/auth/` | `repository/auth/` |
| 校园首页 | `page/homepage/` | 多个业务 Controller | 各业务模型 | 各业务 Repository |
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

### 5.3 认证与安全

`repository/auth/` 是共享认证基础设施：

- `ids_session.cj`：西电 IDS、Ehall、滑块和二次认证链路。
- `ids_password_cipher.cj`：IDS 登录协议要求的密码加密。
- `slider_captcha_solver.cj`：滑块验证码自动识别与轨迹生成。
- `secure_session_cipher.cj`：本地敏感会话加密。
- `session_store.cj`：账号、Cookie、主题等持久化状态。

业务 Repository 应复用该模块，不应各自复制 IDS 登录实现。

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

业务图标命名约定：

- `action_*`：返回、刷新、搜索、保存等页面动作。
- `home_*`：首页业务卡片图标。
- `nav_*`：底部导航图标。
- `exam_*`：考试时间、地点和座位图标。
- `toolbox_*`：工具箱入口图标。

## 7. 构建配置

### 7.1 根 `build-profile.json5`

- 定义 `default` 产品和 `entry` 模块。
- target/compatible SDK 均为 `6.1.0(23)`。
- 启用大小写和规范化 OHM URL 检查。
- 当前没有签名配置，默认产出 unsigned HAP。

### 7.2 `entry/build-profile.json5`

- 使用 Stage 模型。
- `cangjieOptions.path` 指向 `entry/cjpm.toml`。
- `abiFilters` 当前只有 `x86_64`，适用于 HarmonyOS 模拟器。

### 7.3 `entry/cjpm.toml`

- 源码根目录为 `./src/main/cangjie`。
- 输出类型为动态库。
- 同时声明 `aarch64-linux-ohos` 和 `x86_64-linux-ohos` 编译目标。
- 使用 `stdx` 的 JSON、加密、编码等动态库。

注意：虽然 `cjpm.toml` 声明了 aarch64，但 `entry/build-profile.json5` 当前只打包
`x86_64`。如果交付目标包含真机，需要在 `abiFilters` 中补充对应 ARM ABI 并重新验证。

### 7.4 `entry/src/main/module.json5`

- 主入口为 `EntryAbility`。
- 设备类型为手机。
- 声明 `INTERNET`、`READ_CALENDAR`、`WRITE_CALENDAR` 权限。
- Ability 的仓颉入口为 `ohos_app_cangjie_entry.MainAbility`。

### 7.5 跨机器构建前调整 `stdx` 路径

`entry/cjpm.toml` 中的 `stdx` 路径当前指向：

```text
/Users/niu/.portage/stdx/1.1.0.1/...
```

接收方机器如果没有相同目录，必须先将 `entry/cjpm.toml` 中两处
`path-option` 改为该机器 SDK/Portage 实际安装的 `stdx` 路径，再执行
依赖同步或构建。必须同时保留以下两个编译目标，不要为了适配当前
模拟器而删除其中任意一个：

- `[target.aarch64-linux-ohos]`：HarmonyOS 真机。
- `[target.x86_64-linux-ohos]`：HarmonyOS 模拟器。

## 8. 构建与运行

提供两种运行方式。优先使用 DevEco Studio 直接构建和启动；需要自动化、
排错或验证产物时，再使用命令行。

### 8.1 方式一：使用 DevEco Studio 直接启动（推荐）

1. 用 DevEco Studio 打开本工程根目录，不要只打开 `entry/` 子目录。
2. 确认已安装 HarmonyOS SDK `6.1.0(23)` 和匹配的仓颉 SDK。
3. 按照第 7.5 节检查 `entry/cjpm.toml` 中的 `stdx` 路径，等待 DevEco
   Studio 完成 OHPM 依赖同步。
4. 打开 Device Manager，启动 `x86_64` HarmonyOS 模拟器。
5. 在运行配置中选择 `entry` 模块和已启动的模拟器，点击 **Run**。
6. 等待日志显示 `BUILD SUCCESSFUL`，并确认 XDYou 在模拟器前台启动。

当前工程未配置签名，DevEco Studio 在模拟器上可使用 unsigned HAP。如需在
真机运行，还需在 `entry/build-profile.json5` 中加入 ARM ABI，并配置调试
签名。

### 8.2 方式二：使用命令行构建和运行

以下流程不使用项目 Skill 中的 Python 脚本，直接使用 `ohpm`、`hvigorw` 和
`hdc`。

#### 8.2.1 准备环境

确保已安装 DevEco Studio、HarmonyOS SDK `6.1.0(23)` 和仓颉 SDK 6.1，然后直接
进入工程根目录：

```bash
cd /path/to/xdyou_cangjie
```

检查已配置的命令：

```bash
command -v ohpm
command -v hvigorw
command -v hdc
```

仓颉 Hvigor 插件需要仓颉 SDK 位置。同时使用 DevEco 自带的 Node，避免调用系统中
版本过新的 Node：

```bash
export DEVECO_CANGJIE_PATH="/Users/niu/.cangjie-sdk/6.1/cangjie"
export NODE_HOME="/Applications/DevEco-Studio.app/Contents/tools/node"
```

只需补这两项，不需要重复配置整套 SDK、Java、PATH 和动态库变量。

#### 8.2.2 构建 HAP

安装 OHPM 依赖：

```bash
ohpm install --all \
  --registry https://ohpm.openharmony.cn/ohpm/ \
  --strict_ssl true
```

同步仓颉资源：

```bash
hvigorw \
  --mode module \
  -p module=entry@default \
  SyncCangjieResource \
  --analyze=normal \
  --parallel \
  --incremental \
  --no-daemon
```

如果此处报 `cangjieOptions` 不是合法字段，不要删除
`entry/build-profile.json5` 中的 `cangjieOptions`。该错误表示仓颉 Hvigor 插件未启用，
重新执行上面两条 `export` 后再构建。

编译并打包 HAP：

```bash
hvigorw \
  --mode module \
  -p product=default \
  assembleHap \
  --analyze=normal \
  --parallel \
  --incremental \
  --no-daemon
```

成功时日志应包含：

```text
install completed
Finished :entry:SyncCangjieResource
Finished :entry:assembleHap
BUILD SUCCESSFUL
```

检查产物：

```bash
ls -lh entry/build/default/outputs/default/entry-default-unsigned.hap
```

`Will skip sign 'hos_hap'` 表示工程未配置签名。当前模拟器可安装 unsigned HAP，
真机调试或发布时需要另行配置签名。

#### 8.2.3 启动并连接模拟器

先在 DevEco Studio Device Manager 中启动模拟器，然后查看 HDC 目标：

```bash
hdc list targets
```

正常会输出类似：

```text
127.0.0.1:5555
```

把实际输出写入 `TARGET`：

```bash
TARGET="127.0.0.1:5555"
```

如果 `list targets` 为空，可手动连接常用端口：

```bash
hdc tconn 127.0.0.1:5555
hdc list targets
```

部分模拟器使用 `5557`、`5554` 或 `5559`，必须以 `list targets` 实际输出为准。

#### 8.2.4 安装并启动 XDYou

覆盖安装 HAP：

```bash
hdc -t "$TARGET" install -r \
  entry/build/default/outputs/default/entry-default-unsigned.hap
```

成功时应看到 `install bundle successfully`。

启动 `EntryAbility`：

```bash
hdc -t "$TARGET" shell aa start \
  -a EntryAbility \
  -b io.github.benderblog.traintime_pda.harmonyos \
  -m entry
```

检查应用进程：

```bash
hdc -t "$TARGET" shell pidof io.github.benderblog.traintime_pda.harmonyos
```

正常时会输出数字 PID。`aa start` 成功不代表进程一定已拉起，因此不能省略
`pidof` 检查。

查看 Ability 前台状态：

```bash
hdc -t "$TARGET" shell aa dump -a
```

在输出中查找 Bundle Name 和 `FOREGROUND`。

## 9. 跨机器交付注意事项

1. 跨机器构建前必须先按第 7.5 节调整 `stdx` 路径。
2. 当前只打包 `x86_64`，可用于模拟器；真机交付需要补充 ARM ABI。
3. 根配置没有 `signingConfigs`，产物是 `entry-default-unsigned.hap`；真机或正式发布需要配置签名。
4. 校园网、水电、IDS、校园卡等真实数据依赖网络环境、有效账号和服务端会话；
   工程能构建不代表外部服务一定可访问。
5. 不应把真实账号、密码、Cookie、验证码或签名材料写入源码和交付文档。

## 10. 维护约定

- 新业务页面放入 `page/<feature>/`。
- 页面状态和业务编排放入 `controller/<feature>_controller.cj`。
- 数据模型放入 `model/<feature>/`。
- 网络和存储实现放入 `repository/<feature>/`。
- 跨业务复用组件放入 `components/`，系统能力边界放入 `external/`。
- 仓颉文件的 `package` 必须与目录对应；跨包使用的符号必须声明为 `public` 并显式 `import`。
