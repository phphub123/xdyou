# 交互验证报告

**场景**: XDYou settings reference alignment
**描述**: Enter local preview, open settings, capture the reference-aligned first screen, then scroll through every settings group.

## 交互步骤执行结果

| # | 操作 | 状态 | 详情 |
|---|------|------|------|
| 1 | click | PASS | click (660,1463): No Error |
| 2 | click | PASS | click (1177,2607): No Error |
| 3 | snapshot | PASS | 快照保存至 /Users/niu/huawei/Project1/traintime_pda_ohos/xdyou/acceptance/runtime/202 |
| 4 | swipe | PASS | swipe (660,2200)→(660,500): No Error |
| 5 | snapshot | PASS | 快照保存至 /Users/niu/huawei/Project1/traintime_pda_ohos/xdyou/acceptance/runtime/202 |
| 6 | swipe | PASS | swipe (660,2200)→(660,500): No Error |
| 7 | snapshot | PASS | 快照保存至 /Users/niu/huawei/Project1/traintime_pda_ohos/xdyou/acceptance/runtime/202 |
| 8 | swipe | PASS | swipe (660,2200)→(660,500): No Error |
| 9 | snapshot | PASS | 快照保存至 /Users/niu/huawei/Project1/traintime_pda_ohos/xdyou/acceptance/runtime/202 |

## 交互前后界面差异

**摘要**: 新增 86 个节点; 移除 31 个节点; 文本变化 12 处; 属性变化 59 处; 数量变化: Button: 2→0, Scroll: 0→1, rootWebArea: 1→0, Web: 1→0, Text: 12→26, TextInput: 2→0, genericContainer: 2→0, Column: 2→28, Blank: 0→1, Stack: 15→13, Image: 0→5, Row: 10→22, Divider: 0→6

### 文本变化
- `type:Text#10`: "57" → "緩存登錄設置"
- `type:Text#6`: "Clear cache" → "›"
- `type:Text#4`: "IDS Login password" → "課程偏移設置"
- `type:Text#7`: "View network interaction" → "修改學期"
- `type:Text#3`: "PW" → "›"
- `type:Text#2`: "ID" → "強制刷新課表"
- `type:Text#8`: "03" → "使用學期"
- `type:Text#0`: "==" → "清除所有用戶添加課程"
- `type:Text#5`: "View" → "正數錯後開學日期 負數提前開學日期
目前為 0"
- `type:Text#11`: "100" → "查看網絡攔截器和日誌"
- `type:Text#9`: ":" → "›"
- `type:Text#1`: "XDYOU" → "›"

### 新增节点
- `type:Text#14` (Text) ›
- `text:強制刷新課表` (Text) 強制刷新課表
- `type:Column#20` (Column)
- `type:Column#7` (Column)
- `text:其他功能` (Text) 其他功能
- `type:Row#12` (Row)
- `type:Divider#4` (Divider)
- `type:Column#2` (Column)
- `type:Text#15` (Text) 退出登錄並重啟應用
- `type:Divider#5` (Divider)
- `type:Column#25` (Column)
- `type:Text#22` (Text) 03
- `key:navTo_settings` (Column)
- `type:Column#23` (Column)
- `type:Image#2` (Image)
- `type:Column#27` (Column)
- `type:Image#4` (Image)
- `type:Column#26` (Column)
- `type:Divider#1` (Divider)
- `text:睿思論壇` (Text) 睿思論壇
- ... 共 86 个

### 移除节点
- `text:==` (Text) ==
- `text:View` (Text) View
- `text:IDS Login password` (Text) IDS Login password
- `type:Web#0` (Web) https://ids.xidian.edu.cn/authserver/login?service=https%3A%2F%2Fehall.xidian.edu.cn%2Flogin%3Fservice%3Dhttps%3A%2F%2Fehall.xidian.edu.cn%2Fnew%2Findex.html
- `text:XDYOU` (Text) XDYOU
- `text:Login` (Button) Login
- `type:Button#0` (Button) Login
- `text:PW` (Text) PW
- `type:Stack#13` (Stack)
- `type:genericContainer#0` (genericContainer)
- `text:ID` (Text) ID
- `key:loginPasswordMask` (Text) IDS Login password
- `type:TextInput#1` (TextInput)
- `key:loginSubmitButton` (Button) Login
- `type:Stack#14` (Stack)
- `key:idsCookieBootstrap` (Web) https://ids.xidian.edu.cn/authserver/login?service=https%3A%2F%2Fehall.xidian.edu.cn%2Flogin%3Fservice%3Dhttps%3A%2F%2Fehall.xidian.edu.cn%2Fnew%2Findex.html
- `type:rootWebArea#0` (rootWebArea)
- `key:loginPasswordInput` (TextInput)
- `key:mockHomePreviewButton` (Button) Mock 预览主页（仅 UI，不登录）
- `key:togglePasswordVisibility` (Text) View
- ... 共 31 个

