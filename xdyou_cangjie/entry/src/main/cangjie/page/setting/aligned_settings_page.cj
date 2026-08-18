package ohos_app_cangjie_entry.page.setting

// 对齐版设置页，集中管理界面、账户、课表和缓存相关偏好。

import kit.ArkUI.*
import kit.ArkWeb.*
import ohos.arkui.state_macro_manage.*
import ohos.business_exception.*
import ohos.resource.*
import ohos_app_cangjie_entry.repository.*
import ohos_app_cangjie_entry.themes.*

// 设置值由 SessionStore 读写，页面状态只负责当前渲染和交互反馈。
@Component
public class AlignedSettingsPage {
    let account: String
    let onLogout: () -> Unit
    @State var theme: String = "跟隨系統"
    @State var colorName: String = "默認顏色"
    @State var timeline: Bool = false
    @State var lowElectricityWarning: Bool = true
    @State var lowElectricityThreshold: String = "20"
    @State var language: String = "繁體中文"
    @State var semester: String = "使用學期"
    @State var migrationHint: String = ""
    @StorageProp["xdyouThemePreference"]
    let themePreference: String = "System"
    @StorageProp["colorMode"]
    let systemColorMode: ColorMode = ColorMode.Light

    func darkMode(): Bool {
        return AppTheme.isDark(this.themePreference, this.systemColorMode)
    }

    protected override func aboutToAppear(): Unit {
        let store = SessionStore()
        this.theme = match (store.restoreTheme()) {
            case "Light" => "白天模式"
            case "Dark" => "黑夜模式"
            case _ => "跟隨系統"
        }
        let storedColor = store.restoreSetting("color", defaultValue: "默認顏色")
        this.colorName = match (storedColor) {
            case "默认颜色" => "默認顏色"
            case "聪明蓝" => "聰明藍"
            case "春风绿" => "春風綠"
            case _ => storedColor
        }
        this.timeline = store.restoreSetting("timeline", defaultValue: "关闭") == "开启"
        this.lowElectricityWarning = store.restoreSetting("lowElectricityEnabled", defaultValue: "开启") == "开启"
        this.lowElectricityThreshold = store.restoreSetting("lowElectricity", defaultValue: "20")
        this.language = "繁體中文"
        store.saveDisplaySettings("Traditional Chinese", store.restoreTheme())
        this.semester = store.restoreSetting("semester", defaultValue: "使用學期")
    }

    func saveTheme(value: String): Unit {
        this.theme = value
        let stored = if (value == "白天模式") {
            "Light"
        } else if (value == "黑夜模式") {
            "Dark"
        } else {
            "System"
        }
        AppTheme.setPreference(stored, this.storedLanguage())
    }

    func storedLanguage(): String {
        return if (this.language == "繁體中文") {
            "Traditional Chinese"
        } else if (this.language == "English") {
            "English"
        } else {
            "Chinese"
        }
    }

    func toggleTimeline(value: Bool): Unit {
        this.timeline = value
        SessionStore().saveSetting("timeline", if (value) {
            "开启"
        } else {
            "关闭"
        })
    }

    func toggleLowElectricity(value: Bool): Unit {
        this.lowElectricityWarning = value
        SessionStore().saveSetting("lowElectricityEnabled", if (value) {
            "开启"
        } else {
            "关闭"
        })
    }

    func cycleColor(): Unit {
        this.colorName = if (this.colorName == "默認顏色") {
            "聰明藍"
        } else if (this.colorName == "聰明藍") {
            "春風綠"
        } else if (this.colorName == "春風綠") {
            "明日香橙"
        } else {
            "默認顏色"
        }
        SessionStore().saveSetting("color", this.colorName)
    }

    func cycleLanguage(): Unit {
        this.language = if (this.language == "繁體中文") {
            "English"
        } else if (this.language == "English") {
            "簡體中文"
        } else {
            "繁體中文"
        }
        SessionStore().saveDisplaySettings(this.storedLanguage(),
            if (this.theme == "白天模式") {
                "Light"
            } else if (this.theme == "黑夜模式") {
                "Dark"
            } else {
                "System"
            })
    }

    func cycleThreshold(): Unit {
        this.lowElectricityThreshold = if (this.lowElectricityThreshold == "20") {
            "15"
        } else if (this.lowElectricityThreshold == "15") {
            "10"
        } else {
            "20"
        }
        SessionStore().saveSetting("lowElectricity", this.lowElectricityThreshold)
    }

    func unavailable(name: String): Unit {
        this.migrationHint = "${name}功能遷移中"
    }

