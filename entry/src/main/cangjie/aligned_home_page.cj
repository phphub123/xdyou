package ohos_app_cangjie_entry

import kit.ArkUI.*
import kit.ArkWeb.*
import ohos.arkui.state_macro_manage.*
import ohos.business_exception.*
import ohos.resource.*
import ohos_app_cangjie_entry.repository.*

@Component
public class AlignedHomePage {
    let account: String
    let previewMode: Bool
    let onLogout: () -> Unit
    @State var selected: Int64 = 0
    @State var homeFeature: Int64 = 0

    func selectPage(index: Int64): Unit {
        this.selected = index
        if (index != 0) { this.homeFeature = 0 }
    }

    func build() {
        Column {
            Column {
                if (this.selected == 0 && this.homeFeature == 1) {
                    ClassAttendancePage(onBack: { => this.homeFeature = 0 })
                } else if (this.selected == 0 && this.homeFeature == 2) {
                    EmptyClassroomPage()
                } else if (this.selected == 0 && this.homeFeature == 3) {
                    LibraryPage(onBack: { => this.homeFeature = 0 })
                } else if (this.selected == 0 && this.homeFeature == 4) {
                    SchoolnetPage(onBack: { => this.homeFeature = 0 })
                } else if (this.selected == 0 && this.homeFeature == 5) {
                    DormWaterPage(onBack: { => this.homeFeature = 0 })
                } else if (this.selected == 0 && this.homeFeature == 6) {
                    ScorePage()
                } else if (this.selected == 0 && this.homeFeature == 7) {
                    ExamPage()
                } else if (this.selected == 0 && this.homeFeature == 8) {
                    ClassTablePage()
                } else if (this.selected == 0 && this.homeFeature == 9) {
                    SchoolCardPage(onBack: { => this.homeFeature = 0 })
                } else if (this.selected == 0 && this.homeFeature == 10) {
                    SportPage(onBack: { => this.homeFeature = 0 })
                } else if (this.selected == 0 && this.homeFeature == 11) {
                    ExperimentPage(onBack: { => this.homeFeature = 0 })
                } else if (this.selected == 0) {
                    AlignedCampusPage(
                        previewMode: this.previewMode,
                        onSchedule: { => this.homeFeature = 8 },
                        onScore: { => this.homeFeature = 6 },
                        onExam: { => this.homeFeature = 7 },
                        onAttendance: { => this.homeFeature = 1 },
                        onEmptyClassroom: { => this.homeFeature = 2 },
                        onLibrary: { => this.homeFeature = 3 },
                        onSchoolnet: { => this.homeFeature = 4 },
                        onDormWater: { => this.homeFeature = 5 },
                        onSchoolCard: { => this.homeFeature = 9 },
                        onSport: { => this.homeFeature = 10 },
                        onExperiment: { => this.homeFeature = 11 }
                    )
                } else if (this.selected == 1) {
                    AlignedRuisiPage(onOpenToolbox: { => this.selectPage(2) })
                } else if (this.selected == 2) {
                    AlignedToolboxPage()
                } else if (this.selected == 3) {
                    AlignedPigPage()
                } else {
                    AlignedSettingsPage(account: this.account, onLogout: this.onLogout)
                }
            }.width(100.percent).layoutWeight(1)
            Row {
                AlignedNavItem(icon: @r(app.media.nav_school), label: "校園信息", index: 0, selectedIndex: this.selected, onTap: { => this.selectPage(0) }, stableId: "navTo_home")
                AlignedNavItem(icon: @r(app.media.nav_forum), label: "睿思論壇", index: 1, selectedIndex: this.selected, onTap: { => this.selectPage(1) }, stableId: "navTo_ruisi")
                AlignedNavItem(icon: @r(app.media.nav_tools), label: "其他功能", index: 2, selectedIndex: this.selected, onTap: { => this.selectPage(2) }, stableId: "navTo_toolbox")
                AlignedNavItem(icon: @r(app.media.nav_pig), label: "豬圖鑑賞", index: 3, selectedIndex: this.selected, onTap: { => this.selectPage(3) }, stableId: "navTo_pig")
                AlignedNavItem(icon: @r(app.media.nav_user), label: "設置", index: 4, selectedIndex: this.selected, onTap: { => this.selectPage(4) }, stableId: "navTo_settings")
            }.width(100.percent).height(88.vp).padding(left: 3.vp, right: 3.vp, top: 5.vp, bottom: 3.vp)
                .backgroundColor(0xFFF3F3FB).border(width: 1.vp, color: 0xFFE1E1EA)
        }.width(100.percent).height(100.percent).backgroundColor(0xFFFAF9FF)
    }
}

