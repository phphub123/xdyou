# 交互验证报告

**场景**: XDYou settings color mode
**描述**: Verify that the migrated Flutter brightness preference updates the running Cangjie settings shell and remains available across navigation.

## 交互步骤执行结果

| # | 操作 | 状态 | 详情 |
|---|------|------|------|
| 1 | click | PASS | click (660,1463): No Error |
| 2 | click | PASS | click (1177,2607): No Error |
| 3 | click | PASS | click (1128,1484): No Error |
| 4 | snapshot | PASS | 快照保存至 /Users/niu/huawei/Project1/traintime_pda_ohos/xdyou/acceptance/runtime/202 |
| 5 | click | PASS | click (142,2607): No Error |
| 6 | snapshot | PASS | 快照保存至 /Users/niu/huawei/Project1/traintime_pda_ohos/xdyou/acceptance/runtime/202 |
| 7 | click | PASS | click (1177,2607): No Error |
| 8 | click | PASS | click (995,1484): No Error |
| 9 | snapshot | PASS | 快照保存至 /Users/niu/huawei/Project1/traintime_pda_ohos/xdyou/acceptance/runtime/202 |

## 交互前后界面差异

**摘要**: 新增 107 个节点; 移除 33 个节点; 文本变化 14 处; 属性变化 57 处; 数量变化: Button: 2→0, TextInput: 2→0, Divider: 0→5, rootWebArea: 1→0, Image: 0→5, Toggle: 0→2, genericContainer: 2→0, Column: 2→26, Stack: 15→13, Scroll: 0→1, Text: 12→32, Web: 1→0, Row: 10→23

### 文本变化
- `type:Text#8`: "11" → "顏色設置"
- `type:Text#10`: "05" → "›"
- `type:Text#0`: "==" → "關於"
- `type:Text#7`: "View network interaction" → "界面設置"
- `type:Text#2`: "ID" → "版本號：1.0.0+1"
- `type:Text#4`: "IDS Login password" → "檢查軟件更新"
- `type:Text#11`: "100" → "設置深淺色"
- `type:Text#9`: ":" → "春風綠"
- `type:Text#1`: "XDYOU" → "關於本程序"
- `type:Flex#0`: "11, :, 05" → "11, :, 06"
- `type:Text#5`: "View" → "最新版本：等待獲取"
- `type:Text#6`: "Clear cache" → "›"
- `key:ClockStatusView`: "11, :, 05" → "11, :, 06"
- `type:Text#3`: "PW" → "›"

### 新增节点
- `type:Column#7` (Column) 
- `type:Toggle#0` (Toggle) 
- `key:settingsLowElectricityToggle` (Toggle) 
- `key:settingsThemeSystem` (Text) ▯
- `type:Row#21` (Row) 
- `text:◕` (Text) ◕
- `type:Column#10` (Column) 
- `type:Row#13` (Row) 
- `type:Row#11` (Row) 
- `key:settingsTimelineToggle` (Toggle) 
- `type:Text#12` (Text) 黑夜模式
- `type:Text#19` (Text) 電量小於閾值時 電量卡片變色提醒
- `type:Column#15` (Column) 
- `type:Image#0` (Image) 
- `text:設置深淺色` (Text) 設置深淺色
- `type:Column#24` (Column) 
- `type:Row#12` (Row) 
- `type:Column#17` (Column) 
- `type:Column#18` (Column) 
- `text:沒有日程時 減少空間佔用` (Text) 沒有日程時 減少空間佔用
- ... 共 107 个

### 移除节点
- `text:IDS Login password` (Text) IDS Login password
- `key:loginSubmitButton` (Button) Login
- `key:loginPasswordInput` (TextInput) 
- `type:genericContainer#0` (genericContainer) 
- `type:rootWebArea#0` (rootWebArea) 
- `text:https://ids.xidian.edu.cn/authserver/login?service=https%3A%2F%2Fehall.xidian.edu.cn%2Flogin%3Fservice%3Dhttps%3A%2F%2Fehall.xidian.edu.cn%2Fnew%2Findex.html` (Web) https://ids.xidian.edu.cn/authserver/login?service=https%3A%2F%2Fehall.xidian.edu.cn%2Flogin%3Fservice%3Dhttps%3A%2F%2Fehall.xidian.edu.cn%2Fnew%2Findex.html
- `type:Button#0` (Button) Login
- `key:togglePasswordVisibility` (Text) View
- `text:Clear cache` (Text) Clear cache
- `text:ID` (Text) ID
- `key:mockHomePreviewButton` (Button) Mock 预览主页（仅 UI，不登录）
- `text:11, :, 05` (Flex) 11, :, 05
- `text:XDYOU` (Text) XDYOU
- `key:loginLogo` (Stack) 
- `key:loginAccountInput` (TextInput) 
- `key:viewNetworkInteraction` (Text) View network interaction
- `text:05` (Text) 05
- `type:genericContainer#1` (genericContainer) 
- `text:==` (Text) ==
- `type:TextInput#0` (TextInput) 
- ... 共 33 个

