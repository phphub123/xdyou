package ohos_app_cangjie_entry

import kit.ArkUI.*
import ohos.arkui.state_macro_manage.*
import std.collection.*
import ohos_app_cangjie_entry.controller.*
import ohos_app_cangjie_entry.model.xidian_ids.*

@Component
public class ClassAttendancePage {
    let onBack: () -> Unit
    @State var loading: Bool = false
    @State var status: String = ""
    @State var courses: ArrayList<ClassAttendance> = ArrayList<ClassAttendance>()
    @State var ineligible: ArrayList<ClassAttendance> = ArrayList<ClassAttendance>()
    @State var warning: ArrayList<ClassAttendance> = ArrayList<ClassAttendance>()
    @State var eligible: ArrayList<ClassAttendance> = ArrayList<ClassAttendance>()
    @State var unknown: ArrayList<ClassAttendance> = ArrayList<ClassAttendance>()
    @State var selectedIndex: Int64 = -1
    @State var details: ArrayList<ClassAttendanceDetail> = ArrayList<ClassAttendanceDetail>()
    @State var detailPage: Int64 = 1
    @State var detailEnd: Bool = false
    let controller = ClassAttendanceController()

    protected override func aboutToAppear(): Unit { this.reload() }

    func reload(): Unit {
        this.loading = true; this.status = "正在连接学习通并读取考勤，首次加载可能较慢…"
        this.controller.reload({ items, groups => launch {
            this.courses = items; this.ineligible = groups.ineligible; this.warning = groups.warning
            this.eligible = groups.eligible; this.unknown = groups.unknown; this.loading = false
            this.status = if (items.size == 0) { "当前学期没有考勤记录。" } else { "共 ${items.size} 门课程。" }
        } }, { message => launch { this.loading = false; this.status = message } })
    }

    func openDetail(index: Int64): Unit {
        this.selectedIndex = index; this.details = ArrayList<ClassAttendanceDetail>()
        this.detailPage = 1; this.detailEnd = false; this.loadDetailPage()
    }

    func selectedCourse(): ClassAttendance {
        if (this.selectedIndex < 0 || this.selectedIndex >= this.courses.size) { throw Exception("未选择课程") }
        return this.courses[this.selectedIndex]
    }

    func loadDetailPage(): Unit {
        if (this.loading || this.detailEnd || this.selectedIndex < 0) { return }
        this.loading = true; this.status = "正在读取第 ${this.detailPage} 页签到记录…"
        this.controller.loadDetails(this.selectedCourse(), this.detailPage, 10, { items => launch {
            for (item in items) { this.details.add(item) }
            this.detailEnd = items.size < 10; this.detailPage += 1; this.loading = false
            this.status = if (this.details.size == 0) { "没有签到明细。" } else if (this.detailEnd) { "已加载全部 ${this.details.size} 条记录。" } else { "已加载 ${this.details.size} 条记录。" }
        } }, { message => launch { this.loading = false; this.status = message } })
    }

    func indexOf(course: ClassAttendance): Int64 {
        var index: Int64 = 0
        while (index < this.courses.size) {
            if (this.courses[index].courseName == course.courseName && this.courses[index].className == course.className) { return index }
            index += 1
        }
        return -1
    }

    func statusColor(course: ClassAttendance): UInt32 {
        match (course.attendanceStatus()) {
            case AttendanceStatus.Ineligible => 0xFFC33C54
            case AttendanceStatus.Warning => 0xFFE58B2B
            case AttendanceStatus.Eligible => 0xFF2D8B66
            case AttendanceStatus.Unknown => 0xFF75829A
        }
    }

