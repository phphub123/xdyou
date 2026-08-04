package ohos_app_cangjie_entry.controller

import std.collection.*
import ohos_app_cangjie_entry.model.xidian_sport.*
import ohos_app_cangjie_entry.repository.*

public class SportController {
    private let session: SportSession = SportSession()
    private var loading: Bool = false

    public func storedAccount(): String { this.session.storedAccount() }
    public func hasStoredCredential(): Bool { this.session.hasStoredCredential() }
    public func clearCredential(): Unit { this.session.clearCredential() }

    public func reloadScore(account: String, password: String, success: (SportScore) -> Unit, failure: (String) -> Unit): Unit {
        if (this.loading) { return }; this.loading = true
        this.session.getScore(account, password, { value => this.loading = false; success(value) }, { message => this.loading = false; failure(message) })
    }
    public func reloadClasses(account: String, password: String, success: (ArrayList<SportClassItem>) -> Unit, failure: (String) -> Unit): Unit {
        if (this.loading) { return }; this.loading = true
        this.session.getClass(account, password, { value => this.loading = false; success(value) }, { message => this.loading = false; failure(message) })
    }
}
