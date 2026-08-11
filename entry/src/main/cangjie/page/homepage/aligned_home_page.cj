package ohos_app_cangjie_entry.page.homepage

import kit.ArkUI.*
import kit.ArkWeb.*
import ohos.arkui.state_macro_manage.*
import ohos.business_exception.*
import ohos.resource.*
import ohos_app_cangjie_entry.repository.*
import ohos_app_cangjie_entry.repository.xidian_ids.*
import ohos_app_cangjie_entry.controller.*
import ohos_app_cangjie_entry.themes.*
import ohos_app_cangjie_entry.page.class_attendance.*
import ohos_app_cangjie_entry.page.classtable.*
import ohos_app_cangjie_entry.page.dorm_water.*
import ohos_app_cangjie_entry.page.empty_classroom.*
import ohos_app_cangjie_entry.page.energy.*
import ohos_app_cangjie_entry.page.exam.*
import ohos_app_cangjie_entry.page.experiment.*
import ohos_app_cangjie_entry.page.library.*
import ohos_app_cangjie_entry.page.schoolcard.*
import ohos_app_cangjie_entry.page.schoolnet.*
import ohos_app_cangjie_entry.page.score.*
import ohos_app_cangjie_entry.page.sport.*
import ohos_app_cangjie_entry.page.toolbox.*
import ohos_app_cangjie_entry.page.pig.*
import ohos_app_cangjie_entry.page.setting.*

@Component
public class AlignedHomePage {
    let account: String
    let previewMode: Bool
    let onLogout: () -> Unit
    @State var selected: Int64 = 0
    @State var homeFeature: Int64 = 0
    @StorageProp["xdyouThemePreference"]
    let themePreference: String = "System"
    @StorageProp["colorMode"]
    let systemColorMode: ColorMode = ColorMode.Light

    func darkMode(): Bool {
        return AppTheme.isDark(this.themePreference, this.systemColorMode)
    }

    func selectPage(index: Int64): Unit {
        this.selected = index
        if (index != 0) {
            this.homeFeature = 0
        }
    }

    func build() {
        Column {
            Column {
                if (this.selected == 0 && this.homeFeature == 1) {
                    ClassAttendancePage(onBack: {=> this.homeFeature = 0})
                } else if (this.selected == 0 && this.homeFeature == 2) {
                    EmptyClassroomPage(onBack: {=> this.homeFeature = 0})
                } else if (this.selected == 0 && this.homeFeature == 3) {
                    LibraryPage(onBack: {=> this.homeFeature = 0})
                } else if (this.selected == 0 && this.homeFeature == 4) {
                    SchoolnetPage(onBack: {=> this.homeFeature = 0})
                } else if (this.selected == 0 && this.homeFeature == 5) {
                    DormWaterPage(onBack: {=> this.homeFeature = 0})
                } else if (this.selected == 0 && this.homeFeature == 6) {
                    ScorePage()
                } else if (this.selected == 0 && this.homeFeature == 7) {
                    ExamPage()
                } else if (this.selected == 0 && this.homeFeature == 8) {
                    ClassTablePage(onBack: {=> this.homeFeature = 0})
                } else if (this.selected == 0 && this.homeFeature == 9) {
                    SchoolCardPage(onBack: {=> this.homeFeature = 0})
                } else if (this.selected == 0 && this.homeFeature == 10) {
                    SportPage(onBack: {=> this.homeFeature = 0})
                } else if (this.selected == 0 && this.homeFeature == 11) {
                    ExperimentPage(onBack: {=> this.homeFeature = 0})
                } else if (this.selected == 0 && this.homeFeature == 12) {
                    EnergyPage(onBack: {=> this.homeFeature = 0})
                } else if (this.selected == 0) {
                    AlignedCampusPage(
                        previewMode: this.previewMode,
                        onSchedule: {=> this.homeFeature = 8},
                        onScore: {=> this.homeFeature = 6},
                        onExam: {=> this.homeFeature = 7},
                        onAttendance: {=> this.homeFeature = 1},
                        onEmptyClassroom: {=> this.homeFeature = 2},
                        onLibrary: {=> this.homeFeature = 3},
                        onSchoolnet: {=> this.homeFeature = 4},
                        onDormWater: {=> this.homeFeature = 5},
                        onSchoolCard: {=> this.homeFeature = 9},
                        onSport: {=> this.homeFeature = 10},
                        onExperiment: {=> this.homeFeature = 11},
                        onEnergy: {=> this.homeFeature = 12}
                    )
                } else if (this.selected == 1) {
                    AlignedRuisiPage(onOpenToolbox: {=> this.selectPage(2)})
                } else if (this.selected == 2) {
                    AlignedToolboxPage()
                } else if (this.selected == 3) {
                    AlignedPigPage()
                } else {
                    AlignedSettingsPage(account: this.account, onLogout: this.onLogout)
                }
            }.width(100.percent).layoutWeight(1)
            Row {
                AlignedNavItem(
                    icon: @r(app.media.nav_school),
                    label: "校園信息",
                    index: 0,
                    selectedIndex: this.selected,
                    onTap: {=> this.selectPage(0)},
                    stableId: "navTo_home"
                )
                AlignedNavItem(
                    icon: @r(app.media.nav_forum),
                    label: "睿思論壇",
                    index: 1,
                    selectedIndex: this.selected,
                    onTap: {=> this.selectPage(1)},
                    stableId: "navTo_ruisi"
                )
                AlignedNavItem(
                    icon: @r(app.media.nav_tools),
                    label: "其他功能",
                    index: 2,
                    selectedIndex: this.selected,
                    onTap: {=> this.selectPage(2)},
                    stableId: "navTo_toolbox"
                )
                AlignedNavItem(
                    icon: @r(app.media.nav_pig),
                    label: "豬圖鑑賞",
                    index: 3,
                    selectedIndex: this.selected,
                    onTap: {=> this.selectPage(3)},
                    stableId: "navTo_pig"
                )
                AlignedNavItem(
                    icon: @r(app.media.nav_user),
                    label: "設置",
                    index: 4,
                    selectedIndex: this.selected,
                    onTap: {=> this.selectPage(4)},
                    stableId: "navTo_settings"
                )
            }
                .width(100.percent)
                .height(88.vp)
                .padding(left: 3.vp, right: 3.vp, top: 5.vp, bottom: 3.vp)
                .backgroundColor(ThemePalette.navSurface(this.darkMode()))
                .border(width: 1.vp, color: ThemePalette.border(this.darkMode()))
        }.width(100.percent).height(100.percent).backgroundColor(ThemePalette.pageBackground(this.darkMode()))
    }
}

