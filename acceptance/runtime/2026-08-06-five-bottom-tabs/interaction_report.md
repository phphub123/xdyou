# 交互验证报告

**场景**: XDYou five bottom tabs
**描述**: Enter the local UI preview and capture each Flutter-aligned bottom destination.

## 交互步骤执行结果

| # | 操作 | 状态 | 详情 |
|---|------|------|------|
| 1 | click | PASS | click (660,1463): No Error |
| 2 | snapshot | PASS | 快照保存至 acceptance/runtime/2026-08-06-five-bottom-tabs/snapshot_01-home |
| 3 | click | PASS | click (401,2607): No Error |
| 4 | snapshot | PASS | 快照保存至 acceptance/runtime/2026-08-06-five-bottom-tabs/snapshot_02-ruisi |
| 5 | click | PASS | click (660,2607): No Error |
| 6 | snapshot | PASS | 快照保存至 acceptance/runtime/2026-08-06-five-bottom-tabs/snapshot_03-toolbox |
| 7 | click | PASS | click (918,2607): No Error |
| 8 | snapshot | PASS | 快照保存至 acceptance/runtime/2026-08-06-five-bottom-tabs/snapshot_04-pig |
| 9 | click | PASS | click (1177,2607): No Error |
| 10 | snapshot | PASS | 快照保存至 acceptance/runtime/2026-08-06-five-bottom-tabs/snapshot_05-settings |

## 交互前后界面差异

**摘要**: 新增 105 个节点; 移除 31 个节点; 文本变化 12 处; 属性变化 55 处; 数量变化: Column: 2→26, Toggle: 0→2, genericContainer: 2→0, Stack: 15→13, Divider: 0→5, Row: 10→23, Text: 12→32, Image: 0→5, Button: 2→0, TextInput: 2→0, Web: 1→0, rootWebArea: 1→0, Scroll: 0→1

### 文本变化
- `type:Text#7`: "View network interaction" → "界面設置"
- `type:Text#8`: "07" → "顏色設置"
- `type:Text#4`: "IDS Login password" → "檢查軟件更新"
- `type:Text#1`: "XDYOU" → "關於本程序"
- `type:Text#2`: "ID" → "版本號：1.0.0+1"
- `type:Text#3`: "PW" → "›"
- `type:Text#5`: "View" → "最新版本：等待獲取"
- `type:Text#6`: "Clear cache" → "›"
- `type:Text#11`: "100" → "設置深淺色"
- `type:Text#10`: "21" → "›"
- `type:Text#9`: ":" → "明日香橙"
- `type:Text#0`: "==" → "關於"

### 新增节点
- `type:Column#22` (Column) 
- `text:低電量閾值` (Text) 低電量閾值
- `text:顏色設置` (Text) 顏色設置
- `type:Divider#4` (Divider) 
- `type:Image#3` (Image) 
- `key:navTo_pig` (Column) 
- `key:navTo_ruisi` (Column) 
- `type:Image#2` (Image) 
- `text:校園信息` (Text) 校園信息
- `type:Column#5` (Column) 
- `text:▯` (Text) ▯
- `key:settingsTimelineToggle` (Toggle) 
- `type:Text#16` (Text) 簡化日程時間軸
- `text:簡化日程時間軸` (Text) 簡化日程時間軸
- `type:Column#9` (Column) 
- `text:設置深淺色` (Text) 設置深淺色
- `type:Column#13` (Column) 
- `type:Column#7` (Column) 
- `type:Text#19` (Text) 電量小於閾值時 電量卡片變色提醒
- `type:Toggle#1` (Toggle) 
- ... 共 105 个

### 移除节点
- `key:loginPasswordInput` (TextInput) 
- `text:Login` (Button) Login
- `type:Web#0` (Web) https://ids.xidian.edu.cn/authserver/login?service=https%3A%2F%2Fehall.xidian.edu.cn%2Flogin%3Fservice%3Dhttps%3A%2F%2Fehall.xidian.edu.cn%2Fnew%2Findex.html
- `key:idsCookieBootstrap` (Web) https://ids.xidian.edu.cn/authserver/login?service=https%3A%2F%2Fehall.xidian.edu.cn%2Flogin%3Fservice%3Dhttps%3A%2F%2Fehall.xidian.edu.cn%2Fnew%2Findex.html
- `text:https://ids.xidian.edu.cn/authserver/login?service=https%3A%2F%2Fehall.xidian.edu.cn%2Flogin%3Fservice%3Dhttps%3A%2F%2Fehall.xidian.edu.cn%2Fnew%2Findex.html` (Web) https://ids.xidian.edu.cn/authserver/login?service=https%3A%2F%2Fehall.xidian.edu.cn%2Flogin%3Fservice%3Dhttps%3A%2F%2Fehall.xidian.edu.cn%2Fnew%2Findex.html
- `key:viewNetworkInteraction` (Text) View network interaction
- `text:ID` (Text) ID
- `type:genericContainer#1` (genericContainer) 
- `text:PW` (Text) PW
- `key:loginPasswordMask` (Text) IDS Login password
- `text:IDS Login password` (Text) IDS Login password
- `type:Button#0` (Button) Login
- `type:Stack#14` (Stack) 
- `type:Button#1` (Button) Mock 预览主页（仅 UI，不登录）
- `text:Mock 预览主页（仅 UI，不登录）` (Button) Mock 预览主页（仅 UI，不登录）
- `type:Stack#13` (Stack) 
- `key:mockHomePreviewButton` (Button) Mock 预览主页（仅 UI，不登录）
- `text:Clear cache` (Text) Clear cache
- `text:View` (Text) View
- `type:rootWebArea#0` (rootWebArea) 
- ... 共 31 个

