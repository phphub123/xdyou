package ohos_app_cangjie_entry.page.library

import kit.ArkUI.*
import ohos.arkui.state_macro_manage.*
import std.collection.*
import ohos_app_cangjie_entry.controller.*
import ohos_app_cangjie_entry.model.xidian_ids.*
import ohos_app_cangjie_entry.components.*

@Component
public class LibraryPage {
    let onBack: () -> Unit
    @State var keyword: String = ""
    @State var field: String = "keyWord"
    @State var status: String = "输入题名、作者、ISBN 或任意关键词。馆藏检索无需登录。"
    @State var loading: Bool = false
    @State var books: ArrayList<BookInfo> = ArrayList<BookInfo>()
    @State var locations: ArrayList<BookLocation> = ArrayList<BookLocation>()
    @State var selectedIndex: Int64 = -1
    @State var page: Int64 = 1
    @State var end: Bool = false
    let controller = LibraryController()

    func search(reset: Bool): Unit {
        if (this.loading || this.keyword.trimAscii() == "") { return }
        if (reset) { this.books = ArrayList<BookInfo>(); this.page = 1; this.end = false }
        this.loading = true; this.status = "正在检索第 ${this.page} 页…"
        this.controller.search(this.keyword, this.field, this.page, { items => launch {
            for (item in items) { this.books.add(item) }; this.end = items.size < 10; this.page += 1; this.loading = false
            this.status = if (this.books.size == 0) { "没有找到匹配馆藏。" } else { "已加载 ${this.books.size} 条结果。" }
        } }, { message => launch { this.loading = false; this.status = message } })
    }
    func openBook(index: Int64): Unit {
        this.selectedIndex = index; this.locations = ArrayList<BookLocation>(); this.loading = true; this.status = "正在读取馆藏位置…"
        this.controller.locations(this.books[index], { items => launch { this.locations = items; this.loading = false; this.status = "共 ${items.size} 个馆藏位置。" } },
            { message => launch { this.loading = false; this.status = message } })
    }
    func headerBack(): Unit {
        if (this.selectedIndex >= 0) { this.selectedIndex = -1; this.status = "已加载 ${this.books.size} 条结果。" } else { this.onBack() }
    }
    func headerTitle(): String {
        return if (this.selectedIndex >= 0) { this.books[this.selectedIndex].bookName } else { "图书馆" }
    }
    func build() {
        Column {
            PageHeader(title: this.headerTitle(), onBack: this.headerBack, backId: "libraryBack")
            if (this.selectedIndex < 0) {
                Row { TextInput(placeholder: "搜索馆藏", text: this.keyword).layoutWeight(1).onChange({ value => this.keyword = value }).id("librarySearchInput"); Button(if (this.loading) { "检索中" } else { "搜索" }).margin(left: 8.vp).onClick({ _ => this.search(true) }).id("librarySearchButton") }.width(100.percent).height(44.vp).margin(top: 12.vp)
                Row { Button("任意词").layoutWeight(1).onClick({ _ => this.field = "keyWord" }).id("libraryFieldKeyword"); Button("题名").layoutWeight(1).onClick({ _ => this.field = "title" }).id("libraryFieldTitle"); Button("作者").layoutWeight(1).onClick({ _ => this.field = "author" }).id("libraryFieldAuthor"); Button("ISBN").layoutWeight(1).onClick({ _ => this.field = "isbn" }).id("libraryFieldIsbn") }.width(100.percent).height(38.vp).margin(top: 6.vp)
            }
            Text(this.status).fontSize(12.vp).fontColor(0xFF65738A).margin(top: 8.vp).id("libraryStatus")
            if (this.selectedIndex >= 0) {
                LibraryBookHeader(book: this.books[this.selectedIndex])
                Scroll { Column { ForEach(this.locations, itemGenerator: { item: BookLocation, index: Int64 => Column { Row { Text(item.locationName).fontSize(16.vp).fontWeight(FontWeight.Bold).layoutWeight(1); Text(item.processType).fontSize(13.vp).fontColor(if (item.processType == "在架") { 0xFF2D8B66 } else { 0xFFC06B2B }) }.width(100.percent); Text("${item.campus} · ${item.callNo} · ${item.barcode}").fontSize(12.vp).fontColor(0xFF65738A).margin(top: 6.vp); if (item.borrowStatus != "") { Text(item.borrowStatus).fontSize(12.vp).margin(top: 4.vp) } }.width(100.percent).padding(13.vp).margin(top: 8.vp).backgroundColor(0xFFFFFFFF).borderRadius(11.vp).id("libraryLocation_${index}") }) }.width(100.percent) }.width(100.percent).layoutWeight(1)
            } else {
                Scroll { Column { ForEach(this.books, itemGenerator: { book: BookInfo, index: Int64 => Column { Text(book.bookName).fontSize(17.vp).fontWeight(FontWeight.Bold); Text("${book.author} · ${book.publisher} · ${book.publishYear}").fontSize(12.vp).fontColor(0xFF65738A).margin(top: 6.vp); Row { Text("索书号 ${book.callNo}").fontSize(12.vp).layoutWeight(1); Text("可借 ${book.availableCount}/${book.storageCount}").fontSize(13.vp).fontColor(0xFF46699D) }.width(100.percent).margin(top: 8.vp) }.width(100.percent).padding(14.vp).margin(top: 9.vp).backgroundColor(0xFFFFFFFF).borderRadius(12.vp).onClick({ _ => this.openBook(index) }).id("libraryBook_${index}") }); if (!this.end && this.books.size > 0) { Button(if (this.loading) { "加载中…" } else { "加载更多" }).width(100.percent).margin(top: 10.vp).onClick({ _ => this.search(false) }).id("libraryLoadMore") } }.width(100.percent) }.width(100.percent).layoutWeight(1)
            }
        }.width(100.percent).height(100.percent).padding(18.vp).backgroundColor(0xFFF7F9FC).alignItems(HorizontalAlign.Start)
    }
}

@Component
public class LibraryBookHeader {
    let book: BookInfo
    func build() {
        Column {
            Text("作者：${this.book.author}").fontSize(14.vp)
            Text("出版社：${this.book.publisher} ${this.book.publishYear}").fontSize(14.vp).margin(top: 5.vp)
            Text("ISBN：${this.book.isbn}").fontSize(14.vp).margin(top: 5.vp)
            Text("索书号：${this.book.callNo}").fontSize(14.vp).margin(top: 5.vp)
            Text("可借 ${this.book.availableCount} / 馆藏 ${this.book.storageCount}").fontSize(14.vp).fontColor(0xFF46699D).margin(top: 7.vp)
            if (this.book.description != "") { Text(this.book.description).fontSize(13.vp).fontColor(0xFF65738A).maxLines(4).margin(top: 8.vp) }
        }.width(100.percent).padding(14.vp).margin(top: 10.vp).backgroundColor(0xFFFFFFFF).borderRadius(12.vp).alignItems(HorizontalAlign.Start)
    }
}