@Component
public class AlignedNavItem {
    let icon: AppResource
    let label: String
    let index: Int64
    @Prop
    var selectedIndex: Int64
    let onTap: () -> Unit
    let stableId: String
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
                Image(this.icon)
                    .width(25.vp)
                    .height(25.vp)
                    .objectFit(ImageFit.Contain)
                    .fillColor(if (this.selectedIndex == this.index) {
                        ThemePalette.primaryText()
                    } else {
                        ThemePalette.textSecondary(this.darkMode())
                    })
            }
                .width(58.vp)
                .height(34.vp)
                .justifyContent(FlexAlign.Center)
                .backgroundColor(if (this.selectedIndex == this.index) {
                    ThemePalette.primary(this.darkMode())
                } else {
                    ThemePalette.navSurface(this.darkMode())
                })
                .borderRadius(17.vp)
            Text(this.label)
                .fontSize(12.vp)
                .fontColor(if (this.selectedIndex == this.index) {
                    ThemePalette.primary(this.darkMode())
                } else {
                    ThemePalette.textSecondary(this.darkMode())
                })
                .fontWeight(if (this.selectedIndex == this.index) {
                    FontWeight.Medium
                } else {
                    FontWeight.Normal
                })
                .margin(top: 4.vp)
        }.layoutWeight(1).height(78.vp).justifyContent(FlexAlign.Center).onClick({_ => this.onTap()}).id(this.stableId)
    }
}

@Component
public class AlignedCampusPage {
    @State var scheduleCount: Int64 = 0
    @State var scheduleStatus: String = "正在加载真实课表"
    @State var schoolCardValue: String = "正在获取校园卡信息"
    @State var schoolCardStatus: String = "正在查询余额"
    let classTableController = ClassTableController()
    let schoolCardController = SchoolCardController()
    let previewMode: Bool
    let onSchedule: () -> Unit
    let onScore: () -> Unit
    let onExam: () -> Unit
    let onAttendance: () -> Unit
    let onEmptyClassroom: () -> Unit
    let onLibrary: () -> Unit
    let onSchoolnet: () -> Unit
    let onDormWater: () -> Unit
    let onSchoolCard: () -> Unit
    let onSport: () -> Unit
    let onExperiment: () -> Unit
    let onEnergy: () -> Unit
    @State var editMode: Bool = false
    @StorageProp["xdyouThemePreference"]
    let themePreference: String = "System"
    @StorageProp["colorMode"]
    let systemColorMode: ColorMode = ColorMode.Light
    func darkMode(): Bool {
        return AppTheme.isDark(this.themePreference, this.systemColorMode)
    }

