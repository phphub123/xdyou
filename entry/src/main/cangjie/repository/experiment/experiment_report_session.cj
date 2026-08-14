package ohos_app_cangjie_entry.repository.experiment

import kit.NetworkKit.*
import ohos.business_exception.*
import std.collection.*
import std.regex.*
import std.time.*
import stdx.encoding.json.*
import ohos_app_cangjie_entry.model.*

class ReportLoginState {
    var sid: String = ""
    var cookie: String = ""
}

public class ExperimentReportSession {
    static let baseUrl = "http://wlsy.xidian.edu.cn/wgyreport/wgyreport.dll"
    let recognizer = ImageRecognitionService()

    func encode(value: String): String {
        return value.replace("%", "%25").replace(" ", "%20").replace("!", "%21")
            .replace("#", "%23").replace("&", "%26").replace("+", "%2B")
            .replace("/", "%2F").replace("=", "%3D").replace("?", "%3F")
    }

    func headerValue(headers: HashMap<String, String>, name: String): String {
        for ((key, value) in headers) { if (key.toAsciiLower() == name.toAsciiLower()) { return value } }
        return ""
    }

    func requestText(method: RequestMethod, url: String, headers: HashMap<String, String>, body: String,
        success: (UInt32, HashMap<String, String>, String, String) -> Unit, failure: (String) -> Unit): Unit {
        let client = createHttp()
        try {
            let options = HttpRequestOptions(method: method, header: headers,
                extraData: HttpData.StringData(body), expectDataType: HttpDataType.StringValue,
                usingCache: false, connectTimeout: 10000, readTimeout: 30000)
            client.request(url, options, { error, response =>
                client.destroy()
                match (error) {
                    case Some(value) => failure("实验报告服务网络错误 ${value.code}: ${value.message}")
                    case None => match (response) {
                        case Some(value) => match (value.result) {
                            case HttpData.StringData(text) => success(value.responseCode, value.header, value.cookies, text)
                            case _ => failure("实验报告服务返回了非文本响应。")
                        }
                        case None => failure("实验报告服务未返回响应。")
                    }
                }
            })
        } catch (e: BusinessException) { client.destroy(); failure("无法启动实验报告请求：${e.code} ${e.message}") }
    }

    func commonHeaders(cookie!: String = "", json!: Bool = false): HashMap<String, String> {
        let headers = HashMap<String, String>()
        headers["Accept"] = if (json) { "*/*" } else { "text/html,application/xhtml+xml,application/json;q=0.9,*/*;q=0.8" }
        headers["Accept-Language"] = "zh-CN,zh;q=0.9"
        headers["User-Agent"] = "Mozilla/5.0 (HarmonyOS; XDYou) AppleWebKit/537.36"
        headers["Referer"] = ExperimentReportSession.baseUrl + "/?id=stu"
        headers["Origin"] = "http://wlsy.xidian.edu.cn"
        if (json) { headers["Content-Type"] = "application/x-www-form-urlencoded; charset=UTF-8"; headers["X-Requested-With"] = "XMLHttpRequest" }
        if (cookie != "") { headers["Cookie"] = cookie }
        return headers
    }

