package ohos_app_cangjie_entry.controller

import ohos_app_cangjie_entry.model.*
import ohos_app_cangjie_entry.repository.*
import ohos_app_cangjie_entry.repository.energy.*

public class EnergyController {
    public static var cachedRemain: String = ""
    public static var cachedLastReadDate: String = ""
    let aircon = AirconSession()
    let energy = EnergySession()
    var loading: Bool = false

    public func reloadEnergy(success: (EnergyInfo) -> Unit, failure: (String) -> Unit): Unit {
        if (this.loading) { return }; this.loading = true
        this.energy.load({ value => this.loading = false; EnergyController.cache(value); success(value) },
            { message => this.loading = false; failure(message) })
    }

    public func reloadEnergyAuthorized(rawUrl: String, cookies: String,
        success: (EnergyInfo) -> Unit, failure: (String) -> Unit): Unit {
        if (this.loading) { return }; this.loading = true
        this.energy.loadAuthorized(rawUrl, cookies, { value => this.loading = false; EnergyController.cache(value); success(value) },
            { message => this.loading = false; failure(message) })
    }
    public func reloadAircon(imei: String, success: (AirconEnergyInfo) -> Unit, failure: (String) -> Unit): Unit {
        if (this.loading) { return }
        this.loading = true
        this.aircon.load(imei, { value => this.loading = false; success(value) },
            { message => this.loading = false; failure(message) })
    }
    static func cache(value: EnergyInfo): Unit {
        EnergyController.cachedRemain = value.electricityRemain
        EnergyController.cachedLastReadDate = value.lastReadDate
    }
}
