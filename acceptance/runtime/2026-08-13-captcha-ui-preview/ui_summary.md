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
    - Column 1320×2621 key="idsReAuthScrim"
    - Column 1155×1394 key="idsReAuthDialog"
      - Text 987×86 text="短信二次認證"
      - Text 987×148 text="學校要求完成二次認證。請先獲取短信驗證碼，再輸入驗證碼繼續登錄。"
      - Stack 987×189
        - TextInput 988×190 key="idsReAuthCodeInput" [clickable]
        - Text 239×49 text="短信驗證碼"
      - Button 987×147 text="獲取驗證碼" key="idsReAuthSendCodeButton" [clickable]
      - Row 987×208
        - Toggle 84×84 key="idsReAuthTrustDeviceToggle" [clickable]
        - Column 826×208
          - Text 280×66 text="信任此設備"
          - Text 592×132 text="開啟後學校可能在一段時間內
不再要求本設備二次認證"
      - Row 987×140
        - Button 252×140 text="取消" key="idsReAuthCancelButton" [clickable]
        - Button 322×140 text="確定" key="idsReAuthConfirmButton" [clickable]

## 统计
- 控件总数: 37
- 可点击: 13
- 可滚动: 3
- 最大嵌套深度: 5
- 控件类型分布:
  - Text: 13
  - Column: 5
  - Row: 5
  - Button: 5
  - Stack: 4
  - TextInput: 3
  - root: 1
  - Toggle: 1
- 文本内容: ['==', 'XDYOU', 'ID', 'PW', 'IDS Login password', 'View', 'Login', 'Mock 预览主页（仅 UI，不登录）', 'Clear cache', 'View network interaction', '短信二次認證', '學校要求完成二次認證。請先獲取短信驗證碼，再輸入驗證碼繼續登錄。', '短信驗證碼', '獲取驗證碼', '信任此設備', '開啟後學校可能在一段時間內\n不再要求本設備二次認證', '取消', '確定']
- Hint 提示: ['Student ID']
- Key 标识: ['loginLogo', 'loginAccountInput', 'loginPasswordInput', 'loginPasswordMask', 'togglePasswordVisibility', 'loginSubmitButton', 'mockHomePreviewButton', 'clearSessionButton', 'viewNetworkInteraction', 'idsReAuthScrim', 'idsReAuthDialog', 'idsReAuthCodeInput', 'idsReAuthSendCodeButton', 'idsReAuthTrustDeviceToggle', 'idsReAuthCancelButton', 'idsReAuthConfirmButton']

## 视觉审美分析数据

### 屏幕信息
- 屏幕尺寸: 1320×2719 px
- 屏幕利用率（估算）: 100.0%

### 可点击控件尺寸
- ⚠️ 触控区域过小（<48px）: ['Text(View) 154×45', 'Text(Clear cache) 204×45', 'Text(View network interaction) 439×45']
- 尺寸列表: [('TextInput(loginAccountInput)', 916, 133), ('TextInput(loginPasswordInput)', 776, 133), ('Text(IDS Login password)', 776, 133), ('Text(View)', 154, 45), ('Button(Login)', 1090, 140), ('Button(Mock 预览主页（仅 UI，不登录）)', 1090, 126), ('Text(Clear cache)', 204, 45), ('Text(View network interaction)', 439, 45), ('TextInput(idsReAuthCodeInput)', 988, 190), ('Button(獲取驗證碼)', 987, 147), ('Toggle(idsReAuthTrustDeviceToggle)', 84, 84), ('Button(取消)', 252, 140), ('Button(確定)', 322, 140)]

### 文本控件尺寸
- OK all text controls height >= 20px
- 文本控件高度分布: [41, 45, 49, 62, 66, 86, 126, 132, 133, 140, 147, 148]

### 间距分析
- 同级元素垂直间距: 最小=0px, 最大=161px, 平均=59.2px
- ⚠️ 间距不一致: 存在 0px 间距与 161px 间距并存
- ⚠️ 存在 2 处大间距（>100px）: [161, 105]

### 控件尺寸分布
- 宽度范围: 63–1320px, 中位数=776px
- 高度范围: 41–2719px, 中位数=140px