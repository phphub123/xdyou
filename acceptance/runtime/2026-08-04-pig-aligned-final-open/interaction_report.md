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

**摘要**: 新增 43 个节点; 移除 30 个节点; 文本变化 12 处; 属性变化 51 处; 数量变化: Button: 2→0, Text: 12→14, TextInput: 2→0, genericContainer: 2→0, Row: 10→16, Column: 2→9, Image: 0→9, rootWebArea: 1→0, Web: 1→0, Stack: 15→14

### 文本变化
- `type:Text#3`: "PW" → "Change A Pig"
- `type:Text#4`: "IDS Login password" → "Save this Pig"
- `type:Text#1`: "XDYOU" → "本程序將開發一個新主頁，目前先用豬圖秀佔位，玩得愉快"
- `type:Text#7`: "View network interaction" → "其他功能"
- `type:Text#5`: "View" → "校園信息"
- `type:Text#6`: "Clear cache" → "睿思論壇"
- `type:Text#8`: "11" → "豬圖鑑賞"
- `type:Text#9`: ":" → "設置"
- `type:Text#2`: "ID" → "你已笨哭猪"
- `type:Text#11`: "100" → ":"
- `type:Text#10`: "28" → "11"
- `type:Text#0`: "==" → "豬圖鑑賞"

### 新增节点
- `key:navTo_home` (Column) 
- `text:其他功能` (Text) 其他功能
- `key:pigSave` (Row) 
- `text:豬圖鑑賞` (Text) 豬圖鑑賞
- `type:Image#6` (Image) 
- `type:Text#13` (Text) 100
- `text:睿思論壇` (Text) 睿思論壇
- `type:Column#2` (Column) 
- `type:Image#7` (Image) 
- `type:Row#11` (Row) 
- `text:本程序將開發一個新主頁，目前先用豬圖秀佔位，玩得愉快` (Text) 本程序將開發一個新主頁，目前先用豬圖秀佔位，玩得愉快
- `type:Row#10` (Row) 
- `key:navTo_ruisi` (Column) 
- `type:Image#0` (Image) 
- `key:pigImage` (Image) 
- `type:Row#15` (Row) 
- `type:Image#4` (Image) 
- `key:pigTitle` (Text) 你已笨哭猪
- `type:Column#3` (Column) 
- `key:navTo_settings` (Column) 
- ... 共 43 个

### 移除节点
- `text:Login` (Button) Login
- `key:loginPasswordInput` (TextInput) 
- `text:PW` (Text) PW
- `text:Clear cache` (Text) Clear cache
- `type:genericContainer#1` (genericContainer) 
- `type:TextInput#0` (TextInput) 
- `type:Button#0` (Button) Login
- `text:IDS Login password` (Text) IDS Login password
- `key:loginLogo` (Stack) 
- `type:genericContainer#0` (genericContainer) 
- `text:https://ids.xidian.edu.cn/authserver/login?service=https%3A%2F%2Fehall.xidian.edu.cn%2Flogin%3Fservice%3Dhttps%3A%2F%2Fehall.xidian.edu.cn%2Fnew%2Findex.html` (Web) https://ids.xidian.edu.cn/authserver/login?service=https%3A%2F%2Fehall.xidian.edu.cn%2Flogin%3Fservice%3Dhttps%3A%2F%2Fehall.xidian.edu.cn%2Fnew%2Findex.html
- `text:XDYOU` (Text) XDYOU
- `text:Mock 预览主页（仅 UI，不登录）` (Button) Mock 预览主页（仅 UI，不登录）
- `text:ID` (Text) ID
- `key:loginSubmitButton` (Button) Login
- `type:Web#0` (Web) https://ids.xidian.edu.cn/authserver/login?service=https%3A%2F%2Fehall.xidian.edu.cn%2Flogin%3Fservice%3Dhttps%3A%2F%2Fehall.xidian.edu.cn%2Fnew%2Findex.html
- `key:mockHomePreviewButton` (Button) Mock 预览主页（仅 UI，不登录）
- `type:Stack#14` (Stack) 
- `key:loginAccountInput` (TextInput) 
- `text:View` (Text) View
- ... 共 30 个

