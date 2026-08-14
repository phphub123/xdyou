package ohos_app_cangjie_entry.page.library

import kit.ArkUI.*
import ohos.arkui.state_macro_manage.*
import std.collection.*
import std.time.*
import ohos.resource.*
import ohos_app_cangjie_entry.controller.*
import ohos_app_cangjie_entry.model.xidian_ids.*
import ohos_app_cangjie_entry.components.*

@Component
public class LibraryPage {
    let onBack: () -> Unit
    let controller = LibraryController()
    @State var tab: Int64 = 0
    @State var loading: Bool = false
    @State var status: String = "正在读取借阅信息…"
    @State var borrows: ArrayList<BorrowData> = ArrayList<BorrowData>()
    @State var keyword: String = ""
    @State var books: ArrayList<BookInfo> = ArrayList<BookInfo>()
    var authRaw: String = ""
    var authCookies: String = ""

    protected override func aboutToAppear(): Unit { this.reloadBorrows() }
    func reloadBorrows(): Unit {
        if (this.authRaw == "") { this.loading = false; this.status = "正在完成图书馆认证…"; return }
        if (this.loading) { return }; this.loading = true; this.status = "正在读取真实借阅信息…"
        this.controller.borrowsAuthorized(this.authRaw, this.authCookies, { items => launch { this.borrows = items; this.loading = false
            this.status = if (items.size == 0) { "当前没有在借图书" } else { "在借 ${items.size} 本图书" }
        } }, { message => launch { this.loading = false; this.status = message } })
    }
    func search(): Unit {
        if (this.loading || this.keyword.trimAscii() == "") { return }; this.loading = true; this.status = "正在检索馆藏…"
        this.controller.search(this.keyword, "keyWord", 1, { items => launch { this.books = items; this.loading = false; this.status = "已找到 ${items.size} 条馆藏" } },
            { message => launch { this.loading = false; this.status = message } })
    }
    func dateOnly(value: String): String { return if (value.size >= 10) { value[0..10] } else { value } }
    func normalizedDate(value: String): String {
        let raw = this.dateOnly(value)
        let slash = raw.split("/")
        if (slash.size == 3) { return "${slash[0]}-${slash[1]}-${slash[2]}" }
        return raw
    }
    func dateYear(value: String): String {
        let parts = this.normalizedDate(value).split("-")
        return if (parts.size == 3) { parts[0] } else { "----" }
    }
    func shortDate(value: String): String {
        let parts = this.normalizedDate(value).split("-")
        if (parts.size != 3) { return "--/--" }
        var month = parts[1]
        var day = parts[2]
        if (month.startsWith("0") && month.size > 1) { month = month[1..month.size] }
        return "${month}/${day}"
    }
    func lendDays(value: String): Int64 {
        try {
            let due = DateTime.parse(this.normalizedDate(value), "yyyy-MM-dd")
            return (due.toUnixTimeStamp().toSeconds() - DateTime.now().toUnixTimeStamp().toSeconds()) / 86400
        } catch (_) {
            return 0
        }
    }
    func overdue(value: String): Bool { let date=this.dateOnly(value);return date!="" && date.compare(DateTime.now().format("yyyy-MM-dd")) == Ordering.LT }
    func overdueCount(): Int64 { var count:Int64=0;for(item in this.borrows){if(this.overdue(item.normReturnDate)){count+=1}};return count }

    func selectBorrowTab(): Unit {
        this.tab = 0
        if (this.borrows.size == 0 && !this.loading) { this.reloadBorrows() }
    }

    @Builder
    func tabButton(title: String, index: Int64, stableId: String) {
        Column {
            Text(title)
                .width(100.percent)
                .height(42.vp)
                .fontSize(14.vp)
                .fontColor(if (this.tab == index) { 0xFF31343B } else { 0xFF777A83 })
                .textAlign(TextAlign.Center)
            Divider()
                .width(if (this.tab == index) { 48.vp } else { 0.vp })
                .strokeWidth(2.vp)
                .color(0xFF22242A)
        }
            .layoutWeight(1)
            .height(44.vp)
            .onClick({_ => if (index == 0) { this.selectBorrowTab() } else { this.tab = 1 }})
            .id(stableId)
    }

