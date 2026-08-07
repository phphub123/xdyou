# 交互验证报告

**场景**: XDYou settings reference alignment
**描述**: Enter local preview, open settings, capture the reference-aligned first screen, then scroll through every settings group.

## 交互步骤执行结果

| # | 操作 | 状态 | 详情 |
|---|------|------|------|
| 1 | click | PASS | click (660,1463): No Error |
| 2 | click | PASS | click (1177,2607): No Error |
| 3 | snapshot | PASS | 快照保存至 acceptance/runtime/2026-08-06-settings-alignment/snapshot_01-settings-top |
| 4 | swipe | PASS | swipe (660,2200)→(660,500): No Error |
| 5 | snapshot | PASS | 快照保存至 acceptance/runtime/2026-08-06-settings-alignment/snapshot_02-settings-midd |
| 6 | swipe | PASS | swipe (660,2200)→(660,500): No Error |
| 7 | snapshot | PASS | 快照保存至 acceptance/runtime/2026-08-06-settings-alignment/snapshot_03-settings-lowe |
| 8 | swipe | PASS | swipe (660,2200)→(660,500): No Error |
| 9 | snapshot | PASS | 快照保存至 acceptance/runtime/2026-08-06-settings-alignment/snapshot_04-settings-bott |

## 交互前后界面差异

**摘要**: 新增 86 个节点; 移除 31 个节点; 文本变化 12 处; 属性变化 59 处; 数量变化: Stack: 15→13, Web: 1→0, Divider: 0→6, rootWebArea: 1→0, Column: 2→28, TextInput: 2→0, Blank: 0→1, Row: 10→22, Text: 12→26, Button: 2→0, genericContainer: 2→0, Scroll: 0→1, Image: 0→5

### 文本变化
- `type:Text#3`: "PW" → "›"
- `type:Text#1`: "XDYOU" → "›"
- `type:Text#11`: "100" → "查看網絡攔截器和日誌"
- `type:Text#0`: "==" → "清除所有用戶添加課程"
- `type:Text#7`: "View network interaction" → "修改學期"
- `type:Text#4`: "IDS Login password" → "課程偏移設置"
- `type:Text#6`: "Clear cache" → "›"
- `type:Text#10`: "24" → "緩存登錄設置"
- `type:Text#5`: "View" → "正數錯後開學日期 負數提前開學日期
目前為 0"
- `type:Text#8`: "07" → "使用學期"
- `type:Text#2`: "ID" → "強制刷新課表"
- `type:Text#9`: ":" → "›"

### 新增节点
- `type:Column#27` (Column) 
- `type:Column#6` (Column) 
- `type:Row#11` (Row) 
- `type:Row#18` (Row) 
- `type:Column#11` (Column) 
- `text:緩存登錄設置` (Text) 緩存登錄設置
- `type:Text#19` (Text) 其他功能
- `type:Row#19` (Row) 
- `type:Text#20` (Text) 豬圖鑑賞
- `type:Column#3` (Column) 
- `type:Column#17` (Column) 
- `type:Column#8` (Column) 
- `type:Column#10` (Column) 
- `type:Column#12` (Column) 
- `type:Row#13` (Row) 
- `text:正數錯後開學日期 負數提前開學日期
目前為 0` (Text) 正數錯後開學日期 負數提前開學日期
目前為 0
- `type:Text#18` (Text) 睿思論壇
- `type:Text#17` (Text) 校園信息
- `type:Column#5` (Column) 
- `type:Column#21` (Column) 
- ... 共 86 个

### 移除节点
- `key:loginPasswordInput` (TextInput) 
- `text:XDYOU` (Text) XDYOU
- `type:genericContainer#1` (genericContainer) 
- `type:Button#0` (Button) Login
- `text:Mock 预览主页（仅 UI，不登录）` (Button) Mock 预览主页（仅 UI，不登录）
- `key:viewNetworkInteraction` (Text) View network interaction
- `text:View network interaction` (Text) View network interaction
- `type:Stack#13` (Stack) 
- `type:Web#0` (Web) https://ids.xidian.edu.cn/authserver/login?service=https%3A%2F%2Fehall.xidian.edu.cn%2Flogin%3Fservice%3Dhttps%3A%2F%2Fehall.xidian.edu.cn%2Fnew%2Findex.html
- `text:PW` (Text) PW
- `key:loginAccountInput` (TextInput) 
- `type:Stack#14` (Stack) 
- `key:loginPasswordMask` (Text) IDS Login password
- `key:loginLogo` (Stack) 
- `key:loginSubmitButton` (Button) Login
- `type:Button#1` (Button) Mock 预览主页（仅 UI，不登录）
- `text:Login` (Button) Login
- `text:https://ids.xidian.edu.cn/authserver/login?service=https%3A%2F%2Fehall.xidian.edu.cn%2Flogin%3Fservice%3Dhttps%3A%2F%2Fehall.xidian.edu.cn%2Fnew%2Findex.html` (Web) https://ids.xidian.edu.cn/authserver/login?service=https%3A%2F%2Fehall.xidian.edu.cn%2Flogin%3Fservice%3Dhttps%3A%2F%2Fehall.xidian.edu.cn%2Fnew%2Findex.html
- `text:ID` (Text) ID
- `type:genericContainer#0` (genericContainer) 
- ... 共 31 个

