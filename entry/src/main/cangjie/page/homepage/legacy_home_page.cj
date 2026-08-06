package ohos_app_cangjie_entry.page.homepage

import kit.ArkUI.*
import kit.ArkWeb.*
import std.collection.ArrayList
import std.time.*
import ohos.arkui.state_macro_manage.*
import ohos.business_exception.*
import ohos_app_cangjie_entry.repository.*
import ohos_app_cangjie_entry.controller.*
import ohos_app_cangjie_entry.external.*

import ohos_app_cangjie_entry.page.academic.*
import ohos_app_cangjie_entry.page.class_attendance.*
import ohos_app_cangjie_entry.page.dorm_water.*
import ohos_app_cangjie_entry.page.empty_classroom.*
import ohos_app_cangjie_entry.page.library.*
import ohos_app_cangjie_entry.page.schoolnet.*
import ohos_app_cangjie_entry.page.setting.*
import ohos_app_cangjie_entry.page.toolbox.*
@Component
public class HomePage {
    let account: String
    let previewMode: Bool
    let onLogout: () -> Unit
    @State var selected: Int64 = 0
    @State var homeFeature: Int64 = 0

    func pageTitle(): String {
        if (this.selected == 0) { return "Home" }
        else if (this.selected == 1) { return "Ruisi" }
        else if (this.selected == 2) { return "工具箱" }
        else if (this.selected == 3) { return "教务" }
        else { return "Settings" }
    }

    func build() {
        Column {
            Row {
                Text("XDYOU").fontSize(24.vp).fontWeight(FontWeight.Bold).layoutWeight(1)
                Text(this.account).fontSize(14.vp).fontColor(0xFF5F6368).id("sessionAccount")
            }.width(100.percent).padding(18.vp)
            if (this.previewMode) {
                Row {
                    Text("Mock UI 预览：未登录，页面数据不代表真实账号。").fontSize(12.vp).fontColor(0xFF6B4B00).layoutWeight(1).id("mockPreviewBanner")
                    Button("返回登录").height(32.vp).onClick({ _ => this.onLogout() }).id("mockPreviewExit")
                }.width(100.percent).padding(left: 18.vp, right: 18.vp, top: 8.vp, bottom: 8.vp).backgroundColor(0xFFFFF3CD)
            }
            if (this.selected == 4) {
                SettingWindow(onLogout: this.onLogout)
            } else if (this.selected == 3) {
                AcademicHub()
            } else if (this.selected == 2) {
                ToolboxPage()
            } else if (this.selected == 0 && this.homeFeature == 1) {
                ClassAttendancePage(onBack: { => this.homeFeature = 0 })
            } else if (this.selected == 0 && this.homeFeature == 2) {
                EmptyClassroomPage()
            } else if (this.selected == 0 && this.homeFeature == 3) {
                LibraryPage(onBack: { => this.homeFeature = 0 })
            } else if (this.selected == 0 && this.homeFeature == 4) {
                SchoolnetPage(onBack: { => this.homeFeature = 0 })
            } else if (this.selected == 0 && this.homeFeature == 5) {
                DormWaterPage(onBack: { => this.homeFeature = 0 })
            } else if (this.selected == 0) {
                CampusHomePage(onAttendance: { => this.homeFeature = 1 }, onEmptyClassroom: { => this.homeFeature = 2 }, onLibrary: { => this.homeFeature = 3 }, onSchoolnet: { => this.homeFeature = 4 }, onDormWater: { => this.homeFeature = 5 })
            } else {
                Column {
                    Text(this.pageTitle()).fontSize(28.vp).fontWeight(FontWeight.Bold)
                    Text("睿思社区").fontSize(18.vp).fontWeight(FontWeight.Bold).margin(top: 12.vp)
                    Text("正在连接独立睿思会话；请使用工具箱中的睿思入口完成网页登录。")
                        .fontSize(14.vp).fontColor(0xFF5F6368).margin(top: 10.vp)
                }.width(100.percent).layoutWeight(1).padding(24.vp).alignItems(HorizontalAlign.Start)
            }
            Row {
                Button("首页").layoutWeight(1).onClick({ _ => this.selected = 0; this.homeFeature = 0 }).id("navTo_home")
                Button("睿思").layoutWeight(1).onClick({ _ => this.selected = 1 }).id("navTo_ruisi")
                Button("工具").layoutWeight(1).onClick({ _ => this.selected = 2 }).id("navTo_toolbox")
                Button("教务").layoutWeight(1).onClick({ _ => this.selected = 3 }).id("navTo_dashboard")
                Button("设置").layoutWeight(1).onClick({ _ => this.selected = 4 }).id("navTo_settings")
            }.width(100.percent).padding(8.vp)
        }.width(100.percent).height(100.percent).backgroundColor(0xFFF7F9FC)
    }
}

