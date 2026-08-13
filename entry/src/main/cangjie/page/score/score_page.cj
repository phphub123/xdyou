package ohos_app_cangjie_entry.page.score

import kit.ArkUI.*
import ohos.arkui.state_macro_manage.*
import std.collection.*
import ohos_app_cangjie_entry.model.xidian_ids.*
import ohos_app_cangjie_entry.controller.*
import ohos_app_cangjie_entry.components.*

@Component
public class ScorePage {
    let onBack: () -> Unit
    @State var loading: Bool = false
    @State var status: String = "正在获取真实成绩…"
    @State var query: String = ""
    @State var semesterFilter: String = "所有学期"
    @State var typeFilter: String = "所有类型"
    @State var scores: ArrayList<ScoreItem> = ArrayList<ScoreItem>()
    let controller = ScoreController()

    protected override func aboutToAppear(): Unit {
        if (this.scores.size == 0 && !this.loading) { this.refresh() }
    }

    func refresh(): Unit {
        this.loading = true
        this.controller.reloadScores({ items => launch {
            this.scores = items
            this.loading = false
            this.status = if (items.size == 0) { "暂无成绩。" } else { "已加载 ${items.size} 门成绩。" }
        } }, { message => launch {
            this.loading = false
            this.status = message
        } })
    }

    func summary(): ScoreSummary { return this.controller.summarize(this.scores) }

    func semesterValues(): ArrayList<String> {
        let values = ArrayList<String>(); values.add("所有学期")
        for (item in this.scores) { if (!values.contains(item.semester)) { values.add(item.semester) } }
        return values
    }

    func typeValues(): ArrayList<String> {
        let values = ArrayList<String>(); values.add("所有类型")
        for (item in this.scores) { if (!values.contains(item.kind)) { values.add(item.kind) } }
        return values
    }

    func nextSemester(): Unit {
        let values = this.semesterValues(); var index: Int64 = 0
        while (index < values.size) {
            if (values[index] == this.semesterFilter) { this.semesterFilter = values[(index + 1) % values.size]; return }
            index += 1
        }
        this.semesterFilter = "所有学期"
    }

    func nextType(): Unit {
        let values = this.typeValues(); var index: Int64 = 0
        while (index < values.size) {
            if (values[index] == this.typeFilter) { this.typeFilter = values[(index + 1) % values.size]; return }
            index += 1
        }
        this.typeFilter = "所有类型"
    }

    func matches(item: ScoreItem): Bool {
        let queryMatched = this.query == "" || item.name.contains(this.query)
        let semesterMatched = this.semesterFilter == "所有学期" || item.semester == this.semesterFilter
        let typeMatched = this.typeFilter == "所有类型" || item.kind == this.typeFilter
        return queryMatched && semesterMatched && typeMatched
    }

    @Builder
    func refreshAction() {
        HeaderRefreshAction(onRefresh: this.refresh, actionId: "scoreRefreshButton")
    }

    @Builder
    func scoreCard(item: ScoreItem, index: Int64) {
        Column {
            Row {
                Text(item.name).fontSize(13.vp).fontWeight(FontWeight.Medium)
                    .fontColor(0xFFFFFFFF).layoutWeight(1).maxLines(1)
                Text(item.classStatus).fontSize(10.vp).fontColor(0xFFFFFFFF).maxLines(1)
            }.width(100.percent).height(36.vp).padding(left: 12.vp, right: 10.vp).backgroundColor(0xFF476FA9)
            Row {
                Text("学分: ${item.credit}").fontSize(11.vp).layoutWeight(2)
                Text("GPA: ${item.gpa()}").fontSize(11.vp).layoutWeight(2)
                Text("成绩: ${item.displayScore()}").fontSize(11.vp).layoutWeight(2)
            }.width(100.percent).padding(left: 12.vp, right: 12.vp, top: 10.vp, bottom: 10.vp)
        }.width(100.percent).margin(top: 9.vp).backgroundColor(0xFFF0F1F8)
            .borderRadius(9.vp).id("scoreCard_${index}")
    }

    func build() {
        Column {
            PageHeader(title: "成绩查询", onBack: this.onBack, backId: "scoreBack", trailing: this.refreshAction)
            TextInput(placeholder: "搜索成绩记录", text: this.query)
                .width(100.percent).height(42.vp).margin(top: 10.vp)
                .backgroundColor(0xFFF2F3F8).border(width: 1.vp, color: 0xFF476FA9).borderRadius(8.vp)
                .onChange({ value => this.query = value }).id("scoreSearchInput")
            Row {
                Button("学期 ${this.semesterFilter}").layoutWeight(1).height(36.vp).fontSize(11.vp)
                    .onClick({_ => this.nextSemester()}).id("scoreSemesterFilter")
                Button("类型 ${this.typeFilter}").layoutWeight(1).height(36.vp).fontSize(11.vp).margin(left: 8.vp)
                    .onClick({_ => this.nextType()}).id("scoreTypeFilter")
            }.width(100.percent).margin(top: 8.vp)
            if (this.scores.size > 0) {
                Text("计入 ${this.summary().count} 门 · ${this.summary().credit} 学分 · 加权均分 ${this.summary().average} · GPA ${this.summary().gpa}")
                    .fontSize(10.vp).fontColor(0xFF65738A).margin(top: 7.vp).id("scoreSummary")
            }
            if (this.loading || this.scores.size == 0) {
                Text(this.status).fontSize(11.vp).fontColor(0xFF65738A).margin(top: 7.vp).id("scoreStatus")
            }
            Scroll {
                Column {
                    ForEach(this.scores, itemGenerator: { item: ScoreItem, index: Int64 =>
                        if (this.matches(item)) { this.scoreCard(item, index) }
                    })
                    if (!this.loading && this.scores.size == 0) { Text("暂无成绩记录").margin(top: 36.vp) }
                }.width(100.percent).padding(bottom: 24.vp)
            }.width(100.percent).layoutWeight(1).align(Alignment.TopStart)
        }.width(100.percent).height(100.percent).padding(left: 16.vp, right: 16.vp, top: 12.vp, bottom: 8.vp)
            .alignItems(HorizontalAlign.Start).backgroundColor(0xFFF7F9FC)
    }
}
