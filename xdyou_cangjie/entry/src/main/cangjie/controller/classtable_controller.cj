package ohos_app_cangjie_entry.controller

import std.collection.*
import std.sort.*
import ohos_app_cangjie_entry.model.classtable.*
import ohos_app_cangjie_entry.repository.classtable.*

public class ClassTableController {
    var refreshing: Bool = false

    // 刷新指定学期的课表数据（防止重复请求）
    public func reloadClassTable(semester: String, success: (ClassTableData) -> Unit, failure: (String) -> Unit): Unit {
        if (this.refreshing) { return }
        this.refreshing = true
        ClassTableSession().load(semester, { data => this.refreshing = false; success(data) }, { message => this.refreshing = false; failure(message) })
    }

    // 筛选出指定周次、星期几处于生效状态的课程，并按开始时间排序
    public func arrangements(courses: ArrayList<CourseSlot>, day: Int64, week: Int64): ArrayList<CourseSlot> {
        let result = ArrayList<CourseSlot>()
        for (course in courses) {
            if (course.day == day && course.isActiveInWeek(week)) { result.add(course) }
        }
        sort(result, by: { left: CourseSlot, right: CourseSlot =>
            if (left.start < right.start) { Ordering.LT } else if (left.start > right.start) { Ordering.GT } else { left.name.compare(right.name) }
        }, stable: true)
        return result
    }
}