### 属性变化
- `type:Stack#6`.bounds: "[49,55][188,136]" → "[1079,55][1166,136]"
- `type:Row#2`.clickable: "false" → "true"
- `type:Row#2`.bounds: "[300,1589][1020,1634]" → "[59,449][1261,736]"
- `type:Stack#7`.bounds: "[995,55][1079,136]" → "[1086,69][1166,125]"
- `type:Text#10`.bounds: "[126,66][188,128]" → "[492,1430][828,1496]"
- `type:Stack#12`.bounds: "[1173,69][1271,125]" → "[520,48][800,136]"
- `type:Text#6`.clickable: "true" → "false"
- `type:Text#6`.bounds: "[300,1589][504,1634]" → "[1129,842][1163,965]"
- `type:Row#4`.clickable: "false" → "true"
- `type:Row#4`.bounds: "[0,0][1320,136]" → "[59,1072][1261,1359]"
- `type:Row#0`.clickable: "false" → "true"
- `type:Row#0`.bounds: "[115,756][1205,896]" → "[59,137][1261,155]"
- `type:Text#4`.clickable: "true" → "false"
- `type:Text#4`.bounds: "[258,935][1034,1068]" → "[129,809][465,875]"
- `type:Column#1`.bounds: "[559,396][762,599]" → "[0,137][1320,2450]"
- `type:Stack#9`.bounds: "[1086,69][1166,125]" → "[1173,69][1271,125]"
- `type:Row#7`.clickable: "false" → "true"
- `type:Row#7`.bounds: "[1002,55][1079,136]" → "[59,1831][1261,2118]"
- `type:Text#7`.clickable: "true" → "false"
- `type:Text#7`.bounds: "[581,1589][1020,1634]" → "[129,1149][353,1215]"
- `type:Text#3`.bounds: "[153,981][258,1022]" → "[1129,531][1163,654]"
- `type:Stack#0`.bounds: "[506,343][814,651]" → "[0,0][1320,136]"
- `type:Stack#5`.bounds: "[49,55][1320,136]" → "[995,55][1079,136]"
- `type:Text#2`.bounds: "[153,804][258,849]" → "[129,560][465,626]"
- `type:Stack#4`.bounds: "[0,0][1320,136]" → "[49,55][188,136]"
- `type:Text#8`.bounds: "[49,66][111,128]" → "[129,1225][326,1282]"
- `type:Row#6`.clickable: "false" → "true"
- `type:Row#6`.bounds: "[49,66][126,128]" → "[59,1540][1261,1827]"
- `type:Row#5`.bounds: "[49,55][188,136]" → "[59,1386][1261,1540]"
- `type:Stack#10`.bounds: "[1166,55][1271,136]" → "[1173,69][1271,125]"

### 控件数量变化
- Button: 2 → 0 (-2)
- Scroll: 0 → 1 (+1)
- rootWebArea: 1 → 0 (-1)
- Web: 1 → 0 (-1)
- Text: 12 → 26 (+14)
- TextInput: 2 → 0 (-2)
- genericContainer: 2 → 0 (-2)
- Column: 2 → 28 (+26)
- Blank: 0 → 1 (+1)
- Stack: 15 → 13 (-2)
- Image: 0 → 5 (+5)
- Row: 10 → 22 (+12)
- Divider: 0 → 6 (+6)

## 断言检查结果

**通过 4/4**

| # | 类型 | 结果 | 说明 | 详情 |
|---|------|------|------|------|
| 1 | exists | PASS | The final settings group should be reachable by scrolling | 找到目标控件 |
| 2 | exists | PASS | The real logout action should remain present | 找到目标控件 |
| 3 | exists | PASS | The fixed selected settings navigation item should remain visible | 找到目标控件 |
| 4 | page_changed | PASS | Opening and scrolling settings should change the page state | 总变化 176 处 |

> **结论**: 所有断言通过，交互行为符合预期。
