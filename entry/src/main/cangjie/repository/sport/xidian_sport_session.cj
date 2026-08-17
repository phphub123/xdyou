package ohos_app_cangjie_entry.repository.sport

// 体育系统仓储，复用认证会话并解析课程成绩与体测数据。

import kit.NetworkKit.*
import ohos.business_exception.*
import std.collection.*
import std.convert.*
import std.io.*
import std.time.*
import stdx.crypto.digest.*
import stdx.crypto.keys.*
import stdx.encoding.hex.*
import stdx.encoding.json.*
import ohos_app_cangjie_entry.model.*
import ohos_app_cangjie_entry.repository.auth.*

// Real Xidian sport-service implementation. Credentials are never logged and
// Preferences only receives HUKS-authenticated ciphertext.
// 体育系统查询入口，服务端失败时保持真实错误而不生成演示成绩。
public class SportSession {
    static let baseUrl: String = "http://tybjxgl.xidian.edu.cn/app"
    static let publicKeyPem: String = """
-----BEGIN PUBLIC KEY-----
MIIBIjANBgkqhkiG9w0BAQEFAAOCAQ8AMIIBCgKCAQEAq4l
aolA7zAk7jzsqDb3Oa5pS/uCPlZfASK8Soh/NzEmry77QDZ
2koyr96M5Wx+A9cxwewQMHzi8RoOfb3UcQO4UDQlMUImLuz
Unfbk3TTppijSLH+PU88XQxcgYm2JTa546c7JdZSI6dBeXO
JH20quuxWyzgLk9jAlt3ytYygPQ7C6o6ZSmjcMgE3xgLaHG
vixEVpOjL/pdVLzXhrMqWVAnB/snMjpCqesDVTDe5c6OOmj
2q5J8n+tzIXtnvrkxQSDaUp8DWF8meMwyTErmYklMXzKic2
rjdYZpHh4x98Fg0Q28sp6i2ZoWiGrJDKW29mntVQQiDNhKD
awb4B45zUwIDAQAB
-----END PUBLIC KEY-----
"""
    static let encryptedPasswordKey: String = "sportPasswordEncrypted"
    static let accountKey: String = "sportAccount"
    private var token: String = ""
    private var userId: String = ""

    public func storedAccount(): String {
        let store = SessionStore()
        let sportAccount = store.restoreSetting(SportSession.accountKey)
        if (sportAccount != "") { return sportAccount }
        return store.restore().account
    }

    public func hasStoredCredential(): Bool { SessionStore().restoreSetting(SportSession.encryptedPasswordKey) != "" }

    public func clearCredential(): Unit {
        let store = SessionStore()
        store.saveSetting(SportSession.encryptedPasswordKey, "")
        store.saveSetting(SportSession.accountKey, "")
        this.token = ""
        this.userId = ""
    }

    func password(input: String): String {
        if (input != "") { return input }
        let encrypted = SessionStore().restoreSetting(SportSession.encryptedPasswordKey)
        if (encrypted == "") { throw Exception("请输入独立体育系统密码。") }
        try { return SecureSessionCipher.decrypt(encrypted) }
        catch (_) { throw Exception("体育密码安全存储已失效，请重新输入。") }
    }

    func remember(account: String, password: String): Unit {
        let store = SessionStore()
        store.saveSetting(SportSession.accountKey, account)
        store.saveSetting(SportSession.encryptedPasswordKey, SecureSessionCipher.encrypt(password))
    }

    func rsaEncrypt(text: String): String {
        let key = RSAPublicKey.decodeFromPem(SportSession.publicKeyPem)
        let input = ByteBuffer()
        let output = ByteBuffer()
        input.write(text.toArray())
        key.encrypt(input, output, padType: PKCS1)
        return IDSPasswordCipher.toBase64(readToEnd(output))
    }

    func md5Hex(text: String): String {
        let digest = MD5()
        digest.write(text.toArray())
        return toHexString(digest.finish())
    }

    func encode(value: String): String {
        return value.replace("%", "%25").replace("+", "%2B").replace("/", "%2F")
            .replace("=", "%3D").replace("&", "%26").replace(" ", "%20")
    }

