# 交互验证报告

**场景**: IDS slider fallback with non-secret invalid input

## 交互步骤执行结果

| # | 操作 | 状态 | 详情 |
|---|------|------|------|
| 1 | input | PASS | input (716,822): No Error; keyboard hidden |
| 2 | input | PASS | input (646,997): No Error; keyboard hidden |
| 3 | click | PASS | click (660,1298): No Error |
| 4 | snapshot | PASS | 快照保存至 /Users/niu/huawei/Project1/traintime_pda_ohos/xdyou/acceptance/runtime/202 |

## 交互前后界面差异

**摘要**: 新增 24 个节点; 移除 3 个节点; 文本变化 14 处; 属性变化 38 处; 数量变化: Text: 12→14, Slider: 0→1, Button: 2→4, Image: 0→2, Stack: 18→19

### 文本变化
- `key:ClockStatusView`: "03, :, 14" → "03, :, 15"
- `type:Text#11`: "100" → ":"
- `type:Text#7`: "View network interaction" → "Clear cache"
- `type:Text#10`: "14" → "03"
- `type:Flex#0`: "03, :, 14" → "03, :, 15"
- `type:TextInput#1`: "" → "invalid-probe-only"
- `key:loginPasswordMask`: "IDS Login password" → "********"
- `type:Text#4`: "IDS Login password" → "********"
- `type:TextInput#0`: "" → "00000000000"
- `type:Text#8`: "03" → "View network interaction"
- `type:Text#9`: ":" → "滑块未通过（errorCode=0 message=error bodyBytes=34）。请点击“刷新验证码”后再试。"
- `key:loginPasswordInput`: "" → "invalid-probe-only"
- `type:Text#6`: "Clear cache" → "请拖动滑块完成验证"
- `key:loginAccountInput`: "" → "00000000000"

### 新增节点
- `text:00000000000` (TextInput) 00000000000
- `type:Image#0` (Image) 
- `type:Image#1` (Image) 
- `text:114.000000` (Slider) 114.000000
- `key:idsSliderImage` (Image) 
- `type:Button#2` (Button) Verify
- `text:Verify` (Button) Verify
- `type:Text#13` (Text) 100
- `text:invalid-probe-only` (TextInput) invalid-probe-only
- `key:idsSliderRefreshButton` (Button) 刷新验证码
- `type:Button#3` (Button) 刷新验证码
- `text:15` (Text) 15
- `text:********` (Text) ********
- `text:03, :, 15` (Flex) 03, :, 15
- `text:滑块未通过（errorCode=0 message=error bodyBytes=34）。请点击“刷新验证码”后再试。` (Text) 滑块未通过（errorCode=0 message=error bodyBytes=34）。请点击“刷新验证码”后再试。
- `type:Text#12` (Text) 15
- `text:刷新验证码` (Button) 刷新验证码
- `key:idsSliderControl` (Slider) 114.000000
- `type:Stack#18` (Stack) 
- `text:请拖动滑块完成验证` (Text) 请拖动滑块完成验证
- ... 共 24 个

### 移除节点
- `text:IDS Login password` (Text) IDS Login password
- `text:03, :, 14` (Flex) 03, :, 14
- `text:14` (Text) 14

### 属性变化
- `key:clearSessionButton`.bounds: "[300,1585][504,1630]" → "[300,2738][504,2783]"
- `type:Text#11`.bounds: "[1182,75][1252,120]" → "[111,71][126,124]"
- `type:Text#7`.bounds: "[581,1585][1020,1630]" → "[300,2738][504,2783]"
- `type:Stack#12`.bounds: "[1086,69][1166,125]" → "[1079,55][1166,136]"
- `type:Text#10`.bounds: "[126,66][188,128]" → "[49,66][111,128]"
- `type:Stack#13`.bounds: "[1166,55][1271,136]" → "[1086,69][1166,125]"
- `type:Stack#16`.bounds: "[520,48][800,136]" → "[1173,69][1271,125]"
- `type:Stack#14`.bounds: "[1173,69][1271,125]" → "[1166,55][1271,136]"
- `type:Row#2`.bounds: "[300,1585][1020,1630]" → "[300,2738][1020,2783]"
- `key:viewNetworkInteraction`.bounds: "[581,1585][1020,1630]" → "[581,2738][1020,2783]"
- `text:View network interaction`.bounds: "[581,1585][1020,1630]" → "[581,2738][1020,2783]"
- `type:Text#8`.clickable: "false" → "true"
- `type:Text#8`.bounds: "[49,66][111,128]" → "[581,2738][1020,2783]"
- `text:Clear cache`.bounds: "[300,1585][504,1630]" → "[300,2738][504,2783]"
- `type:Text#9`.bounds: "[111,71][126,124]" → "[126,2825][1194,2856]"
- `type:Stack#9`.bounds: "[1004,55][1079,136]" → "[920,55][1004,136]"
- `type:Stack#8`.bounds: "[920,55][1004,136]" → "[49,55][188,136]"
- `type:Text#6`.clickable: "true" → "false"
- `type:Text#6`.bounds: "[300,1585][504,1630]" → "[439,1578][881,1635]"
- `type:Stack#7`.bounds: "[49,55][188,136]" → "[49,55][1320,136]"
- `type:Stack#3`.bounds: "[0,0][1320,136]" → "[170,1663][1150,2206]"
- `type:Stack#10`.bounds: "[1011,55][1079,136]" → "[1004,55][1079,136]"
- `type:Stack#11`.bounds: "[1079,55][1166,136]" → "[1011,55][1079,136]"
- `type:Stack#6`.bounds: "[49,55][1320,136]" → "[0,0][1320,136]"

### 控件数量变化
- Text: 12 → 14 (+2)
- Slider: 0 → 1 (+1)
- Button: 2 → 4 (+2)
- Image: 0 → 2 (+2)
- Stack: 18 → 19 (+1)

## 断言检查结果

**通过 4/4**

| # | 类型 | 结果 | 说明 | 详情 |
|---|------|------|------|------|
| 1 | exists | PASS | Login protocol reports a terminal or progress state | 找到目标控件 |
| 2 | exists | PASS | Automatic attempts fall back to the manual slider | 找到目标控件 |
| 3 | exists | PASS | Manual slider can be submitted | 找到目标控件 |
| 4 | exists | PASS | A new challenge is requested only by an explicit refresh action | 找到目标控件 |

> **结论**: 所有断言通过，交互行为符合预期。
