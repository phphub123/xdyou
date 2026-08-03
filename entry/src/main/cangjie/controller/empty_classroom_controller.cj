package ohos_app_cangjie_entry.controller

import std.collection.*
import std.convert.*
import ohos_app_cangjie_entry.model.xidian_ids.*
import ohos_app_cangjie_entry.repository.xidian_ids.*

public class EmptyClassroomController {
    var refreshing: Bool = false
    public func loadBuildings(success: (ArrayList<EmptyClassroomPlace>) -> Unit, failure: (String) -> Unit): Unit {
        if (this.refreshing) { return }; this.refreshing = true
        EmptyClassroomSession().loadBuildings({ data => this.refreshing = false; success(data) }, { message => this.refreshing = false; failure(message) })
    }
    public func search(building: String, date: String, semester: String, success: (ArrayList<EmptyClassroomData>) -> Unit, failure: (String) -> Unit): Unit {
        if (this.refreshing) { return }
        if (building.trimAscii() == "" || date.trimAscii() == "" || semester.size < 6) { failure("请完整填写教学楼代码、日期和学期代码。"); return }
        let year = semester[0..4]
        let part = semester[semester.size - 1..semester.size]
        this.refreshing = true
        EmptyClassroomSession().search(building, date, "${year}-${Int64.parse(year) + 1}", part, { data => this.refreshing = false; success(data) }, { message => this.refreshing = false; failure(message) })
    }
}
