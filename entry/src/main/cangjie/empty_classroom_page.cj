package ohos_app_cangjie_entry

import kit.ArkUI.*
import ohos.arkui.state_macro_manage.*
import std.collection.*
import std.convert.*
import std.time.*
import ohos_app_cangjie_entry.controller.*
import ohos_app_cangjie_entry.model.xidian_ids.*

@Component
public class EmptyClassroomPage {
    @State var loading: Bool = false
    @State var status: String = "先加载教学楼，再按日期查询。"
    @State var building: String = ""
    @State var date: String = DateTime.now().format("yyyy-MM-dd")
    @State var semester: String = ""
    @State var filter: String = ""
    @State var places: ArrayList<EmptyClassroomPlace> = ArrayList<EmptyClassroomPlace>()
    @State var rooms: ArrayList<EmptyClassroomData> = ArrayList<EmptyClassroomData>()
    let controller = EmptyClassroomController()
    protected override func aboutToAppear(): Unit {
        if (this.semester == "") {
            let now = DateTime.now()
            this.semester = match (now.month) {
                case August => "${now.year}-1"
                case September => "${now.year}-1"
                case October => "${now.year}-1"
                case November => "${now.year}-1"
                case December => "${now.year}-1"
                case _ => "${now.year - 1}-2"
            }
        }
        if (this.places.size == 0 && !this.loading) { this.loadBuildings() }
    }
    func chooseBuilding(index: Int64): Unit {
        if (index >= 0 && index < this.places.size) {
            this.building = this.places[index].code
            this.status = "已选择 ${this.places[index].name}。"
        }
    }
    func loadBuildings(): Unit {
        this.loading = true
        this.controller.loadBuildings({ items => launch {
            this.places = items; this.loading = false
            if (items.size > 0 && this.building == "") { this.building = items[0].code }
            this.status = if (items.size == 0) { "未返回教学楼。" } else { "已加载 ${items.size} 个教学楼，当前代码 ${this.building}。" }
        } }, { message => launch { this.loading = false; this.status = message } })
    }
    func search(): Unit {
        this.loading = true
        this.controller.search(this.building, this.date, this.semester, { items => launch {
            this.rooms = items; this.loading = false; this.status = "查询到 ${items.size} 间教室。"
        } }, { message => launch { this.loading = false; this.status = message } })
    }
    func build() {
        Column {
            Text("空闲教室").fontSize(26.vp).fontWeight(FontWeight.Bold)
            Row {
                TextInput(placeholder: "教学楼代码", text: this.building).layoutWeight(1).onChange({ value => this.building = value }).id("emptyClassroomBuildingInput")
                Button("加载教学楼").margin(left: 8.vp).onClick({ _ => this.loadBuildings() }).id("emptyClassroomLoadBuildings")
            }.width(100.percent).height(44.vp).margin(top: 12.vp)
            if (this.places.size > 0) { Scroll { Row { ForEach(this.places, itemGenerator: { item: EmptyClassroomPlace, index: Int64 => Button(item.name).margin(right: 6.vp).backgroundColor(if (item.code == this.building) { 0xFF476FA9 } else { 0xFFE8EDF6 }).fontColor(if (item.code == this.building) { 0xFFFFFFFF } else { 0xFF41699F }).onClick({ _ => this.chooseBuilding(index) }).id("emptyClassroomBuilding_${index}") }) }.height(38.vp) }.width(100.percent).height(42.vp).margin(top: 6.vp) }
            Row {
                TextInput(placeholder: "日期 yyyy-MM-dd", text: this.date).layoutWeight(1).onChange({ value => this.date = value }).id("emptyClassroomDateInput")
                TextInput(placeholder: "学期 2026-1", text: this.semester).layoutWeight(1).margin(left: 8.vp).onChange({ value => this.semester = value }).id("emptyClassroomSemesterInput")
            }.width(100.percent).height(44.vp).margin(top: 8.vp)
            Row {
                TextInput(placeholder: "筛选教室名称", text: this.filter).layoutWeight(1).onChange({ value => this.filter = value }).id("emptyClassroomFilterInput")
                Button(if (this.loading) { "查询中…" } else { "查询" }).margin(left: 8.vp).onClick({ _ => this.search() }).id("emptyClassroomSearch")
            }.width(100.percent).height(44.vp).margin(top: 8.vp)
            Text(this.status).fontSize(12.vp).fontColor(0xFF5F6368).margin(top: 8.vp).id("emptyClassroomStatus")
            Row { Text("教室").layoutWeight(2); Text("1  2  3  4  5  6  7  8  9 10 11").layoutWeight(5) }.width(100.percent).padding(top: 12.vp, bottom: 6.vp)
            Scroll { Column {
                ForEach(this.rooms, itemGenerator: { item: EmptyClassroomData, _: Int64 => if (this.filter == "" || item.name.contains(this.filter)) { Row {
                    Text(item.name).layoutWeight(2).fontSize(13.vp).maxLines(2)
                    Row { ForEach(item.isUsed, itemGenerator: { used: Bool, index: Int64 => Text("${index + 1}").width(23.vp).height(23.vp).fontSize(10.vp).fontColor(if (used) { 0xFFFFFFFF } else { 0xFF46699D }).backgroundColor(if (used) { 0xFF46699D } else { 0xFFFFFFFF }).border(width: 1.vp, color: 0xFF46699D).borderRadius(5.vp).margin(left: 2.vp) }) }.layoutWeight(5)
                }.width(100.percent).padding(top: 8.vp, bottom: 8.vp).id("emptyClassroomRow") } })
            }.width(100.percent) }.width(100.percent).layoutWeight(1).id("emptyClassroomMatrix")
        }.width(100.percent).height(100.percent).padding(18.vp).alignItems(HorizontalAlign.Start)
    }
}
