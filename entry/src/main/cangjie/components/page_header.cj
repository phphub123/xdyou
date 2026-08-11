package ohos_app_cangjie_entry.components

import kit.ArkUI.*
import ohos.arkui.state_macro_manage.*

@Builder
public func EmptyPageHeaderTrailing() {}

@Component
public class PageHeader {
    let title: String
    let onBack: () -> Unit
    let backId: String
    var titleId: String = ""
    @BuilderParam var trailing: () -> Unit = EmptyPageHeaderTrailing

    func build() {
        Row {
            Button("←").width(38.vp).height(38.vp).fontSize(23.vp)
                .fontColor(0xFF20242B).buttonStyle(ButtonStyleMode.Textual).backgroundColor(Color.Transparent)
                .onClick({ _ => this.onBack() }).id(this.backId)
            if (this.titleId == "") {
                Text(this.title).fontSize(22.vp).fontWeight(FontWeight.Medium).layoutWeight(1).margin(left: 8.vp)
            } else {
                Text(this.title).fontSize(22.vp).fontWeight(FontWeight.Medium).layoutWeight(1).margin(left: 8.vp).id(this.titleId)
            }
            this.trailing()
        }.width(100.percent).height(44.vp)
    }
}