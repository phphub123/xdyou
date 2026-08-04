package ohos_app_cangjie_entry

import kit.ArkUI.*
import kit.ArkWeb.*
import std.collection.ArrayList
import std.time.*
import ohos.arkui.state_macro_manage.*
import ohos.business_exception.*
import ohos_app_cangjie_entry.repository.*
import ohos_app_cangjie_entry.controller.*
import ohos_app_cangjie_entry.external.*

@Entry
@Component
class LoginWindow {
    @State var account: String = ""
    @State var password: String = ""
    @State var passwordVisible: Bool = false
    @State var loading: Bool = false
    @State var showHome: Bool = false
    @State var mockPreview: Bool = false
    @State var status: String = ""
    @State var captchaImage: String = ""
    @State var captchaPieceImage: String = ""
    @State var sliderOffset: Float64 = 0.0
    @State var webReady: Bool = false
    @State var webLoginSubmitting: Bool = false
    let idsBootstrapController = WebviewController()
    let idsCookieBootstrapEnabled: Unit = WebCookieManager.setAcceptCookiesEnabled(true)
    var sliderTrackX: ArrayList<Int64> = ArrayList<Int64>()
    var sliderTrackY: ArrayList<Int64> = ArrayList<Int64>()
    var sliderTrackTime: ArrayList<Int64> = ArrayList<Int64>()
    var sliderStartX: Float64 = 0.0
    var sliderStartY: Float64 = 0.0
    var sliderLastTime: Int64 = 0
    var sessionStore: ?SessionStore = None
    var viewModel: LoginViewModel = LoginViewModel()
    var currentCaptcha: ?SliderCaptcha = None

