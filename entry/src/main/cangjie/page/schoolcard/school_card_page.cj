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
    @State var showDateRange: Bool = false
    @State var datePickerStep: Int64 = 0
    @State var draftBeginDate: String = ""
    @State var draftEndDate: String = ""
    var authorized: Bool = false

    protected override func aboutToAppear(): Unit {
        this.useCurrentMonth()
        this.refreshAll()
    }

    func useCurrentMonth(): Unit {
        this.beginDate = DateTime.now().format("yyyy-MM-01")
        this.endDate = DateTime.now().format("yyyy-MM-dd")
    }

    protected override func aboutToDisappear(): Unit {
        // Payment QR data must not remain referenced after leaving the page.
        this.qrData = ""
        this.showQr = false
    }

    func refreshAll(): Unit {
        if (!this.authorized) { this.loading = false; this.status = "正在完成校园卡认证…"; return }
        this.loadRecords()
    }

    func loadRecords(): Unit {
        this.loading = true
        this.status = "正在查询 ${this.beginDate} 至 ${this.endDate} 的流水…"
        this.controller.records(this.beginDate, this.endDate, {
            values => launch {
                this.records = values
                this.loading = false
                this.status = if (values.size == 0) {
                    "所选日期范围内没有校园卡流水。"
                } else {
                    "已加载 ${values.size} 条校园卡流水。"
                }
            }
        }, {
            message => launch {
                this.loading = false
                this.status = message
            }
        })
    }

    func openQr(): Unit {
        this.loading = true
        this.showQr = true
        this.qrData = ""
        this.status = "正在获取实时付款码…"
        this.controller.qrCode({
            value => launch {
                this.qrData = value
                this.loading = false
                this.status = "付款码已更新；请勿截图或转发。"
            }
        }, {
            message => launch {
                this.loading = false
                this.showQr = false
                this.qrData = ""
                this.status = message
            }
        })
    }

    func closeQr(): Unit {
        this.qrData = ""
        this.showQr = false
        this.status = "付款码已从页面内存中清除。"
    }

    func moneySummary(): String {
        var sum = 0.0
        for (record in this.records) {
            try {
                sum += Float64.parse(record.money)
            } catch (_) {
                ()
            }
        }
        return if (sum < 0.0) {
            "共支出 ${(-sum).format(".2")}元"
        } else {
            "共收入 ${sum.format(".2")}元"
        }
    }

    func dateRangeText(): String {
        return "选择日期：从 ${this.beginDate} 到 ${this.endDate}"
    }

    func parsedDate(value: String): DateTime {
        try {
            return DateTime.parse(value, "yyyy-MM-dd")
        } catch (_) {
            return DateTime.now()
        }
    }

    func openDateRange(): Unit {
        this.draftBeginDate = this.beginDate
        this.draftEndDate = this.endDate
        this.datePickerStep = 0
        this.showDateRange = true
    }

    func updateDraftDate(value: DateTime): Unit {
        if (this.datePickerStep == 0) {
            this.draftBeginDate = value.format("yyyy-MM-dd")
        } else {
            this.draftEndDate = value.format("yyyy-MM-dd")
        }
    }

    func advanceDatePicker(): Unit {
        if (this.datePickerStep == 0) {
            this.datePickerStep = 1
            return
        }
        if (this.draftBeginDate.compare(this.draftEndDate) == Ordering.GT) {
            let oldBegin = this.draftBeginDate
            this.draftBeginDate = this.draftEndDate
            this.draftEndDate = oldBegin
        }
        this.beginDate = this.draftBeginDate
        this.endDate = this.draftEndDate
        this.showDateRange = false
        this.loadRecords()
    }

    func authorizeResponse(url: String, payload: String, cookies: String): Unit {
        try {
            this.authorized = this.controller.authorizeWeb(url + "|" + payload, cookies, { message: String => this.status = message })
            if (this.authorized) { this.refreshAll() }
        } catch (error: Exception) {
            this.authorized = false
            this.loading = false
            this.status = error.message
        }
    }

    func build() {
        Stack {
            Column {
                PageHeader(
                    title: "校园卡流水信息",
                    onBack: this.onBack,
                    backId: "schoolCardBack"
                )
                Button(this.dateRangeText())
                    .width(262.vp)
                    .height(36.vp)
                    .margin(top: 12.vp, bottom: 12.vp)
                    .fontSize(12.vp)
                    .fontWeight(FontWeight.Normal)
                    .fontColor(0xFFFFFFFF)
                    .backgroundColor(0xFF46699D)
                    .borderRadius(11.vp)
                    .enabled(!this.loading)
                    .onClick({_ => this.openDateRange()})
                    .id("schoolCardDateRange")
                Row {
                    Text("商户名称").layoutWeight(3).fontSize(14.vp).textAlign(TextAlign.Center)
                    Text("金额").layoutWeight(2).fontSize(14.vp).textAlign(TextAlign.Center)
                    Text("时间(${this.moneySummary()})")
                        .layoutWeight(4)
                        .fontSize(14.vp)
                        .textAlign(TextAlign.Center)
                }.width(100.percent).height(38.vp).id("schoolCardRecordHeader")
                Divider().width(100.percent).strokeWidth(1.vp).color(0xFFE1E2E6)
                if (this.loading) {
                    Column {
                        LoadingProgress().width(34.vp).height(34.vp).color(0xFF46699D)
                        Text(this.status).fontSize(12.vp).fontColor(0xFF65738A).margin(top: 10.vp).id("schoolCardStatus")
                    }.width(100.percent).layoutWeight(1).justifyContent(FlexAlign.Center)
                } else if (this.records.size == 0) {
                    Column {
                        Text(this.status).fontSize(13.vp).fontColor(0xFF65738A).textAlign(TextAlign.Center).id("schoolCardStatus")
                        Button("重新加载").height(36.vp).margin(top: 14.vp).onClick({_ => this.loadRecords()}).id("schoolCardRetry")
                    }.width(100.percent).layoutWeight(1).justifyContent(FlexAlign.Center)
                } else {
                    Scroll {
                        Column {
                            ForEach(this.records, itemGenerator: {
                                record: PaidRecord, index: Int64 => Column {
                                    Row {
                                        Text(record.place).layoutWeight(3).fontSize(12.vp).textAlign(TextAlign.Center)
                                        Text(record.money).layoutWeight(2).fontSize(12.vp).textAlign(TextAlign.Center)
                                        Text(record.date).layoutWeight(4).fontSize(12.vp).textAlign(TextAlign.Center)
                                    }.width(100.percent).height(47.vp)
                                    Divider().width(100.percent).strokeWidth(1.vp).color(0xFFE8E9EC)
                                }.width(100.percent).id("schoolCardRecord_${index}")
                            })
                        }.width(100.percent)
                    }.width(100.percent).layoutWeight(1).align(Alignment.TopStart)
                }
            }
                .width(100.percent)
                .height(100.percent)
                .padding(left: 12.vp, right: 12.vp, top: 12.vp)
                .backgroundColor(0xFFFFFFFF)
                .alignItems(HorizontalAlign.Center)
            ServiceAuthWeb(
                url: "https://v8scan.xidian.edu.cn/home/openXDOAuth2Page",
                cookieUrl: "https://v8scan.xidian.edu.cn",
                stableId: "schoolCardAuthWeb",
                onReady: { url: String, payload: String, cookies: String => this.authorizeResponse(url, payload, cookies) },
                onFailure: { message: String => this.loading = false; this.status = message }
            )
            if (this.showQr) {
                Column {
                    Text("校园卡实时付款码").fontSize(20.vp).fontWeight(FontWeight.Bold)
                    Text("付款码属于敏感支付信息，请勿截图或转发。")
                        .fontSize(12.vp)
                        .fontColor(0xFFB54848)
                        .margin(top: 7.vp)
                        .textAlign(TextAlign.Center)
                    if (this.qrData == "") {
                        LoadingProgress().width(48.vp).height(48.vp).margin(top: 34.vp)
                    } else {
                        Image(this.qrData)
                            .width(220.vp)
                            .height(220.vp)
                            .objectFit(ImageFit.Contain)
                            .margin(top: 18.vp)
                            .id("schoolCardQrImage")
                    }
                    Row {
                        Button("关闭").layoutWeight(1).onClick({_ => this.closeQr()}).id("schoolCardQrClose")
                        Button("刷新付款码")
                            .layoutWeight(1)
                            .margin(left: 8.vp)
                            .enabled(!this.loading)
                            .onClick({_ => this.openQr()})
                            .id("schoolCardQrReload")
                    }.width(100.percent).margin(top: 22.vp)
                }
                    .width(310.vp)
                    .padding(20.vp)
                    .backgroundColor(0xFFFFFFFF)
                    .borderRadius(18.vp)
                    .align(Alignment.Center)
                    .id("schoolCardQrDialog")
            }
            if (this.showDateRange) {
                Column {
                    Text(if (this.datePickerStep == 0) { "选择开始日期" } else { "选择结束日期" })
                        .fontSize(18.vp).fontWeight(FontWeight.Bold)
                    Text(if (this.datePickerStep == 0) { this.draftBeginDate } else { this.draftEndDate })
                        .fontSize(13.vp).fontColor(0xFF65738A).margin(top: 6.vp)
                    DatePicker(selected: if (this.datePickerStep == 0) { this.parsedDate(this.draftBeginDate) } else { this.parsedDate(this.draftEndDate) })
                        .width(100.percent)
                        .height(220.vp)
                        .onDateChange({value => this.updateDraftDate(value)})
                    Row {
                        Button("取消").layoutWeight(1).height(38.vp).onClick({_ => this.showDateRange = false}).id("schoolCardDateCancel")
                        Button(if (this.datePickerStep == 0) { "下一步" } else { "确定" })
                            .layoutWeight(1).height(38.vp).margin(left: 8.vp)
                            .onClick({_ => this.advanceDatePicker()}).id("schoolCardDateConfirm")
                    }.width(100.percent).margin(top: 10.vp)
                }
                    .width(320.vp)
                    .padding(18.vp)
                    .backgroundColor(0xFFFFFFFF)
                    .borderRadius(18.vp)
                    .align(Alignment.Center)
                    .id("schoolCardDateDialog")
            }
        }.width(100.percent).height(100.percent)
    }
}