@Component
class AlignedNavItem {
    let icon: AppResource
    let label: String
    let index: Int64
    @Prop var selectedIndex: Int64
    let onTap: () -> Unit
    let stableId: String
    func build() {
        Column {
            Row {
                Image(this.icon).width(25.vp).height(25.vp).objectFit(ImageFit.Contain)
                    .fillColor(if (this.selectedIndex == this.index) { 0xFFFFFFFF } else { 0xFF4D515B })
            }.width(58.vp).height(34.vp).justifyContent(FlexAlign.Center)
                .backgroundColor(if (this.selectedIndex == this.index) { 0xFF476FA9 } else { 0xFFF3F3FB }).borderRadius(17.vp)
            Text(this.label).fontSize(12.vp).fontColor(if (this.selectedIndex == this.index) { 0xFF41699F } else { 0xFF3F434C })
                .fontWeight(if (this.selectedIndex == this.index) { FontWeight.Medium } else { FontWeight.Normal }).margin(top: 4.vp)
        }.layoutWeight(1).height(78.vp).justifyContent(FlexAlign.Center).onClick({ _ => this.onTap() }).id(this.stableId)
    }
}

@Component
class AlignedCampusPage {
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
    @State var editMode: Bool = false

    func build() {
        Column {
            Row {
                Text("校園信息查詢").fontSize(22.vp).fontWeight(FontWeight.Medium).fontColor(0xFF202229).layoutWeight(1)
                Image(if (this.editMode) { @r(app.media.action_check) } else { @r(app.media.action_edit) })
                    .width(24.vp).height(24.vp).fillColor(0xFF3E424B).padding(6.vp)
                    .onClick({ _ => this.editMode = !this.editMode }).id("homeEditLayout")
            }.width(100.percent).height(58.vp).padding(left: 20.vp, right: 17.vp)
            Scroll {
                Column {
                    Column {
                        Text("目前您正在運行測試版").fontSize(14.vp).fontColor(0xFF454953)
                    }.width(100.percent).height(40.vp).justifyContent(FlexAlign.Center).backgroundColor(0xFFF6F6FE)
                        .border(width: 1.vp, color: 0xFFDDDDE7).borderRadius(14.vp).id("mockPreviewBanner")
                    Column {
                        Row {
                            Text("部分加載中").fontSize(12.vp).fontWeight(FontWeight.Bold).fontColor(0xFFD6E4FF)
                                .padding(left: 15.vp, right: 15.vp, top: 8.vp, bottom: 8.vp).backgroundColor(0xFF476FA9).borderRadius(12.vp)
                            Text("其他實驗加載失敗").fontSize(12.vp).fontWeight(FontWeight.Bold).fontColor(0xFFFFFFFF)
                                .padding(left: 15.vp, right: 15.vp, top: 8.vp, bottom: 8.vp).margin(left: 9.vp).backgroundColor(0xFFD51F1F).borderRadius(12.vp)
                        }.width(100.percent).height(48.vp).justifyContent(FlexAlign.Center)
                        Row {
                            Image(@r(app.media.home_calendar)).width(30.vp).height(30.vp).fillColor(0xFF41699F).margin(left: 16.vp, right: 15.vp)
                            Column {
                                Text("今日安排完成").fontSize(20.vp).fontColor(0xFF474B55)
                                Text("正在加載").fontSize(13.vp).fontColor(0xFF454953).margin(top: 1.vp)
                            }.layoutWeight(1).alignItems(HorizontalAlign.Start)
                        }.width(100.percent).height(55.vp).onClick({ _ => this.onSchedule() })
                        Text("正在加載日程").width(100.percent).height(34.vp).textAlign(TextAlign.Center).fontSize(14.vp).fontWeight(FontWeight.Medium)
                            .fontColor(0xFF41699F).backgroundColor(0xFFE1E7F4).borderRadius(8.vp).margin(left: 14.vp, right: 14.vp, bottom: 11.vp)
                    }.width(100.percent).height(148.vp).margin(top: 10.vp).backgroundColor(0xFFF6F6FE)
                        .border(width: 1.vp, color: 0xFFDDDDE7).borderRadius(14.vp).id("homeScheduleCard")
                    AlignedInfoCard(icon: @r(app.media.home_flash), value: "電量查詢失敗", note: "欠費查詢網絡故障", showQr: false, onTap: this.onDormWater, testId: "homeDormWaterInfo")
                    AlignedInfoCard(icon: @r(app.media.home_book), value: if (this.previewMode) { "借書 1 本" } else { "正在獲取借書信息" }, note: if (this.previewMode) { "待歸還 1 本書籍" } else { "正在查詢信息中" }, showQr: false, onTap: this.onLibrary, testId: "homeLibraryInfo")
                    AlignedInfoCard(icon: @r(app.media.home_wallet), value: if (this.previewMode) { "未登錄" } else { "正在獲取校園卡信息" }, note: "查看餘額、流水與付款碼", showQr: true, onTap: this.onSchoolCard, testId: "homeSchoolCard")
                    Row {
                        AlignedSmallCard(icon: @r(app.media.home_score), title: "成績查詢", onTap: this.onScore, stableId: "homeScore")
                        AlignedSmallCard(icon: @r(app.media.home_exam), title: "考試安排", onTap: this.onExam, stableId: "homeExam")
                        AlignedSmallCard(icon: @r(app.media.home_room), title: "空閒教室", onTap: this.onEmptyClassroom, stableId: "homeEmptyClassroom")
                        AlignedSmallCard(icon: @r(app.media.home_attendance), title: "考勤查詢", onTap: this.onAttendance, stableId: "homeAttendance")
                    }.width(100.percent).height(78.vp).margin(top: 8.vp)
                    Row {
                        AlignedSmallCard(icon: @r(app.media.home_network), title: "網絡查詢", onTap: this.onSchoolnet, stableId: "homeSchoolnet")
                        AlignedSmallCard(icon: @r(app.media.home_water), title: "宿舍水機", onTap: this.onDormWater, stableId: "homeDormWater")
                        AlignedSmallCard(icon: @r(app.media.home_experiment), title: "實驗信息", onTap: this.onExperiment, stableId: "homeExperiment")
                        AlignedSmallCard(icon: @r(app.media.home_sport), title: "體育信息", onTap: this.onSport, stableId: "homeSport")
                    }.width(100.percent).height(78.vp).margin(top: 8.vp)
                    if (this.editMode) { Text("日程信息和軟件升級信息不允許編輯").width(100.percent).textAlign(TextAlign.Center).fontSize(12.vp).fontColor(0xFF526070).margin(top: 10.vp) }
                    Blank().height(20.vp)
                }.width(100.percent).padding(left: 16.vp, right: 16.vp, top: 11.vp).alignItems(HorizontalAlign.Start)
            }.width(100.percent).layoutWeight(1).align(Alignment.TopStart)
        }.width(100.percent).height(100.percent).backgroundColor(0xFFFAF9FF)
    }
}

