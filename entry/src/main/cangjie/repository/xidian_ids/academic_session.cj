package ohos_app_cangjie_entry.repository.xidian_ids

import kit.NetworkKit.*
import ohos.business_exception.*
import std.collection.*
import std.convert.*
import stdx.encoding.json.*
import ohos_app_cangjie_entry.repository.*
import ohos_app_cangjie_entry.model.xidian_ids.*

// Uses only a cookie saved after a real IDS redirect. No sample response is stored or accepted.
public class AcademicSession {
    static let scoreUrl = "https://ehall.xidian.edu.cn/jwapp/sys/cjcx/modules/cjcx/xscjcx.do"
    static let examUrl = "https://ehall.xidian.edu.cn/jwapp/sys/studentWdksapApp/modules/wdksap/wdksap.do"
    static let unarrangedExamUrl = "https://ehall.xidian.edu.cn/jwapp/sys/studentWdksapApp/modules/wdksap/cxyxkwapkwdkc.do"
    func cookie(): String {
        let snapshot = SessionStore().restore()
        if (!snapshot.loggedIn) { throw Exception("A real IDS/Ehall session is required before academic data can load.") }
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
    func field(object: JsonObject, name: String): String {
        match (object.get(name)) { case Some(value) => this.stringOf(value); case None => "" }
    }
    func intField(object: JsonObject, name: String): Int64 {
        try { return Int64.parse(this.field(object, name)) } catch (_) { return 0 }
    }
    func responseRows(body: String, name: String): JsonArray {
        let root = JsonValue.fromStr(body).asObject()
        match (root.get("datas")) { case Some(_) => (); case None => throw Exception("Response did not contain academic data") }
        return root["datas"].asObject()[name].asObject()["rows"].asArray()
    }
    func request(url: String, form: String, success: (String) -> Unit, failure: (String) -> Unit): Unit {
        let client = createHttp()
        try {
            let headers = HashMap<String, String>()
            headers["Cookie"] = this.cookie()
            headers["Content-Type"] = "application/x-www-form-urlencoded;charset=UTF-8"
            headers["Accept"] = "application/json, text/javascript, */*; q=0.01"
            let options = HttpRequestOptions(method: RequestMethod.Post, header: headers, extraData: HttpData.StringData(form), expectDataType: HttpDataType.StringValue, usingCache: false, connectTimeout: 10000, readTimeout: 30000)
            client.request(url, options, { error, response =>
                client.destroy()
                match (error) {
                    case Some(e) => failure("Academic network error ${e.code}: ${e.message}")
                    case None => match (response) {
                        case Some(r) => if (r.responseCode != 200) { failure("Academic server returned HTTP ${r.responseCode}") }
                            else { match (r.result) { case HttpData.StringData(body) => success(body); case _ => failure("Academic server returned an unexpected response format") } }
                        case None => failure("Academic server returned no response")
                    }
                }
            })
        } catch (e: Exception) { client.destroy(); failure(e.message) }
        catch (e: BusinessException) { client.destroy(); failure("Unable to start academic request: ${e.code} ${e.message}") }
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
                    let classStatus = if (elective == "") { this.field(row, "KCXZDM_DISPLAY") } else { "?? ${elective}" }
                    result.add(ScoreItem(index, this.field(row,"XSKCM"), this.field(row,"XNXQDM"), this.field(row,"ZCJ"), this.field(row,"XF"), this.field(row,"KCLBDM_DISPLAY"), classStatus, this.field(row,"CXCKDM_DISPLAY"), this.intField(row,"DJCJLXDM"), this.field(row,"DJCJMC"), this.field(row,"SFJG"), this.field(row,"JXBID")))
                    index += 1
                }
                success(result)
            }
            catch (e: Exception) { failure("Malformed score response: ${e.message}") }
        }, failure)
    }
    public func loadExams(semester: String, success: (ArrayList<ExamItem>) -> Unit, failure: (String) -> Unit): Unit {
        this.request(AcademicSession.examUrl, "XNXQDM=${semester}&*order=-KSRQ%2C-KSSJMS", { body =>
            try { let result = ArrayList<ExamItem>(); let rows = this.responseRows(body, "wdksap"); var index: Int64 = 0; while (index < rows.size()) { let row = rows[index].asObject(); result.add(ExamItem(this.field(row,"KCM"), this.field(row,"KSSJMS"), this.field(row,"JASMC"), this.field(row,"ZWH"), this.field(row,"KSMC"))); index += 1 }; this.loadUnarrangedExams(semester, result, success, failure) }
            catch (e: Exception) { failure("Malformed exam response: ${e.message}") }
        }, failure)
    }
    func loadUnarrangedExams(semester: String, result: ArrayList<ExamItem>, success: (ArrayList<ExamItem>) -> Unit, failure: (String) -> Unit): Unit {
        this.request(AcademicSession.unarrangedExamUrl, "XNXQDM=${semester}", { body =>
            try {
                let rows = this.responseRows(body, "cxyxkwapkwdkc")
                var index: Int64 = 0
                while (index < rows.size()) {
                    let row = rows[index].asObject()
                    result.add(ExamItem(this.field(row,"KCM"), "", "", "", "Unarranged", courseId: this.field(row,"KCH"), arranged: false))
                    index += 1
                }
                success(result)
            } catch (e: Exception) { failure("Malformed unarranged-exam response: ${e.message}") }
        }, failure)
    }
}
