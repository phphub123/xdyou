package ohos_app_cangjie_entry.repository.xidian_ids

import kit.NetworkKit.*
import ohos.business_exception.*
import ohos.callback_invoke.*
import std.collection.*
import std.regex.*
import std.convert.*
import stdx.encoding.json.*
import ohos_app_cangjie_entry.repository.*
import ohos_app_cangjie_entry.model.*

class EnergyHeadersCb <: Callback1Argument<HashMap<String, String>> {
    let action: (HashMap<String, String>) -> Unit
    public init(action: (HashMap<String, String>) -> Unit) { this.action = action }
    public open func invoke(err: ?BusinessException, value: HashMap<String, String>): Unit { this.action(value) }
}

class EnergyHeaderCapture {
    var cookies: String = ""
    var code: String = ""
}

public class EnergySession {
    static let energyBase = "https://ignypt.xidian.edu.cn"
    static let key = "1234567812345678"
    static let iv = "1234567812345678"
    static let loginTarget = "https://xxcapp.xidian.edu.cn/uc/api/oauth/index?redirect=" +
        "https://ignypt.xidian.edu.cn/revenueH5/login?opcode=MPAY&" +
        "appid=200260318155520600&state=12312312312312&qrcode=0"
    private var cookieHeader: String = ""

    func session(): Unit {
        let snapshot = SessionStore().restore()
        if (!snapshot.loggedIn || snapshot.cookieHeader == "") {
            throw Exception("电量查询需要真实 IDS 会话，请重新登录。")
        }
        this.cookieHeader = snapshot.cookieHeader
    }

