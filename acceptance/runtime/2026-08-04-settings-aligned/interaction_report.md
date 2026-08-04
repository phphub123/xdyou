# 交互验证报告

**场景**: XDYou five bottom tabs
**描述**: Enter the local UI preview and capture each Flutter-aligned bottom destination.

## 交互步骤执行结果

| # | 操作 | 状态 | 详情 |
|---|------|------|------|
| 1 | click | PASS | click (660,1463): No Error |
| 2 | snapshot | PASS | 快照保存至 /Users/niu/huawei/Project1/traintime_pda_ohos/xdyou/acceptance/runtime/202 |
| 3 | click | PASS | click (401,2607): No Error |
| 4 | snapshot | PASS | 快照保存至 /Users/niu/huawei/Project1/traintime_pda_ohos/xdyou/acceptance/runtime/202 |
| 5 | click | PASS | click (660,2607): No Error |
| 6 | snapshot | PASS | 快照保存至 /Users/niu/huawei/Project1/traintime_pda_ohos/xdyou/acceptance/runtime/202 |
| 7 | click | PASS | click (918,2607): No Error |
| 8 | snapshot | PASS | 快照保存至 /Users/niu/huawei/Project1/traintime_pda_ohos/xdyou/acceptance/runtime/202 |
| 9 | click | PASS | click (1177,2607): No Error |
| 10 | snapshot | PASS | 快照保存至 /Users/niu/huawei/Project1/traintime_pda_ohos/xdyou/acceptance/runtime/202 |

## 交互前后界面差异

**摘要**: 新增 102 个节点; 移除 33 个节点; 文本变化 14 处; 属性变化 57 处; 数量变化: genericContainer: 2→0, Divider: 0→5, Scroll: 0→1, Button: 2→0, TextInput: 2→0, Toggle: 0→2, Row: 10→23, Web: 1→0, Text: 12→32, Column: 2→26, Stack: 15→13, rootWebArea: 1→0, Image: 0→5

### 文本变化
- `type:Text#7`: "View network interaction" → "界面设置"
- `type:Text#4`: "IDS Login password" → "检查软件更新"
- `type:Text#3`: "PW" → "›"
- `type:Text#0`: "==" → "关于"
- `type:Text#9`: ":" → "默认颜色"
- `type:Flex#0`: "03, :, 39" → "03, :, 40"
- `type:Text#8`: "03" → "颜色设置"
- `type:Text#2`: "ID" → "版本号：1.0.0+1"
- `type:Text#11`: "100" → "设置深浅色"
- `type:Text#6`: "Clear cache" → "›"
- `type:Text#1`: "XDYOU" → "关于本程序"
- `type:Text#5`: "View" → "最新版本：等待获取"
- `type:Text#10`: "39" → "›"
- `key:ClockStatusView`: "03, :, 39" → "03, :, 40"

### 新增节点
- `type:Column#24` (Column)
- `text:☀` (Text) ☀
- `type:Column#20` (Column)
- `text:最新版本：等待获取` (Text) 最新版本：等待获取
- `type:Divider#4` (Divider)
- `type:Text#25` (Text) 其他功能
- `text:简化日程时间轴` (Text) 简化日程时间轴
- `type:Divider#0` (Divider)
- `type:Scroll#0` (Scroll)
- `type:Column#2` (Column)
- `text:03, :, 40` (Flex) 03, :, 40
- `type:Column#18` (Column)
- `type:Row#13` (Row)
- `text:●` (Text) ●
- `text:低电量阈值` (Text) 低电量阈值
- `type:Text#15` (Text) ●
- `type:Text#22` (Text) ›
- `type:Text#23` (Text) 校園信息
- `text:豬圖鑑賞` (Text) 豬圖鑑賞
- `type:Text#31` (Text) 100
- ... 共 102 个

### 移除节点
- `text:View network interaction` (Text) View network interaction
- `key:loginPasswordMask` (Text) IDS Login password
- `text:PW` (Text) PW
- `text:XDYOU` (Text) XDYOU
- `text:03, :, 39` (Flex) 03, :, 39
- `type:rootWebArea#0` (rootWebArea)
- `text:Login` (Button) Login
- `key:clearSessionButton` (Text) Clear cache
- `key:loginAccountInput` (TextInput)
- `type:Button#1` (Button) Mock 预览主页（仅 UI，不登录）
- `key:togglePasswordVisibility` (Text) View
- `text:IDS Login password` (Text) IDS Login password
- `type:Web#0` (Web) https://ids.xidian.edu.cn/authserver/login?service=https%3A%2F%2Fehall.xidian.edu.cn%2Flogin%3Fservice%3Dhttps%3A%2F%2Fehall.xidian.edu.cn%2Fnew%2Findex.html
- `type:genericContainer#0` (genericContainer)
- `text:==` (Text) ==
- `text:https://ids.xidian.edu.cn/authserver/login?service=https%3A%2F%2Fehall.xidian.edu.cn%2Flogin%3Fservice%3Dhttps%3A%2F%2Fehall.xidian.edu.cn%2Fnew%2Findex.html` (Web) https://ids.xidian.edu.cn/authserver/login?service=https%3A%2F%2Fehall.xidian.edu.cn%2Flogin%3Fservice%3Dhttps%3A%2F%2Fehall.xidian.edu.cn%2Fnew%2Findex.html
- `type:Stack#13` (Stack)
- `text:View` (Text) View
- `text:39` (Text) 39
- `text:ID` (Text) ID
- ... 共 33 个

