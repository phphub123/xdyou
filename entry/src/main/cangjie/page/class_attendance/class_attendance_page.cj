package ohos_app_cangjie_entry.page.class_attendance

import kit.ArkUI.*
import ohos.arkui.state_macro_manage.*
import std.collection.*
import ohos_app_cangjie_entry.controller.*
import ohos_app_cangjie_entry.model.xidian_ids.*
import ohos_app_cangjie_entry.components.*

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

    protected override func aboutToAppear(): Unit {
        this.reload()
    }

    func reload(): Unit {
        this.loading = true
        this.status = "正在连接学习通并读取考勤，首次加载可能较慢…"
        this.controller.reload(
            { items, groups => launch {
                this.courses = items
                this.ineligible = groups.ineligible
                this.warning = groups.warning
                this.eligible = groups.eligible
                this.unknown = groups.unknown
                this.loading = false
                this.status = if (items.size == 0) {
                    "当前学期没有考勤记录。"
                } else {
                    "共 ${items.size} 门课程。"
                }
            } },
            { message => launch {
                this.loading = false
                this.status = message
            } }
        )
    }

    func openDetail(index: Int64): Unit {
        this.selectedIndex = index
        this.details = ArrayList<ClassAttendanceDetail>()
        this.detailPage = 1
        this.detailEnd = false
        this.loadDetailPage()
    }

    func selectedCourse(): ClassAttendance {
        if (this.selectedIndex < 0 || this.selectedIndex >= this.courses.size) {
            throw Exception("未选择课程")
        }
        return this.courses[this.selectedIndex]
    }

    func loadDetailPage(): Unit {
        if (this.loading || this.detailEnd || this.selectedIndex < 0) {
            return
        }

        this.loading = true
        this.status = "正在读取第 ${this.detailPage} 页签到记录…"
        this.controller.loadDetails(
            this.selectedCourse(),
            this.detailPage,
            10,
            { items => launch {
                for (item in items) {
                    this.details.add(item)
                }
                this.detailEnd = items.size < 10
                this.detailPage += 1
                this.loading = false
                this.status = if (this.details.size == 0) {
                    "没有签到明细。"
                } else if (this.detailEnd) {
                    "已加载全部 ${this.details.size} 条记录。"
                } else {
                    "已加载 ${this.details.size} 条记录。"
                }
            } },
            { message => launch {
                this.loading = false
                this.status = message
            } }
        )
    }

    func indexOf(course: ClassAttendance): Int64 {
        var index: Int64 = 0
        while (index < this.courses.size) {
            let current = this.courses[index]
            if (current.courseName == course.courseName &&
                current.className == course.className) {
                return index
            }
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

    func headerBack(): Unit {
        if (this.selectedIndex >= 0) {
            this.selectedIndex = -1
            this.details.clear()
            this.status = "共 ${this.courses.size} 门课程。"
        } else {
            this.onBack()
        }
    }

    func headerTitle(): String {
        return if (this.selectedIndex >= 0) {
            "${this.selectedCourse().courseName} · 签到明细"
        } else {
            "考勤查询"
        }
    }

    @Builder
    func headerTrailing() {
        if (this.selectedIndex < 0) {
            HeaderRefreshAction(onRefresh: this.reload, actionId: "attendanceRefresh")
        }
    }

    func build() {
        Column {
            PageHeader(
                title: this.headerTitle(),
                onBack: this.headerBack,
                backId: "attendanceBack",
                trailing: this.headerTrailing
            )

            if (this.loading || !this.status.startsWith("共 ")) {
                Text(this.status)
                    .fontSize(11.vp)
                    .fontColor(0xFF65738A)
                    .margin(top: 7.vp)
                    .id("attendanceStatus")
            }

            if (this.selectedIndex >= 0) {
                this.detailList()
            } else {
                this.courseList()
            }
        }
        .width(100.percent)
        .height(100.percent)
        .padding(left: 16.vp, right: 16.vp, top: 12.vp, bottom: 8.vp)
        .backgroundColor(0xFFF6F6FE)
        .alignItems(HorizontalAlign.Start)
    }

    @Builder
    func detailList() {
        Scroll {
            Column {
                ForEach(
                    this.details,
                    itemGenerator: {
                        item: ClassAttendanceDetail, index: Int64 => this.detailCard(item, index)
                    }
                )

                if (!this.detailEnd) {
                    Button(if (this.loading) { "加载中…" } else { "加载更多" })
                        .width(100.percent)
                        .margin(top: 12.vp)
                        .onClick({ _ => this.loadDetailPage() })
                        .id("attendanceLoadMore")
                }
            }
            .width(100.percent)
        }
        .width(100.percent)
        .layoutWeight(1)
        .scrollBar(BarState.Auto)
    }

    @Builder
    func detailCard(item: ClassAttendanceDetail, index: Int64) {
        Column {
            Row {
                Text(item.signNameText())
                    .fontSize(16.vp)
                    .fontWeight(FontWeight.Bold)
                    .layoutWeight(1)
                Text(item.signStatusText())
                    .fontSize(13.vp)
                    .fontColor(0xFF46699D)
            }
            .width(100.percent)

            Text("发起人：${item.creatorName}")
                .fontSize(13.vp)
                .margin(top: 7.vp)
            Text("开始：${item.startTime}")
                .fontSize(13.vp)
                .margin(top: 4.vp)

            if (item.submitTime != "") {
                Text("提交：${item.submitTime}")
                    .fontSize(13.vp)
                    .margin(top: 4.vp)
            }
        }
        .width(100.percent)
        .padding(14.vp)
        .margin(top: 10.vp)
        .backgroundColor(0xFFFFFFFF)
        .borderRadius(12.vp)
        .id("attendanceDetail_${index}")
    }

    @Builder
    func courseList() {
        Scroll {
            Column {
                if (this.courses.size > 0) {
                    Row {
                        Text("●").fontSize(13.vp).fontColor(0xFF476FA9).margin(right: 7.vp)
                        Text("未知")
                            .fontSize(18.vp)
                            .fontWeight(FontWeight.Bold)
                            .id("attendanceGroupUnknown")
                    }
                    .width(100.percent)
                    .margin(top: 14.vp, bottom: 2.vp)
                }

                ForEach(
                    this.courses,
                    itemGenerator: {
                        course: ClassAttendance, index: Int64 => this.courseCard(course, index)
                    }
                )
            }
            .width(100.percent)
        }
        .width(100.percent)
        .layoutWeight(1)
        .scrollBar(BarState.Auto)
    }
    @Builder
    func courseCard(course: ClassAttendance, index: Int64) {
        Column {
            Row {
                Text(course.courseName)
                    .fontSize(14.vp)
                    .fontWeight(FontWeight.Medium)
                    .fontColor(0xFFFFFFFF)
                    .layoutWeight(1)
                    .maxLines(1)
                Text(course.statusText())
                    .fontSize(11.vp)
                    .fontColor(0xFFFFFFFF)
            }
                .width(100.percent)
                .height(36.vp)
                .padding(left: 12.vp, right: 10.vp)
                .backgroundColor(this.statusColor(course))

            Column {
                Text(course.className)
                    .fontSize(11.vp)
                    .fontColor(0xFF65738A)
                Row {
                    Text("签到次数　${course.checkInCount}").fontSize(11.vp).layoutWeight(1)
                    Text("应签　${course.requiredCheckIn}").fontSize(11.vp).layoutWeight(1)
                }.width(100.percent).margin(top: 6.vp)
                Row {
                    Text("最近状态　${course.attendanceRate}").fontSize(11.vp).layoutWeight(1)
                    Text("旷课　${course.absenceCount}").fontSize(11.vp).layoutWeight(1)
                }.width(100.percent).margin(top: 5.vp)
                Text("请假：事假 ${course.personalLeave} / 病假 ${course.sickLeave} / 公假 ${course.officialLeave}")
                    .fontSize(10.vp).fontColor(0xFF65738A).margin(top: 5.vp)
                Text("学习进度　任务 ${course.taskProgress} / 作业 ${course.homeworkProgress} / 考试 ${course.examProgress}")
                    .fontSize(10.vp).fontColor(0xFF65738A).margin(top: 4.vp)
            }
                .width(100.percent)
                .padding(left: 12.vp, right: 12.vp, top: 8.vp, bottom: 10.vp)
                .alignItems(HorizontalAlign.Start)
        }
            .width(100.percent)
            .margin(top: 8.vp)
            .backgroundColor(0xFFF0F1F8)
            .borderRadius(9.vp)
            .onClick({ _ => this.openDetail(this.indexOf(course)) })
            .id("attendanceCourseCard_${index}")
    }
}
