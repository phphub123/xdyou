# 交互验证报告

**场景**: PigHub UI alignment and Change A Pig
**描述**: Open the PigHub page, capture its aligned UI, change to another real PigHub item, and capture the result.

## 交互步骤执行结果

| # | 操作 | 状态 | 详情 |
|---|------|------|------|
| 1 | click | PASS | click (660,1463): No Error |
| 2 | click | PASS | click (918,2607): No Error |
| 3 | snapshot | PASS | 快照保存至 acceptance/runtime/2026-08-06-pig-alignment-change-final/snapshot_01-befor |
| 4 | click | PASS | click (660,1997): No Error |
| 5 | snapshot | PASS | 快照保存至 acceptance/runtime/2026-08-06-pig-alignment-change-final/snapshot_02-after |

## 交互前后界面差异

**摘要**: 新增 43 个节点; 移除 30 个节点; 文本变化 12 处; 属性变化 51 处; 数量变化: Column: 2→9, Image: 0→9, Text: 12→14, Stack: 15→14, rootWebArea: 1→0, TextInput: 2→0, genericContainer: 2→0, Web: 1→0, Row: 10→16, Button: 2→0

### 文本变化
- `type:Text#2`: "ID" → "天蝎猪"
- `type:Text#4`: "IDS Login password" → "Save this Pig"
- `type:Text#11`: "100" → ":"
- `type:Text#0`: "==" → "豬圖鑑賞"
- `type:Text#7`: "View network interaction" → "其他功能"
- `type:Text#8`: "07" → "豬圖鑑賞"
- `type:Text#1`: "XDYOU" → "本程序將開發一個新主頁，目前先用豬圖秀佔位，玩得愉快"
- `type:Text#3`: "PW" → "Change A Pig"
- `type:Text#9`: ":" → "設置"
- `type:Text#6`: "Clear cache" → "睿思論壇"
- `type:Text#5`: "View" → "校園信息"
- `type:Text#10`: "25" → "07"

### 新增节点
- `type:Image#3` (Image) 
- `type:Column#8` (Column) 
- `type:Column#4` (Column) 
- `type:Image#0` (Image) 
- `text:其他功能` (Text) 其他功能
- `type:Column#2` (Column) 
- `type:Column#6` (Column) 
- `type:Image#5` (Image) 
- `type:Column#5` (Column) 
- `text:睿思論壇` (Text) 睿思論壇
- `key:navTo_home` (Column) 
- `type:Row#14` (Row) 
- `type:Image#4` (Image) 
- `type:Image#1` (Image) 
- `text:天蝎猪` (Text) 天蝎猪
- `type:Text#13` (Text) 100
- `type:Row#10` (Row) 
- `type:Row#13` (Row) 
- `type:Column#3` (Column) 
- `type:Image#6` (Image) 
- ... 共 43 个

### 移除节点
- `text:==` (Text) ==
- `type:genericContainer#0` (genericContainer) 
- `key:loginSubmitButton` (Button) Login
- `type:genericContainer#1` (genericContainer) 
- `text:View network interaction` (Text) View network interaction
- `key:idsCookieBootstrap` (Web) https://ids.xidian.edu.cn/authserver/login?service=https%3A%2F%2Fehall.xidian.edu.cn%2Flogin%3Fservice%3Dhttps%3A%2F%2Fehall.xidian.edu.cn%2Fnew%2Findex.html
- `type:Button#1` (Button) Mock 预览主页（仅 UI，不登录）
- `key:viewNetworkInteraction` (Text) View network interaction
- `type:Web#0` (Web) https://ids.xidian.edu.cn/authserver/login?service=https%3A%2F%2Fehall.xidian.edu.cn%2Flogin%3Fservice%3Dhttps%3A%2F%2Fehall.xidian.edu.cn%2Fnew%2Findex.html
- `key:mockHomePreviewButton` (Button) Mock 预览主页（仅 UI，不登录）
- `text:XDYOU` (Text) XDYOU
- `text:IDS Login password` (Text) IDS Login password
- `text:Clear cache` (Text) Clear cache
- `key:loginLogo` (Stack) 
- `type:TextInput#0` (TextInput) 
- `type:rootWebArea#0` (rootWebArea) 
- `text:Login` (Button) Login
- `type:Stack#14` (Stack) 
- `key:togglePasswordVisibility` (Text) View
- `key:loginPasswordMask` (Text) IDS Login password
- ... 共 30 个