    public func recognizeAll(account: String, password: String,
        success: (HashMap<String, RecognitionResult>) -> Unit, failure: (String) -> Unit): Unit {
        if (account == "" || password == "") { failure("实验报告识别需要学号和物理实验系统密码。") ; return }
        let state = ReportLoginState()
        this.requestText(RequestMethod.Get, ExperimentReportSession.baseUrl + "/?id=stu", this.commonHeaders(), "", { code, headers, cookies, html =>
            if (code != 200) { failure("实验报告登录页返回 HTTP ${code}。") ; return }
            state.sid = this.headerValue(headers, "session_id")
            if (state.sid == "") {
                match (Regex(#"_S_ID=([A-Za-z0-9_]+)"#).find(html, group: true)) { case Some(value) => state.sid = value.matchString(1); case None => () }
            }
            state.cookie = if (cookies != "") { cookies } else { this.headerValue(headers, "set-cookie") }
            if (state.sid == "") { failure("实验报告登录页未返回会话标识。") ; return }
            this.sendLoginEvents(state, account, password, success, failure)
        }, failure)
    }

    func event(state: ReportLoginState, body: String, next: () -> Unit, failure: (String) -> Unit): Unit {
        this.requestText(RequestMethod.Post, ExperimentReportSession.baseUrl + "/HandleEvent", this.commonHeaders(cookie: state.cookie, json: true), body,
            { code, _, _, _ => if (code < 200 || code >= 400) { failure("实验报告事件返回 HTTP ${code}。") } else { next() } }, failure)
    }

    func sendLoginEvents(state: ReportLoginState, account: String, password: String,
        success: (HashMap<String, RecognitionResult>) -> Unit, failure: (String) -> Unit): Unit {
        let sid = state.sid
        this.event(state, "Ajax=1&IsEvent=1&Obj=O0&Evt=cinfo&ci=br%3D33%3Bos%3D4%3Bbv%3D140%3Bww%3D2048%3Bwh%3D1018&_S_ID=${sid}&_seq_=0&_uo_=O0", { =>
            this.event(state, "Ajax=1&IsEvent=1&Obj=O0&Evt=move&this=O0&x=868&y=381&_S_ID=${sid}&_seq_=1&_uo_=O0", { =>
                this.event(state, "Ajax=1&IsEvent=1&Obj=O0&Evt=activate&this=O0&_S_ID=${sid}&_seq_=2&_uo_=O0", { =>
                    this.event(state, "Ajax=1&IsEvent=1&Obj=O0&Evt=resize&this=O0&w=311&h=255&_S_ID=${sid}&_seq_=3&_uo_=O0", { =>
                        let login = "Ajax=1&IsEvent=1&Obj=O1F&Evt=click&this=O1F&_S_ID=${sid}&_fp_=%26O17%3D%25020%2502%2502${this.encode(account)}%26O1B%3D%25020%2502%2502${this.encode(password)}&_seq_=4&_uo_=O0"
                        this.requestText(RequestMethod.Post, ExperimentReportSession.baseUrl + "/HandleEvent", this.commonHeaders(cookie: state.cookie, json: true), login, { code, headers, cookies, _ =>
                            if (code < 200 || code >= 400) { failure("实验报告登录返回 HTTP ${code}。") ; return }
                            let rawCookie = if (cookies != "") { cookies } else { this.headerValue(headers, "set-cookie") }
                            match (Regex(#"sid=([^;\r\n,]+)"#, RegexFlag.IgnoreCase).find(rawCookie, group: true)) {
                                case Some(value) => state.cookie = "UNI_GUI_SESSION_ID=${sid}; sid=${value.matchString(1)}"
                                case None => ()
                            }
                            this.loadScoreRows(state, success, failure)
                        }, failure)
                    }, failure)
                }, failure)
            }, failure)
        }, failure)
    }

    func loadScoreRows(state: ReportLoginState, success: (HashMap<String, RecognitionResult>) -> Unit, failure: (String) -> Unit): Unit {
        let timestamp = DateTime.now().toUnixTimeStamp().toMilliseconds()
        let url = ExperimentReportSession.baseUrl + "/HandleEvent?IsEvent=1&Obj=OA7&Evt=data&_dc=${timestamp}&start=0&limit=25&options=1&page=1"
        let headers = this.commonHeaders(cookie: state.cookie, json: true)
        headers["UniSessionId"] = state.sid; headers["_S_ID"] = state.sid
        this.requestText(RequestMethod.Get, url, headers, "", { code, _, _, body =>
            if (code != 200) { failure("实验成绩列表返回 HTTP ${code}。") ; return }
            try {
                let root = JsonValue.fromStr(body.replace("\\x3C", "<").replace("\\x3E", ">" )).asObject()
                let rows = root["rows"].asArray()
                let names = ArrayList<String>(); let urls = ArrayList<String>()
                var index: Int64 = 0
                while (index < rows.size()) {
                    let row = rows[index].asObject()
                    let name = this.jsonString(row, "2")
                    let imageHtml = this.jsonString(row, "3")
                    match (Regex(#"src=\\?[\"']([^\"']+)\\?[\"']"#, RegexFlag.IgnoreCase).find(imageHtml, group: true)) {
                        case Some(found) =>
                            var imageUrl = found.matchString(1)
                            if (imageUrl.startsWith("/")) { imageUrl = "http://wlsy.xidian.edu.cn${imageUrl}" }
                            if (name != "" && imageUrl != "") { names.add(name); urls.add(imageUrl) }
                        case None => ()
                    }
                    index += 1
                }
                if (names.size == 0) { failure("实验报告服务未返回成绩图片。") }
                else { this.recognizeAt(names, urls, 0, HashMap<String, RecognitionResult>(), success, failure) }
            } catch (e: Exception) { failure("实验成绩列表解析失败：${e.message}") }
        }, failure)
    }

    func recognizeAt(names: ArrayList<String>, urls: ArrayList<String>, index: Int64,
        result: HashMap<String, RecognitionResult>, success: (HashMap<String, RecognitionResult>) -> Unit,
        failure: (String) -> Unit): Unit {
        if (index >= names.size) { success(result); return }
        let client = createHttp()
        let options = HttpRequestOptions(method: RequestMethod.Get, expectDataType: HttpDataType.ArrayBuffer,
            usingCache: false, connectTimeout: 10000, readTimeout: 30000)
        try {
            client.request(urls[index], options, { error, response =>
                client.destroy()
                match (error) {
                    case Some(_) => result[names[index]] = RecognitionResult("", false, urls[index]); this.recognizeAt(names, urls, index + 1, result, success, failure)
                    case None => match (response) {
                        case Some(value) => match (value.result) {
                            case HttpData.ArrayData(bytes) =>
                                try { result[names[index]] = this.recognizer.recognize(bytes, urls[index]) }
                                catch (_) { result[names[index]] = RecognitionResult("", false, urls[index]) }
                                this.recognizeAt(names, urls, index + 1, result, success, failure)
                            case _ => result[names[index]] = RecognitionResult("", false, urls[index]); this.recognizeAt(names, urls, index + 1, result, success, failure)
                        }
                        case None => result[names[index]] = RecognitionResult("", false, urls[index]); this.recognizeAt(names, urls, index + 1, result, success, failure)
                    }
                }
            })
        } catch (e: BusinessException) { client.destroy(); failure("无法下载实验成绩图片：${e.code} ${e.message}") }
    }

    func jsonString(object: JsonObject, key: String): String {
        match (object.get(key)) { case Some(value) => match (value.kind()) { case JsString => value.asString().getValue(); case _ => "" }; case None => "" }
    }
}
