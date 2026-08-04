package ohos_app_cangjie_entry.controller

import std.collection.*
import ohos_app_cangjie_entry.model.*
import ohos_app_cangjie_entry.repository.*

public class DormWaterController {
    let session = DormWaterSession()
    var loading: Bool = false

    public func isLoggedIn(): Bool { return this.session.isLoggedIn() }
    public func logout(): Unit { this.session.logout() }
    public func captcha(success: (DormWaterCaptcha) -> Unit, failure: (String) -> Unit): Unit {
        this.guard({ => this.session.loadCaptcha({ value => this.done(); success(value) }, { message => this.done(); failure(message) }) })
    }
    public func sendSms(phone: String, code: String, success: (String) -> Unit, failure: (String) -> Unit): Unit {
        this.guard({ => this.session.sendSms(phone, code, { message => this.done(); success(message) }, { message => this.done(); failure(message) }) })
    }
    public func login(phone: String, code: String, success: () -> Unit, failure: (String) -> Unit): Unit {
        this.guard({ => this.session.login(phone, code, { => this.done(); success() }, { message => this.done(); failure(message) }) })
    }
    public func devices(success: (ArrayList<DormWaterDevice>) -> Unit, failure: (String) -> Unit): Unit {
        this.guard({ => this.session.loadDevices({ values => this.done(); success(values) }, { message => this.done(); failure(message) }) })
    }
    public func remove(deviceId: String, success: () -> Unit, failure: (String) -> Unit): Unit {
        this.guard({ => this.session.removeFavorite(deviceId, { => this.done(); success() }, { message => this.done(); failure(message) }) })
    }
    public func add(deviceId: String, success: () -> Unit, failure: (String) -> Unit): Unit {
        this.guard({ => this.session.addFavorite(deviceId, { => this.done(); success() }, { message => this.done(); failure(message) }) })
    }
    public func start(deviceId: String, success: () -> Unit, failure: (String) -> Unit): Unit {
        this.guard({ => this.session.startWater(deviceId, { => this.done(); success() }, { message => this.done(); failure(message) }) })
    }
    public func stop(deviceId: String, success: () -> Unit, failure: (String) -> Unit): Unit {
        this.guard({ => this.session.endWater(deviceId, { => this.done(); success() }, { message => this.done(); failure(message) }) })
    }
    public func status(deviceId: String, success: (Int64) -> Unit, failure: (String) -> Unit): Unit {
        this.guard({ => this.session.checkStatus(deviceId, { value => this.done(); success(value) }, { message => this.done(); failure(message) }) })
    }
    func guard(operation: () -> Unit): Unit { if (this.loading) { return }; this.loading = true; operation() }
    func done(): Unit { this.loading = false }
}
