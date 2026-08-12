package ohos_app_cangjie_entry.model

import std.time.*
import std.collection.*

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

public class MeterReading {
    public let readTime: String
    public let readNum: String
    public let startNum: String
    public let endNum: String
    public init(readTime: String, readNum: String, startNum: String, endNum: String) {
        this.readTime = readTime; this.readNum = readNum
        this.startNum = startNum; this.endNum = endNum
    }
}

public class EnergyInfo {
    public let lastReadDate: String
    public let electricityRemain: String
    public let electricityMeterList: ArrayList<MeterReading>
    public let waterMeterList: ArrayList<MeterReading>
    public init(lastReadDate: String, electricityRemain: String,
        electricityMeterList: ArrayList<MeterReading>, waterMeterList: ArrayList<MeterReading>) {
        this.lastReadDate = lastReadDate; this.electricityRemain = electricityRemain
        this.electricityMeterList = electricityMeterList; this.waterMeterList = waterMeterList
    }
}