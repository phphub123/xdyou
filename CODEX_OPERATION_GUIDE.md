# 解压后操作 Codex 的完整流程

## 1. 解压与首次自检

把压缩包解压到短英文路径，例如：

```text
D:\work\xdyou-cangjie-codex
```

不要再把它放进另一个同名工程，也不要只打开 `entry/`。工作区根目录就是
包含 `AGENTS.md`、`source/`、`entry/` 的这一层。

在 PowerShell 中执行：

```powershell
Set-Location D:\work\xdyou-cangjie-codex
powershell -ExecutionPolicy Bypass -File .\tools\verify-workspace.ps1 -TargetRoot .
```

成功后应生成 `evidence\knowledge-gate.txt`。这证明 skill 文件、本地索引和
首次离线检索可用。`vectors: 0` 是正常的离线状态，不要因此重建索引。

## 2. DevEco Studio 基线

1. 用 DevEco Studio 打开工作区根目录。
2. 等待工程同步；本包刻意不携带 `.idea`、`.hvigor`、`oh_modules` 和
   `local.properties`，它们会在你的电脑上重新生成。
3. 确认 Compatible SDK 为 `6.1.0(23)`。
4. 启动 `x86_64` 模拟器。
5. 先在 Codex 修改任何业务代码之前，手工构建并运行一次 Hello World。
6. 如果空工程都不能运行，先解决本机 SDK、Cangjie SDK、签名、hvigor 或
   模拟器问题；不要直接开始迁移。

## 3. 用 Codex 打开正确目录

在 Codex 中选择：

```text
D:\work\xdyou-cangjie-codex
```

检查 Codex 能看到：

- `AGENTS.md`
- `.agents\skills\`
- `source\lib\`
- `entry\src\main\cangjie\`
- `acceptance\acceptance-matrix.csv`

不要只选 `source`、`source\lib` 或 `entry`，否则根规则和技能可能不生效。

## 4. 阶段 0：只做审计、映射和启动壳

把 `prompts\00_MASTER_PROMPT.md` 的全文发送给 Codex。阶段 0 的重点是：

- 读取并实际使用仓颉 skills；
- 运行 `cjdocs doctor/query/read` 并留下 ref 证据；
- 盘点 Flutter 源码和依赖；
- 先验证现有空工程，不重新创建工程；
- 建立迁移映射、依赖裁决和分阶段计划；
- 把 Hello World 替换成不含假业务的 XDYou 启动壳；
- 构建、安装、启动、截图和日志验证。

Codex 报告完成后，至少检查：

```text
evidence\knowledge-gate.txt
evidence\skill-and-rag-usage.md
migration\source-inventory.md
migration\dependency-map.csv
migration\file-name-map.csv
migration\feature-plan.md
migration\progress.md
```

还要看到真实 `BUILD SUCCESSFUL`、HAP 路径、模拟器截图和目标进程日志。
缺一项就继续让 Codex 修复阶段 0，不要进入下一阶段。

## 5. 后续提示词发送顺序

每个阶段通过后再发送下一份：

| 顺序 | 文件 | 目标 |
| --- | --- | --- |
| 1 | `01_LOGIN_SHELL.md` | 登录、会话、主页壳、设置 |
| 2 | `02_CORE_STUDENT.md` | 课程表、成绩、考试 |
| 3 | `03_CAMPUS_SERVICES.md` | 校园查询与工具箱 |
| 4 | `04_EXTENDED_SYSTEM.md` | 论坛、通知、日历、桌面卡片等 |
| 5 | `05_UI_FINAL_ACCEPTANCE.md` | UI 对齐和全量回归 |

不要一次发送全部提示词。每个阶段内部也应按纵向切片推进，例如课程表必须
同时完成页面、状态、repository、HTTP/Cookie、解析、model 和错误态，然后
立刻构建与设备验收。

## 6. 推荐的日常 Codex 操作节奏

每轮开始：

```text
继续当前阶段。先读取 AGENTS.md、migration/progress.md、
evidence/skill-and-rag-usage.md 和上次首个稳定错误块。
只处理当前最小纵向切片，查询并 read 相关 cjdocs ref 后再改代码。
完成后必须构建、安装、运行、交互、截图、hilog 检查并更新验收矩阵。
```

如果构建失败：

```text
不要继续猜测修改。按 harmonyos-build-run-diagnose skill 提取本次构建的
第一个稳定错误块，说明根因、证据和最小修复；只修该错误后立即重建。
```

如果 Codex 长时间没有产出：

```text
立即停止扩大范围，报告当前命令、最后有效输出、是否仍有进程、已修改文件和
阻塞点。保留现有改动，只执行一个能在 10 分钟内验证的最小动作。
```

如果 Codex 只做了静态页面：

```text
当前结果不能验收。回到 source 中对应 controller/repository/model，
补齐真实会话、接口、解析、加载/空/错误态，并用同一账号数据与 Android 对照。
禁止假数据和静态登录成功。
```

## 7. Android 与 HarmonyOS 一致性对比

两端固定相同条件：

- 同一学生账号；
- 同一学期和刷新时点；
- 同一网络环境；
- 同一语言、主题和尽量接近的屏幕尺寸；
- 相同操作步骤。

截图分别放入：

```text
acceptance\android\
acceptance\harmonyos\
acceptance\diff\
```

每项都在 `acceptance\acceptance-matrix.csv` 填证据路径和状态。校园网、
学校服务器或账号权限导致无法验证时标 `BLOCKED_EXTERNAL`，不能标 `PASS`。

## 8. 账号和密钥

- 学号、密码只在模拟器 UI 中手工输入。
- 不要把 Cookie、Token 或含个人数据的完整 hilog 交给模型；先脱敏。
- `cjdocs` 默认离线，不需要 API Key。
- 如以后确实启用在线增强，只在当前 PowerShell 会话设置环境变量：

  ```powershell
  $env:XDYOU_CJDOCS_EMBED_API_KEY = "你的新密钥"
  ```

  不要把密钥写回 `cjdocs.toml`，也不要提交或打包含密钥的配置。

## 9. 最终完成条件

只有同时满足以下条件才能结束：

- 所有 Must 验收项为 `PASS`；
- 没有 TODO、stub、mock、假数据、空 catch 或未接导航；
- 数据字段、数量、排序和关键计算与 Android 一致；
- 主要页面布局、交互、滚动、弹窗和状态接近；
- 文件与符号映射完整，例外有理由；
- 构建、双 ABI、HAP、安装、启动、截图和 hilog 证据齐全。

存在 `BLOCKED_EXTERNAL` 时，可以写“代码迁移完成、外部条件待验”，不能写
“功能完全一致已验收”。
