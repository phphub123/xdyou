package ohos_app_cangjie_entry.model.energy

import std.collection.*

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
