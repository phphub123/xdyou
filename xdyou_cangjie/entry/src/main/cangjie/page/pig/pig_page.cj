package ohos_app_cangjie_entry.page.pig

// 猪图鉴赏页面，加载远端图片并处理刷新、空态和错误态。

import kit.ArkUI.*
import kit.ArkWeb.*
import ohos.arkui.state_macro_manage.*
import ohos.business_exception.*
import ohos.resource.*
import ohos_app_cangjie_entry.repository.*

@Component
public class AlignedPigPage {
    let session: PigHubSession = PigHubSession()
    @State var imageUrl: String = ""
    @State var title: String = ""
    @State var loading: Bool = false
    @State var imageLoading: Bool = false
    @State var errorMessage: String = ""
    @State var saveHint: String = ""

    protected override func aboutToAppear(): Unit {
        this.loadPig(true)
    }

    func loadPig(forceRefresh: Bool): Unit {
        if (this.loading) {
            return
        }
        this.loading = true
        this.errorMessage = ""
        this.saveHint = ""
        this.session.getRandomPig(
            forceRefresh,
            {
                pig => launch {
                    this.imageUrl = pig.url
                    this.title = pig.title
                    this.imageLoading = true
                    this.loading = false
                }
            },
            {
                message => launch {
                    this.loading = false
                    this.imageLoading = false
                    this.errorMessage = message
                }
            }
        )
    }

    func imageLoaded(): Unit {
        this.imageLoading = false
    }
    func imageFailed(): Unit {
        this.imageLoading = false
        this.errorMessage = "豬圖加載失敗，請重試。"
    }

    func build() {
        Column {
            Row {
                Text("豬圖鑑賞").fontSize(22.vp).fontWeight(FontWeight.Medium).fontColor(0xFF202229).layoutWeight(1)
                Image(@r(app.media.action_refresh))
                    .width(27.vp)
                    .height(27.vp)
                    .fillColor(0xFF4A4E58)
                    .padding(6.vp)
                    .onClick({_ => this.loadPig(true)})
                    .id("pigRefresh")
            }.width(100.percent).height(58.vp).padding(left: 20.vp, right: 17.vp)
            Column {
                Text("本程序將開發一個新主頁，目前先用豬圖秀佔位，玩得愉快")
                    .width(100.percent)
                    .fontSize(14.vp)
                    .fontColor(0xFF22242A)
                    .textAlign(TextAlign.Center)
                if (this.loading) {
                    Column {
                        LoadingProgress().width(42.vp).height(42.vp).color(0xFF476FA9)
                        Text("正在尋找一隻豬…")
                            .fontSize(14.vp)
                            .fontColor(0xFF545965)
                            .margin(top: 14.vp)
                            .id("pigLoadStatus")
                    }.width(300.vp).height(330.vp).justifyContent(FlexAlign.Center)
                } else if (this.errorMessage != "") {
                    Column {
                        Text("!")
                            .width(52.vp)
                            .height(52.vp)
                            .fontSize(34.vp)
                            .fontWeight(FontWeight.Bold)
                            .fontColor(0xFF6A6F79)
                            .textAlign(TextAlign.Center)
                            .border(width: 2.vp, color: 0xFF6A6F79)
                            .borderRadius(26.vp)
                        Text("Failed to fetch a pig :(")
                            .fontSize(17.vp)
                            .fontWeight(FontWeight.Medium)
                            .margin(top: 14.vp)
                        Text(this.errorMessage)
                            .width(100.percent)
                            .fontSize(12.vp)
                            .fontColor(0xFF646A75)
                            .textAlign(TextAlign.Center)
                            .margin(top: 8.vp)
                            .id("pigError")
                        Row {
                            Image(@r(app.media.action_refresh)).width(19.vp).height(19.vp).fillColor(0xFFFFFFFF);
                            Text("Try Again").fontSize(14.vp).fontColor(0xFFFFFFFF).margin(left: 8.vp)
                        }
                            .width(150.vp)
                            .height(42.vp)
                            .justifyContent(FlexAlign.Center)
                            .backgroundColor(0xFF476FA9)
                            .borderRadius(21.vp)
                            .margin(top: 16.vp)
                            .onClick({_ => this.loadPig(true)})
                            .id("pigTryAgain")
                    }.width(100.percent).height(390.vp).justifyContent(FlexAlign.Center)
                } else {
                    Stack {
                        Image(this.imageUrl)
                            .width(300.vp)
                            .height(300.vp)
                            .objectFit(ImageFit.Contain)
                            .borderRadius(12.vp)
                            .onComplete({_ => this.imageLoaded()})
                            .onError({_ => this.imageFailed()})
                            .id("pigImage")
                        if (this.imageLoading) {
                            LoadingProgress().width(42.vp).height(42.vp).color(0xFF476FA9)
                        }
                    }.width(300.vp).height(300.vp).margin(top: 12.vp)
                    Text(this.title)
                        .fontSize(16.vp)
                        .fontColor(0xFF22242A)
                        .textAlign(TextAlign.Center)
                        .margin(top: 8.vp)
                        .id("pigTitle")
                    Row {
                        Image(@r(app.media.action_shuffle)).width(19.vp).height(19.vp).fillColor(0xFF41699F);
                        Text("Change A Pig").fontSize(14.vp).fontColor(0xFF41699F).margin(left: 9.vp)
                    }
                        .width(170.vp)
                        .height(42.vp)
                        .justifyContent(FlexAlign.Center)
                        .border(width: 1.vp, color: 0xFF41699F)
                        .borderRadius(12.vp)
                        .margin(top: 24.vp)
                        .onClick({_ => this.loadPig(false)})
                        .id("pigShuffle")
                    Row {
                        Image(@r(app.media.action_save)).width(19.vp).height(19.vp).fillColor(0xFF41699F);
                        Text("Save this Pig").fontSize(14.vp).fontColor(0xFF41699F).margin(left: 9.vp)
                    }
                        .width(170.vp)
                        .height(42.vp)
                        .justifyContent(FlexAlign.Center)
                        .border(width: 1.vp, color: 0xFF41699F)
                        .borderRadius(12.vp)
                        .margin(top: 9.vp)
                        .onClick({_ => this.saveHint = "請長按圖片使用系統圖片菜單保存"})
                        .id("pigSave")
                    if (this.saveHint != "") {
                        Text(this.saveHint).fontSize(11.vp).fontColor(0xFF646A75).margin(top: 8.vp).id("pigSaveHint")
                    }
                }
            }
                .width(100.percent)
                .layoutWeight(1)
                .padding(left: 24.vp, right: 24.vp)
                .justifyContent(FlexAlign.Center)
                .alignItems(HorizontalAlign.Center)
        }.width(100.percent).height(100.percent).backgroundColor(0xFFFFFFFF)
    }
}
