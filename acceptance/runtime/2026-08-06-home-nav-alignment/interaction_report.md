# 交互验证报告

**场景**: Campus home and bottom navigation alignment
**描述**: Open the local preview and verify the UI keys visible in UI截图/0.png.

## 交互步骤执行结果

| # | 操作 | 状态 | 详情 |
|---|------|------|------|
| 1 | click | PASS | click (660,1463): No Error |
| 2 | snapshot | PASS | 快照保存至 acceptance/runtime/2026-08-06-home-nav-alignment/snapshot_01-home-aligned |

## 交互前后界面差异

**摘要**: 新增 116 个节点; 移除 31 个节点; 文本变化 12 处; 属性变化 55 处; 数量变化: Stack: 15→13, rootWebArea: 1→0, Row: 10→22, Image: 0→19, Scroll: 0→1, TextInput: 2→0, Web: 1→0, Text: 12→30, Button: 2→0, Column: 2→23, genericContainer: 2→0

### 文本变化
- `type:Text#11`: "100" → "未登錄"
- `type:Text#9`: ":" → "借書 1 本"
- `type:Text#8`: "07" → "电费、水费与空调能耗"
- `type:Text#1`: "XDYOU" → "目前您正在運行測試版"
- `type:Text#2`: "ID" → "部分加載中"
- `type:Text#6`: "Clear cache" → "正在加載日程"
- `type:Text#7`: "View network interaction" → "电量查询"
- `type:Text#4`: "IDS Login password" → "今日安排完成"
- `type:Text#10`: "23" → "待歸還 1 本書籍"
- `type:Text#3`: "PW" → "其他實驗加載失敗"
- `type:Text#0`: "==" → "校園信息查詢"
- `type:Text#5`: "View" → "正在加載"

### 新增节点
- `type:Row#11` (Row) 
- `key:homeSport` (Column) 
- `type:Column#15` (Column) 
- `type:Column#14` (Column) 
- `text:目前您正在運行測試版` (Text) 目前您正在運行測試版
- `text:設置` (Text) 設置
- `key:homeExperiment` (Column) 
- `key:homeEnergyInfo` (Row) 
- `text:校園信息` (Text) 校園信息
- `text:實驗信息` (Text) 實驗信息
- `text:豬圖鑑賞` (Text) 豬圖鑑賞
- `text:網絡查詢` (Text) 網絡查詢
- `type:Column#20` (Column) 
- `type:Column#2` (Column) 
- `type:Row#21` (Row) 
- `type:Text#15` (Text) 空閒教室
- `type:Text#21` (Text) 校園信息
- `type:Text#13` (Text) 成績查詢
- `type:Row#15` (Row) 
- `type:Text#26` (Text) 07
- ... 共 116 个

### 移除节点
- `key:togglePasswordVisibility` (Text) View
- `text:Login` (Button) Login
- `key:loginLogo` (Stack) 
- `type:Button#1` (Button) Mock 预览主页（仅 UI，不登录）
- `type:Stack#13` (Stack) 
- `key:clearSessionButton` (Text) Clear cache
- `text:Clear cache` (Text) Clear cache
- `key:loginSubmitButton` (Button) Login
- `text:==` (Text) ==
- `text:Mock 预览主页（仅 UI，不登录）` (Button) Mock 预览主页（仅 UI，不登录）
- `text:PW` (Text) PW
- `type:TextInput#1` (TextInput) 
- `type:genericContainer#0` (genericContainer) 
- `key:mockHomePreviewButton` (Button) Mock 预览主页（仅 UI，不登录）
- `type:Button#0` (Button) Login
- `type:genericContainer#1` (genericContainer) 
- `type:Stack#14` (Stack) 
- `key:loginPasswordMask` (Text) IDS Login password
- `text:View network interaction` (Text) View network interaction
- `text:ID` (Text) ID
- ... 共 31 个

