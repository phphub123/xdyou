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
            Button("‹").width(44.vp).height(40.vp).onClick({ _ => this.onBack() }).id(this.backId)
            if (this.titleId == "") {
                Text(this.title).fontSize(24.vp).fontWeight(FontWeight.Bold).layoutWeight(1).margin(left: 8.vp)
            } else {
                Text(this.title).fontSize(24.vp).fontWeight(FontWeight.Bold).layoutWeight(1).margin(left: 8.vp).id(this.titleId)
            }
            this.trailing()
        }.width(100.percent)
    }
}
