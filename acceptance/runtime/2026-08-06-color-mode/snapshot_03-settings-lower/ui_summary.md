# UI 控件树摘要

**应用**: `io.github.benderblog.traintime_pda.harmonyos`

- root 1320×2719
  - Column 1320×2621
    - Column 1320×2313
      - Column 1320×2313
        - Scroll 1320×2313
          - Column 1320×2313
            - Column 1202×264
              - Column 1202×264
                - Column 1202×264
                  - Row 1202×264 [clickable]
                    - Column 972×133
                      - Text 392×66 text="空調用電數據源"
                      - Text 687×57 text="未設置，電費頁不顯示空調用電"
                    - Text 34×123 text="›"
            - Column 1202×1936
              - Row 1202×154
                - Text 336×66 text="課表相關設置"
              - Column 1202×1782
                - Column 1202×291
                  - Row 1202×287
                    - Column 838×66
                      - Text 392×66 text="開啟課表背景圖"
                    - Toggle 196×119 key="settingsBackgroundToggle" [clickable]
                  - Divider 1104×4
                - Column 1202×291
                  - Row 1202×287 [clickable]
                    - Column 972×66
                      - Text 392×66 text="課表背景圖選擇"
                    - Text 34×123 text="›"
                  - Divider 1104×4
                - Column 1202×291
                  - Row 1202×287 [clickable]
                    - Column 972×66
                      - Text 560×66 text="清除所有用戶添加課程"
                    - Text 34×123 text="›"
                  - Divider 1104×4
                - Column 1202×291
                  - Row 1202×287 [clickable]
                    - Column 972×66
                      - Text 336×66 text="強制刷新課表"
                    - Text 34×123 text="›"
                  - Divider 1104×4
                - Column 1202×333
                  - Row 1202×329 [clickable]
                    - Column 972×190
                      - Text 336×66 text="課程偏移設置"
                      - Text 798×114 text="正數錯後開學日期 負數提前開學日期
目前為 0"
                    - Text 34×123 text="›"
                  - Divider 1104×4
                - Column 1202×287
                  - Row 1202×287 [clickable]
                    - Column 972×133
                      - Text 224×66 text="修改學期"
                      - Text 197×57 text="使用學期"
                    - Text 34×123 text="›"
            - Column 1202×58
              - Row 1202×58
                - Text 336×14 text="緩存登錄設置"
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
- 控件总数: 79
- 可点击: 12
- 可滚动: 1
- 最大嵌套深度: 11
- 控件类型分布:
  - Column: 28
  - Text: 23
  - Row: 15
  - Divider: 5
  - Image: 5
  - root: 1
  - Scroll: 1
  - Toggle: 1
- 文本内容: ['空調用電數據源', '未設置，電費頁不顯示空調用電', '›', '課表相關設置', '開啟課表背景圖', '課表背景圖選擇', '›', '清除所有用戶添加課程', '›', '強制刷新課表', '›', '課程偏移設置', '正數錯後開學日期 負數提前開學日期\n目前為 0', '›', '修改學期', '使用學期', '›', '緩存登錄設置', '校園信息', '睿思論壇', '其他功能', '豬圖鑑賞', '設置']
- Key 标识: ['settingsBackgroundToggle', 'navTo_home', 'navTo_ruisi', 'navTo_toolbox', 'navTo_pig', 'navTo_settings']

## 视觉审美分析数据

### 屏幕信息
- 屏幕尺寸: 1320×2719 px
- 屏幕利用率（估算）: 100.0%

### 可点击控件尺寸
- OK all clickable controls size >= 48px
- 尺寸列表: [('Row()', 1202, 264), ('Toggle(settingsBackgroundToggle)', 196, 119), ('Row()', 1202, 287), ('Row()', 1202, 287), ('Row()', 1202, 287), ('Row()', 1202, 329), ('Row()', 1202, 287), ('Column(navTo_home)', 259, 273), ('Column(navTo_ruisi)', 259, 273), ('Column(navTo_toolbox)', 259, 273), ('Column(navTo_pig)', 259, 273), ('Column(navTo_settings)', 259, 273)]

### 文本控件尺寸
- ⚠️ 高度过小的文本控件（h<20px，可能字体过小）: ['"緩存登錄設置" h=14']
- 文本控件高度分布: [14, 49, 57, 66, 114, 123]

### 间距分析
- 同级元素垂直间距: 最小=0px, 最大=28px, 平均=7.8px
- ⚠️ 间距不一致: 存在 0px 间距与 28px 间距并存

### 控件尺寸分布
- 宽度范围: 34–1320px, 中位数=838px
- 高度范围: 4–2719px, 中位数=123px