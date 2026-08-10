package ohos_app_cangjie_entry.repository

import kit.NetworkKit.*
import kit.ArkWeb.*
import kit.PerformanceAnalysisKit.Hilog
import ohos.business_exception.*
import ohos.callback_invoke.*
import std.collection.*
import std.convert.*
import std.regex.*
import std.time.*

class IDSCookieCapture {
    var value: String = ""
}

class IDSHeadersReceiveCb <: Callback1Argument<HashMap<String, String>> {
    let callback: (HashMap<String, String>) -> Unit
    public init(callback: (HashMap<String, String>) -> Unit) { this.callback = callback }
    public open func invoke(err: ?BusinessException, value: HashMap<String, String>): Unit { this.callback(value) }
}

public class IDSLoginPage {
    public let hiddenFields: HashMap<String, String>
    public let encryptSalt: String
    public let cookieHeader: String
    public init(hiddenFields: HashMap<String, String>, encryptSalt: String, cookieHeader: String) {
        this.hiddenFields = hiddenFields
        this.encryptSalt = encryptSalt
        this.cookieHeader = cookieHeader
    }
}

public class SliderCaptcha {
    public let bigImage: String
    public let smallImage: String
    public let aesKey: Array<UInt8>
    public let cookieHeader: String
    public init(bigImage: String, smallImage: String, aesKey: Array<UInt8>, cookieHeader: String) {
        this.bigImage = bigImage
        this.smallImage = smallImage
        this.aesKey = aesKey
        this.cookieHeader = cookieHeader
    }
}

public class IDSReAuthSession {
    public let challengeLocation: String
    public let username: String
    public let service: String
    public let cookieHeader: String
    var multifactor: String = "true"
    public var recipient: String = ""

    public init(challengeLocation: String, username: String, service: String, cookieHeader: String) {
        this.challengeLocation = challengeLocation
        this.username = username
        this.service = service
        this.cookieHeader = cookieHeader
    }

    public func prepare(onReady: () -> Unit, onError: (String) -> Unit): Unit {
        let client = createHttp()
        let headers = HashMap<String, String>()
        if (this.cookieHeader != "") { headers["Cookie"] = this.cookieHeader }
        let getOptions = HttpRequestOptions(method: RequestMethod.Get, header: headers,
            expectDataType: HttpDataType.StringValue, usingCache: false,
            connectTimeout: 10000, readTimeout: 30000)
        try {
            client.request(this.challengeLocation, getOptions, { error, response =>
                match (error) {
                    case Some(value) => client.destroy(); onError("二次认证页面请求失败：${value.message}")
                    case None => match (response) {
                        case Some(page) => if (page.responseCode != 200) {
                            client.destroy(); onError("二次认证页面已失效（HTTP ${page.responseCode}）。")
                        } else {
                            this.switchToSms(client, headers, onReady, onError)
                        }
                        case None => client.destroy(); onError("二次认证页面没有返回响应。")
                    }
                }
            })
        } catch (e: BusinessException) {
            client.destroy(); onError("无法启动二次认证请求：${e.code} ${e.message}")
        }
    }

    func switchToSms(client: HttpRequest, headers: HashMap<String, String>, onReady: () -> Unit, onError: (String) -> Unit): Unit {
        let body = "isMultifactor=${this.formEncode(this.multifactor)}&reAuthType=3&service=${this.formEncode(this.service)}"
        headers["Content-Type"] = "application/x-www-form-urlencoded;charset=UTF-8"
        let options = HttpRequestOptions(method: RequestMethod.Post, header: headers,
            extraData: HttpData.StringData(body), expectDataType: HttpDataType.StringValue,
            usingCache: false, connectTimeout: 10000, readTimeout: 30000)
        client.request("https://ids.xidian.edu.cn/authserver/reAuthCheck/changeReAuthType.do", options, { error, response =>
            match (error) {
                case Some(value) => client.destroy(); onError("无法切换短信二次认证：${value.message}")
                case None => match (response) {
                    case Some(value) => match (value.result) {
                        case HttpData.StringData(text) =>
                            if (!text.contains("\"code\":\"1\"") && !text.contains("\"code\":1")) {
                                client.destroy(); onError(this.errorWithRawResponse(this.jsonMessage(text, "无法切换到短信二次认证"), text))
                            } else {
                                this.recipient = this.jsonString(text, "reAuthUserNameInput")
                                client.destroy(); onReady()
                            }
                        case _ => client.destroy(); onError("切换短信认证返回了非文本响应。")
                    }
                    case None => client.destroy(); onError("切换短信认证没有返回响应。")
                }
            }
        })
    }

