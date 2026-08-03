# 仓颉(Cangjie)迁移语法生存指南

本指南列出可直接使用的仓颉鸿蒙工程写法与禁区。**只用这里出现的构造**；不确定时先 Grep 工程内的现成写法。

> 规则维护约定：每条 ⛔/✓ 断言必须带证据（实战报错签名 / 探针日期 / 文档核对 / 工程约定）。「未实证」型禁令一律先小样探针再定去留，禁止无证据禁用 — 过时禁令会把 agent 推向非法变通、污染根因诊断。

## 顶层结构

### 文件头固定形态（包名 + 常用导入）
```cangjie
package ohos_app_cangjie_entry        // 每个 .cj 第一行；包名与所在目录绑定（见下节）

import std.collection.ArrayList       // 标准库
import std.convert.*                  // Float64.parse 等
import kit.ArkUI.*                    // UI 组件（仅 UI 文件需要）
import ohos.arkui.state_macro_manage.*  // @Entry/@Component/@State 宏
```
> 证据：战役实证 — 38 个页面场景的工程写法全部编译通过，为全工程通用形态

### 多包工程：目录即包，跨包引用 = public + import
```cangjie
// entry/src/main/cangjie/data/api/weather_client.cj —— 子目录按路径追加包段
package ohos_app_cangjie_entry.data.api

public class RealWeatherClient { /* 跨包要用的声明必须 public */ }
```
```cangjie
// 根包文件（如 services.cj）跨包引用：
package ohos_app_cangjie_entry

import ohos_app_cangjie_entry.data.api.*     // 引子包（放在 package 行之后）
import ohos_app_cangjie_entry.common.*       // 共享设施：ObservableState/LoadState 在 common 包
```
规则三条：
- 首行 `package` 必须与文件所在目录一致（占位文件已由平台写好，勿改勿搬移）；每级包目录至少一个 .cj（`package.cj` 桩勿删，否则整棵子树不入编译）。
- 跨包引用两件事缺一不可：被引方 `public` + 引用方 `import ohos_app_cangjie_entry.<子包>.*`。
- ⛔ 子包不得 import 根包 `ohos_app_cangjie_entry`（根包是组合根，只有它 import 别人）——违者报 `cyclic dependency: A -> B`（逐边列环）。要共享类型用 common；要用其他服务改构造参数注入，由 services.cj 装配。

> 证据：探针实证 2026-07-11 — 子包 @Component/public 类被根包页面跨包实例化 BUILD SUCCESSFUL；observable 下沉 common + 7 文件跨包 import 全绿；包环负探针实录 `cyclic dependency: ohos_app_cangjie_entry.common -> ohos_app_cangjie_entry / ohos_app_cangjie_entry -> ohos_app_cangjie_entry.common`；中间目录缺 .cj 实测告警 "its subdirectories will not be scanned as source code"

## 类与枚举

### 类/接口的可编译形态
```cangjie
public class Foo <: IBar {            // 继承/实现都用 <:
    public static let TAG: String = "Foo"   // 静态常量
    private var count: Int64          // 字段先声明
    public init() { count = 0 }       // 构造函数叫 init
    public func work(x: Int64): String { return "v=${x}" }
    public static func of(): Foo { return Foo() }   // 静态工厂
}

public interface IBar {
    func work(x: Int64): String       // 接口方法不写 public
}
```
> 证据：战役实证 — 38 个页面场景的工程写法全部编译通过

### ⛔ 枚举变体只能裸名或携带类型 — 禁止字面量序数
枚举变体只能「裸名」或「携带类型」，⛔ 禁止 `| UP(1)` 这类字面量序数（构造器参数是类型不是值）。需要枚举↔数字映射时写伴生函数，用 match：
```cangjie
public enum Direction {
    | UP
    | DOWN
    | NONE
}
public enum Resource<T> {             // 泛型携带数据 ✓
    | Loading
    | Success(T)
    | Error(String)
}
public func directionCode(d: Direction): Int64 {
    match (d) {
        case Direction.UP => 1
        case Direction.DOWN => 2
        case Direction.NONE => 0
    }
}
```
> 证据：文档核对 · 2026-07-06 — core-reference enum/README：构造器无参或有参（参数为类型）；与实战报错一致

## Option 与 match

