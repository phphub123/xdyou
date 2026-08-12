package ohos_app_cangjie_entry.controller

import std.collection.*
import ohos_app_cangjie_entry.model.xidian_ids.*
import ohos_app_cangjie_entry.repository.xidian_ids.*

public class LibraryController {
    public static var cachedBorrowCount: Int64 = -1
    private let session = LibrarySession()
    private var loading = false

    public func borrows(success: (ArrayList<BorrowData>) -> Unit, failure: (String) -> Unit): Unit {
        if (this.loading) { return }; this.loading = true
        this.session.loadBorrowList({ items => this.loading = false; LibraryController.cachedBorrowCount = items.size; success(items) },
            { message => this.loading = false; failure(message) })
    }
    public func borrowsAuthorized(raw: String, cookies: String,
        success: (ArrayList<BorrowData>) -> Unit, failure: (String) -> Unit): Unit {
        if (this.loading) { return }; this.loading = true
        this.session.loadBorrowListAuthorized(raw, cookies, { items => this.loading = false; LibraryController.cachedBorrowCount = items.size; success(items) },
            { message => this.loading = false; failure(message) })
    }
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
