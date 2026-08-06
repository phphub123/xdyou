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

**摘要**: 新增 88 个节点; 移除 33 个节点; 文本变化 14 处; 属性变化 61 处; 数量变化: Stack: 15→13, Web: 1→0, genericContainer: 2→0, Column: 2→28, Scroll: 0→1, Text: 12→26, rootWebArea: 1→0, Divider: 0→6, Blank: 0→1, Row: 10→22, TextInput: 2→0, Button: 2→0, Image: 0→5

### 文本变化
- `type:Text#10`: "04" → "緩存登錄設置"
- `type:Text#0`: "==" → "清除所有用戶添加課程"
- `key:ClockStatusView`: "11, :, 04" → "11, :, 05"
- `type:Flex#0`: "11, :, 04" → "11, :, 05"
- `type:Text#8`: "11" → "使用學期"
- `type:Text#1`: "XDYOU" → "›"
- `type:Text#7`: "View network interaction" → "修改學期"
- `type:Text#6`: "Clear cache" → "›"
- `type:Text#2`: "ID" → "強制刷新課表"
- `type:Text#11`: "100" → "查看網絡攔截器和日誌"
- `type:Text#9`: ":" → "›"
- `type:Text#3`: "PW" → "›"
- `type:Text#4`: "IDS Login password" → "課程偏移設置"
- `type:Text#5`: "View" → "正數錯後開學日期 負數提前開學日期
目前為 0"

### 新增节点
- `type:Row#17` (Row) 
- `type:Text#14` (Text) ›
- `type:Text#23` (Text) :
- `text:課程偏移設置` (Text) 課程偏移設置
- `type:Row#14` (Row) 
- `type:Column#27` (Column) 
- `type:Text#16` (Text) ›
- `type:Text#18` (Text) 睿思論壇
- `type:Blank#0` (Blank) 
- `type:Text#15` (Text) 退出登錄並重啟應用
- `type:Column#20` (Column) 
- `type:Text#13` (Text) 清除緩存後重啟
- `type:Row#18` (Row) 
- `key:navTo_toolbox` (Column) 
- `type:Column#8` (Column) 
- `text:設置` (Text) 設置
- `text:05` (Text) 05
- `text:›` (Text) ›
- `type:Divider#1` (Divider) 
- `type:Row#15` (Row) 
- ... 共 88 个

### 移除节点
- `text:View network interaction` (Text) View network interaction
- `key:loginLogo` (Stack) 
- `key:loginPasswordInput` (TextInput) 
- `type:Button#0` (Button) Login
- `key:loginPasswordMask` (Text) IDS Login password
- `text:Login` (Button) Login
- `type:Button#1` (Button) Mock 预览主页（仅 UI，不登录）
- `type:Stack#13` (Stack) 
- `key:togglePasswordVisibility` (Text) View
- `text:Clear cache` (Text) Clear cache
- `text:View` (Text) View
- `type:Web#0` (Web) https://ids.xidian.edu.cn/authserver/login?service=https%3A%2F%2Fehall.xidian.edu.cn%2Flogin%3Fservice%3Dhttps%3A%2F%2Fehall.xidian.edu.cn%2Fnew%2Findex.html
- `text:04` (Text) 04
- `key:idsCookieBootstrap` (Web) https://ids.xidian.edu.cn/authserver/login?service=https%3A%2F%2Fehall.xidian.edu.cn%2Flogin%3Fservice%3Dhttps%3A%2F%2Fehall.xidian.edu.cn%2Fnew%2Findex.html
- `type:Stack#14` (Stack) 
- `text:ID` (Text) ID
- `type:TextInput#0` (TextInput) 
- `key:viewNetworkInteraction` (Text) View network interaction
- `text:https://ids.xidian.edu.cn/authserver/login?service=https%3A%2F%2Fehall.xidian.edu.cn%2Flogin%3Fservice%3Dhttps%3A%2F%2Fehall.xidian.edu.cn%2Fnew%2Findex.html` (Web) https://ids.xidian.edu.cn/authserver/login?service=https%3A%2F%2Fehall.xidian.edu.cn%2Flogin%3Fservice%3Dhttps%3A%2F%2Fehall.xidian.edu.cn%2Fnew%2Findex.html
- `text:IDS Login password` (Text) IDS Login password
- ... 共 33 个