### 可空用 ?T；match 解包为主，??/?./getOrThrow 可用
```cangjie
var m: ?MainViewModel = None          // 可空 = ?T，空值 = None
m = Some(vm)
match (m) {
    case Some(v) => v.fetch()
    case None => ()
}
// match 必须穷尽；default 分支写 case _ => ()
```
轻量场景三件套均可编译：取默认值 `a ?? "dft"`；链式取值 `b?.size`（结果仍是 Option）；确定非空断言 `a.getOrThrow()`（None 时抛异常，仅用于逻辑上不可能为空处）。分支处理仍以 match 为主。
> 证据：战役实证 — 38 个页面场景的工程写法全部编译通过；match 穷尽为编译器强制；??/?./getOrThrow 编译探针通过（2026-07-06）

### ⚠ None 歧义：万能导入后裸 None 会撞名
文件里 `import kit.ArkUI.*` 等万能导入后，构造函数实参位置的裸 `None` 可能撞上其他包的 None 而编译失败。手写可空实参时用**显式类型**：`Option<Float64>.None`，或先 `let t: ?Float64 = None` 再传 `t`。非 UI 文件尽量不 import kit.ArkUI。
> 证据：实战报错 — find multiple constructor 'None' of enum declaration

### ⚠ 自定义枚举不要声明 None/Some 变体
自定义枚举**不要**声明叫 `None/Some` 的变体（与 std.core 的 Option 构造器冲突，放大 None 歧义问题）。
> 证据：战役实证 — None 歧义问题的衍生守则

## 类型与转换

### 基本类型、插值、集合、数组字面量
- 整数 `Int64`（默认）/`Int32`，浮点 `Float64`，布尔 `Bool`，字符串 `String`
- 字符串插值：`"共 ${n} 项"`；拼接 `+`
- 集合：`ArrayList<T>()`，`list.add(x)`，`list.size`，`for (item in list) { }`
- 数组字面量：`let a: Array<Int64> = [1, 2, 3]`
> 证据：战役实证 — 38 个页面场景的工程写法全部编译通过

### ⛔ 无隐式数值转换
`Float64 * Int64` 直接编译失败。混用前显式转：`f * Float64(i)`。显式转换：`Float64(i)`、`Int64(f)`、`x.toString()`。
> 证据：实战报错 · 2026-07-03 — invalid binary operator

### ⛔ 没有裸 parse 函数 — parse 是类型静态方法
`Int64.parse(s)`、`Float64.parse(s)`（需 `import std.convert.*`），可能抛异常要包 try-catch。不存在全局 `parse(...)`。
> 证据：实战报错 · 2026-07-03 — undeclared identifier 'parse'

### ⛔ 字符串按字节迭代 — 字符处理用 runes()
`for (b in s)` 拿到的是 UTF-8 字节（UInt8），和 String/字符比较必编译失败。按字符处理用 `for (r in s.runes())`（Rune），字符字面量 `r'a'`；判断前后缀用 `s.startsWith("x")`/`contains`，别下标逐字节比。
> 证据：实战报错 · 2026-07-03 — 字节/字符类型不匹配

### ⛔ 一般枚举不能 == 比较，用 match
自定义枚举和 SDK 枚举（如 NetBearType）默认没实现 Equatable，`==` 编译失败 — 用 `match` 分支判断（除非该枚举自定义了 operator ==）。Option 是例外，见「工程约定」的 Option == 条目。
> 证据：实战报错 · 2026-07-03 — 无 == 运算符（NetBearType 等实战报错）

### ⚠ ObservedArrayList 与 ArrayList 的 API 不同 — append/size vs add/size
ArkUI 观察集合 ObservedArrayList 追加用 `.append(x)`、长度用 `.size`；std 的 ArrayList 追加是 `.add(x)`。两套 API 不能混记 — ObservedArrayList 上调 `.add`/`.length` 都编译失败。
> 证据：战役实证 — 工程实战：ObservedArrayList.add/.length 编译失败，.append/.size 通过

## 函数与异常

### 函数、lambda、spawn 的形态
```cangjie
public func f(a: Int64, b: String): Bool { return true }
let cb: (String) -> Unit = { s => println(s) }
let thunk: () -> Unit = { => doIt() }         // 零参 lambda 要写 =>
spawn { doNetworkWork() }                      // 后台并发
```
> 证据：战役实证 — 38 个页面场景的工程写法全部编译通过

### ⛔ 块首标识符会被解析成 lambda 参数
`.onClick({ evt => ... })` 必须带参数名 — 块首直接写标识符会被当成 lambda 形参。多语句更新逻辑放成员函数，onClick 里只调 `this.refresh()`。
> 证据：实战报错 · 2026-07-03 — expected '=>' in lambda expression

