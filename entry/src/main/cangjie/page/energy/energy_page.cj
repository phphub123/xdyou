package ohos_app_cangjie_entry.page.energy

import kit.ArkUI.*
import ohos.arkui.state_macro_manage.*
import std.collection.*
import std.regex.*
import std.convert.*
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
    @State var waterReadings: ArrayList<MeterReading> = ArrayList<MeterReading>()
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
            this.remain = value.electricityRemain; this.readings = value.electricityMeterList; this.waterReadings = value.waterMeterList
            this.status = "电量信息已更新"
        } }, { message => launch { this.loading = false; this.status = message } })
    }
    func reloadAircon(): Unit {
        if (this.loading) { return }; this.loading = true; this.status = "正在查询空调设备能耗…"
        this.controller.reloadAircon(this.imei, { value => launch {
            this.loading = false; this.hasAircon = true; this.airconAmount = value.electricAmount; this.status = "空调能耗已更新"
        } }, { message => launch { this.loading = false; this.status = message } })
    }
    func shortDate(value: String): String {
        let parts = Regex(" ").split(value)
        return if (parts.size > 0) { parts[0] } else { value }
    }
    func oneDecimal(value: String): String {
        try {
            let scaled = Int64(Float64.parse(value) * 10.0)
            let fraction = scaled % 10
            return "${scaled / 10}.${if (fraction < 0) { -fraction } else { fraction }}"
        } catch (_) { return value }
    }
    @Builder func headerTrailing() {
        HeaderRefreshAction(onRefresh: this.reloadEnergy, actionId: "energyRefresh")
    }
    func build() {
        Column {
            PageHeader(title: "水电信息", onBack: this.onBack, backId: "energyBack", trailing: this.headerTrailing)
            Scroll { Column {
                Text("新能源系统获取仅限校园网内访问，获取过程中有问题请向开发者报告。\n历史记录依旧为本地记录，平均日用量基于抄表记录计算。")
                    .width(100.percent).padding(12.vp).fontSize(12.vp).fontColor(0xFFE87816)
                    .backgroundColor(0xFFFFF8E8).border(width: 1.vp, color: 0xFFF2BD73).borderRadius(10.vp)
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
                if (this.hasEnergy) {
                    Column {
                        Text("💧  水费信息").width(100.percent).padding(12.vp).fontSize(16.vp).fontWeight(FontWeight.Bold)
                            .fontColor(0xFFFFFFFF).backgroundColor(0xFF46699D)
                        if (this.waterReadings.size == 0) {
                            Text("暂无水表记录").width(100.percent).padding(16.vp).fontSize(13.vp).fontColor(0xFF65738A)
                        } else {
                            Row {
                                Text("获取时间").layoutWeight(4).textAlign(TextAlign.Center).fontSize(12.vp).fontColor(0xFFFFFFFF)
                                Text("洗澡水用量").layoutWeight(3).textAlign(TextAlign.Center).fontSize(12.vp).fontColor(0xFFFFFFFF)
                                Text("本次读数").layoutWeight(3).textAlign(TextAlign.Center).fontSize(12.vp).fontColor(0xFFFFFFFF)
                                Text("上次读数").layoutWeight(3).textAlign(TextAlign.Center).fontSize(12.vp).fontColor(0xFFFFFFFF)
                            }.width(100.percent).height(40.vp).padding(left: 6.vp, right: 6.vp).backgroundColor(0xFF46699D)
                            ForEach(this.waterReadings, itemGenerator: { item: MeterReading, index: Int64 => Row {
                                Text(this.shortDate(item.readTime)).layoutWeight(4).textAlign(TextAlign.Center).fontSize(12.vp)
                                Text(this.oneDecimal(item.readNum)).layoutWeight(3).textAlign(TextAlign.Center).fontSize(12.vp)
                                Text(this.oneDecimal(item.endNum)).layoutWeight(3).textAlign(TextAlign.Center).fontSize(12.vp)
                                Text(this.oneDecimal(item.startNum)).layoutWeight(3).textAlign(TextAlign.Center).fontSize(12.vp)
                            }.width(100.percent).height(42.vp).padding(left: 6.vp, right: 6.vp)
                                .border(width: 0.vp, color: 0xFFE1E5EC).id("energyWaterReading_${index}") })
                        }
                    }.width(100.percent).margin(top: 10.vp).backgroundColor(0xFFFFFFFF).borderRadius(12.vp).clip(true).alignItems(HorizontalAlign.Start)
                }
                Text(this.status).fontSize(12.vp).fontColor(0xFF65738A).margin(top: 10.vp).id("energyStatus")
                Blank().height(20.vp)
            }.width(100.percent) }.width(100.percent).layoutWeight(1).align(Alignment.TopStart)
            ServiceAuthWeb(
                url: "https://xxcapp.xidian.edu.cn/uc/api/oauth/index?redirect=https://ignypt.xidian.edu.cn/revenueH5/login?opcode=MPAY&appid=200260318155520600&state=12312312312312&qrcode=0",
                cookieUrl: "https://ignypt.xidian.edu.cn",
                stableId: "energyAuthWeb",
                requireOpenId: false,
                requireCode: true,
                onReady: { url: String, payload: String, cookies: String => this.authUrl = url + "|" + payload; this.authCookies = cookies; this.reloadEnergy() },
                onFailure: { message: String => this.loading = false; this.status = message }
            )
        }.width(100.percent).height(100.percent).padding(18.vp).backgroundColor(0xFFF7F9FC).alignItems(HorizontalAlign.Start)
    }
}
