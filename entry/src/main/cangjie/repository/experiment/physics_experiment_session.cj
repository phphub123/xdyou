package ohos_app_cangjie_entry.repository.experiment

import kit.NetworkKit.*
import ohos.business_exception.*
import std.collection.*
import std.regex.*
import std.time.*
import ohos_app_cangjie_entry.model.*
import ohos_app_cangjie_entry.repository.auth.*

public class PhysicsExperimentSession {
    static let baseUrl = "http://wlsy.xidian.edu.cn/PhyEws"
    static let passwordKey = "physicsExperimentPasswordEncrypted"
    static let accountKey = "physicsExperimentAccount"
    var cookie: String = ""

    public func storedAccount(): String {
        let store = SessionStore(); let value = store.restoreSetting(PhysicsExperimentSession.accountKey)
        return if (value == "") { store.restore().account } else { value }
    }
    public func hasStoredCredential(): Bool { SessionStore().restoreSetting(PhysicsExperimentSession.passwordKey) != "" }
    public func clearCredential(): Unit { let store = SessionStore(); store.saveSetting(PhysicsExperimentSession.passwordKey, ""); store.saveSetting(PhysicsExperimentSession.accountKey, "") }
    func password(input: String): String {
        if (input != "") { return input }
        let encrypted = SessionStore().restoreSetting(PhysicsExperimentSession.passwordKey)
        if (encrypted == "") { throw Exception("请输入物理实验系统独立密码。") }
        try { return SecureSessionCipher.decrypt(encrypted) } catch (_) { throw Exception("物理实验密码安全存储已失效，请重新输入。") }
    }
    func remember(account: String, password: String): Unit { let store = SessionStore(); store.saveSetting(PhysicsExperimentSession.accountKey, account); store.saveSetting(PhysicsExperimentSession.passwordKey, SecureSessionCipher.encrypt(password)) }
    func encode(value: String): String { value.replace("%", "%25").replace(" ", "%20").replace("!", "%21").replace("#", "%23").replace("$", "%24").replace("&", "%26").replace("+", "%2B").replace("/", "%2F").replace("=", "%3D").replace("?", "%3F") }
    func headerValue(headers: HashMap<String, String>, name: String): String { for ((key,value) in headers) { if (key.toAsciiLower() == name.toAsciiLower()) { return value } }; return "" }
    func request(method: RequestMethod, url: String, body: String, cookie: String,
        success: (UInt32, HashMap<String,String>, String, String) -> Unit, failure: (String) -> Unit): Unit {
        let client = createHttp(); let headers = HashMap<String,String>()
        headers["Accept"] = "text/html,application/xhtml+xml,*/*;q=0.8"; headers["Content-Type"] = "application/x-www-form-urlencoded"
        headers["Host"] = "wlsy.xidian.edu.cn"; if (cookie != "") { headers["Cookie"] = cookie }
        try {
            let options = HttpRequestOptions(method: method, header: headers, extraData: HttpData.StringData(body), expectDataType: HttpDataType.StringValue, usingCache: false, connectTimeout: 10000, readTimeout: 30000)
            client.request(url, options, { error,response => client.destroy(); match(error) {
                case Some(value) => failure("物理实验服务网络错误 ${value.code}: ${value.message}")
                case None => match(response) { case Some(value) => match(value.result) { case HttpData.StringData(text) => success(value.responseCode,value.header,value.cookies,text); case _ => failure("物理实验服务返回非文本响应。") }; case None => failure("物理实验服务未返回响应。") }
            }})
        } catch (e: BusinessException) { client.destroy(); failure("无法启动物理实验请求：${e.code} ${e.message}") }
    }
    func attribute(tag: String, name: String): String { match (Regex("\\b${name}\\s*=\\s*[\\\"']([^\\\"']*)[\\\"']", RegexFlag.IgnoreCase).find(tag, group: true)) { case Some(value) => value.matchString(1); case None => "" } }
    func hiddenForm(html: String): String {
        var result = ""
        for (found in Regex(#"<input\b[^>]*>"#, RegexFlag.IgnoreCase).findAll(html)) {
            let tag = found.matchString(); let name = this.attribute(tag,"name"); let value = this.attribute(tag,"value")
            if (name != "" && name != "login1$StuLoginID" && name != "login1$StuPassword") { if (result != "") { result += "&" }; result += "${this.encode(name)}=${this.encode(value)}" }
        }
        return result
    }
    func mergeCookie(cookies: String, headers: HashMap<String,String>): String {
        let raw = cookies + "\n" + this.headerValue(headers,"set-cookie"); let result = ArrayList<String>()
        for (line in Regex("[\\r\\n,]+").split(raw)) { let fields = Regex(";").split(line); if (fields.size > 0 && fields[0].contains("=")) { let pair = fields[0].trimAscii(); if (!pair.startsWith("PhyEws_StuName=") && !pair.toAsciiLower().startsWith("httponly")) { result.add(pair) } } }
        // The source application substitutes this server-required display-name cookie.
        result.add("PhyEws_StuName=waterfloatinggenderly")
        var value = ""; for (pair in result) { if (value != "") { value += "; " }; value += pair }; return value
    }
    public func load(accountInput: String, passwordInput: String, success: (ArrayList<ExperimentData>) -> Unit, failure: (String) -> Unit): Unit {
        let account = if (accountInput == "") { this.storedAccount() } else { accountInput }
        if (account == "") { failure("请输入学号。") ; return }
        try {
            let plainPassword = this.password(passwordInput)
            this.request(RequestMethod.Get, PhysicsExperimentSession.baseUrl + "/default.aspx", "", "", { code,_,_,html =>
                if (code != 200) { failure("物理实验登录页返回 HTTP ${code}。") ; return }
                var form = this.hiddenForm(html)
                if (form != "") { form += "&" }
                form += "login1%24StuLoginID=${this.encode(account)}&login1%24StuPassword=${this.encode(plainPassword)}&login1%24UserRole=Student&login1%24btnLogin.x=28&login1%24btnLogin.y=14"
                this.request(RequestMethod.Post, PhysicsExperimentSession.baseUrl + "/default.aspx", form, "", { loginCode,headers,cookies,loginHtml =>
                    if (loginCode != 302 && loginCode != 303) { failure(this.loginError(loginHtml)); return }
                    this.cookie = this.mergeCookie(cookies,headers); this.remember(account,plainPassword)
                    ExperimentReportSession().recognizeAll(account,plainPassword,
                        { scores => this.loadSchedule(scores,success,failure) },
                        { _ => this.loadSchedule(HashMap<String,RecognitionResult>(),success,failure) })
                },failure)
            },failure)
        } catch (e: Exception) { failure(e.message) }
    }
    func loginError(html: String): String { match (Regex(#"(?is)id=[\"']login1_Label1[\"'][^>]*>(.*?)</"#).find(html,group:true)) { case Some(value) => "物理实验登录失败：${this.text(value.matchString(1))}"; case None => "物理实验登录失败，请核对独立密码或校园网环境。" } }
    func text(html: String): String { Regex(#"<[^>]+>"#).replaceAll(html," ").replace("&nbsp;"," ").replace("&amp;","&").trimAscii() }
    func tdValues(row: String): ArrayList<String> { let values=ArrayList<String>(); for (found in Regex(#"(?is)<td\b[^>]*>(.*?)</td>"#).findAll(row,group:true)) { values.add(found.matchString(1)) }; return values }
    func firstSpan(html: String): String { match (Regex(#"(?is)<span\b[^>]*>(.*?)</span>"#).find(html,group:true)) { case Some(value)=>this.text(value.matchString(1)); case None=>this.text(html) } }
    func loadSchedule(scores: HashMap<String,RecognitionResult>, success: (ArrayList<ExperimentData>) -> Unit, failure: (String) -> Unit): Unit {
        this.request(RequestMethod.Get, PhysicsExperimentSession.baseUrl + "/student/select.aspx", "", this.cookie, { code,_,_,html =>
            if (code != 200) { failure("物理实验安排返回 HTTP ${code}。") ; return }
            try {
                let result=ArrayList<ExperimentData>()
                for (row in Regex(#"(?is)<tr\b[^>]*>(.*?)</tr>"#).findAll(html,group:true)) {
                    let cells=this.tdValues(row.matchString(1)); if (cells.size < 10) { continue }
                    let date=this.firstSpan(cells[4]); let parts=Regex("/").split(date); if (parts.size < 3) { continue }
                    let timeText=this.firstSpan(cells[3]); let startHour:Int64=if(timeText.contains("15")){15}else{18}; let startMinute:Int64=if(startHour==15){55}else{30}; let endHour:Int64=if(startHour==15){18}else{20}; let endMinute:Int64=if(startHour==15){10}else{45}
                    let start=DateTime.parse("${parts[2]}/${parts[0]}/${parts[1]} ${startHour}:${startMinute}:00", "yyyy/MM/dd HH:mm:ss"); let end=DateTime.parse("${parts[2]}/${parts[0]}/${parts[1]} ${endHour}:${endMinute}:00", "yyyy/MM/dd HH:mm:ss")
                    let name=this.text(cells[1]).replace("（3学时）","").trimAscii(); if(name==""){continue}; let ranges=ArrayList<ExperimentTimeRange>(); ranges.add(ExperimentTimeRange(start,end))
                    let score:?RecognitionResult=match(scores.get(name)){case Some(value)=>Some(value);case None=>None}
                    result.add(ExperimentData(ExperimentType.Physics,name,this.firstSpan(cells[5]),ranges,"教师信息需由课程页返回",reference:this.firstSpan(cells[9]),score:score))
                }
                result.sortBy(comparator: { left,right => left.firstStart().compare(right.firstStart()) }); success(result)
            } catch(e:Exception){failure("物理实验安排解析失败：${e.message}")}
        },failure)
    }
}
