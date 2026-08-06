package ohos_app_cangjie_entry.page.schoolnet

import kit.ArkUI.*
import ohos.arkui.state_macro_manage.*
import ohos_app_cangjie_entry.controller.*
import ohos_app_cangjie_entry.model.*
import ohos_app_cangjie_entry.components.*

@Component
public class SchoolnetPage {
    let onBack: () -> Unit
    @State var loading: Bool = false
    @State var status: String = "仅在校园网内可读取当前在线账号。"
    @State var loaded: Bool = false
    @State var userName: String = ""
    @State var realName: String = ""
    @State var product: String = ""
    @State var ip: String = ""
    @State var devices: String = ""
    @State var used: Int64 = 0
    @State var remain: Int64 = 0
    @State var balance: Int64 = 0
    let controller = SchoolnetController()

    protected override func aboutToAppear(): Unit { this.reload() }

    func reload(): Unit {
        this.loading = true
        this.status = "正在确认校园网并读取在线账号…"
        this.controller.reload(
            { info => launch {
                this.loading = false
                this.loaded = true
                this.userName = info.userName
                this.realName = info.realName
                this.product = info.productsName
                this.ip = info.onlineIp
                this.devices = info.onlineDeviceTotal
                this.used = info.sumBytes
                this.remain = info.remainBytes
                this.balance = info.userBalance
                this.status = "在线账号信息已更新。"
            } },
            { message => launch { this.loading = false; this.loaded = false; this.status = message } }
        )
    }

    func formatBytes(value: Int64): String {
        if (value < 1000) { return "${value} B" }
        if (value < 1000000) { return "${value / 1000} KB" }
        if (value < 1000000000) { return "${value / 1000000} MB" }
        return "${value / 1000000000} GB"
    }

    @Builder func headerTrailing() {
        Button(if (this.loading) { "刷新中" } else { "刷新" }).height(40.vp).onClick({ _ => this.reload() }).id("schoolnetRefresh")
    }

    func build() {
        Column {
            PageHeader(title: "校园网", onBack: this.onBack, backId: "schoolnetBack", trailing: this.headerTrailing)
            Text(this.status).fontSize(12.vp).fontColor(0xFF65738A).margin(top: 8.vp).id("schoolnetStatus")
            if (this.loaded) {
                Scroll {
                    Column {
                        Column {
                            Text("账号概览").fontSize(18.vp).fontWeight(FontWeight.Bold)
                            Text("账号：${this.userName}").fontSize(14.vp).margin(top: 10.vp)
                            Text("姓名：${this.realName}").fontSize(14.vp).margin(top: 6.vp)
                            Text("套餐：${this.product}").fontSize(14.vp).margin(top: 6.vp)
                            Text("余额：¥${this.balance}").fontSize(14.vp).fontColor(0xFF2D8B66).margin(top: 6.vp)
                        }.width(100.percent).padding(16.vp).margin(top: 14.vp).backgroundColor(0xFFFFFFFF).borderRadius(13.vp).alignItems(HorizontalAlign.Start)
                        Column {
                            Text("流量使用").fontSize(18.vp).fontWeight(FontWeight.Bold)
                            Text("已用：${this.formatBytes(this.used)}").fontSize(14.vp).margin(top: 10.vp)
                            Text("剩余：${this.formatBytes(this.remain)}").fontSize(14.vp).fontColor(0xFF2D8B66).margin(top: 6.vp)
                        }.width(100.percent).padding(16.vp).margin(top: 10.vp).backgroundColor(0xFFFFFFFF).borderRadius(13.vp).alignItems(HorizontalAlign.Start)
                        Column {
                            Text("在线设备").fontSize(18.vp).fontWeight(FontWeight.Bold)
                            Text("当前 IP：${this.ip}").fontSize(14.vp).margin(top: 10.vp)
                            Text("在线设备数：${this.devices}").fontSize(14.vp).margin(top: 6.vp)
                        }.width(100.percent).padding(16.vp).margin(top: 10.vp).backgroundColor(0xFFFFFFFF).borderRadius(13.vp).alignItems(HorizontalAlign.Start)
                    }.width(100.percent)
                }.width(100.percent).layoutWeight(1)
            }
        }.width(100.percent).height(100.percent).padding(18.vp).backgroundColor(0xFFF7F9FC).alignItems(HorizontalAlign.Start)
    }
}
