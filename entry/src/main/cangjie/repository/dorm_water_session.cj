package ohos_app_cangjie_entry.repository

import kit.ArkData.*
import kit.CryptoArchitectureKit.*
import kit.NetworkKit.*
import ohos.business_exception.*
import std.collection.*
import std.convert.*
import std.regex.*
import std.time.*
import stdx.encoding.json.*
import ohos_app_cangjie_entry.common.*
import ohos_app_cangjie_entry.model.*

class DormWaterTokenStore {
    let preferences: Preferences = Preferences.getPreferences(AppContext.get(), "xdyou_dorm_water")

    func save(token: String): Unit {
        this.preferences.put("tokenEncrypted", PreferencesValueType.StringData(SecureSessionCipher.encrypt(token)))
        this.preferences.flush()
    }
    func restore(): String {
        match (this.preferences.get("tokenEncrypted", PreferencesValueType.StringData(""))) {
            case PreferencesValueType.StringData(value) =>
                if (value == "") { return "" }
                try { return SecureSessionCipher.decrypt(value) } catch (_) { this.clear(); return "" }
            case _ => return ""
        }
    }
    func clear(): Unit {
        this.preferences.delete("tokenEncrypted")
        this.preferences.flush()
    }
}

public class DormWaterSession {
    static let baseUrl: String = "https://i.ilife798.com"
    static let userAgent: String = "Android_ilife798_2.0.11"
    var currentSessionId: String = ""
    let tokenStore = DormWaterTokenStore()

    public func isLoggedIn(): Bool { return this.tokenStore.restore() != "" }
    public func logout(): Unit { this.tokenStore.clear() }

    public func loadCaptcha(success: (DormWaterCaptcha) -> Unit, failure: (String) -> Unit): Unit {
        let random = createRandom().generateRandom(16).data
        var generatedSessionId = ""
        for (value in random) { generatedSessionId += (Int64(value) % 10).toString() }
        let sessionId = generatedSessionId
        let timestamp = DateTime.now().toUnixTimeStamp().toMilliseconds()
        let client = createHttp()
        let headers = this.headers("", captcha: true)
        let options = HttpRequestOptions(method: RequestMethod.Get, header: headers, expectDataType: HttpDataType.ArrayBuffer,
            usingCache: false, connectTimeout: 10000, readTimeout: 30000)
        try {
            client.request("${DormWaterSession.baseUrl}/api/v1/captcha/?s=${sessionId}&r=${timestamp}", options, { error, response =>
                client.destroy()
                match (error) {
                    case Some(value) => failure("饮水验证码网络错误 ${value.code}: ${value.message}")
                    case None => match (response) {
                        case Some(value) =>
                            if (value.responseCode != 200) { failure("饮水验证码返回 HTTP ${value.responseCode}") }
                            else { match (value.result) {
                                case HttpData.ArrayData(bytes) =>
                                    this.currentSessionId = sessionId
                                    success(DormWaterCaptcha(sessionId, IDSPasswordCipher.toBase64(bytes)))
                                case _ => failure("饮水验证码返回了非图片响应")
                            } }
                        case None => failure("饮水验证码未返回响应")
                    }
                }
            })
        } catch (error: BusinessException) { client.destroy(); failure("无法请求饮水验证码：${error.code} ${error.message}") }
    }

    public func sendSms(phone: String, imageCode: String, success: (String) -> Unit, failure: (String) -> Unit): Unit {
        if (this.currentSessionId == "") { failure("请先加载图片验证码"); return }
        if (!this.validPhone(phone) || !this.validCode(imageCode)) { failure("手机号或图片验证码格式不正确"); return }
        let body = "{\"s\":\"${this.currentSessionId}\",\"authCode\":\"${imageCode}\",\"un\":\"${phone}\"}"
        this.postJson("/api/v1/acc/login/code", body, "", { text =>
            this.requireSuccess(text, { _ => success("短信验证码已发送") }, failure)
        }, failure)
    }

