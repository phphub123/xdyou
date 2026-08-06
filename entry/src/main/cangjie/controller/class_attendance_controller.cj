package ohos_app_cangjie_entry.controller

import std.collection.*
import ohos_app_cangjie_entry.model.xidian_ids.*
import ohos_app_cangjie_entry.repository.xidian_ids.*

public class AttendanceGroups {
    public let ineligible = ArrayList<ClassAttendance>()
    public let warning = ArrayList<ClassAttendance>()
    public let eligible = ArrayList<ClassAttendance>()
    public let unknown = ArrayList<ClassAttendance>()
}

public class ClassAttendanceController {
    private var loading: Bool = false
    private let session = LearningSession()

    // 刷新课堂考勤数据（防止重复请求），成功后按状态分组返回
    public func reload(success: (ArrayList<ClassAttendance>, AttendanceGroups) -> Unit,
        failure: (String) -> Unit): Unit {
        if (this.loading) { return }
        this.loading = true
        this.session.loadAttendance({ courses =>
            this.loading = false
            success(courses, this.group(courses))
        }, { message => this.loading = false; failure(message) })
    }

    // 分页加载指定课程的考勤明细
    public func loadDetails(course: ClassAttendance, page: Int64, pageSize: Int64,
        success: (ArrayList<ClassAttendanceDetail>) -> Unit, failure: (String) -> Unit): Unit {
        this.session.loadAttendanceDetail(course, page, pageSize, success, failure)
    }

    // 按考勤状态（不合格/预警/合格/未知）对课程分组
    public func group(courses: ArrayList<ClassAttendance>): AttendanceGroups {
        let groups = AttendanceGroups()
        for (course in courses) {
            match (course.attendanceStatus()) {
                case AttendanceStatus.Ineligible => groups.ineligible.add(course)
                case AttendanceStatus.Warning => groups.warning.add(course)
                case AttendanceStatus.Eligible => groups.eligible.add(course)
                case AttendanceStatus.Unknown => groups.unknown.add(course)
            }
        }
        return groups
    }
}