### 属性变化
- `type:Stack#4`.bounds: "[0,0][1320,136]" → "[49,55][188,136]"
- `type:Stack#7`.bounds: "[995,55][1079,136]" → "[1086,69][1166,125]"
- `type:Row#7`.clickable: "false" → "true"
- `type:Row#7`.bounds: "[1002,55][1079,136]" → "[59,1831][1261,2118]"
- `type:Text#3`.bounds: "[153,981][258,1022]" → "[1129,531][1163,654]"
- `type:Row#0`.clickable: "false" → "true"
- `type:Row#0`.bounds: "[115,756][1205,896]" → "[59,137][1261,155]"
- `type:Row#5`.bounds: "[49,55][188,136]" → "[59,1386][1261,1540]"
- `type:Stack#0`.bounds: "[506,343][814,651]" → "[0,0][1320,136]"
- `type:Row#8`.clickable: "false" → "true"
- `type:Row#8`.bounds: "[1086,55][1166,136]" → "[59,2121][1261,2408]"
- `type:Stack#11`.bounds: "[1173,69][1271,125]" → "[520,48][800,136]"
- `type:Text#1`.bounds: "[583,468][739,600]" → "[1129,240][1163,363]"
- `type:Row#6`.clickable: "false" → "true"
- `type:Row#6`.bounds: "[49,66][126,128]" → "[59,1540][1261,1827]"
- `type:Text#11`.bounds: "[1182,75][1252,120]" → "[129,1651][689,1717]"
- `type:Row#3`.clickable: "false" → "true"
- `type:Row#3`.bounds: "[49,55][1271,136]" → "[59,739][1261,1068]"
- `type:Stack#10`.bounds: "[1166,55][1271,136]" → "[1173,69][1271,125]"
- `type:Stack#9`.bounds: "[1086,69][1166,125]" → "[1173,69][1271,125]"
- `type:Text#0`.bounds: "[629,406][692,468]" → "[129,269][689,335]"
- `type:Row#9`.bounds: "[1173,55][1271,136]" → "[0,2450][1320,2758]"
- `type:Row#4`.clickable: "false" → "true"
- `type:Row#4`.bounds: "[0,0][1320,136]" → "[59,1072][1261,1359]"
- `type:Stack#5`.bounds: "[49,55][1320,136]" → "[995,55][1079,136]"
- `type:Row#2`.clickable: "false" → "true"
- `type:Row#2`.bounds: "[300,1589][1020,1634]" → "[59,449][1261,736]"
- `type:Column#1`.bounds: "[559,396][762,599]" → "[0,137][1320,2450]"
- `type:Text#7`.clickable: "true" → "false"
- `type:Text#7`.bounds: "[581,1589][1020,1634]" → "[129,1149][353,1215]"

### 控件数量变化
- Stack: 15 → 13 (-2)
- Web: 1 → 0 (-1)
- Divider: 0 → 6 (+6)
- rootWebArea: 1 → 0 (-1)
- Column: 2 → 28 (+26)
- TextInput: 2 → 0 (-2)
- Blank: 0 → 1 (+1)
- Row: 10 → 22 (+12)
- Text: 12 → 26 (+14)
- Button: 2 → 0 (-2)
- genericContainer: 2 → 0 (-2)
- Scroll: 0 → 1 (+1)
- Image: 0 → 5 (+5)

## 断言检查结果

**通过 4/4**

| # | 类型 | 结果 | 说明 | 详情 |
|---|------|------|------|------|
| 1 | exists | PASS | The final settings group should be reachable by scrolling | 找到目标控件 |
| 2 | exists | PASS | The real logout action should remain present | 找到目标控件 |
| 3 | exists | PASS | The fixed selected settings navigation item should remain visible | 找到目标控件 |
| 4 | page_changed | PASS | Opening and scrolling settings should change the page state | 总变化 176 处 |

> **结论**: 所有断言通过，交互行为符合预期。
