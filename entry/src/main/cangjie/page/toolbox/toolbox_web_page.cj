package ohos_app_cangjie_entry.page.toolbox

import kit.ArkUI.*
import kit.ArkWeb.*
import ohos.arkui.state_macro_manage.*
import ohos.business_exception.*
import std.sync.*
import std.time.*

// ArkUI Web exposes page begin/end but no resource-error callback in SDK 6.1.
// This boundary therefore reports controller exceptions and a bounded main-page
// timeout, while retaining explicit retry, web-history back and list return.
@Component
public class ToolboxWebPage {
    let title: String
    let url: String
    let onClose: () -> Unit
    let webController: WebviewController = WebviewController()
    @State var loading: Bool = true
    @State var failed: Bool = false
    @State var status: String = "正在加载网页…"
    var timeoutTimer: ?Timer = None

    protected override func aboutToDisappear(): Unit { this.cancelTimeout() }

    func cancelTimeout(): Unit {
        match (this.timeoutTimer) { case Some(timer) => timer.cancel(); case None => () }
        this.timeoutTimer = None
    }

    func beginLoad(): Unit {
        this.cancelTimeout()
        this.loading = true
        this.failed = false
        this.status = "正在加载${this.title}…"
        this.timeoutTimer = Some(Timer.once(Duration.second * 25, { => launch {
            if (this.loading) {
                this.loading = false
                this.failed = true
                this.status = "网页长时间未完成加载，请检查网络后重试。"
            }
        } }))
    }

    func finishLoad(): Unit {
        this.cancelTimeout()
        this.loading = false
        this.failed = false
        this.status = "${this.title}加载完成。"
    }

    func reload(): Unit {
        this.beginLoad()
        try { this.webController.reload() }
        catch (e: BusinessException) {
            this.cancelTimeout(); this.loading = false; this.failed = true
            this.status = "网页重试失败：${e.code} ${e.message}"
        }
    }

    func webBack(): Unit {
        try {
            if (this.webController.canGoBack()) {
                this.beginLoad()
                this.webController.goBack()
            } else { this.onClose() }
        } catch (e: BusinessException) {
            this.cancelTimeout(); this.loading = false; this.failed = true
            this.status = "网页返回失败：${e.code} ${e.message}"
        }
    }

    func build() {
        Column {
            Row {
                Button("‹").width(42.vp).height(38.vp).onClick({ _ => this.onClose() }).id("toolboxBackToList")
                Text(this.title).fontSize(20.vp).fontWeight(FontWeight.Medium).layoutWeight(1).margin(left: 8.vp)
                Button("网页返回").height(34.vp).fontSize(12.vp).onClick({ _ => this.webBack() }).id("toolboxWebBack")
                if (this.failed) { Button("重试").height(34.vp).fontSize(12.vp).margin(left: 6.vp).onClick({ _ => this.reload() }).id("toolboxWebRetry") }
            }.width(100.percent).height(58.vp).padding(left: 12.vp, right: 12.vp)
            Row {
                if (this.loading) { Text("加载中…").fontSize(12.vp).fontColor(0xFF41699F).margin(right: 8.vp).id("toolboxWebLoading") }
                Text(this.status).fontSize(12.vp).fontColor(if (this.failed) { 0xFFC64545 } else { 0xFF526070 }).layoutWeight(1).id("toolboxStatus")
            }.width(100.percent).padding(left: 16.vp, right: 16.vp, bottom: 6.vp)
            Web(src: this.url, controller: this.webController)
                .domStorageAccess(true).onlineImageAccess(true)
                .onPageBegin({ _ => launch { this.beginLoad() } })
                .onPageEnd({ _ => launch { this.finishLoad() } })
                .width(100.percent).layoutWeight(1).id("toolboxWeb")
        }.width(100.percent).height(100.percent).backgroundColor(0xFFFFFFFF)
    }
}
