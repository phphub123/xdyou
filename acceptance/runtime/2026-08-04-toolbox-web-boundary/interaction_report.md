# 交互验证报告

**场景**: Toolbox Web navigation boundary
**描述**: Open the public physics helper from preview mode and verify Web loading, history back and list-return controls.

## 交互步骤执行结果

| # | 操作 | 状态 | 详情 |
|---|------|------|------|
| 1 | click | PASS | click (660,1463): No Error |
| 2 | click | PASS | click (660,2607): No Error |
| 3 | click | PASS | click (660,1725): No Error |
| 4 | snapshot | PASS | 快照保存至 acceptance\runtime\2026-08-04-toolbox-web-boundary\snapshot_01-toolbox-web |

## 交互前后界面差异

**摘要**: 新增 35 个节点; 移除 28 个节点; 文本变化 14 处; 属性变化 57 处; 数量变化: Stack: 15→13, genericContainer: 2→0, Text: 12→11, Image: 0→5, TextInput: 2→0, Row: 10→15, Column: 2→8

### 文本变化
- `type:Button#1`: "Mock 预览主页（仅 UI，不登录）" → "网页返回"
- `type:Text#3`: "PW" → "睿思論壇"
- `type:Text#5`: "View" → "豬圖鑑賞"
- `type:Text#10`: "16" → "100"
- `type:Text#9`: ":" → "16"
- `type:Button#0`: "Login" → "‹"
- `type:Web#0`: "https://ids.xidian.edu.cn/authserver/login?service=https%3A%2F%2Fehall.xidian.edu.cn%2Flogin%3Fservice%3Dhttps%3A%2F%2Fehall.xidian.edu.cn%2Fnew%2Findex.html" → "https://experiment-helper.wizzstudio.com/#/"
- `type:Text#7`: "View network interaction" → "03"
- `type:Text#4`: "IDS Login password" → "其他功能"
- `type:Text#0`: "==" → "物理計算"
- `type:Text#6`: "Clear cache" → "設置"
- `type:Text#1`: "XDYOU" → "物理計算加载完成。"
- `type:Text#2`: "ID" → "校園信息"
- `type:Text#8`: "03" → ":"

### 新增节点
- `key:navTo_settings` (Column)
- `type:Image#2` (Image)
- `type:Image#3` (Image)
- `key:toolboxBackToList` (Button) ‹
- `type:Image#1` (Image)
- `key:toolboxStatus` (Text) 物理計算加载完成。
- `text:物理計算加载完成。` (Text) 物理計算加载完成。
- `type:Column#5` (Column)
- `type:Row#11` (Row)
- `type:Row#12` (Row)
- `type:Image#4` (Image)
- `text:校園信息` (Text) 校園信息
- `text:豬圖鑑賞` (Text) 豬圖鑑賞
- `type:Row#10` (Row)
- `text:网页返回` (Button) 网页返回
- `key:navTo_ruisi` (Column)
- `key:toolboxWebBack` (Button) 网页返回
- `type:Row#13` (Row)
- `text:睿思論壇` (Text) 睿思論壇
- `type:Column#7` (Column)
- ... 共 35 个

### 移除节点
- `key:loginPasswordMask` (Text) IDS Login password
- `text:PW` (Text) PW
- `type:genericContainer#0` (genericContainer)
- `key:idsCookieBootstrap` (Web) https://ids.xidian.edu.cn/authserver/login?service=https%3A%2F%2Fehall.xidian.edu.cn%2Flogin%3Fservice%3Dhttps%3A%2F%2Fehall.xidian.edu.cn%2Fnew%2Findex.html
- `type:Text#11` (Text) 100
- `text:==` (Text) ==
- `text:Login` (Button) Login
- `type:TextInput#1` (TextInput)
- `key:loginLogo` (Stack)
- `text:View` (Text) View
- `type:genericContainer#1` (genericContainer)
- `type:Stack#14` (Stack)
- `type:Stack#13` (Stack)
- `key:togglePasswordVisibility` (Text) View
- `text:Clear cache` (Text) Clear cache
- `text:XDYOU` (Text) XDYOU
- `text:View network interaction` (Text) View network interaction
- `text:Mock 预览主页（仅 UI，不登录）` (Button) Mock 预览主页（仅 UI，不登录）
- `key:clearSessionButton` (Text) Clear cache
- `key:mockHomePreviewButton` (Button) Mock 预览主页（仅 UI，不登录）
- ... 共 28 个

