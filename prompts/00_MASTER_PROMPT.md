# 给 Codex 的总提示词

你现在负责把本工作区 `source/` 中的 Flutter 应用 XDYou/Traintime PDA
直接迁移到当前工作区已有的仓颉 HarmonyOS 工程中。目标代码位于
`entry/src/main/cangjie/`，资源位于 `entry/src/main/resources/`。当前根目录
就是 DevEco Studio 工程根目录，禁止再创建 `harmonyos-app/` 子工程。

这是“直接迁移”任务：不调用 Portage 的 Dart 分析/自动拆解模块，但必须复用本工作区安装的仓颉 skills 与离线知识库，并自行建立可追踪的迁移计划、映射和验收闭环。

先完整读取并服从根目录 `AGENTS.md`。开始写代码前：

1. 完整读取 `.agents/skills/harmonyos-cangjie-dev/SKILL.md`、`.agents/skills/harmonyos-project-bootstrap/SKILL.md`、`.agents/skills/cangjie-harmonyos-knowledge/SKILL.md`、`.agents/skills/cangjie-core-reference/SKILL.md`、`.agents/skills/harmonyos-build-run-diagnose/SKILL.md`、`.agents/skills/harmonyos-evolution/SKILL.md` 和 `.agents/skills/cangjie-essentials.md`。
2. 检查 `evidence/knowledge-gate.txt`；再次使用根目录 `cjdocs.toml` 运行
   `cjdocs.py doctor`，并查询本阶段所需 API。命中后必须 `read` 相关 ref。
3. 盘点 `source/lib`、`source/pubspec.yaml`、`source/reference/android/AndroidManifest.xml` 和 `source/reference/docs`。
4. 创建：
   - `migration/source-inventory.md`
   - `migration/dependency-map.csv`
   - `migration/file-name-map.csv`
   - `migration/feature-plan.md`
   - `migration/progress.md`
   - `evidence/skill-and-rag-usage.md`
5. 依赖裁决必须逐项说明 Flutter 包在仓颉/HarmonyOS 中的替代方式：直接使用 std/stdx、HarmonyOS Kit、自研改写、资源替代或确有证据的最小互操作。不得因为没有 Flutter 包就删功能。

目标要求：

- 最终实现 README 中列出的全部功能，不做演示版；
- 主要页面 UI、布局、滑动、弹窗、加载、错误态、交互与 Android 基线接近；
- 保留 `controller/model/repository/page/routing/themes/external` 架构前缀；
- 文件基名、类名、枚举名、公开函数名尽量与 Dart 相同；
- 业务代码使用仓颉，不得嵌入 Flutter，不得把 ArkTS 当主要实现；
- HarmonyOS SDK 使用 6.1.0(23)，ABI 同时覆盖 x86_64 与 arm64-v8a；
- 每个纵向切片都必须 build → install → launch → interact → screenshot → log triage → 更新验收矩阵。

本次只执行“阶段 0：审计、映射、现有空工程基线和启动页烟测”，不要一次迁完全部功能：

1. 完成上述五份迁移文档。
2. 检查用户已创建的仓颉工程，先在不改业务代码的情况下完成一次构建基线。
   禁止重新创建或覆盖工程。用 `harmonyos-project-bootstrap` 只做结构审计和
   必要的最小修复。
3. 基线通过后，将 app 名调整为 `XDYou`；建议 bundle name
   `io.github.benderblog.traintime_pda.harmonyos`，修改前先说明影响并保证
   DevEco 可重新同步。若保留原 bundle，则在迁移文档中说明理由。
4. 在现有 `entry/` 中做可启动的仓颉壳和资源加载烟测，不做假业务。
5. 构建并在 DevEco 模拟器安装启动，保存日志、HAP 路径、截图和组件树。
5. 阶段 0 门禁通过后停止，向我报告证据与下一阶段计划，等待我发送下一份提示词。

不要声称“功能完全一致”，除非验收矩阵全部 Must 行为 PASS。