@Component
class AlignedInfoCard {
    let icon: AppResource
    let value: String
    let note: String
    let showQr: Bool
    let onTap: () -> Unit
    let testId: String
    func build() {
        Row {
            Image(this.icon).width(30.vp).height(30.vp).fillColor(0xFF41699F).margin(left: 14.vp, right: 17.vp)
            Column { Text(this.value).fontSize(19.vp).fontColor(0xFF474B55); Text(this.note).fontSize(13.vp).fontColor(0xFF454953).margin(top: 3.vp) }
                .layoutWeight(1).alignItems(HorizontalAlign.Start)
            if (this.showQr) {
                Row { Image(@r(app.media.home_qr)).width(19.vp).height(19.vp).fillColor(0xFF4D5565) }
                    .width(40.vp).height(40.vp).justifyContent(FlexAlign.Center).backgroundColor(0xFFF1F4FD).borderRadius(20.vp)
            }
        }.width(100.percent).height(68.vp).padding(right: 14.vp).margin(top: 8.vp).backgroundColor(0xFFF6F6FE)
            .border(width: 1.vp, color: 0xFFDDDDE7).borderRadius(14.vp).onClick({ _ => this.onTap() }).id(this.testId)
    }
}

@Component
class AlignedSmallCard {
    let icon: AppResource
    let title: String
    let onTap: () -> Unit
    let stableId: String
    func build() {
        Column {
            Image(this.icon).width(29.vp).height(29.vp).fillColor(0xFF41699F)
            Text(this.title).fontSize(12.vp).fontColor(0xFF3F434C).margin(top: 6.vp).textAlign(TextAlign.Center)
        }.layoutWeight(1).height(78.vp).margin(left: 3.vp, right: 3.vp).justifyContent(FlexAlign.Center).backgroundColor(0xFFF6F6FE)
            .border(width: 1.vp, color: 0xFFDDDDE7).borderRadius(13.vp).onClick({ _ => this.onTap() }).id(this.stableId)
    }
}