### 属性变化
- `type:Stack#9`.bounds: "[1086,69][1166,125]" → "[1173,69][1271,125]"
- `type:Column#1`.focused: "false" → "true"
- `type:Column#1`.bounds: "[559,396][762,599]" → "[0,137][1320,2450]"
- `type:Stack#1`.bounds: "[258,935][1034,1068]" → "[0,0][1320,136]"
- `type:Button#1`.bounds: "[115,1400][1205,1526]" → "[997,178][1278,297]"
- `type:Text#3`.bounds: "[153,981][258,1022]" → "[317,2650][486,2699]"
- `type:Text#5`.clickable: "true" → "false"
- `type:Text#5`.bounds: "[1034,979][1188,1024]" → "[834,2650][1003,2699]"
- `type:Row#1`.bounds: "[115,931][1205,1071]" → "[0,339][1320,409]"
- `type:Text#10`.bounds: "[126,66][188,128]" → "[1182,75][1252,120]"
- `type:Stack#6`.bounds: "[49,55][188,136]" → "[1079,55][1166,136]"
- `type:Text#9`.bounds: "[111,71][126,124]" → "[126,66][188,128]"
- `type:Row#6`.bounds: "[49,66][126,128]" → "[817,2517][1020,2636]"
- `type:Button#0`.bounds: "[115,1232][1205,1372]" → "[42,171][189,304]"
- `type:Web#0`.bounds: "[658,339][662,343]" → "[0,409][1320,2450]"
- `type:Row#5`.bounds: "[49,55][188,136]" → "[559,2517][762,2636]"
- `type:Stack#8`.bounds: "[1079,55][1166,136]" → "[1166,55][1271,136]"
- `type:Row#9`.bounds: "[1173,55][1271,136]" → "[0,0][1320,136]"
- `type:Text#7`.clickable: "true" → "false"
- `type:Text#7`.bounds: "[581,1589][1020,1634]" → "[49,66][111,128]"
- `type:Text#4`.clickable: "true" → "false"
- `type:Text#4`.bounds: "[258,935][1034,1068]" → "[576,2650][745,2699]"
- `type:Stack#11`.bounds: "[1173,69][1271,125]" → "[520,48][800,136]"
- `type:Stack#7`.bounds: "[995,55][1079,136]" → "[1086,69][1166,125]"
- `type:Row#3`.bounds: "[49,55][1271,136]" → "[41,2517][244,2636]"
- `type:rootWebArea#0`.bounds: "[658,339][662,343]" → "[0,409][1320,2450]"
- `type:Text#0`.bounds: "[629,406][692,468]" → "[217,197][997,279]"
- `type:Text#6`.clickable: "true" → "false"
- `type:Text#6`.bounds: "[300,1589][504,1634]" → "[1135,2650][1220,2699]"
- `type:Text#1`.bounds: "[583,468][739,600]" → "[56,339][1264,388]"

### 控件数量变化
- Stack: 15 → 13 (-2)
- genericContainer: 2 → 0 (-2)
- Text: 12 → 11 (-1)
- Image: 0 → 5 (+5)
- TextInput: 2 → 0 (-2)
- Row: 10 → 15 (+5)
- Column: 2 → 8 (+6)

## 断言检查结果

**通过 4/4**

| # | 类型 | 结果 | 说明 | 详情 |
|---|------|------|------|------|
| 1 | exists | PASS | ArkWeb should be mounted | 找到目标控件 |
| 2 | exists | PASS | Loading or completion status should be visible | 找到目标控件 |
| 3 | exists | PASS | Web-history back should be available | 找到目标控件 |
| 4 | exists | PASS | Explicit list return should be available | 找到目标控件 |

> **结论**: 所有断言通过，交互行为符合预期。
