package ohos_app_cangjie_entry.page.energy

import kit.ArkUI.*
import ohos.arkui.state_macro_manage.*
import std.collection.*
import ohos_app_cangjie_entry.controller.*
import ohos_app_cangjie_entry.model.*
import ohos_app_cangjie_entry.components.*

@Component
public class EnergyPage {
    let onBack: () -> Unit
    @State var imei: String = ""
    @State var loading: Bool = false
    @State var status: String = "正在查询宿舍电量…"
    @State var hasEnergy: Bool = false
    @State var lastReadDate: String = "--"
    @State var remain: String = "--"
    @State var readings: ArrayList<MeterReading> = ArrayList<MeterReading>()
    @State var hasAircon: Bool = false
    @State var airconAmount: String = ""
    let controller = EnergyController()
    var authUrl: String = ""
    var authCookies: String = ""

    protected override func aboutToAppear(): Unit { this.reloadEnergy() }

    func reloadEnergy(): Unit {
        if (this.authUrl == "") { this.loading = false; this.status = "正在完成能源系统认证…"; return }
        if (this.loading) { return }; this.loading = true; this.status = "正在从能源系统读取真实数据…"
        this.controller.reloadEnergyAuthorized(this.authUrl, this.authCookies, { value => launch {
            this.loading = false; this.hasEnergy = true; this.lastReadDate = value.lastReadDate
            this.remain = value.electricityRemain; this.readings = value.electricityMeterList
            this.status = "电量信息已更新"
        } }, { message => launch { this.loading = false; this.status = message } })
    }
    func reloadAircon(): Unit {
        if (this.loading) { return }; this.loading = true; this.status = "正在查询空调设备能耗…"
        this.controller.reloadAircon(this.imei, { value => launch {
            this.loading = false; this.hasAircon = true; this.airconAmount = value.electricAmount; this.status = "空调能耗已更新"
        } }, { message => launch { this.loading = false; this.status = message } })
    }
    @Builder func headerTrailing() {
        Button(if (this.loading) { "刷新中" } else { "刷新" }).height(38.vp).enabled(!this.loading)
            .onClick({_ => this.reloadEnergy()}).id("energyRefresh")
    }
    func build() {
        Column {
            PageHeader(title: "水电信息", onBack: this.onBack, backId: "energyBack", trailing: this.headerTrailing)
            Scroll { Column {
                Column {
                    Row {
                        Text("电量信息").fontSize(17.vp).fontWeight(FontWeight.Bold).fontColor(0xFFFFFFFF).layoutWeight(1)
                        Text(if (this.loading) { "正在刷新" } else { "刷新" }).fontSize(13.vp).fontColor(0xFFFFFFFF)
                    }.width(100.percent).height(42.vp).padding(left: 14.vp, right: 14.vp).backgroundColor(0xFF46699D)
                    if (this.hasEnergy) {
                        Column {
                            Text("最后一次读表：${this.lastReadDate}").fontSize(12.vp).fontColor(0xFF65738A)
                            Text("${this.remain} kWh").fontSize(32.vp).fontWeight(FontWeight.Bold)
                                .fontColor(if (this.remain.startsWith("-")) { 0xFFC83E3E } else { 0xFF2D765B }).margin(top: 6.vp)
                            Text(if (this.remain.startsWith("-")) { "当前电量余额不足" } else { "当前剩余电量" })
                                .fontSize(13.vp).fontColor(0xFF65738A).margin(top: 3.vp)
                        }.width(100.percent).padding(14.vp).alignItems(HorizontalAlign.Start)
                    } else {
                        Text(this.status).width(100.percent).padding(18.vp).fontSize(13.vp).fontColor(0xFF65738A)
                    }
                }.width(100.percent).margin(top: 10.vp).backgroundColor(0xFFFFFFFF).borderRadius(12.vp).clip(true).id("energyElectricityCard")
                if (this.hasEnergy) {
                    Column {
                        Text("历史用电记录").fontSize(17.vp).fontWeight(FontWeight.Bold)
                        ForEach(this.readings, itemGenerator: { item: MeterReading, index: Int64 => Row {
                            Text(item.readTime).layoutWeight(1).fontSize(12.vp).fontColor(0xFF65738A)
                            Text("${item.readNum} kWh").fontSize(13.vp).fontColor(0xFF46699D)
                        }.width(100.percent).height(36.vp).border(width: 0.vp, color: 0xFFE1E5EC).id("energyReading_${index}") })
                    }.width(100.percent).padding(14.vp).margin(top: 10.vp).backgroundColor(0xFFFFFFFF).borderRadius(12.vp).alignItems(HorizontalAlign.Start)
                }
                Column {
                    Text("空调能耗").fontSize(17.vp).fontWeight(FontWeight.Bold)
                    TextInput(placeholder: "输入空调设备 IMEI", text: this.imei).width(100.percent).height(42.vp).margin(top: 10.vp)
                        .onChange({ value => this.imei = value }).id("energyImeiInput")
                    Button("查询空调能耗").width(100.percent).height(40.vp).margin(top: 8.vp).enabled(!this.loading)
                        .onClick({_ => this.reloadAircon()}).id("energyAirconQuery")
                    if (this.hasAircon) { Text("累计电量：${this.airconAmount}").fontSize(14.vp).fontColor(0xFF2D765B).margin(top: 10.vp) }
                }.width(100.percent).padding(14.vp).margin(top: 10.vp).backgroundColor(0xFFFFFFFF).borderRadius(12.vp).alignItems(HorizontalAlign.Start)
                Text(this.status).fontSize(12.vp).fontColor(0xFF65738A).margin(top: 10.vp).id("energyStatus")
                Blank().height(20.vp)
            }.width(100.percent) }.width(100.percent).layoutWeight(1).align(Alignment.TopStart)
            ServiceAuthWeb(
                url: "https://xxcapp.xidian.edu.cn/uc/api/oauth/index?redirect=https://ignypt.xidian.edu.cn/revenueH5/login?opcode=MPAY%26appid=200260318155520600%26state=12312312312312%26qrcode=0",
                cookieUrl: "https://ignypt.xidian.edu.cn",
                stableId: "energyAuthWeb",
                onReady: { url: String, payload: String, cookies: String => this.authUrl = url; this.authCookies = cookies; this.reloadEnergy() },
                onFailure: { message: String => this.loading = false; this.status = message }
            )
        }.width(100.percent).height(100.percent).padding(18.vp).backgroundColor(0xFFF7F9FC).alignItems(HorizontalAlign.Start)
    }
}