### 属性变化
- `type:Stack#6`.bounds: "[49,55][188,136]" → "[995,55][1079,136]"
- `type:Row#9`.bounds: "[1173,55][1271,136]" → "[49,55][1271,136]"
- `type:Text#3`.bounds: "[153,981][258,1022]" → "[560,1969][858,2026]"
- `type:Stack#12`.bounds: "[1173,69][1271,125]" → "[520,48][800,136]"
- `type:Stack#1`.bounds: "[258,935][1034,1068]" → "[0,0][1320,136]"
- `type:Row#7`.bounds: "[1002,55][1079,136]" → "[817,2517][1020,2636]"
- `type:Text#4`.clickable: "true" → "false"
- `type:Text#4`.bounds: "[258,935][1034,1068]" → "[567,2147][851,2204]"
- `type:Row#2`.clickable: "false" → "true"
- `type:Row#2`.bounds: "[300,1589][1020,1634]" → "[363,2102][958,2249]"
- `type:Text#1`.bounds: "[583,468][739,600]" → "[84,540][1236,654]"
- `type:Stack#7`.bounds: "[995,55][1079,136]" → "[1079,55][1166,136]"
- `type:Row#8`.bounds: "[1086,55][1166,136]" → "[1076,2517][1279,2636]"
- `type:Text#7`.clickable: "true" → "false"
- `type:Text#7`.bounds: "[581,1589][1020,1634]" → "[576,2650][745,2699]"
- `type:Text#5`.clickable: "true" → "false"
- `type:Text#5`.bounds: "[1034,979][1188,1024]" → "[58,2650][227,2699]"
- `type:Text#6`.clickable: "true" → "false"
- `type:Text#6`.bounds: "[300,1589][504,1634]" → "[317,2650][486,2699]"
- `type:Text#8`.bounds: "[49,66][111,128]" → "[834,2650][1003,2699]"
- `type:Column#1`.bounds: "[559,396][762,599]" → "[0,137][1320,2450]"
- `type:Stack#8`.bounds: "[1079,55][1166,136]" → "[1086,69][1166,125]"
- `type:Stack#0`.bounds: "[506,343][814,651]" → "[135,696][1185,1746]"
- `type:Stack#4`.bounds: "[0,0][1320,136]" → "[49,55][1320,136]"
- `type:Row#0`.bounds: "[115,756][1205,896]" → "[0,137][1320,339]"
- `type:Row#1`.clickable: "false" → "true"
- `type:Row#1`.bounds: "[115,931][1205,1071]" → "[363,1924][958,2071]"
- `type:Text#9`.bounds: "[111,71][126,124]" → "[1135,2650][1220,2699]"
- `type:Row#4`.bounds: "[0,0][1320,136]" → "[41,2517][244,2636]"
- `type:Text#2`.bounds: "[153,804][258,849]" → "[520,1774][800,1840]"

### 控件数量变化
- Button: 2 → 0 (-2)
- Text: 12 → 14 (+2)
- TextInput: 2 → 0 (-2)
- genericContainer: 2 → 0 (-2)
- Row: 10 → 16 (+6)
- Column: 2 → 9 (+7)
- Image: 0 → 9 (+9)
- rootWebArea: 1 → 0 (-1)
- Web: 1 → 0 (-1)
- Stack: 15 → 14 (-1)

## 断言检查结果

**通过 4/4**

| # | 类型 | 结果 | 说明 | 详情 |
|---|------|------|------|------|
| 1 | exists | PASS | Pig gallery title should be visible | 找到目标控件 |
| 2 | exists | PASS | A real PigHub image component should be visible | 找到目标控件 |
| 3 | exists | PASS | The PigHub image title should be visible | 找到目标控件 |
| 4 | clickable | PASS | Change A Pig should be clickable | clickable=True |

> **结论**: 所有断言通过，交互行为符合预期。
