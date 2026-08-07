# 交互验证报告

**场景**: Empty classroom defaults
**描述**: Open empty classroom from preview home and verify current-date defaults and building loading state.

## 交互步骤执行结果

| # | 操作 | 状态 | 详情 |
|---|------|------|------|
| 1 | click | PASS | click (660,1463): No Error |
| 2 | click | PASS | click (811,2032): No Error |
| 3 | snapshot | PASS | 快照保存至 acceptance/runtime/2026-08-06-empty-classroom-defaults/snapshot_01-empty-c |

## 交互前后界面差异

**摘要**: 新增 49 个节点; 移除 27 个节点; 文本变化 15 处; 属性变化 58 处; 数量变化: Scroll: 0→1, Stack: 15→13, rootWebArea: 1→0, Text: 12→13, Row: 10→17, Image: 0→5, TextInput: 2→4, genericContainer: 2→0, Column: 2→9, Web: 1→0

### 文本变化
- `type:Button#1`: "Mock 预览主页（仅 UI，不登录）" → "查询"
- `type:Text#10`: "26" → ":"
- `type:Text#4`: "IDS Login password" → "校園信息"
- `type:Text#11`: "100" → "26"
- `type:Text#1`: "XDYOU" → "A real IDS/Ehall session is required before academic data can load."
- `type:Text#7`: "View network interaction" → "豬圖鑑賞"
- `type:Text#8`: "07" → "設置"
- `type:Text#2`: "ID" → "教室"
- `type:Button#0`: "Login" → "加载教学楼"
- `type:Text#3`: "PW" → "1  2  3  4  5  6  7  8  9 10 11"
- `type:Text#0`: "==" → "空闲教室"
- `type:TextInput#1`: "" → "2026-08-06"
- `type:Text#6`: "Clear cache" → "其他功能"
- `type:Text#9`: ":" → "07"
- `type:Text#5`: "View" → "睿思論壇"

### 新增节点
- `key:emptyClassroomStatus` (Text) A real IDS/Ehall session is required before academic data can load.
- `text:1  2  3  4  5  6  7  8  9 10 11` (Text) 1  2  3  4  5  6  7  8  9 10 11
- `key:navTo_settings` (Column) 
- `type:Image#4` (Image) 
- `key:emptyClassroomMatrix` (Scroll) 
- `text:加载教学楼` (Button) 加载教学楼
- `key:navTo_pig` (Column) 
- `type:Row#12` (Row) 
- `text:A real IDS/Ehall session is required before academic data can load.` (Text) A real IDS/Ehall session is required before academic data can load.
- `type:TextInput#3` (TextInput) 
- `key:emptyClassroomSemesterInput` (TextInput) 2026-1
- `text:空闲教室` (Text) 空闲教室
- `text:查询` (Button) 查询
- `key:navTo_toolbox` (Column) 
- `text:2026-08-06` (TextInput) 2026-08-06
- `text:睿思論壇` (Text) 睿思論壇
- `key:navTo_home` (Column) 
- `type:Row#13` (Row) 
- `type:Row#10` (Row) 
- `key:emptyClassroomDateInput` (TextInput) 2026-08-06
- ... 共 49 个

### 移除节点
- `text:Mock 预览主页（仅 UI，不登录）` (Button) Mock 预览主页（仅 UI，不登录）
- `text:Login` (Button) Login
- `type:Stack#13` (Stack) 
- `type:genericContainer#1` (genericContainer) 
- `key:loginSubmitButton` (Button) Login
- `key:loginPasswordMask` (Text) IDS Login password
- `key:loginAccountInput` (TextInput) 
- `text:View` (Text) View
- `text:https://ids.xidian.edu.cn/authserver/login?service=https%3A%2F%2Fehall.xidian.edu.cn%2Flogin%3Fservice%3Dhttps%3A%2F%2Fehall.xidian.edu.cn%2Fnew%2Findex.html` (Web) https://ids.xidian.edu.cn/authserver/login?service=https%3A%2F%2Fehall.xidian.edu.cn%2Flogin%3Fservice%3Dhttps%3A%2F%2Fehall.xidian.edu.cn%2Fnew%2Findex.html
- `text:XDYOU` (Text) XDYOU
- `text:ID` (Text) ID
- `key:togglePasswordVisibility` (Text) View
- `type:rootWebArea#0` (rootWebArea) 
- `type:Web#0` (Web) https://ids.xidian.edu.cn/authserver/login?service=https%3A%2F%2Fehall.xidian.edu.cn%2Flogin%3Fservice%3Dhttps%3A%2F%2Fehall.xidian.edu.cn%2Fnew%2Findex.html
- `type:genericContainer#0` (genericContainer) 
- `type:Stack#14` (Stack) 
- `key:clearSessionButton` (Text) Clear cache
- `text:Clear cache` (Text) Clear cache
- `key:idsCookieBootstrap` (Web) https://ids.xidian.edu.cn/authserver/login?service=https%3A%2F%2Fehall.xidian.edu.cn%2Flogin%3Fservice%3Dhttps%3A%2F%2Fehall.xidian.edu.cn%2Fnew%2Findex.html
- `key:loginLogo` (Stack) 
- ... 共 27 个

