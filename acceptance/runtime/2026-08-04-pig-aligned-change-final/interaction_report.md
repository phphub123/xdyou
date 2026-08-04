# 交互验证报告

**场景**: PigHub UI alignment and Change A Pig
**描述**: Open the PigHub page, capture its aligned UI, change to another real PigHub item, and capture the result.

## 交互步骤执行结果

| # | 操作 | 状态 | 详情 |
|---|------|------|------|
| 1 | click | PASS | click (660,1463): No Error |
| 2 | click | PASS | click (918,2607): No Error |
| 3 | snapshot | PASS | 快照保存至 acceptance/runtime/2026-08-04-pig-aligned-change-final/snapshot_01-before- |
| 4 | click | PASS | click (660,1997): No Error |
| 5 | snapshot | PASS | 快照保存至 acceptance/runtime/2026-08-04-pig-aligned-change-final/snapshot_02-after-c |

## 交互前后界面差异

**摘要**: 新增 45 个节点; 移除 32 个节点; 文本变化 14 处; 属性变化 53 处; 数量变化: Web: 1→0, Image: 0→9, Stack: 15→14, rootWebArea: 1→0, Text: 12→14, Row: 10→16, Column: 2→9, TextInput: 2→0, genericContainer: 2→0, Button: 2→0

### 文本变化
- `type:Text#2`: "ID" → "猪思考(猪撅猪)"
- `type:Text#6`: "Clear cache" → "睿思論壇"
- `key:ClockStatusView`: "11, :, 34" → "11, :, 35"
- `type:Text#8`: "11" → "豬圖鑑賞"
- `type:Text#1`: "XDYOU" → "本程序將開發一個新主頁，目前先用豬圖秀佔位，玩得愉快"
- `type:Text#7`: "View network interaction" → "其他功能"
- `type:Text#5`: "View" → "校園信息"
- `type:Text#9`: ":" → "設置"
- `type:Text#4`: "IDS Login password" → "Save this Pig"
- `type:Text#0`: "==" → "豬圖鑑賞"
- `type:Text#11`: "100" → ":"
- `type:Text#3`: "PW" → "Change A Pig"
- `type:Flex#0`: "11, :, 34" → "11, :, 35"
- `type:Text#10`: "34" → "11"

### 新增节点
- `type:Row#12` (Row)
- `type:Column#8` (Column)
- `key:navTo_toolbox` (Column)
- `type:Row#13` (Row)
- `text:35` (Text) 35
- `key:pigTitle` (Text) 猪思考(猪撅猪)
- `type:Row#11` (Row)
- `key:pigRefresh` (Image)
- `type:Column#2` (Column)
- `key:navTo_home` (Column)
- `type:Column#3` (Column)
- `text:豬圖鑑賞` (Text) 豬圖鑑賞
- `type:Image#7` (Image)
- `key:pigShuffle` (Row)
- `text:其他功能` (Text) 其他功能
- `key:navTo_ruisi` (Column)
- `type:Row#14` (Row)
- `text:11, :, 35` (Flex) 11, :, 35
- `text:猪思考(猪撅猪)` (Text) 猪思考(猪撅猪)
- `type:Image#8` (Image)
- ... 共 45 个

### 移除节点
- `key:loginPasswordMask` (Text) IDS Login password
- `key:loginPasswordInput` (TextInput)
- `text:View network interaction` (Text) View network interaction
- `key:idsCookieBootstrap` (Web) https://ids.xidian.edu.cn/authserver/login?service=https%3A%2F%2Fehall.xidian.edu.cn%2Flogin%3Fservice%3Dhttps%3A%2F%2Fehall.xidian.edu.cn%2Fnew%2Findex.html
- `type:rootWebArea#0` (rootWebArea)
- `text:11, :, 34` (Flex) 11, :, 34
- `type:Button#1` (Button) Mock 预览主页（仅 UI，不登录）
- `type:Stack#14` (Stack)
- `key:viewNetworkInteraction` (Text) View network interaction
- `text:View` (Text) View
- `type:Button#0` (Button) Login
- `text:IDS Login password` (Text) IDS Login password
- `type:genericContainer#1` (genericContainer)
- `text:XDYOU` (Text) XDYOU
- `text:https://ids.xidian.edu.cn/authserver/login?service=https%3A%2F%2Fehall.xidian.edu.cn%2Flogin%3Fservice%3Dhttps%3A%2F%2Fehall.xidian.edu.cn%2Fnew%2Findex.html` (Web) https://ids.xidian.edu.cn/authserver/login?service=https%3A%2F%2Fehall.xidian.edu.cn%2Flogin%3Fservice%3Dhttps%3A%2F%2Fehall.xidian.edu.cn%2Fnew%2Findex.html
- `text:PW` (Text) PW
- `type:TextInput#0` (TextInput)
- `key:togglePasswordVisibility` (Text) View
- `key:clearSessionButton` (Text) Clear cache
- `key:mockHomePreviewButton` (Button) Mock 预览主页（仅 UI，不登录）
- ... 共 32 个

