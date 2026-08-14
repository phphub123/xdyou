package ohos_app_cangjie_entry.page.empty_classroom

import kit.ArkUI.*
import ohos.arkui.state_macro_manage.*
import std.collection.ArrayList
import std.time.*
import ohos_app_cangjie_entry.controller.*
import ohos_app_cangjie_entry.model.empty_classroom.*
import ohos_app_cangjie_entry.repository.academic.*
import ohos_app_cangjie_entry.repository.auth.*
import ohos_app_cangjie_entry.components.*

@Component
public class EmptyClassroomPage {
    let onBack: () -> Unit
    @State var loading: Bool = false
    @State var status: String = "正在读取当前学期和教学楼…"
    @State var building: String = ""
    @State var date: String = DateTime.now().format("yyyy-MM-dd")
    @State var semester: String = ""
    @State var filter: String = ""
    @State var showBuildingPicker: Bool = false
    @State var showDatePicker: Bool = false
    @State var places: ArrayList<EmptyClassroomPlace> = ArrayList<EmptyClassroomPlace>()
    @State var rooms: ArrayList<EmptyClassroomData> = ArrayList<EmptyClassroomData>()
    let controller = EmptyClassroomController()

    protected override func aboutToAppear(): Unit {
        if (this.places.size == 0 && !this.loading) { this.loadInitialData() }
    }

    func loadInitialData(): Unit {
        this.loading = true
        this.status = "正在读取当前学期…"
        AcademicSession().loadCurrentSemester({ value => launch {
            this.semester = value
            SessionStore().saveSetting("semester", value)
            this.loadBuildings()
        } }, { message => launch {
            let cached = SessionStore().restoreSetting("semester")
            if (cached == "") {
                this.loading = false
                this.status = message
            } else {
                this.semester = cached
                this.loadBuildings()
            }
        } })
    }

    func selectedBuildingName(): String {
        for (place in this.places) {
            if (place.code == this.building) { return place.name }
        }
        return if (this.building == "") { "加载中" } else { this.building }
    }

    func chooseBuilding(index: Int64): Unit {
        if (index >= 0 && index < this.places.size) {
            this.building = this.places[index].code
            SessionStore().saveSetting("emptyClassroomBuilding", this.building)
            this.search()
        }
    }

    func nextBuilding(): Unit {
        if (this.places.size == 0) { this.loadBuildings(); return }
        var index: Int64 = 0
        while (index < this.places.size) {
            if (this.places[index].code == this.building) {
                this.chooseBuilding((index + 1) % this.places.size)
                return
            }
            index += 1
        }
        this.chooseBuilding(0)
    }

    func loadBuildings(): Unit {
        this.loading = true
        this.status = "正在加载教学楼…"
        this.controller.loadBuildings({ items => launch {
            this.places = items
            this.loading = false
            if (items.size == 0) {
                this.status = "教务系统未返回教学楼。"
                return
            }
            let cached = SessionStore().restoreSetting("emptyClassroomBuilding")
            var selected: Int64 = 0
            var index: Int64 = 0
            while (index < items.size) {
                if (items[index].code == cached) { selected = index }
                index += 1
            }
            this.building = items[selected].code
            this.search()
        } }, { message => launch {
            this.loading = false
            this.status = message
        } })
    }

    func search(): Unit {
        if (this.loading) { return }
        this.loading = true
        this.rooms = ArrayList<EmptyClassroomData>()
        this.status = "正在查询 ${this.selectedBuildingName()} 的空闲教室…"
        this.controller.search(this.building, this.date, this.semester, { items => launch {
            this.rooms = items
            this.loading = false
            this.status = if (items.size == 0) { "所选日期没有返回教室。" } else { "已加载 ${items.size} 间教室" }
        } }, { message => launch {
            this.loading = false
            this.status = message
        } })
    }

    @Builder
    func slotBadge(used: Bool, index: Int64) {
        Text(if (index >= 0) { "${index + 1}" } else { "" })
            .width(21.vp)
            .height(21.vp)
            .fontSize(10.vp)
            .fontWeight(FontWeight.Medium)
            .textAlign(TextAlign.Center)
            .fontColor(if (used) { 0xFFFFFFFF } else { 0xFF46699D })
            .backgroundColor(if (used) { 0xFF46699D } else { 0x00FFFFFF })
            .border(width: 1.vp, color: 0xFF46699D)
            .borderRadius(5.vp)
            .margin(left: 2.vp)
    }

    func openBuildingPicker(): Unit {
        if (this.places.size == 0) { this.loadBuildings(); return }
        this.showBuildingPicker = true
    }

    func selectBuilding(index: Int64): Unit { this.showBuildingPicker = false; this.chooseBuilding(index) }
    func confirmDate(value: String): Unit { this.showDatePicker = false; this.date = value; this.search() }

