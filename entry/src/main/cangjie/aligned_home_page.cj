package ohos_app_cangjie_entry

import kit.ArkUI.*
import kit.ArkWeb.*
import ohos.arkui.state_macro_manage.*
import ohos.business_exception.*

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
                        onDormWater: { => this.homeFeature = 5 }
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
                Column {
                    Text("◉").fontSize(21.vp).fontColor(if (this.selected == 0) { 0xFF253A5E } else { 0xFF526070 })
                        .width(56.vp).height(32.vp).textAlign(TextAlign.Center).backgroundColor(if (this.selected == 0) { 0xFFD0E4FF } else { 0x00FFFFFF }).borderRadius(18.vp)
                    Text("校园信息").fontSize(11.vp).fontWeight(if (this.selected == 0) { FontWeight.Bold } else { FontWeight.Normal }).margin(top: 2.vp)
                }.layoutWeight(1).height(68.vp).justifyContent(FlexAlign.Center).onClick({ _ => this.selectPage(0) }).id("navTo_home")
                Column {
                    Text("▣").fontSize(21.vp).fontColor(if (this.selected == 1) { 0xFF253A5E } else { 0xFF526070 })
                        .width(56.vp).height(32.vp).textAlign(TextAlign.Center).backgroundColor(if (this.selected == 1) { 0xFFD0E4FF } else { 0x00FFFFFF }).borderRadius(18.vp)
                    Text("睿思论坛").fontSize(11.vp).fontWeight(if (this.selected == 1) { FontWeight.Bold } else { FontWeight.Normal }).margin(top: 2.vp)
                }.layoutWeight(1).height(68.vp).justifyContent(FlexAlign.Center).onClick({ _ => this.selectPage(1) }).id("navTo_ruisi")
                Column {
                    Text("⚒").fontSize(21.vp).fontColor(if (this.selected == 2) { 0xFF253A5E } else { 0xFF526070 })
                        .width(56.vp).height(32.vp).textAlign(TextAlign.Center).backgroundColor(if (this.selected == 2) { 0xFFD0E4FF } else { 0x00FFFFFF }).borderRadius(18.vp)
                    Text("工具箱").fontSize(11.vp).fontWeight(if (this.selected == 2) { FontWeight.Bold } else { FontWeight.Normal }).margin(top: 2.vp)
                }.layoutWeight(1).height(68.vp).justifyContent(FlexAlign.Center).onClick({ _ => this.selectPage(2) }).id("navTo_toolbox")
                Column {
                    Text("♥").fontSize(21.vp).fontColor(if (this.selected == 3) { 0xFF253A5E } else { 0xFF526070 })
                        .width(56.vp).height(32.vp).textAlign(TextAlign.Center).backgroundColor(if (this.selected == 3) { 0xFFD0E4FF } else { 0x00FFFFFF }).borderRadius(18.vp)
                    Text("猪图鉴赏").fontSize(11.vp).fontWeight(if (this.selected == 3) { FontWeight.Bold } else { FontWeight.Normal }).margin(top: 2.vp)
                }.layoutWeight(1).height(68.vp).justifyContent(FlexAlign.Center).onClick({ _ => this.selectPage(3) }).id("navTo_pig")
                Column {
                    Text("●").fontSize(21.vp).fontColor(if (this.selected == 4) { 0xFF253A5E } else { 0xFF526070 })
                        .width(56.vp).height(32.vp).textAlign(TextAlign.Center).backgroundColor(if (this.selected == 4) { 0xFFD0E4FF } else { 0x00FFFFFF }).borderRadius(18.vp)
                    Text("设置").fontSize(11.vp).fontWeight(if (this.selected == 4) { FontWeight.Bold } else { FontWeight.Normal }).margin(top: 2.vp)
                }.layoutWeight(1).height(68.vp).justifyContent(FlexAlign.Center).onClick({ _ => this.selectPage(4) }).id("navTo_settings")
            }.width(100.percent).height(76.vp).padding(left: 4.vp, right: 4.vp, top: 4.vp, bottom: 4.vp).backgroundColor(0xFFF1F4F9).border(width: 1.vp, color: 0xFFE1E5EC)
        }.width(100.percent).height(100.percent).backgroundColor(0xFFF8FAFD)
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
    @State var editMode: Bool = false

    func build() {
        Column {
            Row {
                Text("校园信息查询").fontSize(22.vp).fontWeight(FontWeight.Bold).layoutWeight(1)
                Text(if (this.editMode) { "完成" } else { "编辑" }).fontSize(14.vp).fontColor(0xFF3F5F90)
                    .padding(10.vp).onClick({ _ => this.editMode = !this.editMode }).id("homeEditLayout")
            }.width(100.percent).height(58.vp).padding(left: 18.vp, right: 10.vp)
            if (this.previewMode) {
                Text("Mock UI 预览：未登录，页面数据不代表真实账号。").width(100.percent).fontSize(12.vp).fontColor(0xFF6B4B00)
                    .padding(left: 16.vp, right: 16.vp, top: 9.vp, bottom: 9.vp).backgroundColor(0xFFFFF3CD).id("mockPreviewBanner")
            }
            Scroll {
                Column {
                    Column {
                        Row { Text("应用信息").fontSize(14.vp).fontWeight(FontWeight.Bold).fontColor(0xFFFFFFFF).layoutWeight(1); Text("刷新").fontSize(12.vp).fontColor(0xFFFFFFFF) }
                            .width(100.percent).padding(left: 16.vp, right: 16.vp, top: 12.vp, bottom: 10.vp).backgroundColor(0xFF3F5F90)
                        Text("目前没有获取应用公告，请刷新").width(100.percent).fontSize(14.vp).padding(16.vp)
                    }.width(100.percent).backgroundColor(0xFFFFFFFF).borderRadius(14.vp).clip(true).id("homeNoticeCard")
                    Column {
                        Row { Text("课程表").fontSize(14.vp).fontWeight(FontWeight.Bold).fontColor(0xFFFFFFFF).layoutWeight(1); Text("暂无日程").fontSize(12.vp).fontColor(0xFFFFFFFF) }
                            .width(100.percent).padding(left: 16.vp, right: 16.vp, top: 12.vp, bottom: 10.vp).backgroundColor(0xFF3F5F90)
                        Row { Text("今日课程与日程").fontSize(16.vp).layoutWeight(1); Text("第 1 周  ›").fontSize(13.vp).fontColor(0xFF526070) }.width(100.percent).padding(16.vp)
                    }.width(100.percent).margin(top: 10.vp).backgroundColor(0xFFFFFFFF).borderRadius(14.vp).clip(true).onClick({ _ => this.onSchedule() }).id("homeScheduleCard")
                    AlignedInfoCard(icon: "⚡", title: "水电信息", value: "正在获取信息", note: "查看宿舍电量与用水记录", onTap: this.onDormWater)
                    AlignedInfoCard(icon: "▤", title: "图书借阅", value: "正在查询信息", note: "查看借阅到期时间与馆藏", onTap: this.onLibrary)
                    Row {
                        AlignedSmallCard(icon: "A+", title: "成绩查询", onTap: this.onScore)
                        AlignedSmallCard(icon: "日", title: "考试安排", onTap: this.onExam)
                        AlignedSmallCard(icon: "室", title: "空闲教室", onTap: this.onEmptyClassroom)
                        AlignedSmallCard(icon: "签", title: "考勤查询", onTap: this.onAttendance)
                    }.width(100.percent).height(92.vp).margin(top: 10.vp)
                    Row {
                        AlignedSmallCard(icon: "Wi", title: "校园网", onTap: this.onSchoolnet)
                        AlignedSmallCard(icon: "水", title: "宿舍水机", onTap: this.onDormWater)
                        AlignedSmallCard(icon: "实", title: "实验信息", onTap: { => () })
                        AlignedSmallCard(icon: "体", title: "体育信息", onTap: { => () })
                    }.width(100.percent).height(92.vp).margin(top: 8.vp)
                    if (this.editMode) { Text("按住卡片可调整布局，点击完成保存。").width(100.percent).textAlign(TextAlign.Center).fontSize(12.vp).fontColor(0xFF526070).margin(top: 12.vp) }
                    Blank().height(20.vp)
                }.width(100.percent).padding(left: 10.vp, right: 10.vp, top: 8.vp).alignItems(HorizontalAlign.Start)
            }.width(100.percent).layoutWeight(1).align(Alignment.TopStart)
        }.width(100.percent).height(100.percent)
    }
}