@Component
class AlignedRuisiPage {
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
                Text("最新发布").layoutWeight(1).textAlign(TextAlign.Center).fontSize(13.vp).fontWeight(if (this.tab == 0) { FontWeight.Bold } else { FontWeight.Normal }).padding(12.vp).onClick({ _ => this.tab = 0 }).id("ruisiTabNew")
                Text("最新回复").layoutWeight(1).textAlign(TextAlign.Center).fontSize(13.vp).fontWeight(if (this.tab == 1) { FontWeight.Bold } else { FontWeight.Normal }).padding(12.vp).onClick({ _ => this.tab = 1 }).id("ruisiTabReply")
                Text("水漫金山").layoutWeight(1).textAlign(TextAlign.Center).fontSize(13.vp).fontWeight(if (this.tab == 2) { FontWeight.Bold } else { FontWeight.Normal }).padding(12.vp).onClick({ _ => this.tab = 2 }).id("ruisiTabWater")
                Text("摄影交流").layoutWeight(1).textAlign(TextAlign.Center).fontSize(13.vp).fontWeight(if (this.tab == 3) { FontWeight.Bold } else { FontWeight.Normal }).padding(12.vp).onClick({ _ => this.tab = 3 }).id("ruisiTabPhoto")
            }.width(100.percent).height(46.vp).backgroundColor(0xFFFFFFFF).border(width: 1.vp, color: 0xFFE1E5EC)
            Column {
                Text("▣").fontSize(64.vp).fontColor(0xFF9AA5B5)
                Text("睿思会话尚未登录").fontSize(18.vp).fontWeight(FontWeight.Bold).margin(top: 16.vp)
                Text("请先通过工具箱的睿思入口完成网页登录，\n登录后即可同步论坛帖子。").fontSize(13.vp).fontColor(0xFF526070).textAlign(TextAlign.Center).margin(top: 10.vp)
                Button("前往工具箱").margin(top: 18.vp).backgroundColor(0xFFD0E4FF).fontColor(0xFF253A5E).onClick({ _ => this.onOpenToolbox() }).id("ruisiOpenToolbox")
            }.width(100.percent).layoutWeight(1).justifyContent(FlexAlign.Center)
        }.width(100.percent).height(100.percent)
    }
}

@Component
class AlignedToolboxPage {
    @State var showWeb: Bool = false
    @State var title: String = ""
    @State var url: String = ""

    func open(name: String, url: String): Unit {
        this.title = name
        this.url = url
        this.showWeb = true
    }

    func build() {
        if (this.showWeb) {
            ToolboxWebPage(title: this.title, url: this.url, onClose: { => this.showWeb = false })
        } else {
            Column {
                Row {
                    Text("其他功能").fontSize(22.vp).fontWeight(FontWeight.Medium).fontColor(0xFF202229).layoutWeight(1)
                }.width(100.percent).height(58.vp).padding(left: 20.vp, right: 16.vp)
                Scroll { Column {
                    AlignedToolRow(icon: @r(app.media.toolbox_payment), title: "繳費系統", description: "電費該交了吧", stableId: "toolboxPayment", onTap: { => this.open("繳費系統", "https://xxcapp.xidian.edu.cn/uc/api/oauth/index?redirect=https://ignypt.xidian.edu.cn/revenueH5/login?opcode=MPAY&appid=200260318155520600&state=1231231231") })
                    AlignedToolRow(icon: @r(app.media.toolbox_water), title: "訂水系統", description: "喝水對身體好", stableId: "toolboxWater", onTap: { => this.open("訂水系統", "https://order.xidian.edu.cn/mobile/thirdoauth/oauth2Xidian/1") })
                    AlignedToolRow(icon: @r(app.media.toolbox_repair), title: "後勤報修", description: "不要漏水斷網", stableId: "toolboxRepair", onTap: { => this.open("後勤報修", "https://ids.xidian.edu.cn/authserver/login?service=https%3A%2F%2Fids.xidian.edu.cn%2Fauthserver%2Foauth2.0%2FcallbackAuthorize%3Fclient_id%3D869608421533880320%26redirect_uri%3Dhttp%253A%252F%252Frepair.xidian.edu.cn%252Fappsys%252FxidianCasLogin%252FoauthLogin%26response_type%3Dcode%26state%3Dhome%26client_name%3DCasOAuthClient") })
                    AlignedToolRow(icon: @r(app.media.toolbox_reserve), title: "空間預約", description: "找個地方打牌", stableId: "toolboxReserve", onTap: { => this.open("空間預約", "http://libspace.xidian.edu.cn") })
                    AlignedToolRow(icon: @r(app.media.toolbox_network), title: "網絡查詢", description: "希望永不收費", stableId: "toolboxNetwork", onTap: { => this.open("網絡查詢", "https://zfw.xidian.edu.cn") })
                    AlignedToolRow(icon: @r(app.media.toolbox_calculator), title: "物理計算", description: "希望操作順利", stableId: "toolboxPhysics", onTap: { => this.open("物理計算", "https://experiment-helper.wizzstudio.com/#/") })
                    AlignedToolRow(icon: @r(app.media.toolbox_discover), title: "睿思導航", description: "補充其他功能", stableId: "toolboxDiscover", onTap: { => this.open("睿思導航", "https://nav.xdruisi.cn/") })
                    Blank().height(12.vp)
                }.width(100.percent) }.width(100.percent).layoutWeight(1).align(Alignment.TopStart)
            }.width(100.percent).height(100.percent).backgroundColor(0xFFFFFFFF)
        }
    }
}
@Component
class AlignedToolRow {
    let icon: AppResource
    let title: String
    let description: String
    let stableId: String
    let onTap: () -> Unit
    func build() {
        Row {
            Image(this.icon).width(25.vp).height(25.vp).objectFit(ImageFit.Contain).fillColor(0xFF50545E)
            Column {
                Text(this.title).fontSize(16.vp).fontWeight(FontWeight.Normal).fontColor(0xFF22242A)
                Text(this.description).fontSize(14.vp).fontColor(0xFF545965).margin(top: 4.vp)
            }.layoutWeight(1).margin(left: 16.vp).alignItems(HorizontalAlign.Start)
        }.width(100.percent).height(72.vp).padding(left: 18.vp, right: 18.vp).backgroundColor(0xFFFFFFFF)
            .onClick({ _ => this.onTap() }).id(this.stableId)
    }
}

