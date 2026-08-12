package ohos_app_cangjie_entry.controller

import std.collection.*
import ohos_app_cangjie_entry.model.xidian_ids.*
import ohos_app_cangjie_entry.repository.xidian_ids.*

public class SchoolCardController {
    private let session = SchoolCardSession()
    private var loading = false
    public func authorizeWeb(raw: String, cookies: String, failure: (String) -> Unit): Bool {
        return this.session.authorizeFromWeb(raw, cookies, failure)
    }

    // 获取校园卡账户概览信息（防止重复请求）
    public func overview(success: (SchoolCardOverview) -> Unit, failure: (String) -> Unit): Unit {
        if (this.loading) { return }
        this.loading = true
        this.session.getOverview({ value => this.loading = false; success(value) },
            { message => this.loading = false; failure(message) })
    }

    // 按时间范围查询校园卡消费记录（防止重复请求）
    public func records(begin: String, end: String, success: (ArrayList<PaidRecord>) -> Unit, failure: (String) -> Unit): Unit {
        if (this.loading) { return }
        this.loading = true
        this.session.getPaidStatus(begin, end, { values => this.loading = false; success(values) },
            { message => this.loading = false; failure(message) })
    }

    // 获取校园卡付款二维码（防止重复请求）
    public func qrCode(success: (String) -> Unit, failure: (String) -> Unit): Unit {
        if (this.loading) { return }
        this.loading = true
        this.session.getQRCode({ value => this.loading = false; success(value) },
            { message => this.loading = false; failure(message) })
    }
}
