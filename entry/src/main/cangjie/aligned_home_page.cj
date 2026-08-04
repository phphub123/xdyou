package ohos_app_cangjie_entry

import kit.ArkUI.*
import kit.ArkWeb.*
import ohos.arkui.state_macro_manage.*
import ohos.business_exception.*
import ohos.resource.*

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
                        onSchoolCard: { => this.homeFeature = 9 }
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
                AlignedNavItem(icon: @r(app.media.nav_school), label: "校園信息", selected: this.selected == 0, onTap: { => this.selectPage(0) }, stableId: "navTo_home")
                AlignedNavItem(icon: @r(app.media.nav_forum), label: "睿思論壇", selected: this.selected == 1, onTap: { => this.selectPage(1) }, stableId: "navTo_ruisi")
                AlignedNavItem(icon: @r(app.media.nav_tools), label: "其他功能", selected: this.selected == 2, onTap: { => this.selectPage(2) }, stableId: "navTo_toolbox")
                AlignedNavItem(icon: @r(app.media.nav_pig), label: "豬圖鑑賞", selected: this.selected == 3, onTap: { => this.selectPage(3) }, stableId: "navTo_pig")
                AlignedNavItem(icon: @r(app.media.nav_user), label: "設置", selected: this.selected == 4, onTap: { => this.selectPage(4) }, stableId: "navTo_settings")
            }.width(100.percent).height(88.vp).padding(left: 3.vp, right: 3.vp, top: 5.vp, bottom: 3.vp)
                .backgroundColor(0xFFF3F3FB).border(width: 1.vp, color: 0xFFE1E1EA)
        }.width(100.percent).height(100.percent).backgroundColor(0xFFFAF9FF)
    }
}

