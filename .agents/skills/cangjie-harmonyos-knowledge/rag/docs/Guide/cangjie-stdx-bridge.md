# 应用侧常用能力速查：JSON 解析 / URL 编码 / 主线程回填（stdx 桥接）

> 适用范围：仓颉鸿蒙应用工程。本篇是检索桥接页 — 这些能力的正解在 Cangjie 扩展库 stdx 与 ArkUI 里，
> 完整手册在 `cangjie-core-reference` 技能（stdx 手册不在本知识库索引内）。

## JSON 解析（JsonValue / JsonObject / parse）

应用侧 JSON 解析用 **stdx.encoding.json**：

```cangjie
import stdx.encoding.json.*

let root = JsonValue.fromStr(text)          // 解析字符串
let obj = root.asObject()                   // 取对象
let name = obj.get("name").asString().getValue()
let arr = obj.get("results").asArray()      // 取数组，size / get(i)
```

- ⛔ 不要 `import ohos.encoding.json` — 系统保护包，应用侧直接报
  `package 'ohos.encoding.json' is 'protected' which cannot be imported`。见到此报错即换 stdx。
- 报 stdx 包找不到 = 工程未接线：独立工程按 `cangjie-core-reference/references/cangjie-stdx/config/README.md`
  §0「快速接线」给 cjpm.toml 补 path-option（本机常有现成发行包，免下载）；Portage 管理的工程已接线，直接 import。
- 完整 API（JsonObject/JsonArray/JsonKind、序列化、异常处理）：
  `cangjie-core-reference/references/cangjie-stdx/json/README.md`。

## URL 编码 / 查询串构造（encodeURL / percent-encoding / Form）

URL 解析与编解码用 **stdx.encoding.url**：

```cangjie
import stdx.encoding.url.*

let url = URL.parse("https://api.example.com/search?q=value")
// URL 组件访问：url.scheme / url.host / url.path / url.query
// Form 表单键值对构造与编码见手册 §4
```

- HTTP 请求前查询参数必须百分号编码（NetworkKit 不自动编码）；中文/空格/`&`/`#` 裸拼必坏。
- 完整用法（URL 类、Form、编解码函数）：
  `cangjie-core-reference/references/cangjie-stdx/encoding/README.md` §4。

## 异步回调回填 UI（主线程 / runOnMainThread / 状态不刷新）

异步回调（HTTP 响应、spawn 任务）里**直接写 `@State` 会崩溃或不刷新** — 状态更新必须切回主线程：

```cangjie
import kit.ArkUI.launch

// 在回调/子线程里：
launch {
    this.resultText = parsed    // @State 写操作放 launch 块内，回主线程执行
}
```

规则与更多线程细节见工程内 `.claude/skills/cangjie-essentials.md`（运行时与数据类规则）。