    protected override func aboutToAppear(): Unit {
        if (this.previewMode) {
            this.scheduleStatus = "预览数据"
            return
        }
        AcademicSession().loadCurrentSemester({ semester => launch {
            SessionStore().saveSetting("semester", semester)
            this.classTableController.reloadClassTable(semester, { data => launch {
                this.scheduleCount = data.courses.size
                this.scheduleStatus = if (data.courses.size == 0) { "本学期暂无课程" } else { "已同步 ${data.courses.size} 条课程安排" }
            } }, { message => launch { this.scheduleStatus = message } })
        } }, { message => launch { this.scheduleStatus = message } })
        this.schoolCardController.overview({ value => launch {
            this.schoolCardValue = "余额 ${value.balance} 元"
            this.schoolCardStatus = "校园卡账户已同步"
        } }, { message => launch {
            this.schoolCardValue = "校园卡信息暂不可用"
            this.schoolCardStatus = message
        } })
    }

    func build() {
        Column {
            Row {
                Text("校園信息查詢")
                    .fontSize(22.vp)
                    .fontWeight(FontWeight.Medium)
                    .fontColor(0xFF202229)
                    .layoutWeight(1)
                Image(if (this.editMode) {
                    @r(app.media.action_check)
                } else {
                    @r(app.media.action_edit)
                })
                    .width(24.vp)
                    .height(24.vp)
                    .fillColor(0xFF3E424B)
                    .padding(6.vp)
                    .onClick({_ => this.editMode = !this.editMode})
                    .id("homeEditLayout")
            }.width(100.percent).height(58.vp).padding(left: 20.vp, right: 17.vp)
            Scroll {
                Column {
                    Column {
                        Text("目前您正在運行測試版").fontSize(14.vp).fontColor(0xFF454953)
                    }
                        .width(100.percent)
                        .height(40.vp)
                        .justifyContent(FlexAlign.Center)
                        .backgroundColor(0xFFF6F6FE)
                        .border(width: 1.vp, color: 0xFFDDDDE7)
                        .borderRadius(14.vp)
                        .id("mockPreviewBanner")
                    Column {
                        Row {
                            Text("部分加載中")
                                .fontSize(12.vp)
                                .fontWeight(FontWeight.Bold)
                                .fontColor(0xFFD6E4FF)
                                .padding(left: 15.vp, right: 15.vp, top: 8.vp, bottom: 8.vp)
                                .backgroundColor(0xFF476FA9)
                                .borderRadius(12.vp)
                            Text("其他實驗加載失敗")
                                .fontSize(12.vp)
                                .fontWeight(FontWeight.Bold)
                                .fontColor(0xFFFFFFFF)
                                .padding(left: 15.vp, right: 15.vp, top: 8.vp, bottom: 8.vp)
                                .margin(left: 9.vp)
                                .backgroundColor(0xFFD51F1F)
                                .borderRadius(12.vp)
                        }.width(100.percent).height(48.vp).justifyContent(FlexAlign.Center)
                        Row {
                            Image(@r(app.media.home_calendar))
                                .width(30.vp)
                                .height(30.vp)
                                .fillColor(0xFF41699F)
                                .margin(left: 16.vp, right: 15.vp)
                            Column {
                                Text(if (this.scheduleCount > 0) { "本学期课程 ${this.scheduleCount} 项" } else { "今日安排" }).fontSize(20.vp).fontColor(0xFF474B55)
                                Text(this.scheduleStatus).fontSize(13.vp).fontColor(0xFF454953).margin(top: 1.vp)
                            }.layoutWeight(1).alignItems(HorizontalAlign.Start)
                        }.width(100.percent).height(55.vp).onClick({_ => this.onSchedule()})
                        Text(this.scheduleStatus)
                            .width(100.percent)
                            .height(34.vp)
                            .textAlign(TextAlign.Center)
                            .fontSize(14.vp)
                            .fontWeight(FontWeight.Medium)
                            .fontColor(0xFF41699F)
                            .backgroundColor(0xFFE1E7F4)
                            .borderRadius(8.vp)
                            .margin(left: 14.vp, right: 14.vp, bottom: 11.vp)
                    }
                        .width(100.percent)
                        .height(148.vp)
                        .margin(top: 10.vp)
                        .backgroundColor(0xFFF6F6FE)
                        .border(width: 1.vp, color: 0xFFDDDDE7)
                        .borderRadius(14.vp)
                        .id("homeScheduleCard")
                    AlignedInfoCard(
                        icon: @r(app.media.home_flash),
                        value: "电量查询",
                        note: "电费、水费与空调能耗",
                        showQr: false,
                        onTap: this.onEnergy,
                        testId: "homeEnergyInfo"
                    )
                    AlignedInfoCard(
                        icon: @r(app.media.home_book),
                        value: if (this.previewMode) {
                            "借書 1 本"
                        } else {
                            "正在獲取借書信息"
                        },
                        note: if (this.previewMode) {
                            "待歸還 1 本書籍"
                        } else {
                            "正在查詢信息中"
                        },
                        showQr: false,
                        onTap: this.onLibrary,
                        testId: "homeLibraryInfo"
                    )
                    AlignedInfoCard(
                        icon: @r(app.media.home_wallet),
                        value: if (this.previewMode) {
                            "未登錄"
                        } else {
                            "正在獲取校園卡信息"
                        },
                        note: "查看餘額、流水與付款碼",
                        showQr: true,
                        onTap: this.onSchoolCard,
                        testId: "homeSchoolCard"
                    )
                    Row {
                        AlignedSmallCard(
                            icon: @r(app.media.home_score),
                            title: "成績查詢",
                            onTap: this.onScore,
                            stableId: "homeScore"
                        )
                        AlignedSmallCard(
                            icon: @r(app.media.home_exam),
                            title: "考試安排",
                            onTap: this.onExam,
                            stableId: "homeExam"
                        )
                        AlignedSmallCard(
                            icon: @r(app.media.home_room),
                            title: "空閒教室",
                            onTap: this.onEmptyClassroom,
                            stableId: "homeEmptyClassroom"
                        )
                        AlignedSmallCard(
                            icon: @r(app.media.home_attendance),
                            title: "考勤查詢",
                            onTap: this.onAttendance,
                            stableId: "homeAttendance"
                        )
                    }.width(100.percent).height(78.vp).margin(top: 8.vp)
                    Row {
                        AlignedSmallCard(
                            icon: @r(app.media.home_network),
                            title: "網絡查詢",
                            onTap: this.onSchoolnet,
                            stableId: "homeSchoolnet"
                        )
                        AlignedSmallCard(
                            icon: @r(app.media.home_water),
                            title: "宿舍水機",
                            onTap: this.onDormWater,
                            stableId: "homeDormWater"
                        )
                        AlignedSmallCard(icon: @r(app.media.home_experiment), title: "實驗信息",
                            onTap: this.onExperiment, stableId: "homeExperiment")
                        AlignedSmallCard(icon: @r(app.media.home_sport), title: "體育信息", onTap: this.onSport,
                            stableId: "homeSport")
                    }.width(100.percent).height(78.vp).margin(top: 8.vp)
                    if (this.editMode) {
                        Text("日程信息和軟件升級信息不允許編輯")
                            .width(100.percent)
                            .textAlign(TextAlign.Center)
                            .fontSize(12.vp)
                            .fontColor(0xFF526070)
                            .margin(top: 10.vp)
                    }
                    Blank().height(20.vp)
                }.width(100.percent).padding(left: 16.vp, right: 16.vp, top: 11.vp).alignItems(HorizontalAlign.Start)
            }.width(100.percent).layoutWeight(1).align(Alignment.TopStart)
        }.width(100.percent).height(100.percent).backgroundColor(ThemePalette.pageBackground(this.darkMode()))
    }
}

