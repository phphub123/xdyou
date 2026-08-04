# 交互验证报告

**场景**: Campus home and bottom navigation alignment
**描述**: Open the local preview and verify the UI keys visible in UI截图/0.png.

## 交互步骤执行结果

| # | 操作 | 状态 | 详情 |
|---|------|------|------|
| 1 | click | PASS | click (660,1463): No Error |
| 2 | snapshot | PASS | 快照保存至 /Users/niu/huawei/Project1/traintime_pda_ohos/xdyou/acceptance/runtime/202 |

## 交互前后界面差异

**摘要**: 新增 105 个节点; 移除 31 个节点; 文本变化 12 处; 属性变化 55 处; 数量变化: genericContainer: 2→0, TextInput: 2→0, Column: 2→23, rootWebArea: 1→0, Row: 10→22, Scroll: 0→1, Web: 1→0, Image: 0→19, Button: 2→0, Text: 12→30, Stack: 15→13

### 文本变化
- `type:Text#4`: "IDS Login password" → "今日安排完成"
- `type:Text#7`: "View network interaction" → "電量查詢失敗"
- `type:Text#5`: "View" → "正在加載"
- `type:Text#9`: ":" → "借書 1 本"
- `type:Text#2`: "ID" → "部分加載中"
- `type:Text#10`: "46" → "待歸還 1 本書籍"
- `type:Text#6`: "Clear cache" → "正在加載日程"
- `type:Text#8`: "10" → "欠費查詢網絡故障"
- `type:Text#0`: "==" → "校園信息查詢"
- `type:Text#1`: "XDYOU" → "目前您正在運行測試版"
- `type:Text#11`: "100" → "卡里 0.00 元"
- `type:Text#3`: "PW" → "其他實驗加載失敗"

### 新增节点
- `type:Column#8` (Column) 
- `type:Image#0` (Image) 
- `type:Column#4` (Column) 
- `type:Text#14` (Text) 考試安排
- `type:Image#14` (Image) 
- `key:navTo_settings` (Column) 
- `type:Image#7` (Image) 
- `type:Text#23` (Text) 其他功能
- `type:Text#17` (Text) 網絡查詢
- `type:Row#15` (Row) 
- `key:mockPreviewBanner` (Column) 
- `type:Column#19` (Column) 
- `text:網絡查詢` (Text) 網絡查詢
- `type:Text#27` (Text) :
- `text:欠費查詢網絡故障` (Text) 欠費查詢網絡故障
- `key:navTo_pig` (Column) 
- `type:Column#6` (Column) 
- `type:Text#21` (Text) 校園信息
- `type:Image#15` (Image) 
- `key:navTo_toolbox` (Column) 
- ... 共 105 个

### 移除节点
- `type:TextInput#1` (TextInput) 
- `text:View` (Text) View
- `key:loginAccountInput` (TextInput) 
- `key:mockHomePreviewButton` (Button) Mock 预览主页（仅 UI，不登录）
- `type:Stack#13` (Stack) 
- `text:IDS Login password` (Text) IDS Login password
- `type:genericContainer#0` (genericContainer) 
- `type:Web#0` (Web) https://ids.xidian.edu.cn/authserver/login?service=https%3A%2F%2Fehall.xidian.edu.cn%2Flogin%3Fservice%3Dhttps%3A%2F%2Fehall.xidian.edu.cn%2Fnew%2Findex.html
- `key:idsCookieBootstrap` (Web) https://ids.xidian.edu.cn/authserver/login?service=https%3A%2F%2Fehall.xidian.edu.cn%2Flogin%3Fservice%3Dhttps%3A%2F%2Fehall.xidian.edu.cn%2Fnew%2Findex.html
- `type:rootWebArea#0` (rootWebArea) 
- `key:loginPasswordInput` (TextInput) 
- `text:PW` (Text) PW
- `key:loginLogo` (Stack) 
- `text:XDYOU` (Text) XDYOU
- `type:Button#0` (Button) Login
- `key:loginPasswordMask` (Text) IDS Login password
- `type:TextInput#0` (TextInput) 
- `text:View network interaction` (Text) View network interaction
- `type:Button#1` (Button) Mock 预览主页（仅 UI，不登录）
- `text:Clear cache` (Text) Clear cache
- ... 共 31 个

