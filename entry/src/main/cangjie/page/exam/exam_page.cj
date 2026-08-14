package ohos_app_cangjie_entry.page.exam

import kit.ArkUI.*
import ohos.arkui.state_macro_manage.*
import ohos.resource.*
import std.collection.*
import ohos_app_cangjie_entry.repository.xidian_ids.*
import ohos_app_cangjie_entry.model.xidian_ids.*
import ohos_app_cangjie_entry.controller.*
import ohos_app_cangjie_entry.components.*

@Component
public class ExamPage {
    let onBack: () -> Unit
    @State var loading: Bool = false
    @State var status: String = "正在获取当前学期…"
    @State var semester: String = ""
    @State var showUnarranged: Bool = false
    @State var exams: ArrayList<ExamItem> = ArrayList<ExamItem>()
    @State var scores: ArrayList<ScoreItem> = ArrayList<ScoreItem>()
    let controller = ExamController()
    let scoreController = ScoreController()

    protected override func aboutToAppear(): Unit {
        if (this.semester == "" && !this.loading) { this.loadCurrentSemester() }
    }

    func loadCurrentSemester(): Unit {
        this.loading = true
        AcademicSession().loadCurrentSemester({ code => launch {
            this.semester = code; this.loading = false; this.refresh()
        } }, { message => launch { this.loading = false; this.status = message } })
    }

    func refresh(): Unit {
        if (this.semester.trimAscii() == "") { this.loadCurrentSemester(); return }
        this.loading = true
        this.scoreController.reloadScores({ items => launch {
            this.scores = items; this.reloadExams()
        } }, { _ => launch { this.reloadExams() } })
    }

    func reloadExams(): Unit {
        this.controller.reloadExams(this.semester, { items => launch {
            this.exams = items; this.loading = false
            this.status = if (items.size == 0) { "暂无考试记录。" } else { "已加载 ${items.size} 条考试记录。" }
        } }, { message => launch { this.loading = false; this.status = message } })
    }

    func hasPublishedScore(subject: String): Bool {
        for (score in this.scores) {
            if (score.isFinished() && score.name.trimAscii() == subject.trimAscii()) { return true }
        }
        return false
    }

    func activeExams(): ArrayList<ExamItem> {
        let result = ArrayList<ExamItem>()
        for (exam in this.exams) {
            if (exam.arranged || !this.hasPublishedScore(exam.subject)) { result.add(exam) }
        }
        return result
    }

    func groups(): ExamGroups { return this.controller.group(this.activeExams()) }

    func examKind(item: ExamItem): String {
        if (item.kind.contains("期末")) { return "期末考试" }
        if (item.kind.contains("期中")) { return "期中考试" }
        return item.kind
    }

    @Builder
    func refreshAction() {
        Row {
            HeaderRefreshAction(onRefresh: this.refresh, actionId: "examRefreshButton")
            Button {
                Image(@r(app.media.action_exam_pending)).width(18.vp).height(18.vp)
                    .objectFit(ImageFit.Contain)
            }.width(38.vp).height(38.vp).padding(9.vp)
                .buttonStyle(ButtonStyleMode.Textual).backgroundColor(Color.Transparent)
                .onClick({_ => this.showUnarranged = true}).id("examUnarrangedButton")
        }
    }

    @Builder
    func sectionTitle(title: String, stableId: String) {
        Row {
            Text("●").fontSize(11.vp).fontColor(0xFF46699D).margin(right: 8.vp)
            Text(title).fontSize(13.vp).fontColor(0xFF46699D).id(stableId)
        }.width(100.percent).height(42.vp)
    }

