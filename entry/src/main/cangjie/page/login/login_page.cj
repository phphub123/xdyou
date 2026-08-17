package ohos_app_cangjie_entry.page.login

// 登录页面，驱动 IDS 密码登录、滑块挑战和短信二次验证流程。

import kit.ArkUI.*
import kit.ArkWeb.*
import std.collection.ArrayList
import std.convert.*
import std.math.*
import std.sync.*
import std.time.*
import ohos.arkui.state_macro_manage.*
import ohos.business_exception.*
import ohos_app_cangjie_entry.repository.*
import ohos_app_cangjie_entry.controller.*
import ohos_app_cangjie_entry.model.*
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
    @State var rawLoginResponse: String = ""
    @State var captchaImage: String = ""
    @State var captchaPieceImage: String = ""
    @State var sliderOffset: Float64 = 0.0
    @State var webReady: Bool = false
    @State var webLoginSubmitting: Bool = false
    @State var showOfficialIdsPage: Bool = false
    @State var showReAuthDialog: Bool = false
    @State var reAuthCode: String = ""
    @State var reAuthNotice: String = ""
    @State var reAuthError: String = ""
    @State var reAuthSending: Bool = false
    @State var reAuthSubmitting: Bool = false
    @State var reAuthTrustDevice: Bool = false
    @State var reAuthNavigationPending: Bool = false
    @State var reAuthSecondsRemaining: Int64 = 0
    @StorageProp["xdyouThemePreference"]
    let themePreference: String = "System"
    @StorageProp["colorMode"]
    let systemColorMode: ColorMode = ColorMode.Light
    let idsBootstrapController = WebviewController()
    let idsCookieBootstrapEnabled: Unit = WebCookieManager.setAcceptCookiesEnabled(true)
    var sliderTrackX: ArrayList<Int64> = ArrayList<Int64>()
    var sliderTrackY: ArrayList<Int64> = ArrayList<Int64>()
    var sliderTrackTime: ArrayList<Int64> = ArrayList<Int64>()
    var sliderStartX: Float64 = 0.0
    var sliderStartY: Float64 = 0.0
    var sliderLastTime: Int64 = 0
    var sessionStore: ?SessionStore = None
    var loginWatchdogTimer: ?Timer = None
    var loginInspectionCount: Int64 = 0
    var reAuthCountdownTimer: ?Timer = None
    var viewModel: LoginViewModel = LoginViewModel()
    var currentReAuth: ?IDSReAuthSession = None
    var currentCaptcha: ?SliderCaptcha = None

    func darkMode(): Bool {
        return AppTheme.isDark(this.themePreference, this.systemColorMode)
    }

    protected override func aboutToAppear(): Unit {
        this.sessionStore = Some(SessionStore())
        let snapshot = this.store().restore()
        if (snapshot.loggedIn) {
            this.account = snapshot.account
            this.showHome = true
            this.status = "Restored the saved IDS session."
            this.rawLoginResponse = ""
        } else if (snapshot.account != "") {
            this.account = snapshot.account
        }
    }
    protected override func aboutToDisappear(): Unit {
        this.stopLoginWatchdog()
        this.stopReAuthCountdown()
    }
    func store(): SessionStore {
        match (this.sessionStore) {
            case Some(value) => value;
            case None => throw Exception("Session store is not initialized")
        }
    }
    func clearData(): Unit {
        this.store().clearAll();
        this.account = ""
        this.password = ""
        this.captchaImage = ""
        this.captchaPieceImage = ""
        this.currentCaptcha = None
        this.rawLoginResponse = ""
        this.closeReAuthDialog()
        this.stopLoginWatchdog()
        this.showOfficialIdsPage = false
        this.status = "Local IDS session data was cleared."
    }
    func stopLoginWatchdog(): Unit {
        match (this.loginWatchdogTimer) {
            case Some(timer) => timer.cancel()
            case None => ()
        }
        this.loginWatchdogTimer = None
        this.loginInspectionCount = 0
    }
    func startLoginWatchdog(): Unit {
        this.stopLoginWatchdog()
        this.loginWatchdogTimer = Some(Timer.repeat(Duration.second * 2, Duration.second * 2, { => launch {
            if (!this.webLoginSubmitting || this.showReAuthDialog || this.showHome) {
                this.stopLoginWatchdog()
                return
            }
            this.loginInspectionCount += 1
            this.inspectOfficialIdsPage()
            if (this.loginInspectionCount >= 6 && this.webLoginSubmitting && !this.showOfficialIdsPage) {
                this.loading = false
                this.showOfficialIdsPage = true
                this.status = "统一认证仍在等待操作，请在页面中完成滑块或查看错误提示。"
            }
        }}))
    }
    func inspectOfficialIdsPage(): Unit {
        let script = """
(() => {
  const text = String(document.body ? document.body.innerText : '').split(String.fromCharCode(10)).join(' ').slice(0, 180);
  const slider = Boolean(document.querySelector(
    '#sliderCaptcha, .sliderCaptcha, .slider-captcha, [class*=slider], [id*=slider], iframe[src*=captcha]'
  ));
  const reauth = location.pathname.includes('/authserver/reAuthCheck/reAuthLoginView.do');
  return (reauth ? 'REAUTH' : slider ? 'SLIDER' : 'WAIT') + '|' + text;
})()
"""
        let callback: AsyncCallback<String> = {
            error: ?BusinessException, data: ?String => launch {
                match (error) {
                    case Some(value) =>
                        this.loading = false
                        this.showOfficialIdsPage = true
                        this.status = "无法检查统一认证状态（${value.code}），请直接在页面中继续。"
                    case None => match (data) {
                        case Some(value) => this.handleOfficialIdsInspection(value)
                        case None => ()
                    }
                }
            }
        }
        this.idsBootstrapController.runJavaScript(script, callback)
    }
    func handleOfficialIdsInspection(raw: String): Unit {
        let value = raw.trimAscii().replace("\"", "")
        if (value.startsWith("REAUTH|")) {
            this.stopLoginWatchdog()
            this.showOfficialIdsPage = false
            this.openReAuthDialog()
        } else if (value.startsWith("SLIDER|")) {
            this.loading = false
            this.showOfficialIdsPage = true
            this.status = "账号密码已提交，请先在统一认证页面完成滑块验证。"
        } else if (value.contains("用户名或密码") || value.contains("账号或密码") ||
            value.contains("密码有误")) {
            this.stopLoginWatchdog()
            this.loading = false
            this.webLoginSubmitting = false
            this.showOfficialIdsPage = false
            this.status = "用户名或密码有误。"
        }
    }
    func beginOfficialWebLogin(): Unit {
        if (!this.webReady) {
            this.status = "Preparing the secure IDS session. Try again in a moment."
            return
        }
        this.closeReAuthDialog()
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
                        this.stopLoginWatchdog()
                        this.loading = false
                        this.webLoginSubmitting = false
                        this.showOfficialIdsPage = false
                        this.password = ""
                        this.status = "Unable to submit the IDS form: ${value.code}"
                    case None =>
                        this.password = ""
                        this.status = "正在等待统一认证处理；若需要滑块，页面会自动展开。"
                }
            }
        }
        this.webLoginSubmitting = true
        this.showOfficialIdsPage = false
        this.loading = true
        this.status = "正在提交统一认证账号密码…"
        this.startLoginWatchdog()
        this.idsBootstrapController.runJavaScript(script, callback)
    }
    func finishOfficialWebLogin(url: String): Unit {
        if (!this.webLoginSubmitting && !this.showReAuthDialog) {
            return
        }
        if (this.isReAuthUrl(url)) {
            this.stopLoginWatchdog()
            this.showOfficialIdsPage = false
            this.openReAuthDialog()
            return
        }
        if (url.contains("ids.xidian.edu.cn/authserver/login")) {
            if (this.showReAuthDialog && this.reAuthNavigationPending) {
                return
            }
            if (this.showReAuthDialog) {
                this.reAuthSubmitting = false
                this.reAuthError = "二次认证未完成，请检查验证码后重试。"
                return
            }
            this.stopLoginWatchdog()
            this.loading = false
            this.webLoginSubmitting = false
            this.showOfficialIdsPage = false
            this.status = "IDS rejected the account or password."
            return
        }
        this.completeOfficialWebLogin(url)
    }
    func isReAuthUrl(url: String): Bool {
        return url.contains("ids.xidian.edu.cn/authserver/reAuthCheck/reAuthLoginView.do")
    }
    func openReAuthDialog(): Unit {
        this.loading = false
        this.webLoginSubmitting = true
        if (!this.showReAuthDialog) {
            this.reAuthCode = ""
            this.reAuthError = ""
            let recipient = match (this.currentReAuth) {
                case Some(value) => value.recipient
                case None => ""
            }
            this.reAuthNotice = if (recipient == "") {
                "检测到短信二次认证，请获取并输入验证码。"
            } else {
                "短信二次认证号码：${recipient}。请获取并输入验证码。"
            }
            this.reAuthSending = false
            this.reAuthSubmitting = false
            this.reAuthNavigationPending = false
        }
        this.showReAuthDialog = true
        this.status = "等待短信二次认证。"
    }
    func stopReAuthCountdown(): Unit {
        match (this.reAuthCountdownTimer) {
            case Some(timer) => timer.cancel()
            case None => ()
        }
        this.reAuthCountdownTimer = None
        this.reAuthSecondsRemaining = 0
    }
    func startReAuthCountdown(seconds: Int64): Unit {
        this.stopReAuthCountdown()
        if (seconds <= 0) {
            return
        }
        this.reAuthSecondsRemaining = seconds
        this.reAuthCountdownTimer = Some(
            Timer.repeat(
                Duration.second,
                Duration.second,
                { => launch {
                    if (!this.showReAuthDialog || this.reAuthSecondsRemaining <= 1) {
                        this.stopReAuthCountdown()
                    } else {
                        this.reAuthSecondsRemaining -= 1
                    }
                }}
            )
        )
    }
    func closeReAuthDialog(): Unit {
        this.stopReAuthCountdown()
        this.showReAuthDialog = false
        this.reAuthCode = ""
        this.reAuthNotice = ""
        this.reAuthError = ""
        this.reAuthSending = false
        this.reAuthSubmitting = false
        this.reAuthTrustDevice = false
        this.reAuthNavigationPending = false
    }
    func cancelReAuth(): Unit {
        this.stopLoginWatchdog()
        this.viewModel.clearPendingPassword()
        this.currentReAuth = None
        this.closeReAuthDialog()
        this.showOfficialIdsPage = false
        this.password = ""
        this.loading = false
        this.webLoginSubmitting = false
        this.status = "已取消短信二次认证。"
        try {
            WebCookieManager.clearSessionCookie()
        } catch (e: BusinessException) {
            this.status += " 清理 IDS 会话失败：${e.code}。"
        }
        this.idsBootstrapController.loadUrl(
            "https://ids.xidian.edu.cn/authserver/login?service=" +
                "https%3A%2F%2Fehall.xidian.edu.cn%2Flogin%3Fservice%3D" +
                "https%3A%2F%2Fehall.xidian.edu.cn%2Fnew%2Findex.html"
        )
    }
    func sendReAuthCode(): Unit {
        if (this.reAuthSending || this.reAuthSubmitting || this.reAuthSecondsRemaining > 0) {
            return
        }
        match (this.currentReAuth) {
            case Some(reAuth) =>
                this.reAuthSending = true
                this.reAuthError = ""
                reAuth.sendSms({ message, seconds => launch {
                    this.reAuthSending = false
                    this.reAuthNotice = message
                    this.startReAuthCountdown(seconds)
                } }, { error => launch {
                    this.reAuthSending = false
                    this.reAuthError = this.consumeDebugLoginMessage(error)
                } })
            case None => this.reAuthError = "二次认证会话已失效，请取消后重新登录。"
        }
    }
    func handleReAuthSendResult(raw: String): Unit {
        let value = raw.trimAscii().replace("\"", "")
        if (!value.contains("OK|")) {
            this.reAuthError = if (value.contains("ERROR|")) {
                value.replace("ERROR|", "")
            } else {
                "短信验证码发送失败。"
            }
            return
        }
        let fields = value.replace("OK|", "").split("|")
        if (fields.size < 2) {
            this.reAuthError = "统一认证返回了无效的验证码发送结果。"
            return
        }
        var seconds: Int64 = 0
        try {
            seconds = Int64.parse(fields[0])
        } catch (_) {
            seconds = 0
        }
        let recipient = if (fields.size > 2 && fields[2] != "") { "（${fields[2]}）" } else { "" }
        this.reAuthNotice = fields[1] + recipient
        this.startReAuthCountdown(seconds)
    }
    func submitReAuthCode(): Unit {
        let normalized = this.reAuthCode.trimAscii()
        if (normalized == "") {
            this.reAuthError = "请输入短信验证码。"
            return
        }
        if (this.reAuthSending || this.reAuthSubmitting) {
            return
        }
        match (this.currentReAuth) {
            case Some(reAuth) =>
                this.reAuthSubmitting = true
                this.reAuthError = ""
                reAuth.submitSms(normalized, this.reAuthTrustDevice,
                    { cookie => launch {
                        this.reAuthSubmitting = false
                        this.finishBackendLogin(cookie)
                    } }, { message => launch {
                        this.reAuthSubmitting = false
                        this.reAuthCode = ""
                        this.reAuthError = this.consumeDebugLoginMessage(message)
                    } }, { error => launch {
                        this.reAuthSubmitting = false
                        this.reAuthError = this.consumeDebugLoginMessage(error)
                    } })
            case None => this.reAuthError = "二次认证会话已失效，请取消后重新登录。"
        }
    }
    func handleReAuthSubmitResult(raw: String): Unit {
        let value = raw.trimAscii().replace("\"", "")
        if (value.contains("OK|")) {
            this.reAuthNotice = value.replace("OK|", "")
            this.status = "二次认证通过，正在继续登录…"
            this.reAuthNavigationPending = true
            return
        }
        this.reAuthSubmitting = false
        if (value.contains("REJECTED|")) {
            this.reAuthCode = ""
            this.reAuthError = value.replace("REJECTED|", "")
        } else if (value.contains("EXPIRED|")) {
            this.reAuthError = value.replace("EXPIRED|", "") + "，请取消后重新登录。"
        } else if (value.contains("ERROR|")) {
            this.reAuthError = value.replace("ERROR|", "")
        } else {
            this.reAuthError = "二次认证失败。"
        }
    }
    func completeOfficialWebLogin(url: String): Unit {
        this.stopLoginWatchdog()
        this.showOfficialIdsPage = false
        let idsCookies = WebCookieManager.fetchCookie("https://ids.xidian.edu.cn/authserver/login")
        let serviceCookies = WebCookieManager.fetchCookie(url)
        let cookies = if (idsCookies == "") {
            serviceCookies
        } else if (serviceCookies == "") {
            idsCookies
        } else {
            idsCookies + "; " + serviceCookies
        }
        try {
            if (cookies != "") {
                this.store().saveAuthenticatedSession(this.account, cookies)
            }
            this.password = ""
            this.loading = false
            this.webLoginSubmitting = false
            this.closeReAuthDialog()
            this.showHome = true
            this.status = "IDS authentication succeeded."
        } catch (e: Exception) {
            this.loading = false
            this.webLoginSubmitting = false
            this.status = "Authenticated but local session storage failed: ${e.message}"
        }
    }
    func validate(): Unit {
        if (this.account.trimAscii() == "") {
            this.rawLoginResponse = ""
            this.status = "Student ID is required."
            return
        }
        if (this.password == "") {
            this.rawLoginResponse = ""
            this.status = "Password is required."
            return
        }
        this.currentCaptcha = None
        this.rawLoginResponse = ""
        this.currentReAuth = None
        this.closeReAuthDialog()
        this.loading = true
        this.status = "正在后台登录统一认证…"
        this.viewModel.beginLogin(this.account, this.password,
            { state, message => launch { this.applyLoginState(state, message) } },
            { captcha => launch { this.showManualSlider(captcha) } },
            { reAuth => launch {
                this.currentReAuth = Some(reAuth)
                this.password = ""
                this.openReAuthDialog()
            } },
            { cookie => launch { this.finishBackendLogin(cookie) } })
    }
    func showManualSlider(captcha: SliderCaptcha): Unit {
        this.currentCaptcha = Some(captcha)
        this.captchaImage = "data:image/png;base64," + captcha.bigImage
        this.captchaPieceImage = "data:image/png;base64," + captcha.smallImage
        this.sliderOffset = 0.0
        this.resetSliderTracks()
        this.loading = false
        this.status = "自动识别未通过，请手动拖动滑块后验证。"
    }
    func consumeDebugLoginMessage(message: String): String {
        let separator = "\n---IDS_RAW_RESPONSE---\n"
        let parts = message.split(separator)
        if (parts.size >= 2) {
            var raw = parts[1]
            var index: Int64 = 2
            while (index < parts.size) {
                raw += separator + parts[index]
                index += 1
            }
            this.rawLoginResponse = raw
            return parts[0]
        }
        return message
    }
    func applyLoginState(state: SessionState, message: String): Unit {
        match (state) {
            case SessionState.Failed => this.loading = false
            case SessionState.LoggedIn => this.loading = false
            case _ => this.loading = true
        }
        this.status = this.consumeDebugLoginMessage(message)
    }
    func finishBackendLogin(cookie: String): Unit {
        try {
            this.store().saveAuthenticatedSession(this.account, cookie)
            this.password = ""
            this.loading = false
            this.webLoginSubmitting = false
            this.showOfficialIdsPage = false
            this.captchaImage = ""
            this.captchaPieceImage = ""
            this.currentCaptcha = None
            this.closeReAuthDialog()
            this.showHome = true
            this.status = "IDS authentication succeeded."
        } catch (e: Exception) {
            this.loading = false
            this.status = "Authenticated but local session storage failed: ${e.message}"
        }
    }
    func resetSliderTracks(): Unit {
        this.sliderTrackX.clear();
        this.sliderTrackY.clear();
        this.sliderTrackTime.clear()
        this.sliderStartX = 0.0
        this.sliderStartY = 0.0
        this.sliderLastTime = 0
    }
    func recordSliderValue(value: Float64, mode: SliderChangeMode): Unit {
        match (mode) {
            case SliderChangeMode.Begin => this.sliderOffset = value
            case SliderChangeMode.Moving => this.sliderOffset = value
            case SliderChangeMode.End => this.sliderOffset = value
            case SliderChangeMode.Click =>
                this.status = "请按住圆形滑块拖动，不能点击轨道跳转。"
            case _ => ()
        }
    }
    func addSliderTrack(x: Float64, y: Float64, timestamp: Int64): Unit {
        let dx = Int64(x - this.sliderStartX)
        let dy = Int64(y - this.sliderStartY)
        let elapsed = if (this.sliderLastTime == 0) {
            0
        } else {
            (timestamp - this.sliderLastTime) / 1000000
        }
        if (this.sliderTrackX.size == 0 || elapsed >= 20 && (dx != this.sliderTrackX[this.sliderTrackX.size - 1] ||
            dy != this.sliderTrackY[this.sliderTrackY.size - 1])) {
            this.sliderTrackX.add(dx);
            this.sliderTrackY.add(dy);
            this.sliderTrackTime.add(elapsed)
            this.sliderLastTime = timestamp
        }
    }
    func addFinalSliderTrack(x: Float64, y: Float64, timestamp: Int64): Unit {
        let dx = Int64(x - this.sliderStartX)
        let dy = Int64(y - this.sliderStartY)
        let elapsed = if (this.sliderLastTime == 0) {
            0
        } else {
            (timestamp - this.sliderLastTime) / 1000000
        }
        this.sliderTrackX.add(dx);
        this.sliderTrackY.add(dy);
        this.sliderTrackTime.add(elapsed)
        this.sliderLastTime = timestamp
    }
    func captureSliderTouch(event: TouchEvent): Unit {
        let touch = if (event.touches.size > 0) {
            event.touches[0]
        } else if (event.changedTouches.size > 0) {
            event.changedTouches[0]
        } else {
            return
        }
        match (event.eventType) {
            case TouchType.Down =>
                this.resetSliderTracks();
                this.sliderStartX = touch.screenX
                this.sliderStartY = touch.screenY
                this.sliderLastTime = event.timestamp
                this.sliderTrackX.add(0);
                this.sliderTrackY.add(0);
                this.sliderTrackTime.add(0)
            case TouchType.Move => this.addSliderTrack(touch.screenX, touch.screenY, event.timestamp)
            case TouchType.Up => this.addFinalSliderTrack(touch.screenX, touch.screenY, event.timestamp)
            case _ => ()
        }
    }
    // TouchEvent screen coordinates can be reported in device pixels while the
    // ArkUI Slider value is in vp. Scale the captured Down/Move/Up trajectory so
    // its final `a` is exactly the same logical moveLength sent to IDS. This is
    // the Dart CaptchaWidget invariant: tracks.last.a == moveLength.
    func sliderTracksJson(move: Int64): String {
        if (this.sliderTrackX.size < 2 || move <= 0) {
            return ""
        }
        let rawFinalX = this.sliderTrackX[this.sliderTrackX.size - 1]
        if (rawFinalX <= 0) { return "" }
        var result = "["
        var index: Int64 = 0
        while (index < this.sliderTrackX.size) {
            if (index > 0) {
                result += ","
            }
            let normalizedX = if (index == this.sliderTrackX.size - 1) {
                move
            } else {
                Int64(round(Float64(this.sliderTrackX[index]) * Float64(move) /
                    Float64(rawFinalX)))
            }
            let normalizedY = Int64(round(Float64(this.sliderTrackY[index]) * Float64(move) /
                Float64(rawFinalX)))
            result +=
                "{\"a\":${normalizedX}," +
                "\"b\":${normalizedY}," +
                "\"c\":${this.sliderTrackTime[index]}}"
            index += 1
        }
        return result + "]"
    }
    func lastSliderTrackX(): Int64 {
        if (this.sliderTrackX.size == 0) {
            return 0
        }
        return this.sliderTrackX[this.sliderTrackX.size - 1]
    }
    func verifySlider(): Unit {
        let move = Int64(round(this.sliderOffset))
        let tracks = this.sliderTracksJson(move)
        if (move <= 0 || tracks == "") {
            this.status = "请先拖动滑块到缺口位置。"
            return
        }
        match (this.currentCaptcha) {
            case Some(captcha) =>
                this.loading = true
                this.viewModel.submitManualCaptcha(captcha, move, tracks,
                    { state, message => launch { this.applyLoginState(state, message) } },
                    { refreshed => launch { this.showManualSlider(refreshed) } },
                    { reAuth => launch {
                        this.currentReAuth = Some(reAuth)
                        this.password = ""
                        this.captchaImage = ""
                        this.captchaPieceImage = ""
                        this.currentCaptcha = None
                        this.openReAuthDialog()
                    } },
                    { cookie => launch { this.finishBackendLogin(cookie) } })
            case None => this.status = "滑块会话已失效，请重新登录。"
        }
    }
    func refreshManualSlider(): Unit {
        match (this.currentCaptcha) {
            case Some(captcha) =>
                this.loading = true
                this.viewModel.refreshManualCaptcha(captcha,
                    { state, message => launch { this.applyLoginState(state, message) } },
                    { refreshed => launch { this.showManualSlider(refreshed) } })
            case None => this.status = "滑块会话已失效，请重新登录。"
        }
    }
    func openMockPreview(): Unit {
        this.mockPreview = true
        this.password = ""
        this.showHome = true
    }
    func leaveHome(): Unit {
        if (!this.mockPreview) {
            this.store().clearSession()
        }
        this.password = ""
        this.showHome = false
        this.status = if (this.mockPreview) {
            "已退出 Mock UI 预览。"
        } else {
            "Signed out."
        }
        this.mockPreview = false
    }

    func build() {
        if (this.showHome) {
            AlignedHomePage(account: if (this.mockPreview) {
                "Mock UI"
            } else {
                this.account
            }, previewMode: this.mockPreview, onLogout: {=> this.leaveHome()})
        } else {
            Stack {
                Column {
                Stack {
                    Column {
                    Text("==").fontSize(15.vp).fontWeight(FontWeight.Bold).fontColor(0xFFFFFFFF);
                Text("XDYOU")
                    .fontSize(16.vp)
                    .fontWeight(FontWeight.Bold)
                    .fontStyle(FontStyle.Italic)
                    .fontColor(0xFFFFFFFF)
                }
                    .width(58.vp)
                    .height(58.vp)
                    .border(width: 3.vp, color: 0xFFFFFFFF, radius: 8.vp)
                    .justifyContent(FlexAlign.Center)
                }
                    .width(88.vp)
                    .height(88.vp)
                    .backgroundColor(0xFF0796DB)
                    .borderRadius(20.vp)
                    .align(Alignment.Center)
                    .id("loginLogo")
                Row {
                    Text("ID")
                        .width(30.vp)
                        .fontSize(11.vp)
                        .fontWeight(FontWeight.Bold)
                        .fontColor(ThemePalette.textSecondary(this.darkMode()))
                    TextInput(placeholder: "Student ID", text: this.account)
                        .layoutWeight(1)
                        .height(38.vp)
                        .backgroundColor(ThemePalette.inputSurface(this.darkMode()))
                        .onChange({value => this.account = value})
                        .id("loginAccountInput")
                }
                    .width(100.percent)
                    .height(40.vp)
                    .padding(left: 10.vp, right: 8.vp)
                    .margin(top: 30.vp)
                    .backgroundColor(ThemePalette.inputSurface(this.darkMode()))
                    .border(width: 1.vp, color: ThemePalette.primary(this.darkMode()), radius: 6.vp)
                Row {
                    Text("PW")
                        .width(30.vp)
                        .fontSize(10.vp)
                        .fontWeight(FontWeight.Bold)
                        .fontColor(ThemePalette.textSecondary(this.darkMode()))
                    Stack {
                        TextInput(placeholder: if (this.passwordVisible) {
                            "IDS Login password"
                        } else {
                            ""
                        }, text: this.password)
                            .width(100.percent)
                            .height(38.vp)
                            .opacity(if (this.passwordVisible) {
                                1.0
                            } else {
                                0.0
                            })
                            .selectionMenuHidden(!this.passwordVisible)
                            .backgroundColor(ThemePalette.inputSurface(this.darkMode()))
                            .onChange({value => this.password = value})
                            .id("loginPasswordInput")
                        if (!this.passwordVisible) {
                            Text(if (this.password == "") {
                                "IDS Login password"
                            } else {
                                "********"
                            })
                                .width(100.percent)
                                .height(38.vp)
                                .fontSize(14.vp)
                                .fontColor(if (this.password == "") {
                                    ThemePalette.textSecondary(this.darkMode())
                                } else {
                                    ThemePalette.textPrimary(this.darkMode())
                                })
                                .onClick({_ => FocusControl.requestFocus("loginPasswordInput")})
                                .id("loginPasswordMask")
                        }
                    }.layoutWeight(1).height(38.vp)
                    Text(if (this.passwordVisible) {
                        "Hide"
                    } else {
                        "View"
                    })
                        .width(44.vp)
                        .fontSize(11.vp)
                        .fontColor(ThemePalette.textSecondary(this.darkMode()))
                        .onClick({_ => this.passwordVisible = !this.passwordVisible})
                        .id("togglePasswordVisibility")
                }
                    .width(100.percent)
                    .height(40.vp)
                    .padding(left: 10.vp, right: 4.vp)
                    .margin(top: 10.vp)
                    .backgroundColor(ThemePalette.inputSurface(this.darkMode()))
                    .border(width: 1.vp, color: ThemePalette.primary(this.darkMode()), radius: 6.vp)
                Button(if (this.loading) {
                    "Working..."
                } else {
                    "Login"
                })
                    .width(100.percent)
                    .height(40.vp)
                    .margin(top: 46.vp)
                    .fontSize(15.vp)
                    .fontWeight(FontWeight.Bold)
                    .fontColor(ThemePalette.primaryText())
                    .backgroundColor(ThemePalette.primary(this.darkMode()))
                    .borderRadius(7.vp)
                    .onClick({_ => this.validate()})
                    .id("loginSubmitButton")
                Button("Mock 预览主页（仅 UI，不登录）")
                    .width(100.percent)
                    .height(36.vp)
                    .margin(top: 8.vp)
                    .fontSize(12.vp)
                    .fontColor(ThemePalette.primary(this.darkMode()))
                    .backgroundColor(ThemePalette.primaryContainer(this.darkMode()))
                    .borderRadius(7.vp)
                    .onClick({_ => this.openMockPreview()})
                    .id("mockHomePreviewButton")
                if (this.captchaImage != "") {
                    Text("请拖动滑块完成验证").fontSize(14.vp).fontWeight(FontWeight.Bold).margin(top: 16.vp)
                    Stack {
                        Image(this.captchaImage)
                            .width(280.vp)
                            .height(155.vp)
                            .objectFit(ImageFit.Contain)
                            .id("idsSliderImage")
                        Image(this.captchaPieceImage)
                            .width(44.vp)
                            .height(155.vp)
                            .objectFit(ImageFit.Contain)
                            .position(x: this.sliderOffset.vp, y: 0.vp)
                            .id("idsSliderPiece")
                    }.width(280.vp).height(155.vp).margin(top: 8.vp)
                    Slider(value: this.sliderOffset, min: 0.0, max: 240.0, step: 1.0, style: SliderStyle.OutSet)
                        .width(280.vp)
                        .showTips(true)
                        .onChange({value: Float64, mode: SliderChangeMode => this.recordSliderValue(value, mode)})
                        .onTouch({event => this.captureSliderTouch(event)})
                        .id("idsSliderControl")
                    Button(if (this.loading) {
                        "Verifying..."
                    } else {
                        "Verify"
                    }).width(280.vp).margin(top: 8.vp).onClick({_ => this.verifySlider()}).id("idsSliderVerifyButton")
                    Button("刷新验证码")
                        .width(280.vp)
                        .margin(top: 6.vp)
                        .enabled(!this.loading)
                        .onClick({_ => this.refreshManualSlider()})
                        .id("idsSliderRefreshButton")
                }
                Row {
                    Text("Clear cache")
                        .fontSize(11.vp)
                        .fontColor(0xFF7C8DAA)
                        .onClick({_ => this.clearData()})
                        .id("clearSessionButton")
                    Text("View network interaction")
                        .fontSize(11.vp)
                        .fontColor(0xFF7C8DAA)
                        .margin(left: 22.vp)
                        .onClick(
                            {
                                _ =>
                                    this.status =
                                        "IDS network status is shown below; sensitive request data " +
                                        "is never persisted."
                                    if (this.rawLoginResponse == "") {
                                        this.rawLoginResponse = "还没有捕获到登录接口返回的错误响应。"
                                    }
                            })
                        .id("viewNetworkInteraction")
                }.margin(top: 18.vp)
                if (this.status != "") {
                    Text(this.status).fontSize(11.vp).fontColor(0xFF68758A).margin(top: 12.vp).id("loginStatus")
                }
                if (this.rawLoginResponse != "") {
                    Column {
                        Text("登录接口原始错误响应")
                            .fontSize(11.vp)
                            .fontWeight(FontWeight.Bold)
                            .fontColor(0xFFBA1A1A)
                            .width(100.percent)
                        Scroll {
                            Text(this.rawLoginResponse)
                                .fontSize(10.vp)
                                .fontColor(0xFFBA1A1A)
                                .width(100.percent)
                                .lineHeight(15.vp)
                                .id("loginRawErrorJson")
                        }
                            .width(100.percent)
                            .height(118.vp)
                            .margin(top: 6.vp)
                    }
                        .width(100.percent)
                        .padding(10.vp)
                        .margin(top: 10.vp)
                        .backgroundColor(0xFFFFF1F1)
                        .border(width: 1.vp, color: 0xFFBA1A1A, radius: 8.vp)
                        .alignItems(HorizontalAlign.Start)
                        .id("loginRawErrorPanel")
                }
            }
                .width(100.percent)
                .height(100.percent)
                .padding(left: 33.vp, right: 33.vp, top: 58.vp)
                .alignItems(HorizontalAlign.Center)
                .backgroundColor(ThemePalette.pageBackground(this.darkMode()))
                if (this.showReAuthDialog) {
                    Column {}
                        .width(100.percent)
                        .height(100.percent)
                        .backgroundColor(0x66000000)
                        .id("idsReAuthScrim")
                    Column {
                        Text("短信二次認證")
                            .fontSize(21.vp)
                            .fontWeight(FontWeight.Medium)
                            .fontColor(ThemePalette.textPrimary(this.darkMode()))
                            .width(100.percent)
                        Text("學校要求完成二次認證。請先獲取短信驗證碼，再輸入驗證碼繼續登錄。")
                            .fontSize(14.vp)
                            .fontColor(ThemePalette.textPrimary(this.darkMode()))
                            .lineHeight(21.vp)
                            .margin(top: 14.vp)
                            .width(100.percent)
                        Stack {
                            TextInput(placeholder: "", text: this.reAuthCode)
                                .width(100.percent)
                                .height(54.vp)
                                .backgroundColor(Color.Transparent)
                                .border(
                                    width: 1.5.vp,
                                    color: if (this.reAuthError == "") {
                                        ThemePalette.primary(this.darkMode())
                                    } else {
                                        0xFFBA1A1A
                                    },
                                    radius: 8.vp
                                )
                                .enabled(!this.reAuthSending && !this.reAuthSubmitting)
                                .onChange({value => this.reAuthCode = value})
                                .id("idsReAuthCodeInput")
                            Text("短信驗證碼")
                                .fontSize(12.vp)
                                .fontColor(if (this.reAuthError == "") {
                                    ThemePalette.primary(this.darkMode())
                                } else {
                                    0xFFBA1A1A
                                })
                                .padding(left: 4.vp, right: 4.vp)
                                .backgroundColor(ThemePalette.mutedPrimary(this.darkMode()))
                                .position(x: 12.vp, y: (-7).vp)
                        }.width(100.percent).height(54.vp).margin(top: 20.vp)
                        Button(if (this.reAuthSending) {
                            "正在發送…"
                        } else if (this.reAuthSecondsRemaining > 0) {
                            "${this.reAuthSecondsRemaining} 秒後可重新獲取"
                        } else {
                            "獲取驗證碼"
                        })
                            .width(100.percent)
                            .height(42.vp)
                            .margin(top: 14.vp)
                            .enabled(
                                !this.reAuthSending && !this.reAuthSubmitting &&
                                    this.reAuthSecondsRemaining == 0
                            )
                            .fontSize(14.vp)
                            .fontColor(ThemePalette.primary(this.darkMode()))
                            .buttonStyle(ButtonStyleMode.Textual)
                            .backgroundColor(Color.Transparent)
                            .border(width: 1.vp, color: ThemePalette.primary(this.darkMode()), radius: 12.vp)
                            .onClick({_ => this.sendReAuthCode()})
                            .id("idsReAuthSendCodeButton")
                        if (this.reAuthNotice != "") {
                            Text(this.reAuthNotice)
                                .fontSize(12.vp)
                                .fontColor(ThemePalette.textSecondary(this.darkMode()))
                                .margin(top: 8.vp)
                                .width(100.percent)
                                .id("idsReAuthNotice")
                        }
                        if (this.reAuthError != "") {
                            Text(this.reAuthError)
                                .fontSize(12.vp)
                                .fontColor(0xFFBA1A1A)
                                .margin(top: 8.vp)
                                .width(100.percent)
                                .id("idsReAuthError")
                        }
                        Row {
                            Toggle(ToggleType.Checkbox, isOn: this.reAuthTrustDevice)
                                .size(width: 24.vp, height: 24.vp)
                                .selectedColor(ThemePalette.primary(this.darkMode()))
                                .enabled(!this.reAuthSending && !this.reAuthSubmitting)
                                .onChange({value: Bool => this.reAuthTrustDevice = value})
                                .id("idsReAuthTrustDeviceToggle")
                            Column {
                                Text("信任此設備")
                                    .fontSize(16.vp)
                                    .fontWeight(FontWeight.Medium)
                                    .fontColor(ThemePalette.textPrimary(this.darkMode()))
                                Text("開啟後學校可能在一段時間內\n不再要求本設備二次認證")
                                    .fontSize(13.vp)
                                    .fontColor(ThemePalette.textSecondary(this.darkMode()))
                                    .lineHeight(19.vp)
                                    .margin(top: 3.vp)
                            }.layoutWeight(1).margin(left: 14.vp).alignItems(HorizontalAlign.Start)
                        }.width(100.percent).margin(top: 18.vp).alignItems(VerticalAlign.Top)
                        Row {
                            Button("取消")
                                .width(72.vp)
                                .height(40.vp)
                                .enabled(!this.reAuthSending && !this.reAuthSubmitting)
                                .fontSize(14.vp)
                                .fontColor(ThemePalette.primary(this.darkMode()))
                                .buttonStyle(ButtonStyleMode.Textual)
                                .backgroundColor(Color.Transparent)
                                .onClick({_ => this.cancelReAuth()})
                                .id("idsReAuthCancelButton")
                            Button(if (this.reAuthSubmitting) {
                                "驗證中…"
                            } else {
                                "確定"
                            })
                                .width(92.vp)
                                .height(40.vp)
                                .margin(left: 8.vp)
                                .enabled(!this.reAuthSending && !this.reAuthSubmitting)
                                .fontSize(14.vp)
                                .fontColor(ThemePalette.primaryText())
                                .backgroundColor(ThemePalette.primary(this.darkMode()))
                                .borderRadius(12.vp)
                                .onClick({_ => this.submitReAuthCode()})
                                .id("idsReAuthConfirmButton")
                        }
                            .width(100.percent)
                            .margin(top: 22.vp)
                            .justifyContent(FlexAlign.End)
                    }
                        .width(330.vp)
                        .padding(left: 24.vp, right: 24.vp, top: 26.vp, bottom: 22.vp)
                        .backgroundColor(ThemePalette.mutedPrimary(this.darkMode()))
                        .borderRadius(18.vp)
                        .align(Alignment.Center)
                        .alignItems(HorizontalAlign.Start)
                        .id("idsReAuthDialog")
                }
            }.width(100.percent).height(100.percent)
        }
    }
}
