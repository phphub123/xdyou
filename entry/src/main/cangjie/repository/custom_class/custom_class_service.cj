package ohos_app_cangjie_entry.repository.custom_class

import kit.ArkData.*
import std.collection.*
import stdx.encoding.json.*
import ohos_app_cangjie_entry.common.*
import ohos_app_cangjie_entry.model.*

public class CustomClassRepository {
    static let storeName = "xdyou_custom_classes"
    static let dataKey = "classesJson"
    let preferences = Preferences.getPreferences(AppContext.get(), CustomClassRepository.storeName)

    public func load(): ArrayList<CustomClass> {
        let result = ArrayList<CustomClass>()
        let raw = this.rawValue()
        if (raw == "") { return result }
        let rows = JsonValue.fromStr(raw).asArray()
        var index: Int64 = 0
        while (index < rows.size()) {
            let item = rows[index].asObject(); let ranges = ArrayList<CustomClassTimeRange>()
            let rangeRows = item["timeRanges"].asArray(); var rangeIndex: Int64 = 0
            while (rangeIndex < rangeRows.size()) {
                let range = rangeRows[rangeIndex].asObject()
                ranges.add(CustomClassTimeRange(this.field(range, "id"), this.field(range, "date"), this.intField(range, "startMinutes"), this.intField(range, "endMinutes")))
                rangeIndex += 1
            }
            result.add(CustomClass(this.field(item, "id"), this.field(item, "name"), this.field(item, "teacher"), this.field(item, "classroom"), ranges))
            index += 1
        }
        return result
    }

    public func save(items: ArrayList<CustomClass>): Unit {
        let rows = JsonArray()
        for (item in items) {
            let object = JsonObject(); object.put("id", JsonString(item.id)); object.put("name", JsonString(item.name))
            object.put("teacher", JsonString(item.teacher)); object.put("classroom", JsonString(item.classroom))
            let ranges = JsonArray()
            for (range in item.timeRanges) {
                let rangeObject = JsonObject(); rangeObject.put("id", JsonString(range.id)); rangeObject.put("date", JsonString(range.date))
                rangeObject.put("startMinutes", JsonInt(range.startMinutes)); rangeObject.put("endMinutes", JsonInt(range.endMinutes)); ranges.add(rangeObject)
            }
            object.put("timeRanges", ranges); rows.add(object)
        }
        this.preferences.put(CustomClassRepository.dataKey, PreferencesValueType.StringData(rows.toString()))
        this.preferences.flush()
    }

    public func clear(): Unit { this.preferences.delete(CustomClassRepository.dataKey); this.preferences.flush() }
    func rawValue(): String { match (this.preferences.get(CustomClassRepository.dataKey, PreferencesValueType.StringData(""))) { case PreferencesValueType.StringData(value) => value; case _ => "" } }
    func field(object: JsonObject, name: String): String { match (object.get(name)) { case Some(value) => value.asString().getValue(); case None => "" } }
    func intField(object: JsonObject, name: String): Int64 { match (object.get(name)) { case Some(value) => value.asInt().getValue(); case None => -1 } }
}
