# 交互验证报告

**场景**: Toolbox screenshot alignment
**描述**: Open the unauthenticated preview and verify the seven Traditional Chinese toolbox rows.

## 交互步骤执行结果

| # | 操作 | 状态 | 详情 |
|---|------|------|------|
| 1 | click | PASS | click (660,1463): No Error |
| 2 | click | PASS | click (660,2607): No Error |
| 3 | snapshot | PASS | 快照保存至 acceptance/runtime/2026-08-04-toolbox-aligned-final/snapshot_01-toolbox-al |

## 交互前后界面差异

**摘要**: 新增 82 个节点; 移除 31 个节点; 文本变化 12 处; 属性变化 58 处; 数量变化: Row: 10→21, Blank: 0→1, Scroll: 0→1, Image: 0→12, Button: 2→0, rootWebArea: 1→0, Web: 1→0, TextInput: 2→0, Text: 12→24, Column: 2→16, genericContainer: 2→0, Stack: 15→13

### 文本变化
- `type:Text#4`: "IDS Login password" → "喝水對身體好"
- `type:Text#6`: "Clear cache" → "不要漏水斷網"
- `type:Text#10`: "33" → "希望永不收費"
- `type:Text#5`: "View" → "後勤報修"
- `type:Text#11`: "100" → "物理計算"
- `type:Text#8`: "02" → "找個地方打牌"
- `type:Text#3`: "PW" → "訂水系統"
- `type:Text#2`: "ID" → "電費該交了吧"
- `type:Text#0`: "==" → "其他功能"
- `type:Text#1`: "XDYOU" → "繳費系統"
- `type:Text#9`: ":" → "網絡查詢"
- `type:Text#7`: "View network interaction" → "空間預約"

### 新增节点
- `text:不要漏水斷網` (Text) 不要漏水斷網
- `text:設置` (Text) 設置
- `type:Row#18` (Row) 
- `type:Image#6` (Image) 
- `text:繳費系統` (Text) 繳費系統
- `type:Text#15` (Text) 校園信息
- `type:Image#8` (Image) 
- `type:Column#8` (Column) 
- `type:Column#13` (Column) 
- `text:找個地方打牌` (Text) 找個地方打牌
- `type:Row#14` (Row) 
- `type:Column#3` (Column) 
- `type:Column#5` (Column) 
- `type:Row#20` (Row) 
- `type:Column#7` (Column) 
- `key:navTo_ruisi` (Column) 
- `text:希望操作順利` (Text) 希望操作順利
- `text:睿思導航` (Text) 睿思導航
- `text:電費該交了吧` (Text) 電費該交了吧
- `type:Row#17` (Row) 
- ... 共 82 个

### 移除节点
- `key:togglePasswordVisibility` (Text) View
- `key:clearSessionButton` (Text) Clear cache
- `key:loginLogo` (Stack) 
- `type:Button#0` (Button) Login
- `type:genericContainer#1` (genericContainer) 
- `text:View network interaction` (Text) View network interaction
- `type:Web#0` (Web) https://ids.xidian.edu.cn/authserver/login?service=https%3A%2F%2Fehall.xidian.edu.cn%2Flogin%3Fservice%3Dhttps%3A%2F%2Fehall.xidian.edu.cn%2Fnew%2Findex.html
- `type:TextInput#0` (TextInput) 
- `key:viewNetworkInteraction` (Text) View network interaction
- `text:PW` (Text) PW
- `type:genericContainer#0` (genericContainer) 
- `key:mockHomePreviewButton` (Button) Mock 预览主页（仅 UI，不登录）
- `type:TextInput#1` (TextInput) 
- `text:Mock 预览主页（仅 UI，不登录）` (Button) Mock 预览主页（仅 UI，不登录）
- `text:ID` (Text) ID
- `text:Clear cache` (Text) Clear cache
- `text:==` (Text) ==
- `text:XDYOU` (Text) XDYOU
- `type:Stack#14` (Stack) 
- `type:Button#1` (Button) Mock 预览主页（仅 UI，不登录）
- ... 共 31 个

### 属性变化
- `type:Text#4`.clickable: "true" → "false"
- `type:Text#4`.bounds: "[258,935][1034,1068]" → "[207,729][502,786]"
- `type:Stack#5`.bounds: "[49,55][1320,136]" → "[995,55][1079,136]"
- `type:Row#2`.clickable: "false" → "true"
- `type:Row#2`.bounds: "[300,1589][1020,1634]" → "[0,591][1320,843]"
- `type:Stack#10`.bounds: "[1166,55][1271,136]" → "[1173,69][1271,125]"
- `type:Row#1`.clickable: "false" → "true"
- `type:Row#1`.bounds: "[115,931][1205,1071]" → "[0,339][1320,591]"
- `type:Row#9`.bounds: "[1173,55][1271,136]" → "[41,2517][244,2636]"
- `type:Text#6`.clickable: "true" → "false"
- `type:Text#6`.bounds: "[300,1589][504,1634]" → "[207,981][502,1038]"
- `type:Text#10`.bounds: "[126,66][188,128]" → "[207,1485][502,1542]"
- `type:Text#5`.clickable: "true" → "false"
- `type:Text#5`.bounds: "[1034,979][1188,1024]" → "[207,901][431,967]"
- `type:Text#11`.bounds: "[1182,75][1252,120]" → "[207,1657][431,1723]"
- `type:Stack#12`.bounds: "[1173,69][1271,125]" → "[520,48][800,136]"
- `type:Text#8`.bounds: "[49,66][111,128]" → "[207,1233][502,1290]"
- `type:Stack#3`.bounds: "[0,0][1320,136]" → "[49,55][1320,136]"
- `type:Row#0`.bounds: "[115,756][1205,896]" → "[0,137][1320,339]"
- `type:Row#6`.clickable: "false" → "true"
- `type:Row#6`.bounds: "[49,66][126,128]" → "[0,1599][1320,1851]"
- `type:Column#1`.bounds: "[559,396][762,599]" → "[0,137][1320,2450]"
- `type:Text#3`.bounds: "[153,981][258,1022]" → "[207,649][431,715]"
- `type:Stack#6`.bounds: "[49,55][188,136]" → "[1079,55][1166,136]"
- `type:Stack#0`.bounds: "[506,343][814,651]" → "[0,0][1320,136]"
- `type:Row#5`.clickable: "false" → "true"
- `type:Row#5`.bounds: "[49,55][188,136]" → "[0,1347][1320,1599]"
- `type:Stack#8`.bounds: "[1079,55][1166,136]" → "[1166,55][1271,136]"
- `type:Stack#1`.bounds: "[258,935][1034,1068]" → "[0,0][1320,136]"
- `type:Stack#7`.bounds: "[995,55][1079,136]" → "[1086,69][1166,125]"

### 控件数量变化
- Row: 10 → 21 (+11)
- Blank: 0 → 1 (+1)
- Scroll: 0 → 1 (+1)
- Image: 0 → 12 (+12)
- Button: 2 → 0 (-2)
- rootWebArea: 1 → 0 (-1)
- Web: 1 → 0 (-1)
- TextInput: 2 → 0 (-2)
- Text: 12 → 24 (+12)
- Column: 2 → 16 (+14)
- genericContainer: 2 → 0 (-2)
- Stack: 15 → 13 (-2)

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
