package ohos_app_cangjie_entry.repository.library

// 图书馆仓储，复用 IDS 会话完成 SSO，并解析借阅、位置和续借状态。

import kit.NetworkKit.*
import ohos.business_exception.*
import std.collection.*
import std.convert.*
import std.regex.*
import ohos.callback_invoke.*
import stdx.encoding.json.*
import ohos_app_cangjie_entry.model.*
import ohos_app_cangjie_entry.repository.auth.*

class LibraryHeadersCb <: Callback1Argument<HashMap<String, String>> {
    let action: (HashMap<String, String>) -> Unit
    public init(action: (HashMap<String, String>) -> Unit) { this.action = action }
    public open func invoke(err: ?BusinessException, value: HashMap<String, String>): Unit { this.action(value) }
}

// 图书检索与个人借阅共享认证上下文，但返回各自独立的领域模型。
public class LibrarySession {
    static let baseUrl = "https://mfindxidian.libsp.cn"
    static let defaultGroupCode = "200755"
    private static var authToken: String = ""
    private static var authGroupCode: String = "200755"
    private static var authCookie: String = ""

    func request(url: String, body: String, success: (String) -> Unit, failure: (String) -> Unit): Unit {
        let client = createHttp()
        try {
            let headers = HashMap<String, String>()
            headers["Content-Type"] = "application/json;charset=utf-8"
            headers["Accept"] = "application/json"
            headers["Referer"] = "${LibrarySession.baseUrl}/"
            headers["Host"] = "mfindxidian.libsp.cn"
            headers["groupCode"] = if (LibrarySession.authGroupCode == "") { LibrarySession.defaultGroupCode } else { LibrarySession.authGroupCode }
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

    func sessionCookie(): String {
        let snapshot = SessionStore().restore()
        if (!snapshot.loggedIn || snapshot.cookieHeader == "") { throw Exception("图书馆借阅需要真实 IDS 会话，请重新登录。") }
        return snapshot.cookieHeader
    }
    func mergeAuthCookies(base: String, raw: String): String {
        let values = ArrayList<String>()
        for (pair in Regex(";").split(base)) { this.upsertAuthCookie(values, pair.trimAscii()) }
        for (line in Regex("[\\r\\n,]+").split(raw)) {
            let columns=Regex("\\t").split(line)
            if(columns.size>=7){this.upsertAuthCookie(values,"${columns[columns.size-2]}=${columns[columns.size-1]}");continue}
            let fields=Regex(";").split(line);var index:Int64=0
            while(index<fields.size){let pair=fields[index].trimAscii();let parts=Regex("=").split(pair);let name=if(parts.size>0){parts[0].toAsciiLower()}else{""};if(index==0||!this.isAuthCookieAttribute(name)){this.upsertAuthCookie(values,pair)};index+=1}
        }
        var result=""; for(item in values){if(result!=""){result+="; "};result+=item};return result
    }
    func isAuthCookieAttribute(name:String):Bool{return name=="path"||name=="domain"||name=="expires"||name=="max-age"||name=="samesite"||name=="secure"||name=="httponly"||name=="priority"||name=="partitioned"}
    func upsertAuthCookie(values:ArrayList<String>,pair:String):Unit{if(!pair.contains("=")){return};let fields=Regex("=").split(pair);if(fields.size==0||fields[0]==""){return};let prefix=fields[0]+"=";var i:Int64=0;while(i<values.size){if(values[i].startsWith(prefix)){values[i]=pair;return};i+=1};values.add(pair)}
    func authHeader(headers:HashMap<String,String>,name:String):String{for((key,value) in headers){if(key.toAsciiLower()==name.toAsciiLower()){return value}};return ""}
    func jwtFrom(value:String):String {
        let normalized=value.replace("%3F","?").replace("%3f","?").replace("%26","&").replace("%3D","=").replace("%3d","=")
        match(Regex(#"(?:[?&#])jwt=([A-Za-z0-9._-]+)"#,RegexFlag.IgnoreCase).find(normalized,group:true)){case Some(found)=>found.matchString(1);case None=>""}
    }
    func encode(value:String):String{let hex:Array<String>=["0","1","2","3","4","5","6","7","8","9","A","B","C","D","E","F"];var result="";for(byte in value.toArray()){let n=Int64(byte);if((n>=65&&n<=90)||(n>=97&&n<=122)||(n>=48&&n<=57)||n==45||n==46||n==95||n==126){result+=String.fromUtf8([byte])}else{result+="%${hex[n/16]}${hex[n%16]}"}};return result}

    func ensureBorrowLogin(success:() -> Unit,failure:(String) -> Unit):Unit {
        if(LibrarySession.authToken!=""){success();return}
        let target="https://tyrzfw.chaoxing.com/auth/xidian/cas/init?isLogout=0&refer=https%3A%2F%2Fmfindxidian.libsp.cn%2Ffind%2Fsso%2Flogin%2Fxidian%2F1"
        try { let cookie=this.mergeAuthCookies(this.sessionCookie(),LibrarySession.authCookie); LibrarySession.authCookie=cookie
            this.authGet(IDSSession.loginUrl+"?service="+this.encode(target),cookie,{body=>
                if(LibrarySession.authToken!=""){success()}else{this.chaoxingLogin(body,success,failure)}
            },failure)
        } catch(error:Exception){failure(error.message)}
    }
    func authGet(url:String,cookie:String,success:(String) -> Unit,failure:(String) -> Unit):Unit {
        let client=createHttp();let headers=HashMap<String,String>();headers["Cookie"]=cookie;headers["User-Agent"]=IDSSession.browserUserAgent
        let captured=ArrayList<String>();let callback=LibraryHeadersCb({responseHeaders=>
            let location=this.authHeader(responseHeaders,"location");let jwt=this.jwtFrom(location);if(jwt!=""){LibrarySession.authToken=jwt}
            let raw=this.authHeader(responseHeaders,"set-cookie");if(raw!=""){captured.add(raw)}
        });client.on(HttpRequestEvent.HeadersReceive,callback)
        let options=HttpRequestOptions(method:RequestMethod.Get,header:headers,usingProtocol:HttpProtocol.Http1_1,expectDataType:HttpDataType.StringValue,usingCache:false,connectTimeout:10000,readTimeout:30000)
        try{client.request(url,options,{error,response=>client.destroy();match(error){case Some(value)=>failure("图书馆认证网络错误 ${value.code}: ${value.message}");case None=>match(response){case Some(value)=>match(value.result){case HttpData.StringData(body)=>var raw=value.cookies;for(item in captured){raw+="\n"+item};LibrarySession.authCookie=this.mergeAuthCookies(cookie,raw);if(LibrarySession.authToken!=""||(value.responseCode>=200&&value.responseCode<400)){success(body)}else{failure("图书馆认证返回 HTTP ${value.responseCode}。")}case _=>failure("图书馆认证返回了非文本响应。")}case None=>failure("图书馆认证未返回响应。")}}})}catch(error:BusinessException){client.destroy();failure("无法启动图书馆认证：${error.code} ${error.message}")}
    }
    func htmlField(html:String,pattern:String):String{match(Regex(pattern,RegexFlag.IgnoreCase).find(html,group:true)){case Some(found)=>found.matchString(1);case None=>""}}
    func chaoxingLogin(html:String,success:() -> Unit,failure:(String) -> Unit):Unit {
        let data=this.htmlField(html,#"data:\s*[\"'](.*?)[\"']\s*,"#);let time=this.htmlField(html,#"time:\s*([0-9]+)\s*,"#)
        let enc=this.htmlField(html,#"enc:\s*[\"'](.*?)[\"']\s*,"#);let name=this.htmlField(html,#"displayName:\s*[\"'](.*?)[\"']\s*,"#);let role=this.htmlField(html,#"userRole:\s*([0-9]+)\s*,"#)
        if(data==""||time==""||enc==""||name==""||role==""){failure("图书馆认证未返回 OPAC JWT，请重新登录后重试。");return}
        let url="https://tyrzfw.chaoxing.com/auth/xidian/cas/login?data=${this.encode(data)}&time=${this.encode(time)}&enc=${this.encode(enc)}&displayName=${this.encode(name)}&userRole=${role}"
        this.authGet(url,LibrarySession.authCookie,{body=>if(!body.contains("true")){failure("超星图书馆认证失败。");return};let sso=LibrarySession.baseUrl+"/find/sso/login/xidian/1?data=${this.encode(data)}&time=${this.encode(time)}&enc=${this.encode(enc)}";this.authGet(sso,LibrarySession.authCookie,{_=>if(LibrarySession.authToken==""){failure("图书馆认证未生成 OPAC JWT。")}else{success()}},failure)},failure)
    }
    public func loadBorrowList(success:(ArrayList<BorrowData>) -> Unit,failure:(String) -> Unit):Unit {
        this.ensureBorrowLogin({=>
            let client=createHttp();let headers=HashMap<String,String>();headers["Content-Type"]="application/json;charset=utf-8";headers["Cookie"]="jwt=${LibrarySession.authToken}; jwtHeader=jwtOpacAuth; ${LibrarySession.authCookie}";headers["jwtOpacAuth"]=LibrarySession.authToken;headers["groupCode"]=LibrarySession.authGroupCode;headers["Referer"]=LibrarySession.baseUrl+"/"
            let body="{\"page\":1,\"rows\":999,\"searchType\":1,\"searchContent\":\"\",\"sortType\":0,\"startDate\":null,\"endDate\":null}"
            let options=HttpRequestOptions(method:RequestMethod.Post,header:headers,extraData:HttpData.StringData(body),expectDataType:HttpDataType.StringValue,usingCache:false,connectTimeout:10000,readTimeout:30000)
            try{client.request(LibrarySession.baseUrl+"/find/loanInfo/loanList",options,{error,response=>client.destroy();match(error){case Some(value)=>failure("借阅查询网络错误 ${value.code}: ${value.message}");case None=>match(response){case Some(value)=>match(value.result){case HttpData.StringData(text)=>if(value.responseCode!=200){failure("借阅查询返回 HTTP ${value.responseCode}。")}else{try{let root=JsonValue.fromStr(text).asObject();let data=root.get("data").getOrThrow().asObject();let rows=data.get("searchResult").getOrThrow().asArray();let result=ArrayList<BorrowData>();var i:Int64=0;while(i<rows.size()){let row=rows[i].asObject();result.add(BorrowData(this.intField(row,"loanId"),this.intField(row,"renewTimes"),this.field(row,"loanDate"),this.field(row,"normReturnDate"),this.field(row,"title"),this.field(row,"author"),this.field(row,"publisher"),this.field(row,"isbn"),this.field(row,"locationName"),this.intField(row,"recordId")));i+=1};success(result)}catch(error:Exception){failure("借阅响应解析失败：${error.message}")}}case _=>failure("借阅查询返回了非文本响应。")}case None=>failure("借阅查询未返回响应。")}}})}catch(error:BusinessException){client.destroy();failure("无法启动借阅查询：${error.code} ${error.message}")}
        },failure)
    }
    func jsonQuote(value: String): String { return "\"" + value.replace("\\", "\\\\").replace("\"", "\\\"").replace("\n", "\\n") + "\"" }
    public func loadBorrowListAuthorized(raw:String,cookie:String,success:(ArrayList<BorrowData>) -> Unit,failure:(String) -> Unit):Unit {
        let jwt=match(Regex(#"(?:[?&#|])jwt=([A-Za-z0-9._-]+)"#,RegexFlag.IgnoreCase).find(raw,group:true)){case Some(found)=>found.matchString(1);case None=>this.jwtFrom(raw)}
        LibrarySession.authCookie=this.mergeAuthCookies(SessionStore().restore().cookieHeader,cookie)
        if(jwt==""){this.loadBorrowList(success,failure);return}
        LibrarySession.authToken=jwt
        match(Regex(#"(?:[?&#|])groupCode=([A-Za-z0-9_-]+)"#,RegexFlag.IgnoreCase).find(raw,group:true)){
            case Some(found)=>LibrarySession.authGroupCode=found.matchString(1)
            case None=>()
        }
        this.loadBorrowList(success,failure)
    }
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