    func build() {
        Column {
            Scroll {
                Column {
                    AlignedSettingsSectionHeader(title: "關於")
                    Column {
                        AlignedSettingRow(
                            title: "關於本程序",
                            subtitle: "版本號：1.0.0+1",
                            showDivider: true,
                            onTap: {=> this.unavailable("關於本程序")}
                        )
                        AlignedSettingRow(
                            title: "檢查軟件更新",
                            subtitle: "最新版本：等待獲取",
                            showDivider: false,
                            onTap: {=> this.unavailable("軟件更新")}
                        )
                    }
                        .width(100.percent)
                        .backgroundColor(ThemePalette.surface(this.darkMode()))
                        .borderRadius(bottomLeft: 14.vp, bottomRight: 14.vp)

                    Column {
                        AlignedSettingsSectionHeader(title: "界面設置")
                        Column {
                            AlignedSettingRow(title: "顏色設置", subtitle: this.colorName, showDivider: true,
                                onTap: {=> this.cycleColor()})
                            AlignedBrightnessRow(
                                theme: this.theme,
                                onSystem: {=> this.saveTheme("跟隨系統")},
                                onLight: {=> this.saveTheme("白天模式")},
                                onDark: {=> this.saveTheme("黑夜模式")}
                            )
                            AlignedSettingToggleRow(
                                title: "簡化日程時間軸",
                                subtitle: "沒有日程時 減少空間佔用",
                                isOn: this.timeline,
                                showDivider: true,
                                stableId: "settingsTimelineToggle",
                                onChange: {value => this.toggleTimeline(value)}
                            )
                            AlignedSettingToggleRow(
                                title: "低電量卡片變色提醒",
                                subtitle: "電量小於閾值時 電量卡片變色提醒",
                                isOn: this.lowElectricityWarning,
                                showDivider: true,
                                stableId: "settingsLowElectricityToggle",
                                onChange: {value => this.toggleLowElectricity(value)}
                            )
                            AlignedSettingRow(
                                title: "低電量閾值",
                                subtitle: "目前為 ${this.lowElectricityThreshold} 度",
                                showDivider: true,
                                onTap: {=> this.cycleThreshold()}
                            )
                            AlignedSettingRow(title: "修改語言", subtitle: this.language, showDivider: false,
                                onTap: {=> this.cycleLanguage()})
                        }
                            .width(100.percent)
                            .backgroundColor(ThemePalette.surface(this.darkMode()))
                            .borderRadius(bottomLeft: 14.vp, bottomRight: 14.vp)
                    }.width(100.percent).margin(top: 8.vp)

                    Column {
                        AlignedSettingsSectionHeader(title: "賬號設置")
                        Column {
                            AlignedSettingRow(title: "體育系統密碼設置", subtitle: "", showDivider: true,
                                onTap: {=> this.unavailable("體育系統密碼設置")})
                            AlignedSettingRow(title: "物理實驗系統密碼設置", subtitle: "", showDivider: true,
                                onTap: {=> this.unavailable("物理實驗系統密碼設置")})
                            AlignedSettingRow(
                                title: "校園網帳號密碼設置",
                                subtitle: "不設置查看不了網費",
                                showDivider: true,
                                onTap: {=> this.unavailable("校園網帳號密碼設置")}
                            )
                            AlignedSettingRow(
                                title: "空調用電數據源",
                                subtitle: "未設置，電費頁不顯示空調用電",
                                showDivider: false,
                                onTap: {=> this.unavailable("空調用電數據源")}
                            )
                        }
                            .width(100.percent)
                            .backgroundColor(ThemePalette.surface(this.darkMode()))
                            .borderRadius(bottomLeft: 14.vp, bottomRight: 14.vp)
                    }.width(100.percent).margin(top: 8.vp)

                    Column {
                        AlignedSettingsSectionHeader(title: "課表相關設置")
                        Column {
                            AlignedSettingToggleRow(title: "開啟課表背景圖", subtitle: "", isOn: false,
                                showDivider: true, stableId: "settingsBackgroundToggle",
                                onChange: {_: Bool => this.unavailable("課表背景圖")})
                            AlignedSettingRow(title: "課表背景圖選擇", subtitle: "", showDivider: true,
                                onTap: {=> this.unavailable("課表背景圖選擇")})
                            AlignedSettingRow(title: "清除所有用戶添加課程", subtitle: "", showDivider: true,
                                onTap: {=> this.unavailable("清除用戶課程")})
                            AlignedSettingRow(title: "強制刷新課表", subtitle: "", showDivider: true,
                                onTap: {=> this.unavailable("強制刷新課表")})
                            AlignedSettingRow(
                                title: "課程偏移設置",
                                subtitle: "正數錯後開學日期 負數提前開學日期\n目前為 0",
                                showDivider: true,
                                onTap: {=> this.unavailable("課程偏移設置")}
                            )
                            AlignedSettingRow(title: "修改學期", subtitle: this.semester, showDivider: false,
                                onTap: {=> this.unavailable("修改學期")})
                        }
                            .width(100.percent)
                            .backgroundColor(ThemePalette.surface(this.darkMode()))
                            .borderRadius(bottomLeft: 14.vp, bottomRight: 14.vp)
                    }.width(100.percent).margin(top: 8.vp)

                    Column {
                        AlignedSettingsSectionHeader(title: "緩存登錄設置")
                        Column {
                            AlignedSettingRow(title: "查看網絡攔截器和日誌", subtitle: "", showDivider: true,
                                onTap: {=> this.unavailable("日誌查看")})
                            AlignedSettingRow(title: "清除緩存後重啟", subtitle: "", showDivider: true,
                                onTap: {=> this.unavailable("緩存清理")})
                            AlignedSettingRow(title: "退出登錄並重啟應用", subtitle: "", showDivider: false,
                                onTap: this.onLogout)
                        }
                            .width(100.percent)
                            .backgroundColor(ThemePalette.surface(this.darkMode()))
                            .borderRadius(bottomLeft: 14.vp, bottomRight: 14.vp)
                    }.width(100.percent).margin(top: 8.vp)
                    if (this.migrationHint != "") {
                        Text(this.migrationHint)
                            .width(100.percent)
                            .textAlign(TextAlign.Center)
                            .fontSize(12.vp)
                            .fontColor(0xFF5B6370)
                            .padding(top: 10.vp, bottom: 10.vp)
                            .id("settingsMigrationHint")
                    }
                    Blank().height(12.vp)
                }.width(100.percent).padding(left: 17.vp, right: 17.vp).alignItems(HorizontalAlign.Start)
            }.width(100.percent).height(100.percent).align(Alignment.TopStart)
        }.width(100.percent).height(100.percent).backgroundColor(ThemePalette.pageBackground(this.darkMode()))
    }
}