    @Builder
    func arrangedCard(item: ExamItem, index: Int64, finished: Bool) {
        Column {
            Row {
                Text(item.subject).fontSize(13.vp).fontWeight(FontWeight.Medium)
                    .fontColor(0xFFFFFFFF).layoutWeight(1).maxLines(1)
                Text(this.examKind(item)).width(72.vp).fontSize(10.vp).fontColor(0xFFFFFFFF)
                    .textAlign(TextAlign.End).maxLines(1)
            }.width(100.percent).height(36.vp).padding(left: 12.vp, right: 10.vp)
                .backgroundColor(0xFF46699D)
            Column {
                Row {
                    Image(@r(app.media.exam_time)).width(13.vp).height(13.vp).margin(right: 5.vp)
                    Text(item.time).fontSize(11.vp).maxLines(1)
                }.width(100.percent)
                Row {
                    Image(@r(app.media.exam_location)).width(13.vp).height(13.vp).margin(right: 5.vp)
                    Text(item.room).width(126.vp).fontSize(11.vp).maxLines(1)
                    Image(@r(app.media.exam_seat)).width(15.vp).height(15.vp).margin(left: 7.vp, right: 4.vp)
                    Text(item.seat).fontSize(11.vp).maxLines(1)
                }.width(100.percent).margin(top: 5.vp)
            }.width(100.percent).padding(left: 12.vp, right: 12.vp, top: 9.vp, bottom: 10.vp)
                .alignItems(HorizontalAlign.Start)
        }.width(93.percent).margin(left: 22.vp, top: 8.vp).backgroundColor(0xFFF0F1F8)
            .borderRadius(9.vp).id(if (finished) { "examFinishedCard_${index}" } else { "examUpcomingCard_${index}" })
    }

    @Builder
    func unarrangedCard(item: ExamItem, index: Int64) {
        Column {
            Text(item.subject).width(100.percent).fontSize(13.vp).fontWeight(FontWeight.Medium)
                .fontColor(0xFFFFFFFF).padding(12.vp).backgroundColor(0xFF46699D).maxLines(1)
            Text(if (item.courseId == "") { "考试时间、地点待安排" } else { "课程号 ${item.courseId} · 时间、地点待安排" })
                .width(100.percent).fontSize(11.vp).fontColor(0xFF65738A).padding(12.vp)
        }.width(100.percent).margin(top: 8.vp).backgroundColor(0xFFF0F1F8)
            .borderRadius(9.vp).id("examUnarrangedCard_${index}")
    }

    @Builder
    func emptyCard(text: String) {
        Text(text).width(93.percent).height(50.vp).margin(left: 22.vp, top: 8.vp)
            .textAlign(TextAlign.Center).fontSize(14.vp).fontColor(0xFF46699D)
            .backgroundColor(0xFFE9EDF5).borderRadius(9.vp)
    }

    @Builder
    func mainContent() {
        Column {
            PageHeader(title: "考试安排", onBack: this.onBack, backId: "examBack", trailing: this.refreshAction)
            if (this.loading || this.exams.size == 0) {
                Text(this.status).fontSize(11.vp).fontColor(0xFF65738A).margin(top: 7.vp).id("examStatus")
            }
            Scroll {
                Column {
                    this.sectionTitle("未完成考试", "examUpcomingSection")
                    if (this.groups().upcoming.size == 0) { this.emptyCard("所有考试全部完成") }
                    ForEach(this.groups().upcoming, itemGenerator: { item: ExamItem, index: Int64 =>
                        this.arrangedCard(item, index, false)
                    })
                    this.sectionTitle("已完成考试", "examFinishedSection")
                    if (this.groups().finished.size == 0) { this.emptyCard("暂无已完成考试") }
                    ForEach(this.groups().finished, itemGenerator: { item: ExamItem, index: Int64 =>
                        this.arrangedCard(item, index, true)
                    })
                    Blank().height(24.vp)
                }.width(100.percent).alignItems(HorizontalAlign.Start)
            }.width(100.percent).layoutWeight(1).align(Alignment.TopStart)
        }.width(100.percent).height(100.percent).alignItems(HorizontalAlign.Start)
    }

    @Builder
    func unarrangedContent() {
        Column {
            PageHeader(title: "未安排考试", onBack: {=> this.showUnarranged = false}, backId: "examUnarrangedBack")
            Scroll {
                Column {
                    if (this.groups().unarranged.size == 0) {
                        Text("所有考试均已安排或已有成绩").width(100.percent).margin(top: 36.vp)
                            .textAlign(TextAlign.Center).fontColor(0xFF65738A).id("examAllArranged")
                    }
                    ForEach(this.groups().unarranged, itemGenerator: { item: ExamItem, index: Int64 =>
                        this.unarrangedCard(item, index)
                    })
                }.width(100.percent)
            }.width(100.percent).layoutWeight(1)
        }.width(100.percent).height(100.percent).alignItems(HorizontalAlign.Start)
    }

    func build() {
        Column {
            if (this.showUnarranged) { this.unarrangedContent() } else { this.mainContent() }
        }.width(100.percent).height(100.percent).padding(left: 14.vp, right: 14.vp, top: 8.vp, bottom: 8.vp)
            .alignItems(HorizontalAlign.Start).backgroundColor(0xFFFFFFFF)
    }
}
