package ohos_app_cangjie_entry.repository.schoolnet

import kit.NetworkKit.*
import ohos.business_exception.*
import std.collection.*
import std.convert.*
import std.time.*
import stdx.encoding.json.*
import ohos_app_cangjie_entry.model.*

public class SchoolnetSession {
    public func loadCurrent(success: (CurrentUserNetInfo) -> Unit, failure: (String) -> Unit): Unit {
        this.get("https://notice.xidian.edu.cn", { body =>
            if (body.contains("校外访问")) {
                failure("当前不在西电校园网，无法读取在线账号信息。")
                return
            }
            let timestamp = DateTime.now().toUnixTimeStamp().toMilliseconds()
            this.get("https://w.xidian.edu.cn/cgi-bin/rad_user_info?callback=jsonp&_=${timestamp}", { jsonp =>
                try {
                    var text = jsonp.trimAscii()
                    if (text.startsWith("jsonp(")) { text = text[6..text.size - 2] }
                    let data = JsonValue.fromStr(text).asObject()
                    success(CurrentUserNetInfo(
                        this.field(data, "user_name"), this.field(data, "real_name"),
                        this.field(data, "products_name"), this.field(data, "online_ip"),
                        this.field(data, "online_device_total"), this.intField(data, "sum_bytes"),
                        this.intField(data, "remain_bytes"), this.intField(data, "bytes_in"),
                        this.intField(data, "bytes_out"), this.intField(data, "user_balance"),
                        this.intField(data, "wallet_balance")
                    ))
                } catch (error: Exception) {
                    failure("校园网在线信息解析失败：${error.message}")
                }
            }, failure)
        }, { _ => failure("无法确认校园网环境，请检查网络连接。") })
    }

    func get(url: String, success: (String) -> Unit, failure: (String) -> Unit): Unit {
        let client = createHttp()
        try {
            let headers = HashMap<String, String>()
            headers["User-Agent"] = "Mozilla/5.0 (HarmonyOS; XDYou)"
            let options = HttpRequestOptions(
                method: RequestMethod.Get, header: headers, expectDataType: HttpDataType.StringValue,
                usingCache: false, connectTimeout: 10000, readTimeout: 30000
            )
            client.request(url, options, { error, response =>
                client.destroy()
                match (error) {
                    case Some(value) => failure("校园网请求错误 ${value.code}: ${value.message}")
                    case None => match (response) {
                        case Some(value) =>
                            if (value.responseCode != 200) {
                                failure("校园网返回 HTTP ${value.responseCode}")
                            } else {
                                match (value.result) {
                                    case HttpData.StringData(body) => success(body)
                                    case _ => failure("校园网返回非文本响应")
                                }
                            }
                        case None => failure("校园网未返回响应")
                    }
                }
            })
        } catch (error: BusinessException) {
            client.destroy()
            failure("无法启动校园网请求：${error.code} ${error.message}")
        }
    }

    func stringOf(value: JsonValue): String {
        match (value.kind()) {
            case JsString => value.asString().getValue()
            case JsInt => value.asInt().getValue().toString()
            case JsFloat => value.asFloat().getValue().toString()
            case JsBool => value.asBool().getValue().toString()
            case _ => ""
        }
    }
    func field(object: JsonObject, name: String): String {
        match (object.get(name)) { case Some(value) => this.stringOf(value); case None => "" }
    }
    func intField(object: JsonObject, name: String): Int64 {
        try { return Int64.parse(this.field(object, name)) } catch (_) { return 0 }
    }
}
