package ohos_app_cangjie_entry.controller

import std.collection.*
import ohos_app_cangjie_entry.model.sport.*
import ohos_app_cangjie_entry.repository.sport.*

public class SportController {
    private let session: SportSession = SportSession()
    private var loading: Bool = false

    // 获取已保存的体育系统账号
    public func storedAccount(): String { this.session.storedAccount() }

    // 判断是否已保存体育系统登录凭据
    public func hasStoredCredential(): Bool { this.session.hasStoredCredential() }

    // 清除已保存的体育系统登录凭据
    public func clearCredential(): Unit { this.session.clearCredential() }

    // 使用账号密码登录并刷新体育成绩（防止重复请求）
    public func reloadScore(account: String, password: String, success: (SportScore) -> Unit, failure: (String) -> Unit): Unit {
        if (this.loading) { return }; this.loading = true
        this.session.getScore(account, password, { value => this.loading = false; success(value) }, { message => this.loading = false; failure(message) })
    }

    // 使用账号密码登录并刷新体育课列表（防止重复请求）
    public func reloadClasses(account: String, password: String, success: (ArrayList<SportClassItem>) -> Unit, failure: (String) -> Unit): Unit {
        if (this.loading) { return }; this.loading = true
        this.session.getClass(account, password, { value => this.loading = false; success(value) }, { message => this.loading = false; failure(message) })
    }
}
