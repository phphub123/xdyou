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

**摘要**: 新增 105 个节点; 移除 31 个节点; 文本变化 12 处; 属性变化 55 处; 数量变化: Divider: 0→5, Column: 2→26, Row: 10→23, Scroll: 0→1, Text: 12→32, Stack: 15→13, TextInput: 2→0, Web: 1→0, Image: 0→5, Button: 2→0, Toggle: 0→2, rootWebArea: 1→0, genericContainer: 2→0

### 文本变化
- `type:Text#9`: ":" → "春風綠"
- `type:Text#5`: "View" → "最新版本：等待獲取"
- `type:Text#7`: "View network interaction" → "界面設置"
- `type:Text#11`: "100" → "設置深淺色"
- `type:Text#1`: "XDYOU" → "關於本程序"
- `type:Text#2`: "ID" → "版本號：1.0.0+1"
- `type:Text#4`: "IDS Login password" → "檢查軟件更新"
- `type:Text#6`: "Clear cache" → "›"
- `type:Text#0`: "==" → "關於"
- `type:Text#8`: "11" → "顏色設置"
- `type:Text#10`: "13" → "›"
- `type:Text#3`: "PW" → "›"

### 新增节点
- `type:Column#22` (Column) 
- `text:關於本程序` (Text) 關於本程序
- `type:Text#26` (Text) 豬圖鑑賞
- `type:Column#17` (Column) 
- `key:settingsThemeSystem` (Text) ▯
- `type:Image#4` (Image) 
- `type:Text#23` (Text) 校園信息
- `text:低電量閾值` (Text) 低電量閾值
- `type:Image#1` (Image) 
- `type:Text#21` (Text) 目前為 15 度
- `type:Row#15` (Row) 
- `key:navTo_ruisi` (Column) 
- `key:navTo_settings` (Column) 
- `type:Text#27` (Text) 設置
- `type:Text#14` (Text) ☼
- `type:Column#19` (Column) 
- `key:navTo_toolbox` (Column) 
- `type:Row#20` (Row) 
- `type:Row#14` (Row) 
- `type:Image#3` (Image) 
- ... 共 105 个

### 移除节点
- `text:View` (Text) View
- `type:genericContainer#1` (genericContainer) 
- `type:Button#1` (Button) Mock 预览主页（仅 UI，不登录）
- `text:Clear cache` (Text) Clear cache
- `key:loginLogo` (Stack) 
- `text:Mock 预览主页（仅 UI，不登录）` (Button) Mock 预览主页（仅 UI，不登录）
- `key:loginPasswordInput` (TextInput) 
- `text:PW` (Text) PW
- `type:Web#0` (Web) https://ids.xidian.edu.cn/authserver/login?service=https%3A%2F%2Fehall.xidian.edu.cn%2Flogin%3Fservice%3Dhttps%3A%2F%2Fehall.xidian.edu.cn%2Fnew%2Findex.html
- `key:loginPasswordMask` (Text) IDS Login password
- `text:https://ids.xidian.edu.cn/authserver/login?service=https%3A%2F%2Fehall.xidian.edu.cn%2Flogin%3Fservice%3Dhttps%3A%2F%2Fehall.xidian.edu.cn%2Fnew%2Findex.html` (Web) https://ids.xidian.edu.cn/authserver/login?service=https%3A%2F%2Fehall.xidian.edu.cn%2Flogin%3Fservice%3Dhttps%3A%2F%2Fehall.xidian.edu.cn%2Fnew%2Findex.html
- `type:Stack#14` (Stack) 
- `text:ID` (Text) ID
- `text:Login` (Button) Login
- `key:loginSubmitButton` (Button) Login
- `type:rootWebArea#0` (rootWebArea) 
- `key:idsCookieBootstrap` (Web) https://ids.xidian.edu.cn/authserver/login?service=https%3A%2F%2Fehall.xidian.edu.cn%2Flogin%3Fservice%3Dhttps%3A%2F%2Fehall.xidian.edu.cn%2Fnew%2Findex.html
- `type:Stack#13` (Stack) 
- `text:XDYOU` (Text) XDYOU
- `type:Button#0` (Button) Login
- ... 共 31 个