    func post(path: String, form: String, signatureSource: String, success: (JsonObject) -> Unit, failure: (String) -> Unit): Unit {
        let client = createHttp()
        try {
            let headers = HashMap<String, String>()
            headers["channel"] = "H5"
            headers["version"] = "99999"
            headers["type"] = "0"
            headers["token"] = this.token
            headers["timestamp"] = this.timestampFromForm(form)
            headers["sign"] = this.md5Hex(signatureSource)
            headers["Content-Type"] = "application/x-www-form-urlencoded"
            headers["Accept"] = "application/json"
            let options = HttpRequestOptions(method: RequestMethod.Post, header: headers,
                extraData: HttpData.StringData(form), expectDataType: HttpDataType.StringValue,
                usingCache: false, connectTimeout: 10000, readTimeout: 30000)
            client.request(SportSession.baseUrl + path, options, { error, response =>
                client.destroy()
                match (error) {
                    case Some(value) => failure("体育服务网络错误 ${value.code}: ${value.message}")
                    case None => match (response) {
                        case Some(value) =>
                            if (value.responseCode != 200) { failure("体育服务返回 HTTP ${value.responseCode}。") }
                            else { match (value.result) {
                                case HttpData.StringData(body) => try { success(JsonValue.fromStr(body).asObject()) } catch (e: Exception) { failure("体育服务响应解析失败：${e.message}") }
                                case _ => failure("体育服务返回了非文本响应。")
                            } }
                        case None => failure("体育服务未返回响应。")
                    }
                }
            })
        } catch (e: BusinessException) { client.destroy(); failure("无法启动体育服务请求：${e.code} ${e.message}") }
        catch (e: Exception) { client.destroy(); failure(e.message) }
    }

    func timestampFromForm(form: String): String {
        for (part in form.split("&")) { if (part.startsWith("timestamp=")) { return part[10..part.size] } }
        return ""
    }

    func responseOk(root: JsonObject): Bool { let code = this.field(root, "returnCode"); return code == "200" }
    func responseMessage(root: JsonObject): String { let msg = this.field(root, "returnMsg"); return if (msg == "") { "体育服务请求失败。" } else { msg } }

    func login(accountInput: String, passwordInput: String, success: () -> Unit, failure: (String) -> Unit): Unit {
        let account = if (accountInput == "") { this.storedAccount() } else { accountInput }
        if (account == "") { failure("请输入学号。") ; return }
        try {
            let plainPassword = this.password(passwordInput)
            let encrypted = this.rsaEncrypt(plainPassword)
            let timestamp = DateTime.now().toUnixTimeStamp().toMilliseconds().toString()
            let form = "uname=${this.encode(account)}&pwd=${this.encode(encrypted)}&openid=&timestamp=${timestamp}"
            let signature = "openid=&pwd=${encrypted}&timestamp=${timestamp}&uname=${account}"
            this.token = ""
            this.post("/h5/login", form, signature, { root =>
                if (!this.responseOk(root)) { failure("体育系统登录失败：${this.responseMessage(root)}"); return }
                try {
                    let data = root["data"].asObject()
                    this.userId = this.field(data, "id")
                    this.token = this.field(data, "token")
                    if (this.userId == "" || this.token == "") { failure("体育系统登录响应缺少用户标识或令牌。"); return }
                    this.remember(account, plainPassword)
                    success()
                } catch (e: Exception) { failure("体育系统登录响应解析失败：${e.message}") }
            }, failure)
        } catch (e: Exception) { failure(e.message) }
    }

    public func getScore(account: String, password: String, success: (SportScore) -> Unit, failure: (String) -> Unit): Unit {
        this.login(account, password, { => this.loadScoreSummary(success, failure) }, failure)
    }

    func loadScoreSummary(success: (SportScore) -> Unit, failure: (String) -> Unit): Unit {
        let timestamp = DateTime.now().toUnixTimeStamp().toMilliseconds().toString()
        let form = "userId=${this.encode(this.userId)}&timestamp=${timestamp}"
        let signature = "timestamp=${timestamp}&userId=${this.userId}"
        this.post("/measure/getStuTotalScore", form, signature, { root =>
            if (!this.responseOk(root)) { failure(this.responseMessage(root)); return }
            try {
                let score = SportScore()
                let rows = root["data"].asArray()
                var index: Int64 = 0
                while (index < rows.size()) {
                    let row = rows[index].asObject()
                    match (row.get("graduationStatus")) {
                        case Some(_) => score.total = this.field(row, "totalScore"); score.detail = this.field(row, "gradeType"); score.rank = this.field(row, "rank")
                        case None => score.years.add(SportScoreOfYear(this.field(row, "meaScoreId"), this.field(row, "year"), this.field(row, "totalScore"), this.field(row, "rank"), this.field(row, "gradeType")))
                    }
                    index += 1
                }
                this.loadScoreDetails(score, 0, success, failure)
            } catch (e: Exception) { failure("体测成绩响应解析失败：${e.message}") }
        }, failure)
    }

