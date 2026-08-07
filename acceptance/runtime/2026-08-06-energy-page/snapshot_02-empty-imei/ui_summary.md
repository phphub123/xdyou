# UI 控件树摘要

**应用**: `io.github.benderblog.traintime_pda.harmonyos`

- root 1320×2719
  - Column 1320×2621
    - Column 1320×2313
      - Column 1320×2313
        - Row 1194×140
          - Button 154×140 text="‹" key="energyBack" [clickable]
          - Text 788×98 text="电量与能耗"
          - Button 224×140 text="查询" key="energyRefresh" [clickable]
        - Text 527×49 text="空调设备 IMEI 格式不正确。" key="energyStatus"
        - Scroll 1194×1971
          - Column 1194×1069
            - Column 1194×306 key="energyCampusBoundary"
              - Text 441×74 text="宿舍电费与水费"
              - Text 1051×106 text="该查询仅在校园网和真实 IDS 会话可用；未满足条件时会保留真实错误，不显示演示余额。"
            - Column 1194×609 key="energyAirconCard"
              - Text 252×74 text="空调能耗"
              - TextInput 1096×147 hint="输入空调设备 IMEI" key="energyImeiInput" [clickable]
              - Button 1096×140 text="使用 IMEI 查询" key="energyAirconQuery" [clickable]
              - Text 977×49 text="尚未查询空调设备；IMEI 不会被持久化或写入日志。" key="energyAirconEmpty"
            - Blank 1194×70
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
- 可点击: 9
- 可滚动: 1
- 最大嵌套深度: 7
- 控件类型分布:
  - Column: 11
  - Text: 11
  - Row: 7
  - Image: 5
  - Button: 3
  - root: 1
  - Scroll: 1
  - TextInput: 1
  - Blank: 1
- 文本内容: ['‹', '电量与能耗', '查询', '空调设备 IMEI 格式不正确。', '宿舍电费与水费', '该查询仅在校园网和真实 IDS 会话可用；未满足条件时会保留真实错误，不显示演示余额。', '空调能耗', '使用 IMEI 查询', '尚未查询空调设备；IMEI 不会被持久化或写入日志。', '校園信息', '睿思論壇', '其他功能', '豬圖鑑賞', '設置']
- Hint 提示: ['输入空调设备 IMEI']
- Key 标识: ['energyBack', 'energyRefresh', 'energyStatus', 'energyCampusBoundary', 'energyAirconCard', 'energyImeiInput', 'energyAirconQuery', 'energyAirconEmpty', 'navTo_home', 'navTo_ruisi', 'navTo_toolbox', 'navTo_pig', 'navTo_settings']

## 视觉审美分析数据

### 屏幕信息
- 屏幕尺寸: 1320×2719 px
- 屏幕利用率（估算）: 100.0%

### 可点击控件尺寸
- OK all clickable controls size >= 48px
- 尺寸列表: [('Button(‹)', 154, 140), ('Button(查询)', 224, 140), ('TextInput(energyImeiInput)', 1096, 147), ('Button(使用 IMEI 查询)', 1096, 140), ('Column(navTo_home)', 259, 273), ('Column(navTo_ruisi)', 259, 273), ('Column(navTo_toolbox)', 259, 273), ('Column(navTo_pig)', 259, 273), ('Column(navTo_settings)', 259, 273)]

### 文本控件尺寸
- OK all text controls height >= 20px
- 文本控件高度分布: [49, 74, 98, 106, 140]

### 间距分析
- 同级元素垂直间距: 最小=0px, 最大=35px, 平均=18.7px
- ⚠️ 间距不一致: 存在 0px 间距与 35px 间距并存

### 控件尺寸分布
- 宽度范围: 85–1320px, 中位数=259px
- 高度范围: 49–2719px, 中位数=119px