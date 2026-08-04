# UI 控件树摘要

**应用**: `io.github.benderblog.traintime_pda.harmonyos`

- root 1320×2719
  - Column 1320×2621
    - Column 1320×2313
      - Column 1320×2313
        - Row 1320×202
          - Text 1107×90 text="校園信息查詢"
          - Image 84×84 key="homeEditLayout" [clickable]
        - Scroll 1320×2111
          - Column 1320×2111
            - Column 1208×140 key="mockPreviewBanner"
              - Text 491×57 text="目前您正在運行測試版"
            - Column 1208×518 key="homeScheduleCard"
              - Row 1202×168
                - Text 315×105 text="部分加載中"
                - Text 441×105 text="其他實驗加載失敗"
              - Row 1202×193 [clickable]
                - Image 105×105
                - Column 989×138
                  - Text 420×82 text="今日安排完成"
                  - Text 183×53 text="正在加載"
              - Text 1202×119 text="正在加載日程"
            - Row 1208×238 key="homeDormWaterInfo" [clickable]
              - Image 105×105
              - Column 940×141
                - Text 399×78 text="電量查詢失敗"
                - Text 365×53 text="欠費查詢網絡故障"
            - Row 1208×238 key="homeLibraryInfo" [clickable]
              - Image 105×105
              - Column 940×141
                - Text 274×78 text="借書 1 本"
                - Text 324×53 text="待歸還 1 本書籍"
            - Row 1208×238 key="homeSchoolCard" [clickable]
              - Image 105×105
              - Column 800×141
                - Text 200×78 text="未登錄"
                - Text 501×53 text="查看餘額、流水與付款碼"
              - Row 140×140
                - Image 67×67
            - Row 1208×273
              - Column 282×273 [clickable]
                - Image 102×102
                - Text 169×49 text="成績查詢"
              - Column 282×273 [clickable]
                - Image 102×102
                - Text 169×49 text="考試安排"
              - Column 282×273 [clickable]
                - Image 102×102
                - Text 169×49 text="空閒教室"
              - Column 282×273 [clickable]
                - Image 102×102
                - Text 169×49 text="考勤查詢"
            - Row 1208×253
              - Column 282×253 [clickable]
                - Image 102×102
                - Text 169×49 text="網絡查詢"
              - Column 282×253 [clickable]
                - Image 102×102
                - Text 169×49 text="宿舍水機"
              - Column 282×253 [clickable]
                - Image 102×102
                - Text 169×49 text="實驗信息"
              - Column 282×253 [clickable]
                - Image 102×102
                - Text 169×49 text="體育信息"
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
- 控件总数: 85
- 可点击: 18
- 可滚动: 1
- 最大嵌套深度: 9
- 控件类型分布:
  - Text: 26
  - Column: 23
  - Image: 19
  - Row: 15
  - root: 1
  - Scroll: 1
- 文本内容: ['校園信息查詢', '目前您正在運行測試版', '部分加載中', '其他實驗加載失敗', '今日安排完成', '正在加載', '正在加載日程', '電量查詢失敗', '欠費查詢網絡故障', '借書 1 本', '待歸還 1 本書籍', '未登錄', '查看餘額、流水與付款碼', '成績查詢', '考試安排', '空閒教室', '考勤查詢', '網絡查詢', '宿舍水機', '實驗信息', '體育信息', '校園信息', '睿思論壇', '其他功能', '豬圖鑑賞', '設置']
- Key 标识: ['homeEditLayout', 'mockPreviewBanner', 'homeScheduleCard', 'homeDormWaterInfo', 'homeLibraryInfo', 'homeSchoolCard', 'navTo_home', 'navTo_ruisi', 'navTo_toolbox', 'navTo_pig', 'navTo_settings']

## 视觉审美分析数据

### 屏幕信息
- 屏幕尺寸: 1320×2719 px
- 屏幕利用率（估算）: 100.0%

### 可点击控件尺寸
- OK all clickable controls size >= 48px
- 尺寸列表: [('Image(homeEditLayout)', 84, 84), ('Row()', 1202, 193), ('Row(homeDormWaterInfo)', 1208, 238), ('Row(homeLibraryInfo)', 1208, 238), ('Row(homeSchoolCard)', 1208, 238), ('Column()', 282, 273), ('Column()', 282, 273), ('Column()', 282, 273), ('Column()', 282, 273), ('Column()', 282, 253), ('Column()', 282, 253), ('Column()', 282, 253), ('Column()', 282, 253), ('Column(navTo_home)', 259, 273), ('Column(navTo_ruisi)', 259, 273), ('Column(navTo_toolbox)', 259, 273), ('Column(navTo_pig)', 259, 273), ('Column(navTo_settings)', 259, 273)]

### 文本控件尺寸
- OK all text controls height >= 20px
- 文本控件高度分布: [49, 53, 57, 78, 82, 90, 105, 119]

### 间距分析
- 同级元素垂直间距: 最小=0px, 最大=35px, 平均=16.2px
- ⚠️ 间距不一致: 存在 0px 间距与 35px 间距并存

### 控件尺寸分布
- 宽度范围: 67–1320px, 中位数=259px
- 高度范围: 49–2719px, 中位数=105px