    public func login(phone: String, smsCode: String, success: () -> Unit, failure: (String) -> Unit): Unit {
        if (!this.validPhone(phone) || !this.validCode(smsCode)) { failure("手机号或短信验证码格式不正确"); return }
        let body = "{\"cid\":\"\",\"authCode\":\"${smsCode}\",\"un\":\"${phone}\"}"
        this.postJson("/api/v1/acc/login", body, "", { text =>
            this.requireSuccess(text, { root =>
                try {
                    let data = root["data"].asObject()["al"].asObject()
                    let token = this.field(data, "token")
                    if (token == "") { throw Exception("服务端未返回登录令牌") }
                    this.tokenStore.save(token)
                    success()
                } catch (error: Exception) { failure("饮水登录响应解析失败：${error.message}") }
            }, failure)
        }, failure)
    }

    public func loadDevices(success: (ArrayList<DormWaterDevice>) -> Unit, failure: (String) -> Unit): Unit {
        let token = this.tokenStore.restore()
        if (token == "") { failure("饮水登录已失效，请重新登录"); return }
        this.getText("/api/v1/ui/app/master", token, { text =>
            this.requireSuccess(text, { root =>
                try {
                    let data = root["data"].asObject()
                    match (data.get("account")) { case None => this.logout(); failure("饮水登录已失效，请重新登录"); return; case _ => () }
                    let result = ArrayList<DormWaterDevice>()
                    match (data.get("favos")) {
                        case Some(value) =>
                            let rows = value.asArray(); var index: Int64 = 0
                            while (index < rows.size()) {
                                let item = rows[index].asObject()
                                let id = this.field(item, "id")
                                if (id != "") { result.add(DormWaterDevice(id, this.field(item, "name"))) }
                                index += 1
                            }
                        case None => ()
                    }
                    success(result)
                } catch (error: Exception) { failure("饮水设备列表解析失败：${error.message}") }
            }, failure)
        }, failure)
    }

    public func removeFavorite(deviceId: String, success: () -> Unit, failure: (String) -> Unit): Unit {
        this.deviceGet("/api/v1/dev/favo?did=${deviceId}&remove=true", { _ => success() }, failure)
    }
    public func addFavorite(deviceId: String, success: () -> Unit, failure: (String) -> Unit): Unit {
        if (!this.validDeviceId(deviceId)) { failure("饮水设备 ID 格式不正确") ; return }
        this.deviceGet("/api/v1/dev/favo?did=${deviceId}&remove=false", { _ => success() }, failure)
    }
    public func startWater(deviceId: String, success: () -> Unit, failure: (String) -> Unit): Unit {
        this.deviceGet("/api/v1/dev/start?args=&cnt=1&did=${deviceId}&pip=21&rcp=0&upgrade=1", { _ => success() }, failure)
    }
    public func endWater(deviceId: String, success: () -> Unit, failure: (String) -> Unit): Unit {
        this.deviceGet("/api/v1/dev/end?did=${deviceId}", { _ => success() }, failure)
    }
    public func checkStatus(deviceId: String, success: (Int64) -> Unit, failure: (String) -> Unit): Unit {
        this.deviceGet("/api/v1/ui/app/dev/status?did=${deviceId}&more=true&promo=false", { root =>
            try {
                let status = this.intField(root["data"].asObject()["device"].asObject()["gene"].asObject(), "status")
                success(status)
            } catch (error: Exception) { failure("饮水设备状态解析失败：${error.message}") }
        }, failure)
    }

