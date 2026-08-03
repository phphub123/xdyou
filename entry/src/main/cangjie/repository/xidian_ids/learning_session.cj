package ohos_app_cangjie_entry.repository.xidian_ids

import kit.NetworkKit.*
import ohos.business_exception.*
import std.collection.*
import std.regex.*
import std.convert.*
import stdx.encoding.json.*
import ohos_app_cangjie_entry.repository.*
import ohos_app_cangjie_entry.model.xidian_ids.*

class LearningCourseInfo {
    let courseId: String
    let clazzId: String
    let cpi: String
    let courseName: String
    let classNo: String
    init(courseId: String, clazzId: String, cpi: String, courseName: String, classNo: String) {
        this.courseId = courseId; this.clazzId = clazzId; this.cpi = cpi
        this.courseName = courseName; this.classNo = classNo
    }
}

public class LearningSession {
    static let loginUrl = "https://xdspoc.fanya.chaoxing.com/sso/xdspoc"
    static let courseInfoUrl = "https://fycourse.fanya.chaoxing.com/courselist/study"
    static let courseDataUrl = "https://fycourse.fanya.chaoxing.com/courselist/studyCourseDatashow"
    static let courseDetailUrl = "https://mobilelearn.chaoxing.com/v2/apis/signStat/getActiveList"
    private static var learningCookies: String = ""

    func baseCookies(): String {
        let snapshot = SessionStore().restore()
        if (!snapshot.loggedIn || snapshot.cookieHeader == "") {
            throw Exception("课堂考勤需要真实 IDS 会话，请重新登录。")
        }
        if (LearningSession.learningCookies == "") { LearningSession.learningCookies = snapshot.cookieHeader }
        return LearningSession.learningCookies
    }

    func request(url: String, host: String, success: (String) -> Unit, failure: (String) -> Unit): Unit {
        let client = createHttp()
        try {
            let headers = HashMap<String, String>()
            headers["Cookie"] = this.baseCookies()
            headers["Host"] = host
            headers["Accept"] = "text/html,application/json;q=0.9,*/*;q=0.8"
            headers["User-Agent"] = "Mozilla/5.0 (HarmonyOS; XDYou)"
            let options = HttpRequestOptions(method: RequestMethod.Get, header: headers,
                expectDataType: HttpDataType.StringValue, usingCache: false,
                connectTimeout: 10000, readTimeout: 30000)
            client.request(url, options, { error, response =>
                client.destroy()
                match (error) {
                    case Some(value) => failure("课堂考勤网络错误 ${value.code}: ${value.message}")
                    case None => match (response) {
                        case Some(value) =>
                            LearningSession.learningCookies = this.mergeCookies(LearningSession.learningCookies, value.cookies)
                            if (value.responseCode != 200) { failure("课堂考勤服务返回 HTTP ${value.responseCode}") }
                            else { match (value.result) { case HttpData.StringData(body) => success(body); case _ => failure("课堂考勤服务返回了非文本响应") } }
                        case None => failure("课堂考勤服务未返回响应")
                    }
                }
            })
        } catch (error: BusinessException) { client.destroy(); failure("无法启动课堂考勤请求：${error.code} ${error.message}") }
        catch (error: Exception) { client.destroy(); failure(error.message) }
    }

    func ensureLearningLogin(success: () -> Unit, failure: (String) -> Unit): Unit {
        this.request(LearningSession.loginUrl, "xdspoc.fanya.chaoxing.com", { body =>
            let lower = body.toAsciiLower()
            if (lower.contains("pwdencryptsalt") || lower.contains("authserver/login")) {
                failure("IDS 会话已失效或尚未授权学习通，请退出后重新登录。")
            } else { success() }
        }, failure)
    }

    public func loadAttendance(success: (ArrayList<ClassAttendance>) -> Unit, failure: (String) -> Unit): Unit {
        this.ensureLearningLogin({ => this.loadCourseList(success, failure) }, failure)
    }

    func loadCourseList(success: (ArrayList<ClassAttendance>) -> Unit, failure: (String) -> Unit): Unit {
        this.request(LearningSession.courseInfoUrl, "fycourse.fanya.chaoxing.com", { html =>
            try {
                let semester = this.selectedSemester(html)
                let courses = this.parseCourseList(html)
                let query = "?v=1&semesternum=${this.urlEncode(semester)}"
                this.request(LearningSession.courseDataUrl + query, "fycourse.fanya.chaoxing.com", { tableHtml =>
                    try { success(this.parseAttendanceTable(tableHtml, courses)) }
                    catch (error: Exception) { failure("考勤表解析失败：${error.message}") }
                }, failure)
            } catch (error: Exception) { failure("课程列表解析失败：${error.message}") }
        }, failure)
    }

