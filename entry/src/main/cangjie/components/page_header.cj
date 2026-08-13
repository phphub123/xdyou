package ohos_app_cangjie_entry.components

import kit.ArkUI.*
import ohos.arkui.state_macro_manage.*
import ohos.resource.*

@Builder
public func EmptyPageHeaderTrailing() {}

@Component
public class HeaderRefreshAction {
    let onRefresh: () -> Unit
    let actionId: String

    func build() {
        Button {
            Image(@r(app.media.action_refresh))
                .width(20.vp)
                .height(20.vp)
                .fillColor(0xFF20242B)
                .objectFit(ImageFit.Contain)
        }
            .width(40.vp)
            .height(40.vp)
            .padding(10.vp)
            .buttonStyle(ButtonStyleMode.Textual)
            .backgroundColor(Color.Transparent)
            .onClick({ _ => this.onRefresh() })
            .id(this.actionId)
    }
}

@Component
public class PageHeader {
    let title: String
    let onBack: () -> Unit
    let backId: String
    var titleId: String = ""
    @BuilderParam var trailing: () -> Unit = EmptyPageHeaderTrailing

    func build() {
        Row {
            Button {
                Image(@r(app.media.action_back))
                    .width(22.vp)
                    .height(22.vp)
                    .fillColor(0xFF20242B)
                    .objectFit(ImageFit.Contain)
            }
                .width(40.vp)
                .height(40.vp)
                .padding(9.vp)
                .buttonStyle(ButtonStyleMode.Textual)
                .backgroundColor(Color.Transparent)
                .onClick({ _ => this.onBack() })
                .id(this.backId)
            if (this.titleId == "") {
                Text(this.title).fontSize(20.vp).fontWeight(FontWeight.Medium).fontColor(0xFF20242B)
                    .layoutWeight(1).margin(left: 8.vp)
            } else {
                Text(this.title).fontSize(20.vp).fontWeight(FontWeight.Medium).fontColor(0xFF20242B)
                    .layoutWeight(1).margin(left: 8.vp).id(this.titleId)
            }
            this.trailing()
        }.width(100.percent).height(48.vp)
    }
}
