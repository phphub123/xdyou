package ohos_app_cangjie_entry.controller

import ohos_app_cangjie_entry.model.*
import ohos_app_cangjie_entry.repository.*

public class EnergyController {
    let aircon = AirconSession()
    var loading: Bool = false

    // 按设备IMEI刷新空调能耗信息（防止重复请求）
    public func reloadAircon(imei: String, success: (AirconEnergyInfo) -> Unit, failure: (String) -> Unit): Unit {
        if (this.loading) { return }
        this.loading = true
        this.aircon.load(imei, { value => this.loading = false; success(value) },
            { message => this.loading = false; failure(message) })
    }
}
