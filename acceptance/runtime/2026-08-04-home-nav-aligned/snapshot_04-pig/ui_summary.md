# UI 控件树摘要

**应用**: `io.github.benderblog.traintime_pda.harmonyos`

- root 1320×2719
  - Column 1320×2621
    - Column 1320×2313
      - Column 1320×2313
        - Row 1320×202
          - Text 1077×90 text="猪图鉴赏"
          - Text 152×195 text="↻" key="pigRefresh" [clickable]
        - Scroll 1320×2111
          - Column 1320×1710
            - Text 1128×114 text="本程序将开发一个新主页，目前先用猪图秀占位，玩得愉快"
            - Column 1152×1085 key="pigImageState"
              - Text 420×395 text="🐷"
              - Text 667×53 text="PigHub 图片服务尚未返回内容。"
            - Button 630×140 text="换一只猪" key="pigShuffle" [clickable]
            - Button 630×140 text="保存这只猪" key="pigSave" [clickable]
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
- 控件总数: 36
- 可点击: 8
- 可滚动: 0
- 最大嵌套深度: 7
- 控件类型分布:
  - Column: 10
  - Text: 10
  - Row: 7
  - Image: 5
  - Button: 2
  - root: 1
  - Scroll: 1
- 文本内容: ['猪图鉴赏', '↻', '本程序将开发一个新主页，目前先用猪图秀占位，玩得愉快', '🐷', 'PigHub 图片服务尚未返回内容。', '换一只猪', '保存这只猪', '校園信息', '睿思論壇', '其他功能', '豬圖鑑賞', '設置']
- Key 标识: ['pigRefresh', 'pigImageState', 'pigShuffle', 'pigSave', 'navTo_home', 'navTo_ruisi', 'navTo_toolbox', 'navTo_pig', 'navTo_settings']

## 视觉审美分析数据

### 屏幕信息
- 屏幕尺寸: 1320×2719 px
- 屏幕利用率（估算）: 67.8%

### 可点击控件尺寸
- OK all clickable controls size >= 48px
- 尺寸列表: [('Text(↻)', 152, 195), ('Button(换一只猪)', 630, 140), ('Button(保存这只猪)', 630, 140), ('Column(navTo_home)', 259, 273), ('Column(navTo_ruisi)', 259, 273), ('Column(navTo_toolbox)', 259, 273), ('Column(navTo_pig)', 259, 273), ('Column(navTo_settings)', 259, 273)]

### 文本控件尺寸
- OK all text controls height >= 20px
- 文本控件高度分布: [49, 53, 90, 114, 140, 195, 395]

### 间距分析
- 同级元素垂直间距: 最小=0px, 最大=70px, 平均=25.5px
- ⚠️ 间距不一致: 存在 0px 间距与 70px 间距并存

### 控件尺寸分布
- 宽度范围: 85–1320px, 中位数=259px
- 高度范围: 49–2719px, 中位数=140px