### 属性变化
- `type:Stack#5`.bounds: "[49,55][1320,136]" → "[49,55][188,136]"
- `type:Stack#8`.bounds: "[1079,55][1166,136]" → "[1086,69][1166,125]"
- `type:Text#2`.bounds: "[153,804][258,849]" → "[473,1774][848,1840]"
- `type:Column#1`.bounds: "[559,396][762,599]" → "[0,137][1320,2450]"
- `type:Stack#0`.bounds: "[506,343][814,651]" → "[135,696][1185,1746]"
- `type:Row#6`.bounds: "[49,66][126,128]" → "[559,2517][762,2636]"
- `type:Row#7`.bounds: "[1002,55][1079,136]" → "[817,2517][1020,2636]"
- `type:Row#1`.clickable: "false" → "true"
- `type:Row#1`.bounds: "[115,931][1205,1071]" → "[363,1924][958,2071]"
- `type:Stack#4`.bounds: "[0,0][1320,136]" → "[49,55][1320,136]"
- `type:Stack#9`.bounds: "[1086,69][1166,125]" → "[1166,55][1271,136]"
- `type:Text#6`.clickable: "true" → "false"
- `type:Text#6`.bounds: "[300,1589][504,1634]" → "[317,2650][486,2699]"
- `type:Row#2`.clickable: "false" → "true"
- `type:Row#2`.bounds: "[300,1589][1020,1634]" → "[363,2102][958,2249]"
- `type:Stack#6`.bounds: "[49,55][188,136]" → "[995,55][1079,136]"
- `type:Text#8`.bounds: "[49,66][111,128]" → "[834,2650][1003,2699]"
- `type:Stack#7`.bounds: "[995,55][1079,136]" → "[1079,55][1166,136]"
- `type:Row#8`.bounds: "[1086,55][1166,136]" → "[1076,2517][1279,2636]"
- `type:Text#1`.bounds: "[583,468][739,600]" → "[84,540][1236,654]"
- `type:Stack#1`.bounds: "[258,935][1034,1068]" → "[0,0][1320,136]"
- `type:Text#7`.clickable: "true" → "false"
- `type:Text#7`.bounds: "[581,1589][1020,1634]" → "[576,2650][745,2699]"
- `type:Row#0`.bounds: "[115,756][1205,896]" → "[0,137][1320,339]"
- `type:Text#5`.clickable: "true" → "false"
- `type:Text#5`.bounds: "[1034,979][1188,1024]" → "[58,2650][227,2699]"
- `type:Row#3`.bounds: "[49,55][1271,136]" → "[0,2450][1320,2758]"
- `type:Text#9`.bounds: "[111,71][126,124]" → "[1135,2650][1220,2699]"
- `type:Text#4`.clickable: "true" → "false"
- `type:Text#4`.bounds: "[258,935][1034,1068]" → "[567,2147][851,2204]"

### 控件数量变化
- Web: 1 → 0 (-1)
- Image: 0 → 9 (+9)
- Stack: 15 → 14 (-1)
- rootWebArea: 1 → 0 (-1)
- Text: 12 → 14 (+2)
- Row: 10 → 16 (+6)
- Column: 2 → 9 (+7)
- TextInput: 2 → 0 (-2)
- genericContainer: 2 → 0 (-2)
- Button: 2 → 0 (-2)

## 断言检查结果

**通过 4/4**

| # | 类型 | 结果 | 说明 | 详情 |
|---|------|------|------|------|
| 1 | exists | PASS | Pig gallery title should be visible | 找到目标控件 |
| 2 | exists | PASS | A real PigHub image should remain visible after changing | 找到目标控件 |
| 3 | exists | PASS | The PigHub image title should remain visible after changing | 找到目标控件 |
| 4 | clickable | PASS | Change A Pig should be clickable | clickable=True |

> **结论**: 所有断言通过，交互行为符合预期。
