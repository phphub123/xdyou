# 交互验证报告

**场景**: XDYou five bottom tabs
**描述**: Enter the local UI preview and capture each Flutter-aligned bottom destination.

## 交互步骤执行结果

| # | 操作 | 状态 | 详情 |
|---|------|------|------|
| 1 | click | PASS | click (660,1463): No Error |
| 2 | snapshot | PASS | 快照保存至 /Users/niu/huawei/Project1/traintime_pda_ohos/xdyou/acceptance/runtime/202 |
| 3 | click | PASS | click (402,2814): No Error |
| 4 | snapshot | PASS | 快照保存至 /Users/niu/huawei/Project1/traintime_pda_ohos/xdyou/acceptance/runtime/202 |
| 5 | click | PASS | click (660,2814): No Error |
| 6 | snapshot | PASS | 快照保存至 /Users/niu/huawei/Project1/traintime_pda_ohos/xdyou/acceptance/runtime/202 |
| 7 | click | PASS | click (917,2814): No Error |
| 8 | snapshot | PASS | 快照保存至 /Users/niu/huawei/Project1/traintime_pda_ohos/xdyou/acceptance/runtime/202 |
| 9 | click | PASS | click (1174,2814): No Error |
| 10 | snapshot | PASS | 快照保存至 /Users/niu/huawei/Project1/traintime_pda_ohos/xdyou/acceptance/runtime/202 |

## 交互前后界面差异

**摘要**: 新增 79 个节点; 移除 33 个节点; 文本变化 14 处; 属性变化 61 处; 数量变化: TextInput: 2→0, Button: 2→0, Row: 10→16, Stack: 15→13, Text: 12→36, Web: 1→0, rootWebArea: 1→0, genericContainer: 2→0, Column: 2→15, Scroll: 0→1

### 文本变化
- `type:Text#0`: "==" → "XDYou"
- `type:Text#6`: "Clear cache" → "检查更新"
- `type:Text#11`: "100" → "默认蓝色"
- `key:ClockStatusView`: "10, :, 08" → "10, :, 09"
- `type:Text#10`: "08" → "主题配色"
- `type:Text#4`: "IDS Login password" → "XDYou 仓颉 HarmonyOS 原生版"
- `type:Text#8`: "10" → "›"
- `type:Text#9`: ":" → "界面设置"
- `type:Text#3`: "PW" → "关于本程序"
- `type:Text#1`: "XDYOU" → "Written by BenderBlog Rodriguez and contributors"
- `type:Flex#0`: "10, :, 08" → "10, :, 09"
- `type:Text#2`: "ID" → "关于"
- `type:Text#5`: "View" → "›"
- `type:Text#7`: "View network interaction" → "当前版本 1.0.0"

### 新增节点
- `type:Row#13` (Row) 
- `text:开` (Text) 开
- `type:Text#35` (Text) 100
- `type:Row#10` (Row) 
- `text:亮度设置` (Text) 亮度设置
- `text:关于本程序` (Text) 关于本程序
- `type:Column#14` (Column) 
- `type:Text#20` (Text) 切换学期
- `type:Row#12` (Row) 
- `key:navTo_settings` (Column) 
- `text:简化课程时间轴` (Text) 简化课程时间轴
- `type:Text#34` (Text) 09
- `type:Column#9` (Column) 
- `text:账户与数据` (Text) 账户与数据
- `type:Text#16` (Text) 简化课程时间轴
- `text:课程表设置` (Text) 课程表设置
- `text:XDYou 仓颉 HarmonyOS 原生版` (Text) XDYou 仓颉 HarmonyOS 原生版
- `text:通知与系统日历设置` (Text) 通知与系统日历设置
- `type:Text#15` (Text) 日 夜
- `text:当前学期 2026-1` (Text) 当前学期 2026-1
- ... 共 79 个