@Component
class AlignedPigPage {
    let session: PigHubSession = PigHubSession()
    @State var imageUrl: String = ""
    @State var title: String = ""
    @State var loading: Bool = false
    @State var imageLoading: Bool = false
    @State var errorMessage: String = ""
    @State var saveHint: String = ""

    protected override func aboutToAppear(): Unit { this.loadPig(true) }

    func loadPig(forceRefresh: Bool): Unit {
        if (this.loading) { return }
        this.loading = true
        this.errorMessage = ""
        this.saveHint = ""
        this.session.getRandomPig(forceRefresh,
            { pig => launch {
                this.imageUrl = pig.url
                this.title = pig.title
                this.imageLoading = true
                this.loading = false
            } },
            { message => launch {
                this.loading = false
                this.imageLoading = false
                this.errorMessage = message
            } }
        )
    }

    func imageLoaded(): Unit { this.imageLoading = false }
    func imageFailed(): Unit {
        this.imageLoading = false
        this.errorMessage = "豬圖加載失敗，請重試。"
    }

    func build() {
        Column {
            Row {
                Text("豬圖鑑賞").fontSize(22.vp).fontWeight(FontWeight.Medium).fontColor(0xFF202229).layoutWeight(1)
                Image(@r(app.media.action_refresh)).width(27.vp).height(27.vp).fillColor(0xFF4A4E58).padding(6.vp)
                    .onClick({ _ => this.loadPig(true) }).id("pigRefresh")
            }.width(100.percent).height(58.vp).padding(left: 20.vp, right: 17.vp)
            Column {
                Text("本程序將開發一個新主頁，目前先用豬圖秀佔位，玩得愉快")
                    .width(100.percent).fontSize(14.vp).fontColor(0xFF22242A).textAlign(TextAlign.Center)
                if (this.loading) {
                    Column {
                        LoadingProgress().width(42.vp).height(42.vp).color(0xFF476FA9)
                        Text("正在尋找一隻豬…").fontSize(14.vp).fontColor(0xFF545965).margin(top: 14.vp).id("pigLoadStatus")
                    }.width(300.vp).height(330.vp).justifyContent(FlexAlign.Center)
                } else if (this.errorMessage != "") {
                    Column {
                        Text("!").width(52.vp).height(52.vp).fontSize(34.vp).fontWeight(FontWeight.Bold).fontColor(0xFF6A6F79)
                            .textAlign(TextAlign.Center).border(width: 2.vp, color: 0xFF6A6F79).borderRadius(26.vp)
                        Text("Failed to fetch a pig :(").fontSize(17.vp).fontWeight(FontWeight.Medium).margin(top: 14.vp)
                        Text(this.errorMessage).width(100.percent).fontSize(12.vp).fontColor(0xFF646A75).textAlign(TextAlign.Center).margin(top: 8.vp).id("pigError")
                        Row { Image(@r(app.media.action_refresh)).width(19.vp).height(19.vp).fillColor(0xFFFFFFFF); Text("Try Again").fontSize(14.vp).fontColor(0xFFFFFFFF).margin(left: 8.vp) }
                            .width(150.vp).height(42.vp).justifyContent(FlexAlign.Center).backgroundColor(0xFF476FA9).borderRadius(21.vp)
                            .margin(top: 16.vp).onClick({ _ => this.loadPig(true) }).id("pigTryAgain")
                    }.width(100.percent).height(390.vp).justifyContent(FlexAlign.Center)
                } else {
                    Stack {
                        Image(this.imageUrl).width(300.vp).height(300.vp).objectFit(ImageFit.Contain).borderRadius(12.vp)
                            .onComplete({ _ => this.imageLoaded() }).onError({ _ => this.imageFailed() }).id("pigImage")
                        if (this.imageLoading) {
                            LoadingProgress().width(42.vp).height(42.vp).color(0xFF476FA9)
                        }
                    }.width(300.vp).height(300.vp).margin(top: 12.vp)
                    Text(this.title).fontSize(16.vp).fontColor(0xFF22242A).textAlign(TextAlign.Center).margin(top: 8.vp).id("pigTitle")
                    Row { Image(@r(app.media.action_shuffle)).width(19.vp).height(19.vp).fillColor(0xFF41699F); Text("Change A Pig").fontSize(14.vp).fontColor(0xFF41699F).margin(left: 9.vp) }
                        .width(170.vp).height(42.vp).justifyContent(FlexAlign.Center).border(width: 1.vp, color: 0xFF41699F).borderRadius(12.vp)
                        .margin(top: 24.vp).onClick({ _ => this.loadPig(false) }).id("pigShuffle")
                    Row { Image(@r(app.media.action_save)).width(19.vp).height(19.vp).fillColor(0xFF41699F); Text("Save this Pig").fontSize(14.vp).fontColor(0xFF41699F).margin(left: 9.vp) }
                        .width(170.vp).height(42.vp).justifyContent(FlexAlign.Center).border(width: 1.vp, color: 0xFF41699F).borderRadius(12.vp)
                        .margin(top: 9.vp).onClick({ _ => this.saveHint = "請長按圖片使用系統圖片菜單保存" }).id("pigSave")
                    if (this.saveHint != "") { Text(this.saveHint).fontSize(11.vp).fontColor(0xFF646A75).margin(top: 8.vp).id("pigSaveHint") }
                }
            }.width(100.percent).layoutWeight(1).padding(left: 24.vp, right: 24.vp).justifyContent(FlexAlign.Center).alignItems(HorizontalAlign.Center)
        }.width(100.percent).height(100.percent).backgroundColor(0xFFFFFFFF)
    }
}

