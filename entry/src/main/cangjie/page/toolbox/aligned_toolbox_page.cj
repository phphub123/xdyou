package ohos_app_cangjie_entry.page.toolbox

import kit.ArkUI.*
import kit.ArkWeb.*
import ohos.arkui.state_macro_manage.*
import ohos.business_exception.*
import ohos.resource.*
import ohos_app_cangjie_entry.repository.*

@Component
public class AlignedToolboxPage {
    @State var showWeb: Bool = false
    @State var title: String = ""
    @State var url: String = ""

    func open(name: String, url: String): Unit {
        this.title = name
        this.url = url
        this.showWeb = true
    }

    func build() {
        if (this.showWeb) {
            ToolboxWebPage(title: this.title, url: this.url, onClose: {=> this.showWeb = false})
        } else {
            Column {
                Row {
                    Text("其他功能")
                        .fontSize(22.vp)
                        .fontWeight(FontWeight.Medium)
                        .fontColor(0xFF202229)
                        .layoutWeight(1)
                }.width(100.percent).height(58.vp).padding(left: 20.vp, right: 16.vp)
                Scroll {
                    Column {
                        AlignedToolRow(icon: @r(app.media.toolbox_payment), title: "繳費系統",
                            description: "電費該交了吧", stableId: "toolboxPayment",
                            onTap: {
                                => this.open(
                                    "繳費系統",
                                    "https://xxcapp.xidian.edu.cn/uc/api/oauth/index?redirect=" +
                                    "https://ignypt.xidian.edu.cn/revenueH5/login?opcode=MPAY&" +
                                    "appid=200260318155520600&state=1231231231"
                                )
                            })
                        AlignedToolRow(
                            icon: @r(app.media.toolbox_water),
                            title: "訂水系統",
                            description: "喝水對身體好",
                            stableId: "toolboxWater",
                            onTap: {
                                => this.open(
                                    "訂水系統",
                                    "https://order.xidian.edu.cn/mobile/thirdoauth/oauth2Xidian/1"
                                )
                            }
                        )
                        AlignedToolRow(icon: @r(app.media.toolbox_repair), title: "後勤報修",
                            description: "不要漏水斷網", stableId: "toolboxRepair",
                            onTap: {
                                => this.open("後勤報修",
                                "https://ids.xidian.edu.cn/authserver/login?service=" +
                                "https%3A%2F%2Fids.xidian.edu.cn%2Fauthserver%2Foauth2.0%2FcallbackAuthorize%3F" +
                                "client_id%3D869608421533880320%26redirect_uri%3D" +
                                "http%253A%252F%252Frepair.xidian.edu.cn%252Fappsys%252F" +
                                "xidianCasLogin%252FoauthLogin%26client_name%3DCasOAuthClient")
                            })
                        AlignedToolRow(icon: @r(app.media.toolbox_reserve), title: "空間預約",
                            description: "找個地方打牌", stableId: "toolboxReserve",
                            onTap: {
                                => this.open("空間預約", "http://libspace.xidian.edu.cn")
                            })
                        AlignedToolRow(icon: @r(app.media.toolbox_network), title: "網絡查詢",
                            description: "希望永不收費", stableId: "toolboxNetwork",
                            onTap: {
                                => this.open("網絡查詢", "https://zfw.xidian.edu.cn")
                            })
                        AlignedToolRow(icon: @r(app.media.toolbox_calculator), title: "物理計算",
                            description: "希望操作順利", stableId: "toolboxPhysics",
                            onTap: {=> this.open("物理計算", "https://experiment-helper.wizzstudio.com/#/")})
                        AlignedToolRow(icon: @r(app.media.toolbox_discover), title: "睿思導航",
                            description: "補充其他功能", stableId: "toolboxDiscover",
                            onTap: {=> this.open("睿思導航", "https://nav.xdruisi.cn/")})
                        Blank().height(12.vp)
                    }.width(100.percent)
                }.width(100.percent).layoutWeight(1).align(Alignment.TopStart)
            }.width(100.percent).height(100.percent).backgroundColor(0xFFFFFFFF)
        }
    }
}

@Component
public class AlignedToolRow {
    let icon: AppResource
    let title: String
    let description: String
    let stableId: String
    let onTap: () -> Unit
    func build() {
        Row {
            Image(this.icon).width(25.vp).height(25.vp).objectFit(ImageFit.Contain).fillColor(0xFF50545E)
            Column {
                Text(this.title).fontSize(16.vp).fontWeight(FontWeight.Normal).fontColor(0xFF22242A)
                Text(this.description).fontSize(14.vp).fontColor(0xFF545965).margin(top: 4.vp)
            }.layoutWeight(1).margin(left: 16.vp).alignItems(HorizontalAlign.Start)
        }
            .width(100.percent)
            .height(72.vp)
            .padding(left: 18.vp, right: 18.vp)
            .backgroundColor(0xFFFFFFFF)
            .onClick({_ => this.onTap()})
            .id(this.stableId)
    }
}