### 属性变化
- `type:Text#2`.bounds: "[153,804][258,849]" → "[576,1774][744,1840]"
- `type:Column#1`.bounds: "[559,396][762,599]" → "[0,137][1320,2450]"
- `type:Text#4`.clickable: "true" → "false"
- `type:Text#4`.bounds: "[258,935][1034,1068]" → "[567,2147][851,2204]"
- `type:Text#11`.bounds: "[1182,75][1252,120]" → "[111,71][126,124]"
- `type:Row#9`.bounds: "[1173,55][1271,136]" → "[49,55][1271,136]"
- `type:Stack#12`.bounds: "[1173,69][1271,125]" → "[520,48][800,136]"
- `type:Row#5`.bounds: "[49,55][188,136]" → "[300,2517][503,2636]"
- `type:Row#2`.clickable: "false" → "true"
- `type:Row#2`.bounds: "[300,1589][1020,1634]" → "[363,2102][958,2249]"
- `type:Text#0`.bounds: "[629,406][692,468]" → "[70,193][1167,283]"
- `type:Text#7`.clickable: "true" → "false"
- `type:Text#7`.bounds: "[581,1589][1020,1634]" → "[576,2650][745,2699]"
- `type:Stack#10`.bounds: "[1166,55][1271,136]" → "[1173,69][1271,125]"
- `type:Stack#0`.bounds: "[506,343][814,651]" → "[135,696][1185,1746]"
- `type:Text#8`.bounds: "[49,66][111,128]" → "[834,2650][1003,2699]"
- `type:Row#1`.clickable: "false" → "true"
- `type:Row#1`.bounds: "[115,931][1205,1071]" → "[363,1924][958,2071]"
- `type:Stack#7`.bounds: "[995,55][1079,136]" → "[1079,55][1166,136]"
- `type:Stack#5`.bounds: "[49,55][1320,136]" → "[49,55][188,136]"
- `type:Row#3`.bounds: "[49,55][1271,136]" → "[0,2450][1320,2758]"
- `type:Text#1`.bounds: "[583,468][739,600]" → "[84,540][1236,654]"
- `type:Stack#1`.bounds: "[258,935][1034,1068]" → "[0,0][1320,136]"
- `type:Stack#6`.bounds: "[49,55][188,136]" → "[995,55][1079,136]"
- `type:Row#4`.bounds: "[0,0][1320,136]" → "[41,2517][244,2636]"
- `type:Text#3`.bounds: "[153,981][258,1022]" → "[560,1969][858,2026]"
- `type:Text#9`.bounds: "[111,71][126,124]" → "[1135,2650][1220,2699]"
- `type:Stack#9`.bounds: "[1086,69][1166,125]" → "[1166,55][1271,136]"
- `type:Stack#8`.bounds: "[1079,55][1166,136]" → "[1086,69][1166,125]"
- `type:Stack#4`.bounds: "[0,0][1320,136]" → "[49,55][1320,136]"

### 控件数量变化
- Column: 2 → 9 (+7)
- Image: 0 → 9 (+9)
- Text: 12 → 14 (+2)
- Stack: 15 → 14 (-1)
- rootWebArea: 1 → 0 (-1)
- TextInput: 2 → 0 (-2)
- genericContainer: 2 → 0 (-2)
- Web: 1 → 0 (-1)
- Row: 10 → 16 (+6)
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
