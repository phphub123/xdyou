package ohos_app_cangjie_entry.repository.xidian_ids

import kit.NetworkKit.*
import ohos.business_exception.*
import std.collection.*
import std.regex.*
import stdx.encoding.json.*
import ohos_app_cangjie_entry.model.xidian_ids.*
import ohos_app_cangjie_entry.repository.*

// Real campus-card requests only. OpenID, payment QR data and response bodies stay in memory.
public class SchoolCardSession {
    static let baseUrl = "https://v8scan.xidian.edu.cn"
    private var openid: String = ""
    private var serviceCookie: String = ""

    func sessionCookie(): String {
        let snapshot = SessionStore().restore()
        if (!snapshot.loggedIn || snapshot.cookieHeader == "") {
            throw Exception("A real IDS session is required before campus-card data can load.")
        }
        return snapshot.cookieHeader
    }

    func headerValue(headers: HashMap<String, String>, name: String): ?String {
        for ((key, value) in headers) {
            if (key.toAsciiLower() == name.toAsciiLower()) { return Some(value) }
        }
        return None
    }

    func mergeCookies(base: String, raw: String): String {
        let values = ArrayList<String>()
        for (pair in Regex(";").split(base)) { this.upsertCookie(values, pair.trimAscii()) }
        for (line in Regex("[\\r\\n,]+").split(raw)) {
            let fields = Regex(";").split(line)
            if (fields.size > 0) { this.upsertCookie(values, fields[0].trimAscii()) }
        }
        var result = ""
        for (item in values) { if (result != "") { result += "; " }; result += item }
        return result
    }

    func upsertCookie(values: ArrayList<String>, pair: String): Unit {
        if (!pair.contains("=")) { return }
        let fields = Regex("=").split(pair)
        if (fields.size == 0 || fields[0] == "") { return }
        let prefix = "${fields[0]}="
        var index: Int64 = 0
        while (index < values.size) {
            if (values[index].startsWith(prefix)) { values[index] = pair; return }
            index += 1
        }
        values.add(pair)
    }

    func request(url: String, method: RequestMethod, cookie: String, body: String,
        success: (UInt32, HashMap<String, String>, String, String) -> Unit,
        failure: (String) -> Unit): Unit {
        let client = createHttp()
        try {
            let headers = HashMap<String, String>()
            if (cookie != "") { headers["Cookie"] = cookie }
            headers["Accept"] = "text/html,application/json;q=0.9,*/*;q=0.8"
            headers["Referer"] = SchoolCardSession.baseUrl + "/"
            headers["Content-Type"] = "application/json; charset=utf-8"
            let options = HttpRequestOptions(method: method, header: headers,
                extraData: HttpData.StringData(body),
                expectDataType: HttpDataType.StringValue, usingCache: false,
                connectTimeout: 10000, readTimeout: 30000)
            client.request(url, options, { error, response =>
                client.destroy()
                match (error) {
                    case Some(value) => failure("Campus-card network error ${value.code}: ${value.message}")
                    case None => match (response) {
                        case Some(value) => match (value.result) {
                            case HttpData.StringData(text) =>
                                let setCookie = match (this.headerValue(value.header, "set-cookie")) { case Some(raw) => raw; case None => "" }
                                success(value.responseCode, value.header, text, this.mergeCookies(cookie, value.cookies + "\n" + setCookie))
                            case _ => failure("Campus-card service returned a non-text response.")
                        }
                        case None => failure("Campus-card service returned no response.")
                    }
                }
            })
        } catch (error: BusinessException) {
            client.destroy()
            failure("Unable to start campus-card request: ${error.code} ${error.message}")
        }
    }

    func absoluteLocation(location: String): String {
        if (location.startsWith("http://") || location.startsWith("https://")) { return location }
        if (location.startsWith("/")) { return SchoolCardSession.baseUrl + location }
        return SchoolCardSession.baseUrl + "/" + location
    }

    func follow(url: String, cookie: String, depth: Int64,
        success: (String, String) -> Unit, failure: (String) -> Unit): Unit {
        if (depth > 8) { failure("Campus-card SSO exceeded the redirect limit."); return }
        this.request(url, RequestMethod.Get, cookie, "", { code, headers, body, merged =>
            if (code == 301 || code == 302 || code == 303 || code == 307 || code == 308) {
                match (this.headerValue(headers, "location")) {
                    case Some(location) => this.follow(this.absoluteLocation(location), merged, depth + 1, success, failure)
                    case None => failure("Campus-card SSO redirect did not include a Location header.")
                }
            } else if (code == 200) { success(body, merged) }
            else { failure("Campus-card service returned HTTP ${code}.") }
        }, failure)
    }

    func attribute(tag: String, name: String): String {
        let pattern = Regex("\\b${name}\\s*=\\s*[\\\"']([^\\\"']*)[\\\"']", RegexFlag.IgnoreCase)
        match (pattern.find(tag, group: true)) { case Some(found) => return found.matchString(1); case None => return "" }
    }