// 设置分组标题。
@Component
public class AlignedSettingsSectionHeader {
    let title: String
    @StorageProp["xdyouThemePreference"]
    let themePreference: String = "System"
    @StorageProp["colorMode"]
    let systemColorMode: ColorMode = ColorMode.Light
    func darkMode(): Bool {
        return AppTheme.isDark(this.themePreference, this.systemColorMode)
    }
    func build() {
        Row {
            Text(this.title).fontSize(16.vp).fontWeight(FontWeight.Bold).fontColor(ThemePalette.primaryText())
        }
            .width(100.percent)
            .height(44.vp)
            .justifyContent(FlexAlign.Center)
            .backgroundColor(ThemePalette.primary())
            .borderRadius(topLeft: 14.vp, topRight: 14.vp)
    }
}

// 可点击的普通设置行，尾部文案用于显示当前值或跳转提示。
@Component
public class AlignedSettingRow {
    let title: String
    let subtitle: String
    let showDivider: Bool
    let onTap: () -> Unit
    @StorageProp["xdyouThemePreference"]
    let themePreference: String = "System"
    @StorageProp["colorMode"]
    let systemColorMode: ColorMode = ColorMode.Light
    func darkMode(): Bool {
        return AppTheme.isDark(this.themePreference, this.systemColorMode)
    }
    func build() {
        Column {
            Row {
                Column {
                    Text(this.title).fontSize(16.vp).fontColor(ThemePalette.textPrimary(this.darkMode()))
                    if (this.subtitle != "") {
                        Text(this.subtitle)
                            .fontSize(14.vp)
                            .fontColor(ThemePalette.textSecondary(this.darkMode()))
                            .margin(top: 3.vp)
                    }
                }.layoutWeight(1).alignItems(HorizontalAlign.Start)
                Text("›").fontSize(30.vp).fontColor(ThemePalette.textSecondary(this.darkMode())).margin(left: 8.vp)
            }
                .width(100.percent)
                .height(if (this.subtitle.contains("\n")) {
                    94.vp
                } else {
                    82.vp
                })
                .padding(left: 20.vp, right: 28.vp)
                .onClick({_ => this.onTap()})
            if (this.showDivider) {
                Divider()
                    .color(ThemePalette.border(this.darkMode()))
                    .strokeWidth(1.vp)
                    .margin(left: 14.vp, right: 14.vp)
            }
        }.width(100.percent)
    }
}