    func loadScoreDetails(score: SportScore, index: Int64, success: (SportScore) -> Unit, failure: (String) -> Unit): Unit {
        if (index >= score.years.size) { success(score); return }
        let year = score.years[index]
        if (year.measureScoreId == "") { year.moreInfo = "缺少年度成绩标识。"; this.loadScoreDetails(score, index + 1, success, failure); return }
        let timestamp = DateTime.now().toUnixTimeStamp().toMilliseconds().toString()
        let form = "meaScoreId=${this.encode(year.measureScoreId)}&timestamp=${timestamp}"
        let signature = "meaScoreId=${year.measureScoreId}&timestamp=${timestamp}"
        this.post("/measure/getStuScoreDetail", form, signature, { root =>
            if (!this.responseOk(root)) { year.moreInfo = this.responseMessage(root); this.loadScoreDetails(score, index + 1, success, failure); return }
            try {
                let rows = root["data"].asArray(); var rowIndex: Int64 = 0
                while (rowIndex < rows.size()) {
                    let row = rows[rowIndex].asObject()
                    year.details.add(SportItem(this.field(row,"examName"), this.field(row,"examunit"), this.first(this.field(row,"actualScore"), "0"), this.floatField(row,"score"), this.first(this.field(row,"rank"), "不合格")))
                    rowIndex += 1
                }
                this.loadScoreDetails(score, index + 1, success, failure)
            } catch (e: Exception) { failure("年度体测明细解析失败：${e.message}") }
        }, failure)
    }

    public func getClass(account: String, password: String, success: (ArrayList<SportClassItem>) -> Unit, failure: (String) -> Unit): Unit {
        this.login(account, password, { => this.loadClassTerms(success, failure) }, failure)
    }

    func loadClassTerms(success: (ArrayList<SportClassItem>) -> Unit, failure: (String) -> Unit): Unit {
        let timestamp = DateTime.now().toUnixTimeStamp().toMilliseconds().toString()
        let form = "uid=${this.encode(this.userId)}&pageIndex=1&pageSize=100&timestamp=${timestamp}"
        let signature = "pageIndex=1&pageSize=100&timestamp=${timestamp}&uid=${this.userId}"
        this.post("/stuTermScore/uidSelect", form, signature, { root =>
            if (!this.responseOk(root)) { failure(this.responseMessage(root)); return }
            try { this.loadClassAt(root["data"].asArray(), 0, ArrayList<SportClassItem>(), success, failure) }
            catch (e: Exception) { failure("体育课学期响应解析失败：${e.message}") }
        }, failure)
    }

    func loadClassAt(rows: JsonArray, index: Int64, result: ArrayList<SportClassItem>, success: (ArrayList<SportClassItem>) -> Unit, failure: (String) -> Unit): Unit {
        if (index >= rows.size()) { success(result); return }
        let termScore = rows[index].asObject()
        let scoreId = this.field(termScore, "id")
        let timestamp = DateTime.now().toUnixTimeStamp().toMilliseconds().toString()
        let form = "stuid=${this.encode(this.userId)}&stuTermScoreid=${this.encode(scoreId)}&timestamp=${timestamp}"
        let signature = "stuid=${this.userId}&stuTermScoreid=${scoreId}&timestamp=${timestamp}"
        this.post("/stuTeacherCurriculum/selstuTeacherCurriculum", form, signature, { root =>
            if (this.responseOk(root)) {
                try {
                    let dataRows = root["data"].asArray()
                    if (dataRows.size() > 0) {
                        let row = dataRows[0].asObject()
                        result.add(SportClassItem(this.field(row,"teacherCurriculumSysTermName"), this.field(row,"teacherCurriculumTeachingCurriculumName"), this.field(row,"teacherCurriculumSysUserName"), this.field(row,"teacherCurriculumTeachingSchoolTimeName"), this.field(row,"teacherCurriculumTeachingAddressName"), this.field(termScore,"score"), this.field(termScore,"type")))
                    }
                } catch (e: Exception) { failure("体育课详情解析失败：${e.message}"); return }
            }
            this.loadClassAt(rows, index + 1, result, success, failure)
        }, failure)
    }

    func stringOf(value: JsonValue): String { match (value.kind()) { case JsString => value.asString().getValue(); case JsInt => value.asInt().getValue().toString(); case JsFloat => value.asFloat().getValue().toString(); case JsBool => value.asBool().getValue().toString(); case _ => "" } }
    func field(object: JsonObject, name: String): String { match (object.get(name)) { case Some(value) => this.stringOf(value); case None => "" } }
    func floatField(object: JsonObject, name: String): Float64 { try { return Float64.parse(this.field(object,name)) } catch (_) { return 0.0 } }
    func first(value: String, fallback: String): String { return if (value == "") { fallback } else { value } }
}
