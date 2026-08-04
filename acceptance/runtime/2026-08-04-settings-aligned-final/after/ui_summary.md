# UI 控件树摘要

**应用**: `io.github.benderblog.traintime_pda.harmonyos`

- root 1320×2719
  - Column 1320×2621
    - Column 1320×2313
      - Column 1320×2313
        - Scroll 1320×2313
          - Column 1320×2313
            - Column 1202×1222
              - Column 1202×1222
                - Column 1202×22
                  - Row 1202×18 [clickable]
                  - Divider 1104×4
                - Column 1202×291
                  - Row 1202×287 [clickable]
                    - Column 972×66
                      - Text 560×66 text="清除所有用户添加课程"
                    - Text 34×123 text="›"
                  - Divider 1104×4
                - Column 1202×291
                  - Row 1202×287 [clickable]
                    - Column 972×66
                      - Text 336×66 text="强制刷新课表"
                    - Text 34×123 text="›"
                  - Divider 1104×4
                - Column 1202×333
                  - Row 1202×329 [clickable]
                    - Column 972×190
                      - Text 336×66 text="课程偏移设置"
                      - Text 798×114 text="正数错后开学日期 负数提前开学日期
目前为 0"
                    - Text 34×123 text="›"
                  - Divider 1104×4
                - Column 1202×287
                  - Row 1202×287 [clickable]
                    - Column 972×133
                      - Text 224×66 text="修改学期"
                      - Text 197×57 text="使用学期"
                    - Text 34×123 text="›"
            - Column 1202×1022
              - Row 1202×154
                - Text 336×66 text="缓存登录设置"
              - Column 1202×868
                - Column 1202×291
                  - Row 1202×287 [clickable]
                    - Column 972×66
                      - Text 560×66 text="查看网络拦截器和日志"
                    - Text 34×123 text="›"
                  - Divider 1104×4
                - Column 1202×291
                  - Row 1202×287 [clickable]
                    - Column 972×66
                      - Text 392×66 text="清除缓存后重启"
                    - Text 34×123 text="›"
                  - Divider 1104×4
                - Column 1202×287
                  - Row 1202×287 [clickable]
                    - Column 972×133
                      - Text 504×66 text="退出登录并重启应用"
                      - Text 183×57 text="Mock UI"
                    - Text 34×123 text="›"
            - Blank 1202×42
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
- 控件总数: 80
- 可点击: 13
- 可滚动: 1
- 最大嵌套深度: 11
- 控件类型分布:
  - Column: 28
  - Text: 23
  - Row: 15
  - Divider: 6
  - Image: 5
  - root: 1
  - Scroll: 1
  - Blank: 1
- 文本内容: ['清除所有用户添加课程', '›', '强制刷新课表', '›', '课程偏移设置', '正数错后开学日期 负数提前开学日期\n目前为 0', '›', '修改学期', '使用学期', '›', '缓存登录设置', '查看网络拦截器和日志', '›', '清除缓存后重启', '›', '退出登录并重启应用', 'Mock UI', '›', '校園信息', '睿思論壇', '其他功能', '豬圖鑑賞', '設置']
- Key 标识: ['navTo_home', 'navTo_ruisi', 'navTo_toolbox', 'navTo_pig', 'navTo_settings']

## 视觉审美分析数据

### 屏幕信息
- 屏幕尺寸: 1320×2719 px
- 屏幕利用率（估算）: 100.0%

### 可点击控件尺寸
- ⚠️ 触控区域过小（<48px）: ['Row() 1202×18']
- 尺寸列表: [('Row()', 1202, 18), ('Row()', 1202, 287), ('Row()', 1202, 287), ('Row()', 1202, 329), ('Row()', 1202, 287), ('Row()', 1202, 287), ('Row()', 1202, 287), ('Row()', 1202, 287), ('Column(navTo_home)', 259, 273), ('Column(navTo_ruisi)', 259, 273), ('Column(navTo_toolbox)', 259, 273), ('Column(navTo_pig)', 259, 273), ('Column(navTo_settings)', 259, 273)]

### 文本控件尺寸
- OK all text controls height >= 20px
- 文本控件高度分布: [49, 57, 66, 114, 123]

### 间距分析
- 同级元素垂直间距: 最小=0px, 最大=27px, 平均=6.0px
- ⚠️ 间距不一致: 存在 0px 间距与 27px 间距并存

### 控件尺寸分布
- 宽度范围: 34–1320px, 中位数=972px
- 高度范围: 4–2719px, 中位数=123px