// 带开关的设置行，状态变更通过回调交给页面持久化。
@Component
public class AlignedSettingToggleRow {
    let title: String
    let subtitle: String
    let isOn: Bool
    let showDivider: Bool
    let stableId: String
    let onChange: (Bool) -> Unit
    @StorageProp["xdyouThemePreference"]
    let themePreference: String = "System"
    @StorageProp["colorMode"]
    let systemColorMode: ColorMode = ColorMode.Light
    func darkMode(): Bool {
        return AppTheme.isDark(this.themePreference, this.systemColorMode)
    }
    func build() {
        Column {
            Row {
                Column {
                    Text(this.title).fontSize(16.vp).fontColor(ThemePalette.textPrimary(this.darkMode()))
                    if (this.subtitle != "") {
                        Text(this.subtitle)
                            .fontSize(14.vp)
                            .fontColor(ThemePalette.textSecondary(this.darkMode()))
                            .margin(top: 3.vp)
                    }
                }.layoutWeight(1).alignItems(HorizontalAlign.Start)
                Toggle(ToggleType.Switch, isOn: this.isOn)
                    .width(56.vp)
                    .height(34.vp)
                    .selectedColor(ThemePalette.primary())
                    .switchPointColor(ThemePalette.primaryText())
                    .onChange({value => this.onChange(value)})
                    .margin(left: 10.vp, right: 18.vp)
                    .id(this.stableId)
            }.width(100.percent).height(82.vp).padding(left: 20.vp)
            if (this.showDivider) {
                Divider()
                    .color(ThemePalette.border(this.darkMode()))
                    .strokeWidth(1.vp)
                    .margin(left: 14.vp, right: 14.vp)
            }
        }.width(100.percent)
    }
}

// 亮度调节行，仅产生新数值，不直接操作系统亮度能力。
@Component
public class AlignedBrightnessRow {
    @Prop
    var theme: String
    let onSystem: () -> Unit
    let onLight: () -> Unit
    let onDark: () -> Unit
    @StorageProp["xdyouThemePreference"]
    let themePreference: String = "System"
    @StorageProp["colorMode"]
    let systemColorMode: ColorMode = ColorMode.Light
    func darkMode(): Bool {
        return AppTheme.isDark(this.themePreference, this.systemColorMode)
    }
    func build() {
        Column {
            Row {
                Column {
                    Text("設置深淺色").fontSize(16.vp).fontColor(ThemePalette.textPrimary(this.darkMode()))
                    Text(this.theme)
                        .fontSize(14.vp)
                        .fontColor(ThemePalette.textSecondary(this.darkMode()))
                        .margin(top: 3.vp)
                }.layoutWeight(1).alignItems(HorizontalAlign.Start)
                Row {
                    Text("▯")
                        .width(38.vp)
                        .height(38.vp)
                        .textAlign(TextAlign.Center)
                        .fontSize(21.vp)
                        .fontColor(if (this.theme == "跟隨系統") {
                            ThemePalette.primaryText()
                        } else {
                            ThemePalette.primary()
                        })
                        .backgroundColor(if (this.theme == "跟隨系統") {
                            ThemePalette.primary()
                        } else {
                            ThemePalette.surface(this.darkMode())
                        })
                        .onClick({_ => this.onSystem()})
                        .id("settingsThemeSystem")
                    Text("☼")
                        .width(38.vp)
                        .height(38.vp)
                        .textAlign(TextAlign.Center)
                        .fontSize(20.vp)
                        .fontColor(if (this.theme == "白天模式") {
                            ThemePalette.primaryText()
                        } else {
                            ThemePalette.primary()
                        })
                        .backgroundColor(if (this.theme == "白天模式") {
                            ThemePalette.primary()
                        } else {
                            ThemePalette.surface(this.darkMode())
                        })
                        .onClick({_ => this.onLight()})
                        .id("settingsThemeLight")
                    Text("◕")
                        .width(38.vp)
                        .height(38.vp)
                        .textAlign(TextAlign.Center)
                        .fontSize(18.vp)
                        .fontColor(if (this.theme == "黑夜模式") {
                            ThemePalette.primaryText()
                        } else {
                            ThemePalette.primary()
                        })
                        .backgroundColor(if (this.theme == "黑夜模式") {
                            ThemePalette.primary()
                        } else {
                            ThemePalette.surface(this.darkMode())
                        })
                        .onClick({_ => this.onDark()})
                        .id("settingsThemeDark")
                }
                    .height(38.vp)
                    .border(width: 1.vp, color: ThemePalette.primary())
                    .borderRadius(19.vp)
                    .clip(true)
                    .margin(right: 18.vp)
            }.width(100.percent).height(82.vp).padding(left: 20.vp)
            Divider().color(ThemePalette.border(this.darkMode())).strokeWidth(1.vp).margin(left: 14.vp, right: 14.vp)
        }.width(100.percent)
    }
}
