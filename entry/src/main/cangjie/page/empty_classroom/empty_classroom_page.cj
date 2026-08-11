package ohos_app_cangjie_entry.page.empty_classroom

import kit.ArkUI.*
import ohos.arkui.state_macro_manage.*
import std.collection.ArrayList
import std.time.*
import ohos_app_cangjie_entry.controller.*
import ohos_app_cangjie_entry.model.xidian_ids.*
import ohos_app_cangjie_entry.repository.*
import ohos_app_cangjie_entry.repository.xidian_ids.*
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
    @State var pickerIndex: UInt32 = 0
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
            .fontColor(if (used) { 0xFFFFFFFF } else { 0xFF41699F })
            .backgroundColor(if (used) { 0xFF476FA9 } else { 0x00FFFFFF })
            .border(width: 1.vp, color: 0xFF476FA9)
            .borderRadius(5.vp)
            .margin(left: 2.vp)
    }

    func buildingNames(): Array<String> {
        return Array<String>(this.places.size, { index => this.places[index].name })
    }

    func currentBuildingIndex(): UInt32 {
        var index: Int64 = 0
        while (index < this.places.size) {
            if (this.places[index].code == this.building) { return UInt32(index) }
            index += 1
        }
        return 0
    }

    func openBuildingPicker(): Unit {
        if (this.places.size == 0) { this.loadBuildings(); return }
        this.pickerIndex = this.currentBuildingIndex()
        this.showBuildingPicker = true
    }

    func confirmBuilding(): Unit {
        this.showBuildingPicker = false
        this.chooseBuilding(Int64(this.pickerIndex))
    }

    @Builder
    func refreshAction() {
        Button("↻").width(38.vp).height(38.vp).fontSize(23.vp)
            .fontColor(0xFF344054).buttonStyle(ButtonStyleMode.Textual).backgroundColor(Color.Transparent)
            .onClick({_ => this.search()}).id("emptyClassroomRefresh")
    }

    @Builder
    func buildingPickerDialog() {
        Column {
            Text("选择教学楼").fontSize(17.vp).fontWeight(FontWeight.Medium).margin(bottom: 6.vp)
            TextPicker(range: this.buildingNames(), selected: this.pickerIndex)
                .height(250.vp).canLoop(false).defaultPickerItemHeight(42.vp)
                .onChange({ _: String, index: UInt32 => this.pickerIndex = index })
                .id("emptyClassroomBuildingWheel")
            Row {
                Button("取消").layoutWeight(1).height(36.vp).backgroundColor(0xFFE9EDF5)
                    .fontColor(0xFF476FA9).onClick({_ => this.showBuildingPicker = false})
                    .id("emptyClassroomBuildingCancel")
                Button("确定").layoutWeight(1).height(36.vp).margin(left: 10.vp)
                    .onClick({_ => this.confirmBuilding()}).id("emptyClassroomBuildingConfirm")
            }.width(100.percent)
        }.width(86.percent).padding(18.vp).backgroundColor(0xFFFFFFFF).borderRadius(14.vp)
            .align(Alignment.Center).id("emptyClassroomBuildingDialog")
    }

    func build() {
        Stack {
            Column {
                PageHeader(title: "空闲教室", onBack: this.onBack,
                    backId: "emptyClassroomBack", trailing: this.refreshAction)

                TextInput(placeholder: "搜索教室名称或教学楼代号", text: this.filter)
                    .width(100.percent).height(42.vp).margin(top: 10.vp)
                    .backgroundColor(0xFFF2F3F8).border(width: 1.vp, color: 0xFF476FA9).borderRadius(10.vp)
                    .onChange({ value => this.filter = value }).id("emptyClassroomFilterInput")

                Row {
                    TextInput(placeholder: "yyyy-MM-dd", text: this.date)
                        .layoutWeight(1).height(38.vp).fontSize(12.vp).fontColor(0xFFFFFFFF)
                        .backgroundColor(0xFF476FA9).borderRadius(8.vp)
                        .onChange({ value => this.date = value }).id("emptyClassroomDateInput")
                    Button("教学楼：${this.selectedBuildingName()}")
                        .layoutWeight(1).height(38.vp).fontSize(12.vp).margin(left: 10.vp)
                        .backgroundColor(0xFF476FA9).onClick({_ => this.openBuildingPicker()})
                        .id("emptyClassroomBuildingPicker")
                }.width(100.percent).margin(top: 10.vp)

                Row {
                    Row { this.slotBadge(true, -1); Text("占用").fontSize(12.vp).margin(left: 5.vp) }
                    Row { this.slotBadge(false, -1); Text("空闲").fontSize(12.vp).margin(left: 5.vp) }.margin(left: 18.vp)
                }.width(100.percent).justifyContent(FlexAlign.Center).margin(top: 8.vp)

                Text(this.status).fontSize(11.vp).fontColor(0xFF65738A).margin(top: 7.vp).id("emptyClassroomStatus")

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
            }.width(100.percent).height(100.percent).padding(left: 16.vp, right: 16.vp, top: 12.vp, bottom: 8.vp)
                .alignItems(HorizontalAlign.Start).backgroundColor(0xFFF7F9FC)

            if (this.showBuildingPicker) {
                Column {}.width(100.percent).height(100.percent).backgroundColor(0x66000000)
                    .onClick({_ => this.showBuildingPicker = false})
                this.buildingPickerDialog()
            }
        }.width(100.percent).height(100.percent)
    }
}