### 移除节点
- `text:View` (Text) View
- `key:mockHomePreviewButton` (Button) Mock 预览主页（仅 UI，不登录）
- `type:genericContainer#1` (genericContainer) 
- `key:clearSessionButton` (Text) Clear cache
- `type:Button#1` (Button) Mock 预览主页（仅 UI，不登录）
- `text:IDS Login password` (Text) IDS Login password
- `type:rootWebArea#0` (rootWebArea) 
- `text:View network interaction` (Text) View network interaction
- `text:XDYOU` (Text) XDYOU
- `type:Stack#14` (Stack) 
- `key:loginLogo` (Stack) 
- `text:PW` (Text) PW
- `key:togglePasswordVisibility` (Text) View
- `text:Clear cache` (Text) Clear cache
- `key:idsCookieBootstrap` (Web) https://ids.xidian.edu.cn/authserver/login?service=https%3A%2F%2Fehall.xidian.edu.cn%2Flogin%3Fservice%3Dhttps%3A%2F%2Fehall.xidian.edu.cn%2Fnew%2Findex.html
- `text:10, :, 08` (Flex) 10, :, 08
- `key:loginPasswordMask` (Text) IDS Login password
- `text:==` (Text) ==
- `type:Web#0` (Web) https://ids.xidian.edu.cn/authserver/login?service=https%3A%2F%2Fehall.xidian.edu.cn%2Flogin%3Fservice%3Dhttps%3A%2F%2Fehall.xidian.edu.cn%2Fnew%2Findex.html
- `text:https://ids.xidian.edu.cn/authserver/login?service=https%3A%2F%2Fehall.xidian.edu.cn%2Flogin%3Fservice%3Dhttps%3A%2F%2Fehall.xidian.edu.cn%2Fnew%2Findex.html` (Web) https://ids.xidian.edu.cn/authserver/login?service=https%3A%2F%2Fehall.xidian.edu.cn%2Flogin%3Fservice%3Dhttps%3A%2F%2Fehall.xidian.edu.cn%2Fnew%2Findex.html
- ... 共 33 个

### 属性变化
- `type:Stack#0`.bounds: "[506,343][814,651]" → "[0,0][1320,136]"
- `type:Stack#3`.bounds: "[0,0][1320,136]" → "[49,55][1320,136]"
- `type:Stack#7`.bounds: "[995,55][1079,136]" → "[1086,69][1166,125]"
- `type:Stack#11`.bounds: "[1173,69][1271,125]" → "[520,48][800,136]"
- `type:Row#0`.clickable: "false" → "true"
- `type:Row#0`.bounds: "[115,756][1205,896]" → "[56,549][1264,787]"
- `type:Text#0`.bounds: "[629,406][692,468]" → "[56,199][302,289]"
- `type:Text#6`.clickable: "true" → "false"
- `type:Text#6`.bounds: "[300,1589][504,1634]" → "[115,842][326,904]"
- `type:Row#7`.clickable: "false" → "true"
- `type:Row#7`.bounds: "[1002,55][1079,136]" → "[56,2743][1264,2758]"
- `type:Stack#1`.bounds: "[258,935][1034,1068]" → "[0,0][1320,136]"
- `type:Row#6`.clickable: "false" → "true"
- `type:Row#6`.bounds: "[49,66][126,128]" → "[56,2329][1264,2567]"
- `type:Stack#5`.bounds: "[49,55][1320,136]" → "[995,55][1079,136]"
- `type:Text#11`.bounds: "[1182,75][1252,120]" → "[115,1335][284,1384]"
- `type:Text#10`.bounds: "[126,66][188,128]" → "[115,1256][326,1318]"
- `type:Row#5`.clickable: "false" → "true"
- `type:Row#5`.bounds: "[49,55][188,136]" → "[56,2091][1264,2329]"
- `type:Row#8`.bounds: "[1086,55][1166,136]" → "[0,2758][1320,2856]"
- `type:Stack#12`.bounds: "[1173,69][1271,125]" → "[520,48][800,136]"
- `type:Stack#10`.bounds: "[1166,55][1271,136]" → "[1173,69][1271,125]"
- `type:Text#4`.clickable: "true" → "false"
- `type:Text#4`.bounds: "[258,935][1034,1068]" → "[115,683][718,732]"
- `type:Row#1`.clickable: "false" → "true"
- `type:Row#1`.bounds: "[115,931][1205,1071]" → "[56,787][1264,1025]"
- `type:Text#8`.bounds: "[49,66][111,128]" → "[1189,878][1205,935]"
- `type:Stack#8`.bounds: "[1079,55][1166,136]" → "[1166,55][1271,136]"
- `type:Stack#9`.bounds: "[1086,69][1166,125]" → "[1173,69][1271,125]"
- `type:Row#3`.clickable: "false" → "true"

### 控件数量变化
- TextInput: 2 → 0 (-2)
- Button: 2 → 0 (-2)
- Row: 10 → 16 (+6)
- Stack: 15 → 13 (-2)
- Text: 12 → 36 (+24)
- Web: 1 → 0 (-1)
- rootWebArea: 1 → 0 (-1)
- genericContainer: 2 → 0 (-2)
- Column: 2 → 15 (+13)
- Scroll: 0 → 1 (+1)

## 断言检查结果

**通过 3/3**

| # | 类型 | 结果 | 说明 | 详情 |
|---|------|------|------|------|
| 1 | exists | PASS | Settings page should show the XDYou heading | 找到目标控件 |
| 2 | exists | PASS | Bottom navigation should remain visible | 找到目标控件 |
| 3 | page_changed | PASS | Navigation should change the page content | 总变化 173 处 |

> **结论**: 所有断言通过，交互行为符合预期。
