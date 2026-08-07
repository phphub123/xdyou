package ohos_app_cangjie_entry.page.toolbox

import kit.ArkUI.*
import kit.ArkWeb.*
import ohos.arkui.state_macro_manage.*
import ohos.business_exception.*

@Component
public class ToolboxPage {
    let webController = WebviewController()
    @State var title: String = "缴费"
    @State var loading: Bool = true
    @State var status: String = "正在加载校园缴费。"
    func open(name: String, url: String): Unit {
        try {
            this.title = name
            this.loading = true
            this.status = "正在加载${name}。"
            this.webController.loadUrl(url)
        } catch (e: BusinessException) {
            this.loading = false
            this.status = "无法打开${name}：${e.code} ${e.message}"
        }
    }
    func back(): Unit {
        try {
            if (this.webController.canGoBack()) {
                this.webController.goBack();
                this.loading = true
                this.status = "正在返回上一页。"
            } else {
                this.status = "当前网页没有可返回的历史页面。"
            }
        } catch (e: BusinessException) {
            this.status = "网页返回失败：${e.code} ${e.message}"
        }
    }
    func build() {
        Column {
            Row {
                Text("工具箱 · ${this.title}").fontSize(22.vp).fontWeight(FontWeight.Bold).layoutWeight(1)
                Button("网页返回").onClick({_ => this.back()}).id("toolboxWebBack")
            }.width(100.percent).padding(left: 14.vp, right: 14.vp, top: 8.vp)
            Row {
                Button("缴费")
                    .layoutWeight(1)
                    .onClick(
                        {
                            _ => this.open(
                                "缴费",
                                "https://xxcapp.xidian.edu.cn/uc/api/oauth/index?redirect=" +
                                "https%3A%2F%2Fignypt.xidian.edu.cn%2FrevenueH5%2Flogin%3Fopcode%3DMPAY%26" +
                                "appid%3D200260318155520600%26state%3D1231231231"
                            )
                        })
                    .id("toolboxPayment")
                Button("订水")
                    .layoutWeight(1)
                    .onClick({_ => this.open("订水", "https://order.xidian.edu.cn/mobile/thirdoauth/oauth2Xidian/1")})
                    .id("toolboxWater")
                Button("报修")
                    .layoutWeight(1)
                    .onClick(
                        {
                            _ => this.open("报修",
                            "https://ids.xidian.edu.cn/authserver/login?service=" +
                            "https%3A%2F%2Frepair.xidian.edu.cn%2Fappsys%2FxidianCasLogin%2FoauthLogin")
                        })
                    .id("toolboxRepair")
                Button("预约")
                    .layoutWeight(1)
                    .onClick({_ => this.open("空间预约", "http://libspace.xidian.edu.cn")})
                    .id("toolboxReserve")
            }.width(100.percent).padding(left: 8.vp, right: 8.vp, top: 6.vp)
            Row {
                Button("网络")
                    .layoutWeight(1)
                    .onClick({_ => this.open("校园网络", "https://zfw.xidian.edu.cn")})
                    .id("toolboxNetwork")
                Button("物理计算")
                    .layoutWeight(1)
                    .onClick({_ => this.open("物理计算", "https://experiment-helper.wizzstudio.com/#/")})
                    .id("toolboxPhysics")
                Button("睿思导航")
                    .layoutWeight(1)
                    .onClick({_ => this.open("睿思导航", "https://nav.xdruisi.cn/")})
                    .id("toolboxDiscover")
            }.width(100.percent).padding(left: 8.vp, right: 8.vp, top: 4.vp)
            Text(this.status)
                .fontSize(11.vp)
                .fontColor(0xFF5F6368)
                .padding(left: 14.vp, top: 4.vp)
                .id("toolboxWebStatus")
            Web(
                src: "https://xxcapp.xidian.edu.cn/uc/api/oauth/index?redirect=" +
                    "https%3A%2F%2Fignypt.xidian.edu.cn%2FrevenueH5%2Flogin%3Fopcode%3DMPAY%26" +
                    "appid%3D200260318155520600%26state%3D1231231231",
                controller: this.webController)
                .onPageBegin({_ => launch {this.loading = true}})
                .onPageEnd({
                    _ => launch {
                    this.loading = false
                this.status = "${this.title}加载完成。"
                }
                })
                .width(100.percent)
                .layoutWeight(1)
                .id("toolboxWeb")
        }.width(100.percent).height(100.percent)
    }
}
