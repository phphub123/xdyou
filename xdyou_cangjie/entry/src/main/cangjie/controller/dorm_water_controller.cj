package ohos_app_cangjie_entry.controller

import std.collection.*
import ohos_app_cangjie_entry.model.*
import ohos_app_cangjie_entry.repository.*

public class DormWaterController {
    let session = DormWaterSession()
    var loading: Bool = false

    // 判断宿舍水控是否已登录
    public func isLoggedIn(): Bool { return this.session.isLoggedIn() }

    // 退出宿舍水控登录
    public func logout(): Unit { this.session.logout() }

    // 获取登录验证码
    public func captcha(success: (DormWaterCaptcha) -> Unit, failure: (String) -> Unit): Unit {
        this.guard({ => this.session.loadCaptcha({ value => this.done(); success(value) }, { message => this.done(); failure(message) }) })
    }

    // 发送手机验证码短信
    public func sendSms(phone: String, code: String, success: (String) -> Unit, failure: (String) -> Unit): Unit {
        this.guard({ => this.session.sendSms(phone, code, { message => this.done(); success(message) }, { message => this.done(); failure(message) }) })
    }

    // 使用手机号和验证码登录宿舍水控
    public func login(phone: String, code: String, success: () -> Unit, failure: (String) -> Unit): Unit {
        this.guard({ => this.session.login(phone, code, { => this.done(); success() }, { message => this.done(); failure(message) }) })
    }

    // 加载可用设备列表
    public func devices(success: (ArrayList<DormWaterDevice>) -> Unit, failure: (String) -> Unit): Unit {
        this.guard({ => this.session.loadDevices({ values => this.done(); success(values) }, { message => this.done(); failure(message) }) })
    }

    // 取消收藏指定设备
    public func remove(deviceId: String, success: () -> Unit, failure: (String) -> Unit): Unit {
        this.guard({ => this.session.removeFavorite(deviceId, { => this.done(); success() }, { message => this.done(); failure(message) }) })
    }

    // 收藏指定设备
    public func add(deviceId: String, success: () -> Unit, failure: (String) -> Unit): Unit {
        this.guard({ => this.session.addFavorite(deviceId, { => this.done(); success() }, { message => this.done(); failure(message) }) })
    }

    // 启动指定设备的用水
    public func start(deviceId: String, success: () -> Unit, failure: (String) -> Unit): Unit {
        this.guard({ => this.session.startWater(deviceId, { => this.done(); success() }, { message => this.done(); failure(message) }) })
    }

    // 停止指定设备的用水
    public func stop(deviceId: String, success: () -> Unit, failure: (String) -> Unit): Unit {
        this.guard({ => this.session.endWater(deviceId, { => this.done(); success() }, { message => this.done(); failure(message) }) })
    }

    // 查询指定设备的用水状态
    public func status(deviceId: String, success: (Int64) -> Unit, failure: (String) -> Unit): Unit {
        this.guard({ => this.session.checkStatus(deviceId, { value => this.done(); success(value) }, { message => this.done(); failure(message) }) })
    }

    // 若未处于加载中则加锁并执行操作，防止并发重复请求
    func guard(operation: () -> Unit): Unit { if (this.loading) { return }; this.loading = true; operation() }

    // 释放加载锁
    func done(): Unit { this.loading = false }
}
