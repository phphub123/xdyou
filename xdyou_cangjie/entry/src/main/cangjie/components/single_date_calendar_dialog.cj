package ohos_app_cangjie_entry.components

// 单日期选择弹层，封装月份切换、日期网格和确认/取消回调。

import kit.ArkUI.*
import ohos.arkui.state_macro_manage.*
import std.collection.ArrayList
import std.convert.*
import std.time.*

// 日期以 yyyy-MM-dd 字符串作为输入输出边界，避免页面依赖日历内部状态。
@Component
public class SingleDateCalendarDialog {
    let initialDate: String
    let onCancel: () -> Unit
    let onConfirm: (String) -> Unit
    let idPrefix: String
    @State var year: Int64 = 2026
    @State var month: Int64 = 1
    @State var day: Int64 = 1

    protected override func aboutToAppear(): Unit {
        try {
            let parts = this.initialDate.split("-")
            this.year = Int64.parse(parts[0]); this.month = Int64.parse(parts[1]); this.day = Int64.parse(parts[2])
        } catch (_) {
            let now = DateTime.now()
            this.year = now.year
            this.month = Int64.parse(now.format("MM")); this.day = Int64.parse(now.format("dd"))
        }
    }

    func padded(value: Int64): String { return if (value < 10) { "0${value}" } else { value.toString() } }
    func selectedDate(): String { return "${this.year}-${this.padded(this.month)}-${this.padded(this.day)}" }
    func monthName(): String {
        return ["January", "February", "March", "April", "May", "June", "July", "August", "September", "October", "November", "December"][this.month - 1]
    }
    func daysInMonth(): Int64 {
        if (this.month == 2) { return if (this.year % 400 == 0 || (this.year % 4 == 0 && this.year % 100 != 0)) { 29 } else { 28 } }
        return if (this.month == 4 || this.month == 6 || this.month == 9 || this.month == 11) { 30 } else { 31 }
    }
    func firstWeekday(): Int64 {
        try {
            let first = DateTime.parse("${this.year}-${this.padded(this.month)}-01", "yyyy-MM-dd")
            return match (first.dayOfWeek) {
                case Sunday => 0
                case Monday => 1
                case Tuesday => 2
                case Wednesday => 3
                case Thursday => 4
                case Friday => 5
                case Saturday => 6
            }
        } catch (_) { return 0 }
    }
    func cells(): ArrayList<Int64> {
        // 固定生成 6×7 网格；0 表示当前月份之外的占位单元。
        let result = ArrayList<Int64>(); let offset = this.firstWeekday()
        for (index in 0..42) {
            let value = index - offset + 1
            result.add(if (value >= 1 && value <= this.daysInMonth()) { value } else { 0 })
        }
        return result
    }
    func changeMonth(delta: Int64): Unit {
        this.month += delta
        if (this.month < 1) { this.month = 12; this.year -= 1 }
        if (this.month > 12) { this.month = 1; this.year += 1 }
        if (this.day > this.daysInMonth()) { this.day = this.daysInMonth() }
    }

    @Builder
    func calendarDay(value: Int64, index: Int64) {
        GridItem {
            Text(if (value == 0) { "" } else { value.toString() })
                .width(34.vp).height(34.vp).fontSize(10.vp).textAlign(TextAlign.Center)
                .fontColor(if (value == this.day) { 0xFFFFFFFF } else { 0xFF252932 })
                .backgroundColor(if (value == this.day) { 0xFF46699D } else { Color.Transparent })
                .borderRadius(17.vp)
        }.onClick({_ => if (value > 0) { this.day = value }}).id("${this.idPrefix}Day_${index}")
    }

    func build() {
        Stack {
            Column {}.width(100.percent).height(100.percent).backgroundColor(0x88000000)
                .onClick({_ => this.onCancel()}).id("${this.idPrefix}Scrim")
            Column {
                Row {
                    Text(this.monthName()).fontSize(12.vp).fontColor(0xFF4C5059)
                    Text("⌄").fontSize(12.vp).fontColor(0xFF4F535D).margin(left: 2.vp)
                    Text(this.year.toString()).fontSize(12.vp).fontColor(0xFF4C5059).margin(left: 24.vp)
                    Text("⌄").fontSize(12.vp).fontColor(0xFF4F535D).margin(left: 2.vp)
                    Blank().layoutWeight(1)
                    Button("‹").width(38.vp).height(38.vp).fontSize(23.vp).fontColor(0xFF30343C)
                        .buttonStyle(ButtonStyleMode.Textual).backgroundColor(Color.Transparent)
                        .onClick({_ => this.changeMonth(-1)}).id("${this.idPrefix}Previous")
                    Button("›").width(38.vp).height(38.vp).fontSize(23.vp).fontColor(0xFF30343C)
                        .buttonStyle(ButtonStyleMode.Textual).backgroundColor(Color.Transparent)
                        .onClick({_ => this.changeMonth(1)}).id("${this.idPrefix}Next")
                }.width(100.percent).height(46.vp)
                Row {
                    ForEach(["S", "M", "T", "W", "T", "F", "S"], itemGenerator: { label: String, _: Int64 =>
                        Text(label).layoutWeight(1).fontSize(10.vp).fontColor(0xFF50545D).textAlign(TextAlign.Center)
                    })
                }.width(100.percent).height(28.vp)
                Grid {
                    ForEach(this.cells(), itemGenerator: { value: Int64, index: Int64 => this.calendarDay(value, index) })
                }.width(100.percent).height(204.vp).columnsTemplate("1fr 1fr 1fr 1fr 1fr 1fr 1fr")
                    .rowsTemplate("1fr 1fr 1fr 1fr 1fr 1fr")
                Blank().layoutWeight(1)
                Row {
                    Blank().layoutWeight(1)
                    Button("CANCEL").height(38.vp).fontSize(12.vp).fontColor(0xFF34558F)
                        .buttonStyle(ButtonStyleMode.Textual).backgroundColor(Color.Transparent)
                        .onClick({_ => this.onCancel()}).id("${this.idPrefix}Cancel")
                    Button("OK").height(38.vp).fontSize(12.vp).fontColor(0xFF34558F)
                        .buttonStyle(ButtonStyleMode.Textual).backgroundColor(Color.Transparent)
                        .onClick({_ => this.onConfirm(this.selectedDate())}).id("${this.idPrefix}Confirm")
                }.width(100.percent).height(44.vp)
            }.width(278.vp).height(352.vp).padding(left: 8.vp, right: 8.vp, top: 8.vp, bottom: 7.vp)
                .backgroundColor(0xFFF8F8FF).borderRadius(16.vp).align(Alignment.Center)
                .id("${this.idPrefix}Dialog")
        }.width(100.percent).height(100.percent)
    }
}
