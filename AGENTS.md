# XDYou Flutter → 仓颉 HarmonyOS 直接迁移规则

## 一、工作区目标

本目录本身就是 DevEco Studio 创建的仓颉 HarmonyOS 工程根目录，不得再创建
`harmonyos-app/` 子工程，也不得覆盖或重新脚手架化现有工程。

- Flutter 迁移源：`source/`
- 仓颉目标代码：`entry/src/main/cangjie/`
- HarmonyOS 资源：`entry/src/main/resources/`
- 迁移记录：`migration/`
- 构建、运行和知识检索证据：`evidence/`
- 双端验收证据：`acceptance/`

最终目标是将 XDYou/Traintime PDA 的现有功能迁移为可在 DevEco Studio
运行的仓颉 HarmonyOS 应用。业务、数据语义、主要交互和 UI 应尽量与
Android 版一致；目录前缀、文件基名、类名和公开函数名尽量保持。

## 二、开始工作前的强制动作

首次写仓颉代码前必须：

1. 完整读取以下文件：
   - `.agents/skills/harmonyos-cangjie-dev/SKILL.md`
   - `.agents/skills/harmonyos-project-bootstrap/SKILL.md`
   - `.agents/skills/cangjie-harmonyos-knowledge/SKILL.md`
   - `.agents/skills/cangjie-core-reference/SKILL.md`
   - `.agents/skills/harmonyos-build-run-diagnose/SKILL.md`
   - `.agents/skills/harmonyos-evolution/SKILL.md`
   - `.agents/skills/cangjie-essentials.md`
2. 检查现有工程的 `build-profile.json5`、`entry/cjpm.toml`、
   `entry/src/main/module.json5` 和 `entry/src/main/cangjie/`。
3. 在工作区根目录运行：

   ```powershell
   python .agents\skills\cangjie-harmonyos-knowledge\rag\cjdocs.py --config .\cjdocs.toml doctor
   python .agents\skills\cangjie-harmonyos-knowledge\rag\cjdocs.py --config .\cjdocs.toml query "ArkUI Button TextInput state onClick" --top-k 8
   ```

4. 对命中的相关条目继续执行 `read "<ref>"`，不能只看标题或片段。
5. 把使用的 skill、命令、query、ref 和采用结论记录到
   `evidence/skill-and-rag-usage.md`。缺少这份证据时，不得宣称已经使用
   skill 或知识库。

任何不熟悉的 ArkUI、网络、Cookie、持久化、权限、通知、日历、卡片、
Web、文件或系统 API，都必须先查询知识库再实现。

## 三、工程和语言铁律

- 业务实现必须使用仓颉；禁止嵌入 Flutter 运行，禁止用 ArkTS 重写主要业务。
- 纯仓颉是默认和首选。通知、日历、桌面卡片、扫码等能力必须先完成知识库/原始文档检索、SDK 符号检查和最小纯仓颉编译探针；仅在确认 SDK 缺失能力后，才可调用 `.agents/skills/cangjie-arkts-interop/SKILL.md` 引入最小 ArkTS bridge 或 ExtensionAbility。主 Ability、主要业务和主要 UI 保持仓颉；每项互操作都必须记录 SDK 版本、缺失符号、探针、ArkTS 文件、仓颉调用点、数据边界和回退方案到 `migration/arkts-interop-map.csv`、`migration/file-name-map.csv`、`evidence/skill-and-rag-usage.md`、阶段证据及验收矩阵。
- 当前工程已经由用户在 DevEco Studio 创建，优先增量修改，禁止重新创建工程。
- 首次修改前先完成原始空工程构建基线；若基线失败，先诊断环境，不能用改业务代码掩盖。
- Compatible SDK 固定使用 `6.1.0(23)`；target SDK 沿用工程当前配置，除非构建证据要求调整。
- `entry/cjpm.toml` 必须同时保留 `aarch64-linux-ohos` 与
  `x86_64-linux-ohos` 目标，覆盖真机和模拟器。
- 禁止占位函数、硬编码演示数据、静态登录成功、永远返回空数组、空 catch、
  未接通导航或只凭截图宣布功能完成。
- 不做无关重构；每次只完成一个可构建、可运行、可验收的纵向切片。
- 未经用户明确批准，不得实施 ArkTS 互操作。确实缺少纯仓颉能力时，先提供
  知识库 ref、SDK 版本、最小失败探针和互操作边界提案。

## 四、结构与命名映射

`source/lib/<area>/x.dart` 默认映射到：

`entry/src/main/cangjie/<area>/x.cj`

保留 `controller`、`model`、`repository`、`page`、`routing`、`themes`、
`external` 等分区。每个路径或符号例外都登记到
`migration/file-name-map.csv`，包含源路径、目标路径、源符号、目标符号、
理由和状态。

## 五、实现与验证闭环

每个功能切片必须完成：

1. 读取源页面、controller、repository、model 和资源；
2. 查询并阅读本阶段所需知识库 ref；
3. 实现真实数据链、加载态、空态、错误态和交互；
4. 构建并确认 `BUILD SUCCESSFUL` 和 HAP 路径；
5. 安装、启动、操作目标功能，检查目标进程 hilog；
6. 与 Android 相同条件下截图对比；
7. 更新映射、进度、知识使用证据和验收矩阵。

连续两次出现相同签名的构建错误时，必须按
`harmonyos-build-run-diagnose` 分析第一个稳定错误块，停止盲目改动。

## 六、阶段门禁与完成定义

每阶段结束必须同时具备：

- 构建成功并生成 HAP；
- 当前目标 ABI 可用；
- 安装、启动和关键交互成功；
- 目标进程无致命错误；
- Android/HarmonyOS 成对截图和日志已保存；
- `migration/`、`evidence/` 与 `acceptance/acceptance-matrix.csv` 已更新。

状态仅允许 `TODO`、`IN_PROGRESS`、`PASS`、`FAIL`、`BLOCKED_EXTERNAL`。
校园网、学校服务器或账号权限导致无法验证时只能标
`BLOCKED_EXTERNAL`，不能标 `PASS`。只有所有 Must 项均为 `PASS` 且不存在
业务占位，才能声明“功能完全一致”。


## 长任务连续执行

对用户明确要求连续完成的阶段任务，构建成功、单层完成、单次工具超时、
首个稳定编译错误、知识库查询完成，均不得作为结束本轮的理由。

同一错误连续两次时，只停止原样重跑；必须执行 build_analyzer、
读取首个稳定错误块和相关知识库 ref，再继续修复。除非出现人工凭据/
验证码/滑块、学校服务器不可访问、签名权限或其他明确外部阻塞，否则不得
向用户交还控制权。