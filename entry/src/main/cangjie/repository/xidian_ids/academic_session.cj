package ohos_app_cangjie_entry.repository.xidian_ids

import kit.NetworkKit.*
import kit.PerformanceAnalysisKit.Hilog
import ohos.business_exception.*
import std.collection.*
import std.convert.*
import std.regex.*
import stdx.encoding.json.*
import ohos_app_cangjie_entry.repository.*
import ohos_app_cangjie_entry.model.xidian_ids.*

// Ehall business APIs require an app-specific SSO bootstrap through appShow.
// Only the encrypted real IDS/Ehall session is used; response bodies are never logged or persisted here.
public class AcademicSession {
    static let scoreUrl = "https://ehall.xidian.edu.cn/jwapp/sys/cjcx/modules/cjcx/xscjcx.do"
    static let examUrl = "https://ehall.xidian.edu.cn/jwapp/sys/studentWdksapApp/modules/wdksap/wdksap.do"
    static let unarrangedExamUrl = "https://ehall.xidian.edu.cn/jwapp/sys/studentWdksapApp/modules/wdksap/cxyxkwapkwdkc.do"
    static let scoreAppId = "4768574631264620"
    static let examAppId = "4768687067472349"
    static let timetableAppId = "4770397878132218"
    static let emptyClassroomAppId = "4768402106681759"