### 属性变化
- `type:Stack#4`.bounds: "[0,0][1320,136]" → "[49,55][188,136]"
- `type:Stack#6`.bounds: "[49,55][188,136]" → "[1079,55][1166,136]"
- `type:Text#8`.bounds: "[49,66][111,128]" → "[129,1127][353,1193]"
- `type:Row#3`.bounds: "[49,55][1271,136]" → "[59,896][1261,1050]"
- `type:Row#5`.bounds: "[49,55][188,136]" → "[59,1341][1261,1628]"
- `type:Stack#8`.bounds: "[1079,55][1166,136]" → "[1166,55][1271,136]"
- `type:Stack#1`.bounds: "[258,935][1034,1068]" → "[0,0][1320,136]"
- `type:Text#10`.bounds: "[126,66][188,128]" → "[1129,1132][1163,1255]"
- `type:Row#2`.clickable: "false" → "true"
- `type:Row#2`.bounds: "[300,1589][1020,1634]" → "[59,581][1261,868]"
- `type:Row#9`.clickable: "false" → "true"
- `type:Row#9`.bounds: "[1173,55][1271,136]" → "[59,2212][1261,2450]"
- `type:Stack#5`.bounds: "[49,55][1320,136]" → "[995,55][1079,136]"
- `type:Text#0`.bounds: "[629,406][692,468]" → "[604,180][716,246]"
- `type:Text#7`.clickable: "true" → "false"
- `type:Text#7`.bounds: "[581,1589][1020,1634]" → "[548,940][772,1006]"
- `type:Text#2`.bounds: "[153,804][258,849]" → "[129,443][488,500]"
- `type:Stack#3`.bounds: "[0,0][1320,136]" → "[49,55][1320,136]"
- `type:Column#1`.bounds: "[559,396][762,599]" → "[0,137][1320,2450]"
- `type:Text#4`.clickable: "true" → "false"
- `type:Text#4`.bounds: "[258,935][1034,1068]" → "[129,658][465,724]"
- `type:Row#0`.bounds: "[115,756][1205,896]" → "[59,137][1261,290]"
- `type:Row#4`.clickable: "false" → "true"
- `type:Row#4`.bounds: "[0,0][1320,136]" → "[59,1050][1261,1337]"
- `type:Row#1`.clickable: "false" → "true"
- `type:Row#1`.bounds: "[115,931][1205,1071]" → "[59,290][1261,577]"
- `type:Text#11`.bounds: "[1182,75][1252,120]" → "[129,1418][409,1484]"
- `type:Text#9`.bounds: "[111,71][126,124]" → "[129,1203][277,1260]"
- `type:Text#1`.bounds: "[583,468][739,600]" → "[129,367][409,433]"
- `type:Stack#9`.bounds: "[1086,69][1166,125]" → "[1173,69][1271,125]"

### 控件数量变化
- Button: 2 → 0 (-2)
- TextInput: 2 → 0 (-2)
- Divider: 0 → 5 (+5)
- rootWebArea: 1 → 0 (-1)
- Image: 0 → 5 (+5)
- Toggle: 0 → 2 (+2)
- genericContainer: 2 → 0 (-2)
- Column: 2 → 26 (+24)
- Stack: 15 → 13 (-2)
- Scroll: 0 → 1 (+1)
- Text: 12 → 32 (+20)
- Web: 1 → 0 (-1)
- Row: 10 → 23 (+13)

## 断言检查结果

**通过 3/4**

| # | 类型 | 结果 | 说明 | 详情 |
|---|------|------|------|------|
| 1 | exists | PASS | Dark mode selector remains reachable | 找到目标控件 |
| 2 | exists | PASS | Light mode selector remains reachable | 找到目标控件 |
| 3 | exists | FAIL | Home remains reachable after a theme change | 未找到: {'key': 'homeScheduleCard'} |
| 4 | page_changed | PASS | Theme and navigation interaction changes the rendered page | 总变化 197 处 |

> **结论**: 存在断言失败，需检查以下问题：

> - Home remains reachable after a theme change