### 属性变化
- `type:Stack#11`.bounds: "[1173,69][1271,125]" → "[520,48][800,136]"
- `type:Row#3`.bounds: "[49,55][1271,136]" → "[59,896][1261,1050]"
- `type:Stack#0`.bounds: "[506,343][814,651]" → "[0,0][1320,136]"
- `type:Text#7`.clickable: "true" → "false"
- `type:Text#7`.bounds: "[581,1589][1020,1634]" → "[548,940][772,1006]"
- `type:Stack#9`.bounds: "[1086,69][1166,125]" → "[1173,69][1271,125]"
- `type:Row#2`.clickable: "false" → "true"
- `type:Row#2`.bounds: "[300,1589][1020,1634]" → "[59,581][1261,868]"
- `type:Row#9`.clickable: "false" → "true"
- `type:Row#9`.bounds: "[1173,55][1271,136]" → "[59,2212][1261,2450]"
- `type:Text#8`.bounds: "[49,66][111,128]" → "[129,1127][353,1193]"
- `type:Row#7`.bounds: "[1002,55][1079,136]" → "[59,1631][1261,1918]"
- `type:Stack#12`.bounds: "[1173,69][1271,125]" → "[520,48][800,136]"
- `type:Stack#8`.bounds: "[1079,55][1166,136]" → "[1166,55][1271,136]"
- `type:Text#4`.clickable: "true" → "false"
- `type:Text#4`.bounds: "[258,935][1034,1068]" → "[129,658][465,724]"
- `type:Stack#5`.bounds: "[49,55][1320,136]" → "[995,55][1079,136]"
- `type:Stack#4`.bounds: "[0,0][1320,136]" → "[49,55][188,136]"
- `type:Column#1`.bounds: "[559,396][762,599]" → "[0,137][1320,2450]"
- `type:Text#1`.bounds: "[583,468][739,600]" → "[129,367][409,433]"
- `type:Row#0`.bounds: "[115,756][1205,896]" → "[59,137][1261,290]"
- `type:Stack#6`.bounds: "[49,55][188,136]" → "[1079,55][1166,136]"
- `type:Text#2`.bounds: "[153,804][258,849]" → "[129,443][488,500]"
- `type:Stack#3`.bounds: "[0,0][1320,136]" → "[49,55][1320,136]"
- `type:Row#4`.clickable: "false" → "true"
- `type:Row#4`.bounds: "[0,0][1320,136]" → "[59,1050][1261,1337]"
- `type:Text#3`.bounds: "[153,981][258,1022]" → "[1129,372][1163,495]"
- `type:Stack#7`.bounds: "[995,55][1079,136]" → "[1086,69][1166,125]"
- `type:Text#5`.clickable: "true" → "false"
- `type:Text#5`.bounds: "[1034,979][1188,1024]" → "[129,734][571,791]"

### 控件数量变化
- Column: 2 → 26 (+24)
- Toggle: 0 → 2 (+2)
- genericContainer: 2 → 0 (-2)
- Stack: 15 → 13 (-2)
- Divider: 0 → 5 (+5)
- Row: 10 → 23 (+13)
- Text: 12 → 32 (+20)
- Image: 0 → 5 (+5)
- Button: 2 → 0 (-2)
- TextInput: 2 → 0 (-2)
- Web: 1 → 0 (-1)
- rootWebArea: 1 → 0 (-1)
- Scroll: 0 → 1 (+1)

## 断言检查结果

**通过 2/3**

| # | 类型 | 结果 | 说明 | 详情 |
|---|------|------|------|------|
| 1 | exists | FAIL | Settings page should show the XDYou heading | 未找到: {'text': 'XDYou'} |
| 2 | exists | PASS | Bottom navigation should remain visible | 找到目标控件 |
| 3 | page_changed | PASS | Navigation should change the page content | 总变化 191 处 |

> **结论**: 存在断言失败，需检查以下问题：

> - Settings page should show the XDYou heading