    public func sendSms(onResult: (String, Int64) -> Unit, onError: (String) -> Unit): Unit {
        this.postForm("https://ids.xidian.edu.cn/authserver/dynamicCode/getDynamicCodeByReauth.do",
            "userName=${this.formEncode(this.username)}&authCodeTypeName=reAuthDynamicCodeType",
            { text =>
                let result = this.jsonString(text, "res")
                if (result != "success" && result != "code_time_fail") {
                    onError(this.errorWithRawResponse(this.jsonMessage(text, "短信验证码发送失败"), text))
                } else {
                    var seconds: Int64 = 0
                    try { seconds = Int64.parse(this.jsonString(text, "codeTime")) } catch (_) { seconds = 0 }
                    let mobile = this.jsonString(text, "mobile")
                    onResult(this.jsonMessage(text, "验证码已发送") + if (mobile == "") { "" } else { "（${this.maskPhone(mobile)}）" }, seconds)
                }
            }, onError)
    }

    public func submitSms(code: String, trustDevice: Bool, onSuccess: (String) -> Unit, onRejected: (String) -> Unit, onError: (String) -> Unit): Unit {
        let body = "service=${this.formEncode(this.service)}&reAuthType=3&isMultifactor=${this.formEncode(this.multifactor)}&password=&dynamicCode=${this.formEncode(code)}&uuid=&answer1=&answer2=&otpCode=&skipTmpReAuth=${if (trustDevice) { "true" } else { "false" }}"
        this.postForm("https://ids.xidian.edu.cn/authserver/reAuthCheck/reAuthSubmit.do", body, { text =>
            let status = this.jsonString(text, "code")
            let message = this.jsonMessage(text, "二次认证失败")
            let debugMessage = this.errorWithRawResponse(message, text)
            if (status == "reAuth_failed") { onRejected(debugMessage); return }
            if (status == "reAuth_unauthorized") { onError(debugMessage); return }
            if (status != "reAuth_success") { onError(debugMessage); return }
            this.postForm("${IDSSession.loginUrl}?service=${this.formEncode(this.service)}", "", { finalText =>
                if (finalText.contains("http") || finalText != "") { onSuccess(this.cookieHeader) } else { onError("二次认证成功，但未收到业务系统登录结果") }
            }, onError)
        }, onError)
    }

    func postForm(url: String, body: String, onSuccess: (String) -> Unit, onError: (String) -> Unit): Unit {
        let client = createHttp()
        let headers = HashMap<String, String>()
        if (this.cookieHeader != "") { headers["Cookie"] = this.cookieHeader }
        headers["Content-Type"] = "application/x-www-form-urlencoded;charset=UTF-8"
        let options = HttpRequestOptions(method: if (body == "") { RequestMethod.Get } else { RequestMethod.Post }, header: headers,
            extraData: HttpData.StringData(body), expectDataType: HttpDataType.StringValue,
            usingCache: false, connectTimeout: 10000, readTimeout: 30000)
        try {
            client.request(url, options, { error, response =>
                client.destroy()
                match (error) {
                    case Some(value) => onError("二次认证网络错误：${value.message}")
                    case None => match (response) {
                        case Some(value) => match (value.result) {
                            case HttpData.StringData(text) => if (value.responseCode >= 200 && value.responseCode < 400) { onSuccess(text) } else { onError(this.errorWithRawResponse("二次认证返回 HTTP ${value.responseCode}", text)) }
                            case _ => onError("二次认证返回了非文本响应")
                        }
                        case None => onError("二次认证没有返回响应")
                    }
                }
            })
        } catch (e: BusinessException) { client.destroy(); onError("无法启动二次认证请求：${e.code} ${e.message}") }
    }

    func jsonString(text: String, key: String): String {
        let pattern = Regex("\\\"${key}\\\"\\s*:\\s*\\\"([^\\\"]*)\\\"")
        match (pattern.find(text, group: true)) { case Some(value) => value.matchString(1); case None => "" }
    }
    func jsonMessage(text: String, fallback: String): String {
        let message = this.jsonString(text, "returnMessage")
        if (message != "") { return message }
        let msg = this.jsonString(text, "msg")
        if (msg != "") { return msg }
        let generic = this.jsonString(text, "message")
        return if (generic == "") { fallback } else { generic }
    }
    func errorWithRawResponse(message: String, body: String): String {
        if (body.trimAscii() == "") { return message }
        return message + "\n---IDS_RAW_RESPONSE---\n" + body
    }
    func maskPhone(value: String): String {
        if (value.size < 7) { return "****" }
        return value[0..3] + "****" + value[value.size - 4..value.size]
    }
    func formEncode(value: String): String {
        let hex: Array<String> = ["0","1","2","3","4","5","6","7","8","9","A","B","C","D","E","F"]
        var result = ""
        for (byte in value.toArray()) { let n = Int64(byte); if ((n >= 65 && n <= 90) || (n >= 97 && n <= 122) || (n >= 48 && n <= 57) || n == 45 || n == 46 || n == 95 || n == 126) { result += String.fromUtf8([byte]) } else { result += "%${hex[n / 16]}${hex[n % 16]}" } }
        return result
    }
}

