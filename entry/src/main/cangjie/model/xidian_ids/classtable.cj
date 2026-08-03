package ohos_app_cangjie_entry.model.xidian_ids

import std.collection.*

public class CourseDetail {
    public let name: String
    public let code: String
    public let number: String
    public init(name: String, code: String, number: String) {
        this.name = name; this.code = code; this.number = number
    }
}

public class NotArrangedCourse {
    public let name: String
    public let code: String
    public let number: String
    public let teacher: String
    public init(name: String, code: String, number: String, teacher: String) {
        this.name = name; this.code = code; this.number = number; this.teacher = teacher
    }
}

public class CourseSlot {
    public let name: String
    public let code: String
    public let number: String
    public let teacher: String
    public let room: String
    public let day: Int64
    public let start: Int64
    public let stop: Int64
    public let weekFlags: String
    public init(name: String, code: String, number: String, teacher: String, room: String, day: Int64, start: Int64, stop: Int64, weekFlags: String) {
        this.name = name; this.code = code; this.number = number; this.teacher = teacher; this.room = room
        this.day = day; this.start = start; this.stop = stop; this.weekFlags = weekFlags
    }
    public func isActiveInWeek(week: Int64): Bool {
        if (week < 1) { return true }
        let bytes = this.weekFlags.toArray()
        let index = week - 1
        return index < bytes.size && bytes[index] == 49
    }
    public func weekSummary(): String {
        let bytes = this.weekFlags.toArray()
        var first: Int64 = -1
        var last: Int64 = -1
        var count: Int64 = 0
        var index: Int64 = 0
        while (index < bytes.size) {
            if (bytes[index] == 49) {
                if (first < 0) { first = index + 1 }
                last = index + 1; count += 1
            }
            index += 1
        }
        if (count == 0) { return "No active weeks" }
        if (count == 1) { return "Week ${first}" }
        return "Weeks ${first}-${last} (${count} active)"
    }
}

public class ClassTableData {
    public let semesterCode: String
    public let termStartDay: String
    public let semesterLength: Int64
    public let courses: ArrayList<CourseSlot>
    public let notArranged: ArrayList<NotArrangedCourse>
    public init(semesterCode: String, termStartDay: String, semesterLength: Int64, courses: ArrayList<CourseSlot>, notArranged: ArrayList<NotArrangedCourse>) {
        this.semesterCode = semesterCode; this.termStartDay = termStartDay; this.semesterLength = semesterLength
        this.courses = courses; this.notArranged = notArranged
    }
}
