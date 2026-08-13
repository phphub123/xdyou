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
    func overdue(value: String): Bool { let date=this.dateOnly(value);return date!="" && date.compare(DateTime.now().format("yyyy-MM-dd")) == Ordering.LT }
    func overdueCount(): Int64 { var count:Int64=0;for(item in this.borrows){if(this.overdue(item.normReturnDate)){count+=1}};return count }
    func build() {
        Column {
            PageHeader(title: "图书馆信息", onBack: this.onBack, backId: "libraryBack")
            Row {
                Column {
                    Button("借书状态").width(100.percent).height(38.vp).fontSize(12.vp)
                        .buttonStyle(ButtonStyleMode.Textual).backgroundColor(Color.Transparent)
                        .fontColor(0xFF20242B).onClick({_=>this.tab=0}).id("libraryBorrowTab")
                    Divider().width(46.vp).strokeWidth(2.vp).color(if(this.tab==0){0xFF20242B}else{0x00FFFFFF})
                }.layoutWeight(1)
                Column {
                    Button("查询藏书").width(100.percent).height(38.vp).fontSize(12.vp)
                        .buttonStyle(ButtonStyleMode.Textual).backgroundColor(Color.Transparent)
                        .fontColor(0xFF20242B).onClick({_=>this.tab=1}).id("librarySearchTab")
                    Divider().width(46.vp).strokeWidth(2.vp).color(if(this.tab==1){0xFF20242B}else{0x00FFFFFF})
                }.layoutWeight(1)
            }.width(100.percent).margin(top:2.vp)
            if (this.tab == 0) {
                if (this.loading) { Text(this.status).fontSize(12.vp).fontColor(0xFF65738A).margin(top:8.vp).id("libraryStatus") }
                Scroll { Column {
                    ForEach(this.borrows,itemGenerator:{item:BorrowData,index:Int64=>Row {
                        Column { Image(@r(app.media.home_book)).width(38.vp).height(38.vp).fillColor(0xFF46699D) }
                            .width(78.vp).height(116.vp).justifyContent(FlexAlign.Center).backgroundColor(0xFFE8ECF4).borderRadius(10.vp)
                        Column {
                            Text(item.title).fontSize(17.vp).fontWeight(FontWeight.Bold).maxLines(2)
                            Text("${this.dateOnly(item.loanDate)} 借阅  →  ${this.dateOnly(item.normReturnDate)} 到期")
                                .fontSize(12.vp).fontColor(0xFF65738A).margin(top:10.vp)
                            Row {
                                Text(if(this.overdue(item.normReturnDate)){"已过期"}else{"借阅中"}).fontSize(16.vp).fontWeight(FontWeight.Bold)
                                    .fontColor(if(this.overdue(item.normReturnDate)){0xFFC83E3E}else{0xFF2D765B}).layoutWeight(1)
                                Text(if(this.overdue(item.normReturnDate)){"不可续借"}else{"可续借"}).fontSize(12.vp).fontColor(0xFF46699D)
                            }.width(100.percent).margin(top:12.vp)
                            if(item.author!=""){Text(item.author).fontSize(11.vp).fontColor(0xFF7B8494).maxLines(1).margin(top:5.vp)}
                        }.layoutWeight(1).height(116.vp).margin(left:12.vp).alignItems(HorizontalAlign.Start)
                    }.width(100.percent).padding(12.vp).margin(top:9.vp).backgroundColor(0xFFFFFFFF).borderRadius(12.vp).id("libraryBorrow_${index}")})
                }.width(100.percent) }.width(100.percent).layoutWeight(1).align(Alignment.TopStart)
                Text("在借 ${this.borrows.size} 本，其中已过期 ${this.overdueCount()} 本")
                    .width(100.percent).height(40.vp).fontSize(13.vp).textAlign(TextAlign.Center).backgroundColor(0xFFFFFFFF).id("libraryBorrowSummary")
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
                onReady: { url: String, payload: String, cookies: String => this.authRaw = url + "|" + payload; this.authCookies = cookies; this.reloadBorrows() },
                onFailure: { message: String => this.loading = false; this.status = message }
            )
        }.width(100.percent).height(100.percent).padding(left: 12.vp, right: 12.vp, top: 8.vp, bottom: 0.vp)
            .backgroundColor(0xFFFFFFFF).alignItems(HorizontalAlign.Start)
    }
}
