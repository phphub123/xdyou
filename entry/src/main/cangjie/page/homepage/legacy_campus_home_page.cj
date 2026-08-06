package ohos_app_cangjie_entry.page.homepage

import kit.ArkUI.*
import kit.ArkWeb.*
import std.collection.ArrayList
import std.time.*
import ohos.arkui.state_macro_manage.*
import ohos.business_exception.*
import ohos_app_cangjie_entry.repository.*
import ohos_app_cangjie_entry.controller.*
import ohos_app_cangjie_entry.external.*

@Component
public class CampusHomePage {
    let onAttendance: () -> Unit
    let onEmptyClassroom: () -> Unit
    let onLibrary: () -> Unit
    let onSchoolnet: () -> Unit
    let onDormWater: () -> Unit
    func build() {
        Scroll { Column {
            Text("校园服务").fontSize(28.vp).fontWeight(FontWeight.Bold)
            Text("查询结果来自学校与校园服务的实时接口").fontSize(13.vp).fontColor(0xFF65738A).margin(top: 5.vp)
            Row {
                Column { Text("课堂考勤").fontSize(18.vp).fontWeight(FontWeight.Bold); Text("学习通考勤、预警与签到明细").fontSize(12.vp).fontColor(0xFF65738A).margin(top: 8.vp) }
                    .layoutWeight(1).height(120.vp).padding(14.vp).backgroundColor(0xFFFFFFFF).borderRadius(14.vp).onClick({ _ => this.onAttendance() }).id("homeClassAttendance")
                Column { Text("空闲教室").fontSize(18.vp).fontWeight(FontWeight.Bold); Text("按日期、教学楼和节次查询").fontSize(12.vp).fontColor(0xFF65738A).margin(top: 8.vp) }
                    .layoutWeight(1).height(120.vp).padding(14.vp).margin(left: 10.vp).backgroundColor(0xFFFFFFFF).borderRadius(14.vp).onClick({ _ => this.onEmptyClassroom() }).id("homeEmptyClassroom")
            }.width(100.percent).margin(top: 18.vp)
            Column { Text("图书馆").fontSize(18.vp).fontWeight(FontWeight.Bold); Text("馆藏检索、图书详情与馆藏位置").fontSize(12.vp).fontColor(0xFF65738A).margin(top: 8.vp) }
                .width(100.percent).height(105.vp).padding(14.vp).margin(top: 10.vp).backgroundColor(0xFFFFFFFF).borderRadius(14.vp).onClick({ _ => this.onLibrary() }).id("homeLibrary")
            Column { Text("校园网").fontSize(18.vp).fontWeight(FontWeight.Bold); Text("当前在线账号、流量、余额与设备").fontSize(12.vp).fontColor(0xFF65738A).margin(top: 8.vp) }
                .width(100.percent).height(105.vp).padding(14.vp).margin(top: 10.vp).backgroundColor(0xFFFFFFFF).borderRadius(14.vp).onClick({ _ => this.onSchoolnet() }).id("homeSchoolnet")
            Column { Text("宿舍饮水").fontSize(18.vp).fontWeight(FontWeight.Bold); Text("短信登录、收藏设备与启停供水").fontSize(12.vp).fontColor(0xFF65738A).margin(top: 8.vp) }
                .width(100.percent).height(105.vp).padding(14.vp).margin(top: 10.vp).backgroundColor(0xFFFFFFFF).borderRadius(14.vp).onClick({ _ => this.onDormWater() }).id("homeDormWater")
            Row {
                Column { Text("教务中心").fontSize(18.vp).fontWeight(FontWeight.Bold); Text("课表、成绩、考试").fontSize(12.vp).fontColor(0xFF65738A).margin(top: 8.vp) }
                    .layoutWeight(1).height(110.vp).padding(14.vp).backgroundColor(0xFFEAF2FF).borderRadius(14.vp).id("homeAcademicSummary")
                Column { Text("校园工具").fontSize(18.vp).fontWeight(FontWeight.Bold); Text("缴费、订水、报修、预约与网络").fontSize(12.vp).fontColor(0xFF65738A).margin(top: 8.vp) }
                    .layoutWeight(1).height(110.vp).padding(14.vp).margin(left: 10.vp).backgroundColor(0xFFEAF2FF).borderRadius(14.vp).id("homeToolboxSummary")
            }.width(100.percent).margin(top: 10.vp)
        }.width(100.percent).padding(20.vp).alignItems(HorizontalAlign.Start) }.width(100.percent).layoutWeight(1)
    }
}
