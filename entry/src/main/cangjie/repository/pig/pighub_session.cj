package ohos_app_cangjie_entry.repository.pig

import kit.NetworkKit.*
import ohos.business_exception.*
import std.collection.*
import std.random.*
import stdx.encoding.json.*

public class PigHubImage {
    public let id: String
    public let url: String
    public let title: String

    public init(id: String, url: String, title: String) {
        this.id = id
        this.url = url
        this.title = title
    }
}

public class PigHubSession {
    private static let baseUrl: String = "https://www.pighub.top"
    private let random: Random = Random()
    private let images: ArrayList<PigHubImage> = ArrayList<PigHubImage>()
    private var lastId: String = ""

    public func getRandomPig(forceRefresh: Bool, success: (PigHubImage) -> Unit, failure: (String) -> Unit): Unit {
        if (!forceRefresh && this.images.size > 0) {
            this.choose(success, failure)
            return
        }
        let client = createHttp()
        try {
            let headers = HashMap<String, String>()
            headers["Accept"] = "application/json"
            headers["User-Agent"] = "XDYou HarmonyOS"
            let options = HttpRequestOptions(
                method: RequestMethod.Get,
                header: headers,
                expectDataType: HttpDataType.StringValue,
                usingCache: false,
                connectTimeout: 10000,
                readTimeout: 30000
            )
            client.request("${PigHubSession.baseUrl}/api/images?sort=0", options, { error, response =>
                client.destroy()
                try {
                    match (error) {
                        case Some(value) => failure("PigHub 請求失敗 ${value.code}: ${value.message}")
                        case None => match (response) {
                            case Some(value) =>
                                if (value.responseCode != 200) {
                                    failure("PigHub 返回 HTTP ${value.responseCode}")
                                } else {
                                    match (value.result) {
                                        case HttpData.StringData(body) =>
                                            this.parse(body)
                                            this.choose(success, failure)
                                        case _ => failure("PigHub 返回了非文本響應")
                                    }
                                }
                            case None => failure("PigHub 未返回響應")
                        }
                    }
                } catch (parseError: Exception) {
                    failure("PigHub 數據解析失敗：${parseError.message}")
                }
            })
        } catch (error: BusinessException) {
            client.destroy()
            failure("無法啟動 PigHub 請求：${error.code} ${error.message}")
        }
    }

    private func parse(body: String): Unit {
        let root = JsonValue.fromStr(body)
        let payload = match (root.kind()) {
            case JsObject =>
                let object = root.asObject()
                match (object.get("data")) { case Some(value) => value; case None => root }
            case _ => root
        }
        let rows = payload.asArray()
        if (rows.size() == 0) { throw Exception("PigHub 圖片列表為空") }
        this.images.clear()
        var index: Int64 = 0
        while (index < rows.size()) {
            let item = rows[index].asObject()
            let imagePath = this.field(item, "image_url")
            let title = this.field(item, "title")
            if (imagePath != "" && title != "") {
                let id = this.field(item, "id")
                let separator = if (imagePath.startsWith("/")) { "" } else { "/" }
                this.images.add(PigHubImage(id, "${PigHubSession.baseUrl}${separator}${imagePath}", title))
            }
            index += 1
        }
        if (this.images.size == 0) { throw Exception("PigHub 沒有可顯示的圖片") }
    }

    private func choose(success: (PigHubImage) -> Unit, failure: (String) -> Unit): Unit {
        if (this.images.size == 0) {
            failure("PigHub 圖片列表為空")
            return
        }
        var index = this.random.nextInt64(this.images.size)
        var attempts: Int64 = 0
        while (this.images.size > 1 && this.images[index].id == this.lastId && attempts < 8) {
            index = this.random.nextInt64(this.images.size)
            attempts += 1
        }
        let image = this.images[index]
        this.lastId = image.id
        success(image)
    }

    private func field(object: JsonObject, name: String): String {
        match (object.get(name)) {
            case Some(value) => match (value.kind()) {
                case JsString => value.asString().getValue()
                case JsInt => value.asInt().getValue().toString()
                case JsFloat => value.asFloat().getValue().toString()
                case _ => ""
            }
            case None => ""
        }
    }
}
