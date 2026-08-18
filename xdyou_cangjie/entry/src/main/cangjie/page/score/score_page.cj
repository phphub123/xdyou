package ohos_app_cangjie_entry.page.score

// 成绩查询页面，呈现课程成绩、统计摘要及认证失败边界。

import kit.ArkUI.*
import ohos.arkui.state_macro_manage.*
import std.collection.*
import ohos_app_cangjie_entry.model.score.*
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
            }.width(100.percent).height(36.vp).padding(left: 12.vp, right: 10.vp).backgroundColor(0xFF46699D)
            Row {
                Text("学分: ${item.displayCredit()}").fontSize(11.vp).layoutWeight(2)
                Text("GPA: ${item.displayGpa()}").fontSize(11.vp).layoutWeight(2)
                Text("成绩: ${item.displayScore()}").fontSize(11.vp).layoutWeight(2)
            }.width(100.percent).padding(left: 12.vp, right: 12.vp, top: 10.vp, bottom: 10.vp)
        }.width(100.percent).margin(top: 9.vp).backgroundColor(0xFFF0F1F8)
            .borderRadius(9.vp).id("scoreCard_${index}")
    }

    func build() {
        Column {
            PageHeader(title: "成绩查询", onBack: this.onBack, backId: "scoreBack", trailing: this.refreshAction)
            Column {
                PageSearchField(placeholder: "搜索成绩记录", value: this.query,
                    onChange: { value => this.query = value }, fieldId: "scoreSearchInput")
            }.width(100.percent).margin(top: 8.vp)
            Row {
                Button("学期 ${this.semesterFilter}").height(34.vp).fontSize(11.vp)
                    .padding(left: 14.vp, right: 14.vp).borderRadius(8.vp)
                    .buttonStyle(ButtonStyleMode.Normal)
                    .backgroundColor(0xFF46699D).fontColor(0xFFFFFFFF)
                    .onClick({_ => this.nextSemester()}).id("scoreSemesterFilter")
                Button("类型 ${this.typeFilter}").height(34.vp).fontSize(11.vp).margin(left: 8.vp)
                    .padding(left: 14.vp, right: 14.vp).borderRadius(8.vp)
                    .buttonStyle(ButtonStyleMode.Normal)
                    .backgroundColor(0xFF46699D).fontColor(0xFFFFFFFF)
                    .onClick({_ => this.nextType()}).id("scoreTypeFilter")
            }.width(100.percent).margin(top: 8.vp).justifyContent(FlexAlign.Start)
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
        }.width(100.percent).height(100.percent).padding(left: 14.vp, right: 14.vp, top: 8.vp, bottom: 8.vp)
            .alignItems(HorizontalAlign.Start).backgroundColor(0xFFFFFFFF)
    }
}