@Component
class AlignedInfoCard {
    let icon: String
    let title: String
    let value: String
    let note: String
    let onTap: () -> Unit
    func build() {
        Row {
            Text(this.icon).width(42.vp).fontSize(27.vp).fontColor(0xFF3F5F90).textAlign(TextAlign.Center)
            Column { Text(this.value).fontSize(17.vp).fontWeight(FontWeight.Bold); Text(this.note).fontSize(12.vp).fontColor(0xFF526070).margin(top: 5.vp) }
                .layoutWeight(1).alignItems(HorizontalAlign.Start)
            Text("›").fontSize(24.vp).fontColor(0xFF7B8492)
        }.width(100.percent).height(82.vp).padding(left: 12.vp, right: 14.vp).margin(top: 10.vp).backgroundColor(0xFFFFFFFF).borderRadius(14.vp).onClick({ _ => this.onTap() })
    }
}

@Component
class AlignedSmallCard {
    let icon: String
    let title: String
    let onTap: () -> Unit
    func build() {
        Column {
            Text(this.icon).fontSize(20.vp).fontWeight(FontWeight.Bold).fontColor(0xFF3F5F90)
            Text(this.title).fontSize(11.vp).margin(top: 8.vp).textAlign(TextAlign.Center)
        }.layoutWeight(1).height(92.vp).margin(left: 3.vp, right: 3.vp).justifyContent(FlexAlign.Center).backgroundColor(0xFFFFFFFF).borderRadius(13.vp).onClick({ _ => this.onTap() })
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