### 属性变化
- `type:Text#10`.bounds: "[126,66][188,128]" → "[492,1430][828,1496]"
- `type:Stack#0`.bounds: "[506,343][814,651]" → "[0,0][1320,136]"
- `type:Text#0`.bounds: "[629,406][692,468]" → "[129,269][689,335]"
- `type:Row#1`.clickable: "false" → "true"
- `type:Row#1`.bounds: "[115,931][1205,1071]" → "[59,158][1261,445]"
- `type:Text#8`.bounds: "[49,66][111,128]" → "[129,1225][326,1282]"
- `type:Row#2`.clickable: "false" → "true"
- `type:Row#2`.bounds: "[300,1589][1020,1634]" → "[59,449][1261,736]"
- `type:Row#4`.clickable: "false" → "true"
- `type:Row#4`.bounds: "[0,0][1320,136]" → "[59,1072][1261,1359]"
- `type:Stack#6`.bounds: "[49,55][188,136]" → "[1079,55][1166,136]"
- `type:Stack#3`.bounds: "[0,0][1320,136]" → "[49,55][1320,136]"
- `type:Text#1`.bounds: "[583,468][739,600]" → "[1129,240][1163,363]"
- `type:Text#7`.clickable: "true" → "false"
- `type:Text#7`.bounds: "[581,1589][1020,1634]" → "[129,1149][353,1215]"
- `type:Stack#11`.bounds: "[1173,69][1271,125]" → "[520,48][800,136]"
- `type:Text#6`.clickable: "true" → "false"
- `type:Text#6`.bounds: "[300,1589][504,1634]" → "[1129,842][1163,965]"
- `type:Stack#1`.bounds: "[258,935][1034,1068]" → "[0,0][1320,136]"
- `type:Text#2`.bounds: "[153,804][258,849]" → "[129,560][465,626]"
- `type:Row#9`.bounds: "[1173,55][1271,136]" → "[0,2450][1320,2758]"
- `type:Stack#8`.bounds: "[1079,55][1166,136]" → "[1166,55][1271,136]"
- `type:Text#11`.bounds: "[1182,75][1252,120]" → "[129,1651][689,1717]"
- `type:Row#5`.bounds: "[49,55][188,136]" → "[59,1386][1261,1540]"
- `type:Column#1`.bounds: "[559,396][762,599]" → "[0,137][1320,2450]"
- `type:Row#0`.clickable: "false" → "true"
- `type:Row#0`.bounds: "[115,756][1205,896]" → "[59,137][1261,155]"
- `type:Text#9`.bounds: "[111,71][126,124]" → "[1129,1154][1163,1277]"
- `type:Stack#7`.bounds: "[995,55][1079,136]" → "[1086,69][1166,125]"
- `type:Text#3`.bounds: "[153,981][258,1022]" → "[1129,531][1163,654]"

### 控件数量变化
- Stack: 15 → 13 (-2)
- Web: 1 → 0 (-1)
- genericContainer: 2 → 0 (-2)
- Column: 2 → 28 (+26)
- Scroll: 0 → 1 (+1)
- Text: 12 → 26 (+14)
- rootWebArea: 1 → 0 (-1)
- Divider: 0 → 6 (+6)
- Blank: 0 → 1 (+1)
- Row: 10 → 22 (+12)
- TextInput: 2 → 0 (-2)
- Button: 2 → 0 (-2)
- Image: 0 → 5 (+5)

## 断言检查结果

**通过 4/4**

| # | 类型 | 结果 | 说明 | 详情 |
|---|------|------|------|------|
| 1 | exists | PASS | The final settings group should be reachable by scrolling | 找到目标控件 |
| 2 | exists | PASS | The real logout action should remain present | 找到目标控件 |
| 3 | exists | PASS | The fixed selected settings navigation item should remain visible | 找到目标控件 |
| 4 | page_changed | PASS | Opening and scrolling settings should change the page state | 总变化 182 处 |

> **结论**: 所有断言通过，交互行为符合预期。
