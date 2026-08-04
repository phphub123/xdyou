# 交互验证报告

**场景**: Open aligned PigHub page
**描述**: Enter local preview, open Pig gallery, and wait for the real PigHub image.

## 交互步骤执行结果

| # | 操作 | 状态 | 详情 |
|---|------|------|------|
| 1 | click | PASS | click (660,1463): No Error |
| 2 | click | PASS | click (918,2607): No Error |
| 3 | snapshot | PASS | 快照保存至 /Users/niu/huawei/Project1/traintime_pda_ohos/xdyou/acceptance/runtime/202 |

## 交互前后界面差异

**摘要**: 新增 45 个节点; 移除 32 个节点; 文本变化 14 处; 属性变化 53 处; 数量变化: Text: 12→14, rootWebArea: 1→0, Button: 2→0, Web: 1→0, genericContainer: 2→0, Stack: 15→14, Image: 0→9, Row: 10→16, TextInput: 2→0, Column: 2→9

### 文本变化
- `type:Text#0`: "==" → "豬圖鑑賞"
- `type:Text#11`: "100" → ":"
- `type:Text#8`: "11" → "豬圖鑑賞"
- `type:Text#7`: "View network interaction" → "其他功能"
- `type:Text#3`: "PW" → "Change A Pig"
- `type:Text#2`: "ID" → "死猪咪"
- `type:Text#1`: "XDYOU" → "本程序將開發一個新主頁，目前先用豬圖秀佔位，玩得愉快"
- `type:Text#9`: ":" → "設置"
- `type:Flex#0`: "11, :, 24" → "11, :, 25"
- `key:ClockStatusView`: "11, :, 24" → "11, :, 25"
- `type:Text#5`: "View" → "校園信息"
- `type:Text#10`: "24" → "11"
- `type:Text#4`: "IDS Login password" → "Save this Pig"
- `type:Text#6`: "Clear cache" → "睿思論壇"

### 新增节点
- `type:Row#12` (Row) 
- `key:navTo_toolbox` (Column) 
- `text:11, :, 25` (Flex) 11, :, 25
- `key:navTo_home` (Column) 
- `type:Image#3` (Image) 
- `key:pigTitle` (Text) 死猪咪
- `key:pigShuffle` (Row) 
- `key:navTo_pig` (Column) 
- `type:Column#7` (Column) 
- `type:Column#4` (Column) 
- `type:Column#2` (Column) 
- `type:Row#14` (Row) 
- `type:Image#8` (Image) 
- `key:navTo_ruisi` (Column) 
- `text:其他功能` (Text) 其他功能
- `type:Image#7` (Image) 
- `key:pigImage` (Image) 
- `text:校園信息` (Text) 校園信息
- `type:Column#6` (Column) 
- `type:Image#5` (Image) 
- ... 共 45 个

### 移除节点
- `key:loginPasswordMask` (Text) IDS Login password
- `text:Login` (Button) Login
- `text:ID` (Text) ID
- `key:idsCookieBootstrap` (Web) https://ids.xidian.edu.cn/authserver/login?service=https%3A%2F%2Fehall.xidian.edu.cn%2Flogin%3Fservice%3Dhttps%3A%2F%2Fehall.xidian.edu.cn%2Fnew%2Findex.html
- `type:TextInput#0` (TextInput) 
- `key:clearSessionButton` (Text) Clear cache
- `text:11, :, 24` (Flex) 11, :, 24
- `text:Clear cache` (Text) Clear cache
- `key:loginAccountInput` (TextInput) 
- `text:https://ids.xidian.edu.cn/authserver/login?service=https%3A%2F%2Fehall.xidian.edu.cn%2Flogin%3Fservice%3Dhttps%3A%2F%2Fehall.xidian.edu.cn%2Fnew%2Findex.html` (Web) https://ids.xidian.edu.cn/authserver/login?service=https%3A%2F%2Fehall.xidian.edu.cn%2Flogin%3Fservice%3Dhttps%3A%2F%2Fehall.xidian.edu.cn%2Fnew%2Findex.html
- `key:loginPasswordInput` (TextInput) 
- `type:TextInput#1` (TextInput) 
- `text:View network interaction` (Text) View network interaction
- `type:genericContainer#0` (genericContainer) 
- `text:==` (Text) ==
- `text:View` (Text) View
- `key:loginLogo` (Stack) 
- `text:24` (Text) 24
- `key:loginSubmitButton` (Button) Login
- `key:mockHomePreviewButton` (Button) Mock 预览主页（仅 UI，不登录）
- ... 共 32 个

