# 交互验证报告

**场景**: XDYou settings color mode
**描述**: Verify that the migrated Flutter brightness preference updates the running Cangjie settings shell and remains available across navigation.

## 交互步骤执行结果

| # | 操作 | 状态 | 详情 |
|---|------|------|------|
| 1 | click | PASS | click (660,1463): No Error |
| 2 | click | PASS | click (1177,2607): No Error |
| 3 | click | PASS | click (1128,1484): No Error |
| 4 | snapshot | PASS | 快照保存至 acceptance/runtime/2026-08-06-settings-color-mode/snapshot_01-settings-dar |
| 5 | click | PASS | click (142,2607): No Error |
| 6 | snapshot | PASS | 快照保存至 acceptance/runtime/2026-08-06-settings-color-mode/snapshot_02-home-dark |
| 7 | click | PASS | click (1177,2607): No Error |
| 8 | click | PASS | click (995,1484): No Error |
| 9 | snapshot | PASS | 快照保存至 acceptance/runtime/2026-08-06-settings-color-mode/snapshot_03-settings-lig |

## 交互前后界面差异

**摘要**: 新增 107 个节点; 移除 33 个节点; 文本变化 14 处; 属性变化 57 处; 数量变化: Web: 1→0, Image: 0→5, Text: 12→32, rootWebArea: 1→0, Scroll: 0→1, TextInput: 2→0, Row: 10→23, Stack: 15→13, genericContainer: 2→0, Column: 2→26, Button: 2→0, Divider: 0→5, Toggle: 0→2

### 文本变化
- `type:Text#2`: "ID" → "版本號：1.0.0+1"
- `type:Text#6`: "Clear cache" → "›"
- `key:ClockStatusView`: "07, :, 24" → "07, :, 25"
- `type:Flex#0`: "07, :, 24" → "07, :, 25"
- `type:Text#9`: ":" → "明日香橙"
- `type:Text#1`: "XDYOU" → "關於本程序"
- `type:Text#8`: "07" → "顏色設置"
- `type:Text#10`: "24" → "›"
- `type:Text#3`: "PW" → "›"
- `type:Text#0`: "==" → "關於"
- `type:Text#5`: "View" → "最新版本：等待獲取"
- `type:Text#4`: "IDS Login password" → "檢查軟件更新"
- `type:Text#11`: "100" → "設置深淺色"
- `type:Text#7`: "View network interaction" → "界面設置"

### 新增节点
- `text:界面設置` (Text) 界面設置
- `text:電量小於閾值時 電量卡片變色提醒` (Text) 電量小於閾值時 電量卡片變色提醒
- `text:校園信息` (Text) 校園信息
- `type:Column#3` (Column) 
- `type:Column#8` (Column) 
- `type:Column#23` (Column) 
- `text:睿思論壇` (Text) 睿思論壇
- `text:低電量卡片變色提醒` (Text) 低電量卡片變色提醒
- `type:Column#12` (Column) 
- `type:Divider#0` (Divider) 
- `type:Row#16` (Row) 
- `type:Text#13` (Text) ▯
- `type:Image#2` (Image) 
- `type:Image#0` (Image) 
- `key:settingsTimelineToggle` (Toggle) 
- `text:25` (Text) 25
- `type:Image#1` (Image) 
- `type:Column#16` (Column) 
- `text:目前為 15 度` (Text) 目前為 15 度
- `type:Column#19` (Column) 
- ... 共 107 个

### 移除节点
- `type:Stack#14` (Stack) 
- `type:Button#1` (Button) Mock 预览主页（仅 UI，不登录）
- `key:viewNetworkInteraction` (Text) View network interaction
- `key:mockHomePreviewButton` (Button) Mock 预览主页（仅 UI，不登录）
- `text:==` (Text) ==
- `text:Clear cache` (Text) Clear cache
- `key:togglePasswordVisibility` (Text) View
- `text:24` (Text) 24
- `text:View network interaction` (Text) View network interaction
- `type:genericContainer#0` (genericContainer) 
- `key:loginSubmitButton` (Button) Login
- `key:loginAccountInput` (TextInput) 
- `type:genericContainer#1` (genericContainer) 
- `type:Stack#13` (Stack) 
- `type:Button#0` (Button) Login
- `text:07, :, 24` (Flex) 07, :, 24
- `key:loginPasswordMask` (Text) IDS Login password
- `text:Mock 预览主页（仅 UI，不登录）` (Button) Mock 预览主页（仅 UI，不登录）
- `text:ID` (Text) ID
- `text:https://ids.xidian.edu.cn/authserver/login?service=https%3A%2F%2Fehall.xidian.edu.cn%2Flogin%3Fservice%3Dhttps%3A%2F%2Fehall.xidian.edu.cn%2Fnew%2Findex.html` (Web) https://ids.xidian.edu.cn/authserver/login?service=https%3A%2F%2Fehall.xidian.edu.cn%2Flogin%3Fservice%3Dhttps%3A%2F%2Fehall.xidian.edu.cn%2Fnew%2Findex.html
- ... 共 33 个

