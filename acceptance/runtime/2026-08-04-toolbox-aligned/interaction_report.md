# 交互验证报告

**场景**: Toolbox screenshot alignment
**描述**: Open the unauthenticated preview and verify the seven Traditional Chinese toolbox rows.

## 交互步骤执行结果

| # | 操作 | 状态 | 详情 |
|---|------|------|------|
| 1 | click | PASS | click (660,1463): No Error |
| 2 | click | PASS | click (660,2607): No Error |
| 3 | snapshot | PASS | 快照保存至 acceptance/runtime/2026-08-04-toolbox-aligned/snapshot_01-toolbox-aligned |

## 交互前后界面差异

**摘要**: 新增 82 个节点; 移除 31 个节点; 文本变化 12 处; 属性变化 58 处; 数量变化: Column: 2→16, Blank: 0→1, rootWebArea: 1→0, genericContainer: 2→0, Web: 1→0, Image: 0→12, Stack: 15→13, TextInput: 2→0, Text: 12→24, Button: 2→0, Scroll: 0→1, Row: 10→21

### 文本变化
- `type:Text#8`: "02" → "找個地方打牌"
- `type:Text#7`: "View network interaction" → "空間預約"
- `type:Text#9`: ":" → "網絡查詢"
- `type:Text#3`: "PW" → "訂水系統"
- `type:Text#1`: "XDYOU" → "繳費系統"
- `type:Text#0`: "==" → "其他功能"
- `type:Text#5`: "View" → "後勤報修"
- `type:Text#11`: "100" → "物理計算"
- `type:Text#6`: "Clear cache" → "不要漏水斷網"
- `type:Text#4`: "IDS Login password" → "喝水對身體好"
- `type:Text#10`: "28" → "希望永不收費"
- `type:Text#2`: "ID" → "電費該交了吧"

### 新增节点
- `type:Text#15` (Text) 校園信息
- `type:Column#4` (Column) 
- `type:Image#6` (Image) 
- `text:補充其他功能` (Text) 補充其他功能
- `type:Image#4` (Image) 
- `type:Column#7` (Column) 
- `key:navTo_toolbox` (Column) 
- `type:Image#0` (Image) 
- `type:Row#10` (Row) 
- `text:不要漏水斷網` (Text) 不要漏水斷網
- `text:繳費系統` (Text) 繳費系統
- `type:Image#11` (Image) 
- `text:訂水系統` (Text) 訂水系統
- `type:Text#20` (Text) 02
- `type:Row#11` (Row) 
- `key:toolboxWater` (Row) 
- `type:Column#2` (Column) 
- `type:Blank#0` (Blank) 
- `text:喝水對身體好` (Text) 喝水對身體好
- `type:Row#12` (Row) 
- ... 共 82 个

### 移除节点
- `text:Clear cache` (Text) Clear cache
- `key:loginPasswordInput` (TextInput) 
- `key:loginLogo` (Stack) 
- `text:Login` (Button) Login
- `type:genericContainer#1` (genericContainer) 
- `text:View` (Text) View
- `key:mockHomePreviewButton` (Button) Mock 预览主页（仅 UI，不登录）
- `text:https://ids.xidian.edu.cn/authserver/login?service=https%3A%2F%2Fehall.xidian.edu.cn%2Flogin%3Fservice%3Dhttps%3A%2F%2Fehall.xidian.edu.cn%2Fnew%2Findex.html` (Web) https://ids.xidian.edu.cn/authserver/login?service=https%3A%2F%2Fehall.xidian.edu.cn%2Flogin%3Fservice%3Dhttps%3A%2F%2Fehall.xidian.edu.cn%2Fnew%2Findex.html
- `type:Stack#13` (Stack) 
- `key:loginSubmitButton` (Button) Login
- `type:Button#0` (Button) Login
- `key:viewNetworkInteraction` (Text) View network interaction
- `type:rootWebArea#0` (rootWebArea) 
- `type:Button#1` (Button) Mock 预览主页（仅 UI，不登录）
- `type:TextInput#0` (TextInput) 
- `key:idsCookieBootstrap` (Web) https://ids.xidian.edu.cn/authserver/login?service=https%3A%2F%2Fehall.xidian.edu.cn%2Flogin%3Fservice%3Dhttps%3A%2F%2Fehall.xidian.edu.cn%2Fnew%2Findex.html
- `type:Stack#14` (Stack) 
- `text:IDS Login password` (Text) IDS Login password
- `text:ID` (Text) ID
- `text:PW` (Text) PW
- ... 共 31 个

