package ohos_app_cangjie_entry.controller

import std.collection.*
import ohos_app_cangjie_entry.model.xidian_ids.*
import ohos_app_cangjie_entry.repository.xidian_ids.*

public class LibraryController {
    private let session = LibrarySession()
    private var loading = false

    // 按关键词和检索字段分页搜索图书（防止重复请求）
    public func search(keyword: String, field: String, page: Int64, success: (ArrayList<BookInfo>) -> Unit, failure: (String) -> Unit): Unit {
        if (this.loading) { return }; this.loading = true
        this.session.searchBooks(keyword, field, page, { items => this.loading = false; success(items) }, { message => this.loading = false; failure(message) })
    }

    // 加载指定图书的馆藏位置信息
    public func locations(book: BookInfo, success: (ArrayList<BookLocation>) -> Unit, failure: (String) -> Unit): Unit {
        this.session.loadLocations(book.recordId, success, failure)
    }
}