@Component
public class AlignedInfoCard {
    let icon: AppResource
    let value: String
    let note: String
    let showQr: Bool
    let onTap: () -> Unit
    let testId: String
    func build() {
        Row {
            Image(this.icon).width(30.vp).height(30.vp).fillColor(0xFF41699F).margin(left: 14.vp, right: 17.vp)
            Column {
                Text(this.value).fontSize(19.vp).fontColor(0xFF474B55);
            Text(this.note).fontSize(13.vp).fontColor(0xFF454953).margin(top: 3.vp)
            }.layoutWeight(1).alignItems(HorizontalAlign.Start)
            if (this.showQr) {
                Row {Image(@r(app.media.home_qr)).width(19.vp).height(19.vp).fillColor(0xFF4D5565)}
                    .width(40.vp)
                    .height(40.vp)
                    .justifyContent(FlexAlign.Center)
                    .backgroundColor(0xFFF1F4FD)
                    .borderRadius(20.vp)
            }
        }
            .width(100.percent)
            .height(68.vp)
            .padding(right: 14.vp)
            .margin(top: 8.vp)
            .backgroundColor(0xFFF6F6FE)
            .border(width: 1.vp, color: 0xFFDDDDE7)
            .borderRadius(14.vp)
            .onClick({_ => this.onTap()})
            .id(this.testId)
    }
}

