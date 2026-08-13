package ohos_app_cangjie_entry.page.sport

import kit.ArkUI.*
import ohos.arkui.state_macro_manage.*
import std.collection.ArrayList
import ohos_app_cangjie_entry.controller.*
import ohos_app_cangjie_entry.model.xidian_sport.*
import ohos_app_cangjie_entry.components.*

@Component
public class SportPage {
    let onBack: () -> Unit
    @State var account: String = ""
    @State var password: String = ""
    @State var passwordVisible: Bool = false
    @State var selectedTab: Int64 = 0
    @State var loading: Bool = false
    @State var status: String = "体育系统使用独立密码；未保存密码时请在下方输入。"
    @State var score: SportScore = SportScore()
    @State var scoreLoaded: Bool = false
    @State var classes: ArrayList<SportClassItem> = ArrayList<SportClassItem>()
    @State var hasStoredCredential: Bool = false
    let controller: SportController = SportController()

    protected override func aboutToAppear(): Unit {
        if (this.account == "") {
            this.account = this.controller.storedAccount()
        }
        this.hasStoredCredential = this.controller.hasStoredCredential()
    }

    func reload(): Unit {
        this.loading = true
        this.status = if (this.selectedTab == 0) {
            "正在登录体育系统并读取体测成绩…"
        } else {
            "正在登录体育系统并读取体育课信息…"
        }
        if (this.selectedTab == 0) {
            this.controller.reloadScore(this.account, this.password, {
                value => launch {
                    this.loading = false
                    this.score = value
                    this.scoreLoaded = true
                    this.password = ""
                    this.hasStoredCredential = true
                    this.status = "已加载 ${value.years.size} 个年度的体测成绩。"
                }
            }, {
                message => launch {
                this.loading = false
            this.status = message
            }
            })
        } else {
            this.controller.reloadClasses(this.account, this.password, {
                values => launch {
                    this.loading = false
                    this.classes = values
                    this.password = ""
                    this.hasStoredCredential = true
                    this.status = if (values.size == 0) {
                        "体育系统未返回课程记录。"
                    } else {
                        "已加载 ${values.size} 条体育课记录。"
                    }
                }
            }, {
                message => launch {
                this.loading = false
            this.status = message
            }
            })
        }
    }

    func clearCredential(): Unit {
        this.controller.clearCredential();
        this.password = ""
        this.hasStoredCredential = false
        this.status = "已清除本机保存的体育密码。"
    }

    @Builder
    func headerTrailing() {
        HeaderRefreshAction(onRefresh: this.reload, actionId: "sportRefresh")
    }

    func build() {
        Column {
            PageHeader(title: "体育信息", onBack: this.onBack, backId: "sportBack", trailing: this.headerTrailing)
            Text(this.status).fontSize(12.vp).fontColor(0xFF65738A).margin(top: 8.vp).id("sportStatus")
            Column {
                TextInput(placeholder: "学号", text: this.account)
                    .width(100.percent)
                    .height(42.vp)
                    .onChange({value => this.account = value})
                    .id("sportAccountInput")
                Row {
                    Stack {
                        TextInput(placeholder: if (this.passwordVisible) {
                            "体育系统独立密码"
                        } else {
                            ""
                        }, text: this.password)
                            .width(100.percent)
                            .height(40.vp)
                            .opacity(if (this.passwordVisible) {
                                1.0
                            } else {
                                0.0
                            })
                            .selectionMenuHidden(!this.passwordVisible)
                            .onChange({value => this.password = value})
                            .id("sportPasswordInput")
                        if (!this.passwordVisible) {
                            Text(if (this.password == "") {
                                if (this.hasStoredCredential) {
                                    "已安全保存密码；留空可直接刷新"
                                } else {
                                    "体育系统独立密码"
                                }
                            } else {
                                "********"
                            })
                                .width(100.percent)
                                .height(40.vp)
                                .fontSize(13.vp)
                                .fontColor(0xFF667085)
                                .onClick({_ => FocusControl.requestFocus("sportPasswordInput")})
                                .id("sportPasswordMask")
                        }
                    }.layoutWeight(1).height(40.vp)
                    Text(if (this.passwordVisible) {
                        "隐藏"
                    } else {
                        "查看"
                    })
                        .width(44.vp)
                        .fontSize(12.vp)
                        .fontColor(0xFF41699F)
                        .onClick({_ => this.passwordVisible = !this.passwordVisible})
                        .id("sportPasswordToggle")
                }.width(100.percent).height(42.vp).margin(top: 8.vp)
                if (this.hasStoredCredential) {
                    Button("清除保存的体育密码")
                        .height(34.vp)
                        .margin(top: 7.vp)
                        .fontSize(12.vp)
                        .onClick({_ => this.clearCredential()})
                        .id("sportClearCredential")
                }
            }
                .width(100.percent)
                .padding(12.vp)
                .margin(top: 12.vp)
                .backgroundColor(0xFFFFFFFF)
                .borderRadius(12.vp)
                .alignItems(HorizontalAlign.Start)
                .id("sportCredentialCard")
            Row {
                Button("体测成绩")
                    .layoutWeight(1)
                    .height(38.vp)
                    .backgroundColor(if (this.selectedTab == 0) {
                        0xFF476FA9
                    } else {
                        0xFFE8EDF6
                    })
                    .fontColor(if (this.selectedTab == 0) {
                        0xFFFFFFFF
                    } else {
                        0xFF41699F
                    })
                    .onClick({_ => this.selectedTab = 0})
                    .id("sportScoreTab")
                Button("体育课")
                    .layoutWeight(1)
                    .height(38.vp)
                    .margin(left: 8.vp)
                    .backgroundColor(if (this.selectedTab == 1) {
                        0xFF476FA9
                    } else {
                        0xFFE8EDF6
                    })
                    .fontColor(if (this.selectedTab == 1) {
                        0xFFFFFFFF
                    } else {
                        0xFF41699F
                    })
                    .onClick({_ => this.selectedTab = 1})
                    .id("sportClassTab")
            }.width(100.percent).margin(top: 12.vp)
            Scroll {
                Column {
                    if (this.selectedTab == 0) {
                        this.scoreContent()
                    } else {
                        this.classContent()
                    }
                    Blank().height(20.vp)
                }.width(100.percent)
            }.width(100.percent).layoutWeight(1).margin(top: 4.vp)
        }
            .width(100.percent)
            .height(100.percent)
            .padding(18.vp)
            .backgroundColor(0xFFF7F9FC)
            .alignItems(HorizontalAlign.Start)
    }