    @Builder
    func bookCover(item: BorrowData) {
        if (item.imageUrl != "") {
            Image(item.imageUrl)
                .width(70.vp)
                .height(108.vp)
                .objectFit(ImageFit.Cover)
                .borderRadius(5.vp)
        } else {
            Column {
                Image(@r(app.media.home_book)).width(30.vp).height(30.vp).fillColor(0xFF8A7456)
                Text("暂无封面").fontSize(9.vp).fontColor(0xFF8A7456).margin(top: 8.vp)
            }
                .width(70.vp)
                .height(108.vp)
                .justifyContent(FlexAlign.Center)
                .backgroundColor(0xFFF3DEB5)
                .borderRadius(5.vp)
        }
    }

    @Builder
    func borrowCard(item: BorrowData, index: Int64) {
        Row {
            this.bookCover(item)
            Column {
                Text(item.title)
                    .width(100.percent)
                    .fontSize(17.vp)
                    .fontWeight(FontWeight.Bold)
                    .fontColor(0xFF20242B)
                    .maxLines(2)
                Row {
                    Column {
                        Text(this.dateYear(item.loanDate)).fontSize(9.vp).fontColor(0xFF65738A)
                        Text(this.shortDate(item.loanDate)).fontSize(15.vp).fontWeight(FontWeight.Bold).margin(top: 2.vp)
                        Text("借阅").fontSize(10.vp).fontColor(0xFF65738A)
                    }.alignItems(HorizontalAlign.Start)
                    Text("······")
                        .fontSize(11.vp)
                        .fontColor(0xFF9AA1AC)
                        .layoutWeight(1)
                        .textAlign(TextAlign.Center)
                    Column {
                        Text(this.dateYear(item.normReturnDate)).fontSize(9.vp).fontColor(0xFF65738A)
                        Text(this.shortDate(item.normReturnDate)).fontSize(15.vp).fontWeight(FontWeight.Bold).margin(top: 2.vp)
                        Text("到期").fontSize(10.vp).fontColor(0xFF65738A)
                    }.alignItems(HorizontalAlign.Start)
                }.width(100.percent).margin(top: 8.vp)
                Row {
                    Text("${if (this.lendDays(item.normReturnDate) < 0) { -this.lendDays(item.normReturnDate) } else { this.lendDays(item.normReturnDate) }}")
                        .fontSize(23.vp)
                        .fontWeight(FontWeight.Bold)
                        .fontColor(if (this.lendDays(item.normReturnDate) < 0) { 0xFFFF453A } else { 0xFF20242B })
                    Text(if (this.lendDays(item.normReturnDate) < 0) { " 天前到期" } else { " 天后到期" })
                        .fontSize(10.vp)
                        .fontColor(0xFF65738A)
                        .layoutWeight(1)
                    Text(if (this.lendDays(item.normReturnDate) < 0) { "不可续借" } else { "可续借" })
                        .fontSize(11.vp)
                        .fontColor(0xFF46699D)
                }.width(100.percent).alignItems(VerticalAlign.Bottom).margin(top: 6.vp)
            }.layoutWeight(1).margin(left: 14.vp).alignItems(HorizontalAlign.Start)
        }
            .width(100.percent)
            .height(132.vp)
            .padding(12.vp)
            .margin(top: 10.vp)
            .backgroundColor(0xFFF0F1F8)
            .borderRadius(12.vp)
            .id("libraryBorrow_${index}")
    }

