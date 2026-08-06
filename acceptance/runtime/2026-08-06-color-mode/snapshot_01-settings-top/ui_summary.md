# UI 控件树摘要

**应用**: `io.github.benderblog.traintime_pda.harmonyos`

- root 1320×2719
  - Column 1320×2621
    - Column 1320×2313
      - Column 1320×2313
        - Scroll 1320×2313
          - Column 1320×2313
            - Row 1202×153
              - Text 112×66 text="關於"
            - Column 1202×578
              - Column 1202×291
                - Row 1202×287 [clickable]
                  - Column 972×133
                    - Text 280×66 text="關於本程序"
                    - Text 359×57 text="版本號：1.0.0+1"
                  - Text 34×123 text="›"
                - Divider 1104×4
              - Column 1202×287
                - Row 1202×287 [clickable]
                  - Column 972×133
                    - Text 336×66 text="檢查軟件更新"
                    - Text 442×57 text="最新版本：等待獲取"
                  - Text 34×123 text="›"
            - Column 1202×1554
              - Row 1202×154
                - Text 224×66 text="界面設置"
              - Column 1202×1400
                - Column 1202×291
                  - Row 1202×287 [clickable]
                    - Column 972×133
                      - Text 224×66 text="顏色設置"
                      - Text 148×57 text="春風綠"
                    - Text 34×123 text="›"
                  - Divider 1104×4
                - Column 1202×291
                  - Row 1202×287
                    - Column 664×133
                      - Text 280×66 text="設置深淺色"
                      - Text 197×57 text="白天模式"
                    - Row 405×133
                      - Text 133×133 text="▯" key="settingsThemeSystem" [clickable]
                      - Text 133×133 text="☼" key="settingsThemeLight" [clickable]
                      - Text 133×133 text="◕" key="settingsThemeDark" [clickable]
                  - Divider 1104×4
                - Column 1202×291
                  - Row 1202×287
                    - Column 838×133
                      - Text 392×66 text="簡化日程時間軸"
                      - Text 553×57 text="沒有日程時 減少空間佔用"
                    - Toggle 196×119 key="settingsTimelineToggle" [clickable]
                  - Divider 1104×4
                - Column 1202×291
                  - Row 1202×287
                    - Column 838×133
                      - Text 504×66 text="低電量卡片變色提醒"
                      - Text 749×57 text="電量小於閾值時 電量卡片變色提醒"
                    - Toggle 196×119 key="settingsLowElectricityToggle" [clickable]
                  - Divider 1104×4
                - Column 1202×238
                  - Row 1202×238 [clickable]
                    - Column 972×133
                      - Text 280×66 text="低電量閾值"
                      - Text 279×57 text="目前為 15 度"
                    - Text 34×123 text="›"
    - Row 1320×308
      - Column 259×273 key="navTo_home" [clickable]
        - Row 203×119
          - Image 88×88
        - Text 169×49 text="校園信息"
      - Column 259×273 key="navTo_ruisi" [clickable]
        - Row 203×119
          - Image 88×88
        - Text 169×49 text="睿思論壇"
      - Column 259×273 key="navTo_toolbox" [clickable]
        - Row 203×119
          - Image 88×88
        - Text 169×49 text="其他功能"
      - Column 259×273 key="navTo_pig" [clickable]
        - Row 203×119
          - Image 88×88
        - Text 169×49 text="豬圖鑑賞"
      - Column 259×273 key="navTo_settings" [clickable]
        - Row 203×119
          - Image 88×88
        - Text 85×49 text="設置"

## 统计
- 控件总数: 84
- 可点击: 14
- 可滚动: 1
- 最大嵌套深度: 11
- 控件类型分布:
  - Text: 28
  - Column: 26
  - Row: 16
  - Divider: 5
  - Image: 5
  - Toggle: 2
  - root: 1
  - Scroll: 1
- 文本内容: ['關於', '關於本程序', '版本號：1.0.0+1', '›', '檢查軟件更新', '最新版本：等待獲取', '›', '界面設置', '顏色設置', '春風綠', '›', '設置深淺色', '白天模式', '▯', '☼', '◕', '簡化日程時間軸', '沒有日程時 減少空間佔用', '低電量卡片變色提醒', '電量小於閾值時 電量卡片變色提醒', '低電量閾值', '目前為 15 度', '›', '校園信息', '睿思論壇', '其他功能', '豬圖鑑賞', '設置']
- Key 标识: ['settingsThemeSystem', 'settingsThemeLight', 'settingsThemeDark', 'settingsTimelineToggle', 'settingsLowElectricityToggle', 'navTo_home', 'navTo_ruisi', 'navTo_toolbox', 'navTo_pig', 'navTo_settings']

## 视觉审美分析数据

### 屏幕信息
- 屏幕尺寸: 1320×2719 px
- 屏幕利用率（估算）: 100.0%

### 可点击控件尺寸
- OK all clickable controls size >= 48px
- 尺寸列表: [('Row()', 1202, 287), ('Row()', 1202, 287), ('Row()', 1202, 287), ('Text(▯)', 133, 133), ('Text(☼)', 133, 133), ('Text(◕)', 133, 133), ('Toggle(settingsTimelineToggle)', 196, 119), ('Toggle(settingsLowElectricityToggle)', 196, 119), ('Row()', 1202, 238), ('Column(navTo_home)', 259, 273), ('Column(navTo_ruisi)', 259, 273), ('Column(navTo_toolbox)', 259, 273), ('Column(navTo_pig)', 259, 273), ('Column(navTo_settings)', 259, 273)]

### 文本控件尺寸
- OK all text controls height >= 20px
- 文本控件高度分布: [49, 57, 66, 123, 133]

### 间距分析
- 同级元素垂直间距: 最小=0px, 最大=28px, 平均=7.0px
- ⚠️ 间距不一致: 存在 0px 间距与 28px 间距并存

### 控件尺寸分布
- 宽度范围: 34–1320px, 中位数=442px
- 高度范围: 4–2719px, 中位数=133px