    @Builder
    func scoreContent() {
        if (this.scoreLoaded) {
            Column {
                Column {
                    Text("综合体测成绩").fontSize(18.vp).fontWeight(FontWeight.Bold)
                    Row {
                        Text("总分 ${this.score.total}")
                        .layoutWeight(1)
                        .fontSize(16.vp)
                        .fontColor(if (this.score.isQualified()) {
                            0xFF2D8B66
                        } else {
                            0xFFC64545
                        });
                    Text(this.score.rank).fontSize(14.vp)
                    }.width(100.percent).margin(top: 9.vp)
                    if (this.score.detail != "") {
                        Text(this.score.detail).fontSize(12.vp).fontColor(0xFF65738A).margin(top: 6.vp)
                    }
                }
                    .width(100.percent)
                    .padding(14.vp)
                    .margin(top: 8.vp)
                    .backgroundColor(0xFFFFFFFF)
                    .borderRadius(12.vp)
                    .alignItems(HorizontalAlign.Start)
                    .id("sportScoreSummary")
                ForEach(this.score.years, itemGenerator: {
                    year: SportScoreOfYear, index: Int64 => Column {
                        Row {
                            Text("${year.year} ${year.gradeType}")
                            .fontSize(17.vp)
                            .fontWeight(FontWeight.Bold)
                            .layoutWeight(1);
                        Text(year.totalScore).fontSize(16.vp).fontColor(0xFF41699F)
                        }.width(100.percent)
                        if (year.details.size == 0) {
                            Text(if (year.moreInfo == "") {
                                "没有体测明细。"
                            } else {
                                year.moreInfo
                            }).fontSize(12.vp).fontColor(0xFF65738A).margin(top: 8.vp)
                        }
                        ForEach(year.details,
                            itemGenerator: {
                                item: SportItem, _: Int64 => Row {
                                Text(item.examName).layoutWeight(2).fontSize(13.vp);
                            Text("${item.actualScore}${item.examUnit}").layoutWeight(2).fontSize(12.vp);
                            Text(item.score.toString())
                                .layoutWeight(1)
                                .fontSize(13.vp)
                                .fontColor(if (item.score >= 60.0) {
                                    0xFF2D8B66
                                } else {
                                    0xFFC64545
                                })
                            }.width(100.percent).margin(top: 7.vp)
                            })
                    }
                        .width(100.percent)
                        .padding(14.vp)
                        .margin(top: 9.vp)
                        .backgroundColor(0xFFFFFFFF)
                        .borderRadius(12.vp)
                        .alignItems(HorizontalAlign.Start)
                        .id("sportScoreYear_${index}")
                })
            }.width(100.percent)
        } else {
            Text("输入体育系统独立密码后点击刷新。不会使用演示成绩。")
                .fontSize(13.vp)
                .fontColor(0xFF65738A)
                .margin(top: 18.vp)
                .id("sportScoreEmpty")
        }
    }
    @Builder
    func classContent() {
        if (this.classes.size == 0) {
            Text("尚未加载体育课信息。不会用空数组冒充成功。")
                .fontSize(13.vp)
                .fontColor(0xFF65738A)
                .margin(top: 18.vp)
                .id("sportClassEmpty")
        }
        ForEach(this.classes, itemGenerator: {
            item: SportClassItem, index: Int64 => Column {
                Row {
                    Text(item.termName).fontSize(16.vp).fontWeight(FontWeight.Bold).layoutWeight(1);
                if (item.score != "") {
                    Text(item.score).fontSize(15.vp).fontColor(0xFF41699F)
                }
                }.width(100.percent)
                Text(if (item.name == "") {
                    item.classType
                } else {
                    item.name
                }).fontSize(14.vp).margin(top: 8.vp)
                Text("${item.time} · ${item.place}").fontSize(12.vp).fontColor(0xFF65738A).margin(top: 6.vp)
                Text("教师：${item.teacher}").fontSize(12.vp).fontColor(0xFF65738A).margin(top: 4.vp)
            }
                .width(100.percent)
                .padding(14.vp)
                .margin(top: 9.vp)
                .backgroundColor(0xFFFFFFFF)
                .borderRadius(12.vp)
                .alignItems(HorizontalAlign.Start)
                .id("sportClass_${index}")
        })
    }
}
