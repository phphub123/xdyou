# 交互验证报告

**场景**: Energy page boundary
**描述**: Open the energy card and verify the independent air-conditioner query boundary.

## 交互步骤执行结果

| # | 操作 | 状态 | 详情 |
|---|------|------|------|
| 1 | click | PASS | click (660,1463): No Error |
| 2 | click | PASS | click (660,1217): No Error |
| 3 | snapshot | PASS | 快照保存至 acceptance/runtime/2026-08-06-energy-page/snapshot_01-energy-page |
| 4 | click | PASS | click (1145,269): No Error |
| 5 | snapshot | PASS | 快照保存至 acceptance/runtime/2026-08-06-energy-page/snapshot_02-empty-imei |

## 交互前后界面差异

**摘要**: 新增 51 个节点; 移除 28 个节点; 文本变化 14 处; 属性变化 56 处; 数量变化: Row: 10→14, Column: 2→11, genericContainer: 2→0, TextInput: 2→1, Text: 12→15, Scroll: 0→1, Button: 2→3, Image: 0→5, Web: 1→0, rootWebArea: 1→0, Stack: 15→13, Blank: 0→1

### 文本变化
- `type:Button#1`: "Mock 预览主页（仅 UI，不登录）" → "查询"
- `type:Text#5`: "View" → "尚未查询空调设备；IMEI 不会被持久化或写入日志。"
- `type:Text#10`: "26" → "設置"
- `type:Text#9`: ":" → "豬圖鑑賞"
- `type:Text#7`: "View network interaction" → "睿思論壇"
- `type:Text#2`: "ID" → "宿舍电费与水费"
- `type:Text#8`: "07" → "其他功能"
- `type:Text#11`: "100" → "07"
- `type:Text#4`: "IDS Login password" → "空调能耗"
- `type:Text#0`: "==" → "电量与能耗"
- `type:Text#3`: "PW" → "该查询仅在校园网和真实 IDS 会话可用；未满足条件时会保留真实错误，不显示演示余额。"
- `type:Text#1`: "XDYOU" → "空调设备 IMEI 格式不正确。"
- `type:Text#6`: "Clear cache" → "校園信息"
- `type:Button#0`: "Login" → "‹"

### 新增节点
- `type:Column#2` (Column) 
- `type:Column#10` (Column) 
- `type:Text#14` (Text) 100
- `text:尚未查询空调设备；IMEI 不会被持久化或写入日志。` (Text) 尚未查询空调设备；IMEI 不会被持久化或写入日志。
- `type:Row#13` (Row) 
- `text:‹` (Button) ‹
- `text:豬圖鑑賞` (Text) 豬圖鑑賞
- `type:Image#4` (Image) 
- `key:energyCampusBoundary` (Column) 
- `type:Column#5` (Column) 
- `type:Image#1` (Image) 
- `type:Column#4` (Column) 
- `text:该查询仅在校园网和真实 IDS 会话可用；未满足条件时会保留真实错误，不显示演示余额。` (Text) 该查询仅在校园网和真实 IDS 会话可用；未满足条件时会保留真实错误，不显示演示余额。
- `key:energyAirconEmpty` (Text) 尚未查询空调设备；IMEI 不会被持久化或写入日志。
- `type:Column#7` (Column) 
- `text:空调设备 IMEI 格式不正确。` (Text) 空调设备 IMEI 格式不正确。
- `type:Text#13` (Text) 26
- `key:navTo_settings` (Column) 
- `text:其他功能` (Text) 其他功能
- `text:睿思論壇` (Text) 睿思論壇
- ... 共 51 个

### 移除节点
- `key:loginSubmitButton` (Button) Login
- `key:clearSessionButton` (Text) Clear cache
- `text:PW` (Text) PW
- `type:Stack#14` (Stack) 
- `key:viewNetworkInteraction` (Text) View network interaction
- `type:genericContainer#0` (genericContainer) 
- `key:togglePasswordVisibility` (Text) View
- `text:ID` (Text) ID
- `key:loginLogo` (Stack) 
- `type:Web#0` (Web) https://ids.xidian.edu.cn/authserver/login?service=https%3A%2F%2Fehall.xidian.edu.cn%2Flogin%3Fservice%3Dhttps%3A%2F%2Fehall.xidian.edu.cn%2Fnew%2Findex.html
- `text:View network interaction` (Text) View network interaction
- `type:Stack#13` (Stack) 
- `text:Login` (Button) Login
- `text:XDYOU` (Text) XDYOU
- `text:==` (Text) ==
- `text:Mock 预览主页（仅 UI，不登录）` (Button) Mock 预览主页（仅 UI，不登录）
- `text:Clear cache` (Text) Clear cache
- `text:https://ids.xidian.edu.cn/authserver/login?service=https%3A%2F%2Fehall.xidian.edu.cn%2Flogin%3Fservice%3Dhttps%3A%2F%2Fehall.xidian.edu.cn%2Fnew%2Findex.html` (Web) https://ids.xidian.edu.cn/authserver/login?service=https%3A%2F%2Fehall.xidian.edu.cn%2Flogin%3Fservice%3Dhttps%3A%2F%2Fehall.xidian.edu.cn%2Fnew%2Findex.html
- `key:loginAccountInput` (TextInput) 
- `text:View` (Text) View
- ... 共 28 个

