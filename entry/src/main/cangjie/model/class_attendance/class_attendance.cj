package ohos_app_cangjie_entry.model.class_attendance

import std.regex.*
import std.convert.*

public enum AttendanceStatus {
    | Unknown
    | Eligible
    | Warning
    | Ineligible
}

public class ClassAttendance {
    public let isWarning: Bool
    public let courseName: String
    public let className: String
    public let checkInCount: String
    public let personalLeave: String
    public let sickLeave: String
    public let officialLeave: String
    public let absenceCount: String
    public let requiredCheckIn: String
    public let attendanceRate: String
    public let readCount: String
    public let unreadCount: String
    public let accessCount: String
    public let taskProgress: String
    public let homeworkProgress: String
    public let examProgress: String
    public let discussionCount: String
    public let materialCount: String
    public let courseId: String
    public let clazzId: String
    public let cpi: String

    public init(courseName: String, className: String, checkInCount: String,
        personalLeave: String, sickLeave: String, officialLeave: String,
        absenceCount: String, requiredCheckIn: String, attendanceRate: String,
        readCount: String, unreadCount: String, accessCount: String,
        taskProgress: String, homeworkProgress: String, examProgress: String,
        discussionCount: String, materialCount: String, courseId!: String = "",
        clazzId!: String = "", cpi!: String = "", isWarning!: Bool = false) {
        this.courseName = courseName
        this.className = className
        this.checkInCount = checkInCount
        this.personalLeave = personalLeave
        this.sickLeave = sickLeave
        this.officialLeave = officialLeave
        this.absenceCount = absenceCount
        this.requiredCheckIn = requiredCheckIn
        this.attendanceRate = attendanceRate
        this.readCount = readCount
        this.unreadCount = unreadCount
        this.accessCount = accessCount
        this.taskProgress = taskProgress
        this.homeworkProgress = homeworkProgress
        this.examProgress = examProgress
        this.discussionCount = discussionCount
        this.materialCount = materialCount
        this.courseId = courseId
        this.clazzId = clazzId
        this.cpi = cpi
        this.isWarning = isWarning
    }

    public func attendanceStatus(): AttendanceStatus {
        if (this.isWarning) { return AttendanceStatus.Ineligible }
        let normalized = Regex("[%％\\s]").replaceAll(this.attendanceRate, "")
        try {
            let ratio = Float64.parse(normalized)
            return if (ratio < 80.0) { AttendanceStatus.Warning } else { AttendanceStatus.Eligible }
        } catch (_) { return AttendanceStatus.Unknown }
    }

    public func statusText(): String {
        match (this.attendanceStatus()) {
            case AttendanceStatus.Ineligible => "不合格"
            case AttendanceStatus.Warning => "预警"
            case AttendanceStatus.Eligible => "正常"
            case AttendanceStatus.Unknown => "未知"
        }
    }
}

public class ClassAttendanceDetail {
    public let submitTime: String
    public let createXxuid: String
    public let userStatus: Int64
    public let creatorName: String
    public let activeId: Int64
    public let startTime: String
    public let attendId: Int64
    public let activeType: Int64
    public let name: String
    public let otherId: Int64
    public let updateTime: Int64
    public let createUid: String
    public let status: Int64

    public init(submitTime: String, createXxuid: String, userStatus: Int64,
        creatorName: String, activeId: Int64, startTime: String, attendId: Int64,
        activeType: Int64, name: String, otherId: Int64, updateTime: Int64,
        createUid: String, status: Int64) {
        this.submitTime = submitTime; this.createXxuid = createXxuid
        this.userStatus = userStatus; this.creatorName = creatorName
        this.activeId = activeId; this.startTime = startTime; this.attendId = attendId
        this.activeType = activeType; this.name = name; this.otherId = otherId
        this.updateTime = updateTime; this.createUid = createUid; this.status = status
    }

    public func signStatusText(): String {
        match (this.userStatus) {
            case 1 => "已签到"
            case 2 => "老师代签"
            case 4 => "请假"
            case 5 => "缺勤"
            case 7 => "病假"
            case 8 => "事假"
            case 9 => "迟到"
            case 10 => "早退"
            case 11 => "签到过期"
            case 12 => "公假"
            case _ => "未参与"
        }
    }

    public func signNameText(): String {
        if (this.name != "") { return this.name }
        match (this.otherId) { case 2 => "二维码签到"; case 3 => "手势签到"; case 4 => "位置签到"; case _ => "普通签到" }
    }
}