public class IDSSession {
    static let loginUrl: String = "https://ids.xidian.edu.cn/authserver/login"
    static let sliderUrl: String = "https://ids.xidian.edu.cn/authserver/common/openSliderCaptcha.htl"
    static let verifySliderUrl: String = "https://ids.xidian.edu.cn/authserver/common/verifySliderCaptcha.htl"

    public func requestLoginPage(target: String, onReady: (IDSLoginPage) -> Unit, onError: (String) -> Unit): Unit {
        let request = createHttp()
        let requestUrl = "${IDSSession.loginUrl}?service=${target}"
        let normalCookies = WebCookieManager.fetchCookie(requestUrl)
        let privateCookies = WebCookieManager.fetchCookie(requestUrl, incognito: true)
        let webCookies = if (normalCookies != "") { normalCookies } else { privateCookies }
        let requestHeaders = HashMap<String, String>()
        if (webCookies != "") { requestHeaders["Cookie"] = webCookies }
        let receivedCookies = IDSCookieCapture()
        let headerCallback = IDSHeadersReceiveCb({ headers =>
            for ((name, value) in headers) {
                match (Regex("^set-cookie$", RegexFlag.IgnoreCase).find(name)) {
                    case Some(_) => receivedCookies.value = value
                    case None => ()
                }
            }
        })
        request.on(HttpRequestEvent.HeadersReceive, headerCallback)
        let options = HttpRequestOptions(method: RequestMethod.Get, header: requestHeaders, expectDataType: HttpDataType.StringValue, usingCache: false, readTimeout: 30000, connectTimeout: 10000)
        try {
            request.request(requestUrl, options, { err, response =>
                request.destroy()
                match (err) {
                    case Some(error) => onError("Network error ${error.code}: ${error.message}")
                    case None => match (response) {
                        case Some(value) => match (value.result) {
                            case HttpData.StringData(html) =>
                                if (value.responseCode == 200) {
                                    try {
                                        let responseCookies = if (receivedCookies.value != "") { receivedCookies.value } else { this.responseCookieText(value.cookies, value.header) }
                                        onReady(this.parseLoginPage(html, this.mergeCookies(webCookies, responseCookies)))
                                    }
                                    catch (e: Exception) { onError("Malformed IDS login page: ${e.message}") }
                                } else { onError("IDS returned HTTP ${value.responseCode}") }
                            case _ => onError("IDS returned an unexpected response format")
                        }
                        case None => onError("IDS returned no response")
                    }
                }
            })
        } catch (e: BusinessException) { request.destroy(); onError("Unable to start IDS request: ${e.code} ${e.message}") }
    }

