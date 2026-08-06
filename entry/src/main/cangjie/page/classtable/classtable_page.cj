package ohos_app_cangjie_entry.page.classtable

import kit.ArkUI.*
import ohos.arkui.state_macro_manage.*
import std.collection.*
import std.time.*
import ohos_app_cangjie_entry.controller.*
import ohos_app_cangjie_entry.model.pda_service.*
import ohos_app_cangjie_entry.model.xidian_ids.*

@Component
public class ClassTablePage {
    @State var loading: Bool = false
    @State var status: String = "请输入学期并刷新真实课表。"
    @State var semester: String = ""
    @State var termStartDay: String = ""
    @State var semesterLength: Int64 = 1
    @State var courses: ArrayList<CourseSlot> = ArrayList<CourseSlot>()
    @State var customClasses: ArrayList<CustomClass> = ArrayList<CustomClass>()
    @State var notArranged: ArrayList<NotArrangedCourse> = ArrayList<NotArrangedCourse>()
    @State var chosenDay: Int64 = 1
    @State var chosenWeek: Int64 = 1
    let controller = ClassTableController()
    let customClassController = CustomClassController()

    protected override func aboutToAppear(): Unit {
        this.customClasses = this.customClassController.load()
    }

    func refresh(): Unit {
        if (this.semester.trimAscii() == "") { this.status = "请先输入学期，例如 2025-2026-2。"; return }
        this.loading = true
        this.status = "正在从统一身份认证服务获取课表..."
        this.controller.reloadClassTable(this.semester, { data => launch {
            this.courses = data.courses
            this.notArranged = data.notArranged
            this.termStartDay = data.termStartDay
            this.semesterLength = data.semesterLength
            if (this.chosenWeek > data.semesterLength) { this.chosenWeek = data.semesterLength }
            this.loading = false
            this.status = if (data.courses.size == 0) { "本学期暂无已排课程。" } else { "已加载 ${data.courses.size} 条课程安排。" }
        } }, { message => launch { this.loading = false; this.status = message } })
    }

    func previousWeek(): Unit {
        if (this.chosenWeek > 1) { this.chosenWeek -= 1 }
    }
    func nextWeek(): Unit {
        if (this.chosenWeek < this.semesterLength) { this.chosenWeek += 1 }
    }
    func visibleCourses(): ArrayList<CourseSlot> {
        return this.controller.arrangements(this.courses, this.chosenDay, this.chosenWeek)
    }
    func selectedDate(): String {
        if (this.termStartDay == "") { return "" }
        try {
            return DateTime.parse(this.termStartDay, "yyyy-MM-dd")
                .addDays((this.chosenWeek - 1) * 7 + this.chosenDay - 1)
                .format("yyyy-MM-dd")
        } catch (_) { return "" }
    }
    func visibleCustomCourses(): ArrayList<CustomClassOccurrence> {
        let date = this.selectedDate()
        if (date == "") { return ArrayList<CustomClassOccurrence>() }
        return this.customClassController.rangesOnDate(this.customClasses, date)
    }

