package ohos_app_cangjie_entry.controller

import std.collection.*
import ohos_app_cangjie_entry.model.xidian_ids.*
import ohos_app_cangjie_entry.repository.xidian_ids.*

public class LibraryController {
    private let session = LibrarySession()
    private var loading = false
    public func search(keyword: String, field: String, page: Int64, success: (ArrayList<BookInfo>) -> Unit, failure: (String) -> Unit): Unit {
        if (this.loading) { return }; this.loading = true
        this.session.searchBooks(keyword, field, page, { items => this.loading = false; success(items) }, { message => this.loading = false; failure(message) })
    }
    public func locations(book: BookInfo, success: (ArrayList<BookLocation>) -> Unit, failure: (String) -> Unit): Unit {
        this.session.loadLocations(book.recordId, success, failure)
    }
}