    protected override func aboutToAppear(): Unit {
        this.sessionStore = Some(SessionStore())
        let snapshot = this.store().restore()
        if (snapshot.loggedIn) { this.account = snapshot.account; this.showHome = true; this.status = "Restored the saved IDS session." }
        else if (snapshot.account != "") { this.account = snapshot.account }
    }
    func store(): SessionStore { match (this.sessionStore) { case Some(value) => value; case None => throw Exception("Session store is not initialized") } }
    func clearData(): Unit {
        this.store().clearAll(); this.account = ""; this.password = ""; this.captchaImage = ""; this.captchaPieceImage = ""; this.currentCaptcha = None
        this.status = "Local IDS session data was cleared."
    }
    func beginOfficialWebLogin(): Unit {
        if (!this.webReady) { this.status = "Preparing the secure IDS session. Try again in a moment."; return }
        let account64 = IDSPasswordCipher.toBase64(this.account.toArray())
        let password64 = IDSPasswordCipher.toBase64(this.password.toArray())
        let script = """
(() => {
  const decode = value => new TextDecoder().decode(Uint8Array.from(atob(value), ch => ch.charCodeAt(0)));
  const form = document.getElementById('pwdFromId');
  if (!form) return 'FORM_MISSING';
  const account = form.querySelector('input[name="username"]');
  const password = form.querySelector('input[name="passwordText"]');
  const submit = form.querySelector('#login_submit');
  if (!account || !password || !submit) return 'CONTROL_MISSING';
  account.value = decode('${account64}');
  password.value = decode('${password64}');
  account.dispatchEvent(new Event('input', { bubbles: true }));
  account.dispatchEvent(new Event('change', { bubbles: true }));
  password.dispatchEvent(new Event('input', { bubbles: true }));
  password.dispatchEvent(new Event('change', { bubbles: true }));
  account.dispatchEvent(new Event('blur', { bubbles: true }));
  setTimeout(() => submit.click(), 600);
  return 'QUEUED';
})()
"""
        let callback: AsyncCallback<String> = {
            error: ?BusinessException, _: ?String => launch {
                match (error) {
                    case Some(value) =>
                        this.loading = false
                        this.webLoginSubmitting = false
                        this.password = ""
                        this.status = "Unable to submit the IDS form: ${value.code}"
                    case None =>
                        this.password = ""
                        this.status = "Submitting the official IDS form..."
                }
            }
        }
        this.webLoginSubmitting = true
        this.loading = true
        this.status = "Submitting the official IDS form..."
        this.idsBootstrapController.runJavaScript(script, callback)
    }
    func finishOfficialWebLogin(url: String): Unit {
        if (!this.webLoginSubmitting) { return }
        if (url.contains("ids.xidian.edu.cn/authserver/login")) {
            this.loading = false
            this.webLoginSubmitting = false
            this.status = "IDS rejected the account or password."
            return
        }
        let idsCookies = WebCookieManager.fetchCookie("https://ids.xidian.edu.cn/authserver/login")
        let serviceCookies = WebCookieManager.fetchCookie(url)
        let cookies = if (idsCookies == "") { serviceCookies } else if (serviceCookies == "") { idsCookies } else { idsCookies + "; " + serviceCookies }
        try {
            if (cookies != "") { this.store().saveAuthenticatedSession(this.account, cookies) }
            this.password = ""
            this.loading = false
            this.webLoginSubmitting = false
            this.showHome = true
            this.status = "IDS authentication succeeded."
        } catch (e: Exception) {
            this.loading = false
            this.webLoginSubmitting = false
            this.status = "Authenticated but local session storage failed: ${e.message}"
        }
    }
    func validate(): Unit {
        if (this.account.trimAscii() == "") { this.status = "Student ID is required."; return }
        if (this.password == "") { this.status = "Password is required."; return }
        this.captchaImage = ""; this.captchaPieceImage = ""; this.currentCaptcha = None; this.resetSliderTracks()
        this.beginOfficialWebLogin()
    }
    func resetSliderTracks(): Unit {
        this.sliderTrackX.clear(); this.sliderTrackY.clear(); this.sliderTrackTime.clear()
        this.sliderStartX = 0.0; this.sliderStartY = 0.0; this.sliderLastTime = 0
    }
    func addSliderTrack(x: Float64, y: Float64, timestamp: Int64): Unit {
        let dx = Int64(x - this.sliderStartX)
        let dy = Int64(y - this.sliderStartY)
        let elapsed = if (this.sliderLastTime == 0) { 0 } else { (timestamp - this.sliderLastTime) / 1000000 }
        if (this.sliderTrackX.size == 0 || elapsed >= 20 && (dx != this.sliderTrackX[this.sliderTrackX.size - 1] || dy != this.sliderTrackY[this.sliderTrackY.size - 1])) {
            this.sliderTrackX.add(dx); this.sliderTrackY.add(dy); this.sliderTrackTime.add(elapsed)
            this.sliderLastTime = timestamp
        }
    }
    func addFinalSliderTrack(x: Float64, y: Float64, timestamp: Int64): Unit {
        let dx = Int64(x - this.sliderStartX)
        let dy = Int64(y - this.sliderStartY)
        let elapsed = if (this.sliderLastTime == 0) { 0 } else { (timestamp - this.sliderLastTime) / 1000000 }
        this.sliderTrackX.add(dx); this.sliderTrackY.add(dy); this.sliderTrackTime.add(elapsed)
        this.sliderLastTime = timestamp
    }
    func captureSliderTouch(event: TouchEvent): Unit {
        let touch = if (event.touches.size > 0) { event.touches[0] } else if (event.changedTouches.size > 0) { event.changedTouches[0] } else { return }
        match (event.eventType) {
            case TouchType.Down =>
                this.resetSliderTracks(); this.sliderStartX = touch.screenX; this.sliderStartY = touch.screenY; this.sliderLastTime = event.timestamp
                this.sliderTrackX.add(0); this.sliderTrackY.add(0); this.sliderTrackTime.add(0)
            case TouchType.Move => this.addSliderTrack(touch.screenX, touch.screenY, event.timestamp)
            case TouchType.Up => this.addFinalSliderTrack(touch.screenX, touch.screenY, event.timestamp)
            case _ => ()
        }
    }
    func sliderTracksJson(): String {
        if (this.sliderTrackX.size < 2) { return "" }
        var result = "["
        var index: Int64 = 0
        while (index < this.sliderTrackX.size) {
            if (index > 0) { result += "," }
            result += "{\\\"a\\\":${this.sliderTrackX[index]},\\\"b\\\":${this.sliderTrackY[index]},\\\"c\\\":${this.sliderTrackTime[index]}}"
            index += 1
        }
        return result + "]"
    }
    func lastSliderTrackX(): Int64 {
        if (this.sliderTrackX.size == 0) { return 0 }
        return this.sliderTrackX[this.sliderTrackX.size - 1]
    }
    func verifySlider(): Unit {
        match (this.currentCaptcha) {
            case Some(captcha) =>
                this.loading = true
                let tracks = this.sliderTracksJson()
                if (tracks == "") { this.status = "Drag the IDS slider before verification."; this.loading = false; return }
                this.viewModel.verifyCaptcha(captcha, this.lastSliderTrackX(), tracks, { _, message => launch { this.loading = false; this.status = message } }, { cookie => launch { try { this.store().saveAuthenticatedSession(this.account, cookie); this.password = ""; this.showHome = true } catch (e: Exception) { this.loading = false; this.status = "Authenticated but local session storage failed: ${e.message}" } } })
            case None => this.status = "Load the IDS slider before verification."
        }
    }
    func openMockPreview(): Unit {
        this.mockPreview = true
        this.password = ""
        this.showHome = true
    }
    func leaveHome(): Unit {
        if (!this.mockPreview) { this.store().clearSession() }
        this.password = ""
        this.showHome = false
        this.status = if (this.mockPreview) { "已退出 Mock UI 预览。" } else { "Signed out." }
        this.mockPreview = false
    }

