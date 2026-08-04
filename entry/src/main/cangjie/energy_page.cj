package ohos_app_cangjie_entry

import kit.ArkUI.*
import ohos.arkui.state_macro_manage.*
import ohos_app_cangjie_entry.controller.*
import ohos_app_cangjie_entry.model.*

@Component
public class EnergyPage {
    let onBack: () -> Unit
    @State var imei: String = ""
    @State var loading: Bool = false
    @State var status: String = "电费和水费需要真实 IDS 会话；空调能耗可使用设备 IMEI 独立查询。"
    @State var hasResult: Bool = false
    @State var resultImei: String = ""
    @State var resultAmount: String = ""
    @State var resultTime: String = ""
    let controller = EnergyController()

    func reloadAircon(): Unit {
        this.loading = true
        this.status = "正在查询空调设备能耗…"
        this.controller.reloadAircon(this.imei, { value => launch {
            this.loading = false
            this.hasResult = true
            this.resultImei = value.imei
            this.resultAmount = value.electricAmount
            this.resultTime = value.stateTime.toString()
            this.status = "空调设备状态已更新。"
        } }, { message => launch { this.loading = false; this.status = message } })
    }

    func build() {
        Column {
            Row {
                Button("‹").width(44.vp).height(40.vp).onClick({ _ => this.onBack() }).id("energyBack")
                Text("电量与能耗").fontSize(24.vp).fontWeight(FontWeight.Bold).layoutWeight(1).margin(left: 8.vp)
                Button(if (this.loading) { "查询中" } else { "查询" }).height(40.vp).onClick({ _ => this.reloadAircon() }).id("energyRefresh")
            }.width(100.percent)
            Text(this.status).fontSize(12.vp).fontColor(0xFF65738A).margin(top: 8.vp).id("energyStatus")
            Scroll { Column {
                Column {
                    Text("宿舍电费与水费").fontSize(18.vp).fontWeight(FontWeight.Bold)
                    Text("该查询仅在校园网和真实 IDS 会话可用；未满足条件时会保留真实错误，不显示演示余额。")
                        .fontSize(13.vp).fontColor(0xFF65738A).margin(top: 8.vp)
                }.width(100.percent).padding(14.vp).margin(top: 14.vp).backgroundColor(0xFFFFFFFF).borderRadius(12.vp).alignItems(HorizontalAlign.Start).id("energyCampusBoundary")
                Column {
                    Text("空调能耗").fontSize(18.vp).fontWeight(FontWeight.Bold)
                    TextInput(placeholder: "输入空调设备 IMEI", text: this.imei).width(100.percent).height(42.vp).margin(top: 10.vp)
                        .onChange({ value => this.imei = value }).id("energyImeiInput")
                    Button("使用 IMEI 查询").width(100.percent).height(40.vp).margin(top: 9.vp).onClick({ _ => this.reloadAircon() }).id("energyAirconQuery")
                    if (this.hasResult) { Column {
                        Text("设备：${this.resultImei}").fontSize(14.vp)
                        Text("累计电量：${this.resultAmount}").fontSize(16.vp).fontColor(0xFF2D8B66).margin(top: 7.vp)
                        Text("设备状态时间：${this.resultTime}").fontSize(12.vp).fontColor(0xFF65738A).margin(top: 7.vp)
                    }.width(100.percent).margin(top: 12.vp).alignItems(HorizontalAlign.Start).id("energyAirconResult")
                    } else { Text("尚未查询空调设备；IMEI 不会被持久化或写入日志。").fontSize(12.vp).fontColor(0xFF65738A).margin(top: 10.vp).id("energyAirconEmpty") }
                }.width(100.percent).padding(14.vp).margin(top: 10.vp).backgroundColor(0xFFFFFFFF).borderRadius(12.vp).alignItems(HorizontalAlign.Start).id("energyAirconCard")
                Blank().height(20.vp)
            }.width(100.percent) }.width(100.percent).layoutWeight(1).align(Alignment.TopStart)
        }.width(100.percent).height(100.percent).padding(18.vp).backgroundColor(0xFFF7F9FC).alignItems(HorizontalAlign.Start)
    }
}