    @Builder
    func dayButton(label: String, day: Int64, stableId: String) {
        Button(label).width(42.vp).height(34.vp).fontSize(12.vp)
            .fontColor(if (this.chosenDay == day) { 0xFFFFFFFF } else { 0xFF3F5574 })
            .backgroundColor(if (this.chosenDay == day) { 0xFF46699D } else { 0xFFEAF0F8 })
            .borderRadius(8.vp).onClick({ _ => this.chosenDay = day }).id(stableId)
    }
    func build() {
        Column {
            Row {
                Text("课程表").fontSize(26.vp).fontWeight(FontWeight.Bold).layoutWeight(1)
                Button(if (this.loading) { "刷新中" } else { "刷新" }).height(36.vp).onClick({ _ => this.refresh() }).id("classtableRefreshButton")
            }.width(100.percent)
            TextInput(placeholder: "学期，例如 2025-2026-2", text: this.semester).width(100.percent).height(42.vp).margin(top: 12.vp).onChange({ value => this.semester = value }).id("classtableSemesterInput")
            Row {
                Button("<").width(40.vp).height(34.vp).onClick({ _ => this.previousWeek() }).id("classtablePreviousWeek")
                Text("第 ${this.chosenWeek} 周").fontSize(16.vp).fontWeight(FontWeight.Bold).layoutWeight(1).textAlign(TextAlign.Center).id("classtableWeekLabel")
                Button(">").width(40.vp).height(34.vp).onClick({ _ => this.nextWeek() }).id("classtableNextWeek")
            }.width(100.percent).margin(top: 12.vp)
            if (this.termStartDay != "") { Text("学期开始：${this.termStartDay} · 共 ${this.semesterLength} 周").fontSize(11.vp).fontColor(0xFF738198).margin(top: 6.vp).id("classtableTermMeta") }
            Row {
                this.dayButton("一", 1, "classtableDay1")
                this.dayButton("二", 2, "classtableDay2")
                this.dayButton("三", 3, "classtableDay3")
                this.dayButton("四", 4, "classtableDay4")
                this.dayButton("五", 5, "classtableDay5")
                this.dayButton("六", 6, "classtableDay6")
                this.dayButton("日", 7, "classtableDay7")
            }.width(100.percent).justifyContent(FlexAlign.SpaceBetween).margin(top: 12.vp)
            Text(this.status).fontSize(12.vp).fontColor(0xFF5F6B7C).margin(top: 10.vp).id("classtableStatus")
            Scroll {
                Column {
                    if (!this.loading && this.visibleCourses().size == 0 && this.visibleCustomCourses().size == 0) {
                        Text("本周当天没有课程").fontSize(16.vp).fontColor(0xFF7A8797).margin(top: 32.vp).id("classtableEmptyState")
                    }
                    ForEach(this.visibleCourses(), itemGenerator: { course: CourseSlot, _: Int64 =>
                        Column {
                            Row {
                                Text("${course.start}-${course.stop} 节").fontSize(13.vp).fontWeight(FontWeight.Bold).fontColor(0xFF46699D)
                                Text(course.name).fontSize(17.vp).fontWeight(FontWeight.Bold).layoutWeight(1).margin(left: 10.vp)
                            }.width(100.percent)
                            Text("${course.teacher}  ·  ${course.room}").fontSize(13.vp).fontColor(0xFF4F5E72).margin(top: 6.vp)
                            Text(course.weekSummary()).fontSize(11.vp).fontColor(0xFF738198).margin(top: 4.vp)
                        }.width(100.percent).padding(14.vp).margin(top: 10.vp).backgroundColor(0xFFEAF2FC).borderRadius(12.vp).id("classtableCourseCard")
                    })
                    ForEach(this.visibleCustomCourses(), itemGenerator: { occurrence: CustomClassOccurrence, _: Int64 =>
                        Column {
                            Row {
                                Text(occurrence.range.timeText()).fontSize(13.vp).fontWeight(FontWeight.Bold).fontColor(0xFF7A4E00)
                                Text(occurrence.course.name).fontSize(17.vp).fontWeight(FontWeight.Bold).layoutWeight(1).margin(left: 10.vp)
                            }.width(100.percent)
                            Text("${occurrence.course.teacher}  ·  ${occurrence.course.classroom}").fontSize(13.vp).fontColor(0xFF5D4A2F).margin(top: 6.vp)
                            Text("自定义课程 · ${occurrence.range.date}").fontSize(11.vp).fontColor(0xFF806A4C).margin(top: 4.vp)
                        }.width(100.percent).padding(14.vp).margin(top: 10.vp).backgroundColor(0xFFFFF3D6).borderRadius(12.vp).id("classtableCustomCourseCard")
                    })
                    if (this.notArranged.size > 0) {
                        Text("未排课课程").fontSize(16.vp).fontWeight(FontWeight.Bold).margin(top: 22.vp).id("classtableNotArrangedTitle")
                        ForEach(this.notArranged, itemGenerator: { course: NotArrangedCourse, _: Int64 =>
                            Row {
                                Text(course.name).fontSize(14.vp).layoutWeight(1)
                                Text(course.teacher).fontSize(12.vp).fontColor(0xFF738198)
                            }.width(100.percent).padding(12.vp).margin(top: 8.vp).backgroundColor(0xFFF4F6F9).borderRadius(10.vp).id("classtableNotArrangedCard")
                        })
                    }
                }.width(100.percent).padding(bottom: 28.vp).alignItems(HorizontalAlign.Start)
            }.width(100.percent).layoutWeight(1).align(Alignment.TopStart)
        }.width(100.percent).height(100.percent).padding(20.vp).alignItems(HorizontalAlign.Start).backgroundColor(0xFFF7F9FC)
    }
}
