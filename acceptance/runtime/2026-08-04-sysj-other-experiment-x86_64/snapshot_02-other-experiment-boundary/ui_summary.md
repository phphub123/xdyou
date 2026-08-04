# UI 控件树摘要

**应用**: `io.github.benderblog.traintime_pda.harmonyos`

- root 1320×2719
  - Column 1320×2621
    - Column 1320×2313
      - Column 1320×2313
        - Row 1194×140
          - Button 154×140 text="‹" key="experimentBack" [clickable]
          - Text 788×98 text="实验信息"
          - Button 224×140 text="刷新" key="experimentRefresh" [clickable]
        - Text 928×49 text="其他实验需要真实 IDS 会话，请先完成正式登录。" key="experimentStatus"
        - Row 1194×133
          - Button 597×133 text="物理实验" key="experimentPhysicsTab" [clickable]
          - Button 569×133 text="其他实验" key="experimentOtherTab" [clickable]
        - Row 1194×119
          - Button 398×119 text="进行中" key="experimentDoingTab" [clickable]
          - Button 377×119 text="未完成" key="experimentUpcomingTab" [clickable]
          - Button 377×119 text="已完成" key="experimentFinishedTab" [clickable]
        - Scroll 1194×1625
          - Column 1194×253
            - Text 1194×106 text="其他实验需要真实 IDS 会话和校园网；点击刷新会执行真实 OAuth 与 25 周课表请求。" key="experimentOtherBlocked"
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
- 可点击: 12
- 可滚动: 0
- 最大嵌套深度: 6
- 控件类型分布:
  - Column: 9
  - Row: 9
  - Text: 8
  - Button: 7
  - Image: 5
  - root: 1
  - Scroll: 1
  - Blank: 1
- 文本内容: ['‹', '实验信息', '刷新', '其他实验需要真实 IDS 会话，请先完成正式登录。', '物理实验', '其他实验', '进行中', '未完成', '已完成', '其他实验需要真实 IDS 会话和校园网；点击刷新会执行真实 OAuth 与 25 周课表请求。', '校園信息', '睿思論壇', '其他功能', '豬圖鑑賞', '設置']
- Key 标识: ['experimentBack', 'experimentRefresh', 'experimentStatus', 'experimentPhysicsTab', 'experimentOtherTab', 'experimentDoingTab', 'experimentUpcomingTab', 'experimentFinishedTab', 'experimentOtherBlocked', 'navTo_home', 'navTo_ruisi', 'navTo_toolbox', 'navTo_pig', 'navTo_settings']

## 视觉审美分析数据

### 屏幕信息
- 屏幕尺寸: 1320×2719 px
- 屏幕利用率（估算）: 100.0%

### 可点击控件尺寸
- OK all clickable controls size >= 48px
- 尺寸列表: [('Button(‹)', 154, 140), ('Button(刷新)', 224, 140), ('Button(物理实验)', 597, 133), ('Button(其他实验)', 569, 133), ('Button(进行中)', 398, 119), ('Button(未完成)', 377, 119), ('Button(已完成)', 377, 119), ('Column(navTo_home)', 259, 273), ('Column(navTo_ruisi)', 259, 273), ('Column(navTo_toolbox)', 259, 273), ('Column(navTo_pig)', 259, 273), ('Column(navTo_settings)', 259, 273)]

### 文本控件尺寸
- OK all text controls height >= 20px
- 文本控件高度分布: [49, 98, 106, 119, 133, 140]

### 间距分析
- 同级元素垂直间距: 最小=0px, 最大=42px, 平均=17.5px
- ⚠️ 间距不一致: 存在 0px 间距与 42px 间距并存

### 控件尺寸分布
- 宽度范围: 85–1320px, 中位数=259px
- 高度范围: 49–2719px, 中位数=119px