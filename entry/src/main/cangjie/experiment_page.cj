package ohos_app_cangjie_entry

import kit.ArkUI.*
import ohos.arkui.state_macro_manage.*
import std.collection.ArrayList
import std.time.*
import ohos_app_cangjie_entry.controller.*
import ohos_app_cangjie_entry.model.xidian_ids.*

@Component
public class ExperimentPage {
    let onBack: () -> Unit
    @State var account: String = ""
    @State var password: String = ""
    @State var passwordVisible: Bool = false
    @State var loading: Bool = false
    @State var status: String = "物理实验需要独立密码；其他实验需要真实 IDS 会话和校园网。"
    @State var selectedType: Int64 = 0
    @State var selectedGroup: Int64 = 1
    @State var physicsValues: ArrayList<ExperimentData> = ArrayList<ExperimentData>()
    @State var otherValues: ArrayList<ExperimentData> = ArrayList<ExperimentData>()
    @State var hasStoredCredential: Bool = false
    let controller = ExperimentController()

    protected override func aboutToAppear(): Unit { this.account=this.controller.storedAccount(); this.hasStoredCredential=this.controller.hasStoredCredential() }
    func reload(): Unit {
        if (this.selectedType == 1) {
            this.loading=true; this.status="正在使用真实 IDS 会话登录其他实验系统并读取 25 周课表…"
            this.controller.reloadOther({ rows => launch { this.loading=false; this.otherValues=rows; this.status=if(rows.size==0){"其他实验系统未返回本学期安排。"}else{"已加载 ${rows.size} 组其他实验安排。"} } }, { message => launch { this.loading=false; this.status=message } })
            return
        }
        this.loading=true; this.status="正在登录物理实验系统，并读取安排与成绩图片…"
        this.controller.reloadPhysics(this.account,this.password,{ rows => launch {
            this.loading=false; this.physicsValues=rows; this.password=""; this.hasStoredCredential=true
            this.status=if(rows.size==0){"物理实验系统未返回本学期安排。"}else{"已加载 ${rows.size} 条物理实验安排。"}
        }},{ message => launch { this.loading=false; this.status=message } })
    }
    func clearCredential(): Unit { this.controller.clearCredential(); this.password=""; this.hasStoredCredential=false; this.status="已清除本机保存的物理实验密码。" }
    func activeValues(): ArrayList<ExperimentData> { return if(this.selectedType==0){this.physicsValues}else{this.otherValues} }
    func groupValues(): ArrayList<ExperimentData> {
        let result=ArrayList<ExperimentData>(); let now=DateTime.now()
        for (item in this.activeValues()) {
            var include=false
            for (range in item.timeRanges) {
                if (this.selectedGroup==0 && range.startAt <= now && now <= range.endAt) { include=true }
                else if (this.selectedGroup==1 && now < range.startAt) { include=true }
                else if (this.selectedGroup==2 && range.endAt < now) { include=true }
            }
            if(include){result.add(item)}
        }
        return result
    }
    func build() {
        Column {
            Row { Button("‹").width(44.vp).height(40.vp).onClick({_=>this.onBack()}).id("experimentBack"); Text("实验信息").fontSize(24.vp).fontWeight(FontWeight.Bold).layoutWeight(1).margin(left:8.vp); Button(if(this.loading){"加载中"}else{"刷新"}).height(40.vp).onClick({_=>this.reload()}).id("experimentRefresh") }.width(100.percent)
            Text(this.status).fontSize(12.vp).fontColor(0xFF65738A).margin(top:8.vp).id("experimentStatus")
            Row {
                Button("物理实验").layoutWeight(1).height(38.vp).backgroundColor(if(this.selectedType==0){0xFF476FA9}else{0xFFE8EDF6}).fontColor(if(this.selectedType==0){0xFFFFFFFF}else{0xFF41699F}).onClick({_=>this.selectedType=0}).id("experimentPhysicsTab")
                Button("其他实验").layoutWeight(1).height(38.vp).margin(left:8.vp).backgroundColor(if(this.selectedType==1){0xFF476FA9}else{0xFFE8EDF6}).fontColor(if(this.selectedType==1){0xFFFFFFFF}else{0xFF41699F}).onClick({_=>this.selectedType=1;this.status="点击刷新将使用真实 IDS 会话请求其他实验。"}).id("experimentOtherTab")
            }.width(100.percent).margin(top:12.vp)
            if(this.selectedType==0) {
                Column {
                    TextInput(placeholder:"学号",text:this.account).width(100.percent).height(42.vp).onChange({value=>this.account=value}).id("experimentAccountInput")
                    Row { Stack {
                        TextInput(placeholder:if(this.passwordVisible){"物理实验系统独立密码"}else{""},text:this.password).width(100.percent).height(40.vp).opacity(if(this.passwordVisible){1.0}else{0.0}).selectionMenuHidden(!this.passwordVisible).onChange({value=>this.password=value}).id("experimentPasswordInput")
                        if(!this.passwordVisible){Text(if(this.password==""){if(this.hasStoredCredential){"已安全保存密码；留空可直接刷新"}else{"物理实验系统独立密码"}}else{"********"}).width(100.percent).height(40.vp).fontSize(13.vp).fontColor(0xFF667085).onClick({_=>FocusControl.requestFocus("experimentPasswordInput")}).id("experimentPasswordMask")}
                    }.layoutWeight(1).height(40.vp); Text(if(this.passwordVisible){"隐藏"}else{"查看"}).width(44.vp).fontSize(12.vp).fontColor(0xFF41699F).onClick({_=>this.passwordVisible=!this.passwordVisible}).id("experimentPasswordToggle") }.width(100.percent).height(42.vp).margin(top:8.vp)
                    if(this.hasStoredCredential){Button("清除保存的实验密码").height(34.vp).margin(top:7.vp).fontSize(12.vp).onClick({_=>this.clearCredential()}).id("experimentClearCredential")}
                }.width(100.percent).padding(12.vp).margin(top:10.vp).backgroundColor(0xFFFFFFFF).borderRadius(12.vp).alignItems(HorizontalAlign.Start).id("experimentCredentialCard")
            }
            Row {
                Button("进行中").layoutWeight(1).height(34.vp).backgroundColor(if(this.selectedGroup==0){0xFF476FA9}else{0xFFE8EDF6}).fontColor(if(this.selectedGroup==0){0xFFFFFFFF}else{0xFF41699F}).onClick({_=>this.selectedGroup=0}).id("experimentDoingTab")
                Button("未完成").layoutWeight(1).height(34.vp).margin(left:6.vp).backgroundColor(if(this.selectedGroup==1){0xFF476FA9}else{0xFFE8EDF6}).fontColor(if(this.selectedGroup==1){0xFFFFFFFF}else{0xFF41699F}).onClick({_=>this.selectedGroup=1}).id("experimentUpcomingTab")
                Button("已完成").layoutWeight(1).height(34.vp).margin(left:6.vp).backgroundColor(if(this.selectedGroup==2){0xFF476FA9}else{0xFFE8EDF6}).fontColor(if(this.selectedGroup==2){0xFFFFFFFF}else{0xFF41699F}).onClick({_=>this.selectedGroup=2}).id("experimentFinishedTab")
            }.width(100.percent).margin(top:10.vp)
            Scroll { Column {
                if(this.groupValues().size==0){Text(if(this.selectedType==1){"其他实验需要真实 IDS 会话和校园网；点击刷新会执行真实 OAuth 与 25 周课表请求。"}else{"当前分组暂无实验记录。刷新会请求真实服务，不展示演示数据。"}).fontSize(13.vp).fontColor(0xFF65738A).margin(top:22.vp).id(if(this.selectedType==1){"experimentOtherBlocked"}else{"experimentEmpty"})}
                else { ForEach(this.groupValues(),itemGenerator:{item:ExperimentData,index:Int64=>this.experimentCard(item,index)}) }
                Blank().height(20.vp)
            }.width(100.percent) }.width(100.percent).layoutWeight(1).margin(top:5.vp)
        }.width(100.percent).height(100.percent).padding(18.vp).backgroundColor(0xFFF7F9FC).alignItems(HorizontalAlign.Start)
    }
    func scoreText(item: ExperimentData): String { let value=item.score.getOrThrow(); return if(value.found){"成绩 ${value.label}"}else{"未识别；保留原始成绩图"} }
    @Builder func experimentCard(item:ExperimentData,index:Int64) {
        Column {
            Row { Text(item.name).fontSize(17.vp).fontWeight(FontWeight.Bold).layoutWeight(1); if(item.score.isSome()){Text(this.scoreText(item)).fontSize(12.vp).fontColor(0xFF41699F).id("experimentScore_${index}")} }.width(100.percent)
            ForEach(item.timeRanges,itemGenerator:{range:ExperimentTimeRange,_:Int64=>Text("${range.startAt.toString()} ～ ${range.endAt.toString()}").fontSize(12.vp).fontColor(0xFF65738A).margin(top:7.vp)})
            Text("地点 ${item.classroom}    教师 ${item.teacher}").fontSize(12.vp).margin(top:7.vp)
            if(item.reference!=""){Text("参考资料 ${item.reference}").fontSize(12.vp).fontColor(0xFF65738A).margin(top:5.vp)}
        }.width(100.percent).padding(14.vp).margin(top:9.vp).backgroundColor(0xFFFFFFFF).borderRadius(12.vp).alignItems(HorizontalAlign.Start).id("experimentCard_${index}")
    }
}
