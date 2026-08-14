package ohos_app_cangjie_entry.page.custom_class

import kit.ArkUI.*
import ohos.arkui.state_macro_manage.*
import std.collection.*
import ohos_app_cangjie_entry.controller.*
import ohos_app_cangjie_entry.model.custom_class.*
import ohos_app_cangjie_entry.components.*

@Component
public class CustomClassPage {
    let onBack: () -> Unit
    let controller = CustomClassController()
    @State var classes: ArrayList<CustomClass> = ArrayList<CustomClass>()
    @State var editing: Bool = false
    @State var selectedIndex: Int64 = -1
    @State var name: String = ""
    @State var teacher: String = ""
    @State var classroom: String = ""
    @State var date: String = ""
    @State var startTime: String = "08:30"
    @State var endTime: String = "09:15"
    @State var ranges: ArrayList<CustomClassTimeRange> = ArrayList<CustomClassTimeRange>()
    @State var status: String = "自定义课程仅保存在本机，不需要 IDS 登录。"

    protected override func aboutToAppear(): Unit {
        this.reload()
    }
    func reload(): Unit {
        try {
            this.classes = this.controller.load()
        } catch (error: Exception) {
            this.classes = ArrayList<CustomClass>()
            this.status = "读取自定义课程失败：${error.message}"
        }
    }
    func startAdd(): Unit {
        this.selectedIndex = -1
        this.name = ""
        this.teacher = ""
        this.classroom = ""
        this.date = ""
        this.startTime = "08:30"
        this.endTime = "09:15"
        this.ranges = ArrayList<CustomClassTimeRange>()
        this.editing = true
        this.status = "填写课程信息并至少添加一个时间段。"
    }
    func startEdit(index: Int64): Unit {
        let item = this.classes[index];
        this.selectedIndex = index
        this.name = item.name
        this.teacher = item.teacher
        this.classroom = item.classroom
        this.ranges = this.controller.copyRanges(item.timeRanges)
        this.editing = true
        this.status = "正在编辑 ${item.name}"
    }
    func addRange(): Unit {
        try {
            let next = this.controller.copyRanges(this.ranges);
            next.add(this.controller.createRange(this.date, this.startTime, this.endTime));
            this.ranges = next
            this.status = "已添加时间段。"
        } catch (error: Exception) {
            this.status = error.message
        }
    }
    func removeRange(index: Int64): Unit {
        let next = this.controller.copyRanges(this.ranges);
        if (index >= 0 && index < next.size) {
            next.remove(at: index)
        };
        this.ranges = next
    }
    func save(): Unit {
        try {
            if (this.selectedIndex < 0) {
                this.classes = this.controller.add(this.classes, this.name, this.teacher, this.classroom, this.ranges)
            } else {
                this.classes = this
                    .controller
                    .update(this.classes, this.selectedIndex, this.name, this.teacher, this.classroom, this.ranges)
            };
            this.editing = false
            this.status = "自定义课程已保存。"
        } catch (error: Exception) {
            this.status = error.message
        }
    }
    func removeClass(index: Int64): Unit {
        this.classes = this.controller.remove(this.classes, index)
        this.status = "自定义课程已删除。"
    }
    func clearAll(): Unit {
        this.classes = this.controller.clear()
        this.editing = false
        this.status = "已清空全部自定义课程。"
    }

    func headerTitle(): String {
        return if (this.editing) {
            if (this.selectedIndex < 0) {
                "新增自定义课程"
            } else {
                "编辑自定义课程"
            }
        } else {
            "自定义课程"
        }
    }
    @Builder
    func headerTrailing() {
        if (this.editing) {
            Button("取消").onClick({_ => this.editing = false}).id("customClassCancel")
        } else {
            Button("新增").onClick({_ => this.startAdd()}).id("customClassAdd")
        }
    }

