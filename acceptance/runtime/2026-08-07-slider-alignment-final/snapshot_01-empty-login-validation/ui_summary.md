# UI 控件树摘要

**应用**: `io.github.benderblog.traintime_pda.harmonyos`

- root 1320×2719
  - Stack 1320×2621
    - Column 1320×2621
      - Stack 308×308 key="loginLogo"
        - Column 203×203
          - Text 63×62 text="=="
          - Text 156×132 text="XDYOU"
      - Row 1090×140
        - Text 105×45 text="ID"
        - TextInput 916×133 hint="Student ID" key="loginAccountInput" [clickable]
      - Row 1090×140
        - Text 105×41 text="PW"
        - Stack 776×133
          - TextInput 776×133 key="loginPasswordInput" [clickable]
          - Text 776×133 text="IDS Login password" key="loginPasswordMask" [clickable]
        - Text 154×45 text="View" key="togglePasswordVisibility" [clickable]
      - Button 1090×140 text="Login" key="loginSubmitButton" [clickable]
      - Button 1090×126 text="Mock 预览主页（仅 UI，不登录）" key="mockHomePreviewButton" [clickable]
      - Row 720×45
        - Text 204×45 text="Clear cache" key="clearSessionButton" [clickable]
        - Text 439×45 text="View network interaction" key="viewNetworkInteraction" [clickable]
      - Text 391×45 text="Student ID is required." key="loginStatus"

## 统计
- 控件总数: 22
- 可点击: 8
- 可滚动: 2
- 最大嵌套深度: 5
- 控件类型分布:
  - Text: 9
  - Stack: 3
  - Row: 3
  - Column: 2
  - TextInput: 2
  - Button: 2
  - root: 1
- 文本内容: ['==', 'XDYOU', 'ID', 'PW', 'IDS Login password', 'View', 'Login', 'Mock 预览主页（仅 UI，不登录）', 'Clear cache', 'View network interaction', 'Student ID is required.']
- Hint 提示: ['Student ID']
- Key 标识: ['loginLogo', 'loginAccountInput', 'loginPasswordInput', 'loginPasswordMask', 'togglePasswordVisibility', 'loginSubmitButton', 'mockHomePreviewButton', 'clearSessionButton', 'viewNetworkInteraction', 'loginStatus']

## 视觉审美分析数据

### 屏幕信息
- 屏幕尺寸: 1320×2719 px
- 屏幕利用率（估算）: 35.7%

### 可点击控件尺寸
- ⚠️ 触控区域过小（<48px）: ['Text(View) 154×45', 'Text(Clear cache) 204×45', 'Text(View network interaction) 439×45']
- 尺寸列表: [('TextInput(loginAccountInput)', 916, 133), ('TextInput(loginPasswordInput)', 776, 133), ('Text(IDS Login password)', 776, 133), ('Text(View)', 154, 45), ('Button(Login)', 1090, 140), ('Button(Mock 预览主页（仅 UI，不登录）)', 1090, 126), ('Text(Clear cache)', 204, 45), ('Text(View network interaction)', 439, 45)]

### 文本控件尺寸
- OK all text controls height >= 20px
- 文本控件高度分布: [41, 45, 62, 126, 132, 133, 140]

### 间距分析
- 同级元素垂直间距: 最小=0px, 最大=161px, 平均=62.0px
- ⚠️ 间距不一致: 存在 0px 间距与 161px 间距并存
- ⚠️ 存在 2 处大间距（>100px）: [161, 105]

### 控件尺寸分布
- 宽度范围: 63–1320px, 中位数=776px
- 高度范围: 41–2719px, 中位数=133px