@Component
class AlignedNavItem {
    let icon: AppResource
    let label: String
    let selected: Bool
    let onTap: () -> Unit
    let stableId: String
    func build() {
        Column {
            Row {
                Image(this.icon).width(25.vp).height(25.vp).objectFit(ImageFit.Contain)
                    .fillColor(if (this.selected) { 0xFFFFFFFF } else { 0xFF4D515B })
            }.width(58.vp).height(34.vp).justifyContent(FlexAlign.Center)
                .backgroundColor(if (this.selected) { 0xFF476FA9 } else { 0x00FFFFFF }).borderRadius(17.vp)
            Text(this.label).fontSize(12.vp).fontColor(if (this.selected) { 0xFF41699F } else { 0xFF3F434C })
                .fontWeight(if (this.selected) { FontWeight.Medium } else { FontWeight.Normal }).margin(top: 4.vp)
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
                        AlignedSmallCard(icon: @r(app.media.home_score), title: "成績查詢", onTap: this.onScore)
                        AlignedSmallCard(icon: @r(app.media.home_exam), title: "考試安排", onTap: this.onExam)
                        AlignedSmallCard(icon: @r(app.media.home_room), title: "空閒教室", onTap: this.onEmptyClassroom)
                        AlignedSmallCard(icon: @r(app.media.home_attendance), title: "考勤查詢", onTap: this.onAttendance)
                    }.width(100.percent).height(78.vp).margin(top: 8.vp)
                    Row {
                        AlignedSmallCard(icon: @r(app.media.home_network), title: "網絡查詢", onTap: this.onSchoolnet)
                        AlignedSmallCard(icon: @r(app.media.home_water), title: "宿舍水機", onTap: this.onDormWater)
                        AlignedSmallCard(icon: @r(app.media.home_experiment), title: "實驗信息", onTap: { => this.editMode = false })
                        AlignedSmallCard(icon: @r(app.media.home_sport), title: "體育信息", onTap: { => this.editMode = false })
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
    func build() {
        Column {
            Image(this.icon).width(29.vp).height(29.vp).fillColor(0xFF41699F)
            Text(this.title).fontSize(12.vp).fontColor(0xFF3F434C).margin(top: 6.vp).textAlign(TextAlign.Center)
        }.layoutWeight(1).height(78.vp).margin(left: 3.vp, right: 3.vp).justifyContent(FlexAlign.Center).backgroundColor(0xFFF6F6FE)
            .border(width: 1.vp, color: 0xFFDDDDE7).borderRadius(13.vp).onClick({ _ => this.onTap() })
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
    let webController = WebviewController()
    @State var showWeb: Bool = false
    @State var title: String = ""
    @State var status: String = ""

    func open(name: String, url: String): Unit {
        this.title = name
        this.status = "正在打开${name}…"
        this.showWeb = true
        try { this.webController.loadUrl(url) }
        catch (e: BusinessException) { this.status = "无法打开${name}：${e.code} ${e.message}" }
    }

    func build() {
        Column {
            Row {
                if (this.showWeb) { Text("‹").fontSize(30.vp).padding(right: 12.vp).onClick({ _ => this.showWeb = false }).id("toolboxBackToList") }
                Text(if (this.showWeb) { this.title } else { "校园工具箱" }).fontSize(22.vp).fontWeight(FontWeight.Bold).layoutWeight(1)
            }.width(100.percent).height(58.vp).padding(left: 18.vp, right: 14.vp)
            if (this.showWeb) {
                if (this.status != "") { Text(this.status).fontSize(12.vp).fontColor(0xFF526070).padding(left: 16.vp, bottom: 6.vp).id("toolboxStatus") }
                Web(src: "about:blank", controller: this.webController).onPageEnd({ _ => launch { this.status = "${this.title}加载完成。" } }).width(100.percent).layoutWeight(1).id("toolboxWeb")
            } else {
                Scroll { Column {
                    AlignedToolRow(icon: "元", title: "校园缴费", description: "支付电费、网费等校园费用", onTap: { => this.open("校园缴费", "https://xxcapp.xidian.edu.cn/uc/api/oauth/index") })
                    AlignedToolRow(icon: "水", title: "宿舍订水", description: "打开校园订水服务", onTap: { => this.open("宿舍订水", "https://order.xidian.edu.cn/mobile/thirdoauth/oauth2Xidian/1") })
                    AlignedToolRow(icon: "修", title: "校园报修", description: "宿舍与校园设施故障报修", onTap: { => this.open("校园报修", "https://repair.xidian.edu.cn") })
                    AlignedToolRow(icon: "座", title: "图书馆空间预约", description: "预约研讨室与学习空间", onTap: { => this.open("空间预约", "http://libspace.xidian.edu.cn") })
                    AlignedToolRow(icon: "Wi", title: "校园网络", description: "查询与管理校园网账号", onTap: { => this.open("校园网络", "https://zfw.xidian.edu.cn") })
                    AlignedToolRow(icon: "Σ", title: "物理实验计算", description: "实验数据计算辅助", onTap: { => this.open("物理实验计算", "https://experiment-helper.wizzstudio.com/#/") })
                    AlignedToolRow(icon: "◎", title: "睿思导航", description: "发现校内常用站点与服务", onTap: { => this.open("睿思导航", "https://nav.xdruisi.cn/") })
                    Blank().height(18.vp)
                }.width(100.percent) }.width(100.percent).layoutWeight(1).align(Alignment.TopStart)
            }
        }.width(100.percent).height(100.percent)
    }
}

@Component
class AlignedToolRow {
    let icon: String
    let title: String
    let description: String
    let onTap: () -> Unit
    func build() {
        Row {
            Text(this.icon).width(48.vp).height(48.vp).fontSize(18.vp).fontWeight(FontWeight.Bold).fontColor(0xFF3F5F90).textAlign(TextAlign.Center).backgroundColor(0xFFD0E4FF).borderRadius(24.vp)
            Column { Text(this.title).fontSize(16.vp).fontWeight(FontWeight.Bold); Text(this.description).fontSize(12.vp).fontColor(0xFF526070).margin(top: 5.vp) }.layoutWeight(1).margin(left: 14.vp).alignItems(HorizontalAlign.Start)
            Text("›").fontSize(24.vp).fontColor(0xFF7B8492)
        }.width(100.percent).height(76.vp).padding(left: 18.vp, right: 18.vp).backgroundColor(0xFFFFFFFF).border(width: 1.vp, color: 0xFFE8EBF0).onClick({ _ => this.onTap() })
    }
}

@Component
class AlignedPigPage {
    @State var message: String = "PigHub 图片服务尚未返回内容。"
    func retry(): Unit { this.message = "正在重新请求 PigHub…" }
    func build() {
        Column {
            Row { Text("猪图鉴赏").fontSize(22.vp).fontWeight(FontWeight.Bold).layoutWeight(1); Text("↻").fontSize(24.vp).padding(10.vp).onClick({ _ => this.retry() }).id("pigRefresh") }
                .width(100.percent).height(58.vp).padding(left: 18.vp, right: 8.vp)
            Scroll { Column {
                Text("本程序将开发一个新主页，目前先用猪图秀占位，玩得愉快").fontSize(14.vp).textAlign(TextAlign.Center).fontColor(0xFF526070)
                Column { Text("🐷").fontSize(96.vp); Text(this.message).fontSize(13.vp).fontColor(0xFF526070).textAlign(TextAlign.Center).margin(top: 12.vp) }
                    .width(100.percent).height(310.vp).margin(top: 18.vp).justifyContent(FlexAlign.Center).backgroundColor(0xFFE9F2FF).borderRadius(16.vp).id("pigImageState")
                Button("换一只猪").width(180.vp).margin(top: 20.vp).backgroundColor(0xFFD0E4FF).fontColor(0xFF253A5E).onClick({ _ => this.retry() }).id("pigShuffle")
                Button("保存这只猪").width(180.vp).margin(top: 10.vp).onClick({ _ => this.message = "暂无可保存的猪图。" }).id("pigSave")
            }.width(100.percent).padding(left: 24.vp, right: 24.vp, top: 18.vp).alignItems(HorizontalAlign.Center) }.width(100.percent).layoutWeight(1).align(Alignment.TopStart)
        }.width(100.percent).height(100.percent)
    }
}

@Component
class AlignedSettingsPage {
    let account: String
    let onLogout: () -> Unit
    @State var theme: String = "跟随系统"
    @State var timeline: Bool = true
    func build() {
        Column {
            Scroll { Column {
                Text("XDYou").fontSize(22.vp).fontWeight(FontWeight.Bold)
                Text("Written by BenderBlog Rodriguez and contributors").fontSize(12.vp).fontColor(0xFF526070).margin(top: 4.vp)
                Text("关于").width(100.percent).textAlign(TextAlign.Center).fontSize(14.vp).fontWeight(FontWeight.Bold).fontColor(0xFFFFFFFF).padding(10.vp).margin(top: 20.vp).backgroundColor(0xFF3F5F90).borderRadius(topLeft: 14.vp, topRight: 14.vp)
                AlignedSettingRow(title: "关于本程序", subtitle: "XDYou 仓颉 HarmonyOS 原生版", value: "›", onTap: { => () })
                AlignedSettingRow(title: "检查更新", subtitle: "当前版本 1.0.0", value: "›", onTap: { => () })
                Text("界面设置").width(100.percent).textAlign(TextAlign.Center).fontSize(14.vp).fontWeight(FontWeight.Bold).fontColor(0xFFFFFFFF).padding(10.vp).margin(top: 14.vp).backgroundColor(0xFF3F5F90).borderRadius(topLeft: 14.vp, topRight: 14.vp)
                AlignedSettingRow(title: "主题配色", subtitle: "默认蓝色", value: "›", onTap: { => () })
                AlignedSettingRow(title: "亮度设置", subtitle: this.theme, value: "日 夜", onTap: { => this.theme = if (this.theme == "跟随系统") { "浅色" } else if (this.theme == "浅色") { "深色" } else { "跟随系统" } })
                AlignedSettingRow(title: "简化课程时间轴", subtitle: "精简显示课程节次", value: if (this.timeline) { "开" } else { "关" }, onTap: { => this.timeline = !this.timeline })
                Text("课程表设置").width(100.percent).textAlign(TextAlign.Center).fontSize(14.vp).fontWeight(FontWeight.Bold).fontColor(0xFFFFFFFF).padding(10.vp).margin(top: 14.vp).backgroundColor(0xFF3F5F90).borderRadius(topLeft: 14.vp, topRight: 14.vp)
                AlignedSettingRow(title: "切换学期", subtitle: "当前学期 2026-1", value: "›", onTap: { => () })
                AlignedSettingRow(title: "上课提醒", subtitle: "通知与系统日历设置", value: "›", onTap: { => () })
                Text("账户与数据").width(100.percent).textAlign(TextAlign.Center).fontSize(14.vp).fontWeight(FontWeight.Bold).fontColor(0xFFFFFFFF).padding(10.vp).margin(top: 14.vp).backgroundColor(0xFF3F5F90).borderRadius(topLeft: 14.vp, topRight: 14.vp)
                AlignedSettingRow(title: "当前账号", subtitle: this.account, value: "", onTap: { => () })
                AlignedSettingRow(title: "退出登录", subtitle: "清除本地会话信息", value: "›", onTap: this.onLogout)
                Blank().height(22.vp)
            }.width(100.percent).padding(left: 16.vp, right: 16.vp, top: 18.vp).alignItems(HorizontalAlign.Start) }.width(100.percent).height(100.percent).align(Alignment.TopStart)
        }.width(100.percent).height(100.percent)
    }
}

@Component
class AlignedSettingRow {
    let title: String
    let subtitle: String
    let value: String
    let onTap: () -> Unit
    func build() {
        Row {
            Column { Text(this.title).fontSize(15.vp).fontWeight(FontWeight.Bold); Text(this.subtitle).fontSize(12.vp).fontColor(0xFF526070).margin(top: 5.vp) }.layoutWeight(1).alignItems(HorizontalAlign.Start)
            Text(this.value).fontSize(14.vp).fontColor(0xFF3F5F90)
        }.width(100.percent).height(68.vp).padding(left: 16.vp, right: 16.vp).backgroundColor(0xFFFFFFFF).border(width: 1.vp, color: 0xFFE8EBF0).onClick({ _ => this.onTap() })
    }
}