    public func loadAttendanceDetail(course: ClassAttendance, page: Int64, pageSize: Int64,
        success: (ArrayList<ClassAttendanceDetail>) -> Unit, failure: (String) -> Unit): Unit {
        if (course.courseId == "" || course.clazzId == "") { failure("该课程缺少超星课程标识，无法读取签到详情。"); return }
        let url = LearningSession.courseDetailUrl + "?classId=${this.urlEncode(course.clazzId)}" +
            "&courseId=${this.urlEncode(course.courseId)}&page=${page}&pageSize=${pageSize}&puid="
        this.request(url, "mobilelearn.chaoxing.com", { body =>
            try {
                if (body.contains("请登录后再试")) { failure("学习通会话已失效，请刷新课程后重试。"); return }
                let root = JsonValue.fromStr(body).asObject()
                let result = ArrayList<ClassAttendanceDetail>()
                match (root.get("data")) {
                    case Some(dataValue) => match (dataValue.asObject().get("list")) {
                        case Some(listValue) =>
                            let rows = listValue.asArray()
                            var index: Int64 = 0
                            while (index < rows.size()) {
                                let row = rows[index].asObject()
                                result.add(ClassAttendanceDetail(
                                    this.field(row, "submittime"), this.field(row, "createxxuid"), this.intField(row, "userStatus"),
                                    this.field(row, "creatorName"), this.intField(row, "activeid"), this.field(row, "starttime"),
                                    this.intField(row, "attendid"), this.intField(row, "activeType"), this.field(row, "name"),
                                    this.intField(row, "other_id"), this.intField(row, "updatetime"), this.field(row, "createUid"),
                                    this.intField(row, "status")))
                                index += 1
                            }
                        case None => ()
                    }
                    case None => ()
                }
                success(result)
            } catch (error: Exception) { failure("签到详情解析失败：${error.message}") }
        }, failure)
    }

