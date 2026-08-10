# 交互验证报告

**场景**: XDYou login validation and process health
**描述**: Verify account/password validation and that the official IDS submission keeps the target process alive without retaining test secrets.

## 交互步骤执行结果

| # | 操作 | 状态 | 详情 |
|---|------|------|------|
| 1 | click | PASS | click (660,1298): No Error |
| 2 | snapshot | PASS | 快照保存至 /Users/niu/huawei/Project1/traintime_pda_ohos/xdyou/acceptance/runtime/202 |

## 交互前后界面差异

**摘要**: 新增 3 个节点; 文本变化 4 处; 属性变化 8 处; 数量变化: Text: 12→13

### 文本变化
- `type:Text#10`: "23" → ":"
- `type:Text#11`: "100" → "23"
- `type:Text#9`: ":" → "09"
- `type:Text#8`: "09" → "Student ID is required."

### 新增节点
- `type:Text#12` (Text) 100
- `text:Student ID is required.` (Text) Student ID is required.
- `key:loginStatus` (Text) Student ID is required.

### 属性变化
- `type:Text#10`.bounds: "[126,66][188,128]" → "[111,71][126,124]"
- `type:Text#11`.bounds: "[1182,75][1252,120]" → "[126,66][188,128]"
- `type:Text#9`.bounds: "[111,71][126,124]" → "[49,66][111,128]"
- `type:Text#8`.bounds: "[49,66][111,128]" → "[465,1672][856,1717]"

### 控件数量变化
- Text: 12 → 13 (+1)

## 断言检查结果

**通过 3/3**

| # | 类型 | 结果 | 说明 | 详情 |
|---|------|------|------|------|
| 1 | exists | PASS | Account input remains visible | 找到目标控件 |
| 2 | exists | PASS | Password input remains visible | 找到目标控件 |
| 3 | exists | PASS | Empty account validation is shown | 找到目标控件 |

> **结论**: 所有断言通过，交互行为符合预期。
