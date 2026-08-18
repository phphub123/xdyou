package ohos_app_cangjie_entry.repository.energy

// 空调电量仓储，按设备标识查询独立计量系统，区别于宿舍水电表链路。

import kit.NetworkKit.*
import ohos.business_exception.*
import std.collection.*
import std.convert.*
import std.regex.*
import std.time.*
import stdx.encoding.json.*
import ohos_app_cangjie_entry.model.*

// 空调系统使用独立设备标识，不能复用宿舍电表的余额语义。
public class AirconSession {
    static let endpoint = "https://gxkt.juhaolian.cn/api/device/direct/state"

    public func load(imei: String, success: (AirconEnergyInfo) -> Unit, failure: (String) -> Unit): Unit {
        let value = imei.trimAscii()
        if (!Regex("^[A-Za-z0-9_-]{6,64}$").matches(value)) {
            failure("空调设备 IMEI 格式不正确。")
            return
        }
        let client = createHttp()
        let headers = HashMap<String, String>()
        headers["Accept"] = "application/json"
        headers["User-Agent"] = "XDYou HarmonyOS"
        let options = HttpRequestOptions(method: RequestMethod.Get, header: headers,
            expectDataType: HttpDataType.StringValue, usingCache: false,
            connectTimeout: 10000, readTimeout: 30000)
        try {
            client.request("${AirconSession.endpoint}?imei=${value}", options, { error, response =>
                client.destroy()
                match (error) {
                    case Some(value) => failure("空调能耗请求失败 ${value.code}: ${value.message}")
                    case None => match (response) {
                        case Some(value) =>
                            if (value.responseCode != 200) { failure("空调能耗返回 HTTP ${value.responseCode}") }
                            else { match (value.result) {
                                case HttpData.StringData(body) => this.parse(body, success, failure)
                                case _ => failure("空调能耗返回非文本响应。")
                            } }
                        case None => failure("空调能耗未返回响应。")
                    }
                }
            })
        } catch (error: BusinessException) {
            client.destroy()
            failure("无法启动空调能耗请求：${error.code} ${error.message}")
        }
    }

    func parse(body: String, success: (AirconEnergyInfo) -> Unit, failure: (String) -> Unit): Unit {
        try {
            let root = JsonValue.fromStr(body).asObject()
            match (root.get("success")) {
                case Some(value) => match (value.kind()) {
                    case JsBool => if (!value.asBool().getValue()) { failure("空调能耗服务拒绝请求：${this.field(root, "message")}"); return }
                    case _ => failure("空调能耗响应缺少 success 标志。"); return
                }
                case None => failure("空调能耗响应缺少 success 标志。"); return
            }
            let result = match (root.get("result")) { case Some(value) => value.asObject(); case None => throw Exception("响应缺少设备状态") }
            let imei = this.field(result, "imei")
            let amount = this.field(result, "electricAmount")
            let timestamp = this.intField(root, "timestamp")
            let stateTimestamp = this.intField(result, "timestamp")
            if (imei == "" || amount == "" || timestamp <= 0 || stateTimestamp <= 0) { throw Exception("响应缺少设备能耗字段") }
            let fetchTime = DateTime.now().addSeconds((timestamp - DateTime.now().toUnixTimeStamp().toMilliseconds()) / 1000)
            let stateTime = DateTime.now().addSeconds(stateTimestamp - DateTime.now().toUnixTimeStamp().toSeconds())
            success(AirconEnergyInfo(imei, fetchTime, stateTime, amount))
        } catch (error: Exception) { failure("空调能耗响应解析失败：${error.message}") }
    }

    func field(object: JsonObject, name: String): String {
        match (object.get(name)) {
            case Some(value) => match (value.kind()) {
                case JsString => value.asString().getValue()
                case JsInt => value.asInt().getValue().toString()
                case JsFloat => value.asFloat().getValue().toString()
                case _ => ""
            }
            case None => ""
        }
    }
    func intField(object: JsonObject, name: String): Int64 {
        try { return Int64.parse(this.field(object, name)) } catch (_) { return 0 }
    }
}
