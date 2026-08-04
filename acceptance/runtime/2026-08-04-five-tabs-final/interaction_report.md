# 交互验证报告

**场景**: XDYou five bottom tabs
**描述**: Enter the local UI preview and capture each Flutter-aligned bottom destination.

## 交互步骤执行结果

| # | 操作 | 状态 | 详情 |
|---|------|------|------|
| 1 | click | PASS | click (660,1463): No Error |
| 2 | snapshot | PASS | 快照保存至 /Users/niu/huawei/Project1/traintime_pda_ohos/xdyou/acceptance/runtime/202 |
| 3 | click | PASS | click (402,2625): No Error |
| 4 | snapshot | PASS | 快照保存至 /Users/niu/huawei/Project1/traintime_pda_ohos/xdyou/acceptance/runtime/202 |
| 5 | click | PASS | click (660,2625): No Error |
| 6 | snapshot | PASS | 快照保存至 /Users/niu/huawei/Project1/traintime_pda_ohos/xdyou/acceptance/runtime/202 |
| 7 | click | PASS | click (917,2625): No Error |
| 8 | snapshot | PASS | 快照保存至 /Users/niu/huawei/Project1/traintime_pda_ohos/xdyou/acceptance/runtime/202 |
| 9 | click | PASS | click (1174,2625): No Error |
| 10 | snapshot | PASS | 快照保存至 /Users/niu/huawei/Project1/traintime_pda_ohos/xdyou/acceptance/runtime/202 |

## 交互前后界面差异

**摘要**: 新增 85 个节点; 移除 31 个节点; 文本变化 12 处; 属性变化 58 处; 数量变化: TextInput: 2→0, genericContainer: 2→0, Row: 10→15, rootWebArea: 1→0, Stack: 15→13, Column: 2→16, Web: 1→0, Scroll: 0→1, Button: 2→0, Text: 12→40

### 文本变化
- `type:Text#6`: "Clear cache" → "检查更新"
- `type:Text#0`: "==" → "XDYou"
- `type:Text#8`: "10" → "›"
- `type:Text#9`: ":" → "界面设置"
- `type:Text#3`: "PW" → "关于本程序"
- `type:Text#5`: "View" → "›"
- `type:Text#7`: "View network interaction" → "当前版本 1.0.0"
- `type:Text#11`: "100" → "默认蓝色"
- `type:Text#1`: "XDYOU" → "Written by BenderBlog Rodriguez and contributors"
- `type:Text#4`: "IDS Login password" → "XDYou 仓颉 HarmonyOS 原生版"
- `type:Text#2`: "ID" → "关于"
- `type:Text#10`: "11" → "主题配色"

### 新增节点
- `type:Text#17` (Text) 精简显示课程节次
- `text:当前版本 1.0.0` (Text) 当前版本 1.0.0
- `type:Text#29` (Text) 睿思论坛
- `type:Text#18` (Text) 开
- `type:Text#21` (Text) 当前学期 2026-1
- `text:精简显示课程节次` (Text) 精简显示课程节次
- `text:Written by BenderBlog Rodriguez and contributors` (Text) Written by BenderBlog Rodriguez and contributors
- `type:Column#4` (Column) 
- `type:Column#10` (Column) 
- `type:Column#14` (Column) 
- `text:默认蓝色` (Text) 默认蓝色
- `type:Text#26` (Text) ◉
- `type:Column#7` (Column) 
- `text:切换学期` (Text) 切换学期
- `text:当前学期 2026-1` (Text) 当前学期 2026-1
- `text:跟随系统` (Text) 跟随系统
- `text:›` (Text) ›
- `type:Text#32` (Text) ♥
- `type:Text#12` (Text) ›
- `text:关于` (Text) 关于
- ... 共 85 个