    func ensureOpenId(success: () -> Unit, failure: (String) -> Unit): Unit {
        if (this.openid != "" && this.serviceCookie != "") { success(); return }
        try {
            let cookie = this.sessionCookie()
            this.follow(SchoolCardSession.baseUrl + "/home/openXDOAuth2Page", cookie, 0, { html, merged =>
                let inputPattern = Regex(#"<input\b[^>]*\bid\s*=\s*[\"']openid[\"'][^>]*>"#, RegexFlag.IgnoreCase)
                match (inputPattern.find(html)) {
                    case Some(found) =>
                        let value = this.attribute(found.matchString(), "value")
                        if (value == "") { failure("Campus-card SSO did not return an OpenID.") }
                        else { this.openid = value; this.serviceCookie = merged; success() }
                    case None => failure("Campus-card SSO did not reach the account service. Sign in to IDS again.")
                }
            }, failure)
        } catch (error: Exception) { failure(error.message) }
    }

    func moneyFromOverview(html: String): String {
        let firstItem = Regex(#"<li\b[^>]*>([\s\S]*?)</li>"#, RegexFlag.IgnoreCase)
        match (firstItem.find(html, group: true)) {
            case Some(found) =>
                let text = Regex(#"<[^>]+>"#).replaceAll(found.matchString(1), " ")
                match (Regex(#"[-+]?[0-9]+(?:\.[0-9]+)?"#).find(text)) {
                    case Some(money) => return money.matchString()
                    case None => return ""
                }
            case None => return ""
        }
    }

    public func getOverview(success: (SchoolCardOverview) -> Unit, failure: (String) -> Unit): Unit {
        this.ensureOpenId({ =>
            this.request(SchoolCardSession.baseUrl + "/myaccount/openMyAccount?openid=${this.openid}",
                RequestMethod.Get, this.serviceCookie, "", { code, _, html, merged =>
                    this.serviceCookie = merged
                    if (code != 200) { failure("Campus-card overview returned HTTP ${code}."); return }
                    let money = this.moneyFromOverview(html)
                    if (money == "") { failure("Campus-card overview did not contain a balance.") }
                    else { success(SchoolCardOverview(money)) }
                }, failure)
        }, failure)
    }

    public func getPaidStatus(begin: String, end: String,
        success: (ArrayList<PaidRecord>) -> Unit, failure: (String) -> Unit): Unit {
        if (!Regex(#"^[0-9]{4}-[0-9]{2}-[0-9]{2}$"#).matches(begin) ||
            !Regex(#"^[0-9]{4}-[0-9]{2}-[0-9]{2}$"#).matches(end)) {
            failure("Dates must use yyyy-MM-dd."); return
        }
        this.ensureOpenId({ =>
            let body = "{\"beginDate\":\"${begin}\",\"endDate\":\"${end}\",\"tradeType\":\"-1\",\"openid\":\"${this.openid}\"}"
            this.request(SchoolCardSession.baseUrl + "/selftrade/queryCardSelfTradeList?openid=${this.openid}",
                RequestMethod.Post, this.serviceCookie, body, { code, _, text, merged =>
                    this.serviceCookie = merged
                    if (code != 200) { failure("Campus-card records returned HTTP ${code}."); return }
                    try {
                        let root = JsonValue.fromStr(text).asObject()
                        match (root.get("resultData")) {
                            case Some(value) =>
                                let rows = value.asArray(); let result = ArrayList<PaidRecord>(); var index: Int64 = 0
                                while (index < rows.size()) {
                                    let row = rows[index].asObject()
                                    result.add(PaidRecord(this.field(row, "mername"), this.field(row, "txdate"), this.field(row, "txamt")))
                                    index += 1
                                }
                                success(result)
                            case None => failure("Campus-card response did not contain transaction data.")
                        }
                    } catch (error: Exception) { failure("Malformed campus-card transaction response: ${error.message}") }
                }, failure)
        }, failure)
    }

    public func getQRCode(success: (String) -> Unit, failure: (String) -> Unit): Unit {
        this.ensureOpenId({ =>
            this.request(SchoolCardSession.baseUrl + "/home/openHomePage?openid=${this.openid}", RequestMethod.Get,
                this.serviceCookie, "", { code, _, home, merged =>
                    this.serviceCookie = merged
                    if (code != 200) { failure("Campus-card home returned HTTP ${code}."); return }
                    let linkPattern = Regex(#"href\s*=\s*[\"']([^\"']*virtualcard/openVirtualcard[^\"']*)[\"']"#, RegexFlag.IgnoreCase)
                    match (linkPattern.find(home, group: true)) {
                        case Some(found) =>
                            let href = found.matchString(1).replace("&amp;", "&")
                            match (Regex(#"(?:\?|&)id=([^&\"']+)"#).find(href, group: true)) {
                                case Some(idMatch) => this.loadQrImage(idMatch.matchString(1), success, failure)
                                case None => failure("Campus-card virtual-card link did not contain an id.")
                            }
                        case None => failure("Campus-card virtual-card entry was not available.")
                    }
                }, failure)
        }, failure)
    }

    func loadQrImage(id: String, success: (String) -> Unit, failure: (String) -> Unit): Unit {
        let url = SchoolCardSession.baseUrl + "/virtualcard/openVirtualcard?openid=${this.openid}&displayflag=1&id=${id}"
        this.request(url, RequestMethod.Get, this.serviceCookie, "", { code, _, html, merged =>
            this.serviceCookie = merged
            if (code != 200) { failure("Campus-card QR page returned HTTP ${code}."); return }
            let imagePattern = Regex(#"<img\b[^>]*\bid\s*=\s*[\"']qrcode[\"'][^>]*>"#, RegexFlag.IgnoreCase)
            match (imagePattern.find(html)) {
                case Some(found) =>
                    let src = this.attribute(found.matchString(), "src").replace("&#10;", "").replace("\n", "")
                    if (!src.startsWith("data:image/")) { failure("Campus-card QR image had an unexpected format.") }
                    else { success(src) }
                case None => failure("Campus-card QR page did not contain an image.")
            }
        }, failure)
    }

    func stringOf(value: JsonValue): String {
        match (value.kind()) {
            case JsString => value.asString().getValue()
            case JsInt => value.asInt().getValue().toString()
            case JsFloat => value.asFloat().getValue().toString()
            case _ => ""
        }
    }
    func field(object: JsonObject, name: String): String {
        match (object.get(name)) { case Some(value) => this.stringOf(value); case None => "" }
    }
}
