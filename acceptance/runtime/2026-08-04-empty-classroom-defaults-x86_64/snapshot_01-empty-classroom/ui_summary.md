# UI 控件树摘要

**应用**: `io.github.benderblog.traintime_pda.harmonyos`

- root 1320×2719
  - Column 1320×2621
    - Column 1320×2313
      - Column 1320×2313
        - Text 365×107 text="空闲教室"
        - Row 1194×154
          - TextInput 774×140 hint="教学楼代码" key="emptyClassroomBuildingInput" [clickable]
          - Button 392×140 text="加载教学楼" key="emptyClassroomLoadBuildings" [clickable]
        - Row 1194×154
          - TextInput 597×140 text="2026-08-04" hint="日期 yyyy-MM-dd" key="emptyClassroomDateInput" [clickable]
          - TextInput 569×140 text="2026-1" hint="学期 2026-1" key="emptyClassroomSemesterInput" [clickable]
        - Row 1194×154
          - TextInput 942×140 hint="筛选教室名称" key="emptyClassroomFilterInput" [clickable]
          - Button 224×140 text="查询" key="emptyClassroomSearch" [clickable]
        - Text 1175×98 text="A real IDS/Ehall session is required before academic data can load." key="emptyClassroomStatus"
        - Row 1194×129
          - Text 341×66 text="教室"
          - Text 853×66 text="1  2  3  4  5  6  7  8  9 10 11"
        - Scroll 1194×1266 key="emptyClassroomMatrix"
          - Column 1194×1
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
- 控件总数: 41
- 可点击: 11
- 可滚动: 4
- 最大嵌套深度: 5
- 控件类型分布:
  - Row: 10
  - Column: 9
  - Text: 9
  - Image: 5
  - TextInput: 4
  - Button: 2
  - root: 1
  - Scroll: 1
- 文本内容: ['空闲教室', '加载教学楼', '2026-08-04', '2026-1', '查询', 'A real IDS/Ehall session is required before academic data can load.', '教室', '1  2  3  4  5  6  7  8  9 10 11', '校園信息', '睿思論壇', '其他功能', '豬圖鑑賞', '設置']
- Hint 提示: ['教学楼代码', '日期 yyyy-MM-dd', '学期 2026-1', '筛选教室名称']
- Key 标识: ['emptyClassroomBuildingInput', 'emptyClassroomLoadBuildings', 'emptyClassroomDateInput', 'emptyClassroomSemesterInput', 'emptyClassroomFilterInput', 'emptyClassroomSearch', 'emptyClassroomStatus', 'emptyClassroomMatrix', 'navTo_home', 'navTo_ruisi', 'navTo_toolbox', 'navTo_pig', 'navTo_settings']

## 视觉审美分析数据

### 屏幕信息
- 屏幕尺寸: 1320×2719 px
- 屏幕利用率（估算）: 97.3%

### 可点击控件尺寸
- OK all clickable controls size >= 48px
- 尺寸列表: [('TextInput(emptyClassroomBuildingInput)', 774, 140), ('Button(加载教学楼)', 392, 140), ('TextInput(2026-08-04)', 597, 140), ('TextInput(2026-1)', 569, 140), ('TextInput(emptyClassroomFilterInput)', 942, 140), ('Button(查询)', 224, 140), ('Column(navTo_home)', 259, 273), ('Column(navTo_ruisi)', 259, 273), ('Column(navTo_toolbox)', 259, 273), ('Column(navTo_pig)', 259, 273), ('Column(navTo_settings)', 259, 273)]

### 文本控件尺寸
- OK all text controls height >= 20px
- 文本控件高度分布: [49, 66, 98, 107, 140]

### 间距分析
- 同级元素垂直间距: 最小=0px, 最大=42px, 平均=16.3px
- ⚠️ 间距不一致: 存在 0px 间距与 42px 间距并存

### 控件尺寸分布
- 宽度范围: 85–1320px, 中位数=259px
- 高度范围: 1–2719px, 中位数=129px