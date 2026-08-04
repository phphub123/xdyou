# 交互验证报告

**场景**: Experiment page navigation and groups
**描述**: Open preview home and verify the real physics/other experiment boundary without entering credentials.

## 交互步骤执行结果

| # | 操作 | 状态 | 详情 |
|---|------|------|------|
| 1 | click | PASS | click (660,1463): No Error |
| 2 | click | PASS | click (811,2323): No Error |
| 3 | snapshot | PASS | 快照保存至 C:\Users\21768\Desktop\XDYou-Cangjie-Codex-Workspace\acceptance\runtime\20 |
| 4 | click | PASS | click (972,524): No Error |
| 5 | click | PASS | click (1145,269): No Error |
| 6 | snapshot | PASS | 快照保存至 C:\Users\21768\Desktop\XDYou-Cangjie-Codex-Workspace\acceptance\runtime\20 |

## 交互前后界面差异

**摘要**: 新增 54 个节点; 移除 29 个节点; 文本变化 10 处; 属性变化 47 处; 数量变化: Image: 0→5, Stack: 15→13, Row: 10→16, Web: 1→0, Blank: 0→1, Column: 2→9, genericContainer: 2→0, Button: 2→7, TextInput: 2→0, Scroll: 0→1, rootWebArea: 1→0

### 文本变化
- `type:Text#7`: "View network interaction" → "設置"
- `type:Text#5`: "View" → "其他功能"
- `type:Text#6`: "Clear cache" → "豬圖鑑賞"
- `type:Text#2`: "ID" → "其他实验需要真实 IDS 会话和校园网；点击刷新会执行真实 OAuth 与 25 周课表请求。"
- `type:Text#4`: "IDS Login password" → "睿思論壇"
- `type:Text#3`: "PW" → "校園信息"
- `type:Text#0`: "==" → "实验信息"
- `type:Button#0`: "Login" → "‹"
- `type:Button#1`: "Mock 预览主页（仅 UI，不登录）" → "刷新"
- `type:Text#1`: "XDYOU" → "其他实验需要真实 IDS 会话，请先完成正式登录。"

### 新增节点
- `type:Row#15` (Row) 
- `type:Column#8` (Column) 
- `text:已完成` (Button) 已完成
- `type:Image#2` (Image) 
- `key:experimentUpcomingTab` (Button) 未完成
- `type:Image#3` (Image) 
- `type:Image#0` (Image) 
- `key:experimentFinishedTab` (Button) 已完成
- `type:Column#2` (Column) 
- `key:experimentStatus` (Text) 其他实验需要真实 IDS 会话，请先完成正式登录。
- `type:Row#11` (Row) 
- `type:Button#3` (Button) 其他实验
- `type:Blank#0` (Blank) 
- `type:Column#5` (Column) 
- `text:豬圖鑑賞` (Text) 豬圖鑑賞
- `type:Image#4` (Image) 
- `key:navTo_ruisi` (Column) 
- `text:‹` (Button) ‹
- `type:Image#1` (Image) 
- `text:其他实验需要真实 IDS 会话，请先完成正式登录。` (Text) 其他实验需要真实 IDS 会话，请先完成正式登录。
- ... 共 54 个

### 移除节点
- `key:mockHomePreviewButton` (Button) Mock 预览主页（仅 UI，不登录）
- `key:idsCookieBootstrap` (Web) https://ids.xidian.edu.cn/authserver/login?service=https%3A%2F%2Fehall.xidian.edu.cn%2Flogin%3Fservice%3Dhttps%3A%2F%2Fehall.xidian.edu.cn%2Fnew%2Findex.html
- `key:loginLogo` (Stack) 
- `text:Clear cache` (Text) Clear cache
- `text:https://ids.xidian.edu.cn/authserver/login?service=https%3A%2F%2Fehall.xidian.edu.cn%2Flogin%3Fservice%3Dhttps%3A%2F%2Fehall.xidian.edu.cn%2Fnew%2Findex.html` (Web) https://ids.xidian.edu.cn/authserver/login?service=https%3A%2F%2Fehall.xidian.edu.cn%2Flogin%3Fservice%3Dhttps%3A%2F%2Fehall.xidian.edu.cn%2Fnew%2Findex.html
- `type:Stack#14` (Stack) 
- `text:View network interaction` (Text) View network interaction
- `key:loginAccountInput` (TextInput) 
- `text:PW` (Text) PW
- `key:viewNetworkInteraction` (Text) View network interaction
- `text:Mock 预览主页（仅 UI，不登录）` (Button) Mock 预览主页（仅 UI，不登录）
- `key:loginPasswordMask` (Text) IDS Login password
- `text:XDYOU` (Text) XDYOU
- `key:loginSubmitButton` (Button) Login
- `text:View` (Text) View
- `type:Stack#13` (Stack) 
- `type:TextInput#1` (TextInput) 
- `key:togglePasswordVisibility` (Text) View
- `type:rootWebArea#0` (rootWebArea) 
- `type:TextInput#0` (TextInput) 
- ... 共 29 个

