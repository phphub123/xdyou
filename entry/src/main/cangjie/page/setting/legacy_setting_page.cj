package ohos_app_cangjie_entry.page.setting

import kit.ArkUI.*
import kit.ArkWeb.*
import std.collection.ArrayList
import std.time.*
import ohos.arkui.state_macro_manage.*
import ohos.business_exception.*
import ohos_app_cangjie_entry.repository.*
import ohos_app_cangjie_entry.controller.*
import ohos_app_cangjie_entry.external.*

@Component
public class SettingWindow {
    let onLogout: () -> Unit
    @State var language: String = "Chinese"
    @State var color: String = "蓝色"
    @State var semester: String = "2026-1"
    @State var week: String = "1"
    @State var lowElectricity: String = "15"
    @State var timeline: String = "开启"
    @State var systemStatus: String = ""
    @State var theme: String = "System"

    protected override func aboutToAppear(): Unit {
        let store = SessionStore();
        this.language = store.restoreLanguage()
        this.theme = store.restoreTheme()
        this.color = store.restoreSetting("color", defaultValue: "蓝色")
        this.semester = store.restoreSetting("semester", defaultValue: "2026-1")
        this.week = store.restoreSetting("week", defaultValue: "1")
        this.lowElectricity = store.restoreSetting("lowElectricity", defaultValue: "15")
        this.timeline = store.restoreSetting("timeline", defaultValue: "开启")
    }
    func saveSettings(): Unit {
        let store = SessionStore();
        store.saveDisplaySettings(this.language, this.theme)
        store.saveSetting("color", this.color)
        store.saveSetting("semester", this.semester)
        store.saveSetting("week", this.week)
        store.saveSetting("lowElectricity", this.lowElectricity)
        store.saveSetting("timeline", this.timeline)
    }
    func testNotification(): Unit {
        this.systemStatus = "正在发送测试通知…"
        SystemCapabilityBridge.getInstance().publishCourseReminder(
            91001,
            "XDYou 上课提醒",
            "系统通知互操作测试",
            {
            ok, message => launch {
                this.systemStatus = if (ok) {
                "测试通知已发布。"
            } else {
                "通知发布失败：${message}"
            }
            }
        })
    }
    func testCalendar(): Unit {
        this.systemStatus = "正在申请权限并写入测试日程…"
        let startTime = DateTime.now().toUnixTimeStamp().toMilliseconds() + 3600000
        SystemCapabilityBridge.getInstance().addCalendarEvent(
            "XDYou 课程日历测试",
            startTime,
            startTime + 3600000,
            {
            ok, message => launch {
                this.systemStatus = if (ok) {
                "测试日程已写入系统日历（${message}）。"
            } else {
                "日历写入失败：${message}"
            }
            }
        })
    }
    func build() {
        Column {
            Text("设置").fontSize(28.vp).fontWeight(FontWeight.Bold)
            Text("语言").fontSize(16.vp).margin(top: 18.vp)
            Row {
                Button("简体中文").onClick(
                    {
                        _ =>
                        this.language = "Chinese"
                        this.saveSettings()
                    }
                ).id("languageZhCn")
                Button("繁體中文").margin(left: 8.vp).onClick(
                    {
                        _ =>
                        this.language = "Traditional Chinese"
                        this.saveSettings()
                    }
                ).id("languageZhTw")
                Button("English").margin(left: 8.vp).onClick(
                    {
                        _ =>
                        this.language = "English"
                        this.saveSettings()
                    }
                ).id("languageEnUs")
            }.margin(top: 10.vp)
            Text("当前语言：${this.language}").fontSize(13.vp).margin(top: 8.vp)
            Text("外观").fontSize(16.vp).margin(top: 14.vp)
            Row {
                Button("跟随系统").onClick(
                    {
                        _ =>
                        this.theme = "System"
                        this.saveSettings()
                    }
                ).id("themeSystem")
                Button("浅色").margin(left: 8.vp).onClick(
                    {
                        _ =>
                        this.theme = "Light"
                        this.saveSettings()
                    }
                ).id("themeLight")
                Button("深色").margin(left: 8.vp).onClick(
                    {
                        _ =>
                        this.theme = "Dark"
                        this.saveSettings()
                    }
                ).id("themeDark")
            }.margin(top: 10.vp)
            Row {
                Button("蓝色").onClick(
                    {
                        _ =>
                        this.color = "蓝色"
                        this.saveSettings()
                    }
                ).id("colorBlue")
                Button("绿色").margin(left: 8.vp).onClick(
                    {
                        _ =>
                        this.color = "绿色"
                        this.saveSettings()
                    }
                ).id("colorGreen")
                Button("橙色").margin(left: 8.vp).onClick(
                    {
                        _ =>
                        this.color = "橙色"
                        this.saveSettings()
                    }
                ).id("colorOrange")
                Button("时间轴：${this.timeline}").margin(left: 8.vp).onClick(
                    {
                        _ =>
                        this.timeline = if (this.timeline == "开启") {
                            "关闭"
                        } else {
                            "开启"
                        };
                        this.saveSettings()
                    }
                ).id("timelineToggle")
            }.margin(top: 8.vp)
            Text("学期与课表").fontSize(16.vp).margin(top: 14.vp)
            Row {
                TextInput(placeholder: "学期代码", text: this.semester)
                    .layoutWeight(2)
                    .onChange({value => this.semester = value})
                    .id("settingSemester")
                TextInput(placeholder: "当前周", text: this.week)
                    .layoutWeight(1)
                    .margin(left: 8.vp)
                    .onChange({value => this.week = value})
                    .id("settingWeek")
                Button("保存").margin(left: 8.vp).onClick({_ => this.saveSettings()}).id("saveAcademicSettings")
            }.width(100.percent).height(42.vp).margin(top: 8.vp)
            Row {
                Text("低电量阈值 (%)").layoutWeight(1)
                TextInput(placeholder: "15", text: this.lowElectricity)
                    .width(100.vp)
                    .onChange({value => this.lowElectricity = value})
                    .id("lowElectricityThreshold")
                Button("保存").margin(left: 8.vp).onClick({_ => this.saveSettings()}).id("saveLowElectricity")
            }.width(100.percent).height(42.vp).margin(top: 10.vp)
            Text("关于 XDYOU · 仓颉 HarmonyOS 原生版").fontSize(14.vp).margin(top: 14.vp).id("settingsAbout")
            Button("退出登录并清除会话")
                .width(100.percent)
                .height(48.vp)
                .margin(top: 18.vp)
                .onClick({_ => this.onLogout()})
                .id("logoutButton")
            Button("测试上课通知")
                .width(100.percent)
                .height(42.vp)
                .margin(top: 12.vp)
                .onClick({_ => this.testNotification()})
                .id("testCourseNotification")
            Button("测试系统日历")
                .width(100.percent)
                .height(42.vp)
                .margin(top: 8.vp)
                .onClick({_ => this.testCalendar()})
                .id("testSystemCalendar")
            if (this.systemStatus != "") {
                Text(this.systemStatus)
                    .fontSize(12.vp)
                    .fontColor(0xFF5F6368)
                    .margin(top: 6.vp)
                    .id("systemCapabilityStatus")
            }
        }.width(100.percent).layoutWeight(1).padding(24.vp).alignItems(HorizontalAlign.Start)
    }
}
