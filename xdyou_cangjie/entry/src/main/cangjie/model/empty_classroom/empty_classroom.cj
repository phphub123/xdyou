package ohos_app_cangjie_entry.model.empty_classroom

import std.collection.*

public class EmptyClassroomPlace {
    public let name: String
    public let code: String
    public init(name: String, code: String) { this.name = name; this.code = code }
}

public class EmptyClassroomData {
    public let name: String
    public let isUsed: ArrayList<Bool>
    public init(name: String, isUsed: ArrayList<Bool>) {
        if (isUsed.size != 11) { throw IllegalArgumentException("Empty classroom matrix requires 11 periods") }
        this.name = name; this.isUsed = isUsed
    }
}