### 属性变化
- `type:Stack#1`.bounds: "[258,935][1034,1068]" → "[0,0][1320,136]"
- `type:Text#7`.clickable: "true" → "false"
- `type:Text#7`.bounds: "[581,1589][1020,1634]" → "[548,940][772,1006]"
- `type:Row#8`.bounds: "[1086,55][1166,136]" → "[59,1922][1261,2209]"
- `type:Stack#8`.bounds: "[1079,55][1166,136]" → "[1166,55][1271,136]"
- `type:Row#5`.bounds: "[49,55][188,136]" → "[59,1341][1261,1628]"
- `type:Stack#6`.bounds: "[49,55][188,136]" → "[1079,55][1166,136]"
- `type:Stack#10`.bounds: "[1166,55][1271,136]" → "[1173,69][1271,125]"
- `type:Text#4`.clickable: "true" → "false"
- `type:Text#4`.bounds: "[258,935][1034,1068]" → "[129,658][465,724]"
- `type:Text#3`.bounds: "[153,981][258,1022]" → "[1129,372][1163,495]"
- `type:Text#0`.bounds: "[629,406][692,468]" → "[604,180][716,246]"
- `type:Text#9`.bounds: "[111,71][126,124]" → "[129,1203][326,1260]"
- `type:Text#8`.bounds: "[49,66][111,128]" → "[129,1127][353,1193]"
- `type:Text#2`.bounds: "[153,804][258,849]" → "[129,443][488,500]"
- `type:Column#1`.bounds: "[559,396][762,599]" → "[0,137][1320,2450]"
- `type:Row#1`.clickable: "false" → "true"
- `type:Row#1`.bounds: "[115,931][1205,1071]" → "[59,290][1261,577]"
- `type:Text#11`.bounds: "[1182,75][1252,120]" → "[129,1418][409,1484]"
- `type:Stack#4`.bounds: "[0,0][1320,136]" → "[49,55][188,136]"
- `type:Row#2`.clickable: "false" → "true"
- `type:Row#2`.bounds: "[300,1589][1020,1634]" → "[59,581][1261,868]"
- `type:Text#6`.clickable: "true" → "false"
- `type:Text#6`.bounds: "[300,1589][504,1634]" → "[1129,663][1163,786]"
- `type:Row#6`.bounds: "[49,66][126,128]" → "[793,1418][1198,1551]"
- `type:Stack#0`.bounds: "[506,343][814,651]" → "[0,0][1320,136]"
- `type:Row#7`.bounds: "[1002,55][1079,136]" → "[59,1631][1261,1918]"
- `type:Stack#9`.bounds: "[1086,69][1166,125]" → "[1173,69][1271,125]"
- `type:Row#3`.bounds: "[49,55][1271,136]" → "[59,896][1261,1050]"
- `type:Row#4`.clickable: "false" → "true"

### 控件数量变化
- genericContainer: 2 → 0 (-2)
- Divider: 0 → 5 (+5)
- Scroll: 0 → 1 (+1)
- Button: 2 → 0 (-2)
- TextInput: 2 → 0 (-2)
- Toggle: 0 → 2 (+2)
- Row: 10 → 23 (+13)
- Web: 1 → 0 (-1)
- Text: 12 → 32 (+20)
- Column: 2 → 26 (+24)
- Stack: 15 → 13 (-2)
- rootWebArea: 1 → 0 (-1)
- Image: 0 → 5 (+5)

## 断言检查结果

**通过 2/3**

| # | 类型 | 结果 | 说明 | 详情 |
|---|------|------|------|------|
| 1 | exists | FAIL | Settings page should show the XDYou heading | 未找到: {'text': 'XDYou'} |
| 2 | exists | PASS | Bottom navigation should remain visible | 找到目标控件 |
| 3 | page_changed | PASS | Navigation should change the page content | 总变化 192 处 |

> **结论**: 存在断言失败，需检查以下问题：

> - Settings page should show the XDYou heading
