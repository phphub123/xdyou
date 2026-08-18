package ohos_app_cangjie_entry.model.dorm_water

public class DormWaterCaptcha {
    public let sessionId: String
    public let imageBase64: String
    public init(sessionId: String, imageBase64: String) {
        this.sessionId = sessionId
        this.imageBase64 = imageBase64
    }
}

public class DormWaterDevice {
    public let id: String
    public let name: String
    public init(id: String, name: String) {
        this.id = id
        this.name = name
    }
}
