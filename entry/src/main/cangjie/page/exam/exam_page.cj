package ohos_app_cangjie_entry.page.exam

import kit.ArkUI.*
import ohos.arkui.state_macro_manage.*
import std.collection.ArrayList
import ohos_app_cangjie_entry.repository.xidian_ids.*
import ohos_app_cangjie_entry.model.xidian_ids.*
import ohos_app_cangjie_entry.controller.*

@Component
public class ExamPage {
    @State var loading: Bool = false
    @State var status: String = "输入学期代码后刷新真实考试安排。"
    @State var semester: String = ""
    @State var exams: ArrayList<ExamItem> = ArrayList<ExamItem>()
    let controller = ExamController()
    protected override func aboutToAppear(): Unit {
        if (this.semester == "" && !this.loading) {
            this.loading = true
            this.status = "正在获取当前学期…"
            AcademicSession().loadCurrentSemester({ code => launch {
                this.semester = code
                this.loading = false
                this.refresh()
            } }, { message => launch {
                this.loading = false
                this.status = message
            } })
        }
    }
    func refresh(): Unit {
        if (this.semester.trimAscii() == "") {
            this.status = "请先输入学期代码。"
            return
        }
        this.loading = true
        this.controller.reloadExams(this.semester, {
            items => launch {
                this.exams = items
                this.loading = false
                this.status = if (items.size == 0) {
                    "暂无考试记录。"
                } else {
                    "已从教务系统加载 ${items.size} 条考试记录。"
                }
            }
        }, {
            message => launch {
                this.loading = false
                this.status = message
            }
        })
    }
    func groups(): ExamGroups {
        return this.controller.group(this.exams)
    }
    func build() {
        Column {
            Text("考试安排").fontSize(26.vp).fontWeight(FontWeight.Bold)
            TextInput(placeholder: "学期代码", text: this.semester)
                .width(100.percent)
                .height(46.vp)
                .margin(top: 14.vp)
                .onChange({value => this.semester = value})
                .id("examSemesterInput")
            Button(if (this.loading) {
                "刷新中…"
            } else {
                "刷新考试"
            }).margin(top: 10.vp).onClick({_ => this.refresh()}).id("examRefreshButton")
            Text(this.status).fontSize(13.vp).fontColor(0xFF5F6368).margin(top: 10.vp).id("examStatus")
            Scroll {
                Column {
                    if (!this.loading && this.exams.size == 0) {
                        Text("暂无考试卡片").margin(top: 36.vp)
                    }
                    Text("已安排 · ${this.groups().upcoming.size}")
                        .fontSize(18.vp)
                        .fontWeight(FontWeight.Bold)
                        .margin(top: 18.vp)
                        .id("examUpcomingSection")
                    ForEach(this.groups().upcoming, itemGenerator: {
                        item: ExamItem, _: Int64 => Column {
                            Text(item.subject).fontSize(17.vp).fontWeight(FontWeight.Bold)
                            Text(item.time).fontSize(14.vp).margin(top: 5.vp)
                            Text("${item.kind} · ${item.room} · 座位 ${item.seat}")
                                .fontSize(12.vp)
                                .fontColor(0xFF5F6368)
                                .margin(top: 4.vp)
                        }
                            .width(100.percent)
                            .padding(14.vp)
                            .margin(top: 10.vp)
                            .backgroundColor(0xFFEAF2FF)
                            .borderRadius(12.vp)
                            .id("examUpcomingCard")
                    })
                    Text("未安排 · ${this.groups().unarranged.size}")
                        .fontSize(18.vp)
                        .fontWeight(FontWeight.Bold)
                        .margin(top: 22.vp)
                        .id("examUnarrangedSection")
                    ForEach(this.groups().unarranged, itemGenerator: {
                        item: ExamItem, _: Int64 => Column {
                            Text(item.subject).fontSize(17.vp).fontWeight(FontWeight.Bold)
                            Text(if (item.courseId == "") {
                                "考试时间、地点待安排"
                            } else {
                                "课程号 ${item.courseId} · 时间、地点待安排"
                            }).fontSize(13.vp).fontColor(0xFF7A5A20).margin(top: 5.vp)
                        }
                            .width(100.percent)
                            .padding(14.vp)
                            .margin(top: 10.vp)
                            .backgroundColor(0xFFFFF3E5)
                            .borderRadius(12.vp)
                            .id("examUnarrangedCard")
                    })
                    Text("已完成 · ${this.groups().finished.size}")
                        .fontSize(18.vp)
                        .fontWeight(FontWeight.Bold)
                        .margin(top: 22.vp)
                        .id("examFinishedSection")
                    ForEach(this.groups().finished, itemGenerator: {
                        item: ExamItem, _: Int64 => Column {
                            Text(item.subject).fontSize(17.vp).fontWeight(FontWeight.Bold)
                            Text(item.time).fontSize(14.vp).margin(top: 5.vp)
                            Text("${item.kind} · ${item.room} · 座位 ${item.seat}")
                                .fontSize(12.vp)
                                .fontColor(0xFF5F6368)
                                .margin(top: 4.vp)
                        }
                            .width(100.percent)
                            .padding(14.vp)
                            .margin(top: 10.vp)
                            .backgroundColor(0xFFF1F2F4)
                            .borderRadius(12.vp)
                            .id("examFinishedCard")
                    })
                    Blank().height(24.vp)
                }
            }.width(100.percent).layoutWeight(1).align(Alignment.TopStart)
        }.width(100.percent).height(100.percent).padding(20.vp).alignItems(HorizontalAlign.Start)
    }
}