    public func requestSliderCaptcha(page: IDSLoginPage, onReady: (SliderCaptcha) -> Unit, onError: (String) -> Unit): Unit {
        Hilog.info(1, "IDSLogin", "slider open request started")
        let request = createHttp()
        let headers = HashMap<String, String>()
        if (page.cookieHeader != "") { headers["Cookie"] = page.cookieHeader }
        headers["Accept"] = "application/json, text/javascript, */*; q=0.01"
        headers["User-Agent"] = "Dart/3.12 (dart:io)"
        let options = HttpRequestOptions(method: RequestMethod.Get, header: headers, usingProtocol: HttpProtocol.Http1_1, expectDataType: HttpDataType.StringValue, usingCache: false, readTimeout: 30000, connectTimeout: 10000)
        try {
            let timestamp = DateTime.now().toUnixTimeStamp().toMilliseconds()
            request.request("${IDSSession.sliderUrl}?_=${timestamp}", options, { err, response =>
                request.destroy()
                match (err) {
                    case Some(error) =>
                        Hilog.error(1, "IDSLogin", "slider open network error code=${error.code} message=${this.safeLog(error.message)}")
                        onError("Slider request failed: ${error.code} ${error.message}")
                    case None => match (response) {
                        case Some(value) => match (value.result) {
                            case HttpData.StringData(body) =>
                                if (value.responseCode == 200) {
                                    try {
                                        let big = this.jsonString(body, "bigImage")
                                        let small = this.jsonString(body, "smallImage")
                                        let bytes = IDSPasswordCipher.decodeBase64(small)
                                        if (bytes.size < 16) { throw Exception("slider image did not contain an AES key") }
                                        let key = ArrayList<UInt8>()
                                        var index: Int64 = bytes.size - 16
                                        while (index < bytes.size) { key.add(bytes[index]); index += 1 }
                                        Hilog.info(1, "IDSLogin", "slider open accepted HTTP 200 image payload present")
                                        onReady(SliderCaptcha(big, small, key.toArray(), page.cookieHeader))
                                    } catch (e: Exception) {
                                        Hilog.error(1, "IDSLogin", "slider open malformed response: ${this.safeLog(e.message)}")
                                        onError("Malformed slider response: ${e.message}")
                                    }
                                } else {
                                    Hilog.error(1, "IDSLogin", "slider open rejected HTTP ${value.responseCode}")
                                    onError("Slider returned HTTP ${value.responseCode}")
                                }
                            case _ =>
                                Hilog.error(1, "IDSLogin", "slider open unexpected response data type")
                                onError("Slider returned an unexpected response format")
                        }
                        case None => onError("Slider returned no response")
                    }
                }
            })
        } catch (e: BusinessException) { request.destroy(); onError("Unable to load slider: ${e.code} ${e.message}") }
    }