### try-catch 形态（忽略异常也要有块）
```cangjie
try {
    let v = Float64.parse(s)
} catch (_) {
    ()                                         // 忽略异常也要有块
}
```
服务/数据层的 catch 不许真「忽略」— 见铁律「禁止静默吞异常」。
> 证据：战役实证 — 38 个页面场景的工程写法全部编译通过

## ArkUI 页面

### ✓ 页面组件骨架（@Component/@State/生命周期/条件渲染）
```cangjie
@Component                                     // 页面组件；应用入口才加 @Entry
class PageFoo {
    @State var title: String = "…"             // 状态变量驱动刷新
    protected override func aboutToAppear(): Unit { }   // 生命周期
    func build() {
        Column {
            Row {
                Text(this.title).fontSize(17).fontWeight(FontWeight.Bold)
                    .fontColor(0xFF23211C)     // 颜色 = 0xAARRGGBB 整数
                    .layoutWeight(1)
                Text("⚙").fontSize(18).padding(8)
                    .onClick({ evt => this.title = "clicked" })
            }.width(100.percent).padding(10)
            if (this.title != "") {            // 条件渲染 if/else ✓
                Text(this.title).fontSize(13)
            }
            Divider()
        }.width(100.percent).height(100.percent).backgroundColor(0xFFF5F3EC)
    }
}
// 组合自定义组件：直接 PageFoo()；带参 HelloComp(message: "hi")
```
> 证据：战役实证 — 38 个页面场景的工程写法全部编译通过

### ⛔ ForEach/LazyForEach 可用 — 但调用处禁止显式泛型
列表渲染用 ForEach / LazyForEach，一个致命陷阱：
- ⛔ **不要写显式泛型** `ForEach<String>(...)` — 宏展开把 `<` `>` 解析成链式比较，报 `comparison operators cannot be chained`，或只剩一句不透明的 `macro evaluation has failed for macro call 'Component'`。
- ✓ 省泛型靠推断：`ForEach(items, itemGenerator: { item: String, idx: Int64 => Text(item) })`（arr 传 ArrayList<T>；itemGenerator 是命名参数，形参 (T, Int64)）
- ✓ LazyForEach 同理省泛型：`LazyForEach(src, itemGenerator: {...})`，src 实现 `IDataSource<T>`（totalCount/getData/registerDataChangeListener/unregisterDataChangeListener 四成员），放 `List{}` 里配 `ListItem{}` 用。
- 标签 `itemGenerator:` 与 `itemGeneratorFunc:` 两种形态均可编译；统一写文档形态 `itemGenerator:`，见到另一形态不要当错误去改。
> 证据：探针实证 · 2026-07-06 — 编译探针：显式泛型报 comparison operators cannot be chained，去泛型后通过；itemGenerator 与 itemGeneratorFunc 两种标签均通过编译

### ⛔ build() 里不能写 while/for 命令式循环
`build()` 只许 UI 组件语法 — while/for 命令式循环直接宏失败（同样以不透明的 macro evaluation failed 示人）。循环渲染一律 ForEach，别用循环拼组件。
> 证据：探针实证 · 2026-07-06 — ForEach 案首轮死因实证

### ✓ Navigation/router 编译可用 — 但本工程约定走 AppNav
Navigation(NavPathStack){} 容器与 router.pushUrl(url: "…", params: "") 签名均编译可用 — 但**本工程约定仍走 AppNav 导航壳**：脚手架与设备自动化（导航记忆、navTo_ 稳定 id、场景冒烟）都锚定 AppNav，迁移单元不要私自引入第二套导航体系；确需 Navigation 栈式能力时先提边界决策，不要静默换。
> 证据：探针实证 · 2026-07-06 — 编译探针通过；AppNav 约定属架构决策非 SDK 限制

### ⛔ 自定义组件调用处不能链修饰符
`PageFoo().transition(...)/.width(...)` 会被宏展开成构造实参。需要修饰就在外面包一层：`Column { PageFoo() }.transition(...)`，或把修饰放组件内部根容器。
> 证据：实战报错 · 2026-07-03 — missing arguments for parameter list …（expected N arguments）

