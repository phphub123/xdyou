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

**摘要**: 新增 85 个节点; 移除 33 个节点; 文本变化 14 处; 属性变化 60 处; 数量变化: Button: 2→0, Row: 10→20, Column: 2→16, Text: 12→34, Scroll: 0→1, Stack: 15→13, TextInput: 2→0, Image: 0→5, rootWebArea: 1→0, Web: 1→0, genericContainer: 2→0

### 文本变化
- `type:Text#6`: "Clear cache" → "检查更新"
- `type:Text#10`: "43" → "主题配色"
- `type:Text#9`: ":" → "界面设置"
- `type:Text#11`: "100" → "默认蓝色"
- `type:Text#5`: "View" → "›"
- `key:ClockStatusView`: "10, :, 43" → "10, :, 44"
- `type:Text#3`: "PW" → "关于本程序"
- `type:Text#2`: "ID" → "关于"
- `type:Flex#0`: "10, :, 43" → "10, :, 44"
- `type:Text#0`: "==" → "XDYou"
- `type:Text#7`: "View network interaction" → "当前版本 1.0.0"
- `type:Text#8`: "10" → "›"
- `type:Text#4`: "IDS Login password" → "XDYou 仓颉 HarmonyOS 原生版"
- `type:Text#1`: "XDYOU" → "Written by BenderBlog Rodriguez and contributors"

### 新增节点
- `text:›` (Text) ›
- `type:Column#12` (Column) 
- `type:Text#28` (Text) 豬圖鑑賞
- `type:Column#4` (Column) 
- `type:Text#29` (Text) 設置
- `text:当前版本 1.0.0` (Text) 当前版本 1.0.0
- `type:Text#15` (Text) 日 夜
- `text:XDYou` (Text) XDYou
- `type:Text#17` (Text) 精简显示课程节次
- `text:跟随系统` (Text) 跟随系统
- `type:Row#17` (Row) 
- `key:navTo_ruisi` (Column) 
- `text:亮度设置` (Text) 亮度设置
- `type:Column#10` (Column) 
- `type:Column#7` (Column) 
- `type:Text#18` (Text) 开
- `type:Row#13` (Row) 
- `text:开` (Text) 开
- `type:Image#2` (Image) 
- `text:日 夜` (Text) 日 夜
- ... 共 85 个

### 移除节点
- `text:Clear cache` (Text) Clear cache
- `key:mockHomePreviewButton` (Button) Mock 预览主页（仅 UI，不登录）
- `type:Stack#14` (Stack) 
- `type:rootWebArea#0` (rootWebArea) 
- `text:IDS Login password` (Text) IDS Login password
- `key:loginLogo` (Stack) 
- `type:Web#0` (Web) https://ids.xidian.edu.cn/authserver/login?service=https%3A%2F%2Fehall.xidian.edu.cn%2Flogin%3Fservice%3Dhttps%3A%2F%2Fehall.xidian.edu.cn%2Fnew%2Findex.html
- `text:XDYOU` (Text) XDYOU
- `text:View` (Text) View
- `key:idsCookieBootstrap` (Web) https://ids.xidian.edu.cn/authserver/login?service=https%3A%2F%2Fehall.xidian.edu.cn%2Flogin%3Fservice%3Dhttps%3A%2F%2Fehall.xidian.edu.cn%2Fnew%2Findex.html
- `text:https://ids.xidian.edu.cn/authserver/login?service=https%3A%2F%2Fehall.xidian.edu.cn%2Flogin%3Fservice%3Dhttps%3A%2F%2Fehall.xidian.edu.cn%2Fnew%2Findex.html` (Web) https://ids.xidian.edu.cn/authserver/login?service=https%3A%2F%2Fehall.xidian.edu.cn%2Flogin%3Fservice%3Dhttps%3A%2F%2Fehall.xidian.edu.cn%2Fnew%2Findex.html
- `type:Stack#13` (Stack) 
- `text:View network interaction` (Text) View network interaction
- `type:genericContainer#1` (genericContainer) 
- `key:togglePasswordVisibility` (Text) View
- `type:TextInput#0` (TextInput) 
- `text:ID` (Text) ID
- `key:loginPasswordInput` (TextInput) 
- `key:loginPasswordMask` (Text) IDS Login password
- `key:loginSubmitButton` (Button) Login
- ... 共 33 个

