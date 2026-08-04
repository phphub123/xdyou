# UI 控件树摘要

**应用**: `io.github.benderblog.traintime_pda.harmonyos`

- root 1320×2719
  - Column 1320×2621
    - Column 1320×2355
      - Column 1320×2355
        - Row 1320×202
          - Text 1053×90 text="校园信息查询"
          - Text 169×127 text="编辑" key="homeEditLayout" [clickable]
        - Text 1320×111 text="Mock UI 预览：未登录，页面数据不代表真实账号。" key="mockPreviewBanner"
        - Scroll 1320×2042
          - Column 1320×2042
            - Column 1250×303 key="homeNoticeCard"
              - Row 1250×134
                - Text 1053×57 text="应用信息"
                - Text 85×49 text="刷新"
              - Text 1250×169 text="目前没有获取应用公告，请刷新"
            - Column 1250×312 key="homeScheduleCard" [clickable]
              - Row 1250×134
                - Text 969×57 text="课程表"
                - Text 169×49 text="暂无日程"
              - Row 1250×178
                - Text 957×66 text="今日课程与日程"
                - Text 181×53 text="第 1 周  ›"
            - Row 1250×287 [clickable]
              - Text 147×111 text="⚡"
              - Column 984×136
                - Text 357×70 text="正在获取信息"
                - Text 463×49 text="查看宿舍电量与用水记录"
              - Text 28×98 text="›"
            - Row 1250×287 [clickable]
              - Text 147×137 text="▤"
              - Column 984×136
                - Text 357×70 text="正在查询信息"
                - Text 463×49 text="查看借阅到期时间与馆藏"
              - Text 28×98 text="›"
            - Row 1250×322
              - Column 293×322 [clickable]
                - Text 89×82 text="A+"
                - Text 155×45 text="成绩查询"
              - Column 293×322 [clickable]
                - Text 70×82 text="日"
                - Text 155×45 text="考试安排"
              - Column 293×322 [clickable]
                - Text 70×82 text="室"
                - Text 155×45 text="空闲教室"
              - Column 293×322 [clickable]
                - Text 70×82 text="签"
                - Text 155×45 text="考勤查询"
            - Row 1250×322
              - Column 293×322 [clickable]
                - Text 90×82 text="Wi"
                - Text 116×45 text="校园网"
              - Column 293×322 [clickable]
                - Text 70×82 text="水"
                - Text 155×45 text="宿舍水机"
              - Column 293×322 [clickable]
                - Text 70×82 text="实"
                - Text 155×45 text="实验信息"
              - Column 293×322 [clickable]
                - Text 70×82 text="体"
                - Text 155×45 text="体育信息"
            - Blank 1250×13
    - Row 1320×266
      - Column 257×238 key="navTo_home" [clickable]
        - Text 196×112 text="◉"
        - Text 155×45 text="校园信息"
      - Column 257×238 key="navTo_ruisi" [clickable]
        - Text 196×112 text="▣"
        - Text 155×45 text="睿思论坛"
      - Column 258×238 key="navTo_toolbox" [clickable]
        - Text 196×112 text="⚒"
        - Text 116×45 text="工具箱"
      - Column 257×238 key="navTo_pig" [clickable]
        - Text 196×112 text="♥"
        - Text 155×45 text="猪图鉴赏"
      - Column 257×238 key="navTo_settings" [clickable]
        - Text 196×112 text="●"
        - Text 78×45 text="设置"

## 统计
- 控件总数: 77
- 可点击: 17
- 可滚动: 1
- 最大嵌套深度: 8
- 控件类型分布:
  - Text: 44
  - Column: 21
  - Row: 9
  - root: 1
  - Scroll: 1
  - Blank: 1
- 文本内容: ['校园信息查询', '编辑', 'Mock UI 预览：未登录，页面数据不代表真实账号。', '应用信息', '刷新', '目前没有获取应用公告，请刷新', '课程表', '暂无日程', '今日课程与日程', '第 1 周  ›', '⚡', '正在获取信息', '查看宿舍电量与用水记录', '›', '▤', '正在查询信息', '查看借阅到期时间与馆藏', '›', 'A+', '成绩查询', '日', '考试安排', '室', '空闲教室', '签', '考勤查询', 'Wi', '校园网', '水', '宿舍水机', '实', '实验信息', '体', '体育信息', '◉', '校园信息', '▣', '睿思论坛', '⚒', '工具箱', '♥', '猪图鉴赏', '●', '设置']
- Key 标识: ['homeEditLayout', 'mockPreviewBanner', 'homeNoticeCard', 'homeScheduleCard', 'navTo_home', 'navTo_ruisi', 'navTo_toolbox', 'navTo_pig', 'navTo_settings']

## 视觉审美分析数据

### 屏幕信息
- 屏幕尺寸: 1320×2719 px
- 屏幕利用率（估算）: 100.0%

### 可点击控件尺寸
- OK all clickable controls size >= 48px
- 尺寸列表: [('Text(编辑)', 169, 127), ('Column(homeScheduleCard)', 1250, 312), ('Row()', 1250, 287), ('Row()', 1250, 287), ('Column()', 293, 322), ('Column()', 293, 322), ('Column()', 293, 322), ('Column()', 293, 322), ('Column()', 293, 322), ('Column()', 293, 322), ('Column()', 293, 322), ('Column()', 293, 322), ('Column(navTo_home)', 257, 238), ('Column(navTo_ruisi)', 257, 238), ('Column(navTo_toolbox)', 258, 238), ('Column(navTo_pig)', 257, 238), ('Column(navTo_settings)', 257, 238)]

### 文本控件尺寸
- OK all text controls height >= 20px
- 文本控件高度分布: [45, 49, 53, 57, 66, 70, 82, 90, 98, 111, 112, 127, 137, 169]

### 间距分析
- 同级元素垂直间距: 最小=0px, 最大=35px, 平均=17.7px
- ⚠️ 间距不一致: 存在 0px 间距与 35px 间距并存

### 控件尺寸分布
- 宽度范围: 28–1320px, 中位数=258px
- 高度范围: 13–2719px, 中位数=112px