    func build() {
        Column {
            PageHeader(title: this.headerTitle(), onBack: this.onBack, backId: "customClassBack",
                trailing: this.headerTrailing)
            Text(this.status).fontSize(12.vp).fontColor(0xFF65738A).margin(top: 8.vp).id("customClassStatus")
            if (this.editing) {
                Scroll {
                    Column {
                        TextInput(placeholder: "课程名称（必填）", text: this.name)
                            .width(100.percent)
                            .height(44.vp)
                            .onChange({value => this.name = value})
                            .id("customClassName")
                        TextInput(placeholder: "教师（可选）", text: this.teacher)
                            .width(100.percent)
                            .height(44.vp)
                            .margin(top: 8.vp)
                            .onChange({value => this.teacher = value})
                            .id("customClassTeacher")
                        TextInput(placeholder: "教室（可选）", text: this.classroom)
                            .width(100.percent)
                            .height(44.vp)
                            .margin(top: 8.vp)
                            .onChange({value => this.classroom = value})
                            .id("customClassRoom")
                        Text("上课时间（08:30-21:25）")
                            .fontSize(15.vp)
                            .fontWeight(FontWeight.Bold)
                            .margin(top: 16.vp)
                        TextInput(placeholder: "日期 yyyy-MM-dd", text: this.date)
                            .width(100.percent)
                            .height(44.vp)
                            .margin(top: 8.vp)
                            .onChange({value => this.date = value})
                            .id("customClassDate")
                        Row {
                            TextInput(placeholder: "开始 HH:mm", text: this.startTime)
                            .layoutWeight(1)
                            .height(44.vp)
                            .onChange({value => this.startTime = value})
                            .id("customClassStart");
                        TextInput(placeholder: "结束 HH:mm", text: this.endTime)
                            .layoutWeight(1)
                            .height(44.vp)
                            .margin(left: 8.vp)
                            .onChange({value => this.endTime = value})
                            .id("customClassEnd")
                        }.width(100.percent).margin(top: 8.vp)
                        Button("添加时间段")
                            .width(100.percent)
                            .margin(top: 9.vp)
                            .onClick({_ => this.addRange()})
                            .id("customClassAddRange")
                        ForEach(this.ranges,
                            itemGenerator: {
                                range: CustomClassTimeRange, index: Int64 => Row {
                                Text("${range.date}  ${range.timeText()}").layoutWeight(1);
                            Button("移除")
                                .onClick({_ => this.removeRange(index)})
                                .id("customClassRemoveRange_${index}")
                            }
                                .width(100.percent)
                                .padding(10.vp)
                                .margin(top: 7.vp)
                                .backgroundColor(0xFFEAF2FC)
                                .borderRadius(9.vp)
                            })
                        Button("保存课程")
                            .width(100.percent)
                            .margin(top: 14.vp)
                            .onClick({_ => this.save()})
                            .id("customClassSave")
                    }.width(100.percent).padding(bottom: 28.vp).alignItems(HorizontalAlign.Start)
                }.width(100.percent).layoutWeight(1).margin(top: 12.vp)
            } else {
                Scroll {
                    Column {
                        if (this.classes.size == 0) {
                            Text("暂无自定义课程")
                                .fontSize(16.vp)
                                .fontColor(0xFF7A8797)
                                .margin(top: 36.vp)
                                .id("customClassEmpty")
                        }
                        ForEach(this.classes, itemGenerator: {
                            item: CustomClass, index: Int64 => Column {
                                Row {
                                    Text(item.name).fontSize(17.vp).fontWeight(FontWeight.Bold).layoutWeight(1);
                                Button("编辑").onClick({_ => this.startEdit(index)}).id("customClassEdit_${index}");
                                Button("删除")
                                    .margin(left: 6.vp)
                                    .onClick({_ => this.removeClass(index)})
                                    .id("customClassDelete_${index}")
                                }.width(100.percent)
                                Text(
                                    "${if (item.teacher == "") { "教师未知" } else { item.teacher }} · " +
                                    "${if (item.classroom == "") { "地点未知" } else { item.classroom }}"
                                )
                                    .fontSize(12.vp)
                                    .fontColor(0xFF65738A)
                                    .margin(top: 5.vp)
                                ForEach(item.timeRanges,
                                    itemGenerator: {
                                        range: CustomClassTimeRange, _: Int64 => Text(
                                        "${range.date}  ${range.timeText()}").fontSize(13.vp).margin(top: 5.vp)
                                    })
                            }
                                .width(100.percent)
                                .padding(13.vp)
                                .margin(top: 9.vp)
                                .backgroundColor(0xFFFFFFFF)
                                .borderRadius(12.vp)
                                .id("customClassCard_${index}")
                        })
                        if (this.classes.size > 0) {
                            Button("清空全部")
                                .width(100.percent)
                                .margin(top: 14.vp)
                                .backgroundColor(0xFFB54848)
                                .onClick({_ => this.clearAll()})
                                .id("customClassClearAll")
                        }
                    }.width(100.percent).padding(bottom: 28.vp).alignItems(HorizontalAlign.Start)
                }.width(100.percent).layoutWeight(1).margin(top: 10.vp)
            }
        }
            .width(100.percent)
            .height(100.percent)
            .padding(20.vp)
            .alignItems(HorizontalAlign.Start)
            .backgroundColor(0xFFF7F9FC)
    }
}