@Component
class AlignedSettingsPage {
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
        let stored = if (value == "白天模式") { "Light" } else if (value == "黑夜模式") { "Dark" } else { "System" }
        SessionStore().saveDisplaySettings(this.storedLanguage(), stored)
    }

    func storedLanguage(): String {
        return if (this.language == "繁體中文") { "Traditional Chinese" } else if (this.language == "English") { "English" } else { "Chinese" }
    }

    func toggleTimeline(value: Bool): Unit {
        this.timeline = value
        SessionStore().saveSetting("timeline", if (value) { "开启" } else { "关闭" })
    }

    func toggleLowElectricity(value: Bool): Unit {
        this.lowElectricityWarning = value
        SessionStore().saveSetting("lowElectricityEnabled", if (value) { "开启" } else { "关闭" })
    }

    func cycleColor(): Unit {
        this.colorName = if (this.colorName == "默認顏色") { "聰明藍" } else if (this.colorName == "聰明藍") { "春風綠" } else if (this.colorName == "春風綠") { "明日香橙" } else { "默認顏色" }
        SessionStore().saveSetting("color", this.colorName)
    }

    func cycleLanguage(): Unit {
        this.language = if (this.language == "繁體中文") { "English" } else if (this.language == "English") { "簡體中文" } else { "繁體中文" }
        SessionStore().saveDisplaySettings(this.storedLanguage(), if (this.theme == "白天模式") { "Light" } else if (this.theme == "黑夜模式") { "Dark" } else { "System" })
    }

    func cycleThreshold(): Unit {
        this.lowElectricityThreshold = if (this.lowElectricityThreshold == "20") { "15" } else if (this.lowElectricityThreshold == "15") { "10" } else { "20" }
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
                        AlignedSettingRow(title: "關於本程序", subtitle: "版本號：1.0.0+1", showDivider: true, onTap: { => this.unavailable("關於本程序") })
                        AlignedSettingRow(title: "檢查軟件更新", subtitle: "最新版本：等待獲取", showDivider: false, onTap: { => this.unavailable("軟件更新") })
                    }.width(100.percent).backgroundColor(0xFFF7F7FF).borderRadius(bottomLeft: 14.vp, bottomRight: 14.vp)

                    Column {
                        AlignedSettingsSectionHeader(title: "界面設置")
                        Column {
                            AlignedSettingRow(title: "顏色設置", subtitle: this.colorName, showDivider: true, onTap: { => this.cycleColor() })
                            AlignedBrightnessRow(theme: this.theme, onSystem: { => this.saveTheme("跟隨系統") }, onLight: { => this.saveTheme("白天模式") }, onDark: { => this.saveTheme("黑夜模式") })
                            AlignedSettingToggleRow(title: "簡化日程時間軸", subtitle: "沒有日程時 減少空間佔用", isOn: this.timeline, showDivider: true, stableId: "settingsTimelineToggle", onChange: { value => this.toggleTimeline(value) })
                            AlignedSettingToggleRow(title: "低電量卡片變色提醒", subtitle: "電量小於閾值時 電量卡片變色提醒", isOn: this.lowElectricityWarning, showDivider: true, stableId: "settingsLowElectricityToggle", onChange: { value => this.toggleLowElectricity(value) })
                            AlignedSettingRow(title: "低電量閾值", subtitle: "目前為 ${this.lowElectricityThreshold} 度", showDivider: true, onTap: { => this.cycleThreshold() })
                            AlignedSettingRow(title: "修改語言", subtitle: this.language, showDivider: false, onTap: { => this.cycleLanguage() })
                        }.width(100.percent).backgroundColor(0xFFF7F7FF).borderRadius(bottomLeft: 14.vp, bottomRight: 14.vp)
                    }.width(100.percent).margin(top: 8.vp)

                    Column {
                        AlignedSettingsSectionHeader(title: "賬號設置")
                        Column {
                            AlignedSettingRow(title: "體育系統密碼設置", subtitle: "", showDivider: true, onTap: { => this.unavailable("體育系統密碼設置") })
                            AlignedSettingRow(title: "物理實驗系統密碼設置", subtitle: "", showDivider: true, onTap: { => this.unavailable("物理實驗系統密碼設置") })
                            AlignedSettingRow(title: "校園網帳號密碼設置", subtitle: "不設置查看不了網費", showDivider: true, onTap: { => this.unavailable("校園網帳號密碼設置") })
                            AlignedSettingRow(title: "空調用電數據源", subtitle: "未設置，電費頁不顯示空調用電", showDivider: false, onTap: { => this.unavailable("空調用電數據源") })
                        }.width(100.percent).backgroundColor(0xFFF7F7FF).borderRadius(bottomLeft: 14.vp, bottomRight: 14.vp)
                    }.width(100.percent).margin(top: 8.vp)

                    Column {
                        AlignedSettingsSectionHeader(title: "課表相關設置")
                        Column {
                            AlignedSettingToggleRow(title: "開啟課表背景圖", subtitle: "", isOn: false, showDivider: true, stableId: "settingsBackgroundToggle", onChange: { _: Bool => this.unavailable("課表背景圖") })
                            AlignedSettingRow(title: "課表背景圖選擇", subtitle: "", showDivider: true, onTap: { => this.unavailable("課表背景圖選擇") })
                            AlignedSettingRow(title: "清除所有用戶添加課程", subtitle: "", showDivider: true, onTap: { => this.unavailable("清除用戶課程") })
                            AlignedSettingRow(title: "強制刷新課表", subtitle: "", showDivider: true, onTap: { => this.unavailable("強制刷新課表") })
                            AlignedSettingRow(title: "課程偏移設置", subtitle: "正數錯後開學日期 負數提前開學日期\n目前為 0", showDivider: true, onTap: { => this.unavailable("課程偏移設置") })
                            AlignedSettingRow(title: "修改學期", subtitle: this.semester, showDivider: false, onTap: { => this.unavailable("修改學期") })
                        }.width(100.percent).backgroundColor(0xFFF7F7FF).borderRadius(bottomLeft: 14.vp, bottomRight: 14.vp)
                    }.width(100.percent).margin(top: 8.vp)

                    Column {
                        AlignedSettingsSectionHeader(title: "緩存登錄設置")
                        Column {
                            AlignedSettingRow(title: "查看網絡攔截器和日誌", subtitle: "", showDivider: true, onTap: { => this.unavailable("日誌查看") })
                            AlignedSettingRow(title: "清除緩存後重啟", subtitle: "", showDivider: true, onTap: { => this.unavailable("緩存清理") })
                            AlignedSettingRow(title: "退出登錄並重啟應用", subtitle: "", showDivider: false, onTap: this.onLogout)
                        }.width(100.percent).backgroundColor(0xFFF7F7FF).borderRadius(bottomLeft: 14.vp, bottomRight: 14.vp)
                    }.width(100.percent).margin(top: 8.vp)
                    if (this.migrationHint != "") {
                        Text(this.migrationHint).width(100.percent).textAlign(TextAlign.Center).fontSize(12.vp).fontColor(0xFF5B6370)
                            .padding(top: 10.vp, bottom: 10.vp).id("settingsMigrationHint")
                    }
                    Blank().height(12.vp)
                }.width(100.percent).padding(left: 17.vp, right: 17.vp).alignItems(HorizontalAlign.Start)
            }.width(100.percent).height(100.percent).align(Alignment.TopStart)
        }.width(100.percent).height(100.percent).backgroundColor(0xFFFFFFFF)
    }
}

