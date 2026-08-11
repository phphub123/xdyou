package ohos_app_cangjie_entry.page.classtable

import kit.ArkUI.*
import ohos.arkui.state_macro_manage.*
import std.collection.*
import std.time.*
import ohos_app_cangjie_entry.controller.*
import ohos_app_cangjie_entry.model.pda_service.*
import ohos_app_cangjie_entry.model.xidian_ids.*
import ohos_app_cangjie_entry.repository.*
import ohos_app_cangjie_entry.repository.xidian_ids.*

@Component
public class ClassTablePage {
    let onBack: () -> Unit
    @State var loading: Bool = false
    @State var status: String = "正在读取当前学期…"
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
        if (this.courses.size == 0 && !this.loading) { this.loadCurrentSemester() }
    }

    func loadCurrentSemester(): Unit {
        this.loading = true
        this.status = "正在读取当前学期…"
        AcademicSession().loadCurrentSemester({ value => launch {
            this.semester = value
            SessionStore().saveSetting("semester", value)
            this.refresh()
        } }, { message => launch {
            let cached = SessionStore().restoreSetting("semester")
            if (cached == "") {
                this.loading = false
                this.status = message
            } else {
                this.semester = cached
                this.refresh()
            }
        } })
    }

    func refresh(): Unit {
        if (this.semester.trimAscii() == "") { this.loadCurrentSemester(); return }
        this.loading = true
        this.status = "正在从教务系统获取课程表…"
        this.controller.reloadClassTable(this.semester, { data => launch {
            this.courses = data.courses
            this.notArranged = data.notArranged
            this.termStartDay = data.termStartDay
            this.semesterLength = data.semesterLength
            this.selectCurrentDate()
            this.loading = false
            this.status = if (data.courses.size == 0) { "本学期暂无已排课程。" } else { "已同步 ${data.courses.size} 条课程安排" }
        } }, { message => launch {
            this.loading = false
            this.status = message
        } })
    }

    func selectCurrentDate(): Unit {
        if (this.termStartDay == "") { return }
        try {
            let now = DateTime.now()
            let start = DateTime.parse(this.termStartDay, "yyyy-MM-dd")
            let diffDays = (now.toUnixTimeStamp().toSeconds() - start.toUnixTimeStamp().toSeconds()) / 86400
            if (diffDays >= 0) {
                let week = diffDays / 7 + 1
                this.chosenWeek = if (week > this.semesterLength) { this.semesterLength } else { week }
            }
            this.chosenDay = match (now.dayOfWeek) {
                case Monday => 1
                case Tuesday => 2
                case Wednesday => 3
                case Thursday => 4
                case Friday => 5
                case Saturday => 6
                case Sunday => 7
            }
        } catch (_) { () }
    }

    func chooseWeek(value: Int64): Unit {
        if (value >= 1 && value <= this.semesterLength) { this.chosenWeek = value }
    }
    func previousWeek(): Unit { if (this.chosenWeek > 1) { this.chosenWeek -= 1 } }
    func nextWeek(): Unit { if (this.chosenWeek < this.semesterLength) { this.chosenWeek += 1 } }
    func dayCourses(day: Int64): ArrayList<CourseSlot> { return this.controller.arrangements(this.courses, day, this.chosenWeek) }

    @Builder
    func weekChoice(offset: Int64) {
        if (this.chosenWeek + offset >= 1 && this.chosenWeek + offset <= this.semesterLength) {
            Button("第${this.chosenWeek + offset}周")
                .layoutWeight(1)
                .height(43.vp)
                .fontSize(10.vp)
                .fontColor(if (offset == 0) { 0xFFFFFFFF } else { 0xFF55657A })
                .backgroundColor(if (offset == 0) { 0xFF9AAFCB } else { 0xFFF0F3F8 })
                .borderRadius(8.vp)
                .margin(left: 2.vp, right: 2.vp)
                .onClick({_ => this.chooseWeek(this.chosenWeek + offset)})
                .id("classtableWeek_${this.chosenWeek + offset}")
        } else { Blank().layoutWeight(1).height(43.vp) }
    }

    @Builder
    func dayColumn(day: Int64, label: String) {
        Column {
            Text(label)
                .width(100.percent)
                .height(28.vp)
                .textAlign(TextAlign.Center)
                .fontSize(11.vp)
                .fontWeight(if (this.chosenDay == day) { FontWeight.Bold } else { FontWeight.Normal })
                .fontColor(if (this.chosenDay == day) { 0xFF41699F } else { 0xFF30343B })
                .onClick({_ => this.chosenDay = day})
            ForEach(this.dayCourses(day), itemGenerator: { course: CourseSlot, _: Int64 =>
                Column {
                    Text(course.name).fontSize(9.vp).fontWeight(FontWeight.Medium).maxLines(4)
                    Text(course.room).fontSize(8.vp).maxLines(2).margin(top: 2.vp)
                    Text("${course.start}-${course.stop}节").fontSize(8.vp).margin(top: 2.vp)
                }
                    .width(100.percent)
                    .padding(4.vp)
                    .margin(top: 3.vp)
                    .backgroundColor(0xFFEAF3D5)
                    .border(width: 1.vp, color: 0xFF86B56A)
                    .borderRadius(5.vp)
                    .id("classtableCourseCard")
            })
        }.layoutWeight(1).padding(left: 1.vp, right: 1.vp).alignItems(HorizontalAlign.Start)
    }

    func build() {
        Column {
            Row {
                Button("<").width(38.vp).height(36.vp).margin(right: 8.vp).onClick({_ => this.onBack()}).id("classtableBack")
                Text("我的日程表").fontSize(22.vp).fontWeight(FontWeight.Medium).layoutWeight(1)
                Button(if (this.loading) { "刷新中" } else { "刷新" })
                    .height(36.vp)
                    .onClick({_ => this.refresh()})
                    .id("classtableRefreshButton")
            }.width(100.percent)

            Row {
                this.weekChoice(-2)
                this.weekChoice(-1)
                this.weekChoice(0)
                this.weekChoice(1)
                this.weekChoice(2)
            }.width(100.percent).margin(top: 10.vp).id("classtableWeekStrip")

            Row {
                Button("<").width(38.vp).height(32.vp).onClick({_ => this.previousWeek()}).id("classtablePreviousWeek")
                Text("第 ${this.chosenWeek} 周")
                    .fontSize(15.vp).fontWeight(FontWeight.Bold).layoutWeight(1).textAlign(TextAlign.Center)
                    .id("classtableWeekLabel")
                Button(">").width(38.vp).height(32.vp).onClick({_ => this.nextWeek()}).id("classtableNextWeek")
            }.width(100.percent).margin(top: 8.vp)

            Text(this.status).fontSize(11.vp).fontColor(0xFF65738A).margin(top: 7.vp).id("classtableStatus")

            Scroll {
                Column {
                    Row {
                        this.dayColumn(1, "周一")
                        this.dayColumn(2, "周二")
                        this.dayColumn(3, "周三")
                        this.dayColumn(4, "周四")
                        this.dayColumn(5, "周五")
                        this.dayColumn(6, "周六")
                        this.dayColumn(7, "周日")
                    }.width(100.percent).alignItems(VerticalAlign.Top).id("classtableWeekGrid")

                    if (!this.loading && this.courses.size == 0) {
                        Text("本学期没有课程").fontSize(15.vp).fontColor(0xFF7A8797).margin(top: 32.vp)
                    }
                    if (this.notArranged.size > 0) {
                        Text("未安排时间的课程 · ${this.notArranged.size}")
                            .fontSize(13.vp).fontWeight(FontWeight.Medium).margin(top: 18.vp)
                            .id("classtableNotArrangedTitle")
                    }
                }.width(100.percent).padding(bottom: 24.vp).alignItems(HorizontalAlign.Start)
            }.width(100.percent).layoutWeight(1).margin(top: 4.vp).align(Alignment.TopStart)
        }
            .width(100.percent)
            .height(100.percent)
            .padding(left: 18.vp, right: 18.vp, top: 16.vp, bottom: 8.vp)
            .alignItems(HorizontalAlign.Start)
            .backgroundColor(0xFFF7F9FC)
    }
}