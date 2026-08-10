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
        - TextInput 916×133 text="00000000000" hint="Student ID" key="loginAccountInput" [clickable]
      - Row 1090×140
        - Text 105×41 text="PW"
        - Stack 776×133
          - TextInput 776×133 text="invalid-probe-only" key="loginPasswordInput" [clickable]
          - Text 776×133 text="********" key="loginPasswordMask" [clickable]
        - Text 154×45 text="View" key="togglePasswordVisibility" [clickable]
      - Button 1090×140 text="Login" key="loginSubmitButton" [clickable]
      - Button 1090×126 text="Mock 预览主页（仅 UI，不登录）" key="mockHomePreviewButton" [clickable]
      - Text 442×57 text="请拖动滑块完成验证"
      - Stack 980×543
        - Image 980×543 key="idsSliderImage"
        - Image 154×542 key="idsSliderPiece"
      - Slider 980×140 text="114.000000" key="idsSliderControl" [clickable]
      - Button 980×140 text="Verify" key="idsSliderVerifyButton" [clickable]
      - Button 980×140 text="刷新验证码" key="idsSliderRefreshButton" [clickable]
      - Row 720×45
        - Text 204×45 text="Clear cache" key="clearSessionButton" [clickable]
        - Text 439×45 text="View network interaction" key="viewNetworkInteraction" [clickable]
      - Text 1068×31 text="滑块未通过（errorCode=0 message=error bodyBytes=34）。请点击“刷新验证码”后再试。" key="loginStatus"

## 统计
- 控件总数: 29
- 可点击: 11
- 可滚动: 3
- 最大嵌套深度: 5
- 控件类型分布:
  - Text: 10
  - Stack: 4
  - Button: 4
  - Row: 3
  - Column: 2
  - TextInput: 2
  - Image: 2
  - root: 1
  - Slider: 1
- 文本内容: ['==', 'XDYOU', 'ID', '00000000000', 'PW', 'invalid-probe-only', '********', 'View', 'Login', 'Mock 预览主页（仅 UI，不登录）', '请拖动滑块完成验证', '114.000000', 'Verify', '刷新验证码', 'Clear cache', 'View network interaction', '滑块未通过（errorCode=0 message=error bodyBytes=34）。请点击“刷新验证码”后再试。']
- Hint 提示: ['Student ID']
- Key 标识: ['loginLogo', 'loginAccountInput', 'loginPasswordInput', 'loginPasswordMask', 'togglePasswordVisibility', 'loginSubmitButton', 'mockHomePreviewButton', 'idsSliderImage', 'idsSliderPiece', 'idsSliderControl', 'idsSliderVerifyButton', 'idsSliderRefreshButton', 'clearSessionButton', 'viewNetworkInteraction', 'loginStatus']

## 视觉审美分析数据

### 屏幕信息
- 屏幕尺寸: 1320×2719 px
- 屏幕利用率（估算）: 80.3%

### 可点击控件尺寸
- ⚠️ 触控区域过小（<48px）: ['Text(View) 154×45', 'Text(Clear cache) 204×45', 'Text(View network interaction) 439×45']
- 尺寸列表: [('TextInput(00000000000)', 916, 133), ('TextInput(invalid-probe-only)', 776, 133), ('Text(********)', 776, 133), ('Text(View)', 154, 45), ('Button(Login)', 1090, 140), ('Button(Mock 预览主页（仅 UI，不登录）)', 1090, 126), ('Slider(114.000000)', 980, 140), ('Button(Verify)', 980, 140), ('Button(刷新验证码)', 980, 140), ('Text(Clear cache)', 204, 45), ('Text(View network interaction)', 439, 45)]

### 文本控件尺寸
- OK all text controls height >= 20px
- 文本控件高度分布: [31, 41, 45, 57, 62, 126, 132, 133, 140]

### 间距分析
- 同级元素垂直间距: 最小=0px, 最大=161px, 平均=47.2px
- ⚠️ 间距不一致: 存在 0px 间距与 161px 间距并存
- ⚠️ 存在 2 处大间距（>100px）: [161, 105]

### 控件尺寸分布
- 宽度范围: 63–1320px, 中位数=776px
- 高度范围: 31–2719px, 中位数=133px