### 属性变化
- `type:Row#0`.bounds: "[115,756][1205,896]" → "[63,199][1257,339]"
- `type:Row#7`.bounds: "[1002,55][1079,136]" → "[817,2517][1020,2636]"
- `type:Text#7`.clickable: "true" → "false"
- `type:Text#7`.bounds: "[581,1589][1020,1634]" → "[1135,2650][1220,2699]"
- `type:Text#5`.clickable: "true" → "false"
- `type:Text#5`.bounds: "[1034,979][1188,1024]" → "[576,2650][745,2699]"
- `type:Text#6`.clickable: "true" → "false"
- `type:Text#6`.bounds: "[300,1589][504,1634]" → "[834,2650][1003,2699]"
- `type:Text#2`.bounds: "[153,804][258,849]" → "[63,1525][1257,1631]"
- `type:Stack#8`.bounds: "[1079,55][1166,136]" → "[1166,55][1271,136]"
- `type:Row#4`.bounds: "[0,0][1320,136]" → "[41,2517][244,2636]"
- `type:Stack#1`.bounds: "[258,935][1034,1068]" → "[0,0][1320,136]"
- `type:Stack#7`.bounds: "[995,55][1079,136]" → "[1086,69][1166,125]"
- `type:Stack#9`.bounds: "[1086,69][1166,125]" → "[1173,69][1271,125]"
- `type:Column#1`.bounds: "[559,396][762,599]" → "[0,137][1320,2450]"
- `type:Stack#4`.bounds: "[0,0][1320,136]" → "[49,55][188,136]"
- `type:Stack#6`.bounds: "[49,55][188,136]" → "[1079,55][1166,136]"
- `type:Text#4`.clickable: "true" → "false"
- `type:Text#4`.bounds: "[258,935][1034,1068]" → "[317,2650][486,2699]"
- `type:Row#3`.bounds: "[49,55][1271,136]" → "[0,2450][1320,2758]"
- `type:Row#5`.bounds: "[49,55][188,136]" → "[300,2517][503,2636]"
- `type:Text#3`.bounds: "[153,981][258,1022]" → "[58,2650][227,2699]"
- `type:Stack#0`.bounds: "[506,343][814,651]" → "[0,0][1320,136]"
- `type:Text#0`.bounds: "[629,406][692,468]" → "[245,220][1033,318]"
- `type:Button#0`.bounds: "[115,1232][1205,1372]" → "[63,199][217,339]"
- `type:Stack#12`.bounds: "[1173,69][1271,125]" → "[520,48][800,136]"
- `type:Row#1`.bounds: "[115,931][1205,1071]" → "[63,458][1257,591]"
- `type:Row#9`.bounds: "[1173,55][1271,136]" → "[49,55][1271,136]"
- `type:Button#1`.bounds: "[115,1400][1205,1526]" → "[1033,199][1257,339]"
- `type:Stack#5`.bounds: "[49,55][1320,136]" → "[995,55][1079,136]"

### 控件数量变化
- Image: 0 → 5 (+5)
- Stack: 15 → 13 (-2)
- Row: 10 → 16 (+6)
- Web: 1 → 0 (-1)
- Blank: 0 → 1 (+1)
- Column: 2 → 9 (+7)
- genericContainer: 2 → 0 (-2)
- Button: 2 → 7 (+5)
- TextInput: 2 → 0 (-2)
- Scroll: 0 → 1 (+1)
- rootWebArea: 1 → 0 (-1)

## 断言检查结果

**通过 4/4**

| # | 类型 | 结果 | 说明 | 详情 |
|---|------|------|------|------|
| 1 | exists | PASS | Physics experiment tab should exist | 找到目标控件 |
| 2 | exists | PASS | Other experiment tab should exist | 找到目标控件 |
| 3 | exists | PASS | Load/error state should be visible | 找到目标控件 |
| 4 | exists | PASS | Refresh must expose the real missing-session failure | 找到目标控件 |

> **结论**: 所有断言通过，交互行为符合预期。
