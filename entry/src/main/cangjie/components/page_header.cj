package ohos_app_cangjie_entry.components

// 页面通用标题栏、刷新动作与搜索输入组件，统一子页面的导航和交互样式。

import kit.ArkUI.*
import ohos.arkui.state_macro_manage.*
import ohos.resource.*

@Builder
public func EmptyPageHeaderTrailing() {}

// 标题栏右侧的标准刷新按钮；actionId 供自动化验收稳定定位。
@Component
public class HeaderRefreshAction {
    let onRefresh: () -> Unit
    let actionId: String

    func build() {
        Button {
            Image(@r(app.media.action_refresh))
                .width(18.vp)
                .height(18.vp)
                .fillColor(0xFF20242B)
                .objectFit(ImageFit.Contain)
        }
            .width(38.vp)
            .height(38.vp)
            .padding(9.vp)
            .buttonStyle(ButtonStyleMode.Textual)
            .backgroundColor(Color.Transparent)
            .onClick({ _ => this.onRefresh() })
            .id(this.actionId)
    }
}

// 受控搜索框：文本状态由调用页面持有，组件只转发输入变化。
@Component
public class PageSearchField {
    let placeholder: String
    let value: String
    let onChange: (String) -> Unit
    let fieldId: String

    func build() {
        Row {
            Image(@r(app.media.action_search))
                .width(18.vp)
                .height(18.vp)
                .objectFit(ImageFit.Contain)
                .margin(left: 11.vp, right: 7.vp)
            TextInput(placeholder: this.placeholder, text: this.value)
                .layoutWeight(1)
                .height(38.vp)
                .fontSize(13.vp)
                .backgroundColor(Color.Transparent)
                .border(width: 0.vp, color: Color.Transparent, radius: 0.vp)
                .onChange({ value => this.onChange(value) })
                .id(this.fieldId)
        }.width(100.percent).height(42.vp).backgroundColor(0xFFF7F7FC)
            .border(width: 1.vp, color: 0xFF697386, radius: 8.vp)
    }
}

// 子页面统一标题栏；trailing 允许调用方注入刷新等附加动作。
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
        }.width(100.percent).height(48.vp).backgroundColor(0xFFF7F7FC)
    }
}