@Component
public class AlignedSmallCard {
    let icon: AppResource
    let title: String
    let onTap: () -> Unit
    let stableId: String
    func build() {
        Column {
            Image(this.icon).width(29.vp).height(29.vp).fillColor(0xFF41699F)
            Text(this.title).fontSize(12.vp).fontColor(0xFF3F434C).margin(top: 6.vp).textAlign(TextAlign.Center)
        }
            .layoutWeight(1)
            .height(78.vp)
            .margin(left: 3.vp, right: 3.vp)
            .justifyContent(FlexAlign.Center)
            .backgroundColor(0xFFF6F6FE)
            .border(width: 1.vp, color: 0xFFDDDDE7)
            .borderRadius(13.vp)
            .onClick({_ => this.onTap()})
            .id(this.stableId)
    }
}

@Component
public class AlignedRuisiPage {
    let onOpenToolbox: () -> Unit
    @State var tab: Int64 = 0
    func build() {
        Column {
            Row {
                Text("睿思论坛").fontSize(22.vp).fontWeight(FontWeight.Bold).layoutWeight(1)
                Text("⌕").fontSize(22.vp).padding(8.vp).id("ruisiSearch")
                Text("✎").fontSize(21.vp).padding(8.vp).id("ruisiNewPost")
                Text("▦").fontSize(21.vp).padding(8.vp).id("ruisiForumList")
                Text("●").fontSize(18.vp).padding(8.vp).id("ruisiProfile")
            }.width(100.percent).height(58.vp).padding(left: 18.vp, right: 6.vp)
            Row {
                Text("最新发布")
                    .layoutWeight(1)
                    .textAlign(TextAlign.Center)
                    .fontSize(13.vp)
                    .fontWeight(if (this.tab == 0) {
                        FontWeight.Bold
                    } else {
                        FontWeight.Normal
                    })
                    .padding(12.vp)
                    .onClick({_ => this.tab = 0})
                    .id("ruisiTabNew")
                Text("最新回复")
                    .layoutWeight(1)
                    .textAlign(TextAlign.Center)
                    .fontSize(13.vp)
                    .fontWeight(if (this.tab == 1) {
                        FontWeight.Bold
                    } else {
                        FontWeight.Normal
                    })
                    .padding(12.vp)
                    .onClick({_ => this.tab = 1})
                    .id("ruisiTabReply")
                Text("水漫金山")
                    .layoutWeight(1)
                    .textAlign(TextAlign.Center)
                    .fontSize(13.vp)
                    .fontWeight(if (this.tab == 2) {
                        FontWeight.Bold
                    } else {
                        FontWeight.Normal
                    })
                    .padding(12.vp)
                    .onClick({_ => this.tab = 2})
                    .id("ruisiTabWater")
                Text("摄影交流")
                    .layoutWeight(1)
                    .textAlign(TextAlign.Center)
                    .fontSize(13.vp)
                    .fontWeight(if (this.tab == 3) {
                        FontWeight.Bold
                    } else {
                        FontWeight.Normal
                    })
                    .padding(12.vp)
                    .onClick({_ => this.tab = 3})
                    .id("ruisiTabPhoto")
            }.width(100.percent).height(46.vp).backgroundColor(0xFFFFFFFF).border(width: 1.vp, color: 0xFFE1E5EC)
            Column {
                Text("▣").fontSize(64.vp).fontColor(0xFF9AA5B5)
                Text("睿思会话尚未登录").fontSize(18.vp).fontWeight(FontWeight.Bold).margin(top: 16.vp)
                Text("请先通过工具箱的睿思入口完成网页登录，\n登录后即可同步论坛帖子。")
                    .fontSize(13.vp)
                    .fontColor(0xFF526070)
                    .textAlign(TextAlign.Center)
                    .margin(top: 10.vp)
                Button("前往工具箱")
                    .margin(top: 18.vp)
                    .backgroundColor(0xFFD0E4FF)
                    .fontColor(0xFF253A5E)
                    .onClick({_ => this.onOpenToolbox()})
                    .id("ruisiOpenToolbox")
            }.width(100.percent).layoutWeight(1).justifyContent(FlexAlign.Center)
        }.width(100.percent).height(100.percent)
    }
}