    public func verifySlider(captcha: SliderCaptcha, move: Int64, tracks: String,
        onResult: (Bool, String, String) -> Unit, onError: (String) -> Unit): Unit {
        try {
            let safeMove = if (move < 0) { 0 } else if (move > 280) { 280 } else { move }
            Hilog.info(1, "IDSLogin", "slider verify request move=${safeMove} trackPoints=${this.trackPointCount(tracks)}")
            if (tracks == "") { throw Exception("Slider gesture track is empty") }
            let payload = "{\"canvasLength\":280,\"moveLength\":${safeMove},\"tracks\":${tracks}}"
            let sign = IDSPasswordCipher.encryptCaptchaPayload(payload, captcha.aesKey)
            let request = createHttp()
            let headers = HashMap<String, String>()
            if (captcha.cookieHeader != "") { headers["Cookie"] = captcha.cookieHeader }
            headers["Accept"] = "application/json, text/javascript, */*; q=0.01"
            headers["Content-Type"] = "application/x-www-form-urlencoded;charset=UTF-8"
            headers["Access-Control-Allow-Origin"] = "https://ids.xidian.edu.cn"
            headers["Origin"] = "https://ids.xidian.edu.cn"
            headers["X-Requested-With"] = "XMLHttpRequest"
            headers["User-Agent"] = "Dart/3.12 (dart:io)"
            let options = HttpRequestOptions(method: RequestMethod.Post, header: headers, usingProtocol: HttpProtocol.Http1_1, extraData: HttpData.ArrayData("sign=${this.formEncode(sign)}".toArray()), expectDataType: HttpDataType.StringValue, usingCache: false, readTimeout: 30000, connectTimeout: 10000)
            request.request(IDSSession.verifySliderUrl, options, { err, response =>
                request.destroy()
                match (err) {
                    case Some(error) =>
                        Hilog.error(1, "IDSLogin", "slider verify network error move=${safeMove} code=${error.code} message=${this.safeLog(error.message)}")
                        onError("滑块网络错误 ${error.code}: ${error.message}")
                    case None => match (response) {
                        case Some(value) => match (value.result) {
                            case HttpData.StringData(body) =>
                                if (value.responseCode == 200) {
                                    let accepted = this.sliderAccepted(body)
                                    let summary = this.sliderResponseSummary(body)
                                    if (accepted) {
                                        Hilog.info(1, "IDSLogin", "slider verify accepted move=${safeMove} ${summary}")
                                    } else {
                                        Hilog.warn(1, "IDSLogin", "slider verify rejected move=${safeMove} ${summary}")
                                    }
                                    onResult(accepted, captcha.cookieHeader, summary)
                                }
                                else {
                                    Hilog.error(1, "IDSLogin", "slider verify HTTP ${value.responseCode} move=${safeMove}")
                                    onError("滑块验证返回 HTTP ${value.responseCode}")
                                }
                            case _ =>
                                Hilog.error(1, "IDSLogin", "slider verify unexpected response type move=${safeMove}")
                                onError("滑块验证返回了非文本响应")
                        }
                        case None => onError("Slider verification returned no response")
                    }
                }
            })
        } catch (e: Exception) {
            Hilog.error(1, "IDSLogin", "slider verify preparation failed move=${move}: ${this.safeLog(e.message)}")
            onError("滑块验证准备失败：${e.message}")
        }
    }
    func sliderAccepted(body: String): Bool {
        let accepted = Regex(#"\"errorCode\"\s*:\s*(\"1\"|1)"#)
        match (accepted.find(body)) { case Some(_) => return true; case None => return false }
    }
    func sliderResponseSummary(body: String): String {
        let code = this.jsonScalar(body, "errorCode")
        let message = this.firstJsonMessage(body)
        return "errorCode=${if (code == "") { "<missing>" } else { code }} message=${if (message == "") { "<empty>" } else { this.safeLog(message) }} bodyBytes=${body.toArray().size}"
    }
    func firstJsonMessage(body: String): String {
        let names: Array<String> = ["message", "msg", "errorMsg", "errorMessage"]
        for (name in names) { let value = this.jsonScalar(body, name); if (value != "") { return value } }
        return ""
    }
    func jsonScalar(body: String, name: String): String {
        let quoted = Regex("\\\"${name}\\\"\\s*:\\s*\\\"([^\\\"]*)\\\"")
        match (quoted.find(body, group: true)) { case Some(value) => return value.matchString(1); case None => () }
        let number = Regex("\\\"${name}\\\"\\s*:\\s*(-?[0-9]+)")
        match (number.find(body, group: true)) { case Some(value) => value.matchString(1); case None => "" }
    }
    func trackPointCount(tracks: String): Int64 {
        var count: Int64 = 0
        for (_ in Regex(#"\"a\"\s*:"#).findAll(tracks)) { count += 1 }
        return count
    }
    func safeLog(value: String): String {
        var result = value.replace("\n", " ").replace("\r", " ")
        if (result.size > 160) { result = result[0..160] }
        return result
    }

    public func submitCredentials(
        page: IDSLoginPage,
        verifiedCookie: String,
        captchaVerified: Bool,
        account: String,
        password: String,
        onSuccess: (String) -> Unit,
        onCaptchaRequired: (IDSLoginPage) -> Unit,
        onReAuthRequired: (IDSReAuthSession) -> Unit,
        onError: (String) -> Unit
    ): Unit {
        try {
            let encrypted = IDSPasswordCipher.encrypt(password, page.encryptSalt)
            var form = ""
            for ((name, value) in page.hiddenFields) {
                if (name != "username" && name != "password" && name != "rememberMe" &&
                    name != "cllt" && name != "dllt" && name != "_eventId") {
                    form = this.addFormField(form, name, value)
                }
            }
            form = this.addFormField(form, "username", account)
            form = this.addFormField(form, "password", encrypted)
            form = this.addFormField(form, "rememberMe", "true")
            form = this.addFormField(form, "cllt", "userNameLogin")
            form = this.addFormField(form, "dllt", "generalLogin")
            form = this.addFormField(form, "_eventId", "submit")
            let headers = HashMap<String, String>()
            headers["Cookie"] = verifiedCookie
            headers["Content-Type"] = "application/x-www-form-urlencoded; charset=UTF-8"
            headers["Origin"] = "https://ids.xidian.edu.cn"
            headers["Referer"] = "${IDSSession.loginUrl}?service=${EhallSession.landingUrl}"
            let request = createHttp()
            let options = HttpRequestOptions(method: RequestMethod.Post, header: headers, usingProtocol: HttpProtocol.Http1_1, extraData: HttpData.StringData(form), expectDataType: HttpDataType.StringValue, usingCache: false, readTimeout: 30000, connectTimeout: 10000)
            request.request("${IDSSession.loginUrl}?service=${EhallSession.landingUrl}", options, { err, response =>
                request.destroy()
                match (err) {
                    case Some(error) => onError(this.errorWithRawResponse("Login network error ${error.code}: ${error.message}", "network_error: ${error.code} ${error.message}"))
                    case None => match (response) {
                        case Some(value) => match (value.result) {
                            case HttpData.StringData(body) =>
                                let cookies = this.mergeCookies(verifiedCookie, this.responseCookieText(value.cookies, value.header))
                                this.handleLoginResponse(value.responseCode, value.header, body, cookies, page,
                                    captchaVerified, account, onSuccess, onCaptchaRequired, onReAuthRequired, onError)
                            case _ => onError(this.errorWithRawResponse("IDS returned an unexpected login response format.", "unexpected_response_format"))
                        }
                        case None => onError(this.errorWithRawResponse("IDS login returned no response", "no_response"))
                    }
                }
            })
        } catch (e: Exception) { onError("Could not prepare IDS credential submission: ${e.message}") }
    }
    func handleLoginResponse(
        code: UInt32,
        headers: HashMap<String, String>,
        body: String,
        cookies: String,
        page: IDSLoginPage,
        captchaVerified: Bool,
        account: String,
        onSuccess: (String) -> Unit,
        onCaptchaRequired: (IDSLoginPage) -> Unit,
        onReAuthRequired: (IDSReAuthSession) -> Unit,
        onError: (String) -> Unit
    ): Unit {
        if (code == 301 || code == 302 || code == 303 || code == 307 || code == 308) {
            match (this.headerValue(headers, "location")) {
                case Some(location) =>
                    if (this.isReAuthLocation(location)) {
                        onReAuthRequired(IDSReAuthSession(this.absoluteIdsUrl(location), account,
                            EhallSession.landingUrl, cookies))
                    } else if (cookies == "") {
                        onError("IDS redirected without creating a session.")
                    } else {
                        onSuccess(cookies)
                    }
                case None => onError("IDS returned a redirect without a Location header.")
            }
            return
        }
        if (code == 401) { onError(this.loginErrorWithRawResponse(body)); return }
        if (code != 200) { onError(this.errorWithRawResponse("IDS login failed with HTTP ${code}.", body)); return }
        if (this.requiresCaptcha(body)) {
            onCaptchaRequired(IDSLoginPage(page.hiddenFields, page.encryptSalt, cookies))
            return
        }
        match (this.continueFields(body)) {
            case Some(fields) => this.submitContinue(fields, cookies, onSuccess, onError); return
            case None => ()
        }
        if (this.isLoginPage(body)) {
            if (!captchaVerified) {
                try { onCaptchaRequired(this.parseLoginPage(body, cookies)) }
                catch (e: Exception) { onError("IDS requested verification but returned an invalid login form: ${e.message}") }
            } else { onError(this.errorWithRawResponse(this.loginErrorMessage(body), body)) }
            return
        }
        if (cookies != "" && this.isEhallPage(body)) { onSuccess(cookies); return }
        onError(this.errorWithRawResponse("IDS returned an unrecognized page after credential submission.", body))
    }
    func submitContinue(fields: HashMap<String, String>, cookieHeader: String, onSuccess: (String) -> Unit, onError: (String) -> Unit): Unit {
        var form = ""
        for ((name, value) in fields) { form = this.addFormField(form, name, value) }
        let headers = HashMap<String, String>()
        headers["Cookie"] = cookieHeader
        headers["Content-Type"] = "application/x-www-form-urlencoded; charset=UTF-8"
        headers["Origin"] = "https://ids.xidian.edu.cn"
        headers["Referer"] = IDSSession.loginUrl
        let request = createHttp()
        let options = HttpRequestOptions(method: RequestMethod.Post, header: headers, usingProtocol: HttpProtocol.Http1_1, extraData: HttpData.StringData(form), expectDataType: HttpDataType.StringValue, usingCache: false, readTimeout: 30000, connectTimeout: 10000)
        try {
            request.request(IDSSession.loginUrl, options, { err, response =>
                request.destroy()
                match (err) {
                    case Some(error) => onError("IDS continuation failed: ${error.code} ${error.message}")
                    case None => match (response) {
                        case Some(value) =>
                            let cookies = this.mergeCookies(cookieHeader, this.responseCookieText(value.cookies, value.header))
                            if (value.responseCode == 301 || value.responseCode == 302 || value.responseCode == 303 ||
                                value.responseCode == 307 || value.responseCode == 308) {
                                match (this.headerValue(value.header, "location")) {
                                    case Some(_) => if (cookies == "") { onError("IDS continuation redirected without a session.") } else { onSuccess(cookies) }
                                    case None => onError("IDS continuation did not include a Location header.")
                                }
                            } else {
                                match (value.result) {
                                    case HttpData.StringData(body) =>
                                        if (value.responseCode == 200 && cookies != "" && this.isEhallPage(body)) { onSuccess(cookies) }
                                        else { onError("IDS continuation did not reach Ehall (HTTP ${value.responseCode}).") }
                                    case _ => onError("IDS continuation returned an unexpected response format.")
                                }
                            }
                        case None => onError("IDS continuation returned no response.")
                    }
                }
            })
        } catch (e: BusinessException) { request.destroy(); onError("Unable to start IDS continuation: ${e.code} ${e.message}") }
    }
    func continueFields(html: String): ?HashMap<String, String> {
        let formPattern = Regex(#"<form\b[^>]*\bid\s*=\s*[\"']continue[\"'][^>]*>([\s\S]*?)</form>"#, RegexFlag.IgnoreCase)
        match (formPattern.find(html, group: true)) {
            case Some(found) =>
                let fields = HashMap<String, String>()
                this.collectInputs(found.matchString(1), fields, false)
                return if (fields.size == 0) { None } else { Some(fields) }
            case None => return None
        }
    }

    func requiresCaptcha(html: String): Bool {
        let lower = html.toAsciiLower()
        return lower.contains("captcha-required") || lower.contains("data-captcha-required=\"true\"") ||
            lower.contains("\"needcaptcha\":true") || lower.contains("\"needcaptcha\":\"true\"")
    }

    func isLoginPage(html: String): Bool {
        let lower = html.toAsciiLower()
        return lower.contains("pwdencryptsalt") || lower.contains("username") && lower.contains("_eventid")
    }
    func advertisesSlider(html: String): Bool {
        let lower = html.toAsciiLower()
        return lower.contains("openslidercaptcha") && lower.contains("verifyslidercaptcha")
    }

    func isEhallPage(html: String): Bool {
        let lower = html.toAsciiLower()
        return lower.contains("ehall") || lower.contains("new/index.html") || lower.contains("servicehall")
    }

    func loginErrorMessage(html: String): String {
        let errorPattern = Regex(#"<[^>]*\bid\s*=\s*[\"']showErrorTip[\"'][^>]*>([\s\S]*?)</[^>]+>"#, RegexFlag.IgnoreCase)
        match (errorPattern.find(html, group: true)) {
            case Some(found) =>
                let text = Regex(#"<[^>]+>"#).replaceAll(found.matchString(1), "").trimAscii()
                if (text != "") {
                    if (text.toAsciiLower().contains("password")) { return "The account or password is incorrect." }
                    return text
                }
            case None => ()
        }
        return "IDS rejected the account or password."
    }

    func errorWithRawResponse(message: String, body: String): String {
        if (body.trimAscii() == "") { return message }
        return message + "\n---IDS_RAW_RESPONSE---\n" + body
    }

    func loginErrorWithRawResponse(body: String): String {
        return this.errorWithRawResponse(this.loginErrorMessage(body), body)
    }

    func isReAuthLocation(value: String): Bool {
        return value.contains("/authserver/reAuthCheck/reAuthLoginView.do")
    }
    func absoluteIdsUrl(value: String): String {
        if (value.startsWith("https://") || value.startsWith("http://")) { return value }
        return if (value.startsWith("/")) { "https://ids.xidian.edu.cn" + value } else { "https://ids.xidian.edu.cn/" + value }
    }

    func headerValue(headers: HashMap<String, String>, name: String): ?String {
        for ((key, value) in headers) {
            if (key.toAsciiLower() == name.toAsciiLower()) { return Some(value) }
        }
        return None
    }

    func addFormField(form: String, name: String, value: String): String {
        let prefix = if (form == "") { "" } else { "&" }
        return form + prefix + this.formEncode(name) + "=" + this.formEncode(value)
    }
    func parseLoginPage(html: String, cookies: String): IDSLoginPage {
        let fields = HashMap<String, String>()
        let inputs = Regex(#"<input\b[^>]*>"#, RegexFlag.IgnoreCase)
        let name = Regex(#"\bname\s*=\s*[\"']([^\"']+)[\"']"#, RegexFlag.IgnoreCase)
        let value = Regex(#"\bvalue\s*=\s*[\"']([^\"']*)[\"']"#, RegexFlag.IgnoreCase)
        let hiddenType = Regex(#"\btype\s*=\s*[\"']hidden[\"']"#, RegexFlag.IgnoreCase)
        let id = Regex(#"\bid\s*=\s*[\"']pwdEncryptSalt[\"']"#, RegexFlag.IgnoreCase)
        var salt = ""
        for (input in inputs.findAll(html)) {
            let item = input.matchString()
            match (name.find(item, group: true)) {
                case Some(nameMatch) => match (value.find(item, group: true)) {
                    case Some(valueMatch) =>
                        match (hiddenType.find(item)) { case Some(_) => fields[nameMatch.matchString(1)] = valueMatch.matchString(1); case None => () }
                        match (id.find(item)) { case Some(_) => salt = valueMatch.matchString(1); case None => () }
                    case None => ()
                }
                case None => ()
            }
        }
        if (salt == "") {
            let legacySalt = Regex(#"id=[\"']pwdEncryptSalt[\"'][^>]*value=[\"']([^\"']+)[\"']"#, RegexFlag.IgnoreCase)
            match (legacySalt.find(html, group: true)) { case Some(found) => salt = found.matchString(1); case None => () }
        }
        if (salt == "") { throw Exception("pwdEncryptSalt was not present") }
        return IDSLoginPage(fields, salt, this.mergeCookies("", cookies))
    }

    func collectInputs(html: String, fields: HashMap<String, String>, hiddenOnly: Bool): Unit {
        let inputs = Regex(#"<input\b[^>]*>"#, RegexFlag.IgnoreCase)
        let name = Regex(#"\bname\s*=\s*[\"']([^\"']+)[\"']"#, RegexFlag.IgnoreCase)
        let value = Regex(#"\bvalue\s*=\s*[\"']([^\"']*)[\"']"#, RegexFlag.IgnoreCase)
        let hiddenType = Regex(#"\btype\s*=\s*[\"']hidden[\"']"#, RegexFlag.IgnoreCase)
        for (input in inputs.findAll(html)) {
            let item = input.matchString()
            match (name.find(item, group: true)) {
                case Some(nameMatch) => match (value.find(item, group: true)) {
                    case Some(valueMatch) =>
                        if (!hiddenOnly) { fields[nameMatch.matchString(1)] = valueMatch.matchString(1) }
                        else { match (hiddenType.find(item)) { case Some(_) => fields[nameMatch.matchString(1)] = valueMatch.matchString(1); case None => () } }
                    case None => ()
                }
                case None => ()
            }
        }
    }
    func jsonString(body: String, name: String): String {
        let expression = Regex("\\\"${name}\\\"\\s*:\\s*\\\"([^\\\"]+)\\\"")
        match (expression.find(body, group: true)) { case Some(value) => return value.matchString(1); case None => throw Exception("${name} was not present") }
    }

    func responseCookieText(cookies: String, headers: HashMap<String, String>): String {
        if (cookies != "") { return cookies }
        for ((name, value) in headers) {
            match (Regex("^set-cookie$", RegexFlag.IgnoreCase).find(name)) {
                case Some(_) => return value
                case None => ()
            }
        }
        return ""
    }

    func mergeCookies(existing: String, raw: String): String {
        let values = ArrayList<String>()
        // `existing` is already a Cookie request header, so every semicolon
        // separates a cookie pair. Treating it as Set-Cookie discarded every
        // pair after the first one and invalidated the IDS slider session.
        for (pair in Regex(";").split(existing)) {
            this.upsertCookie(values, pair.trimAscii())
        }
        // `raw` is the response's Set-Cookie text. Each line/comma starts a
        // cookie and attributes after the first semicolon are not request data.
        for (line in Regex("[\\r\\n,]+").split(raw)) {
            let fields = Regex(";").split(line)
            if (fields.size > 0) { this.upsertCookie(values, fields[0].trimAscii()) }
        }
        var result = ""
        for (item in values) { if (result != "") { result += "; " }; result += item }
        return result
    }

    func upsertCookie(values: ArrayList<String>, pair: String): Unit {
        if (!pair.contains("=")) { return }
        let equal = Regex("=").split(pair)
        if (equal.size == 0 || equal[0] == "") { return }
        let prefix = "${equal[0]}="
        var index: Int64 = 0
        while (index < values.size) {
            if (values[index].startsWith(prefix)) { values[index] = pair; return }
            index += 1
        }
        values.add(pair)
    }
    func cookieCount(header: String): Int64 {
        var count: Int64 = 0
        for (pair in Regex(";").split(header)) { if (pair.contains("=")) { count += 1 } }
        return count
    }

    func formEncode(value: String): String {
        let hex: Array<String> = ["0","1","2","3","4","5","6","7","8","9","A","B","C","D","E","F"]
        var result = ""
        for (byte in value.toArray()) {
            let n = Int64(byte)
            if (n >= 65 && n <= 90) { result += IDSPasswordCipher.base64Alphabet[n - 65] }
            else if (n >= 97 && n <= 122) { result += IDSPasswordCipher.base64Alphabet[n - 71] }
            else if (n >= 48 && n <= 57) { result += IDSPasswordCipher.base64Alphabet[n + 4] }
            else if (n == 43) { result += "%2B" }
            else if (n == 47) { result += "%2F" }
            else if (n == 61) { result += "%3D" }
            else { result += "%${hex[n / 16]}${hex[n % 16]}" }
        }
        return result
    }
}

public class EhallSession {
    public static let landingUrl: String = "https://ehall.xidian.edu.cn/login?service=https://ehall.xidian.edu.cn/new/index.html"
    public let ids: IDSSession = IDSSession()
}
