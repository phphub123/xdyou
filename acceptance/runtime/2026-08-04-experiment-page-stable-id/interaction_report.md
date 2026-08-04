# 交互验证报告

**场景**: Experiment page navigation and groups
**描述**: Open preview home and verify the real physics/other experiment boundary without entering credentials.

## 交互步骤执行结果

| # | 操作 | 状态 | 详情 |
|---|------|------|------|
| 1 | click | PASS | click (660,1463): No Error |
| 2 | click | PASS | click (811,2323): No Error |
| 3 | snapshot | PASS | 快照保存至 acceptance\runtime\2026-08-04-experiment-page-stable-id\snapshot_01-experi |
| 4 | click | PASS | click (972,524): No Error |
| 5 | snapshot | PASS | 快照保存至 acceptance\runtime\2026-08-04-experiment-page-stable-id\snapshot_02-other- |

## 交互前后界面差异

**摘要**: 新增 56 个节点; 移除 31 个节点; 文本变化 13 处; 属性变化 50 处; 数量变化: Row: 10→16, TextInput: 2→0, rootWebArea: 1→0, Stack: 15→13, Scroll: 0→1, Blank: 0→1, Web: 1→0, Image: 0→5, genericContainer: 2→0, Button: 2→7, Column: 2→9

### 文本变化
- `type:Text#3`: "PW" → "校園信息"
- `type:Text#0`: "==" → "实验信息"
- `key:ClockStatusView`: "03, :, 55" → "03, :, 56"
- `type:Text#2`: "ID" → "其他实验数据来自 sysj.xidian.edu.cn，必须完成真实 IDS OAuth 跳转；Mock 登录不返回可用 Cookie。"
- `type:Text#1`: "XDYOU" → "其他实验等待真实 IDS 会话恢复后联调。"
- `type:Text#7`: "View network interaction" → "設置"
- `type:Text#6`: "Clear cache" → "豬圖鑑賞"
- `type:Button#0`: "Login" → "‹"
- `type:Text#4`: "IDS Login password" → "睿思論壇"
- `type:Flex#0`: "03, :, 55" → "03, :, 56"
- `type:Button#1`: "Mock 预览主页（仅 UI，不登录）" → "刷新"
- `type:Text#10`: "55" → "56"
- `type:Text#5`: "View" → "其他功能"

### 新增节点
- `key:experimentOtherBlocked` (Text) 其他实验数据来自 sysj.xidian.edu.cn，必须完成真实 IDS OAuth 跳转；Mock 登录不返回可用 Cookie。
- `key:experimentOtherTab` (Button) 其他实验
- `key:navTo_home` (Column)
- `type:Row#13` (Row)
- `type:Row#10` (Row)
- `key:experimentDoingTab` (Button) 进行中
- `key:navTo_toolbox` (Column)
- `key:navTo_settings` (Column)
- `key:experimentPhysicsTab` (Button) 物理实验
- `key:experimentBack` (Button) ‹
- `text:其他实验数据来自 sysj.xidian.edu.cn，必须完成真实 IDS OAuth 跳转；Mock 登录不返回可用 Cookie。` (Text) 其他实验数据来自 sysj.xidian.edu.cn，必须完成真实 IDS OAuth 跳转；Mock 登录不返回可用 Cookie。
- `key:experimentRefresh` (Button) 刷新
- `key:navTo_pig` (Column)
- `type:Scroll#0` (Scroll)
- `text:校園信息` (Text) 校園信息
- `text:物理实验` (Button) 物理实验
- `text:豬圖鑑賞` (Text) 豬圖鑑賞
- `key:experimentUpcomingTab` (Button) 未完成
- `text:实验信息` (Text) 实验信息
- `type:Image#4` (Image)
- ... 共 56 个

### 移除节点
- `text:Login` (Button) Login
- `text:Mock 预览主页（仅 UI，不登录）` (Button) Mock 预览主页（仅 UI，不登录）
- `text:ID` (Text) ID
- `key:idsCookieBootstrap` (Web) https://ids.xidian.edu.cn/authserver/login?service=https%3A%2F%2Fehall.xidian.edu.cn%2Flogin%3Fservice%3Dhttps%3A%2F%2Fehall.xidian.edu.cn%2Fnew%2Findex.html
- `key:viewNetworkInteraction` (Text) View network interaction
- `key:loginPasswordMask` (Text) IDS Login password
- `text:View network interaction` (Text) View network interaction
- `type:genericContainer#1` (genericContainer)
- `type:genericContainer#0` (genericContainer)
- `text:IDS Login password` (Text) IDS Login password
- `text:==` (Text) ==
- `type:TextInput#1` (TextInput)
- `key:loginLogo` (Stack)
- `text:https://ids.xidian.edu.cn/authserver/login?service=https%3A%2F%2Fehall.xidian.edu.cn%2Flogin%3Fservice%3Dhttps%3A%2F%2Fehall.xidian.edu.cn%2Fnew%2Findex.html` (Web) https://ids.xidian.edu.cn/authserver/login?service=https%3A%2F%2Fehall.xidian.edu.cn%2Flogin%3Fservice%3Dhttps%3A%2F%2Fehall.xidian.edu.cn%2Fnew%2Findex.html
- `key:loginSubmitButton` (Button) Login
- `text:55` (Text) 55
- `key:togglePasswordVisibility` (Text) View
- `type:Stack#13` (Stack)
- `text:XDYOU` (Text) XDYOU
- `text:PW` (Text) PW
- ... 共 31 个

