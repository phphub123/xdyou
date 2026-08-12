package ohos_app_cangjie_entry.controller

import ohos_app_cangjie_entry.model.*
import ohos_app_cangjie_entry.repository.*
import ohos_app_cangjie_entry.repository.xidian_ids.*

public class EnergyController {
    let aircon = AirconSession()
    let energy = EnergySession()
    var loading: Bool = false

    public func reloadEnergy(success: (EnergyInfo) -> Unit, failure: (String) -> Unit): Unit {
        if (this.loading) { return }; this.loading = true
        this.energy.load({ value => this.loading = false; success(value) },
            { message => this.loading = false; failure(message) })
    }

    public func reloadEnergyAuthorized(rawUrl: String, cookies: String,
        success: (EnergyInfo) -> Unit, failure: (String) -> Unit): Unit {
        if (this.loading) { return }; this.loading = true
        this.energy.loadAuthorized(rawUrl, cookies, { value => this.loading = false; success(value) },
            { message => this.loading = false; failure(message) })
    }
    public func reloadAircon(imei: String, success: (AirconEnergyInfo) -> Unit, failure: (String) -> Unit): Unit {
        if (this.loading) { return }
        this.loading = true
        this.aircon.load(imei, { value => this.loading = false; success(value) },
            { message => this.loading = false; failure(message) })
    }
}