    func build() {
        if (this.showHome) {
            AlignedHomePage(account: if (this.mockPreview) { "Mock UI" } else { this.account }, previewMode: this.mockPreview, onLogout: { => this.leaveHome() })
        } else {
            Column {
                Web(
                    src: "https://ids.xidian.edu.cn/authserver/login?service=https%3A%2F%2Fehall.xidian.edu.cn%2Flogin%3Fservice%3Dhttps%3A%2F%2Fehall.xidian.edu.cn%2Fnew%2Findex.html",
                    controller: this.idsBootstrapController
                )
                    .onPageEnd({ event =>
                        if (!this.webReady && event.url.contains("ids.xidian.edu.cn/authserver/login")) {
                            this.webReady = true
                            if (this.status == "") { this.status = "" }
                        } else {
                            this.finishOfficialWebLogin(event.url)
                        }
                    })
                    .width(1.vp)
                    .height(1.vp)
                    .opacity(0.0)
                    .id("idsCookieBootstrap")
                Stack { Column { Text("==").fontSize(15.vp).fontWeight(FontWeight.Bold).fontColor(0xFFFFFFFF); Text("XDYOU").fontSize(16.vp).fontWeight(FontWeight.Bold).fontStyle(FontStyle.Italic).fontColor(0xFFFFFFFF) }.width(58.vp).height(58.vp).border(width: 3.vp, color: 0xFFFFFFFF, radius: 8.vp).justifyContent(FlexAlign.Center) }.width(88.vp).height(88.vp).backgroundColor(0xFF0796DB).borderRadius(20.vp).align(Alignment.Center).id("loginLogo")
                Row {
                    Text("ID").width(30.vp).fontSize(11.vp).fontWeight(FontWeight.Bold).fontColor(0xFF4B5565)
                    TextInput(placeholder: "Student ID", text: this.account).layoutWeight(1).height(38.vp).backgroundColor(0xFFF5F6FB).onChange({ value => this.account = value }).id("loginAccountInput")
                }.width(100.percent).height(40.vp).padding(left: 10.vp, right: 8.vp).margin(top: 30.vp).backgroundColor(0xFFF5F6FB).border(width: 1.vp, color: 0xFF91A6D0, radius: 6.vp)
                Row {
                    Text("PW").width(30.vp).fontSize(10.vp).fontWeight(FontWeight.Bold).fontColor(0xFF4B5565)
                    Stack {
                        TextInput(placeholder: if (this.passwordVisible) { "IDS Login password" } else { "" }, text: this.password).width(100.percent).height(38.vp).opacity(if (this.passwordVisible) { 1.0 } else { 0.0 }).selectionMenuHidden(!this.passwordVisible).backgroundColor(0xFFF5F6FB).onChange({ value => this.password = value }).id("loginPasswordInput")
                        if (!this.passwordVisible) { Text(if (this.password == "") { "IDS Login password" } else { "********" }).width(100.percent).height(38.vp).fontSize(14.vp).fontColor(if (this.password == "") { 0xFF8A94A6 } else { 0xFF1F2937 }).onClick({ _ => FocusControl.requestFocus("loginPasswordInput") }).id("loginPasswordMask") }
                    }.layoutWeight(1).height(38.vp)
                    Text(if (this.passwordVisible) { "Hide" } else { "View" }).width(44.vp).fontSize(11.vp).fontColor(0xFF4B5565).onClick({ _ => this.passwordVisible = !this.passwordVisible }).id("togglePasswordVisibility")
                }.width(100.percent).height(40.vp).padding(left: 10.vp, right: 4.vp).margin(top: 10.vp).backgroundColor(0xFFF5F6FB).border(width: 1.vp, color: 0xFF91A6D0, radius: 6.vp)
                Button(if (this.loading) { "Working..." } else { "Login" }).width(100.percent).height(40.vp).margin(top: 46.vp).fontSize(15.vp).fontWeight(FontWeight.Bold).fontColor(0xFFFFFFFF).backgroundColor(0xFF46699D).borderRadius(7.vp).onClick({ _ => this.validate() }).id("loginSubmitButton")
                Button("Mock 预览主页（仅 UI，不登录）").width(100.percent).height(36.vp).margin(top: 8.vp).fontSize(12.vp).fontColor(0xFF46699D).backgroundColor(0xFFEAF2FC).borderRadius(7.vp).onClick({ _ => this.openMockPreview() }).id("mockHomePreviewButton")
                if (this.captchaImage != "") {
                    Text("IDS verification").fontSize(14.vp).fontWeight(FontWeight.Bold).margin(top: 16.vp)
                    Stack {
                        Image(this.captchaImage).width(250.vp).height(138.vp).objectFit(ImageFit.Contain).id("idsSliderImage")
                        Image(this.captchaPieceImage).width(40.vp).height(138.vp).objectFit(ImageFit.Contain).position(x: this.sliderOffset.vp, y: 0.vp).id("idsSliderPiece")
                    }.width(250.vp).height(138.vp).margin(top: 8.vp)
                    Slider(value: this.sliderOffset, min: 0.0, max: 210.0, step: 1.0, style: SliderStyle.OutSet).width(250.vp).showTips(true).onChange({ value: Float64, _ => this.sliderOffset = value }).onTouch({ event => this.captureSliderTouch(event) }).id("idsSliderControl")
                    Button(if (this.loading) { "Verifying..." } else { "Verify" }).width(250.vp).margin(top: 8.vp).onClick({ _ => this.verifySlider() }).id("idsSliderVerifyButton")
                }
                Row {
                    Text("Clear cache").fontSize(11.vp).fontColor(0xFF7C8DAA).onClick({ _ => this.clearData() }).id("clearSessionButton")
                    Text("View network interaction").fontSize(11.vp).fontColor(0xFF7C8DAA).margin(left: 22.vp).onClick({ _ => this.status = "IDS network status is shown below; sensitive request data is never persisted." }).id("viewNetworkInteraction")
                }.margin(top: 18.vp)
                if (this.status != "") { Text(this.status).fontSize(11.vp).fontColor(0xFF68758A).margin(top: 12.vp).id("loginStatus") }
            }.width(100.percent).height(100.percent).padding(left: 33.vp, right: 33.vp, top: 58.vp).alignItems(HorizontalAlign.Center)
        }
    }
}
@Component
class HomePage {
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

@Component
class CampusHomePage {
    let onAttendance: () -> Unit
    let onEmptyClassroom: () -> Unit
    let onLibrary: () -> Unit
    let onSchoolnet: () -> Unit
    let onDormWater: () -> Unit
    func build() {
        Scroll { Column {
            Text("校园服务").fontSize(28.vp).fontWeight(FontWeight.Bold)
            Text("查询结果来自学校与校园服务的实时接口").fontSize(13.vp).fontColor(0xFF65738A).margin(top: 5.vp)
            Row {
                Column { Text("课堂考勤").fontSize(18.vp).fontWeight(FontWeight.Bold); Text("学习通考勤、预警与签到明细").fontSize(12.vp).fontColor(0xFF65738A).margin(top: 8.vp) }
                    .layoutWeight(1).height(120.vp).padding(14.vp).backgroundColor(0xFFFFFFFF).borderRadius(14.vp).onClick({ _ => this.onAttendance() }).id("homeClassAttendance")
                Column { Text("空闲教室").fontSize(18.vp).fontWeight(FontWeight.Bold); Text("按日期、教学楼和节次查询").fontSize(12.vp).fontColor(0xFF65738A).margin(top: 8.vp) }
                    .layoutWeight(1).height(120.vp).padding(14.vp).margin(left: 10.vp).backgroundColor(0xFFFFFFFF).borderRadius(14.vp).onClick({ _ => this.onEmptyClassroom() }).id("homeEmptyClassroom")
            }.width(100.percent).margin(top: 18.vp)
            Column { Text("图书馆").fontSize(18.vp).fontWeight(FontWeight.Bold); Text("馆藏检索、图书详情与馆藏位置").fontSize(12.vp).fontColor(0xFF65738A).margin(top: 8.vp) }
                .width(100.percent).height(105.vp).padding(14.vp).margin(top: 10.vp).backgroundColor(0xFFFFFFFF).borderRadius(14.vp).onClick({ _ => this.onLibrary() }).id("homeLibrary")
            Column { Text("校园网").fontSize(18.vp).fontWeight(FontWeight.Bold); Text("当前在线账号、流量、余额与设备").fontSize(12.vp).fontColor(0xFF65738A).margin(top: 8.vp) }
                .width(100.percent).height(105.vp).padding(14.vp).margin(top: 10.vp).backgroundColor(0xFFFFFFFF).borderRadius(14.vp).onClick({ _ => this.onSchoolnet() }).id("homeSchoolnet")
            Column { Text("宿舍饮水").fontSize(18.vp).fontWeight(FontWeight.Bold); Text("短信登录、收藏设备与启停供水").fontSize(12.vp).fontColor(0xFF65738A).margin(top: 8.vp) }
                .width(100.percent).height(105.vp).padding(14.vp).margin(top: 10.vp).backgroundColor(0xFFFFFFFF).borderRadius(14.vp).onClick({ _ => this.onDormWater() }).id("homeDormWater")
            Row {
                Column { Text("教务中心").fontSize(18.vp).fontWeight(FontWeight.Bold); Text("课表、成绩、考试").fontSize(12.vp).fontColor(0xFF65738A).margin(top: 8.vp) }
                    .layoutWeight(1).height(110.vp).padding(14.vp).backgroundColor(0xFFEAF2FF).borderRadius(14.vp).id("homeAcademicSummary")
                Column { Text("校园工具").fontSize(18.vp).fontWeight(FontWeight.Bold); Text("缴费、订水、报修、预约与网络").fontSize(12.vp).fontColor(0xFF65738A).margin(top: 8.vp) }
                    .layoutWeight(1).height(110.vp).padding(14.vp).margin(left: 10.vp).backgroundColor(0xFFEAF2FF).borderRadius(14.vp).id("homeToolboxSummary")
            }.width(100.percent).margin(top: 10.vp)
        }.width(100.percent).padding(20.vp).alignItems(HorizontalAlign.Start) }.width(100.percent).layoutWeight(1)
    }
}

@Component
class SettingWindow {
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
        let store = SessionStore(); this.language = store.restoreLanguage(); this.theme = store.restoreTheme()
        this.color = store.restoreSetting("color", defaultValue: "蓝色")
        this.semester = store.restoreSetting("semester", defaultValue: "2026-1")
        this.week = store.restoreSetting("week", defaultValue: "1")
        this.lowElectricity = store.restoreSetting("lowElectricity", defaultValue: "15")
        this.timeline = store.restoreSetting("timeline", defaultValue: "开启")
    }
    func saveSettings(): Unit {
        let store = SessionStore(); store.saveDisplaySettings(this.language, this.theme)
        store.saveSetting("color", this.color)
        store.saveSetting("semester", this.semester)
        store.saveSetting("week", this.week)
        store.saveSetting("lowElectricity", this.lowElectricity)
        store.saveSetting("timeline", this.timeline)
    }
    func testNotification(): Unit {
        this.systemStatus = "正在发送测试通知…"
        SystemCapabilityBridge.getInstance().publishCourseReminder(91001, "XDYou 上课提醒", "系统通知互操作测试", { ok, message =>
            launch { this.systemStatus = if (ok) { "测试通知已发布。" } else { "通知发布失败：${message}" } }
        })
    }
    func testCalendar(): Unit {
        this.systemStatus = "正在申请权限并写入测试日程…"
        let startTime = DateTime.now().toUnixTimeStamp().toMilliseconds() + 3600000
        SystemCapabilityBridge.getInstance().addCalendarEvent("XDYou 课程日历测试", startTime, startTime + 3600000, { ok, message =>
            launch { this.systemStatus = if (ok) { "测试日程已写入系统日历（${message}）。" } else { "日历写入失败：${message}" } }
        })
    }
    func build() {
        Column {
            Text("设置").fontSize(28.vp).fontWeight(FontWeight.Bold)
            Text("语言").fontSize(16.vp).margin(top: 18.vp)
            Row {
                Button("简体中文").onClick({ _ => this.language = "Chinese"; this.saveSettings() }).id("languageZhCn")
                Button("繁體中文").margin(left: 8.vp).onClick({ _ => this.language = "Traditional Chinese"; this.saveSettings() }).id("languageZhTw")
                Button("English").margin(left: 8.vp).onClick({ _ => this.language = "English"; this.saveSettings() }).id("languageEnUs")
            }.margin(top: 10.vp)
            Text("当前语言：${this.language}").fontSize(13.vp).margin(top: 8.vp)
            Text("外观").fontSize(16.vp).margin(top: 14.vp)
            Row {
                Button("跟随系统").onClick({ _ => this.theme = "System"; this.saveSettings() }).id("themeSystem")
                Button("浅色").margin(left: 8.vp).onClick({ _ => this.theme = "Light"; this.saveSettings() }).id("themeLight")
                Button("深色").margin(left: 8.vp).onClick({ _ => this.theme = "Dark"; this.saveSettings() }).id("themeDark")
            }.margin(top: 10.vp)
            Row {
                Button("蓝色").onClick({ _ => this.color = "蓝色"; this.saveSettings() }).id("colorBlue")
                Button("绿色").margin(left: 8.vp).onClick({ _ => this.color = "绿色"; this.saveSettings() }).id("colorGreen")
                Button("橙色").margin(left: 8.vp).onClick({ _ => this.color = "橙色"; this.saveSettings() }).id("colorOrange")
                Button("时间轴：${this.timeline}").margin(left: 8.vp).onClick({ _ => this.timeline = if (this.timeline == "开启") { "关闭" } else { "开启" }; this.saveSettings() }).id("timelineToggle")
            }.margin(top: 8.vp)
            Text("学期与课表").fontSize(16.vp).margin(top: 14.vp)
            Row {
                TextInput(placeholder: "学期代码", text: this.semester).layoutWeight(2).onChange({ value => this.semester = value }).id("settingSemester")
                TextInput(placeholder: "当前周", text: this.week).layoutWeight(1).margin(left: 8.vp).onChange({ value => this.week = value }).id("settingWeek")
                Button("保存").margin(left: 8.vp).onClick({ _ => this.saveSettings() }).id("saveAcademicSettings")
            }.width(100.percent).height(42.vp).margin(top: 8.vp)
            Row {
                Text("低电量阈值 (%)").layoutWeight(1)
                TextInput(placeholder: "15", text: this.lowElectricity).width(100.vp).onChange({ value => this.lowElectricity = value }).id("lowElectricityThreshold")
                Button("保存").margin(left: 8.vp).onClick({ _ => this.saveSettings() }).id("saveLowElectricity")
            }.width(100.percent).height(42.vp).margin(top: 10.vp)
            Text("关于 XDYOU · 仓颉 HarmonyOS 原生版").fontSize(14.vp).margin(top: 14.vp).id("settingsAbout")
            Button("退出登录并清除会话").width(100.percent).height(48.vp).margin(top: 18.vp)
                .onClick({ _ => this.onLogout() }).id("logoutButton")
            Button("测试上课通知").width(100.percent).height(42.vp).margin(top: 12.vp).onClick({ _ => this.testNotification() }).id("testCourseNotification")
            Button("测试系统日历").width(100.percent).height(42.vp).margin(top: 8.vp).onClick({ _ => this.testCalendar() }).id("testSystemCalendar")
            if (this.systemStatus != "") { Text(this.systemStatus).fontSize(12.vp).fontColor(0xFF5F6368).margin(top: 6.vp).id("systemCapabilityStatus") }
        }.width(100.percent).layoutWeight(1).padding(24.vp).alignItems(HorizontalAlign.Start)
    }
}
