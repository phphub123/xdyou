# XDYou 仓颉迁移 Codex 完整工作区

这是可直接交给 DevEco Studio 和 Codex 使用的工作区，已经合并：

- 用户创建的 Cangjie Empty Ability 工程；
- 7 套仓颉/HarmonyOS skills 与本地 `cjdocs` 文档索引；
- XDYou Flutter 最小迁移源集；
- Codex 强制规则、6 个阶段提示词和 35 项验收矩阵；
- 工作区自检脚本和完整中文操作手册。

## 目录角色

```text
xdyou-cangjie-codex-workspace/
├─ entry/                    # 直接开发的仓颉 HarmonyOS 模块
├─ AppScope/                 # HarmonyOS 应用级配置与资源
├─ source/                   # Flutter 迁移源，仅作为业务真相和对照
├─ .agents/skills/           # Codex 必须使用的仓颉 skills 与本地知识库
├─ prompts/                  # 00 到 05，按顺序逐阶段发送
├─ migration/                # Codex 维护源→目标映射和进度
├─ evidence/                 # 知识查询、构建、运行与日志证据
├─ acceptance/               # Android/HarmonyOS 截图和验收矩阵
├─ AGENTS.md                 # Codex 自动读取的强制规则
└─ CODEX_OPERATION_GUIDE.md  # 从解压到最终验收的操作说明
```

## 最短开始方式

1. 解压到一个不含中文和空格的短路径，例如：

   ```text
   D:\work\xdyou-cangjie-codex
   ```

2. 在 PowerShell 进入根目录并自检：

   ```powershell
   Set-Location D:\work\xdyou-cangjie-codex
   powershell -ExecutionPolicy Bypass -File .\tools\verify-workspace.ps1 -TargetRoot .
   ```

3. 先用 DevEco Studio 打开这个根目录，等待依赖同步，启动
   `x86_64` 模拟器并确认空工程能构建、安装、显示 Hello World。
4. 用 Codex 打开同一个根目录，发送 `prompts\00_MASTER_PROMPT.md` 的完整内容。
5. 阶段 0 通过后，再依次发送 `01` 到 `05`；一次只发一个阶段。

详细流程见 `CODEX_OPERATION_GUIDE.md`。

## 重要安全要求

本包不含 API Key，`cjdocs` 默认离线可用。学生账号和密码只允许在模拟器
界面手工输入，不要发给 Codex，也不要写入源码、配置或日志。
