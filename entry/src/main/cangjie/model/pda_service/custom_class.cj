package ohos_app_cangjie_entry.model.pda_service

import std.collection.*
import std.time.*

public class CustomClassTimeRange {
    public let id: String
    public let date: String
    public let startMinutes: Int64
    public let endMinutes: Int64

    public init(id: String, date: String, startMinutes: Int64, endMinutes: Int64) {
        if (id == "") { throw IllegalArgumentException("时间段标识不能为空") }
        try { DateTime.parse(date, "yyyy-MM-dd") } catch (_) { throw IllegalArgumentException("日期格式必须为 yyyy-MM-dd") }
        if (startMinutes < 510 || endMinutes > 1285) { throw IllegalArgumentException("课程时间必须在 08:30-21:25 内") }
        if (startMinutes >= endMinutes) { throw IllegalArgumentException("开始时间必须早于结束时间") }
        this.id = id; this.date = date; this.startMinutes = startMinutes; this.endMinutes = endMinutes
    }

    public func timeText(): String { return "${this.clock(this.startMinutes)}-${this.clock(this.endMinutes)}" }
    func clock(value: Int64): String {
        let hour = value / 60; let minute = value % 60
        return "${if (hour < 10) { "0" } else { "" }}${hour}:${if (minute < 10) { "0" } else { "" }}${minute}"
    }
}

public class CustomClass {
    public let id: String
    public let name: String
    public let teacher: String
    public let classroom: String
    public let timeRanges: ArrayList<CustomClassTimeRange>

    public init(id: String, name: String, teacher: String, classroom: String, timeRanges: ArrayList<CustomClassTimeRange>) {
        if (id == "") { throw IllegalArgumentException("课程标识不能为空") }
        if (name.trimAscii() == "") { throw IllegalArgumentException("课程名称不能为空") }
        if (timeRanges.size == 0) { throw IllegalArgumentException("至少添加一个上课时间") }
        this.id = id; this.name = name.trimAscii(); this.teacher = teacher.trimAscii(); this.classroom = classroom.trimAscii()
        this.timeRanges = timeRanges
    }
}

public class CustomClassOccurrence {
    public let course: CustomClass
    public let range: CustomClassTimeRange

    public init(course: CustomClass, range: CustomClassTimeRange) {
        this.course = course
        this.range = range
    }
}