### 属性变化
- `type:Stack#6`.bounds: "[49,55][188,136]" → "[1079,55][1166,136]"
- `type:Text#11`.bounds: "[1182,75][1252,120]" → "[272,1679][472,1757]"
- `type:Row#7`.bounds: "[1002,55][1079,136]" → "[56,1896][1264,2169]"
- `type:Row#3`.clickable: "false" → "true"
- `type:Row#3`.bounds: "[49,55][1271,136]" → "[56,1098][1264,1336]"
- `type:Row#4`.clickable: "false" → "true"
- `type:Row#4`.bounds: "[0,0][1320,136]" → "[56,1364][1264,1602]"
- `type:Text#9`.bounds: "[111,71][126,124]" → "[272,1413][546,1491]"
- `type:Stack#1`.bounds: "[258,935][1034,1068]" → "[0,0][1320,136]"
- `type:Row#5`.clickable: "false" → "true"
- `type:Row#5`.bounds: "[49,55][188,136]" → "[56,1630][1264,1868]"
- `type:Stack#5`.bounds: "[49,55][1320,136]" → "[995,55][1079,136]"
- `type:Stack#8`.bounds: "[1079,55][1166,136]" → "[1166,55][1271,136]"
- `type:Text#8`.bounds: "[49,66][111,128]" → "[272,1235][728,1288]"
- `type:Text#1`.bounds: "[583,468][739,600]" → "[415,419][906,476]"
- `type:Stack#9`.bounds: "[1086,69][1166,125]" → "[1173,69][1271,125]"
- `type:Row#8`.bounds: "[1086,55][1166,136]" → "[56,2197][1264,2450]"
- `type:Text#2`.bounds: "[153,804][258,849]" → "[267,587][582,692]"
- `type:Text#6`.clickable: "true" → "false"
- `type:Text#6`.bounds: "[300,1589][504,1634]" → "[59,916][1261,1035]"
- `type:Text#7`.clickable: "true" → "false"
- `type:Text#7`.bounds: "[581,1589][1020,1634]" → "[272,1147][538,1225]"
- `type:Row#6`.bounds: "[49,66][126,128]" → "[1072,1679][1212,1819]"
- `type:Text#4`.clickable: "true" → "false"
- `type:Text#4`.bounds: "[258,935][1034,1068]" → "[272,750][692,832]"
- `type:Row#0`.bounds: "[115,756][1205,896]" → "[0,137][1320,339]"
- `type:Text#10`.bounds: "[126,66][188,128]" → "[272,1501][596,1554]"
- `type:Stack#10`.bounds: "[1166,55][1271,136]" → "[1173,69][1271,125]"
- `type:Stack#7`.bounds: "[995,55][1079,136]" → "[1086,69][1166,125]"
- `type:Stack#0`.bounds: "[506,343][814,651]" → "[0,0][1320,136]"

### 控件数量变化
- Stack: 15 → 13 (-2)
- rootWebArea: 1 → 0 (-1)
- Row: 10 → 22 (+12)
- Image: 0 → 19 (+19)
- Scroll: 0 → 1 (+1)
- TextInput: 2 → 0 (-2)
- Web: 1 → 0 (-1)
- Text: 12 → 30 (+18)
- Button: 2 → 0 (-2)
- Column: 2 → 23 (+21)
- genericContainer: 2 → 0 (-2)

## 断言检查结果

**通过 4/5**

| # | 类型 | 结果 | 说明 | 详情 |
|---|------|------|------|------|
| 1 | exists | PASS | Reference title should be visible | 找到目标控件 |
| 2 | exists | PASS | Reference beta card should be visible | 找到目标控件 |
| 3 | exists | PASS | Schedule failure chip should be visible | 找到目标控件 |
| 4 | exists | FAIL | School card preview should be visible | 未找到: {'text': '卡里 0.00 元'} |
| 5 | exists | PASS | Bottom navigation should remain visible | 找到目标控件 |

> **结论**: 存在断言失败，需检查以下问题：

> - School card preview should be visible