### 属性变化
- `type:Stack#0`.bounds: "[506,343][814,651]" → "[0,0][1320,136]"
- `type:Text#3`.bounds: "[153,981][258,1022]" → "[58,2650][227,2699]"
- `type:Stack#8`.bounds: "[1079,55][1166,136]" → "[1166,55][1271,136]"
- `type:Row#3`.bounds: "[49,55][1271,136]" → "[0,2450][1320,2758]"
- `type:Text#0`.bounds: "[629,406][692,468]" → "[245,220][1033,318]"
- `type:Text#2`.bounds: "[153,804][258,849]" → "[72,1431][1248,1649]"
- `type:Text#1`.bounds: "[583,468][739,600]" → "[63,367][823,416]"
- `type:Row#5`.bounds: "[49,55][188,136]" → "[300,2517][503,2636]"
- `type:Text#7`.clickable: "true" → "false"
- `type:Text#7`.bounds: "[581,1589][1020,1634]" → "[1135,2650][1220,2699]"
- `type:Text#6`.clickable: "true" → "false"
- `type:Text#6`.bounds: "[300,1589][504,1634]" → "[834,2650][1003,2699]"
- `type:Button#0`.bounds: "[115,1232][1205,1372]" → "[63,199][217,339]"
- `type:Text#4`.clickable: "true" → "false"
- `type:Text#4`.bounds: "[258,935][1034,1068]" → "[317,2650][486,2699]"
- `type:Stack#6`.bounds: "[49,55][188,136]" → "[1079,55][1166,136]"
- `type:Stack#5`.bounds: "[49,55][1320,136]" → "[995,55][1079,136]"
- `type:Row#8`.bounds: "[1086,55][1166,136]" → "[1076,2517][1279,2636]"
- `type:Stack#9`.bounds: "[1086,69][1166,125]" → "[1173,69][1271,125]"
- `type:Stack#3`.bounds: "[0,0][1320,136]" → "[49,55][1320,136]"
- `type:Stack#4`.bounds: "[0,0][1320,136]" → "[49,55][188,136]"
- `type:Row#2`.bounds: "[300,1589][1020,1634]" → "[63,626][1257,745]"
- `type:Row#7`.bounds: "[1002,55][1079,136]" → "[817,2517][1020,2636]"
- `type:Stack#11`.bounds: "[1173,69][1271,125]" → "[520,48][800,136]"
- `type:Row#1`.bounds: "[115,931][1205,1071]" → "[63,458][1257,591]"
- `type:Stack#7`.bounds: "[995,55][1079,136]" → "[1086,69][1166,125]"
- `type:Row#9`.bounds: "[1173,55][1271,136]" → "[49,55][1271,136]"
- `type:Row#6`.bounds: "[49,66][126,128]" → "[559,2517][762,2636]"
- `type:Button#1`.bounds: "[115,1400][1205,1526]" → "[1033,199][1257,339]"
- `type:Column#1`.bounds: "[559,396][762,599]" → "[0,137][1320,2450]"

### 控件数量变化
- Row: 10 → 16 (+6)
- TextInput: 2 → 0 (-2)
- rootWebArea: 1 → 0 (-1)
- Stack: 15 → 13 (-2)
- Scroll: 0 → 1 (+1)
- Blank: 0 → 1 (+1)
- Web: 1 → 0 (-1)
- Image: 0 → 5 (+5)
- genericContainer: 2 → 0 (-2)
- Button: 2 → 7 (+5)
- Column: 2 → 9 (+7)

## 断言检查结果

**通过 4/4**

| # | 类型 | 结果 | 说明 | 详情 |
|---|------|------|------|------|
| 1 | exists | PASS | Physics experiment tab should exist | 找到目标控件 |
| 2 | exists | PASS | Other experiment tab should exist | 找到目标控件 |
| 3 | exists | PASS | Load/error state should be visible | 找到目标控件 |
| 4 | exists | PASS | IDS-dependent state should stay explicit | 找到目标控件 |

> **结论**: 所有断言通过，交互行为符合预期。
