package ohos_app_cangjie_entry.repository

import kit.NetworkKit.*
import kit.ArkWeb.*
import ohos.business_exception.*
import ohos.callback_invoke.*
import std.collection.*
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
                    case Some(error) => onError("Slider request failed: ${error.code} ${error.message}")
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
                                        onReady(SliderCaptcha(big, small, key.toArray(), page.cookieHeader))
                                    } catch (e: Exception) { onError("Malformed slider response: ${e.message}") }
                                } else { onError("Slider returned HTTP ${value.responseCode}") }
                            case _ => onError("Slider returned an unexpected response format")
                        }
                        case None => onError("Slider returned no response")
                    }
                }
            })
        } catch (e: BusinessException) { request.destroy(); onError("Unable to load slider: ${e.code} ${e.message}") }
    }

    public func verifySlider(captcha: SliderCaptcha, move: Int64, tracks: String, onResult: (Bool, String) -> Unit, onError: (String) -> Unit): Unit {
        try {
            let safeMove = if (move < 0) { 0 } else if (move > 280) { 280 } else { move }
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
                    case Some(error) => onError("Slider verification failed: ${error.code} ${error.message}")
                    case None => match (response) {
                        case Some(value) => match (value.result) {
                            case HttpData.StringData(body) =>
                                if (value.responseCode == 200) {
                                    let accepted = this.sliderAccepted(body)
                                    onResult(accepted, captcha.cookieHeader)
                                }
                                else { onError("Slider verification returned HTTP ${value.responseCode}") }
                            case _ => onError("Slider verification returned an unexpected response format")
                        }
                        case None => onError("Slider verification returned no response")
                    }
                }
            })
        } catch (e: Exception) { onError("Could not prepare slider verification: ${e.message}") }
    }
    func sliderAccepted(body: String): Bool {
        let accepted = Regex(#"\"errorCode\"\s*:\s*(\"1\"|1)"#)
        match (accepted.find(body)) { case Some(_) => return true; case None => return false }
    }

    public func submitCredentials(
        page: IDSLoginPage,
        verifiedCookie: String,
        captchaVerified: Bool,
        account: String,
        password: String,
        onSuccess: (String) -> Unit,
        onCaptchaRequired: (IDSLoginPage) -> Unit,
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
                    case Some(error) => onError("Login network error ${error.code}: ${error.message}")
                    case None => match (response) {
                        case Some(value) => match (value.result) {
                            case HttpData.StringData(body) =>
                                let cookies = this.mergeCookies(verifiedCookie, this.responseCookieText(value.cookies, value.header))
                                this.handleLoginResponse(value.responseCode, value.header, body, cookies, page, captchaVerified, onSuccess, onCaptchaRequired, onError)
                            case _ => onError("IDS returned an unexpected login response format.")
                        }
                        case None => onError("IDS login returned no response")
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
        onSuccess: (String) -> Unit,
        onCaptchaRequired: (IDSLoginPage) -> Unit,
        onError: (String) -> Unit
    ): Unit {
        if (code == 301 || code == 302 || code == 303 || code == 307 || code == 308) {
            match (this.headerValue(headers, "location")) {
                case Some(_) => if (cookies == "") { onError("IDS redirected without creating a session.") } else { onSuccess(cookies) }
                case None => onError("IDS returned a redirect without a Location header.")
            }
            return
        }
        if (code == 401) { onError(this.loginErrorMessage(body)); return }
        if (code != 200) { onError("IDS login failed with HTTP ${code}."); return }
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
            } else { onError(this.loginErrorMessage(body)) }
            return
        }
        if (cookies != "" && this.isEhallPage(body)) { onSuccess(cookies); return }
        onError("IDS returned an unrecognized page after credential submission.")
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
