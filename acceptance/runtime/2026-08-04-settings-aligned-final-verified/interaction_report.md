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

**摘要**: 新增 86 个节点; 移除 31 个节点; 文本变化 12 处; 属性变化 59 处; 数量变化: Web: 1→0, TextInput: 2→0, genericContainer: 2→0, Text: 12→26, Divider: 0→6, Row: 10→22, Button: 2→0, Image: 0→5, Blank: 0→1, Stack: 15→13, rootWebArea: 1→0, Scroll: 0→1, Column: 2→28

### 文本变化
- `type:Text#1`: "XDYOU" → "›"
- `type:Text#11`: "100" → "查看网络拦截器和日志"
- `type:Text#6`: "Clear cache" → "›"
- `type:Text#3`: "PW" → "›"
- `type:Text#7`: "View network interaction" → "修改学期"
- `type:Text#5`: "View" → "正数错后开学日期 负数提前开学日期
目前为 0"
- `type:Text#4`: "IDS Login password" → "课程偏移设置"
- `type:Text#10`: "47" → "缓存登录设置"
- `type:Text#0`: "==" → "清除所有用户添加课程"
- `type:Text#9`: ":" → "›"
- `type:Text#2`: "ID" → "强制刷新课表"
- `type:Text#8`: "03" → "使用学期"

### 新增节点
- `text:缓存登录设置` (Text) 缓存登录设置
- `text:使用学期` (Text) 使用学期
- `type:Column#7` (Column)
- `type:Row#15` (Row)
- `type:Image#2` (Image)
- `type:Row#19` (Row)
- `type:Column#5` (Column)
- `type:Column#21` (Column)
- `type:Column#16` (Column)
- `type:Row#17` (Row)
- `type:Column#9` (Column)
- `type:Blank#0` (Blank)
- `type:Column#20` (Column)
- `type:Text#25` (Text) 100
- `type:Divider#4` (Divider)
- `type:Column#2` (Column)
- `type:Scroll#0` (Scroll)
- `type:Text#17` (Text) 校園信息
- `type:Column#3` (Column)
- `type:Column#4` (Column)
- ... 共 86 个

### 移除节点
- `key:togglePasswordVisibility` (Text) View
- `key:idsCookieBootstrap` (Web) https://ids.xidian.edu.cn/authserver/login?service=https%3A%2F%2Fehall.xidian.edu.cn%2Flogin%3Fservice%3Dhttps%3A%2F%2Fehall.xidian.edu.cn%2Fnew%2Findex.html
- `type:Button#0` (Button) Login
- `type:Button#1` (Button) Mock 预览主页（仅 UI，不登录）
- `text:XDYOU` (Text) XDYOU
- `key:loginLogo` (Stack)
- `type:Stack#14` (Stack)
- `key:loginPasswordInput` (TextInput)
- `type:rootWebArea#0` (rootWebArea)
- `text:ID` (Text) ID
- `text:Clear cache` (Text) Clear cache
- `key:loginSubmitButton` (Button) Login
- `text:PW` (Text) PW
- `key:viewNetworkInteraction` (Text) View network interaction
- `type:Stack#13` (Stack)
- `key:loginAccountInput` (TextInput)
- `text:https://ids.xidian.edu.cn/authserver/login?service=https%3A%2F%2Fehall.xidian.edu.cn%2Flogin%3Fservice%3Dhttps%3A%2F%2Fehall.xidian.edu.cn%2Fnew%2Findex.html` (Web) https://ids.xidian.edu.cn/authserver/login?service=https%3A%2F%2Fehall.xidian.edu.cn%2Flogin%3Fservice%3Dhttps%3A%2F%2Fehall.xidian.edu.cn%2Fnew%2Findex.html
- `type:Web#0` (Web) https://ids.xidian.edu.cn/authserver/login?service=https%3A%2F%2Fehall.xidian.edu.cn%2Flogin%3Fservice%3Dhttps%3A%2F%2Fehall.xidian.edu.cn%2Fnew%2Findex.html
- `text:Mock 预览主页（仅 UI，不登录）` (Button) Mock 预览主页（仅 UI，不登录）
- `key:clearSessionButton` (Text) Clear cache
- ... 共 31 个