### 属性变化
- `type:Row#7`.bounds: "[1002,55][1079,136]" → "[559,2517][762,2636]"
- `type:Stack#0`.bounds: "[506,343][814,651]" → "[0,0][1320,136]"
- `type:Button#1`.bounds: "[115,1400][1205,1526]" → "[1033,719][1257,859]"
- `type:Row#6`.bounds: "[49,66][126,128]" → "[300,2517][503,2636]"
- `type:Stack#6`.bounds: "[49,55][188,136]" → "[1079,55][1166,136]"
- `type:Stack#11`.bounds: "[1173,69][1271,125]" → "[520,48][800,136]"
- `type:Text#10`.bounds: "[126,66][188,128]" → "[111,71][126,124]"
- `type:Text#4`.clickable: "true" → "false"
- `type:Text#4`.bounds: "[258,935][1034,1068]" → "[58,2650][227,2699]"
- `type:Row#5`.bounds: "[49,55][188,136]" → "[41,2517][244,2636]"
- `type:Text#11`.bounds: "[1182,75][1252,120]" → "[126,66][188,128]"
- `type:Text#1`.bounds: "[583,468][739,600]" → "[63,894][1238,992]"
- `type:Text#7`.clickable: "true" → "false"
- `type:Text#7`.bounds: "[581,1589][1020,1634]" → "[834,2650][1003,2699]"
- `type:Row#3`.bounds: "[49,55][1271,136]" → "[63,992][1257,1121]"
- `type:Row#8`.bounds: "[1086,55][1166,136]" → "[817,2517][1020,2636]"
- `type:Row#9`.bounds: "[1173,55][1271,136]" → "[1076,2517][1279,2636]"
- `type:Text#8`.bounds: "[49,66][111,128]" → "[1135,2650][1220,2699]"
- `type:Stack#10`.bounds: "[1166,55][1271,136]" → "[1173,69][1271,125]"
- `type:Text#2`.bounds: "[153,804][258,849]" → "[63,1034][404,1100]"
- `type:Stack#1`.bounds: "[258,935][1034,1068]" → "[0,0][1320,136]"
- `type:Button#0`.bounds: "[115,1232][1205,1372]" → "[865,355][1257,495]"
- `type:Text#3`.bounds: "[153,981][258,1022]" → "[404,1034][1257,1100]"
- `type:Stack#7`.bounds: "[995,55][1079,136]" → "[1086,69][1166,125]"
- `type:Row#0`.bounds: "[115,756][1205,896]" → "[63,348][1257,502]"
- `type:Stack#5`.bounds: "[49,55][1320,136]" → "[995,55][1079,136]"
- `type:Stack#9`.bounds: "[1086,69][1166,125]" → "[1173,69][1271,125]"
- `type:Column#1`.bounds: "[559,396][762,599]" → "[0,137][1320,2450]"
- `type:Stack#12`.bounds: "[1173,69][1271,125]" → "[520,48][800,136]"
- `type:TextInput#0`.bounds: "[258,760][1174,893]" → "[63,355][837,495]"

### 控件数量变化
- Scroll: 0 → 1 (+1)
- Stack: 15 → 13 (-2)
- rootWebArea: 1 → 0 (-1)
- Text: 12 → 13 (+1)
- Row: 10 → 17 (+7)
- Image: 0 → 5 (+5)
- TextInput: 2 → 4 (+2)
- genericContainer: 2 → 0 (-2)
- Column: 2 → 9 (+7)
- Web: 1 → 0 (-1)

## 断言检查结果

**通过 3/3**

| # | 类型 | 结果 | 说明 | 详情 |
|---|------|------|------|------|
| 1 | exists | PASS | Current date input should be available | 找到目标控件 |
| 2 | exists | PASS | Derived semester input should be available | 找到目标控件 |
| 3 | exists | PASS | Loading or external failure status should be explicit | 找到目标控件 |

> **结论**: 所有断言通过，交互行为符合预期。
