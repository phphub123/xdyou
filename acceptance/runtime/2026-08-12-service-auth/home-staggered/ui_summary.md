# UI 控件树摘要

**应用**: `io.github.benderblog.traintime_pda.harmonyos`

- Unknown 1320×2856
  - WindowScene 1320×2719 key="session10"
    - EffectComponent 1320×2719 key="SCBDesktop_Image_container"
      - Stack 1320×2719
        - Flex 1320×2719 key="SCBDesktop_Flex_Desktop" [clickable]
          - Column 1320×2341 key="SCBDesktop_Column_PageDesktopLayout"
            - __Common__ 1320×2341
              - Stack 1320×2341 key="GridSwiper_stack_snap"
                - Swiper 1320×2341 key="GridSwiper_Stack_Swiper"
                  - Stack 1320×2341
                    - Stack 1320×2341
                      - Grid 1264×2100 key="SwiperPage_Grid_WorkSpace_1"
                        - GridItem 316×350 key="SwiperPage_GridItem_[com.wemaka.weatherapp___16777217___0,1]"
                          - RelativeContainer 316×350 key="AppIconCommonView_com.wemaka.weatherapp.MainActivity" [clickable]
                            - Image 203×203 key="AppIcon_Image_com.wemaka.weatherappMainActivityentry0_undefined_0" [clickable]
                            - Text 281×50 text="Weather App" key="AppNameLite_text_com.wemaka.weatherapp_msof3mm0h7s5g5zperf"
                        - GridItem 316×350 key="SwiperPage_GridItem_[com.example.cangjienotepad___16777219___0,1]"
                          - RelativeContainer 316×350 key="AppIconCommonView_com.example.cangjienotepad.EntryAbility" [clickable]
                            - Image 203×203 key="AppIcon_Image_com.example.cangjienotepadEntryAbilityentry0_undefined_0" [clickable]
                            - Text 316×50 text="Cangjie Notepad" key="AppNameLite_text_com.example.cangjienotepad_msof3mmwhtfz8bi3rzf"
                        - GridItem 316×350 key="SwiperPage_GridItem_[com.example.myapplication___16777219___0,1]"
                          - RelativeContainer 316×350 key="AppIconCommonView_com.example.myapplication.EntryAbility" [clickable]
                            - Image 203×203 key="AppIcon_Image_com.example.myapplicationEntryAbilityentry0_undefined_0" [clickable]
                            - Text 120×50 text="label" key="AppNameLite_text_com.example.myapplication_msof3mnoghy3guw06wp"
                        - GridItem 316×350 key="SwiperPage_GridItem_[io.github.benderblog.traintime_pda.harmonyos___16777219___0,1]"
                          - RelativeContainer 316×350 key="AppIconCommonView_io.github.benderblog.traintime_pda.harmonyos.EntryAbility" [clickable]
                            - Image 203×203 key="AppIcon_Image_io.github.benderblog.traintime_pda.harmonyosEntryAbilityentry0_undefined_0" [clickable]
                            - Text 171×50 text="XDYOU" key="AppNameLite_text_io.github.benderblog.traintime_pda.harmonyos_msof3monncpl69kzong"
                - __Common__ 140×28
                  - Stack 140×28 key="SwiperIndicator_indicator"
                    - Row 140×28
                      - Image 21×28 key="SwiperIndicator_ic_negative_screen_indicator"
                      - Stack 21×21
                      - Stack 21×21
                    - Stack 42×22
          - Column 1320×378 key="SCBDesktop_Column_smartDock"
            - Row 1320×378
              - Stack 1320×287 key="ResidentLayout"
                - Column 203×203 key="SmartDock_V_ResidentLayout_Rect_placeholder"
                - List 1320×287
                  - ListItem 203×203 key="ResidentLayout_AppItem_com.ohos.contacts_Wrap"
                    - ListItem 203×203 key="ResidentLayout_AppItem_com.ohos.contacts"
                      - RelativeContainer 203×203 key="AppIconCommonView_com.ohos.contacts.com.ohos.contacts.MainAbility" [clickable]
                        - Image 203×203 key="AppIcon_Image_com.ohos.contactscom.ohos.contacts.MainAbilityentry0_undefined_1" [clickable]
                  - ListItem 203×203 key="ResidentLayout_AppItem_com.huawei.hmos.browser_Wrap"
                    - ListItem 203×203 key="ResidentLayout_AppItem_com.huawei.hmos.browser"
                      - RelativeContainer 203×203 key="AppIconCommonView_com.huawei.hmos.browser.MainAbility" [clickable]
                        - Image 203×203 key="AppIcon_Image_com.huawei.hmos.browserMainAbilityentry0_undefined_1" [clickable]
        - Column 1×1
  - WindowScene 1320×136 key="session21"
    - __Common__ 1320×136 key="StatusBarBox"
      - Stack 1320×136
        - __Common__ 1320×136 key="StatusBarBridgeView" [clickable]
          - Stack 1320×136
            - Row 1222×81 key="status_bar_color_picker"
            - Stack 1320×136 key="StatusBarView"
              - Row 1320×136 key="StatusBarBackground_Row_0"
              - Stack 1271×81 key="sbg_left"
                - RelativeContainer 1271×81
                  - Stack 139×81 key="StatusBarIconWrapper_status_bar_clock"
                    - Row 139×81
                      - Flex 139×81 text="10, :, 41" key="ClockStatusView"
                        - Row 77×62
                          - TextClock 62×62 key="TimeView_Text_timeText"
                            - Text 62×62 text="10"
                          - Text 15×53 text=":" key="TimeView_Text_timeText"
                        - TextClock 62×62 key="TimeView_Text_timeText"
                          - Text 62×62 text="41"
              - RelativeContainer 1271×81 key="sbg_right"
                - Stack 84×81 key="StatusBarIconWrapper_status_bar_ethernet"
                  - Row 77×81
                    - SymbolGlyph 77×56 key="StatusBarIconItemEthernetComponent_Image_icon"
                - Stack 75×81 key="StatusBarIconWrapper_status_bar_wifi"
                  - Stack 68×81
                    - SymbolGlyph 68×56 key="WifiComponent-WifiIcon_Image_wifi_signal_level"
                    - SymbolGlyph 68×56 key="WifiComponent-WifiIcon_Image_wifi_data_flow"
                - Stack 87×81 key="StatusBarIconWrapper_status_bar_signal"
                  - Row 80×81
                    - Stack 80×56
                      - SymbolGlyph 80×56 key="SignalComponent-SignalIcon_Image_cellular"
                      - SymbolGlyph 80×56 key="SignalComponent-SignalIcon_Image_cellularImage"
                - Stack 105×81 key="StatusBarIconWrapper_status_bar_battery"
                  - Row 98×81 key="BatteryComponent-batteryIcon_Image_batteryIcon"
                    - Stack 98×56
                      - Stack 98×56
                        - SymbolGlyph 98×56 key="BatteryComponent-batteryIcon_Image_batteryBorder"
                        - Text 70×45 text="100" key="BatteryComponent-batteryIcon_Text_batterySoc"
                        - Text 70×45 text="100" key="BatteryComponent-batteryIcon_Text_batterySoc"
            - Stack 280×88 key="StatusBarView_LiveCapsuleListContainer"
              - Stack 280×88 key="[Live]LiveCapsuleListView"
                - metaballNode 560×117 key="LiveMetaBallBaseVm" [clickable]

