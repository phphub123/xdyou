# 交互验证报告

**场景**: Energy page boundary
**描述**: Open the energy card and verify the independent air-conditioner query boundary.

## 交互步骤执行结果

| # | 操作 | 状态 | 详情 |
|---|------|------|------|
| 1 | click | PASS | click (660,1463): No Error |
| 2 | click | PASS | click (660,1217): No Error |
| 3 | snapshot | PASS | 快照保存至 C:\Users\21768\Desktop\XDYou-Cangjie-Codex-Workspace\acceptance\runtime\20 |
| 4 | click | PASS | click (1145,269): No Error |
| 5 | snapshot | PASS | 快照保存至 C:\Users\21768\Desktop\XDYou-Cangjie-Codex-Workspace\acceptance\runtime\20 |

## 交互前后界面差异

**摘要**: 新增 53 个节点; 移除 30 个节点; 文本变化 16 处; 属性变化 58 处; 数量变化: TextInput: 2→1, Image: 0→5, Text: 12→15, Web: 1→0, Row: 10→14, Column: 2→11, genericContainer: 2→0, Button: 2→3, rootWebArea: 1→0, Blank: 0→1, Scroll: 0→1, Stack: 15→13

### 文本变化
- `type:Text#0`: "==" → "电量与能耗"
- `type:Text#2`: "ID" → "宿舍电费与水费"
- `type:Button#0`: "Login" → "‹"
- `type:Text#4`: "IDS Login password" → "空调能耗"
- `type:Button#1`: "Mock 预览主页（仅 UI，不登录）" → "查询"
- `type:Text#8`: "08" → "其他功能"
- `type:Text#1`: "XDYOU" → "空调设备 IMEI 格式不正确。"
- `type:Text#9`: ":" → "豬圖鑑賞"
- `type:Text#5`: "View" → "尚未查询空调设备；IMEI 不会被持久化或写入日志。"
- `type:Text#6`: "Clear cache" → "校園信息"
- `key:ClockStatusView`: "08, :, 37" → "08, :, 38"
- `type:Text#7`: "View network interaction" → "睿思論壇"
- `type:Text#10`: "37" → "設置"
- `type:Text#11`: "100" → "08"
- `type:Text#3`: "PW" → "该查询仅在校园网和真实 IDS 会话可用；未满足条件时会保留真实错误，不显示演示余额。"
- `type:Flex#0`: "08, :, 37" → "08, :, 38"

### 新增节点
- `type:Column#8` (Column) 
- `text:尚未查询空调设备；IMEI 不会被持久化或写入日志。` (Text) 尚未查询空调设备；IMEI 不会被持久化或写入日志。
- `text:校園信息` (Text) 校園信息
- `type:Text#14` (Text) 100
- `key:energyStatus` (Text) 空调设备 IMEI 格式不正确。
- `text:睿思論壇` (Text) 睿思論壇
- `type:Column#10` (Column) 
- `type:Image#3` (Image) 
- `key:energyImeiInput` (TextInput) 
- `type:Row#10` (Row) 
- `type:Image#1` (Image) 
- `type:Text#12` (Text) :
- `text:使用 IMEI 查询` (Button) 使用 IMEI 查询
- `type:Row#11` (Row) 
- `type:Column#5` (Column) 
- `text:电量与能耗` (Text) 电量与能耗
- `text:設置` (Text) 設置
- `text:空调能耗` (Text) 空调能耗
- `key:energyCampusBoundary` (Column) 
- `key:energyAirconEmpty` (Text) 尚未查询空调设备；IMEI 不会被持久化或写入日志。
- ... 共 53 个

### 移除节点
- `key:idsCookieBootstrap` (Web) https://ids.xidian.edu.cn/authserver/login?service=https%3A%2F%2Fehall.xidian.edu.cn%2Flogin%3Fservice%3Dhttps%3A%2F%2Fehall.xidian.edu.cn%2Fnew%2Findex.html
- `key:loginLogo` (Stack) 
- `key:viewNetworkInteraction` (Text) View network interaction
- `text:Clear cache` (Text) Clear cache
- `key:loginPasswordInput` (TextInput) 
- `text:ID` (Text) ID
- `key:mockHomePreviewButton` (Button) Mock 预览主页（仅 UI，不登录）
- `text:XDYOU` (Text) XDYOU
- `type:genericContainer#0` (genericContainer) 
- `type:Stack#14` (Stack) 
- `type:rootWebArea#0` (rootWebArea) 
- `text:Login` (Button) Login
- `text:PW` (Text) PW
- `key:loginPasswordMask` (Text) IDS Login password
- `text:View` (Text) View
- `text:37` (Text) 37
- `text:IDS Login password` (Text) IDS Login password
- `key:togglePasswordVisibility` (Text) View
- `text:https://ids.xidian.edu.cn/authserver/login?service=https%3A%2F%2Fehall.xidian.edu.cn%2Flogin%3Fservice%3Dhttps%3A%2F%2Fehall.xidian.edu.cn%2Fnew%2Findex.html` (Web) https://ids.xidian.edu.cn/authserver/login?service=https%3A%2F%2Fehall.xidian.edu.cn%2Flogin%3Fservice%3Dhttps%3A%2F%2Fehall.xidian.edu.cn%2Fnew%2Findex.html
- `type:genericContainer#1` (genericContainer) 
- ... 共 30 个

