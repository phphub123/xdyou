package ohos_app_cangjie_entry.page.homepage

import kit.ArkUI.*
import kit.ArkWeb.*
import ohos.arkui.state_macro_manage.*
import ohos.business_exception.*
import ohos.resource.*
import std.collection.ArrayList
import std.sync.*
import std.time.*
import ohos_app_cangjie_entry.repository.*
import ohos_app_cangjie_entry.repository.xidian_ids.*
import ohos_app_cangjie_entry.model.xidian_ids.*
import ohos_app_cangjie_entry.controller.*
import ohos_app_cangjie_entry.components.*
import ohos_app_cangjie_entry.components.*
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
                    ScorePage(onBack: {=> this.homeFeature = 0})
                } else if (this.selected == 0 && this.homeFeature == 7) {
                    ExamPage(onBack: {=> this.homeFeature = 0})
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
            if (this.homeFeature == 0) {
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
            }
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
    @State var scheduleTitle: String = "今日安排"
    @State var scheduleStatus: String = "正在加载真实课表"
    @State var scheduleBottomText: String = "正在加载真实课表"
    @State var scheduleLoaded: Bool = false
    @State var scheduleCourses: ArrayList<CourseSlot> = ArrayList<CourseSlot>()
    @State var scheduleTermStartDay: String = ""
    @State var scheduleSemesterLength: Int64 = 1
    @State var energyValue: String = "水电信息需连接校园网"
    @State var energyStatus: String = "连接校园网后进入详情页刷新"
    @State var libraryValue: String = "正在获取借书信息"
    @State var libraryStatus: String = "正在查询借阅信息"
    @State var schoolCardValue: String = "正在获取校园卡信息"
    @State var schoolCardStatus: String = "正在查询余额"
    let classTableController = ClassTableController()
    let libraryController = LibraryController()
    let schoolCardController = SchoolCardController()
    let previewMode: Bool
    @State var libraryAuthStarted: Bool = false
    @State var cardAuthStarted: Bool = false
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
    var scheduleTimer: ?Timer = None
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
        this.stopScheduleTimer()
        this.scheduleTimer = Some(Timer.repeat(Duration.second * 60, Duration.second * 60, { => launch {
            if (this.scheduleLoaded) { this.updateScheduleDisplay() }
        }}))
        Timer.once(Duration.second * 22, { => launch {
            this.libraryAuthStarted = true
        }})
        Timer.once(Duration.second * 32, { => launch {
            this.cardAuthStarted = true
        }})
        if (LibraryController.cachedBorrowCount >= 0) {
            this.libraryValue = "借书 ${LibraryController.cachedBorrowCount} 本"
            this.libraryStatus = "待归还 ${LibraryController.cachedBorrowCount} 本书籍"
        }
        if (SchoolCardController.cachedBalance != "") {
            this.schoolCardValue = "卡里 ${SchoolCardController.cachedBalance} 元"
            this.schoolCardStatus = "查询一卡通流水"
        }
        AcademicSession().loadCurrentSemester({ semester => launch {
            SessionStore().saveSetting("semester", semester)
            this.classTableController.reloadClassTable(semester, { data => launch {
                this.scheduleCourses = data.courses
                this.scheduleTermStartDay = data.termStartDay
                this.scheduleSemesterLength = data.semesterLength
                this.scheduleLoaded = true
                this.updateScheduleDisplay()
            } }, { message => launch {
                this.scheduleLoaded = false
                this.scheduleTitle = "今日安排"
                this.scheduleStatus = "加载失败"
                this.scheduleBottomText = message
            } })
        } }, { message => launch {
            this.scheduleLoaded = false
            this.scheduleTitle = "今日安排"
            this.scheduleStatus = "加载失败"
            this.scheduleBottomText = message
        } })
    }

    protected override func aboutToDisappear(): Unit {
        this.stopScheduleTimer()
    }

    func stopScheduleTimer(): Unit {
        match (this.scheduleTimer) {
            case Some(timer) => timer.cancel()
            case None => ()
        }
        this.scheduleTimer = None
    }

    func weekdayNumber(value: DateTime): Int64 {
        return match (value.dayOfWeek) {
            case Monday => 1
            case Tuesday => 2
            case Wednesday => 3
            case Thursday => 4
            case Friday => 5
            case Saturday => 6
            case Sunday => 7
        }
    }

    func weekdayLabel(value: DateTime): String {
        return match (value.dayOfWeek) {
            case Monday => "周一"
            case Tuesday => "周二"
            case Wednesday => "周三"
            case Thursday => "周四"
            case Friday => "周五"
            case Saturday => "周六"
            case Sunday => "周日"
        }
    }

    func monthNumber(value: DateTime): Int64 {
        return match (value.month) {
            case January => 1
            case February => 2
            case March => 3
            case April => 4
            case May => 5
            case June => 6
            case July => 7
            case August => 8
            case September => 9
            case October => 10
            case November => 11
            case December => 12
        }
    }

    func currentScheduleWeek(value: DateTime): Int64 {
        if (this.scheduleTermStartDay == "" || this.scheduleSemesterLength < 1) { return -1 }
        try {
            let start = DateTime.parse(this.scheduleTermStartDay, "yyyy-MM-dd")
            let diffDays = (value.toUnixTimeStamp().toSeconds() - start.toUnixTimeStamp().toSeconds()) / 86400
            if (diffDays < 0) { return -1 }
            let week = diffDays / 7 + 1
            return if (week > this.scheduleSemesterLength) { -1 } else { week }
        } catch (_) {
            return -1
        }
    }

    func courseEndMinutes(stop: Int64): Int64 {
        return match (stop) {
            case 1 => 9 * 60 + 15
            case 2 => 10 * 60 + 5
            case 3 => 11 * 60 + 10
            case 4 => 12 * 60
            case 5 => 14 * 60 + 45
            case 6 => 15 * 60 + 35
            case 7 => 16 * 60 + 40
            case 8 => 17 * 60 + 30
            case 9 => 19 * 60 + 45
            case 10 => 20 * 60 + 35
            case _ => 21 * 60 + 25
        }
    }

    func updateScheduleDisplay(): Unit {
        let now = DateTime.now()
        let showTomorrow = now.hour * 60 + now.minute > 21 * 60 + 25
        let displayTime = if (showTomorrow) { now.addDays(1) } else { now }
        let week = this.currentScheduleWeek(displayTime)
        let active = if (week < 1) {
            ArrayList<CourseSlot>()
        } else {
            this.classTableController.arrangements(this.scheduleCourses, this.weekdayNumber(displayTime), week)
        }
        var remaining: Int64 = 0
        let currentMinutes = now.hour * 60 + now.minute
        for (course in active) {
            if (showTomorrow || this.courseEndMinutes(course.stop) > currentMinutes) { remaining += 1 }
        }
        this.scheduleCount = remaining
        this.scheduleTitle = if (showTomorrow) {
            if (remaining == 0) { "明日没有安排" } else { "明日有 ${remaining} 个安排" }
        } else {
            if (remaining == 0) { "今日安排完成" } else { "今日还有 ${remaining} 个日程" }
        }
        let weekText = if (week < 1) { "假期中" } else { "第 ${week} 周" }
        this.scheduleStatus = "${this.monthNumber(displayTime)}月${displayTime.dayOfMonth}日 ${this.weekdayLabel(displayTime)} ${weekText}"
        this.scheduleBottomText = if (remaining == 0) { "暂无日程" } else { "${remaining} 个日程待完成" }
    }

    func loadLibraryWeb(raw: String, cookies: String): Unit {
        this.libraryController.borrowsAuthorized(raw, cookies, { values => launch {
            this.libraryValue = "借书 ${values.size} 本"
            this.libraryStatus = "待归还 ${values.size} 本书籍"
        } }, { message => launch { this.libraryValue = "借书信息暂不可用"; this.libraryStatus = message } })
    }
    func loadCardWeb(raw: String, cookies: String): Unit {
        if (!this.schoolCardController.authorizeWeb(raw, cookies, { message =>
            this.schoolCardValue = "校园卡信息暂不可用"; this.schoolCardStatus = message
        })) { return }
        this.schoolCardController.overview({ value => launch {
            this.schoolCardValue = "卡里 ${value.balance} 元"; this.schoolCardStatus = "查询一卡通流水"
        } }, { message => launch { this.schoolCardValue = "校园卡信息暂不可用"; this.schoolCardStatus = message } })
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
                            Text(if (this.previewMode) { "物理实验加载失败" } else { "部分加載中" })
                                .fontSize(12.vp)
                                .fontWeight(FontWeight.Bold)
                                .fontColor(if (this.previewMode) { 0xFFFFFFFF } else { 0xFFD6E4FF })
                                .padding(left: 15.vp, right: 15.vp, top: 8.vp, bottom: 8.vp)
                                .backgroundColor(if (this.previewMode) { 0xFFD51F1F } else { 0xFF476FA9 })
                                .borderRadius(16.vp)
                            Text(if (this.previewMode) { "其他实验加载失败" } else { "其他實驗加載失敗" })
                                .fontSize(12.vp)
                                .fontWeight(FontWeight.Bold)
                                .fontColor(0xFFFFFFFF)
                                .padding(left: 15.vp, right: 15.vp, top: 8.vp, bottom: 8.vp)
                                .margin(left: 9.vp)
                                .backgroundColor(0xFFD51F1F)
                                .borderRadius(16.vp)
                        }.width(100.percent).height(48.vp).justifyContent(FlexAlign.Center)
                        Row {
                            Image(@r(app.media.home_calendar))
                                .width(32.vp)
                                .height(32.vp)
                                .fillColor(0xFF41699F)
                                .margin(left: 16.vp, right: 18.vp)
                            Column {
                                Text(if (this.previewMode) {
                                    "今日安排完成"
                                } else {
                                    this.scheduleTitle
                                }).fontSize(20.vp).fontColor(0xFF474B55)
                                Text(if (this.previewMode) { "8月11日 周二 假期中" } else { this.scheduleStatus })
                                    .fontSize(14.vp)
                                    .fontColor(0xFF454953)
                                    .margin(top: 1.vp)
                            }.layoutWeight(1).alignItems(HorizontalAlign.Start)
                        }.width(100.percent).height(55.vp).onClick({_ => this.onSchedule()})
                        Text(if (this.previewMode) { "暂无日程" } else { this.scheduleBottomText })
                            .width(100.percent)
                            .height(34.vp)
                            .textAlign(TextAlign.Center)
                            .fontSize(16.vp)
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
                        value: if (this.previewMode) { "余额 -62.7 度" } else { this.energyValue },
                        note: if (this.previewMode) { "最后一次读表：2026-08-11" } else { this.energyStatus },
                        showQr: false,
                        onTap: this.onEnergy,
                        testId: "homeEnergyInfo"
                    )
                    AlignedInfoCard(
                        icon: @r(app.media.home_book),
                        value: if (this.previewMode) { "借书 1 本" } else { this.libraryValue },
                        note: if (this.previewMode) { "待归还 1 本书籍" } else { this.libraryStatus },
                        showQr: false,
                        onTap: this.onLibrary,
                        testId: "homeLibraryInfo"
                    )
                    AlignedInfoCard(
                        icon: @r(app.media.home_wallet),
                        value: if (this.previewMode) { "卡里 0.00 元" } else { this.schoolCardValue },
                        note: if (this.previewMode) { "查询一卡通流水" } else { this.schoolCardStatus },
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
            if (this.libraryAuthStarted) {
            ServiceAuthWeb(
                url: "https://tyrzfw.chaoxing.com/auth/xidian/cas/init?isLogout=0&refer=https%3A%2F%2Fmfindxidian.libsp.cn%2Ffind%2Fsso%2Flogin%2Fxidian%2F1",
                cookieUrl: "https://mfindxidian.libsp.cn",
                stableId: "homeLibraryAuthWeb",
                onReady: { url: String, payload: String, cookies: String => this.loadLibraryWeb(url + "|" + payload, cookies) },
                onFailure: { message: String => this.libraryValue = "借书信息暂不可用"; this.libraryStatus = message }
            )
            }
            if (this.cardAuthStarted) {
            ServiceAuthWeb(
                url: "https://v8scan.xidian.edu.cn/home/openXDOAuth2Page",
                cookieUrl: "https://v8scan.xidian.edu.cn",
                stableId: "homeCardAuthWeb",
                onReady: { url: String, payload: String, cookies: String => this.loadCardWeb(url + "|" + payload, cookies) },
                onFailure: { message: String => this.schoolCardValue = "校园卡信息暂不可用"; this.schoolCardStatus = message }
            )
            }
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