    func build() {
        Column {
            PageHeader(title: "图书馆信息", onBack: this.onBack, backId: "libraryBack")
            Row {
                this.tabButton("借书状态", 0, "libraryBorrowTab")
                this.tabButton("查询藏书", 1, "librarySearchTab")
            }.width(100.percent).height(45.vp)
            Divider().width(100.percent).strokeWidth(1.vp).color(0xFFD5D8E2)
            if (this.tab == 0) {
                if (this.loading) {
                    Column {
                        LoadingProgress().width(34.vp).height(34.vp).color(0xFF46699D)
                        Text(this.status).fontSize(12.vp).fontColor(0xFF65738A).margin(top: 10.vp).id("libraryStatus")
                    }.width(100.percent).layoutWeight(1).justifyContent(FlexAlign.Center)
                } else if (this.borrows.size == 0) {
                    Column {
                        Image(@r(app.media.home_book)).width(52.vp).height(52.vp).fillColor(0xFF9AA4B3)
                        Text(this.status).fontSize(13.vp).fontColor(0xFF65738A).margin(top: 12.vp).id("libraryStatus")
                        Button("重新加载").height(36.vp).margin(top: 14.vp).onClick({_ => this.reloadBorrows()}).id("libraryRetry")
                    }.width(100.percent).layoutWeight(1).justifyContent(FlexAlign.Center)
                } else {
                    Scroll { Column {
                        ForEach(this.borrows,itemGenerator:{item:BorrowData,index:Int64=>this.borrowCard(item, index)})
                    }.width(100.percent).padding(left: 10.vp, right: 10.vp, bottom: 10.vp) }
                        .width(100.percent).layoutWeight(1).align(Alignment.TopStart)
                }
                Text("在借 ${this.borrows.size} 本，其中已过期 ${this.overdueCount()} 本")
                    .width(100.percent).height(44.vp).padding(left: 12.vp, right: 12.vp)
                    .fontSize(13.vp).fontColor(0xFF20242B).backgroundColor(0xFFF0F1F8).id("libraryBorrowSummary")
            } else {
                Column {
                    Row {
                        Column {
                            Text("搜索字段").fontSize(10.vp).fontColor(0xFF65738A)
                                .width(100.percent).margin(left: 10.vp, top: 3.vp)
                            Row {
                                Text("任意词").fontSize(12.vp).layoutWeight(1)
                                Text("⌄").fontSize(12.vp)
                            }.width(100.percent).padding(left: 10.vp, right: 10.vp)
                        }.width(112.vp).height(42.vp).border(width: 1.vp, color: 0xFF20242B, radius: 8.vp)
                        Row {
                            Image(@r(app.media.action_search)).width(16.vp).height(16.vp).margin(left: 10.vp, right: 7.vp)
                            TextInput(placeholder:"在此搜索",text:this.keyword).layoutWeight(1).height(40.vp)
                                .fontSize(12.vp).backgroundColor(Color.Transparent)
                                .border(width:0.vp,color:Color.Transparent,radius:0.vp)
                                .onChange({v=>this.keyword=v}).id("librarySearchInput")
                        }.layoutWeight(1).height(42.vp).margin(left: 7.vp)
                            .border(width: 1.vp, color: 0xFF20242B, radius: 8.vp)
                    }.width(100.percent)
                    Row {
                        Text("⌄  更多搜索选项").fontSize(11.vp).fontColor(0xFF476FA9).layoutWeight(1)
                        Button("搜索").width(80.vp).height(36.vp).fontSize(12.vp)
                            .buttonStyle(ButtonStyleMode.Normal).backgroundColor(0xFF476FA9)
                            .onClick({_=>this.search()}).id("librarySearchButton")
                    }.width(100.percent).margin(top: 9.vp)
                }.width(100.percent).padding(9.vp).margin(top: 10.vp)
                    .backgroundColor(0xFFF0F1F8).borderRadius(8.vp)
                Text(this.status).fontSize(12.vp).fontColor(0xFF65738A).margin(top:8.vp)
                Scroll { Column { ForEach(this.books,itemGenerator:{book:BookInfo,index:Int64=>Column {
                    Text(book.bookName).fontSize(16.vp).fontWeight(FontWeight.Bold)
                    Text("${book.author} · ${book.publisher} · 可借 ${book.availableCount}/${book.storageCount}").fontSize(12.vp).fontColor(0xFF65738A).margin(top:6.vp)
                }.width(100.percent).padding(13.vp).margin(top:8.vp).backgroundColor(0xFFFFFFFF).borderRadius(10.vp).alignItems(HorizontalAlign.Start).id("libraryBook_${index}")}) }.width(100.percent) }.width(100.percent).layoutWeight(1)
            }
            ServiceAuthWeb(
                url: "https://tyrzfw.chaoxing.com/auth/xidian/cas/init?isLogout=0&refer=https%3A%2F%2Fmfindxidian.libsp.cn%2Ffind%2Fsso%2Flogin%2Fxidian%2F1",
                cookieUrl: "https://mfindxidian.libsp.cn",
                stableId: "libraryAuthWeb",
                requireOpenId: false,
                onReady: { url: String, payload: String, cookies: String => this.authRaw = url + "|" + payload; this.authCookies = cookies; this.reloadBorrows() },
                onFailure: { message: String => this.loading = false; this.status = message }
            )
        }.width(100.percent).height(100.percent).padding(left: 12.vp, right: 12.vp, top: 12.vp)
            .backgroundColor(0xFFF9FAFC).alignItems(HorizontalAlign.Start)
    }
}
