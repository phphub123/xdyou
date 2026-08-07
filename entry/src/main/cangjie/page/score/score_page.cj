package ohos_app_cangjie_entry.page.score

import kit.ArkUI.*
import ohos.arkui.state_macro_manage.*
import std.collection.ArrayList
import ohos_app_cangjie_entry.repository.xidian_ids.*
import ohos_app_cangjie_entry.model.xidian_ids.*
import ohos_app_cangjie_entry.controller.*

@Component
public class ScorePage {
    @State var loading: Bool = false
    @State var status: String = "刷新以获取真实成绩。"
    @State var scores: ArrayList<ScoreItem> = ArrayList<ScoreItem>()
    let controller = ScoreController()
    func refresh(): Unit {
        this.loading = true
        this.controller.reloadScores({
            items => launch {
                this.scores = items
                this.loading = false
                this.status = if (items.size == 0) {
                    "暂无成绩。"
                } else {
                    "已加载 ${items.size} 门成绩。"
                }
            }
        }, {
            message => launch {
                this.loading = false
                this.status = message
            }
        })
    }
    func summary(): ScoreSummary {
        return this.controller.summarize(this.scores)
    }
    func build() {
        Column {
            Text("成绩").fontSize(26.vp).fontWeight(FontWeight.Bold)
            Button(if (this.loading) {
                "刷新中..."
            } else {
                "刷新成绩"
            }).margin(top: 14.vp).onClick({_ => this.refresh()}).id("scoreRefreshButton")
            Text(this.status).fontSize(13.vp).fontColor(0xFF5F6368).margin(top: 10.vp).id("scoreStatus")
            if (this.scores.size > 0) {
                Text(
                    "计入 ${this.summary().count} 门 · " +
                    "${this.summary().credit} 学分 · " +
                    "加权均分 ${this.summary().average} · " +
                    "GPA ${this.summary().gpa}"
                )
                    .fontSize(12.vp)
                    .fontColor(0xFF46699D)
                    .margin(top: 8.vp)
                    .id("scoreSummary")
            }
            Scroll {
                Column {
                    if (!this.loading && this.scores.size == 0) {
                        Text("暂无成绩记录").margin(top: 36.vp)
                    }
                    ForEach(this.scores, itemGenerator: {
                        item: ScoreItem, _: Int64 => Column {
                            Text(item.name).fontSize(17.vp).fontWeight(FontWeight.Bold)
                            Text("${item.displayScore()} · ${item.credit} 学分 · ${item.semester}")
                                .fontSize(14.vp)
                                .margin(top: 5.vp)
                            Text("${item.classStatus} · ${item.kind} · ${item.scoreStatus} · GPA ${item.gpa()}")
                                .fontSize(12.vp)
                                .fontColor(0xFF5F6368)
                                .margin(top: 4.vp)
                        }
                            .width(100.percent)
                            .padding(14.vp)
                            .margin(top: 10.vp)
                            .backgroundColor(0xFFEAF7EE)
                            .borderRadius(12.vp)
                            .id("scoreCard")
                    })
                }.width(100.percent).padding(bottom: 28.vp)
            }.width(100.percent).layoutWeight(1).align(Alignment.TopStart)
        }.width(100.percent).height(100.percent).padding(20.vp).alignItems(HorizontalAlign.Start)
    }
}