@Component
class AlignedSettingsSectionHeader {
    let title: String
    func build() {
        Row {
            Text(this.title).fontSize(16.vp).fontWeight(FontWeight.Bold).fontColor(0xFFFFFFFF)
        }.width(100.percent).height(44.vp).justifyContent(FlexAlign.Center).backgroundColor(0xFF476FA9)
            .borderRadius(topLeft: 14.vp, topRight: 14.vp)
    }
}

@Component
class AlignedSettingRow {
    let title: String
    let subtitle: String
    let showDivider: Bool
    let onTap: () -> Unit
    func build() {
        Column {
            Row {
                Column {
                    Text(this.title).fontSize(16.vp).fontColor(0xFF202229)
                    if (this.subtitle != "") { Text(this.subtitle).fontSize(14.vp).fontColor(0xFF565C67).margin(top: 3.vp) }
                }.layoutWeight(1).alignItems(HorizontalAlign.Start)
                Text("›").fontSize(30.vp).fontColor(0xFF4F5662).margin(left: 8.vp)
            }.width(100.percent).height(if (this.subtitle.contains("\n")) { 94.vp } else { 82.vp }).padding(left: 20.vp, right: 28.vp)
                .onClick({ _ => this.onTap() })
            if (this.showDivider) { Divider().color(0xFFD9DAE2).strokeWidth(1.vp).margin(left: 14.vp, right: 14.vp) }
        }.width(100.percent)
    }
}