### 属性变化
- `type:Text#4`.clickable: "true" → "false"
- `type:Text#4`.bounds: "[258,935][1034,1068]" → "[272,750][692,832]"
- `type:Text#7`.clickable: "true" → "false"
- `type:Text#7`.bounds: "[581,1589][1020,1634]" → "[272,1147][671,1225]"
- `type:Text#5`.clickable: "true" → "false"
- `type:Text#5`.bounds: "[1034,979][1188,1024]" → "[272,835][455,888]"
- `type:Row#9`.bounds: "[1173,55][1271,136]" → "[0,2450][1320,2758]"
- `type:Text#9`.bounds: "[111,71][126,124]" → "[272,1413][546,1491]"
- `type:Row#7`.bounds: "[1002,55][1079,136]" → "[56,1896][1264,2169]"
- `type:Stack#10`.bounds: "[1166,55][1271,136]" → "[1173,69][1271,125]"
- `type:Stack#8`.bounds: "[1079,55][1166,136]" → "[1166,55][1271,136]"
- `type:Row#6`.bounds: "[49,66][126,128]" → "[1072,1679][1212,1819]"
- `type:Row#4`.clickable: "false" → "true"
- `type:Row#4`.bounds: "[0,0][1320,136]" → "[56,1364][1264,1602]"
- `type:Text#2`.bounds: "[153,804][258,849]" → "[267,587][582,692]"
- `type:Stack#1`.bounds: "[258,935][1034,1068]" → "[0,0][1320,136]"
- `type:Row#3`.clickable: "false" → "true"
- `type:Row#3`.bounds: "[49,55][1271,136]" → "[56,1098][1264,1336]"
- `type:Stack#7`.bounds: "[995,55][1079,136]" → "[1086,69][1166,125]"
- `type:Stack#4`.bounds: "[0,0][1320,136]" → "[49,55][188,136]"
- `type:Row#1`.bounds: "[115,931][1205,1071]" → "[59,555][1261,723]"
- `type:Row#8`.bounds: "[1086,55][1166,136]" → "[56,2197][1264,2450]"
- `type:Stack#3`.bounds: "[0,0][1320,136]" → "[49,55][1320,136]"
- `type:Text#10`.bounds: "[126,66][188,128]" → "[272,1501][596,1554]"
- `type:Text#6`.clickable: "true" → "false"
- `type:Text#6`.bounds: "[300,1589][504,1634]" → "[59,916][1261,1035]"
- `type:Text#8`.bounds: "[49,66][111,128]" → "[272,1235][637,1288]"
- `type:Row#5`.clickable: "false" → "true"
- `type:Row#5`.bounds: "[49,55][188,136]" → "[56,1630][1264,1868]"
- `type:Stack#5`.bounds: "[49,55][1320,136]" → "[995,55][1079,136]"

### 控件数量变化
- genericContainer: 2 → 0 (-2)
- TextInput: 2 → 0 (-2)
- Column: 2 → 23 (+21)
- rootWebArea: 1 → 0 (-1)
- Row: 10 → 22 (+12)
- Scroll: 0 → 1 (+1)
- Web: 1 → 0 (-1)
- Image: 0 → 19 (+19)
- Button: 2 → 0 (-2)
- Text: 12 → 30 (+18)
- Stack: 15 → 13 (-2)

## 断言检查结果

**通过 5/5**

| # | 类型 | 结果 | 说明 | 详情 |
|---|------|------|------|------|
| 1 | exists | PASS | Reference title should be visible | 找到目标控件 |
| 2 | exists | PASS | Reference beta card should be visible | 找到目标控件 |
| 3 | exists | PASS | Schedule failure chip should be visible | 找到目标控件 |
| 4 | exists | PASS | School card preview should be visible | 找到目标控件 |
| 5 | exists | PASS | Bottom navigation should remain visible | 找到目标控件 |

> **结论**: 所有断言通过，交互行为符合预期。