### 属性变化
- `type:Text#6`.clickable: "true" → "false"
- `type:Text#6`.bounds: "[300,1589][504,1634]" → "[115,842][326,904]"
- `type:Stack#12`.bounds: "[1173,69][1271,125]" → "[520,48][800,136]"
- `type:Text#10`.bounds: "[126,66][188,128]" → "[115,1256][326,1318]"
- `type:Stack#9`.bounds: "[1086,69][1166,125]" → "[1173,69][1271,125]"
- `type:Row#9`.bounds: "[1173,55][1271,136]" → "[300,2517][503,2636]"
- `type:Text#9`.bounds: "[111,71][126,124]" → "[56,1074][1264,1201]"
- `type:Row#2`.clickable: "false" → "true"
- `type:Row#2`.bounds: "[300,1589][1020,1634]" → "[56,1201][1264,1439]"
- `type:Text#11`.bounds: "[1182,75][1252,120]" → "[115,1335][284,1384]"
- `type:Stack#1`.bounds: "[258,935][1034,1068]" → "[0,0][1320,136]"
- `type:Stack#11`.bounds: "[1173,69][1271,125]" → "[520,48][800,136]"
- `type:Row#4`.clickable: "false" → "true"
- `type:Row#4`.bounds: "[0,0][1320,136]" → "[56,1677][1264,1915]"
- `type:Text#5`.clickable: "true" → "false"
- `type:Text#5`.bounds: "[1034,979][1188,1024]" → "[1189,640][1205,697]"
- `type:Row#6`.clickable: "false" → "true"
- `type:Row#6`.bounds: "[49,66][126,128]" → "[56,2329][1264,2450]"
- `type:Row#0`.clickable: "false" → "true"
- `type:Row#0`.bounds: "[115,756][1205,896]" → "[56,549][1264,787]"
- `type:Stack#4`.bounds: "[0,0][1320,136]" → "[49,55][188,136]"
- `type:Row#3`.clickable: "false" → "true"
- `type:Row#3`.bounds: "[49,55][1271,136]" → "[56,1439][1264,1677]"
- `type:Text#3`.bounds: "[153,981][258,1022]" → "[115,604][378,666]"
- `type:Row#5`.clickable: "false" → "true"
- `type:Row#5`.bounds: "[49,55][188,136]" → "[56,2091][1264,2329]"
- `type:Row#7`.bounds: "[1002,55][1079,136]" → "[0,2450][1320,2758]"
- `type:Stack#5`.bounds: "[49,55][1320,136]" → "[995,55][1079,136]"
- `type:Text#2`.bounds: "[153,804][258,849]" → "[56,422][1264,549]"
- `type:Text#0`.bounds: "[629,406][692,468]" → "[56,199][302,289]"

### 控件数量变化
- Button: 2 → 0 (-2)
- Row: 10 → 20 (+10)
- Column: 2 → 16 (+14)
- Text: 12 → 34 (+22)
- Scroll: 0 → 1 (+1)
- Stack: 15 → 13 (-2)
- TextInput: 2 → 0 (-2)
- Image: 0 → 5 (+5)
- rootWebArea: 1 → 0 (-1)
- Web: 1 → 0 (-1)
- genericContainer: 2 → 0 (-2)

## 断言检查结果

**通过 3/3**

| # | 类型 | 结果 | 说明 | 详情 |
|---|------|------|------|------|
| 1 | exists | PASS | Settings page should show the XDYou heading | 找到目标控件 |
| 2 | exists | PASS | Bottom navigation should remain visible | 找到目标控件 |
| 3 | page_changed | PASS | Navigation should change the page content | 总变化 178 处 |

> **结论**: 所有断言通过，交互行为符合预期。