    func deviceGet(path: String, success: (JsonObject) -> Unit, failure: (String) -> Unit): Unit {
        match (Regex("^[A-Za-z0-9_?&=./:-]+$").find(path)) { case None => failure("饮水设备参数格式不正确"); return; case _ => () }
        let token = this.tokenStore.restore()
        if (token == "") { failure("饮水登录已失效，请重新登录"); return }
        this.getText(path, token, { text => this.requireSuccess(text, success, failure) }, failure)
    }
    func getText(path: String, token: String, success: (String) -> Unit, failure: (String) -> Unit): Unit {
        let client = createHttp()
        let options = HttpRequestOptions(method: RequestMethod.Get, header: this.headers(token), expectDataType: HttpDataType.StringValue,
            usingCache: false, connectTimeout: 10000, readTimeout: 30000)
        try {
            client.request(DormWaterSession.baseUrl + path, options, { error, response =>
                client.destroy(); this.textResponse(error, response, success, failure)
            })
        } catch (error: BusinessException) { client.destroy(); failure("无法启动饮水请求：${error.code} ${error.message}") }
    }
    func postJson(path: String, body: String, token: String, success: (String) -> Unit, failure: (String) -> Unit): Unit {
        let headers = this.headers(token); headers["Content-Type"] = "application/json"
        let client = createHttp()
        let options = HttpRequestOptions(method: RequestMethod.Post, header: headers, extraData: HttpData.StringData(body),
            expectDataType: HttpDataType.StringValue, usingCache: false, connectTimeout: 10000, readTimeout: 30000)
        try {
            client.request(DormWaterSession.baseUrl + path, options, { error, response =>
                client.destroy(); this.textResponse(error, response, success, failure)
            })
        } catch (error: BusinessException) { client.destroy(); failure("无法启动饮水请求：${error.code} ${error.message}") }
    }
    func textResponse(error: ?BusinessException, response: ?HttpResponse, success: (String) -> Unit, failure: (String) -> Unit): Unit {
        match (error) {
            case Some(value) => failure("饮水服务网络错误 ${value.code}: ${value.message}")
            case None => match (response) {
                case Some(value) =>
                    if (value.responseCode != 200) { failure("饮水服务返回 HTTP ${value.responseCode}") }
                    else { match (value.result) { case HttpData.StringData(text) => success(text); case _ => failure("饮水服务返回非文本响应") } }
                case None => failure("饮水服务未返回响应")
            }
        }
    }
    func requireSuccess(text: String, success: (JsonObject) -> Unit, failure: (String) -> Unit): Unit {
        try {
            let root = JsonValue.fromStr(text).asObject()
            if (this.intField(root, "code") != 0) { failure("饮水服务拒绝请求：${this.field(root, "msg")}") }
            else { success(root) }
        } catch (error: Exception) { failure("饮水服务响应解析失败：${error.message}") }
    }
    func headers(token: String, captcha!: Bool = false): HashMap<String, String> {
        let headers = HashMap<String, String>()
        headers["Accept"] = "*/*"
        headers["User-Agent"] = if (captcha) { "iLife798/3.1.1 (iPhone; iOS 26.2; Scale/3.00)" } else { DormWaterSession.userAgent }
        headers["Accept-Language"] = "zh-Hans-US;q=1, en-US;q=0.8"
        if (token != "") { headers["Authorization"] = token }
        return headers
    }
    func validPhone(value: String): Bool { match (Regex("^[0-9]{11}$").find(value)) { case Some(_) => true; case None => false } }
    func validDeviceId(value: String): Bool { return Regex("^[A-Za-z0-9_-]{1,64}$").matches(value) }
    func validCode(value: String): Bool { match (Regex("^[A-Za-z0-9]{1,12}$").find(value)) { case Some(_) => true; case None => false } }
    func stringOf(value: JsonValue): String {
        match (value.kind()) {
            case JsString => value.asString().getValue()
            case JsInt => value.asInt().getValue().toString()
            case JsFloat => value.asFloat().getValue().toString()
            case JsBool => value.asBool().getValue().toString()
            case _ => ""
        }
    }
    func field(object: JsonObject, name: String): String { match (object.get(name)) { case Some(value) => this.stringOf(value); case None => "" } }
    func intField(object: JsonObject, name: String): Int64 { try { return Int64.parse(this.field(object, name)) } catch (_) { return -1 } }
}