    func selectedSemester(html: String): String {
        let pattern = Regex(#"<option\b(?=[^>]*\bselected\b)[^>]*\bvalue\s*=\s*[\"']([^\"']*)[\"'][^>]*>"#, RegexFlag.IgnoreCase)
        match (pattern.find(html, group: true)) {
            case Some(value) => return this.decodeHtml(value.matchString(1)).trimAscii()
            case None =>
                let reverse = Regex(#"<option\b(?=[^>]*\bvalue\s*=\s*[\"']([^\"']*)[\"'])(?=[^>]*\bselected\b)[^>]*>"#, RegexFlag.IgnoreCase)
                match (reverse.find(html, group: true)) { case Some(value) => return this.decodeHtml(value.matchString(1)).trimAscii(); case None => throw Exception("未找到当前学期") }
        }
    }

    func parseCourseList(html: String): ArrayList<LearningCourseInfo> {
        let result = ArrayList<LearningCourseInfo>()
        let seen = HashSet<String>()
        let itemPattern = Regex(#"(<div\b[^>]*\bclass\s*=\s*[\"'][^\"']*\bmyde_course_item\b[^\"']*[\"'][^>]*>)([\s\S]*?)(?=<div\b[^>]*\bclass\s*=\s*[\"'][^\"']*\bmyde_course_item\b|$)"#, RegexFlag.IgnoreCase)
        for (matchData in itemPattern.findAll(html, group: true)) {
            let opening = matchData.matchString(1)
            let content = matchData.matchString(2)
            var courseName = this.attribute(opening, "cname")
            if (courseName == "") {
                courseName = Regex(#"\s*\([^)]*\)\s*$"#).replaceAll(this.firstTagText(content, "dt"), "").trimAscii()
            }
            let dds = ArrayList<String>()
            let ddPattern = Regex(#"<dd\b[^>]*>([\s\S]*?)</dd>"#, RegexFlag.IgnoreCase)
            for (dd in ddPattern.findAll(content, group: true)) { dds.add(this.htmlText(dd.matchString(1))) }
            let classNo = if (dds.size >= 2) { dds[1] } else { "" }
            let hrefPattern = Regex(#"<a\b[^>]*\bhref\s*=\s*[\"']([^\"']+)[\"'][^>]*>"#, RegexFlag.IgnoreCase)
            let href = match (hrefPattern.find(content, group: true)) { case Some(value) => this.decodeHtml(value.matchString(1)); case None => "" }
            var courseId = this.queryValue(href, "courseId")
            let clazzId = this.queryValue(href, "clazzId")
            let cpi = this.queryValue(href, "cpi")
            if (courseId == "") { courseId = this.attribute(opening, "cid") }
            if (courseId == "" || clazzId == "") { continue }
            let key = "${courseId}|${clazzId}"
            if (seen.contains(key)) { continue }
            seen.add(key)
            result.add(LearningCourseInfo(courseId, clazzId, cpi, courseName, classNo))
        }
        return result
    }

    func parseAttendanceTable(html: String, courses: ArrayList<LearningCourseInfo>): ArrayList<ClassAttendance> {
        let result = ArrayList<ClassAttendance>()
        let normalized = Regex("[\\r\\n\\t]").replaceAll(html, "")
        let rowPattern = Regex(#"<tr\b([^>]*)>([\s\S]*?)</tr>"#, RegexFlag.IgnoreCase)
        let cellPattern = Regex(#"<td\b[^>]*>([\s\S]*?)</td>"#, RegexFlag.IgnoreCase)
        for (row in rowPattern.findAll(normalized, group: true)) {
            let cells = ArrayList<String>()
            for (cell in cellPattern.findAll(row.matchString(2), group: true)) { cells.add(this.htmlText(cell.matchString(1))) }
            if (cells.size < 17) { continue }
            var courseId = ""; var clazzId = ""; var cpi = ""
            for (course in courses) {
                if (course.courseName == cells[0] && course.classNo == cells[1]) {
                    courseId = course.courseId; clazzId = course.clazzId; cpi = course.cpi; break
                }
            }
            let warning = Regex(#"\bclass\s*=\s*[\"'][^\"']*\bredtr\b"#, RegexFlag.IgnoreCase).find(row.matchString(1)).isSome()
            result.add(ClassAttendance(cells[0], cells[1], cells[2], cells[3], cells[4], cells[5], cells[6], cells[7], cells[8],
                cells[9], cells[10], cells[11], cells[12], cells[13], cells[14], cells[15], cells[16],
                courseId: courseId, clazzId: clazzId, cpi: cpi, isWarning: warning))
        }
        return result
    }

    func firstTagText(html: String, tag: String): String {
        let pattern = Regex("<${tag}\\b[^>]*>([\\s\\S]*?)</${tag}>", RegexFlag.IgnoreCase)
        match (pattern.find(html, group: true)) { case Some(value) => this.htmlText(value.matchString(1)); case None => "" }
    }
    func attribute(tag: String, name: String): String {
        let pattern = Regex("\\b${name}\\s*=\\s*[\\\"']([^\\\"']*)[\\\"']", RegexFlag.IgnoreCase)
        match (pattern.find(tag, group: true)) { case Some(value) => this.decodeHtml(value.matchString(1)).trimAscii(); case None => "" }
    }
    func queryValue(url: String, name: String): String {
        let pattern = Regex("(?:[?&])${name}=([^&#]*)", RegexFlag.IgnoreCase)
        match (pattern.find(url, group: true)) { case Some(value) => this.decodeHtml(value.matchString(1)).trimAscii(); case None => "" }
    }
    func htmlText(value: String): String { return this.decodeHtml(Regex(#"<[^>]+>"#).replaceAll(value, " ")).trimAscii() }
    func decodeHtml(value: String): String {
        return value.replace("&nbsp;", " ").replace("&amp;", "&").replace("&quot;", "\"").replace("&#39;", "'").replace("&lt;", "<").replace("&gt;", ">")
    }
    func urlEncode(value: String): String { return value.replace("%", "%25").replace(" ", "%20").replace("+", "%2B").replace("&", "%26").replace("=", "%3D") }

    func stringOf(value: JsonValue): String {
        match (value.kind()) { case JsString => value.asString().getValue(); case JsInt => value.asInt().getValue().toString(); case JsFloat => value.asFloat().getValue().toString(); case JsBool => value.asBool().getValue().toString(); case _ => "" }
    }
    func field(object: JsonObject, name: String): String { match (object.get(name)) { case Some(value) => this.stringOf(value); case None => "" } }
    func intField(object: JsonObject, name: String): Int64 { try { return Int64.parse(this.field(object, name)) } catch (_) { return -1 } }

    func mergeCookies(existing: String, raw: String): String {
        let values = ArrayList<String>()
        for (source in [existing, raw]) {
            for (line in Regex("[\\r\\n,]+").split(source)) {
                let parts = Regex(";").split(line)
                if (parts.size == 0 || !parts[0].contains("=")) { continue }
                let pair = parts[0].trimAscii(); let name = Regex("=").split(pair)[0]
                var replaced = false; var index: Int64 = 0
                while (index < values.size) { if (values[index].startsWith("${name}=")) { values[index] = pair; replaced = true }; index += 1 }
                if (!replaced) { values.add(pair) }
            }
        }
        var result = ""; for (item in values) { if (result != "") { result += "; " }; result += item }; return result
    }
}
