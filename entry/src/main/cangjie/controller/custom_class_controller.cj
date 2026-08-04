package ohos_app_cangjie_entry.controller

import std.collection.*
import std.convert.*
import std.time.*
import std.sort.*
import ohos_app_cangjie_entry.model.pda_service.*
import ohos_app_cangjie_entry.repository.*

public class CustomClassController {
    let repository = CustomClassRepository()
    var sequence: Int64 = 0

    public func load(): ArrayList<CustomClass> { return this.repository.load() }
    public func createRange(date: String, startText: String, endText: String): CustomClassTimeRange {
        return CustomClassTimeRange(this.nextId("tr"), date.trimAscii(), this.parseClock(startText), this.parseClock(endText))
    }
    public func add(items: ArrayList<CustomClass>, name: String, teacher: String, classroom: String, ranges: ArrayList<CustomClassTimeRange>): ArrayList<CustomClass> {
        let next = this.copyClasses(items); next.add(CustomClass(this.nextId("cc"), name, teacher, classroom, this.copyRanges(ranges))); this.repository.save(next); return next
    }
    public func update(items: ArrayList<CustomClass>, index: Int64, name: String, teacher: String, classroom: String, ranges: ArrayList<CustomClassTimeRange>): ArrayList<CustomClass> {
        if (index < 0 || index >= items.size) { throw IllegalArgumentException("未找到要编辑的自定义课程") }
        let next = this.copyClasses(items); next[index] = CustomClass(items[index].id, name, teacher, classroom, this.copyRanges(ranges)); this.repository.save(next); return next
    }
    public func remove(items: ArrayList<CustomClass>, index: Int64): ArrayList<CustomClass> {
        if (index < 0 || index >= items.size) { return items }
        let next = this.copyClasses(items); next.remove(at: index); this.repository.save(next); return next
    }
    public func clear(): ArrayList<CustomClass> { this.repository.clear(); return ArrayList<CustomClass>() }

    public func rangesOnDate(items: ArrayList<CustomClass>, date: String): ArrayList<CustomClassOccurrence> {
        let result = ArrayList<CustomClassOccurrence>()
        for (course in items) {
            for (range in course.timeRanges) {
                if (range.date == date) { result.add(CustomClassOccurrence(course, range)) }
            }
        }
        sort(result, by: { left: CustomClassOccurrence, right: CustomClassOccurrence =>
            if (left.range.startMinutes == right.range.startMinutes) { return left.course.name.compare(right.course.name) }
            if (left.range.startMinutes < right.range.startMinutes) { Ordering.LT } else { Ordering.GT }
        }, stable: true)
        return result
    }

    func parseClock(value: String): Int64 {
        let parts = value.trimAscii().split(":")
        if (parts.size != 2) { throw IllegalArgumentException("时间格式必须为 HH:mm") }
        let hour = Int64.parse(parts[0]); let minute = Int64.parse(parts[1])
        if (hour < 0 || hour > 23 || minute < 0 || minute > 59) { throw IllegalArgumentException("时间格式必须为 HH:mm") }
        return hour * 60 + minute
    }
    func nextId(prefix: String): String { this.sequence += 1; return "${prefix}-${DateTime.now().toUnixTimeStamp().toMicroseconds()}-${this.sequence}" }
    func copyClasses(values: ArrayList<CustomClass>): ArrayList<CustomClass> { let result = ArrayList<CustomClass>(); for (value in values) { result.add(value) }; return result }
    public func copyRanges(values: ArrayList<CustomClassTimeRange>): ArrayList<CustomClassTimeRange> { let result = ArrayList<CustomClassTimeRange>(); for (value in values) { result.add(value) }; return result }
}
