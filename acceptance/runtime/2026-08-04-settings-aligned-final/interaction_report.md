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

**摘要**: 新增 88 个节点; 移除 31 个节点; 文本变化 12 处; 属性变化 59 处; 数量变化: Text: 12→27, Scroll: 0→1, Web: 1→0, Row: 10→22, rootWebArea: 1→0, Stack: 15→13, Button: 2→0, Divider: 0→6, Blank: 0→1, TextInput: 2→0, Column: 2→28, Image: 0→5, genericContainer: 2→0

### 文本变化
- `type:Text#5`: "View" → "正数错后开学日期 负数提前开学日期
目前为 0"
- `type:Text#6`: "Clear cache" → "›"
- `type:Text#3`: "PW" → "›"
- `type:Text#10`: "43" → "缓存登录设置"
- `type:Text#4`: "IDS Login password" → "课程偏移设置"
- `type:Text#2`: "ID" → "强制刷新课表"
- `type:Text#1`: "XDYOU" → "›"
- `type:Text#9`: ":" → "›"
- `type:Text#7`: "View network interaction" → "修改学期"
- `type:Text#8`: "03" → "使用学期"
- `type:Text#11`: "100" → "查看网络拦截器和日志"
- `type:Text#0`: "==" → "清除所有用户添加课程"

### 新增节点
- `text:›` (Text) ›
- `type:Divider#0` (Divider)
- `type:Text#18` (Text) 校園信息
- `type:Scroll#0` (Scroll)
- `text:睿思論壇` (Text) 睿思論壇
- `type:Row#15` (Row)
- `type:Row#10` (Row)
- `type:Divider#3` (Divider)
- `key:navTo_pig` (Column)
- `type:Text#22` (Text) 設置
- `text:修改学期` (Text) 修改学期
- `type:Column#12` (Column)
- `type:Column#18` (Column)
- `type:Image#1` (Image)
- `type:Column#19` (Column)
- `type:Column#8` (Column)
- `type:Text#24` (Text) :
- `type:Column#14` (Column)
- `type:Text#15` (Text) 退出登录并重启应用
- `type:Row#13` (Row)
- ... 共 88 个

### 移除节点
- `key:clearSessionButton` (Text) Clear cache
- `type:Stack#13` (Stack)
- `text:View network interaction` (Text) View network interaction
- `text:Clear cache` (Text) Clear cache
- `text:Mock 预览主页（仅 UI，不登录）` (Button) Mock 预览主页（仅 UI，不登录）
- `key:loginPasswordInput` (TextInput)
- `type:genericContainer#0` (genericContainer)
- `type:TextInput#1` (TextInput)
- `type:Button#1` (Button) Mock 预览主页（仅 UI，不登录）
- `type:rootWebArea#0` (rootWebArea)
- `text:Login` (Button) Login
- `text:ID` (Text) ID
- `key:mockHomePreviewButton` (Button) Mock 预览主页（仅 UI，不登录）
- `key:loginAccountInput` (TextInput)
- `text:PW` (Text) PW
- `type:genericContainer#1` (genericContainer)
- `text:==` (Text) ==
- `text:https://ids.xidian.edu.cn/authserver/login?service=https%3A%2F%2Fehall.xidian.edu.cn%2Flogin%3Fservice%3Dhttps%3A%2F%2Fehall.xidian.edu.cn%2Fnew%2Findex.html` (Web) https://ids.xidian.edu.cn/authserver/login?service=https%3A%2F%2Fehall.xidian.edu.cn%2Flogin%3Fservice%3Dhttps%3A%2F%2Fehall.xidian.edu.cn%2Fnew%2Findex.html
- `text:XDYOU` (Text) XDYOU
- `key:loginLogo` (Stack)
- ... 共 31 个

### 属性变化
- `type:Text#5`.clickable: "true" → "false"
- `type:Text#5`.bounds: "[1034,979][1188,1024]" → "[129,885][927,999]"
- `type:Row#6`.clickable: "false" → "true"
- `type:Row#6`.bounds: "[49,66][126,128]" → "[59,1540][1261,1827]"
- `type:Text#6`.clickable: "true" → "false"
- `type:Text#6`.bounds: "[300,1589][504,1634]" → "[1129,842][1163,965]"
- `type:Text#3`.bounds: "[153,981][258,1022]" → "[1129,531][1163,654]"
- `type:Stack#3`.bounds: "[0,0][1320,136]" → "[49,55][1320,136]"
- `type:Text#10`.bounds: "[126,66][188,128]" → "[492,1430][828,1496]"
- `type:Text#4`.clickable: "true" → "false"
- `type:Text#4`.bounds: "[258,935][1034,1068]" → "[129,809][465,875]"
- `type:Text#2`.bounds: "[153,804][258,849]" → "[129,560][465,626]"
- `type:Stack#7`.bounds: "[995,55][1079,136]" → "[1086,69][1166,125]"
- `type:Text#1`.bounds: "[583,468][739,600]" → "[1129,240][1163,363]"
- `type:Stack#11`.bounds: "[1173,69][1271,125]" → "[520,48][800,136]"
- `type:Row#7`.clickable: "false" → "true"
- `type:Row#7`.bounds: "[1002,55][1079,136]" → "[59,1831][1261,2118]"
- `type:Column#1`.bounds: "[559,396][762,599]" → "[0,137][1320,2450]"
- `type:Stack#0`.bounds: "[506,343][814,651]" → "[0,0][1320,136]"
- `type:Row#3`.clickable: "false" → "true"
- `type:Row#3`.bounds: "[49,55][1271,136]" → "[59,739][1261,1068]"
- `type:Text#9`.bounds: "[111,71][126,124]" → "[1129,1154][1163,1277]"
- `type:Row#2`.clickable: "false" → "true"
- `type:Row#2`.bounds: "[300,1589][1020,1634]" → "[59,449][1261,736]"
- `type:Row#9`.bounds: "[1173,55][1271,136]" → "[0,2450][1320,2758]"
- `type:Row#4`.clickable: "false" → "true"
- `type:Row#4`.bounds: "[0,0][1320,136]" → "[59,1072][1261,1359]"
- `type:Row#5`.bounds: "[49,55][188,136]" → "[59,1386][1261,1540]"
- `type:Text#7`.clickable: "true" → "false"
- `type:Text#7`.bounds: "[581,1589][1020,1634]" → "[129,1149][353,1215]"

### 控件数量变化
- Text: 12 → 27 (+15)
- Scroll: 0 → 1 (+1)
- Web: 1 → 0 (-1)
- Row: 10 → 22 (+12)
- rootWebArea: 1 → 0 (-1)
- Stack: 15 → 13 (-2)
- Button: 2 → 0 (-2)
- Divider: 0 → 6 (+6)
- Blank: 0 → 1 (+1)
- TextInput: 2 → 0 (-2)
- Column: 2 → 28 (+26)
- Image: 0 → 5 (+5)
- genericContainer: 2 → 0 (-2)

## 断言检查结果

**通过 4/4**

| # | 类型 | 结果 | 说明 | 详情 |
|---|------|------|------|------|
| 1 | exists | PASS | The final settings group should be reachable by scrolling | 找到目标控件 |
| 2 | exists | PASS | The real logout action should remain present | 找到目标控件 |
| 3 | exists | PASS | The fixed selected settings navigation item should remain visible | 找到目标控件 |
| 4 | page_changed | PASS | Opening and scrolling settings should change the page state | 总变化 178 处 |

> **结论**: 所有断言通过，交互行为符合预期。