    func headerValue(headers: HashMap<String, String>, name: String): String {
        for ((key, value) in headers) { if (key.toAsciiLower() == name.toAsciiLower()) { return value } }
        return ""
    }
    func mergeCookies(base: String, raw: String): String {
        let values = ArrayList<String>()
        for (pair in Regex(";").split(base)) { this.upsert(values, pair.trimAscii()) }
        for (line in Regex("[\\r\\n,]+").split(raw)) {
            let columns = Regex("\\t").split(line)
            if (columns.size >= 7) {
                this.upsert(values, "${columns[columns.size - 2]}=${columns[columns.size - 1]}")
                continue
            }
            let pieces = Regex(";").split(line); var index: Int64 = 0
            while (index < pieces.size) {
                let pair = pieces[index].trimAscii(); let fields = Regex("=").split(pair)
                let name = if (fields.size > 0) { fields[0].toAsciiLower() } else { "" }
                if (index == 0 || !this.isCookieAttribute(name)) { this.upsert(values, pair) }
                index += 1
            }
        }
        var result = ""; for (item in values) { if (result != "") { result += "; " }; result += item }; return result
    }
    func isCookieAttribute(name: String): Bool {
        return name == "path" || name == "domain" || name == "expires" ||
            name == "max-age" || name == "samesite" || name == "secure" ||
            name == "httponly" || name == "priority" || name == "partitioned"
    }
    func upsert(values: ArrayList<String>, pair: String): Unit {
        if (!pair.contains("=")) { return }; let pieces = Regex("=").split(pair)
        if (pieces.size == 0 || pieces[0] == "") { return }; let prefix = pieces[0] + "="
        var index: Int64 = 0; while (index < values.size) { if (values[index].startsWith(prefix)) { values[index] = pair; return }; index += 1 }; values.add(pair)
    }
    func codeFromLocation(raw: String): String {
        let normalized = raw.replace("%3F", "?").replace("%3f", "?")
            .replace("%26", "&").replace("%3D", "=").replace("%3d", "=")
        match (Regex(#"(?:[?&])code=([^&#\"']+)"#, RegexFlag.IgnoreCase).find(normalized, group: true)) {
            case Some(found) => return found.matchString(1)
            case None => return ""
        }
    }
    func formEncode(value: String): String {
        let hex: Array<String> = ["0","1","2","3","4","5","6","7","8","9","A","B","C","D","E","F"]
        var result = ""; for (byte in value.toArray()) { let n = Int64(byte)
            if ((n>=65&&n<=90)||(n>=97&&n<=122)||(n>=48&&n<=57)||n==45||n==46||n==95||n==126) { result += String.fromUtf8([byte]) }
            else { result += "%${hex[n/16]}${hex[n%16]}" }
        }; return result
    }

    func authenticate(success: (String) -> Unit, failure: (String) -> Unit): Unit {
        if (this.cookieHeader == "") { try { this.session() } catch (error: Exception) { failure(error.message); return } }
        let capture = EnergyHeaderCapture()
        let request = createHttp()
        let callback = EnergyHeadersCb({ headers =>
            let location = this.headerValue(headers, "location")
            let code = this.codeFromLocation(location)
            if (code != "") { capture.code = code }
            let raw = this.headerValue(headers, "set-cookie")
            if (raw != "") { capture.cookies = this.mergeCookies(capture.cookies, raw) }
        })
        request.on(HttpRequestEvent.HeadersReceive, callback)
        let headers = HashMap<String, String>()
        headers["Cookie"] = this.cookieHeader
        headers["User-Agent"] = IDSSession.browserUserAgent
        let url = IDSSession.loginUrl + "?service=" + this.formEncode(EnergySession.loginTarget)
        let options = HttpRequestOptions(method: RequestMethod.Get, header: headers, usingProtocol: HttpProtocol.Http1_1,
            expectDataType: HttpDataType.StringValue, usingCache: false, connectTimeout: 10000, readTimeout: 30000)
        try {
            request.request(url, options, { error, response =>
                request.destroy()
                match (error) {
                    case Some(value) => failure("电量认证网络错误 ${value.code}: ${value.message}")
                    case None => match (response) {
                        case Some(value) => match (value.result) {
                            case HttpData.StringData(body) =>
                                this.cookieHeader = this.mergeCookies(this.cookieHeader, capture.cookies + "\n" + value.cookies)
                                if (capture.code != "") { success(capture.code) }
                                else if (body.toAsciiLower().contains("pwdencryptsalt") || body.contains("authserver/login")) {
                                    failure("IDS 会话已失效，电量查询需要重新登录。")
                                } else { failure("电量认证未返回授权码，请确认当前连接校园网。") }
                            case _ => failure("电量认证返回了非文本响应。")
                        }
                        case None => failure("电量认证未返回响应。")
                    }
                }
            })
        } catch (error: BusinessException) {
            request.destroy(); failure("无法启动电量认证：${error.code} ${error.message}")
        }
    }
    func plainRequest(url: String, body: String, success: (String) -> Unit, failure: (String) -> Unit): Unit {
        let request = createHttp(); let headers = HashMap<String, String>()
        headers["Content-Type"] = "application/x-www-form-urlencoded; charset=UTF-8"; headers["Accept"] = "application/json"; headers["User-Agent"] = IDSSession.browserUserAgent
        if (this.cookieHeader != "") { headers["Cookie"] = this.cookieHeader }
        let options = HttpRequestOptions(method: RequestMethod.Post, header: headers, extraData: HttpData.StringData(body),
            expectDataType: HttpDataType.StringValue, usingCache: false, connectTimeout: 10000, readTimeout: 30000)
        try { request.request(url, options, { error, response => request.destroy(); match (error) {
            case Some(value) => failure("电量服务网络错误 ${value.code}: ${value.message}")
            case None => match (response) { case Some(value) => match (value.result) {
                case HttpData.StringData(text) => if (value.responseCode == 200) { success(text) } else { failure("电量服务返回 HTTP ${value.responseCode}。") }
                case _ => failure("电量服务返回了非文本响应。")
            }; case None => failure("电量服务未返回响应。") }
        } }) } catch (error: BusinessException) { request.destroy(); failure("无法启动电量请求：${error.code} ${error.message}") }
    }

    func signedRequest(url: String, data: String, isGet: Bool, success: (String) -> Unit, failure: (String) -> Unit): Unit {
        let signatureBody = "data=&access_token=&OpCode=MPAY&RequestID="
        this.plainRequest(EnergySession.energyBase + "/baseNew/api/User/GetSignature", signatureBody, { signatureText =>
            try {
                let dataObject = JsonValue.fromStr(signatureText).asObject().get("data").getOrThrow().asObject()
                let timestamp = this.field(dataObject, "timestamp"); let signature = this.field(dataObject, "signature")
                if (timestamp == "" || signature == "") { failure("电量签名响应缺少必要字段。"); return }
                let encrypted = IDSPasswordCipher.encryptServicePayload(data, EnergySession.key, EnergySession.iv)
                let request = createHttp(); let headers = HashMap<String, String>()
                if (this.cookieHeader != "") { headers["Cookie"] = this.cookieHeader }
                headers["timestamp"] = timestamp; headers["signature"] = signature; headers["OpCode"] = "MPAY"
                headers["OrgId"] = ""; headers["RequestID"] = ""; headers["Content-Type"] = "application/json"
                let target = if (isGet) { url + "?content=" + this.formEncode(this.formEncode(encrypted)) } else { url }
                let options = if (isGet) {
                    HttpRequestOptions(method: RequestMethod.Get, header: headers, expectDataType: HttpDataType.StringValue,
                        usingCache: false, connectTimeout: 10000, readTimeout: 30000)
                } else {
                    HttpRequestOptions(method: RequestMethod.Post, header: headers,
                        extraData: HttpData.StringData("{\"content\":${this.jsonQuoteEnergy(encrypted)}}"), expectDataType: HttpDataType.StringValue,
                        usingCache: false, connectTimeout: 10000, readTimeout: 30000)
                }
                request.request(target, options, { error, response => request.destroy(); match (error) {
                    case Some(value) => failure("电量业务网络错误 ${value.code}: ${value.message}")
                    case None => match (response) { case Some(value) => match (value.result) {
                        case HttpData.StringData(text) => if (value.responseCode == 200) { success(text) } else { failure("电量业务返回 HTTP ${value.responseCode}。") }
                        case _ => failure("电量业务返回了非文本响应。")
                    }; case None => failure("电量业务未返回响应。") }
                } })
            } catch (error: Exception) { failure("电量签名解析失败：${error.message}") }
        }, failure)
    }

    public func loadAuthorized(rawUrl: String, browserCookies: String,
        success: (EnergyInfo) -> Unit, failure: (String) -> Unit): Unit {
        let code = this.codeFromLocation(rawUrl)
        try { this.session() } catch (error: Exception) { failure(error.message); return }
        this.cookieHeader = this.mergeCookies(this.cookieHeader, browserCookies)
        if (code == "") {
            this.authenticate({ freshCode => this.loadAuthorized("?code=" + freshCode, browserCookies, success, failure) }, failure)
            return
        }
        this.signedRequest(EnergySession.energyBase + "/estManage/api/WeChat/V2/OauthGetUserInfo", "{\"CODE\":${this.jsonQuoteEnergy(code)}}", true, { _ =>
            let account = SessionStore().restore().account
            let login = "{\"UserID\":${this.jsonQuoteEnergy(account)},\"Pwd\":\"\",\"IsCehckPwd\":1,\"NodeID\":\"\"}"
            this.signedRequest(EnergySession.energyBase + "/estManage/api/WeChat/V2/H5UserIDLogIn", login, false, { loginText =>
                try {
                    let root = JsonValue.fromStr(loginText).asObject()
                    let rows = root.get("ResData").getOrThrow().asArray()
                    if (rows.size() == 0) { failure("电量账户未返回宿舍节点。"); return }
                    this.loadMeters(this.field(rows[0].asObject(), "NodeID"), success, failure)
                } catch (error: Exception) { failure("电量账户响应解析失败：${error.message}") }
            }, failure)
        }, failure)
    }
    public func load(success: (EnergyInfo) -> Unit, failure: (String) -> Unit): Unit {
        this.authenticate({ code =>
            this.signedRequest(EnergySession.energyBase + "/estManage/api/WeChat/V2/OauthGetUserInfo", "{\"CODE\":${this.jsonQuoteEnergy(code)}}", true, { _ =>
                let account = SessionStore().restore().account
                let login = "{\"UserID\":${this.jsonQuoteEnergy(account)},\"Pwd\":\"\",\"IsCehckPwd\":1,\"NodeID\":\"\"}"
                this.signedRequest(EnergySession.energyBase + "/estManage/api/WeChat/V2/H5UserIDLogIn", login, false, { loginText =>
                    try {
                        let root = JsonValue.fromStr(loginText).asObject(); let rows = root.get("ResData").getOrThrow().asArray()
                        if (rows.size() == 0) { failure("电量账户未返回宿舍节点。"); return }
                        let nodeId = this.field(rows[0].asObject(), "NodeID")
                        this.loadMeters(nodeId, success, failure)
                    } catch (error: Exception) { failure("电量账户响应解析失败：${error.message}") }
                }, failure)
            }, failure)
        }, failure)
    }

    func loadMeters(nodeId: String, success: (EnergyInfo) -> Unit, failure: (String) -> Unit): Unit {
        this.signedRequest(EnergySession.energyBase + "/estManage/api/wechat/v2/H5QueryMeterList",
            "{\"NodeID\":${this.jsonQuoteEnergy(nodeId)}}", true, { text =>
            try {
                let root = JsonValue.fromStr(text).asObject(); let data = root.get("ResData").getOrThrow().asObject()
                let rows = data.get("rows").getOrThrow().asArray(); if (rows.size() == 0) { failure("宿舍未绑定电表。"); return }
                var electricIndex: Int64 = 0
                if (rows.size() > 1 && this.field(rows[0].asObject(), "MediumCode") != "2") { electricIndex = 1 }
                let electric = rows[electricIndex].asObject(); let remain = this.field(electric, "LastNum")
                let meterId = this.field(electric, "MetID"); let lastDate = this.field(electric, "LastReadDate")
                let range = this.previousMonth(lastDate)
                let query = "{\"MetID\":${this.jsonQuoteEnergy(meterId)},\"ReadTimeS\":${this.jsonQuoteEnergy(range)}," +
                    "\"ReadTimeE\":${this.jsonQuoteEnergy(lastDate)},\"ReadNum\":\"\"}"
                this.signedRequest(EnergySession.energyBase + "/estManage/api/WeChat/V2/GetMetRead", query, true, { historyText =>
                    try { success(EnergyInfo(lastDate, remain, this.parseReadings(historyText), ArrayList<MeterReading>())) }
                    catch (error: Exception) { failure("电量历史解析失败：${error.message}") }
                }, failure)
            } catch (error: Exception) { failure("电表列表解析失败：${error.message}") }
        }, failure)
    }
    func parseReadings(text: String): ArrayList<MeterReading> {
        let root = JsonValue.fromStr(text).asObject(); let data = root.get("ResData").getOrThrow().asObject()
        let rows = data.get("rows").getOrThrow().asArray(); let result = ArrayList<MeterReading>(); var index: Int64 = 0
        while (index < rows.size()) { let row = rows[index].asObject(); result.add(MeterReading(this.field(row,"ReadTime"), this.field(row,"ReadNum"), this.field(row,"StartNum"), this.field(row,"EndNum"))); index += 1 }; return result
    }
    func previousMonth(date: String): String {
        let pieces = Regex("-").split(date); if (pieces.size < 3) { return date }
        try { var year = Int64.parse(pieces[0]); var month = Int64.parse(pieces[1]); if (month <= 1) { year -= 1; month = 12 } else { month -= 1 }
            return "${year}-${if (month < 10) { "0${month}" } else { month.toString() }}-${pieces[2]}"
        } catch (_) { return date }
    }
    func jsonQuoteEnergy(value: String): String { return "\"" + value.replace("\\","\\\\").replace("\"","\\\"").replace("\n","\\n") + "\"" }
    func stringOf(value: JsonValue): String { match (value.kind()) { case JsString => value.asString().getValue(); case JsInt => value.asInt().getValue().toString(); case JsFloat => value.asFloat().getValue().toString(); case _ => "" } }
    func field(object: JsonObject, name: String): String { match (object.get(name)) { case Some(value) => this.stringOf(value); case None => "" } }
}
