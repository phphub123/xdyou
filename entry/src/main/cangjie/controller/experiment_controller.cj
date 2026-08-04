package ohos_app_cangjie_entry.controller

import std.collection.*
import ohos_app_cangjie_entry.model.xidian_ids.*
import ohos_app_cangjie_entry.repository.*
import ohos_app_cangjie_entry.repository.xidian_ids.*

public class ExperimentController {
    let physics = PhysicsExperimentSession()
    let other = SysjSession()
    var physicsLoading: Bool = false
    var otherLoading: Bool = false
    public func storedAccount(): String { this.physics.storedAccount() }
    public func hasStoredCredential(): Bool { this.physics.hasStoredCredential() }
    public func clearCredential(): Unit { this.physics.clearCredential() }
    public func reloadOther(success: (ArrayList<ExperimentData>) -> Unit, failure: (String) -> Unit): Unit {
        if (this.otherLoading) { return }; this.otherLoading = true
        this.other.load({ values => this.otherLoading=false; success(values) }, { message => this.otherLoading=false; failure(message) })
    }
    public func reloadPhysics(account: String, password: String,
        success: (ArrayList<ExperimentData>) -> Unit, failure: (String) -> Unit): Unit {
        if (this.physicsLoading) { return }; this.physicsLoading = true
        this.physics.load(account,password,{ values => this.physicsLoading=false; success(values) },{ message => this.physicsLoading=false; failure(message) })
    }
}