### 属性变化
- `type:Text#0`.bounds: "[629,406][692,468]" → "[70,193][1167,283]"
- `type:Row#9`.bounds: "[1173,55][1271,136]" → "[49,55][1271,136]"
- `type:Stack#12`.bounds: "[1173,69][1271,125]" → "[520,48][800,136]"
- `type:Stack#10`.bounds: "[1166,55][1271,136]" → "[1173,69][1271,125]"
- `type:Row#0`.bounds: "[115,756][1205,896]" → "[0,137][1320,339]"
- `type:Stack#8`.bounds: "[1079,55][1166,136]" → "[1086,69][1166,125]"
- `type:Row#2`.clickable: "false" → "true"
- `type:Row#2`.bounds: "[300,1589][1020,1634]" → "[363,2102][958,2249]"
- `type:Text#11`.bounds: "[1182,75][1252,120]" → "[111,71][126,124]"
- `type:Row#8`.bounds: "[1086,55][1166,136]" → "[1076,2517][1279,2636]"
- `type:Text#8`.bounds: "[49,66][111,128]" → "[834,2650][1003,2699]"
- `type:Row#7`.bounds: "[1002,55][1079,136]" → "[817,2517][1020,2636]"
- `type:Text#7`.clickable: "true" → "false"
- `type:Text#7`.bounds: "[581,1589][1020,1634]" → "[576,2650][745,2699]"
- `type:Stack#4`.bounds: "[0,0][1320,136]" → "[49,55][1320,136]"
- `type:Row#3`.bounds: "[49,55][1271,136]" → "[0,2450][1320,2758]"
- `type:Stack#0`.bounds: "[506,343][814,651]" → "[135,696][1185,1746]"
- `type:Text#3`.bounds: "[153,981][258,1022]" → "[560,1969][858,2026]"
- `type:Stack#5`.bounds: "[49,55][1320,136]" → "[49,55][188,136]"
- `type:Text#2`.bounds: "[153,804][258,849]" → "[576,1774][744,1840]"
- `type:Text#1`.bounds: "[583,468][739,600]" → "[84,540][1236,654]"
- `type:Stack#7`.bounds: "[995,55][1079,136]" → "[1079,55][1166,136]"
- `type:Row#4`.bounds: "[0,0][1320,136]" → "[41,2517][244,2636]"
- `type:Row#5`.bounds: "[49,55][188,136]" → "[300,2517][503,2636]"
- `type:Text#9`.bounds: "[111,71][126,124]" → "[1135,2650][1220,2699]"
- `type:Text#5`.clickable: "true" → "false"
- `type:Text#5`.bounds: "[1034,979][1188,1024]" → "[58,2650][227,2699]"
- `type:Text#10`.bounds: "[126,66][188,128]" → "[49,66][111,128]"
- `type:Stack#1`.bounds: "[258,935][1034,1068]" → "[0,0][1320,136]"
- `type:Text#4`.clickable: "true" → "false"

### 控件数量变化
- Text: 12 → 14 (+2)
- rootWebArea: 1 → 0 (-1)
- Button: 2 → 0 (-2)
- Web: 1 → 0 (-1)
- genericContainer: 2 → 0 (-2)
- Stack: 15 → 14 (-1)
- Image: 0 → 9 (+9)
- Row: 10 → 16 (+6)
- TextInput: 2 → 0 (-2)
- Column: 2 → 9 (+7)

## 断言检查结果

**通过 4/4**

| # | 类型 | 结果 | 说明 | 详情 |
|---|------|------|------|------|
| 1 | exists | PASS | Pig gallery title should be visible | 找到目标控件 |
| 2 | exists | PASS | A real PigHub image component should be visible | 找到目标控件 |
| 3 | exists | PASS | The PigHub image title should be visible | 找到目标控件 |
| 4 | clickable | PASS | Change A Pig should be clickable | clickable=True |

> **结论**: 所有断言通过，交互行为符合预期。