## 统计
- 控件总数: 91
- 可点击: 15
- 可滚动: 1
- 最大嵌套深度: 14
- 控件类型分布:
  - Stack: 24
  - Text: 9
  - Row: 9
  - RelativeContainer: 8
  - Image: 7
  - SymbolGlyph: 6
  - Column: 4
  - __Common__: 4
  - GridItem: 4
  - ListItem: 4
  - WindowScene: 2
  - Flex: 2
  - TextClock: 2
  - Unknown: 1
  - EffectComponent: 1
  - Swiper: 1
  - Grid: 1
  - List: 1
  - metaballNode: 1
- 文本内容: ['Weather App', 'Cangjie Notepad', 'label', 'XDYOU', '10, :, 41', '10', ':', '41', '100', '100']
- Key 标识: ['session10', 'SCBDesktop_Image_container', 'SCBDesktop_Flex_Desktop', 'SCBDesktop_Column_PageDesktopLayout', 'GridSwiper_stack_snap', 'GridSwiper_Stack_Swiper', 'SwiperPage_Grid_WorkSpace_1', 'SwiperPage_GridItem_[com.wemaka.weatherapp___16777217___0,1]', 'AppIconCommonView_com.wemaka.weatherapp.MainActivity', 'AppIcon_Image_com.wemaka.weatherappMainActivityentry0_undefined_0', 'AppNameLite_text_com.wemaka.weatherapp_msof3mm0h7s5g5zperf', 'SwiperPage_GridItem_[com.example.cangjienotepad___16777219___0,1]', 'AppIconCommonView_com.example.cangjienotepad.EntryAbility', 'AppIcon_Image_com.example.cangjienotepadEntryAbilityentry0_undefined_0', 'AppNameLite_text_com.example.cangjienotepad_msof3mmwhtfz8bi3rzf', 'SwiperPage_GridItem_[com.example.myapplication___16777219___0,1]', 'AppIconCommonView_com.example.myapplication.EntryAbility', 'AppIcon_Image_com.example.myapplicationEntryAbilityentry0_undefined_0', 'AppNameLite_text_com.example.myapplication_msof3mnoghy3guw06wp', 'SwiperPage_GridItem_[io.github.benderblog.traintime_pda.harmonyos___16777219___0,1]', 'AppIconCommonView_io.github.benderblog.traintime_pda.harmonyos.EntryAbility', 'AppIcon_Image_io.github.benderblog.traintime_pda.harmonyosEntryAbilityentry0_undefined_0', 'AppNameLite_text_io.github.benderblog.traintime_pda.harmonyos_msof3monncpl69kzong', 'SwiperIndicator_indicator', 'SwiperIndicator_ic_negative_screen_indicator', 'SCBDesktop_Column_smartDock', 'ResidentLayout', 'SmartDock_V_ResidentLayout_Rect_placeholder', 'ResidentLayout_AppItem_com.ohos.contacts_Wrap', 'ResidentLayout_AppItem_com.ohos.contacts', 'AppIconCommonView_com.ohos.contacts.com.ohos.contacts.MainAbility', 'AppIcon_Image_com.ohos.contactscom.ohos.contacts.MainAbilityentry0_undefined_1', 'ResidentLayout_AppItem_com.huawei.hmos.browser_Wrap', 'ResidentLayout_AppItem_com.huawei.hmos.browser', 'AppIconCommonView_com.huawei.hmos.browser.MainAbility', 'AppIcon_Image_com.huawei.hmos.browserMainAbilityentry0_undefined_1', 'session21', 'StatusBarBox', 'StatusBarBridgeView', 'status_bar_color_picker', 'StatusBarView', 'StatusBarBackground_Row_0', 'sbg_left', 'StatusBarIconWrapper_status_bar_clock', 'ClockStatusView', 'TimeView_Text_timeText', 'TimeView_Text_timeText', 'TimeView_Text_timeText', 'sbg_right', 'StatusBarIconWrapper_status_bar_ethernet', 'StatusBarIconItemEthernetComponent_Image_icon', 'StatusBarIconWrapper_status_bar_wifi', 'WifiComponent-WifiIcon_Image_wifi_signal_level', 'WifiComponent-WifiIcon_Image_wifi_data_flow', 'StatusBarIconWrapper_status_bar_signal', 'SignalComponent-SignalIcon_Image_cellular', 'SignalComponent-SignalIcon_Image_cellularImage', 'StatusBarIconWrapper_status_bar_battery', 'BatteryComponent-batteryIcon_Image_batteryIcon', 'BatteryComponent-batteryIcon_Image_batteryBorder', 'BatteryComponent-batteryIcon_Text_batterySoc', 'BatteryComponent-batteryIcon_Text_batterySoc', 'StatusBarView_LiveCapsuleListContainer', '[Live]LiveCapsuleListView', 'LiveMetaBallBaseVm']