### 属性变化
- `type:Text#8`.bounds: "[49,66][111,128]" → "[235,1233][530,1290]"
- `type:Stack#4`.bounds: "[0,0][1320,136]" → "[49,55][188,136]"
- `type:Row#9`.bounds: "[1173,55][1271,136]" → "[41,2517][244,2636]"
- `type:Stack#3`.bounds: "[0,0][1320,136]" → "[49,55][1320,136]"
- `type:Stack#1`.bounds: "[258,935][1034,1068]" → "[0,0][1320,136]"
- `type:Stack#8`.bounds: "[1079,55][1166,136]" → "[1166,55][1271,136]"
- `type:Row#5`.clickable: "false" → "true"
- `type:Row#5`.bounds: "[49,55][188,136]" → "[0,1347][1320,1599]"
- `type:Row#6`.clickable: "false" → "true"
- `type:Row#6`.bounds: "[49,66][126,128]" → "[0,1599][1320,1851]"
- `type:Text#7`.clickable: "true" → "false"
- `type:Text#7`.bounds: "[581,1589][1020,1634]" → "[235,1153][459,1219]"
- `type:Text#9`.bounds: "[111,71][126,124]" → "[235,1405][459,1471]"
- `type:Stack#6`.bounds: "[49,55][188,136]" → "[1079,55][1166,136]"
- `type:Row#0`.bounds: "[115,756][1205,896]" → "[0,137][1320,339]"
- `type:Stack#11`.bounds: "[1173,69][1271,125]" → "[520,48][800,136]"
- `type:Text#3`.bounds: "[153,981][258,1022]" → "[235,649][459,715]"
- `type:Text#1`.bounds: "[583,468][739,600]" → "[235,397][459,463]"
- `type:Row#2`.clickable: "false" → "true"
- `type:Row#2`.bounds: "[300,1589][1020,1634]" → "[0,591][1320,843]"
- `type:Text#0`.bounds: "[629,406][692,468]" → "[70,193][1264,283]"
- `type:Text#5`.clickable: "true" → "false"
- `type:Text#5`.bounds: "[1034,979][1188,1024]" → "[235,901][459,967]"
- `type:Text#11`.bounds: "[1182,75][1252,120]" → "[235,1657][459,1723]"
- `type:Text#6`.clickable: "true" → "false"
- `type:Text#6`.bounds: "[300,1589][504,1634]" → "[235,981][530,1038]"
- `type:Row#3`.clickable: "false" → "true"
- `type:Row#3`.bounds: "[49,55][1271,136]" → "[0,843][1320,1095]"
- `type:Text#4`.clickable: "true" → "false"
- `type:Text#4`.bounds: "[258,935][1034,1068]" → "[235,729][530,786]"

### 控件数量变化
- Column: 2 → 16 (+14)
- Blank: 0 → 1 (+1)
- rootWebArea: 1 → 0 (-1)
- genericContainer: 2 → 0 (-2)
- Web: 1 → 0 (-1)
- Image: 0 → 12 (+12)
- Stack: 15 → 13 (-2)
- TextInput: 2 → 0 (-2)
- Text: 12 → 24 (+12)
- Button: 2 → 0 (-2)
- Scroll: 0 → 1 (+1)
- Row: 10 → 21 (+11)

## 断言检查结果

**通过 8/8**

| # | 类型 | 结果 | 说明 | 详情 |
|---|------|------|------|------|
| 1 | exists | PASS | Toolbox title should be visible | 找到目标控件 |
| 2 | exists | PASS | Payment row should be visible | 找到目标控件 |
| 3 | exists | PASS | Water row should be visible | 找到目标控件 |
| 4 | exists | PASS | Repair row should be visible | 找到目标控件 |
| 5 | exists | PASS | Reserve row should be visible | 找到目标控件 |
| 6 | exists | PASS | Network row should be visible | 找到目标控件 |
| 7 | exists | PASS | Physics row should be visible | 找到目标控件 |
| 8 | exists | PASS | Discover row should be visible | 找到目标控件 |

> **结论**: 所有断言通过，交互行为符合预期。