### 属性变化
- `type:Stack#3`.bounds: "[0,0][1320,136]" → "[49,55][1320,136]"
- `type:Column#1`.bounds: "[559,396][762,599]" → "[0,137][1320,2450]"
- `type:Stack#10`.bounds: "[1166,55][1271,136]" → "[1173,69][1271,125]"
- `type:Row#4`.bounds: "[0,0][1320,136]" → "[559,2517][762,2636]"
- `type:Stack#11`.bounds: "[1173,69][1271,125]" → "[520,48][800,136]"
- `type:Button#1`.bounds: "[115,1400][1205,1526]" → "[1033,199][1257,339]"
- `type:Stack#1`.bounds: "[258,935][1034,1068]" → "[0,0][1320,136]"
- `type:Stack#8`.bounds: "[1079,55][1166,136]" → "[1166,55][1271,136]"
- `type:Text#5`.clickable: "true" → "false"
- `type:Text#5`.bounds: "[1034,979][1188,1024]" → "[112,1317][1089,1366]"
- `type:Text#10`.bounds: "[126,66][188,128]" → "[1135,2650][1220,2699]"
- `type:Row#7`.bounds: "[1002,55][1079,136]" → "[49,55][1271,136]"
- `type:Text#9`.bounds: "[111,71][126,124]" → "[834,2650][1003,2699]"
- `type:Text#7`.clickable: "true" → "false"
- `type:Text#7`.bounds: "[581,1589][1020,1634]" → "[317,2650][486,2699]"
- `type:Text#2`.bounds: "[153,804][258,849]" → "[112,514][553,588]"
- `type:Row#3`.bounds: "[49,55][1271,136]" → "[300,2517][503,2636]"
- `type:Text#8`.bounds: "[49,66][111,128]" → "[576,2650][745,2699]"
- `type:Stack#9`.bounds: "[1086,69][1166,125]" → "[1173,69][1271,125]"
- `type:Text#11`.bounds: "[1182,75][1252,120]" → "[49,66][111,128]"
- `type:Text#4`.clickable: "true" → "false"
- `type:Text#4`.bounds: "[258,935][1034,1068]" → "[112,855][364,929]"
- `type:Row#2`.bounds: "[300,1589][1020,1634]" → "[41,2517][244,2636]"
- `type:Stack#0`.bounds: "[506,343][814,651]" → "[0,0][1320,136]"
- `type:Text#0`.bounds: "[629,406][692,468]" → "[245,220][1033,318]"
- `type:Row#5`.bounds: "[49,55][188,136]" → "[817,2517][1020,2636]"
- `type:Text#3`.bounds: "[153,981][258,1022]" → "[112,616][1163,722]"
- `type:Text#1`.bounds: "[583,468][739,600]" → "[63,367][590,416]"
- `type:Row#6`.bounds: "[49,66][126,128]" → "[1076,2517][1279,2636]"
- `type:Row#8`.bounds: "[1086,55][1166,136]" → "[0,0][1320,136]"

### 控件数量变化
- Row: 10 → 14 (+4)
- Column: 2 → 11 (+9)
- genericContainer: 2 → 0 (-2)
- TextInput: 2 → 1 (-1)
- Text: 12 → 15 (+3)
- Scroll: 0 → 1 (+1)
- Button: 2 → 3 (+1)
- Image: 0 → 5 (+5)
- Web: 1 → 0 (-1)
- rootWebArea: 1 → 0 (-1)
- Stack: 15 → 13 (-2)
- Blank: 0 → 1 (+1)

## 断言检查结果

**通过 3/3**

| # | 类型 | 结果 | 说明 | 详情 |
|---|------|------|------|------|
| 1 | exists | PASS | Campus electricity boundary should remain explicit | 找到目标控件 |
| 2 | exists | PASS | Air-conditioner IMEI input should exist | 找到目标控件 |
| 3 | exists | PASS | Invalid independent query should show a real validation error | 找到目标控件 |

> **结论**: 所有断言通过，交互行为符合预期。
