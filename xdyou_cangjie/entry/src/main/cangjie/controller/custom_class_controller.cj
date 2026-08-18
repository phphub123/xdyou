package ohos_app_cangjie_entry.controller

import std.collection.*
import std.convert.*
import std.time.*
import std.sort.*
import ohos_app_cangjie_entry.model.custom_class.*
import ohos_app_cangjie_entry.repository.custom_class.*

public class CustomClassController {
    let repository = CustomClassRepository()
    var sequence: Int64 = 0

    // 从本地仓库加载自定义课程列表
    public func load(): ArrayList<CustomClass> { return this.repository.load() }

    // 根据日期和起止时间文本创建一个自定义课程时间段
    public func createRange(date: String, startText: String, endText: String): CustomClassTimeRange {
        return CustomClassTimeRange(this.nextId("tr"), date.trimAscii(), this.parseClock(startText), this.parseClock(endText))
    }

    // 新增一个自定义课程并持久化保存
    public func add(items: ArrayList<CustomClass>, name: String, teacher: String, classroom: String, ranges: ArrayList<CustomClassTimeRange>): ArrayList<CustomClass> {
        let next = this.copyClasses(items); next.add(CustomClass(this.nextId("cc"), name, teacher, classroom, this.copyRanges(ranges))); this.repository.save(next); return next
    }

    // 更新指定索引处的自定义课程并持久化保存
    public func update(items: ArrayList<CustomClass>, index: Int64, name: String, teacher: String, classroom: String, ranges: ArrayList<CustomClassTimeRange>): ArrayList<CustomClass> {
        if (index < 0 || index >= items.size) { throw IllegalArgumentException("未找到要编辑的自定义课程") }
        let next = this.copyClasses(items); next[index] = CustomClass(items[index].id, name, teacher, classroom, this.copyRanges(ranges)); this.repository.save(next); return next
    }

    // 删除指定索引处的自定义课程并持久化保存
    public func remove(items: ArrayList<CustomClass>, index: Int64): ArrayList<CustomClass> {
        if (index < 0 || index >= items.size) { return items }
        let next = this.copyClasses(items); next.remove(at: index); this.repository.save(next); return next
    }

    // 清空所有自定义课程
    public func clear(): ArrayList<CustomClass> { this.repository.clear(); return ArrayList<CustomClass>() }

    // 获取指定日期下所有自定义课程的时间段，并按开始时间排序
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

    // 解析"HH:mm"格式的时间字符串为从零点起的分钟数
    func parseClock(value: String): Int64 {
        let parts = value.trimAscii().split(":")
        if (parts.size != 2) { throw IllegalArgumentException("时间格式必须为 HH:mm") }
        let hour = Int64.parse(parts[0]); let minute = Int64.parse(parts[1])
        if (hour < 0 || hour > 23 || minute < 0 || minute > 59) { throw IllegalArgumentException("时间格式必须为 HH:mm") }
        return hour * 60 + minute
    }

    // 基于当前时间戳和自增序号生成带前缀的唯一ID
    func nextId(prefix: String): String { this.sequence += 1; return "${prefix}-${DateTime.now().toUnixTimeStamp().toMicroseconds()}-${this.sequence}" }

    // 复制自定义课程列表
    func copyClasses(values: ArrayList<CustomClass>): ArrayList<CustomClass> { let result = ArrayList<CustomClass>(); for (value in values) { result.add(value) }; return result }

    // 复制自定义课程时间段列表
    public func copyRanges(values: ArrayList<CustomClassTimeRange>): ArrayList<CustomClassTimeRange> { let result = ArrayList<CustomClassTimeRange>(); for (value in values) { result.add(value) }; return result }
}
