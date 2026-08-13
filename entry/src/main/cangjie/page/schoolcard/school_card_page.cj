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
    @State var calendarYear: Int64 = 0
    @State var calendarMonth: Int64 = 0
    @State var calendarSelector: Int64 = 0
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

    func openDateRange(): Unit {
        this.draftBeginDate = this.beginDate
        this.draftEndDate = this.endDate
        this.datePickerStep = 0
        let parts = this.beginDate.split("-")
        try {
            this.calendarYear = Int64.parse(parts[0])
            this.calendarMonth = Int64.parse(parts[1])
        } catch (_) {
            this.calendarYear = DateTime.now().year
            this.calendarMonth = Int64.parse(DateTime.now().format("MM"))
        }
        this.calendarSelector = 0
        this.showDateRange = true
    }

    func padded(value: Int64): String {
        return if (value < 10) { "0${value}" } else { value.toString() }
    }

    func calendarDate(day: Int64): String {
        return "${this.calendarYear}-${this.padded(this.calendarMonth)}-${this.padded(day)}"
    }

    func monthName(): String {
        let names: Array<String> = ["Jan", "Feb", "Mar", "Apr", "May", "Jun", "Jul", "Aug", "Sep", "Oct", "Nov", "Dec"]
        if (this.calendarMonth < 1 || this.calendarMonth > 12) { return "" }
        return names[this.calendarMonth - 1]
    }

    func draftMonth(): Int64 {
        let parts = this.draftBeginDate.split("-")
        try { return Int64.parse(parts[1]) } catch (_) { return 0 }
    }

    func draftYear(): Int64 {
        let parts = this.draftBeginDate.split("-")
        try { return Int64.parse(parts[0]) } catch (_) { return 0 }
    }

    func selectableYears(): ArrayList<Int64> {
        let years = ArrayList<Int64>()
        let first = this.calendarYear - 5
        for (offset in 0..12) { years.add(first + offset) }
        return years
    }

    func showMonthSelector(): Unit {
        this.calendarSelector = if (this.calendarSelector == 1) { 0 } else { 1 }
    }

    func showYearSelector(): Unit {
        this.calendarSelector = if (this.calendarSelector == 2) { 0 } else { 2 }
    }

    func selectMonth(month: Int64): Unit {
        this.calendarMonth = month
        this.calendarSelector = 0
    }

    func selectYear(year: Int64): Unit {
        this.calendarYear = year
        this.calendarSelector = 0
    }

    func daysInMonth(): Int64 {
        if (this.calendarMonth == 2) {
            return if (this.calendarYear % 400 == 0 || (this.calendarYear % 4 == 0 && this.calendarYear % 100 != 0)) { 29 } else { 28 }
        }
        return if (this.calendarMonth == 4 || this.calendarMonth == 6 || this.calendarMonth == 9 || this.calendarMonth == 11) { 30 } else { 31 }
    }

    func firstWeekday(): Int64 {
        try {
            let first = DateTime.parse("${this.calendarYear}-${this.padded(this.calendarMonth)}-01", "yyyy-MM-dd")
            return match (first.dayOfWeek) {
                case Sunday => 0
                case Monday => 1
                case Tuesday => 2
                case Wednesday => 3
                case Thursday => 4
                case Friday => 5
                case Saturday => 6
            }
        } catch (_) {
            return 0
        }
    }

    func calendarCells(): ArrayList<Int64> {
        let cells = ArrayList<Int64>()
        let offset = this.firstWeekday()
        for (index in 0..42) {
            let day = index - offset + 1
            cells.add(if (day >= 1 && day <= this.daysInMonth()) { day } else { 0 })
        }
        return cells
    }

    func changeMonth(delta: Int64): Unit {
        this.calendarMonth += delta
        if (this.calendarMonth < 1) { this.calendarMonth = 12; this.calendarYear -= 1 }
        if (this.calendarMonth > 12) { this.calendarMonth = 1; this.calendarYear += 1 }
    }

    func chooseDay(day: Int64): Unit {
        if (day == 0) { return }
        let chosen = this.calendarDate(day)
        if (this.datePickerStep == 0) {
            this.draftBeginDate = chosen
            this.draftEndDate = chosen
            this.datePickerStep = 1
        } else {
            if (chosen.compare(this.draftBeginDate) == Ordering.LT) {
                this.draftEndDate = this.draftBeginDate
                this.draftBeginDate = chosen
            } else {
                this.draftEndDate = chosen
            }
            this.datePickerStep = 0
        }
    }

    func isRangeDay(day: Int64): Bool {
        if (day == 0) { return false }
        let date = this.calendarDate(day)
        return date.compare(this.draftBeginDate) != Ordering.LT && date.compare(this.draftEndDate) != Ordering.GT
    }

    func isRangeEdge(day: Int64): Bool {
        if (day == 0) { return false }
        let date = this.calendarDate(day)
        return date == this.draftBeginDate || date == this.draftEndDate
    }

    func confirmDateRange(): Unit {
        this.beginDate = this.draftBeginDate
        this.endDate = this.draftEndDate
        this.showDateRange = false
        this.loadRecords()
    }

    @Builder
    func weekdayHeader() {
        Row {
            ForEach(["S", "M", "T", "W", "T", "F", "S"], itemGenerator: { label: String, _: Int64 =>
                Text(label).layoutWeight(1).fontSize(10.vp).fontColor(0xFF50545D).textAlign(TextAlign.Center)
            })
        }.width(100.percent).height(28.vp)
    }

    @Builder
    func calendarDay(day: Int64, index: Int64) {
        GridItem {
            Stack {
                Text("")
                    .width(100.percent)
                    .height(34.vp)
                    .backgroundColor(if (this.isRangeDay(day)) { 0xFFDDE3F0 } else { Color.Transparent })
                Text(if (day == 0) { "" } else { day.toString() })
                    .width(34.vp)
                    .height(34.vp)
                    .fontSize(10.vp)
                    .fontColor(if (this.isRangeEdge(day)) { 0xFFFFFFFF } else { 0xFF252932 })
                    .textAlign(TextAlign.Center)
                    .backgroundColor(if (this.isRangeEdge(day)) { 0xFF46699D } else { Color.Transparent })
                    .borderRadius(17.vp)
            }.width(100.percent).height(34.vp).align(Alignment.Center)
        }.onClick({_ => this.chooseDay(day)}).id("schoolCardCalendarDay_${index}")
    }

    @Builder
    func dropdownHeader(title: String, opened: Bool, stableId: String, action: () -> Unit) {
        Button {
            Row {
                Text(title).fontSize(12.vp).fontColor(0xFF4C5059)
                Text(if (opened) { "▴" } else { "▾" })
                    .width(14.vp)
                    .height(20.vp)
                    .fontSize(14.vp)
                    .fontWeight(FontWeight.Medium)
                    .fontColor(0xFF4F535D)
                    .textAlign(TextAlign.Center)
                    .margin(left: 1.vp)
            }.height(36.vp)
        }
            .height(36.vp)
            .padding(left: 4.vp, right: 4.vp)
            .buttonStyle(ButtonStyleMode.Textual)
            .backgroundColor(Color.Transparent)
            .onClick({_ => action()})
            .id(stableId)
    }

    @Builder
    func monthOption(label: String, index: Int64) {
        GridItem {
            Text(label)
                .width(62.vp)
                .height(32.vp)
                .fontSize(12.vp)
                .fontColor(if (this.calendarMonth == index + 1) { 0xFFFFFFFF } else { 0xFF30343C })
                .textAlign(TextAlign.Center)
                .backgroundColor(if (this.calendarMonth == index + 1) { 0xFF46699D } else { Color.Transparent })
                .border(width: if (this.calendarMonth != index + 1 && this.draftMonth() == index + 1) { 1.vp } else { 0.vp }, color: 0xFF46699D)
                .borderRadius(17.vp)
        }.onClick({_ => this.selectMonth(index + 1)}).id("schoolCardMonthOption_${index + 1}")
    }

    @Builder
    func yearOption(year: Int64, index: Int64) {
        GridItem {
            Text(year.toString())
                .width(72.vp)
                .height(32.vp)
                .fontSize(12.vp)
                .fontColor(if (this.calendarYear == year) { 0xFFFFFFFF } else { 0xFF30343C })
                .textAlign(TextAlign.Center)
                .backgroundColor(if (this.calendarYear == year) { 0xFF46699D } else { Color.Transparent })
                .border(width: if (this.calendarYear != year && this.draftYear() == year) { 1.vp } else { 0.vp }, color: 0xFF46699D)
                .borderRadius(17.vp)
        }.onClick({_ => this.selectYear(year)}).id("schoolCardYearOption_${index}")
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
                Column {}.width(100.percent).height(100.percent).backgroundColor(0x88000000)
                    .onClick({_ => this.showDateRange = false}).id("schoolCardDateScrim")
                Column {
                    Row {
                        this.dropdownHeader(this.monthName(), this.calendarSelector == 1, "schoolCardMonthDropdown", {=> this.showMonthSelector()})
                        this.dropdownHeader(this.calendarYear.toString(), this.calendarSelector == 2, "schoolCardYearDropdown", {=> this.showYearSelector()})
                        Blank().layoutWeight(1)
                        if (this.calendarSelector == 0) {
                            Button("‹").width(38.vp).height(38.vp).fontSize(23.vp).fontColor(0xFF30343C)
                                .buttonStyle(ButtonStyleMode.Textual).backgroundColor(Color.Transparent)
                                .onClick({_ => this.changeMonth(-1)}).id("schoolCardCalendarPrevious")
                            Button("›").width(38.vp).height(38.vp).fontSize(23.vp).fontColor(0xFF30343C)
                                .buttonStyle(ButtonStyleMode.Textual).backgroundColor(Color.Transparent)
                                .onClick({_ => this.changeMonth(1)}).id("schoolCardCalendarNext")
                        }
                    }.width(100.percent).height(46.vp)
                    Divider().width(100.percent).strokeWidth(if (this.calendarSelector == 0) { 0.vp } else { 1.vp }).color(0xFFE1E2EA)
                    if (this.calendarSelector == 1) {
                        Grid {
                            ForEach(["Jan", "Feb", "Mar", "Apr", "May", "Jun", "Jul", "Aug", "Sep", "Oct", "Nov", "Dec"], itemGenerator: { label: String, index: Int64 => this.monthOption(label, index) })
                        }
                            .width(100.percent)
                            .height(204.vp)
                            .padding(top: 10.vp, bottom: 10.vp)
                            .columnsTemplate("1fr 1fr 1fr")
                            .rowsTemplate("1fr 1fr 1fr 1fr")
                            .id("schoolCardMonthGrid")
                    } else if (this.calendarSelector == 2) {
                        Grid {
                            ForEach(this.selectableYears(), itemGenerator: { year: Int64, index: Int64 => this.yearOption(year, index) })
                        }
                            .width(100.percent)
                            .height(204.vp)
                            .padding(top: 10.vp, bottom: 10.vp)
                            .columnsTemplate("1fr 1fr 1fr")
                            .rowsTemplate("1fr 1fr 1fr 1fr")
                            .id("schoolCardYearGrid")
                    } else {
                        this.weekdayHeader()
                        Grid {
                            ForEach(this.calendarCells(), itemGenerator: { day: Int64, index: Int64 => this.calendarDay(day, index) })
                        }
                            .width(100.percent)
                            .height(204.vp)
                            .columnsTemplate("1fr 1fr 1fr 1fr 1fr 1fr 1fr")
                            .rowsTemplate("1fr 1fr 1fr 1fr 1fr 1fr")
                    }
                    Blank().layoutWeight(1)
                    Row {
                        Blank().layoutWeight(1)
                        Button("CANCEL").height(38.vp).fontSize(12.vp).fontColor(0xFF34558F)
                            .buttonStyle(ButtonStyleMode.Textual).backgroundColor(Color.Transparent)
                            .onClick({_ => this.showDateRange = false}).id("schoolCardDateCancel")
                        Button("OK").height(38.vp).fontSize(12.vp).fontColor(0xFF34558F)
                            .buttonStyle(ButtonStyleMode.Textual).backgroundColor(Color.Transparent)
                            .onClick({_ => this.confirmDateRange()}).id("schoolCardDateConfirm")
                    }.width(100.percent).height(44.vp)
                }
                    .width(278.vp)
                    .height(352.vp)
                    .padding(left: 8.vp, right: 8.vp, top: 8.vp, bottom: 7.vp)
                    .backgroundColor(0xFFF8F8FF)
                    .borderRadius(16.vp)
                    .align(Alignment.Center)
                    .id("schoolCardDateDialog")
            }
        }.width(100.percent).height(100.percent)
    }
}
