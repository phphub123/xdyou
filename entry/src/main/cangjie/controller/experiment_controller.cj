package ohos_app_cangjie_entry.controller

import std.collection.*
import ohos_app_cangjie_entry.model.xidian_ids.*
import ohos_app_cangjie_entry.repository.*

public class ExperimentController {
    let physics = PhysicsExperimentSession()
    var loading: Bool = false
    public func storedAccount(): String { this.physics.storedAccount() }
    public func hasStoredCredential(): Bool { this.physics.hasStoredCredential() }
    public func clearCredential(): Unit { this.physics.clearCredential() }
    public func reloadPhysics(account: String, password: String,
        success: (ArrayList<ExperimentData>) -> Unit, failure: (String) -> Unit): Unit {
        if (this.loading) { return }; this.loading = true
        this.physics.load(account,password,{ values => this.loading=false; success(values) },{ message => this.loading=false; failure(message) })
    }
}
