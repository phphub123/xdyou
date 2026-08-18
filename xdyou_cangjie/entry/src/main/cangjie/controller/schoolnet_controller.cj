package ohos_app_cangjie_entry.controller

import ohos_app_cangjie_entry.model.*
import ohos_app_cangjie_entry.repository.*

public class SchoolnetController {
    private var loading: Bool = false

    // 刷新当前用户的校园网使用信息（防止重复请求）
    public func reload(success: (CurrentUserNetInfo) -> Unit, failure: (String) -> Unit): Unit {
        if (this.loading) { return }
        this.loading = true
        SchoolnetSession().loadCurrent(
            { value => this.loading = false; success(value) },
            { message => this.loading = false; failure(message) }
        )
    }
}