## 视觉审美分析数据

### 屏幕信息
- 屏幕尺寸: 1320×2856 px
- 屏幕利用率（估算）: 100.0%

### 可点击控件尺寸
- OK all clickable controls size >= 48px
- 尺寸列表: [('Flex(SCBDesktop_Flex_Desktop)', 1320, 2719), ('RelativeContainer(AppIconCommonView_com.wemaka.weatherapp.MainActivity)', 316, 350), ('Image(AppIcon_Image_com.wemaka.weatherappMainActivityentry0_undefined_0)', 203, 203), ('RelativeContainer(AppIconCommonView_com.example.cangjienotepad.EntryAbility)', 316, 350), ('Image(AppIcon_Image_com.example.cangjienotepadEntryAbilityentry0_undefined_0)', 203, 203), ('RelativeContainer(AppIconCommonView_com.example.myapplication.EntryAbility)', 316, 350), ('Image(AppIcon_Image_com.example.myapplicationEntryAbilityentry0_undefined_0)', 203, 203), ('RelativeContainer(AppIconCommonView_io.github.benderblog.traintime_pda.harmonyos.EntryAbility)', 316, 350), ('Image(AppIcon_Image_io.github.benderblog.traintime_pda.harmonyosEntryAbilityentry0_undefined_0)', 203, 203), ('RelativeContainer(AppIconCommonView_com.ohos.contacts.com.ohos.contacts.MainAbility)', 203, 203), ('Image(AppIcon_Image_com.ohos.contactscom.ohos.contacts.MainAbilityentry0_undefined_1)', 203, 203), ('RelativeContainer(AppIconCommonView_com.huawei.hmos.browser.MainAbility)', 203, 203), ('Image(AppIcon_Image_com.huawei.hmos.browserMainAbilityentry0_undefined_1)', 203, 203), ('__Common__(StatusBarBridgeView)', 1320, 136), ('metaballNode(LiveMetaBallBaseVm)', 560, 117)]

### 文本控件尺寸
- OK all text controls height >= 20px
- 文本控件高度分布: [45, 50, 53, 62, 81]

### 间距分析
- 同级元素垂直间距: 最小=0px, 最大=12px, 平均=8.2px
- ⚠️ 间距不一致: 存在 0px 间距与 12px 间距并存

### 控件尺寸分布
- 宽度范围: 1–1320px, 中位数=203px
- 高度范围: 1–2856px, 中位数=88px