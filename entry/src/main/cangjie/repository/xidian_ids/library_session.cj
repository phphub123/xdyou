package ohos_app_cangjie_entry.repository.xidian_ids

import kit.NetworkKit.*
import ohos.business_exception.*
import std.collection.*
import std.convert.*
import stdx.encoding.json.*
import ohos_app_cangjie_entry.model.xidian_ids.*

public class LibrarySession {
    static let baseUrl = "https://mfindxidian.libsp.cn"
    static let groupCode = "200755"

    func request(url: String, body: String, success: (String) -> Unit, failure: (String) -> Unit): Unit {
        let client = createHttp()
        try {
            let headers = HashMap<String, String>()
            headers["Content-Type"] = "application/json;charset=utf-8"
            headers["Accept"] = "application/json"
            headers["Referer"] = "${LibrarySession.baseUrl}/"
            headers["Host"] = "mfindxidian.libsp.cn"
            headers["groupCode"] = LibrarySession.groupCode
            headers["mappingPath"] = ""
            let options = HttpRequestOptions(method: RequestMethod.Post, header: headers,
                extraData: HttpData.StringData(body), expectDataType: HttpDataType.StringValue,
                usingCache: false, connectTimeout: 10000, readTimeout: 30000)
            client.request(url, options, { error, response =>
                client.destroy()
                match (error) { case Some(value) => failure("图书馆网络错误 ${value.code}: ${value.message}"); case None => match (response) {
                    case Some(value) => if (value.responseCode != 200) { failure("图书馆返回 HTTP ${value.responseCode}") } else { match (value.result) { case HttpData.StringData(text) => success(text); case _ => failure("图书馆返回非文本响应") } }
                    case None => failure("图书馆未返回响应")
                } }
            })
        } catch (error: BusinessException) { client.destroy(); failure("无法启动图书馆请求：${error.code} ${error.message}") }
    }

    public func searchBooks(keyword: String, field: String, page: Int64,
        success: (ArrayList<BookInfo>) -> Unit, failure: (String) -> Unit): Unit {
        if (keyword.trimAscii() == "") { success(ArrayList<BookInfo>()); return }
        let body = "{\"docCode\":[null],\"litCode\":[],\"searchFieldContent\":${this.jsonQuote(keyword)}," +
            "\"searchField\":${this.jsonQuote(field)},\"matchMode\":\"2\",\"resourceType\":[],\"subject\":[]," +
            "\"publisher\":[],\"locationId\":[],\"author\":[],\"langCode\":[],\"countryCode\":[]," +
            "\"sortField\":\"relevance\",\"sortClause\":\"desc\",\"page\":${page},\"rows\":10," +
            "\"onlyOnShelf\":null,\"campusId\":[],\"searchItems\":null,\"indexSearch\":1}"
        this.request("${LibrarySession.baseUrl}/find/unify/search", body, { text =>
            try {
                let result = ArrayList<BookInfo>()
                let root = JsonValue.fromStr(text).asObject()
                match (root.get("data")) { case Some(data) => match (data.asObject().get("searchResult")) {
                    case Some(rowsValue) =>
                        let rows = rowsValue.asArray(); var index: Int64 = 0
                        while (index < rows.size()) {
                            let row = rows[index].asObject()
                            result.add(BookInfo(this.field(row,"author"), this.field(row,"isbn"), this.firstNonEmpty(row,"adstract","ddAbstract"),
                                this.field(row,"title"), this.intField(row,"recordId"), this.firstNonEmpty(row,"publishYear","year"),
                                this.field(row,"publisher"), this.firstArrayOrField(row,"callNo"),
                                this.firstInt(row,"onShelfCountI","canBrrowCountI","onShelfNum"),
                                this.firstInt(row,"groupPhysicalCount","physicalCount","storageCount")))
                            index += 1
                        }
                    case None => ()
                }; case None => () }
                success(result)
            } catch (error: Exception) { failure("图书检索响应解析失败：${error.message}") }
        }, failure)
    }

    public func loadLocations(recordId: Int64, success: (ArrayList<BookLocation>) -> Unit, failure: (String) -> Unit): Unit {
        if (recordId <= 0) { success(ArrayList<BookLocation>()); return }
        let body = "{\"page\":1,\"rows\":200,\"entrance\":null,\"recordId\":\"${recordId}\",\"isUnify\":true}"
        this.request("${LibrarySession.baseUrl}/find/physical/groupitems", body, { text =>
            try {
                let result = ArrayList<BookLocation>(); let root = JsonValue.fromStr(text).asObject()
                match (root.get("data")) { case Some(data) => match (data.asObject().get("list")) { case Some(value) =>
                    let rows = value.asArray(); var index: Int64 = 0
                    while (index < rows.size()) { let row = rows[index].asObject(); let base = this.firstNonEmpty(row,"realLocationName","locationName"); let shelf = this.field(row,"urlName")
                        result.add(BookLocation(if (shelf == "") { base } else { "${base} ${shelf}" }, this.field(row,"callNo"), this.field(row,"campus"), this.firstNonEmpty(row,"barcode","propNo"), this.field(row,"processType"), this.field(row,"borrowStatus"))); index += 1 }
                case None => () }; case None => () }
                success(result)
            } catch (error: Exception) { failure("馆藏位置解析失败：${error.message}") }
        }, failure)
    }

    func jsonQuote(value: String): String { return "\"" + value.replace("\\", "\\\\").replace("\"", "\\\"").replace("\n", "\\n") + "\"" }
    func stringOf(value: JsonValue): String { match (value.kind()) { case JsString => value.asString().getValue(); case JsInt => value.asInt().getValue().toString(); case JsFloat => value.asFloat().getValue().toString(); case JsBool => value.asBool().getValue().toString(); case _ => "" } }
    func field(object: JsonObject, name: String): String { match (object.get(name)) { case Some(value) => this.stringOf(value); case None => "" } }
    func intField(object: JsonObject, name: String): Int64 { try { return Int64.parse(this.field(object,name)) } catch (_) { return 0 } }
    func firstNonEmpty(object: JsonObject, first: String, second: String): String { let value = this.field(object,first); return if (value == "") { this.field(object,second) } else { value } }
    func firstInt(object: JsonObject, first: String, second: String, third: String): Int64 { var value = this.intField(object,first); if (value == 0) { value = this.intField(object,second) }; if (value == 0) { value = this.intField(object,third) }; return value }
    func firstArrayOrField(object: JsonObject, name: String): String {
        match (object.get(name)) {
            case Some(value) => match (value.kind()) {
                case JsArray => let array = value.asArray(); if (array.size() > 0) { this.stringOf(array[0]) } else { "" }
                case _ => this.stringOf(value)
            }
            case None => ""
        }
    }
}