    func build() {
        Column {
            Row {
                Button("‹").width(44.vp).height(40.vp).onClick({ _ => if (this.selectedIndex >= 0) { this.selectedIndex = -1; this.details.clear(); this.status = "共 ${this.courses.size} 门课程。" } else { this.onBack() } }).id("attendanceBack")
                Text(if (this.selectedIndex >= 0) { "${this.selectedCourse().courseName} · 签到明细" } else { "课堂考勤" }).fontSize(24.vp).fontWeight(FontWeight.Bold).layoutWeight(1).margin(left: 8.vp)
                if (this.selectedIndex < 0) { Button("刷新").height(40.vp).onClick({ _ => this.reload() }).id("attendanceRefresh") }
            }.width(100.percent)
            Text(this.status).fontSize(12.vp).fontColor(0xFF65738A).margin(top: 8.vp).id("attendanceStatus")
            if (this.selectedIndex >= 0) {
                Scroll { Column {
                    ForEach(this.details, itemGenerator: { item: ClassAttendanceDetail, index: Int64 => Column {
                        Row { Text(item.signNameText()).fontSize(16.vp).fontWeight(FontWeight.Bold).layoutWeight(1); Text(item.signStatusText()).fontSize(13.vp).fontColor(0xFF46699D) }.width(100.percent)
                        Text("发起人：${item.creatorName}").fontSize(13.vp).margin(top: 7.vp)
                        Text("开始：${item.startTime}").fontSize(13.vp).margin(top: 4.vp)
                        if (item.submitTime != "") { Text("提交：${item.submitTime}").fontSize(13.vp).margin(top: 4.vp) }
                    }.width(100.percent).padding(14.vp).margin(top: 10.vp).backgroundColor(0xFFFFFFFF).borderRadius(12.vp).id("attendanceDetail_${index}") })
                    if (!this.detailEnd) { Button(if (this.loading) { "加载中…" } else { "加载更多" }).width(100.percent).margin(top: 12.vp).onClick({ _ => this.loadDetailPage() }).id("attendanceLoadMore") }
                }.width(100.percent) }.width(100.percent).layoutWeight(1).scrollBar(BarState.Auto)
            } else {
                Scroll { Column {
                    if (this.ineligible.size > 0) { Text("不合格").fontSize(18.vp).fontWeight(FontWeight.Bold).margin(top: 14.vp).id("attendanceGroupIneligible") }
                    ForEach(this.ineligible, itemGenerator: { course: ClassAttendance, _: Int64 => AttendanceCourseCard(course: course, color: this.statusColor(course), onOpen: { => this.openDetail(this.indexOf(course)) }) })
                    if (this.warning.size > 0) { Text("预警").fontSize(18.vp).fontWeight(FontWeight.Bold).margin(top: 14.vp).id("attendanceGroupWarning") }
                    ForEach(this.warning, itemGenerator: { course: ClassAttendance, _: Int64 => AttendanceCourseCard(course: course, color: this.statusColor(course), onOpen: { => this.openDetail(this.indexOf(course)) }) })
                    if (this.eligible.size > 0) { Text("正常").fontSize(18.vp).fontWeight(FontWeight.Bold).margin(top: 14.vp).id("attendanceGroupEligible") }
                    ForEach(this.eligible, itemGenerator: { course: ClassAttendance, _: Int64 => AttendanceCourseCard(course: course, color: this.statusColor(course), onOpen: { => this.openDetail(this.indexOf(course)) }) })
                    if (this.unknown.size > 0) { Text("未知").fontSize(18.vp).fontWeight(FontWeight.Bold).margin(top: 14.vp).id("attendanceGroupUnknown") }
                    ForEach(this.unknown, itemGenerator: { course: ClassAttendance, _: Int64 => AttendanceCourseCard(course: course, color: this.statusColor(course), onOpen: { => this.openDetail(this.indexOf(course)) }) })
                }.width(100.percent) }.width(100.percent).layoutWeight(1).scrollBar(BarState.Auto)
            }
        }.width(100.percent).height(100.percent).padding(18.vp).backgroundColor(0xFFF7F9FC).alignItems(HorizontalAlign.Start)
    }
}

@Component
class AttendanceCourseCard {
    let course: ClassAttendance
    let color: UInt32
    let onOpen: () -> Unit
    func build() {
        Column {
            Row { Text(this.course.courseName).fontSize(17.vp).fontWeight(FontWeight.Bold).layoutWeight(1); Text(this.course.statusText()).fontSize(13.vp).fontColor(this.color) }.width(100.percent)
            Text(this.course.className).fontSize(12.vp).fontColor(0xFF75829A).margin(top: 4.vp)
            Row { Text("到课率 ${this.course.attendanceRate}").fontSize(13.vp).layoutWeight(1); Text("签到 ${this.course.checkInCount}/${this.course.requiredCheckIn}").fontSize(13.vp).layoutWeight(1); Text("旷课 ${this.course.absenceCount}").fontSize(13.vp).layoutWeight(1) }.width(100.percent).margin(top: 10.vp)
            Text("请假：事假 ${this.course.personalLeave} · 病假 ${this.course.sickLeave} · 公假 ${this.course.officialLeave}").fontSize(12.vp).fontColor(0xFF65738A).margin(top: 7.vp)
            Text("任务点 ${this.course.taskProgress} · 作业 ${this.course.homeworkProgress} · 考试 ${this.course.examProgress}").fontSize(12.vp).fontColor(0xFF65738A).margin(top: 4.vp)
        }.width(100.percent).padding(14.vp).margin(top: 9.vp).backgroundColor(0xFFFFFFFF).border(width: 2.vp, color: this.color).borderRadius(12.vp).onClick({ _ => this.onOpen() }).id("attendanceCourseCard")
    }
}