### 属性变化
- `type:Row#4`.clickable: "false" → "true"
- `type:Row#4`.bounds: "[0,0][1320,136]" → "[59,1050][1261,1337]"
- `type:Text#9`.bounds: "[111,71][126,124]" → "[129,1203][277,1260]"
- `type:Stack#10`.bounds: "[1166,55][1271,136]" → "[1173,69][1271,125]"
- `type:Stack#7`.bounds: "[995,55][1079,136]" → "[1086,69][1166,125]"
- `type:Stack#6`.bounds: "[49,55][188,136]" → "[1079,55][1166,136]"
- `type:Text#5`.clickable: "true" → "false"
- `type:Text#5`.bounds: "[1034,979][1188,1024]" → "[129,734][571,791]"
- `type:Text#7`.clickable: "true" → "false"
- `type:Text#7`.bounds: "[581,1589][1020,1634]" → "[548,940][772,1006]"
- `type:Row#1`.clickable: "false" → "true"
- `type:Row#1`.bounds: "[115,931][1205,1071]" → "[59,290][1261,577]"
- `type:Row#0`.bounds: "[115,756][1205,896]" → "[59,137][1261,290]"
- `type:Row#5`.bounds: "[49,55][188,136]" → "[59,1341][1261,1628]"
- `type:Text#11`.bounds: "[1182,75][1252,120]" → "[129,1418][409,1484]"
- `type:Stack#5`.bounds: "[49,55][1320,136]" → "[995,55][1079,136]"
- `type:Row#2`.clickable: "false" → "true"
- `type:Row#2`.bounds: "[300,1589][1020,1634]" → "[59,581][1261,868]"
- `type:Row#3`.bounds: "[49,55][1271,136]" → "[59,896][1261,1050]"
- `type:Stack#11`.bounds: "[1173,69][1271,125]" → "[520,48][800,136]"
- `type:Row#7`.bounds: "[1002,55][1079,136]" → "[59,1631][1261,1918]"
- `type:Stack#0`.bounds: "[506,343][814,651]" → "[0,0][1320,136]"
- `type:Text#1`.bounds: "[583,468][739,600]" → "[129,367][409,433]"
- `type:Row#8`.bounds: "[1086,55][1166,136]" → "[59,1922][1261,2209]"
- `type:Text#2`.bounds: "[153,804][258,849]" → "[129,443][488,500]"
- `type:Stack#9`.bounds: "[1086,69][1166,125]" → "[1173,69][1271,125]"
- `type:Row#9`.clickable: "false" → "true"
- `type:Row#9`.bounds: "[1173,55][1271,136]" → "[59,2212][1261,2450]"
- `type:Row#6`.bounds: "[49,66][126,128]" → "[793,1418][1198,1551]"
- `type:Stack#8`.bounds: "[1079,55][1166,136]" → "[1166,55][1271,136]"

### 控件数量变化
- Divider: 0 → 5 (+5)
- Column: 2 → 26 (+24)
- Row: 10 → 23 (+13)
- Scroll: 0 → 1 (+1)
- Text: 12 → 32 (+20)
- Stack: 15 → 13 (-2)
- TextInput: 2 → 0 (-2)
- Web: 1 → 0 (-1)
- Image: 0 → 5 (+5)
- Button: 2 → 0 (-2)
- Toggle: 0 → 2 (+2)
- rootWebArea: 1 → 0 (-1)
- genericContainer: 2 → 0 (-2)

## 断言检查结果

**通过 4/4**

| # | 类型 | 结果 | 说明 | 详情 |
|---|------|------|------|------|
| 1 | exists | PASS | Dark mode selector remains reachable | 找到目标控件 |
| 2 | exists | PASS | Light mode selector remains reachable | 找到目标控件 |
| 3 | exists | PASS | Home navigation remains available after a theme change | 找到目标控件 |
| 4 | page_changed | PASS | Theme and navigation interaction changes the rendered page | 总变化 191 处 |

> **结论**: 所有断言通过，交互行为符合预期。
