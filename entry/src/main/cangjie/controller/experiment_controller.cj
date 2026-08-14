package ohos_app_cangjie_entry.controller

import std.collection.*
import ohos_app_cangjie_entry.model.experiment.*
import ohos_app_cangjie_entry.repository.experiment.*

public class ExperimentController {
    let physics = PhysicsExperimentSession()
    let other = SysjSession()
    var physicsLoading: Bool = false
    var otherLoading: Bool = false

    // 获取已保存的物理实验账号
    public func storedAccount(): String { this.physics.storedAccount() }

    // 判断是否已保存物理实验登录凭据
    public func hasStoredCredential(): Bool { this.physics.hasStoredCredential() }

    // 清除已保存的物理实验登录凭据
    public func clearCredential(): Unit { this.physics.clearCredential() }

    // 刷新非物理类实验数据（防止重复请求）
    public func reloadOther(success: (ArrayList<ExperimentData>) -> Unit, failure: (String) -> Unit): Unit {
        if (this.otherLoading) { return }; this.otherLoading = true
        this.other.load({ values => this.otherLoading=false; success(values) }, { message => this.otherLoading=false; failure(message) })
    }

    // 使用账号密码登录并刷新物理实验数据（防止重复请求）
    public func reloadPhysics(account: String, password: String,
        success: (ArrayList<ExperimentData>) -> Unit, failure: (String) -> Unit): Unit {
        if (this.physicsLoading) { return }; this.physicsLoading = true
        this.physics.load(account,password,{ values => this.physicsLoading=false; success(values) },{ message => this.physicsLoading=false; failure(message) })
    }
}