    @Builder
    func buildingPickerDialog() {
        Column {
            Scroll {
                Column {
                    ForEach(this.places, itemGenerator: { place: EmptyClassroomPlace, index: Int64 =>
                        Row {
                            Text(if (place.code == this.building) { "●" } else { "○" })
                                .width(36.vp).fontSize(22.vp).fontColor(0xFF46699D).textAlign(TextAlign.Center)
                            Text(place.name).fontSize(14.vp).margin(left: 12.vp)
                        }.width(100.percent).height(48.vp).padding(left: 10.vp, right: 10.vp)
                            .onClick({_ => this.selectBuilding(index)}).id("emptyClassroomBuilding_${index}")
                    })
                }.width(100.percent).alignItems(HorizontalAlign.Start)
            }.width(100.percent).layoutWeight(1).align(Alignment.TopStart)
        }.width(284.vp).height(680.vp).padding(left: 10.vp, right: 10.vp, top: 12.vp, bottom: 12.vp)
            .backgroundColor(0xFFF8F8FF).borderRadius(12.vp)
            .align(Alignment.Center).id("emptyClassroomBuildingDialog")
    }

    func build() {
        Stack {
            Column {
                PageHeader(title: "空闲教室", onBack: this.onBack,
                    backId: "emptyClassroomBack")

                Column {
                    PageSearchField(placeholder: "教室名称或者教学楼代码", value: this.filter,
                        onChange: { value => this.filter = value }, fieldId: "emptyClassroomFilterInput")
                }.width(100.percent).margin(top: 8.vp)

                Row {
                    Button("日期 ${this.date}")
                        .width(128.vp).height(34.vp).fontSize(11.vp)
                        .buttonStyle(ButtonStyleMode.Normal).backgroundColor(0xFF46699D)
                        .fontColor(0xFFFFFFFF).borderRadius(8.vp)
                        .onClick({_ => this.showDatePicker = true}).id("emptyClassroomDateInput")
                    Button("教学楼：${this.selectedBuildingName()}")
                        .height(34.vp).fontSize(11.vp).margin(left: 8.vp).padding(left: 13.vp, right: 13.vp)
                        .buttonStyle(ButtonStyleMode.Normal).backgroundColor(0xFF46699D).fontColor(0xFFFFFFFF)
                        .onClick({_ => this.openBuildingPicker()})
                        .id("emptyClassroomBuildingPicker")
                }.width(100.percent).margin(top: 10.vp).justifyContent(FlexAlign.Center)

                Row {
                    Row { this.slotBadge(true, -1); Text("占用").fontSize(12.vp).margin(left: 5.vp) }
                    Row { this.slotBadge(false, -1); Text("空闲").fontSize(12.vp).margin(left: 5.vp) }.margin(left: 18.vp)
                }.width(100.percent).justifyContent(FlexAlign.Center).margin(top: 8.vp)

                if (this.loading) {
                    Text(this.status).fontSize(11.vp).fontColor(0xFF65738A).margin(top: 7.vp).id("emptyClassroomStatus")
                }

                Scroll {
                    Column {
                        ForEach(this.rooms, itemGenerator: { item: EmptyClassroomData, _: Int64 =>
                            if (this.filter == "" || item.name.contains(this.filter)) {
                                Row {
                                    Text(item.name).width(65.vp).fontSize(11.vp).maxLines(2)
                                    Row {
                                        ForEach(item.isUsed, itemGenerator: { used: Bool, index: Int64 => this.slotBadge(used, index) })
                                    }.layoutWeight(1).justifyContent(FlexAlign.SpaceBetween)
                                }.width(100.percent).height(34.vp).id("emptyClassroomRow")
                            }
                        })
                        if (!this.loading && this.rooms.size == 0) {
                            Text("暂无教室数据").fontSize(14.vp).fontColor(0xFF7A8797).margin(top: 32.vp)
                        }
                    }.width(100.percent).alignItems(HorizontalAlign.Start)
                }.width(100.percent).layoutWeight(1).margin(top: 5.vp).align(Alignment.TopStart)
                    .id("emptyClassroomMatrix")
            }.width(100.percent).height(100.percent).padding(left: 14.vp, right: 14.vp, top: 8.vp, bottom: 8.vp)
                .alignItems(HorizontalAlign.Start).backgroundColor(0xFFFFFFFF)

            if (this.showBuildingPicker) {
                Column {}.width(100.percent).height(100.percent).backgroundColor(0x66000000)
                    .onClick({_ => this.showBuildingPicker = false})
                this.buildingPickerDialog()
            }
            if (this.showDatePicker) {
                SingleDateCalendarDialog(initialDate: this.date,
                    onCancel: {=> this.showDatePicker = false},
                    onConfirm: { value => this.confirmDate(value) }, idPrefix: "emptyClassroomDate")
            }
        }.width(100.percent).height(100.percent)
    }
}
