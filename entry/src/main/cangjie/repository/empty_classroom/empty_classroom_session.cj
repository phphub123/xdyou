package ohos_app_cangjie_entry.repository.empty_classroom

import std.collection.*
import stdx.encoding.json.*
import ohos_app_cangjie_entry.model.*
import ohos_app_cangjie_entry.repository.academic.*

public class EmptyClassroomSession {
    static let baseUrl = "https://ehall.xidian.edu.cn/jwapp/sys/kxjas/modules/kxjas"
    func stringOf(value: JsonValue): String {
        match (value.kind()) {
            case JsString => value.asString().getValue()
            case JsInt => value.asInt().getValue().toString()
            case JsFloat => value.asFloat().getValue().toString()
            case JsBool => value.asBool().getValue().toString()
            case _ => ""
        }
    }
    func field(object: JsonObject, name: String): String {
        match (object.get(name)) { case Some(value) => this.stringOf(value); case None => "" }
    }
    func dataObject(body: String, name: String): JsonObject {
        return JsonValue.fromStr(body).asObject()["datas"].asObject()[name].asObject()
    }
    public func loadBuildings(success: (ArrayList<EmptyClassroomPlace>) -> Unit, failure: (String) -> Unit): Unit {
        AcademicSession().request("${EmptyClassroomSession.baseUrl}/jxlcx.do", "*order=%2BXXXQDM%2C%2BPX%2C%2BJXLDM", { body =>
            try {
                let result = ArrayList<EmptyClassroomPlace>()
                let rows = this.dataObject(body, "jxlcx")["rows"].asArray()
                var index: Int64 = 0
                while (index < rows.size()) {
                    let row = rows[index].asObject()
                    result.add(EmptyClassroomPlace(this.field(row, "JXLJC"), this.field(row, "JXLDM")))
                    index += 1
                }
                success(result)
            } catch (e: Exception) { failure("教学楼响应解析失败：${e.message}") }
        }, failure)
    }
    public func search(building: String, date: String, semesterRange: String, semesterPart: String, success: (ArrayList<EmptyClassroomData>) -> Unit, failure: (String) -> Unit): Unit {
        let semester = "${semesterRange}-${semesterPart}"
        AcademicSession().request("${EmptyClassroomSession.baseUrl}/rqzhzcjc.do", "RQ=${date}&XN=${semesterRange}&XQ=${semesterPart}", { dateBody =>
            try {
                let dateData = this.dataObject(dateBody, "rqzhzcjc")
                let week = this.field(dateData, "ZC")
                let weekday = this.field(dateData, "XQJ")
                let settings = "%5B%7B%22name%22%3A%22JXLDM%22%2C%22builder%22%3A%22equal%22%2C%22linkOpt%22%3A%22AND%22%2C%22value%22%3A%22${building}%22%7D%2C%7B%22name%22%3A%22XNXQDM%22%2C%22builder%22%3A%22equal%22%2C%22linkOpt%22%3A%22AND%22%2C%22value%22%3A%22${semester}%22%7D%2C%7B%22name%22%3A%22ZC%22%2C%22builder%22%3A%22equal%22%2C%22linkOpt%22%3A%22AND%22%2C%22value%22%3A%22${week}%22%7D%2C%7B%22name%22%3A%22XQ%22%2C%22builder%22%3A%22equal%22%2C%22linkOpt%22%3A%22AND%22%2C%22value%22%3A%22${weekday}%22%7D%5D"
                let form = "XNXQDM=${semester}&ZC=${week}&XQ=${weekday}&querySetting=${settings}&*order=%2BLC%2C%2BJASMC&pageSize=999&pageNumber=1"
                AcademicSession().request("${EmptyClassroomSession.baseUrl}/cxjsqk.do", form, { body =>
                    try {
                        let result = ArrayList<EmptyClassroomData>()
                        let rows = this.dataObject(body, "cxjsqk")["rows"].asArray()
                        var rowIndex: Int64 = 0
                        while (rowIndex < rows.size()) {
                            let row = rows[rowIndex].asObject(); let slots = ArrayList<Bool>()
                            var slot: Int64 = 1
                            while (slot <= 11) { slots.add(this.field(row, "JC${slot}").contains("1_")); slot += 1 }
                            result.add(EmptyClassroomData(this.field(row, "JASMC"), slots)); rowIndex += 1
                        }
                        success(result)
                    } catch (e: Exception) { failure("空闲教室响应解析失败：${e.message}") }
                }, failure)
            } catch (e: Exception) { failure("日期换算响应解析失败：${e.message}") }
        }, failure)
    }
}