### 属性变化
- `type:Row#9`.bounds: "[1173,55][1271,136]" → "[0,2450][1320,2758]"
- `type:Text#1`.bounds: "[583,468][739,600]" → "[1129,240][1163,363]"
- `type:Text#11`.bounds: "[1182,75][1252,120]" → "[129,1651][689,1717]"
- `type:Stack#6`.bounds: "[49,55][188,136]" → "[1079,55][1166,136]"
- `type:Stack#10`.bounds: "[1166,55][1271,136]" → "[1173,69][1271,125]"
- `type:Row#2`.clickable: "false" → "true"
- `type:Row#2`.bounds: "[300,1589][1020,1634]" → "[59,449][1261,736]"
- `type:Column#1`.bounds: "[559,396][762,599]" → "[0,137][1320,2450]"
- `type:Row#8`.clickable: "false" → "true"
- `type:Row#8`.bounds: "[1086,55][1166,136]" → "[59,2121][1261,2408]"
- `type:Text#6`.clickable: "true" → "false"
- `type:Text#6`.bounds: "[300,1589][504,1634]" → "[1129,842][1163,965]"
- `type:Stack#0`.bounds: "[506,343][814,651]" → "[0,0][1320,136]"
- `type:Stack#5`.bounds: "[49,55][1320,136]" → "[995,55][1079,136]"
- `type:Stack#3`.bounds: "[0,0][1320,136]" → "[49,55][1320,136]"
- `type:Row#5`.bounds: "[49,55][188,136]" → "[59,1386][1261,1540]"
- `type:Row#6`.clickable: "false" → "true"
- `type:Row#6`.bounds: "[49,66][126,128]" → "[59,1540][1261,1827]"
- `type:Text#3`.bounds: "[153,981][258,1022]" → "[1129,531][1163,654]"
- `type:Stack#9`.bounds: "[1086,69][1166,125]" → "[1173,69][1271,125]"
- `type:Text#7`.clickable: "true" → "false"
- `type:Text#7`.bounds: "[581,1589][1020,1634]" → "[129,1149][353,1215]"
- `type:Text#5`.clickable: "true" → "false"
- `type:Text#5`.bounds: "[1034,979][1188,1024]" → "[129,885][927,999]"
- `type:Text#4`.clickable: "true" → "false"
- `type:Text#4`.bounds: "[258,935][1034,1068]" → "[129,809][465,875]"
- `type:Text#10`.bounds: "[126,66][188,128]" → "[492,1430][828,1496]"
- `type:Stack#7`.bounds: "[995,55][1079,136]" → "[1086,69][1166,125]"
- `type:Stack#1`.bounds: "[258,935][1034,1068]" → "[0,0][1320,136]"
- `type:Row#7`.clickable: "false" → "true"

### 控件数量变化
- Web: 1 → 0 (-1)
- TextInput: 2 → 0 (-2)
- genericContainer: 2 → 0 (-2)
- Text: 12 → 26 (+14)
- Divider: 0 → 6 (+6)
- Row: 10 → 22 (+12)
- Button: 2 → 0 (-2)
- Image: 0 → 5 (+5)
- Blank: 0 → 1 (+1)
- Stack: 15 → 13 (-2)
- rootWebArea: 1 → 0 (-1)
- Scroll: 0 → 1 (+1)
- Column: 2 → 28 (+26)

## 断言检查结果

**通过 4/4**

| # | 类型 | 结果 | 说明 | 详情 |
|---|------|------|------|------|
| 1 | exists | PASS | The final settings group should be reachable by scrolling | 找到目标控件 |
| 2 | exists | PASS | The real logout action should remain present | 找到目标控件 |
| 3 | exists | PASS | The fixed selected settings navigation item should remain visible | 找到目标控件 |
| 4 | page_changed | PASS | Opening and scrolling settings should change the page state | 总变化 176 处 |

> **结论**: 所有断言通过，交互行为符合预期。
