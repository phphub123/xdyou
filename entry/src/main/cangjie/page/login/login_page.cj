package ohos_app_cangjie_entry.page.login

import kit.ArkUI.*
import kit.ArkWeb.*
import std.collection.ArrayList
import std.time.*
import ohos.arkui.state_macro_manage.*
import ohos.business_exception.*
import ohos_app_cangjie_entry.repository.*
import ohos_app_cangjie_entry.controller.*
import ohos_app_cangjie_entry.external.*
import ohos_app_cangjie_entry.themes.*

import ohos_app_cangjie_entry.page.homepage.*
@Entry
@Component
public class LoginWindow {
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
    @StorageProp["xdyouThemePreference"] let themePreference: String = "System"
    @StorageProp["colorMode"] let systemColorMode: ColorMode = ColorMode.Light
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

    func darkMode(): Bool { return AppTheme.isDark(this.themePreference, this.systemColorMode) }

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
                    Text("ID").width(30.vp).fontSize(11.vp).fontWeight(FontWeight.Bold).fontColor(ThemePalette.textSecondary(this.darkMode()))
                    TextInput(placeholder: "Student ID", text: this.account).layoutWeight(1).height(38.vp).backgroundColor(ThemePalette.inputSurface(this.darkMode())).onChange({ value => this.account = value }).id("loginAccountInput")
                }.width(100.percent).height(40.vp).padding(left: 10.vp, right: 8.vp).margin(top: 30.vp).backgroundColor(ThemePalette.inputSurface(this.darkMode())).border(width: 1.vp, color: ThemePalette.primary(this.darkMode()), radius: 6.vp)
                Row {
                    Text("PW").width(30.vp).fontSize(10.vp).fontWeight(FontWeight.Bold).fontColor(ThemePalette.textSecondary(this.darkMode()))
                    Stack {
                        TextInput(placeholder: if (this.passwordVisible) { "IDS Login password" } else { "" }, text: this.password).width(100.percent).height(38.vp).opacity(if (this.passwordVisible) { 1.0 } else { 0.0 }).selectionMenuHidden(!this.passwordVisible).backgroundColor(ThemePalette.inputSurface(this.darkMode())).onChange({ value => this.password = value }).id("loginPasswordInput")
                        if (!this.passwordVisible) { Text(if (this.password == "") { "IDS Login password" } else { "********" }).width(100.percent).height(38.vp).fontSize(14.vp).fontColor(if (this.password == "") { ThemePalette.textSecondary(this.darkMode()) } else { ThemePalette.textPrimary(this.darkMode()) }).onClick({ _ => FocusControl.requestFocus("loginPasswordInput") }).id("loginPasswordMask") }
                    }.layoutWeight(1).height(38.vp)
                    Text(if (this.passwordVisible) { "Hide" } else { "View" }).width(44.vp).fontSize(11.vp).fontColor(ThemePalette.textSecondary(this.darkMode())).onClick({ _ => this.passwordVisible = !this.passwordVisible }).id("togglePasswordVisibility")
                }.width(100.percent).height(40.vp).padding(left: 10.vp, right: 4.vp).margin(top: 10.vp).backgroundColor(ThemePalette.inputSurface(this.darkMode())).border(width: 1.vp, color: ThemePalette.primary(this.darkMode()), radius: 6.vp)
                Button(if (this.loading) { "Working..." } else { "Login" }).width(100.percent).height(40.vp).margin(top: 46.vp).fontSize(15.vp).fontWeight(FontWeight.Bold).fontColor(ThemePalette.primaryText()).backgroundColor(ThemePalette.primary(this.darkMode())).borderRadius(7.vp).onClick({ _ => this.validate() }).id("loginSubmitButton")
                Button("Mock 预览主页（仅 UI，不登录）").width(100.percent).height(36.vp).margin(top: 8.vp).fontSize(12.vp).fontColor(ThemePalette.primary(this.darkMode())).backgroundColor(ThemePalette.primaryContainer(this.darkMode())).borderRadius(7.vp).onClick({ _ => this.openMockPreview() }).id("mockHomePreviewButton")
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
            }.width(100.percent).height(100.percent).padding(left: 33.vp, right: 33.vp, top: 58.vp).alignItems(HorizontalAlign.Center).backgroundColor(ThemePalette.pageBackground(this.darkMode()))
        }
    }
}