@Component
class AlignedSettingToggleRow {
    let title: String
    let subtitle: String
    let isOn: Bool
    let showDivider: Bool
    let stableId: String
    let onChange: (Bool) -> Unit
    func build() {
        Column {
            Row {
                Column {
                    Text(this.title).fontSize(16.vp).fontColor(0xFF202229)
                    if (this.subtitle != "") { Text(this.subtitle).fontSize(14.vp).fontColor(0xFF565C67).margin(top: 3.vp) }
                }.layoutWeight(1).alignItems(HorizontalAlign.Start)
                Toggle(ToggleType.Switch, isOn: this.isOn).width(56.vp).height(34.vp).selectedColor(0xFF476FA9)
                    .switchPointColor(0xFFFFFFFF).onChange({ value => this.onChange(value) }).margin(left: 10.vp, right: 18.vp).id(this.stableId)
            }.width(100.percent).height(82.vp).padding(left: 20.vp)
            if (this.showDivider) { Divider().color(0xFFD9DAE2).strokeWidth(1.vp).margin(left: 14.vp, right: 14.vp) }
        }.width(100.percent)
    }
}

@Component
class AlignedBrightnessRow {
    let theme: String
    let onSystem: () -> Unit
    let onLight: () -> Unit
    let onDark: () -> Unit
    func build() {
        Column {
            Row {
                Column {
                    Text("設置深淺色").fontSize(16.vp).fontColor(0xFF202229)
                    Text(this.theme).fontSize(14.vp).fontColor(0xFF565C67).margin(top: 3.vp)
                }.layoutWeight(1).alignItems(HorizontalAlign.Start)
                Row {
                    Text("▯").width(38.vp).height(38.vp).textAlign(TextAlign.Center).fontSize(21.vp)
                        .fontColor(if (this.theme == "跟隨系統") { 0xFFFFFFFF } else { 0xFF476FA9 })
                        .backgroundColor(if (this.theme == "跟隨系統") { 0xFF476FA9 } else { 0xFFF7F7FF }).onClick({ _ => this.onSystem() }).id("settingsThemeSystem")
                    Text("☼").width(38.vp).height(38.vp).textAlign(TextAlign.Center).fontSize(20.vp)
                        .fontColor(if (this.theme == "白天模式") { 0xFFFFFFFF } else { 0xFF476FA9 })
                        .backgroundColor(if (this.theme == "白天模式") { 0xFF476FA9 } else { 0xFFF7F7FF }).onClick({ _ => this.onLight() }).id("settingsThemeLight")
                    Text("◕").width(38.vp).height(38.vp).textAlign(TextAlign.Center).fontSize(18.vp)
                        .fontColor(if (this.theme == "黑夜模式") { 0xFFFFFFFF } else { 0xFF476FA9 })
                        .backgroundColor(if (this.theme == "黑夜模式") { 0xFF476FA9 } else { 0xFFF7F7FF }).onClick({ _ => this.onDark() }).id("settingsThemeDark")
                }.height(38.vp).border(width: 1.vp, color: 0xFF476FA9).borderRadius(19.vp).clip(true).margin(right: 18.vp)
            }.width(100.percent).height(82.vp).padding(left: 20.vp)
            Divider().color(0xFFD9DAE2).strokeWidth(1.vp).margin(left: 14.vp, right: 14.vp)
        }.width(100.percent)
    }
}