### ⛔ SDK 方法传参以声明为准：带 `!` 的命名传，其余位置传
判定标准只有一个 — 看 Cangjie 声明：形参带 `!`（文档参数表标注「命名参数」）就必须命名传，如 `itemGenerator:`、`HttpRequestOptions(method:, expectDataType:)`、`.margin(left: 20.vp)`、分角 `.borderRadius(topLeft: ..., topRight: ...)`；不带 `!` 一律位置传参。
高频陷阱方向：把文档签名里的**普通**参数名当命名实参标签 — ✓ `.scrollable(ScrollDirection.Vertical)`　✕ `.scrollable(scrollDirection: ...)`（报 `invalid named arguments prefix`）。
自定义 @Component 构造的 named args 是宏生成的特例，与 SDK 方法无关。拿不准就查知识库 `symbol <名>` 看成员签名有没有 `!`。
> 证据：实战报错 · 2026-07-04 — invalid named arguments prefix 'xxx:', target is not a named parameter

### ⛔ Hilog 调用固定三位置参
✓ `Hilog.error(1, "Tag", "msg ${e.message}")` — domain 固定写 1、tag 字符串、消息字符串（插值放消息里）。
⛔ `Hilog.error(TAG, "msg")` 两参必编译失败。info/warn/debug 同形态。
> 证据：实战报错 · 2026-07-04 — missing arguments for parameter list '(UInt32, String, String, Array<String>)'

## 运行时与数据

### ✓ JSON 解析优先用 stdx.encoding.json
stdx.encoding.json 可用：`import stdx.encoding.json.*` + `JsonValue.fromStr`/`asObject`/`get`/`asString().getValue()`。**新写/重写 JSON 解析优先用 stdx**，别再手写扫描（Portage 工程依赖已接线可直接 import；独立工程接线见 cangjie-core-reference 的 stdx config 篇）。
⛔ 别用 `ohos.encoding.json` — 系统保护包，应用侧 import 直接报 `package 'ohos.encoding.json' is 'protected' which cannot be imported`。见到该报错 = 换 stdx，不是找权限。
独立工程报 stdx 包找不到 = 未接线：按 cangjie-core-reference 的 stdx config 篇 §0「快速接线」补 cjpm.toml 的 path-option（本机常有现成发行包，免下载）。实在无 stdx 可用才降级手写解析（字节级、UTF-8 安全）；⛔ 禁止自己造 `stdx/` 目录伪实现。
用法细节读 cangjie-core-reference 的 stdx json 篇（`references/cangjie-stdx/json/README.md`）— RAG 知识库里检索不到 stdx 手册。
> 证据：探针实证 · 2026-07-04 — import + 全链构建探针通过

### ⛔ 维护手写扫描：严禁按 Int64 下标切 String
`s[i..i+1]` 切到多字节 UTF-8 字符（任意中文等）直接抛异常。正解按**字节**做结构扫描 — UTF-8 里 `{ } [ ] " \ :` 等结构字符都是单字节且不会出现在多字节序列内部：`for (b in s)` 与 `b'{'` 字节字面量比较，天然 UTF-8 安全；要提取子串再用字节下标一次性切片（起止都落在结构字符上就是合法 UTF-8）。
> 证据：实战报错 · 2026-07-04 — Invalid utf8 byte sequence（非 ASCII 城市名持久化静默失效根因）

### ⛔ HTTP/异步回调 body 必须整体 try-catch
回调在独立线程执行，逃逸的异常 = 应用崩溃。catch 里 Hilog.error 细节 + onError 兜底，别让任何解析异常穿透。
> 证据：战役实证 · 2026-07-04 — 实机崩溃排障沉淀

### ⛔ 解析结果要过合理性检查再回调 onSuccess
手写解析器「缺字段走默认值 0」的兜底策略，遇到错误响应体会静默产出全零业务对象（还可能被持久化固化）。关键数组/字段为空时应走 onError（"Malformed response"），不许把空壳当成功。
> 证据：战役实证 · 2026-07-04 — 全零数据污染 UI 与缓存的实战案

### ⛔ 异步回调写 @State 必须 launch{} 切主线程
HTTP/定位/spawn 等**异步回调在子线程执行**，回调里直接 `this.xxx = ...` 写 @State 会运行时崩溃（未捕获异常，应用直接退出）。正解用 `kit.ArkUI` 的全局 `launch { ... }`：
```cangjie
Services.dataService.fetchData(params,
    { data => launch { this.onDataLoaded(data) } },
    { err => launch { this.toastMessage = err } }
)
```
规则：**页面里所有传给服务的回调 lambda，body 一律套 `launch {}`**（成功/失败回调都要）；服务层内部不碰 @State 则无需。`spawn` 里做完耗时工作后同理用 `launch` 回主线程。
> 证据：实战报错 · 2026-07-03 — State updates are not performed on the main thread（实机崩溃）

