package ohos_app_cangjie_entry.page.schoolcard

import kit.ArkUI.*
import ohos.arkui.state_macro_manage.*
import std.collection.ArrayList
import std.convert.*
import std.time.*
import ohos_app_cangjie_entry.controller.*
import ohos_app_cangjie_entry.model.xidian_ids.*
import ohos_app_cangjie_entry.components.*

@Component
public class SchoolCardPage {
    let onBack: () -> Unit
    let controller = SchoolCardController()
    @State var balance: String = "--"
    @State var beginDate: String = ""
    @State var endDate: String = ""
    @State var status: String = ""
    @State var loading: Bool = false
    @State var records: ArrayList<PaidRecord> = ArrayList<PaidRecord>()
    @State var qrData: String = ""
    @State var showQr: Bool = false

    protected override func aboutToAppear(): Unit {
        let now = DateTime.now()
        this.beginDate = now.format("yyyy-MM-01")
        this.endDate = now.format("yyyy-MM-dd")
        this.refreshAll()
    }

    protected override func aboutToDisappear(): Unit {
        // Payment QR data must not remain referenced after leaving the page.
        this.qrData = ""
        this.showQr = false
    }

    func refreshAll(): Unit {
        this.loading = true
        this.status = "正在查询校园卡余额…"
        this.controller.overview({ value => launch {
            this.balance = value.balance
            this.loading = false
            this.loadRecords()
        } }, { message => launch {
            this.loading = false
            this.status = message
        } })
    }

    func loadRecords(): Unit {
        this.loading = true
        this.status = "正在查询 ${this.beginDate} 至 ${this.endDate} 的流水…"
        this.controller.records(this.beginDate, this.endDate, { values => launch {
            this.records = values
            this.loading = false
            this.status = if (values.size == 0) { "所选日期范围内没有校园卡流水。" } else { "已加载 ${values.size} 条校园卡流水。" }
        } }, { message => launch {
            this.loading = false
            this.status = message
        } })
    }

    func openQr(): Unit {
        this.loading = true
        this.showQr = true
        this.qrData = ""
        this.status = "正在获取实时付款码…"
        this.controller.qrCode({ value => launch {
            this.qrData = value
            this.loading = false
            this.status = "付款码已更新；请勿截图或转发。"
        } }, { message => launch {
            this.loading = false
            this.showQr = false
            this.qrData = ""
            this.status = message
        } })
    }

    func closeQr(): Unit {
        this.qrData = ""
        this.showQr = false
        this.status = "付款码已从页面内存中清除。"
    }

    func moneySummary(): String {
        var sum = 0.0
        for (record in this.records) {
            try { sum += Float64.parse(record.money) } catch (_) { () }
        }
        return if (sum < 0.0) { "支出 ${(-sum).format(".2")} 元" } else { "收入 ${sum.format(".2")} 元" }
    }

    @Builder func headerTrailing() {
        Button(if (this.loading) { "刷新中" } else { "刷新" }).enabled(!this.loading).onClick({ _ => this.refreshAll() }).id("schoolCardRefresh")
    }

    func build() {
        Stack {
            Column {
                PageHeader(title: "校园卡", onBack: this.onBack, backId: "schoolCardBack", trailing: this.headerTrailing)
                Row {
                    Column {
                        Text("校园卡余额").fontSize(13.vp).fontColor(0xFF65738A)
                        Text("¥ ${this.balance}").fontSize(30.vp).fontWeight(FontWeight.Bold).margin(top: 6.vp).id("schoolCardBalance")
                    }.layoutWeight(1).alignItems(HorizontalAlign.Start)
                    Button("付款码").enabled(!this.loading).backgroundColor(0xFF46699D).fontColor(0xFFFFFFFF).onClick({ _ => this.openQr() }).id("schoolCardQrButton")
                }.width(100.percent).padding(16.vp).margin(top: 14.vp).backgroundColor(0xFFFFFFFF).borderRadius(14.vp)
                Text(this.status).width(100.percent).fontSize(12.vp).fontColor(0xFF65738A).margin(top: 9.vp).id("schoolCardStatus")
                Row {
                    TextInput(placeholder: "开始日期 yyyy-MM-dd", text: this.beginDate).layoutWeight(1).height(42.vp).onChange({ value => this.beginDate = value }).id("schoolCardBeginDate")
                    TextInput(placeholder: "结束日期 yyyy-MM-dd", text: this.endDate).layoutWeight(1).height(42.vp).margin(left: 8.vp).onChange({ value => this.endDate = value }).id("schoolCardEndDate")
                }.width(100.percent).margin(top: 12.vp)
                Button("查询流水").width(100.percent).height(42.vp).margin(top: 8.vp).enabled(!this.loading).onClick({ _ => this.loadRecords() }).id("schoolCardQueryRecords")
                Row {
                    Text("商户").layoutWeight(3).fontWeight(FontWeight.Bold).textAlign(TextAlign.Center)
                    Text("金额").layoutWeight(2).fontWeight(FontWeight.Bold).textAlign(TextAlign.Center)
                    Text("时间（${this.moneySummary()}）").layoutWeight(4).fontWeight(FontWeight.Bold).textAlign(TextAlign.Center)
                }.width(100.percent).padding(top: 12.vp, bottom: 10.vp).id("schoolCardRecordHeader")
                Scroll {
                    Column {
                        ForEach(this.records, itemGenerator: { record: PaidRecord, index: Int64 =>
                            Row {
                                Text(record.place).layoutWeight(3).fontSize(12.vp).textAlign(TextAlign.Center)
                                Text(record.money).layoutWeight(2).fontSize(12.vp).textAlign(TextAlign.Center)
                                Text(record.date).layoutWeight(4).fontSize(12.vp).textAlign(TextAlign.Center)
                            }.width(100.percent).height(52.vp).padding(top: 8.vp, bottom: 8.vp).backgroundColor(if (index % 2 == 0) { 0xFFFFFFFF } else { 0xFFF1F4F8 }).id("schoolCardRecord_${index}")
                        })
                    }.width(100.percent)
                }.width(100.percent).layoutWeight(1).align(Alignment.TopStart)
            }.width(100.percent).height(100.percent).padding(18.vp).backgroundColor(0xFFF7F9FC).alignItems(HorizontalAlign.Start)
            if (this.showQr) {
                Column {
                    Text("校园卡实时付款码").fontSize(20.vp).fontWeight(FontWeight.Bold)
                    Text("付款码属于敏感支付信息，请勿截图或转发。").fontSize(12.vp).fontColor(0xFFB54848).margin(top: 7.vp).textAlign(TextAlign.Center)
                    if (this.qrData == "") {
                        LoadingProgress().width(48.vp).height(48.vp).margin(top: 34.vp)
                    } else {
                        Image(this.qrData).width(220.vp).height(220.vp).objectFit(ImageFit.Contain).margin(top: 18.vp).id("schoolCardQrImage")
                    }
                    Row {
                        Button("关闭").layoutWeight(1).onClick({ _ => this.closeQr() }).id("schoolCardQrClose")
                        Button("刷新付款码").layoutWeight(1).margin(left: 8.vp).enabled(!this.loading).onClick({ _ => this.openQr() }).id("schoolCardQrReload")
                    }.width(100.percent).margin(top: 22.vp)
                }.width(310.vp).padding(20.vp).backgroundColor(0xFFFFFFFF).borderRadius(18.vp).align(Alignment.Center).id("schoolCardQrDialog")
            }
        }.width(100.percent).height(100.percent)
    }
}
