package ohos_app_cangjie_entry.page.classtable

import kit.ArkUI.*
import ohos.arkui.state_macro_manage.*
import std.collection.ArrayList
import std.sync.*
import std.time.*
import ohos_app_cangjie_entry.controller.*
import ohos_app_cangjie_entry.model.pda_service.*
import ohos_app_cangjie_entry.model.xidian_ids.*
import ohos_app_cangjie_entry.repository.*
import ohos_app_cangjie_entry.repository.xidian_ids.*
import ohos_app_cangjie_entry.components.*

public class WeekPreviewData {
    public let week: Int64
    public let revision: Int64
    public let colors: ArrayList<Int64>

    public init(week: Int64, revision: Int64, colors: ArrayList<Int64>) {
        this.week = week
        this.revision = revision
        this.colors = colors
    }

    public func color(day: Int64, block: Int64): Int64 {
        let index = block * 5 + day - 1
        return if (index >= 0 && index < this.colors.size) { this.colors[index] } else { 0xFFD1DAE7 }
    }

    public func key(): String { return "${this.week}-${this.revision}" }
}

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
    @State var weekPreviewRevision: Int64 = 0
    @State var weekPreviews: ArrayList<WeekPreviewData> = ArrayList<WeekPreviewData>()
    let controller = ClassTableController()
    let customClassController = CustomClassController()
    let weekScroller = Scroller()

    protected override func aboutToAppear(): Unit {
        let loadedCustomClasses = this.customClassController.load()
        this.customClasses = loadedCustomClasses
        this.rebuildWeekPreviews(this.courses, loadedCustomClasses, this.termStartDay, this.semesterLength)
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
            // 直接使用本次请求返回的数据生成缩略图，避免同一 UI 任务中读取到 @State 的旧值。
            this.rebuildWeekPreviews(data.courses, this.customClasses, data.termStartDay, data.semesterLength)
            this.selectCurrentDate(data.termStartDay, data.semesterLength)
            this.loading = false
            this.status = if (data.courses.size == 0) { "本学期暂无已排课程。" } else { "已同步 ${data.courses.size} 条课程安排" }
        } }, { message => launch {
            this.loading = false
            this.status = message
        } })
    }

    func dateOnly(value: String): String { return if (value.size >= 10) { value[0..10] } else { value } }

    func selectCurrentDate(sourceTermStartDay: String, sourceSemesterLength: Int64): Unit {
        if (sourceTermStartDay == "") { return }
        try {
            let now = DateTime.now()
            let start = DateTime.parse(this.dateOnly(sourceTermStartDay), "yyyy-MM-dd")
            let diffDays = (now.toUnixTimeStamp().toSeconds() - start.toUnixTimeStamp().toSeconds()) / 86400
            if (diffDays >= 0) {
                let week = diffDays / 7 + 1
                this.chosenWeek = if (week > sourceSemesterLength) { sourceSemesterLength } else { week }
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
            Timer.once(Duration.millisecond * 80, { => launch { this.centerChosenWeek(false) }})
        } catch (_) { () }
    }

    func chooseWeek(value: Int64): Unit {
        if (value >= 1 && value <= this.semesterLength) {
            this.chosenWeek = value
            this.centerChosenWeek(true)
        }
    }

    func centerChosenWeek(animated: Bool): Unit {
        let firstVisibleWeek = if (this.chosenWeek > 3) { this.chosenWeek - 3 } else { 0 }
        this.weekScroller.scrollTo(
            xOffset: (Float64(firstVisibleWeek) * 62.0).vp,
            yOffset: 0.vp,
            animation: animated
        )
    }

    func weekNumbers(): ArrayList<Int64> {
        let result = ArrayList<Int64>()
        var week: Int64 = 1
        while (week <= this.semesterLength) {
            result.add(week)
            week += 1
        }
        return result
    }

    func dayCourses(day: Int64): ArrayList<CourseSlot> { return this.controller.arrangements(this.courses, day, this.chosenWeek) }

    func previewSlotStart(block: Int64): Int64 {
        return match (block) {
            case 0 => 1
            case 1 => 3
            case 2 => 5
            case 3 => 7
            case _ => 9
        }
    }

    func previewSlotStop(block: Int64): Int64 {
        return match (block) {
            case 0 => 2
            case 1 => 4
            case 2 => 6
            case 3 => 8
            case _ => 9
        }
    }

    func previewSlotStartMinutes(block: Int64): Int64 {
        return match (block) {
            case 0 => 8 * 60 + 30
            case 1 => 10 * 60 + 25
            case 2 => 14 * 60
            case 3 => 15 * 60 + 55
            case _ => 19 * 60
        }
    }

    func previewSlotStopMinutes(block: Int64): Int64 {
        return match (block) {
            case 0 => 10 * 60 + 5
            case 1 => 12 * 60
            case 2 => 15 * 60 + 35
            case 3 => 17 * 60 + 30
            // Flutter compact preview ends at block 49: 3/5 into the 19:00-19:45 period.
            case _ => 19 * 60 + 27
        }
    }

    func monthNumber(value: DateTime): Int64 {
        return match (value.month) {
            case January => 1
            case February => 2
            case March => 3
            case April => 4
            case May => 5
            case June => 6
            case July => 7
            case August => 8
            case September => 9
            case October => 10
            case November => 11
            case December => 12
        }
    }

    func padded(value: Int64): String { return if (value < 10) { "0${value}" } else { "${value}" } }

    // 0 = 空闲，1 = 已结束，2 = 尚未结束；语义与 Flutter WeekChoiceView 保持一致。
    func weekDotState(sourceCourses: ArrayList<CourseSlot>, sourceCustomClasses: ArrayList<CustomClass>,
        sourceTermStartDay: String, week: Int64, day: Int64, block: Int64): Int64 {
        if (sourceTermStartDay == "") { return 0 }
        try {
            let slotStart = this.previewSlotStart(block)
            let slotStop = this.previewSlotStop(block)
            var occupied = false
            for (course in this.controller.arrangements(sourceCourses, day, week)) {
                if (course.stop >= slotStart && course.start <= slotStop) {
                    occupied = true
                    break
                }
            }

            // 教务接口可能返回 `yyyy-MM-dd HH:mm:ss`，预览只使用日期部分。
            let termStart = DateTime.parse(this.dateOnly(sourceTermStartDay), "yyyy-MM-dd")
            let slotDate = termStart.addDays((week - 1) * 7 + day - 1)
            let dateText = "${slotDate.year}-${this.padded(this.monthNumber(slotDate))}-${this.padded(slotDate.dayOfMonth)}"
            let customSlotStart = this.previewSlotStartMinutes(block)
            let customSlotStop = this.previewSlotStopMinutes(block)
            for (customClass in sourceCustomClasses) {
                for (range in customClass.timeRanges) {
                    if (range.date == dateText && range.endMinutes > customSlotStart && range.startMinutes < customSlotStop) {
                        occupied = true
                        break
                    }
                }
                if (occupied) { break }
            }
            if (!occupied) { return 0 }

            let now = DateTime.now()
            let nowSeconds = now.toUnixTimeStamp().toSeconds()
            let slotDaySeconds = slotDate.toUnixTimeStamp().toSeconds()
            if (nowSeconds >= slotDaySeconds + 86400) { return 1 }
            if (nowSeconds < slotDaySeconds) { return 2 }
            let currentMinutes = now.hour * 60 + now.minute
            return if (this.previewSlotStopMinutes(block) <= currentMinutes) { 1 } else { 2 }
        } catch (_) {
            return 0
        }
    }

    // 使用预混合后的实体色，而不是依赖 Shape.fillOpacity；后者在当前设备上未稳定呈现差异。
    func weekDotColor(sourceCourses: ArrayList<CourseSlot>, sourceCustomClasses: ArrayList<CustomClass>,
        sourceTermStartDay: String, week: Int64, day: Int64, block: Int64): Int64 {
        return match (this.weekDotState(sourceCourses, sourceCustomClasses, sourceTermStartDay, week, day, block)) {
            case 2 => 0xFF41699F
            case 1 => 0xFF8EA7C6
            case _ => 0xFFD1DAE7
        }
    }

    func rebuildWeekPreviews(sourceCourses: ArrayList<CourseSlot>, sourceCustomClasses: ArrayList<CustomClass>,
        sourceTermStartDay: String, sourceSemesterLength: Int64): Unit {
        this.weekPreviewRevision += 1
        let result = ArrayList<WeekPreviewData>()
        var week: Int64 = 1
        while (week <= sourceSemesterLength) {
            let colors = ArrayList<Int64>()
            var block: Int64 = 0
            while (block < 5) {
                var day: Int64 = 1
                while (day <= 5) {
                    colors.add(this.weekDotColor(sourceCourses, sourceCustomClasses, sourceTermStartDay,
                        week, day, block))
                    day += 1
                }
                block += 1
            }
            result.add(WeekPreviewData(week, this.weekPreviewRevision, colors))
            week += 1
        }
        this.weekPreviews = result
    }

    @Builder
    func weekDot(preview: WeekPreviewData, day: Int64, block: Int64) {
        Circle(width: 4.8.vp, height: 4.8.vp)
            .fill(preview.color(day, block))
            .id("classtableWeekDot_${preview.week}_${day}_${block}")
    }

    @Builder
    func weekDotRow(preview: WeekPreviewData, block: Int64) {
        Row(space: 3.0.vp) {
            this.weekDot(preview, 1, block)
            this.weekDot(preview, 2, block)
            this.weekDot(preview, 3, block)
            this.weekDot(preview, 4, block)
            this.weekDot(preview, 5, block)
        }.width(36.vp).height(5.vp).justifyContent(FlexAlign.Center)
    }

    @Builder
    func weekChoice(preview: WeekPreviewData) {
        Column {
            Text("第${preview.week}周")
                .fontSize(10.vp)
                .fontWeight(if (this.chosenWeek == preview.week) { FontWeight.Medium } else { FontWeight.Normal })
                .fontColor(if (this.chosenWeek == preview.week) { 0xFF243B5A } else { 0xFF30343B })
            Column(space: 1.8.vp) {
                this.weekDotRow(preview, 0)
                this.weekDotRow(preview, 1)
                this.weekDotRow(preview, 2)
                this.weekDotRow(preview, 3)
                this.weekDotRow(preview, 4)
            }
                .width(42.vp)
                .height(33.vp)
                .justifyContent(FlexAlign.Center)
                .margin(top: 2.vp)
        }
            .width(56.vp)
            .height(66.vp)
            .margin(left: 3.vp, right: 3.vp)
            .justifyContent(FlexAlign.Center)
            .backgroundColor(if (this.chosenWeek == preview.week) { 0xFFB6C5D9 } else { 0xFFF7F9FC })
            .borderRadius(12.vp)
            .onClick({_ => this.chooseWeek(preview.week)})
            .id("classtableWeek_${preview.week}")
    }

    func courseTop(course: CourseSlot): Float64 { return Float64(course.start - 1) * 64.0 }
    func courseHeight(course: CourseSlot): Float64 {
        let slots = if (course.stop >= course.start) { course.stop - course.start + 1 } else { 1 }
        return Float64(slots) * 64.0 - 4.0
    }

    @Builder
    func dayHeader(day: Int64, label: String) {
        Text(label).layoutWeight(1).height(28.vp).textAlign(TextAlign.Center).fontSize(11.vp)
            .fontWeight(if (this.chosenDay == day) { FontWeight.Bold } else { FontWeight.Normal })
            .fontColor(if (this.chosenDay == day) { 0xFF41699F } else { 0xFF30343B })
            .onClick({_ => this.chosenDay = day})
    }

    @Builder
    func timeCell(index: Int64, value: String) {
        Column {
            Text("${index}").fontSize(11.vp).fontWeight(FontWeight.Medium)
            Text(value).fontSize(7.vp).fontColor(0xFF65738A).textAlign(TextAlign.Center).maxLines(2)
        }.width(42.vp).height(64.vp).justifyContent(FlexAlign.Start)
    }

    @Builder
    func timeAxis() {
        Column {
            this.timeCell(1, "08:30\n09:15")
            this.timeCell(2, "09:20\n10:05")
            this.timeCell(3, "10:25\n11:10")
            this.timeCell(4, "11:15\n12:00")
            this.timeCell(5, "14:00\n14:45")
            this.timeCell(6, "14:50\n15:35")
            this.timeCell(7, "15:55\n16:40")
            this.timeCell(8, "16:45\n17:30")
        }.width(42.vp).height(512.vp)
    }

    @Builder
    func dayColumn(day: Int64) {
        Stack(alignContent: Alignment.TopStart) {
            ForEach(this.dayCourses(day), itemGenerator: { course: CourseSlot, _: Int64 =>
                Column {
                    Text(course.name).fontSize(8.vp).fontWeight(FontWeight.Medium).maxLines(4)
                    Text(course.room).fontSize(7.vp).maxLines(2).margin(top: 2.vp)
                    Text("${course.start}-${course.stop}节").fontSize(7.vp).margin(top: 2.vp)
                }.width(100.percent).height(this.courseHeight(course).vp).padding(3.vp)
                    .backgroundColor(0xFFEAF3D5).border(width: 1.vp, color: 0xFF86B56A).borderRadius(5.vp)
                    .position(x: 0.vp, y: this.courseTop(course).vp).id("classtableCourseCard")
            })
        }.layoutWeight(1).height(512.vp).padding(left: 1.vp, right: 1.vp)
    }

    @Builder
    func refreshAction() {
        HeaderRefreshAction(onRefresh: this.refresh, actionId: "classtableRefreshButton")
    }

    func build() {
        Column {
            PageHeader(title: "我的日程表", onBack: this.onBack,
                backId: "classtableBack", trailing: this.refreshAction)

            Scroll(this.weekScroller) {
                Row {
                    ForEach(this.weekPreviews, itemGenerator: { preview: WeekPreviewData, _: Int64 =>
                        this.weekChoice(preview)
                    }, keyGenerator: { preview: WeekPreviewData, _: Int64 => preview.key() })
                }.width((Float64(this.weekPreviews.size) * 62.0).vp).height(70.vp)
            }
                .width(100.percent)
                .height(70.vp)
                .margin(top: 8.vp)
                .scrollable(ScrollDirection.Horizontal)
                .scrollBar(BarState.Off)
                .id("classtableWeekStrip")

            if (this.loading || this.courses.size == 0) {
                Text(this.status).fontSize(11.vp).fontColor(0xFF65738A).margin(top: 7.vp).id("classtableStatus")
            }

            Scroll {
                Column {
                    Row {
                        Blank().width(42.vp).height(28.vp)
                        this.dayHeader(1, "周一")
                        this.dayHeader(2, "周二")
                        this.dayHeader(3, "周三")
                        this.dayHeader(4, "周四")
                        this.dayHeader(5, "周五")
                        this.dayHeader(6, "周六")
                        this.dayHeader(7, "周日")
                    }.width(100.percent)
                    Row {
                        this.timeAxis()
                        this.dayColumn(1)
                        this.dayColumn(2)
                        this.dayColumn(3)
                        this.dayColumn(4)
                        this.dayColumn(5)
                        this.dayColumn(6)
                        this.dayColumn(7)
                    }.width(100.percent).alignItems(VerticalAlign.Top).id("classtableWeekGrid")
                    if (!this.loading && this.courses.size == 0) {
                        Text("本学期没有课程").fontSize(15.vp).fontColor(0xFF7A8797).margin(top: 32.vp)
                    }
                    if (this.notArranged.size > 0) {
                        Text("未安排时间的课程 · ${this.notArranged.size}")
                            .fontSize(13.vp).fontWeight(FontWeight.Medium).margin(top: 14.vp)
                            .id("classtableNotArrangedTitle")
                    }
                }.width(100.percent).padding(bottom: 24.vp).alignItems(HorizontalAlign.Start)
            }.width(100.percent).layoutWeight(1).margin(top: 4.vp).align(Alignment.TopStart)
        }.width(100.percent).height(100.percent).padding(left: 16.vp, right: 16.vp, top: 12.vp, bottom: 8.vp)
            .alignItems(HorizontalAlign.Start).backgroundColor(0xFFF7F9FC)
    }
}
