package ohos_app_cangjie_entry.controller

import ohos_app_cangjie_entry.model.*
import ohos_app_cangjie_entry.repository.*

public class EnergyController {
    let aircon = AirconSession()
    var loading: Bool = false

    public func reloadAircon(imei: String, success: (AirconEnergyInfo) -> Unit, failure: (String) -> Unit): Unit {
        if (this.loading) { return }
        this.loading = true
        this.aircon.load(imei, { value => this.loading = false; success(value) },
            { message => this.loading = false; failure(message) })
    }
}