### ⛔ @State 字段只能在组件自身成员方法里读写
宏展开后字段外部不可见，组件外写 `page.count = x` 必报错 — 且这类错误改不动就会卡死修复环。**不要**把组件实例传给自由函数/其他类去更新状态。正确做法三选一：
1. 把「更新状态」的逻辑写成组件的**成员函数**（`func applyData(d: X)` 里 `this.count = ...`）；
2. 数据下行：父组件用**构造 named 参数**传入子组件；状态上行：把回调 lambda 传给子组件调用；
3. 多屏共享：状态放 services.cj 服务类（普通 class 字段），页面在 `aboutToAppear`/`onClick` 里读服务并赋给**自己的** @State。
> 证据：实战报错 · 2026-07-03 — can not access field 'xxx'

### ⚠ Float 转 Int 前防 NaN/Inf — 运行时崩溃
`Int64(x)` 等浮点转整型在 x 为 NaN/Inf 时**运行时崩溃**（崩溃签名 `casting infinite or NaN value to Int`）。数据解析/聚合路径常见成因：空数据集求均值、分母为零。转换前守卫：分母为零早退；对可疑值用 `x.isNaN() || x.isInf()` 判定后走兜底值；解析路径的 catch 按铁律记 Hilog 并走错误回调。
> 证据：实战报错 · 2026-07-06 — faultlog: casting infinite or NaN value to Int（实机启动崩溃，网络数据为空触发）

## HTTP 与解析

### ⛔ HTTP 请求要显式声明响应类型
`ohos.net.http` 的 `HttpRequestOptions` 里 `expectDataType` 默认 None，响应 `r.result` 可能不是 `HttpData.StringData` — 只 match StringData 的解析代码会走进兜底分支（表现为 "Unexpected response format"，数据永远加载不出来）。
正解：请求 JSON/文本接口时显式 `HttpRequestOptions(method: RequestMethod.Get, expectDataType: HttpDataType.StringValue)`；match 时兜底分支也把 `ArrayBufferData` 转成 String 处理一遍再放弃。
> 证据：战役实证 · 2026-07-03 — 数据永远加载不出的实机排障案

### ⛔ HTTP 客户端四件套（每个客户端都要齐）
1. **URL 查询参数必须字节级百分号编码**：NetworkKit **不会**自动编码 URL（官方文档明确要求先编码再请求）。用户输入/中文/空格/`&`/`#` 裸拼 URL = 请求失败或参数注入。编码实现优先用 stdx：`import stdx.encoding.url.*`（URL 解析/编解码/Form，用法见 cangjie-core-reference 的 stdx encoding 篇 §4）；不引 stdx 时手写字节级 `urlEncode`：`for (b in s)` 按 UTF-8 字节，`[A-Za-z0-9-._~]` 原样，其余输出 `%XX` 大写十六进制 — 对多字节天然安全。
2. **必须校验 `r.responseCode != 200`**：非 200 的错误体会被「找不到字段走默认值」的解析器成功解析成全零数据，污染 UI 与持久化缓存。非 200 → Hilog.error 带 code → onError，不进解析。
3. **显式超时**：`connectTimeout: 10000, readTimeout: 30000` — 默认 60s 会让下拉刷新假死转圈一分钟以上。
4. **ArrayData 兜底解码用 `String.fromUtf8(bytes)`**（std.core，UTF-8 校验解码）：⛔ 禁止 `String(Rune(Int64(byte)))` 逐字节拼 — 那是 Latin-1 解码，中文变乱码，且 O(n²) 拼接会让大响应卡死回调线程。
> 证据：战役实证 · 2026-07-04 — 实机运行时多维审计沉淀 + 官方文档核对（URL 编码要求；stdx.encoding.url 能力文档核对 2026-07-06）

### ⚠ hasDefaultNet 可能抛 201 — 乐观降级，别据此判无网
`connection.hasDefaultNet` 可能抛错误码 201（网络权限已实授也会出现）。处理方式：捕获后**继续发起请求**，把网络可用性交给请求自身的失败路径兜底；不要因 201 直接报「无网络」终止流程。
> 证据：战役实证 · 2026-07-03 — 实机复现：权限已授仍抛 201；乐观降级后请求正常完成

## UI 配方