### 移除节点
- `key:clearSessionButton` (Text) Clear cache
- `type:rootWebArea#0` (rootWebArea) 
- `text:Login` (Button) Login
- `key:viewNetworkInteraction` (Text) View network interaction
- `key:mockHomePreviewButton` (Button) Mock 预览主页（仅 UI，不登录）
- `type:Web#0` (Web) https://ids.xidian.edu.cn/authserver/login?service=https%3A%2F%2Fehall.xidian.edu.cn%2Flogin%3Fservice%3Dhttps%3A%2F%2Fehall.xidian.edu.cn%2Fnew%2Findex.html
- `type:genericContainer#1` (genericContainer) 
- `text:==` (Text) ==
- `type:Button#1` (Button) Mock 预览主页（仅 UI，不登录）
- `text:ID` (Text) ID
- `text:https://ids.xidian.edu.cn/authserver/login?service=https%3A%2F%2Fehall.xidian.edu.cn%2Flogin%3Fservice%3Dhttps%3A%2F%2Fehall.xidian.edu.cn%2Fnew%2Findex.html` (Web) https://ids.xidian.edu.cn/authserver/login?service=https%3A%2F%2Fehall.xidian.edu.cn%2Flogin%3Fservice%3Dhttps%3A%2F%2Fehall.xidian.edu.cn%2Fnew%2Findex.html
- `key:togglePasswordVisibility` (Text) View
- `key:loginLogo` (Stack) 
- `text:PW` (Text) PW
- `type:Button#0` (Button) Login
- `text:View` (Text) View
- `text:View network interaction` (Text) View network interaction
- `text:Clear cache` (Text) Clear cache
- `text:Mock 预览主页（仅 UI，不登录）` (Button) Mock 预览主页（仅 UI，不登录）
- `text:IDS Login password` (Text) IDS Login password
- ... 共 31 个

### 属性变化
- `type:Row#6`.clickable: "false" → "true"
- `type:Row#6`.bounds: "[49,66][126,128]" → "[56,2329][1264,2492]"
- `type:Stack#4`.bounds: "[0,0][1320,136]" → "[49,55][188,136]"
- `type:Row#5`.clickable: "false" → "true"
- `type:Row#5`.bounds: "[49,55][188,136]" → "[56,2091][1264,2329]"
- `type:Text#6`.clickable: "true" → "false"
- `type:Text#6`.bounds: "[300,1589][504,1634]" → "[115,842][326,904]"
- `type:Stack#0`.bounds: "[506,343][814,651]" → "[0,0][1320,136]"
- `type:Row#4`.clickable: "false" → "true"
- `type:Row#4`.bounds: "[0,0][1320,136]" → "[56,1677][1264,1915]"
- `type:Text#0`.bounds: "[629,406][692,468]" → "[56,199][302,289]"
- `type:Stack#5`.bounds: "[49,55][1320,136]" → "[995,55][1079,136]"
- `type:Stack#8`.bounds: "[1079,55][1166,136]" → "[1166,55][1271,136]"
- `type:Column#1`.bounds: "[559,396][762,599]" → "[0,137][1320,2492]"
- `type:Text#8`.bounds: "[49,66][111,128]" → "[1189,878][1205,935]"
- `type:Text#9`.bounds: "[111,71][126,124]" → "[56,1074][1264,1201]"
- `type:Text#3`.bounds: "[153,981][258,1022]" → "[115,604][378,666]"
- `type:Text#5`.clickable: "true" → "false"
- `type:Text#5`.bounds: "[1034,979][1188,1024]" → "[1189,640][1205,697]"
- `type:Row#7`.bounds: "[1002,55][1079,136]" → "[0,2492][1320,2758]"
- `type:Row#8`.bounds: "[1086,55][1166,136]" → "[49,55][1271,136]"
- `type:Text#7`.clickable: "true" → "false"
- `type:Text#7`.bounds: "[581,1589][1020,1634]" → "[115,921][386,970]"
- `type:Text#11`.bounds: "[1182,75][1252,120]" → "[115,1335][284,1384]"
- `type:Text#1`.bounds: "[583,468][739,600]" → "[56,303][1032,352]"
- `type:Row#0`.clickable: "false" → "true"
- `type:Row#0`.bounds: "[115,756][1205,896]" → "[56,549][1264,787]"
- `type:Stack#9`.bounds: "[1086,69][1166,125]" → "[1173,69][1271,125]"
- `type:Stack#1`.bounds: "[258,935][1034,1068]" → "[0,0][1320,136]"
- `type:Row#9`.bounds: "[1173,55][1271,136]" → "[0,0][1320,136]"

### 控件数量变化
- TextInput: 2 → 0 (-2)
- genericContainer: 2 → 0 (-2)
- Row: 10 → 15 (+5)
- rootWebArea: 1 → 0 (-1)
- Stack: 15 → 13 (-2)
- Column: 2 → 16 (+14)
- Web: 1 → 0 (-1)
- Scroll: 0 → 1 (+1)
- Button: 2 → 0 (-2)
- Text: 12 → 40 (+28)

## 断言检查结果

**通过 3/3**

| # | 类型 | 结果 | 说明 | 详情 |
|---|------|------|------|------|
| 1 | exists | PASS | Settings page should show the XDYou heading | 找到目标控件 |
| 2 | exists | PASS | Bottom navigation should remain visible | 找到目标控件 |
| 3 | page_changed | PASS | Navigation should change the page content | 总变化 174 处 |

> **结论**: 所有断言通过，交互行为符合预期。