### 属性变化
- `type:Text#2`.bounds: "[153,804][258,849]" → "[129,443][488,500]"
- `type:Text#6`.clickable: "true" → "false"
- `type:Text#6`.bounds: "[300,1589][504,1634]" → "[1129,663][1163,786]"
- `type:Stack#5`.bounds: "[49,55][1320,136]" → "[995,55][1079,136]"
- `type:Row#8`.bounds: "[1086,55][1166,136]" → "[59,1922][1261,2209]"
- `type:Stack#0`.bounds: "[506,343][814,651]" → "[0,0][1320,136]"
- `type:Row#9`.clickable: "false" → "true"
- `type:Row#9`.bounds: "[1173,55][1271,136]" → "[59,2212][1261,2450]"
- `type:Stack#4`.bounds: "[0,0][1320,136]" → "[49,55][188,136]"
- `type:Stack#12`.bounds: "[1173,69][1271,125]" → "[520,48][800,136]"
- `type:Row#3`.bounds: "[49,55][1271,136]" → "[59,896][1261,1050]"
- `type:Row#0`.bounds: "[115,756][1205,896]" → "[59,137][1261,290]"
- `type:Stack#8`.bounds: "[1079,55][1166,136]" → "[1166,55][1271,136]"
- `type:Text#9`.bounds: "[111,71][126,124]" → "[129,1203][326,1260]"
- `type:Row#7`.bounds: "[1002,55][1079,136]" → "[59,1631][1261,1918]"
- `type:Stack#11`.bounds: "[1173,69][1271,125]" → "[520,48][800,136]"
- `type:Text#1`.bounds: "[583,468][739,600]" → "[129,367][409,433]"
- `type:Stack#10`.bounds: "[1166,55][1271,136]" → "[1173,69][1271,125]"
- `type:Stack#6`.bounds: "[49,55][188,136]" → "[1079,55][1166,136]"
- `type:Text#8`.bounds: "[49,66][111,128]" → "[129,1127][353,1193]"
- `type:Stack#1`.bounds: "[258,935][1034,1068]" → "[0,0][1320,136]"
- `type:Row#5`.bounds: "[49,55][188,136]" → "[59,1341][1261,1628]"
- `type:Stack#3`.bounds: "[0,0][1320,136]" → "[49,55][1320,136]"
- `type:Text#10`.bounds: "[126,66][188,128]" → "[1129,1132][1163,1255]"
- `type:Row#2`.clickable: "false" → "true"
- `type:Row#2`.bounds: "[300,1589][1020,1634]" → "[59,581][1261,868]"
- `type:Stack#9`.bounds: "[1086,69][1166,125]" → "[1173,69][1271,125]"
- `type:Text#3`.bounds: "[153,981][258,1022]" → "[1129,372][1163,495]"
- `type:Text#0`.bounds: "[629,406][692,468]" → "[604,180][716,246]"
- `type:Text#5`.clickable: "true" → "false"

### 控件数量变化
- Web: 1 → 0 (-1)
- Image: 0 → 5 (+5)
- Text: 12 → 32 (+20)
- rootWebArea: 1 → 0 (-1)
- Scroll: 0 → 1 (+1)
- TextInput: 2 → 0 (-2)
- Row: 10 → 23 (+13)
- Stack: 15 → 13 (-2)
- genericContainer: 2 → 0 (-2)
- Column: 2 → 26 (+24)
- Button: 2 → 0 (-2)
- Divider: 0 → 5 (+5)
- Toggle: 0 → 2 (+2)

## 断言检查结果

**通过 4/4**

| # | 类型 | 结果 | 说明 | 详情 |
|---|------|------|------|------|
| 1 | exists | PASS | Dark mode selector remains reachable | 找到目标控件 |
| 2 | exists | PASS | Light mode selector remains reachable | 找到目标控件 |
| 3 | exists | PASS | Home navigation remains available after a theme change | 找到目标控件 |
| 4 | page_changed | PASS | Theme and navigation interaction changes the rendered page | 总变化 197 处 |

> **结论**: 所有断言通过，交互行为符合预期。