### 属性变化
- `type:Stack#0`.bounds: "[506,343][814,651]" → "[0,0][1320,136]"
- `type:Stack#3`.bounds: "[0,0][1320,136]" → "[49,55][1320,136]"
- `type:Text#0`.bounds: "[629,406][692,468]" → "[245,220][1033,318]"
- `type:Text#2`.bounds: "[153,804][258,849]" → "[112,514][553,588]"
- `type:Stack#6`.bounds: "[49,55][188,136]" → "[1079,55][1166,136]"
- `type:Stack#12`.bounds: "[1173,69][1271,125]" → "[520,48][800,136]"
- `type:Button#0`.bounds: "[115,1232][1205,1372]" → "[63,199][217,339]"
- `type:Row#8`.bounds: "[1086,55][1166,136]" → "[0,0][1320,136]"
- `type:Row#5`.bounds: "[49,55][188,136]" → "[817,2517][1020,2636]"
- `type:Text#4`.clickable: "true" → "false"
- `type:Text#4`.bounds: "[258,935][1034,1068]" → "[112,855][364,929]"
- `type:Row#3`.bounds: "[49,55][1271,136]" → "[300,2517][503,2636]"
- `type:Button#1`.bounds: "[115,1400][1205,1526]" → "[1033,199][1257,339]"
- `type:Stack#8`.bounds: "[1079,55][1166,136]" → "[1166,55][1271,136]"
- `type:Text#8`.bounds: "[49,66][111,128]" → "[576,2650][745,2699]"
- `type:Text#1`.bounds: "[583,468][739,600]" → "[63,367][590,416]"
- `type:Stack#11`.bounds: "[1173,69][1271,125]" → "[520,48][800,136]"
- `type:Stack#1`.bounds: "[258,935][1034,1068]" → "[0,0][1320,136]"
- `type:Row#7`.bounds: "[1002,55][1079,136]" → "[49,55][1271,136]"
- `type:Row#4`.bounds: "[0,0][1320,136]" → "[559,2517][762,2636]"
- `type:Text#9`.bounds: "[111,71][126,124]" → "[834,2650][1003,2699]"
- `type:Row#0`.bounds: "[115,756][1205,896]" → "[63,199][1257,339]"
- `type:Row#1`.bounds: "[115,931][1205,1071]" → "[0,2450][1320,2758]"
- `type:TextInput#0`.bounds: "[258,760][1174,893]" → "[112,964][1208,1111]"
- `type:Stack#9`.bounds: "[1086,69][1166,125]" → "[1173,69][1271,125]"
- `type:Text#5`.clickable: "true" → "false"
- `type:Text#5`.bounds: "[1034,979][1188,1024]" → "[112,1317][1089,1366]"
- `type:Row#6`.bounds: "[49,66][126,128]" → "[1076,2517][1279,2636]"
- `type:Row#2`.bounds: "[300,1589][1020,1634]" → "[41,2517][244,2636]"
- `type:Text#6`.clickable: "true" → "false"

### 控件数量变化
- TextInput: 2 → 1 (-1)
- Image: 0 → 5 (+5)
- Text: 12 → 15 (+3)
- Web: 1 → 0 (-1)
- Row: 10 → 14 (+4)
- Column: 2 → 11 (+9)
- genericContainer: 2 → 0 (-2)
- Button: 2 → 3 (+1)
- rootWebArea: 1 → 0 (-1)
- Blank: 0 → 1 (+1)
- Scroll: 0 → 1 (+1)
- Stack: 15 → 13 (-2)

## 断言检查结果

**通过 3/3**

| # | 类型 | 结果 | 说明 | 详情 |
|---|------|------|------|------|
| 1 | exists | PASS | Campus electricity boundary should remain explicit | 找到目标控件 |
| 2 | exists | PASS | Air-conditioner IMEI input should exist | 找到目标控件 |
| 3 | exists | PASS | Invalid independent query should show a real validation error | 找到目标控件 |

> **结论**: 所有断言通过，交互行为符合预期。