### ✓ BottomSheet/弹层迁移配方（Stack 叠层 + backdropBlur）
Android `BottomSheetDialogFragment`（模糊透底弹窗）在鸿蒙无对等组件，用 **Stack 叠层**复刻：
```cangjie
Stack {
    PageMain()                                  // 打底页（会被模糊）
    if (this.showSheet) {
        Column { PageSheetContent() }           // 自定义组件不能链修饰符，包一层 Column
            .width(100.percent).height(100.percent)
            .backdropBlur(40.0)                 // 参数是浮点
            .backgroundColor(0x80FFFFFF)        // 半透明白（AARRGGBB，AA=80）
            .borderRadius(topLeft: 20, topRight: 20, bottomLeft: 0, bottomRight: 0)
            .margin(top: 36)                    // 露出状态栏区域的底层页
    }
}.width(100.percent).layoutWeight(1)
```
- 弹层内容页自己的根容器背景必须改**透明**（0x00000000），否则挡住模糊效果。
- `borderRadius`/`margin`/`padding` 这类修饰符**支持命名参数分角/分边**（topLeft:/top: 等）— 「SDK 方法一律位置传参」铁律的例外清单，其余方法仍默认位置传参。
> 证据：战役实证 · 2026-07-04 — 编译与实机双重验证

### ✓ Scroll 短内容默认整体居中 — 顶置用 align
`Scroll` 的子内容高度小于视口时**默认居中显示** — 列表页看起来「内容跑到屏幕中间」就是它。顶置修法：`Scroll { ... }.align(Alignment.TopStart)`。
> 证据：战役实证 · 2026-07-04 — 实机对齐验证

### ⛔ 悬浮叠加层的触摸吞噬陷阱（裸 Row + align 正解）
Stack 顶层「全屏容器 + `Column{}.layoutWeight(1)` 透明撑杆 + 底部悬浮条」的写法**视觉正确但交互致命**：透明撑杆参与触摸测试，把整页点击全部吞掉（底下按钮全点不动，肉眼完全看不出问题）。
- ⛔ `.hitTestBehavior(HitTestMode.None)` 在本 SDK 编译不过（知识库文档里有该 API 但 SDK 未实现，文档≠现实）。
- **正解**：悬浮条**不要包全屏层** — 直接作为 Stack 子组件的裸 Row（只占自身高度，天然不挡任何点击），用 `.align(Alignment.Bottom)` 定位到底部：
```cangjie
if (this.showSnackbar) {
    Row { ...条内容... }.width(100.percent).backgroundColor(0xCC333333)
     .align(Alignment.Bottom)
}
```
- 验收标准：悬浮条显示期间，页面其余区域的点击/滑动必须照常生效。写完悬浮层务必自问：「这层挡不挡点击？」
- 文档确认过的 API 编译报 `not a member` 时，**以工程内已编译通过的写法为准**（Grep 工程内同类页面 / git log），不要反复硬试文档 API。
> 证据：探针实证 · 2026-07-05 — hitTestBehavior 编译报错 'not a member' + 裸 Row 配方编译+实机+冒烟三重实证

## 工程约定

### ⛔ 不要 null、不要三元 ?:
不要写 `null`（用 `None`）；不要三元 `?:`（仓颉无此运算符，if 本身是表达式）。
> 证据：文档核对 · 2026-07-06 — core-reference 语言特性核对：无 null 字面量、无三元运算符

### ✓ Option 可以 ==（须显式类型消歧），首选仍是 match
Option **可以** `==`，但比较对象要显式类型消歧：`o == Option<Int64>.None`（裸 None 在 import kit.ArkUI 的文件里撞名）— 首选仍是 match 解包；一般枚举不能 ==（见「类型与转换」）。
> 证据：探针实证 · 2026-07-06 — 编译探针：消歧后通过，裸 None 报 find multiple constructor

### 文件规模宁多勿改
新逻辑放自己的目标文件，别在别的单元文件里插代码（services.cj 注册行除外）— 降低单元间 diff 冲突与回滚半径。
> 证据：工程约定 — 单元所有权模型的配套纪律

### ✓ 交互入口挂稳定 .id() — 自动化定位不能依赖文本
导航按钮与主要操作按钮必须挂稳定 `.id("...")`（如 `.id("navTo_settings")`、`.id("btnSearch")`）：自动化测试与验收靠 id 定位；后续迭代可能改字形/文案，文本定位会断。自定义组件把 id 挂到其内部根容器上（组件调用处不能链修饰符）。
> 证据：战役实证 — 实战教训：修复迭代改按钮字形后文本定位失效、自动化断链