    func cookie(): String {
        let snapshot = SessionStore().restore()
        if (!snapshot.loggedIn || snapshot.cookieHeader == "") {
            throw Exception("真实 IDS/Ehall 会话已失效，请重新登录。")
        }
        return snapshot.cookieHeader
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
    public func field(object: JsonObject, name: String): String {
        match (object.get(name)) { case Some(value) => this.stringOf(value); case None => "" }
    }
    func intField(object: JsonObject, name: String): Int64 {
        try { return Int64.parse(this.field(object, name)) } catch (_) { return 0 }
    }
    public func responseRows(body: String, name: String): JsonArray {
        if (body.contains("pwdFromId") || body.contains("authserver/login")) {
            throw Exception("Ehall 会话已失效，请退出后重新登录。")
        }
        let root = JsonValue.fromStr(body).asObject()
        match (root.get("datas")) { case Some(_) => (); case None => throw Exception("教务响应不包含 datas") }
        return root["datas"].asObject()[name].asObject()["rows"].asArray()
    }

    func appIdFor(url: String): String {
        if (url.contains("/sys/cjcx/")) { return AcademicSession.scoreAppId }
        if (url.contains("/studentWdksapApp/")) { return AcademicSession.examAppId }
        if (url.contains("/sys/wdkb/")) { return AcademicSession.timetableAppId }
        if (url.contains("/sys/kxjas/")) { return AcademicSession.emptyClassroomAppId }
        return ""
    }

    // Establish the business-app session exactly as Flutter EhallSession.useApp does.
    func useApp(appId: String, ready: (String) -> Unit, failure: (String) -> Unit): Unit {
        let baseCookie = try { this.cookie() } catch (e: Exception) { failure(e.message); return }
        let url = "https://ehall.xidian.edu.cn/appShow?appId=${appId}"
        this.requestRaw(url, RequestMethod.Get, "", baseCookie, { code, body, mergedCookie =>
            if (code != 200) {
                failure("Ehall 应用会话初始化返回 HTTP ${code}。")
            } else if (body.contains("pwdFromId") || body.contains("authserver/login")) {
                failure("Ehall 会话已过期，请退出后重新登录。")
            } else {
                Hilog.info(1, "AcademicSession", "Ehall app session ready appId=${appId} cookieCount=${this.cookieCount(mergedCookie)}")
                ready(mergedCookie)
            }
        }, failure)
    }

    public func request(url: String, form: String, success: (String) -> Unit, failure: (String) -> Unit): Unit {
        let appId = this.appIdFor(url)
        if (appId == "") {
            let baseCookie = try { this.cookie() } catch (e: Exception) { failure(e.message); return }
            this.requestBusiness(url, form, baseCookie, success, failure)
        } else {
            this.useApp(appId, { appCookie => this.requestBusiness(url, form, appCookie, success, failure) }, failure)
        }
    }

    func requestBusiness(url: String, form: String, cookieHeader: String,
        success: (String) -> Unit, failure: (String) -> Unit): Unit {
        this.requestRaw(url, RequestMethod.Post, form, cookieHeader, { code, body, _ =>
            if (code != 200) { failure("教务服务返回 HTTP ${code}。") }
            else if (body.contains("pwdFromId") || body.contains("authserver/login")) {
                failure("Ehall 会话已过期，请退出后重新登录。")
            } else { success(body) }
        }, failure)
    }

    func requestRaw(url: String, method: RequestMethod, form: String, cookieHeader: String,
        success: (UInt32, String, String) -> Unit, failure: (String) -> Unit): Unit {
        let client = createHttp()
        try {
            let isPost = match (method) { case RequestMethod.Post => true; case _ => false }
            let headers = HashMap<String, String>()
            headers["Cookie"] = cookieHeader
            headers["User-Agent"] = "Mozilla/5.0 (HarmonyOS; XDYou/2.0) AppleWebKit/537.36"
            headers["Accept-Language"] = "zh-CN,zh;q=0.9"
            headers["Accept-Encoding"] = "identity"
            headers["Referer"] = "https://ehall.xidian.edu.cn/new/index_xd.html"
            if (isPost) {
                headers["Content-Type"] = "application/x-www-form-urlencoded; charset=UTF-8"
                headers["Accept"] = "application/json, text/javascript, */*; q=0.01"
                headers["X-Requested-With"] = "XMLHttpRequest"
            }
            let options = if (isPost) {
                HttpRequestOptions(method: method, header: headers,
                    extraData: HttpData.StringData(form), expectDataType: HttpDataType.StringValue,
                    usingCache: false, connectTimeout: 10000, readTimeout: 30000)
            } else {
                HttpRequestOptions(method: method, header: headers,
                    expectDataType: HttpDataType.StringValue, usingCache: false,
                    connectTimeout: 10000, readTimeout: 30000)
            }
            client.request(url, options, { error, response =>
                client.destroy()
                match (error) {
                    case Some(e) => failure("教务网络错误 ${e.code}: ${e.message}")
                    case None => match (response) {
                        case Some(r) => match (r.result) {
                            case HttpData.StringData(body) =>
                                let rawCookies = if (r.cookies != "") { r.cookies } else { this.headerValue(r.header, "set-cookie") }
                                success(r.responseCode, body, this.mergeCookies(cookieHeader, rawCookies))
                            case _ => failure("教务服务返回了非文本响应。")
                        }
                        case None => failure("教务服务未返回响应。")
                    }
                }
            })
        } catch (e: BusinessException) {
            client.destroy()
            failure("无法启动教务请求：${e.code} ${e.message}")
        }
    }

    func headerValue(headers: HashMap<String, String>, expected: String): String {
        for ((name, value) in headers) {
            if (name.toAsciiLower() == expected) { return value }
        }
        return ""
    }
    func mergeCookies(existing: String, raw: String): String {
        let values = ArrayList<String>()
        for (pair in Regex(";").split(existing)) { this.upsertCookie(values, pair.trimAscii()) }
        for (line in Regex("[\r\n,]+").split(raw)) {
            let columns = Regex("\\t").split(line)
            if (columns.size >= 7) {
                this.upsertCookie(values, "${columns[columns.size - 2]}=${columns[columns.size - 1]}")
                continue
            }
            let fields = Regex(";").split(line)
            var index: Int64 = 0
            while (index < fields.size) {
                let pair = fields[index].trimAscii()
                let parts = Regex("=").split(pair)
                let name = if (parts.size > 0) { parts[0].toAsciiLower() } else { "" }
                if (index == 0 || !this.isCookieAttribute(name)) { this.upsertCookie(values, pair) }
                index += 1
            }
        }
        var result = ""
        for (item in values) { if (result != "") { result += "; " }; result += item }
        return result
    }
    func isCookieAttribute(name: String): Bool {
        return name == "path" || name == "domain" || name == "expires" || name == "max-age" ||
            name == "samesite" || name == "secure" || name == "httponly" || name == "priority"
    }
    func upsertCookie(values: ArrayList<String>, pair: String): Unit {
        if (!pair.contains("=")) { return }
        let parts = Regex("=").split(pair)
        if (parts.size == 0 || parts[0] == "") { return }
        let prefix = "${parts[0]}="
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

    public func loadCurrentSemester(success: (String) -> Unit, failure: (String) -> Unit): Unit {
        let url = "https://ehall.xidian.edu.cn/jwapp/sys/wdkb/modules/jshkcb/dqxnxq.do"
        this.request(url, "", { body =>
            try {
                let rows = this.responseRows(body, "dqxnxq")
                if (rows.size() == 0) { failure("教务系统未返回当前学期。") }
                else {
                    let code = this.field(rows[0].asObject(), "DM")
                    if (code == "") { failure("当前学期代码为空。") } else { success(code) }
                }
            } catch (e: Exception) { failure("当前学期解析失败：${e.message}") }
        }, failure)
    }

    public func loadScores(success: (ArrayList<ScoreItem>) -> Unit, failure: (String) -> Unit): Unit {
        this.request(AcademicSession.scoreUrl, "*json=1&querySetting=%7B%22name%22%3A%22SFYX%22%2C%22value%22%3A%221%22%2C%22linkOpt%22%3A%22and%22%2C%22builder%22%3A%22m_value_equal%22%7D&*order=%2BXNXQDM%2CKCH%2CKXH&pageSize=1000&pageNumber=1", { body =>
            try {
                let result = ArrayList<ScoreItem>()
                let rows = this.responseRows(body, "xscjcx")
                var index: Int64 = 0
                while (index < rows.size()) {
                    let row = rows[index].asObject()
                    let elective = this.field(row, "XGXKLBDM_DISPLAY")
                    let classStatus = if (elective == "") { this.field(row, "KCXZDM_DISPLAY") } else { "选修 ${elective}" }
                    result.add(ScoreItem(index, this.field(row,"XSKCM"), this.field(row,"XNXQDM"), this.field(row,"ZCJ"), this.field(row,"XF"), this.field(row,"KCLBDM_DISPLAY"), classStatus, this.field(row,"CXCKDM_DISPLAY"), this.intField(row,"DJCJLXDM"), this.field(row,"DJCJMC"), this.field(row,"SFJG"), this.field(row,"JXBID")))
                    index += 1
                }
                success(result)
            } catch (e: Exception) { failure("成绩响应解析失败：${e.message}") }
        }, failure)
    }
    public func loadExams(semester: String, success: (ArrayList<ExamItem>) -> Unit, failure: (String) -> Unit): Unit {
        this.request(AcademicSession.examUrl, "XNXQDM=${semester}&*order=-KSRQ%2C-KSSJMS", { body =>
            try {
                let result = ArrayList<ExamItem>()
                let rows = this.responseRows(body, "wdksap")
                var index: Int64 = 0
                while (index < rows.size()) {
                    let row = rows[index].asObject()
                    result.add(ExamItem(this.field(row,"KCM"), this.field(row,"KSSJMS"), this.field(row,"JASMC"), this.field(row,"ZWH"), this.field(row,"KSMC")))
                    index += 1
                }
                this.loadUnarrangedExams(semester, result, success, failure)
            } catch (e: Exception) { failure("考试响应解析失败：${e.message}") }
        }, failure)
    }
    func loadUnarrangedExams(semester: String, result: ArrayList<ExamItem>, success: (ArrayList<ExamItem>) -> Unit, failure: (String) -> Unit): Unit {
        this.request(AcademicSession.unarrangedExamUrl, "XNXQDM=${semester}", { body =>
            try {
                let rows = this.responseRows(body, "cxyxkwapkwdkc")
                var index: Int64 = 0
                while (index < rows.size()) {
                    let row = rows[index].asObject()
                    result.add(ExamItem(this.field(row,"KCM"), "", "", "", "未安排", courseId: this.field(row,"KCH"), arranged: false))
                    index += 1
                }
                success(result)
            } catch (e: Exception) { failure("未安排考试响应解析失败：${e.message}") }
        }, failure)
    }
}