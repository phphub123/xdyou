package ohos_app_cangjie_entry.model

import std.time.*

public class AirconEnergyInfo {
    public let imei: String
    public let fetchTime: DateTime
    public let stateTime: DateTime
    public let electricAmount: String

    public init(imei: String, fetchTime: DateTime, stateTime: DateTime, electricAmount: String) {
        this.imei = imei
        this.fetchTime = fetchTime
        this.stateTime = stateTime
        this.electricAmount = electricAmount
    }
}
