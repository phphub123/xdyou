package ohos_app_cangjie_entry.page.dorm_water

import kit.ArkUI.*
import ohos.arkui.state_macro_manage.*
import std.collection.*
import std.sync.*
import std.time.*
import ohos_app_cangjie_entry.controller.*
import ohos_app_cangjie_entry.model.*

@Component
public class DormWaterPage {
    let onBack: () -> Unit
    let controller = DormWaterController()
    @State var phone: String = ""
    @State var imageCode: String = ""
    @State var smsCode: String = ""
    @State var captchaImage: String = ""
    @State var status: String = ""
    @State var loading: Bool = false
    @State var loggedIn: Bool = false
    @State var devices: ArrayList<DormWaterDevice> = ArrayList<DormWaterDevice>()
    @State var deviceId: String = ""
    @State var activeDevice: String = ""
    @State var idleChecks: Int64 = 0
    var pollTimer: ?Timer = None

    protected override func aboutToAppear(): Unit {
        this.loggedIn = this.controller.isLoggedIn()
        if (this.loggedIn) { this.loadDevices() } else { this.loadCaptcha() }
    }
    protected override func aboutToDisappear(): Unit {
        this.stopPolling()
    }
    func stopPolling(): Unit {
        match (this.pollTimer) { case Some(timer) => timer.cancel(); case None => () }
        this.pollTimer = None
        this.idleChecks = 0
    }
    func startPolling(device: DormWaterDevice): Unit {
        this.stopPolling()
        this.pollTimer = Some(Timer.repeat(Duration.second * 60, Duration.second * 60, { =>
            if (this.activeDevice != device.id) { return }
            this.controller.status(device.id, { value => launch {
                if (value == 99) { this.idleChecks += 1 } else { this.idleChecks = 0 }
                if (this.idleChecks >= 3) { this.stopPolling(); this.activeDevice = ""; this.status = "设备已连续三次空闲，监控结束。" }
                else { this.status = "供水状态监控中（空闲确认 ${this.idleChecks}/3）。" }
            } }, { message => launch { this.status = message } })
        }))
    }
    func loadCaptcha(): Unit {
        this.loading = true; this.status = "正在加载图片验证码…"
        this.controller.captcha({ value => launch { this.captchaImage = "data:image/png;base64," + value.imageBase64; this.loading = false; this.status = "请输入手机号和图片验证码。" } },
            { message => launch { this.loading = false; this.status = message } })
    }
    func sendSms(): Unit {
        this.loading = true; this.status = "正在发送短信验证码…"
        this.controller.sendSms(this.phone, this.imageCode, { message => launch { this.loading = false; this.status = message } },
            { message => launch { this.loading = false; this.status = message; this.loadCaptcha() } })
    }
    func login(): Unit {
        this.loading = true; this.status = "正在登录饮水服务…"
        this.controller.login(this.phone, this.smsCode, { => launch { this.loading = false; this.loggedIn = true; this.status = "登录成功，正在加载设备。"; this.loadDevices() } },
            { message => launch { this.loading = false; this.status = message } })
    }
    func loadDevices(): Unit {
        this.loading = true; this.status = "正在加载收藏设备…"
        this.controller.devices({ values => launch { this.devices = values; this.loading = false; this.status = if (values.size == 0) { "没有收藏的饮水设备。" } else { "已加载 ${values.size} 台设备。" } } },
            { message => launch { this.loading = false; this.status = message; if (message.contains("失效")) { this.loggedIn = false; this.loadCaptcha() } } })
    }
    func addDevice(): Unit {
        this.loading = true
        this.controller.add(this.deviceId, { => launch { this.loading = false; this.deviceId = ""; this.status = "已添加设备，正在刷新列表。"; this.loadDevices() } },
            { message => launch { this.loading = false; this.status = message } })
    }
    func remove(index: Int64): Unit {
        let id = this.devices[index].id; this.loading = true
        this.controller.remove(id, { => launch { this.loading = false; this.status = "已移除收藏设备。"; this.loadDevices() } },
            { message => launch { this.loading = false; this.status = message } })
    }
    func toggleWater(device: DormWaterDevice): Unit {
        this.loading = true
        if (this.activeDevice == device.id) {
            this.controller.stop(device.id, { => launch { this.loading = false; this.stopPolling(); this.activeDevice = ""; this.status = "已停止供水。" } },
                { message => launch { this.loading = false; this.status = message } })
        } else {
            this.controller.start(device.id, { => launch { this.loading = false; this.activeDevice = device.id; this.startPolling(device); this.status = "供水已启动，请使用完毕后停止。" } },
                { message => launch { this.loading = false; this.status = message } })
        }
    }
    func check(device: DormWaterDevice): Unit {
        this.loading = true
        this.controller.status(device.id, { value => launch { this.loading = false; this.status = if (value == 99) { "${device.name} 当前空闲。" } else { "${device.name} 当前状态码：${value}" } } },
            { message => launch { this.loading = false; this.status = message } })
    }
    func logout(): Unit {
        if (this.activeDevice != "") { this.status = "请先停止正在运行的饮水设备。"; return }
        this.stopPolling(); this.controller.logout(); this.loggedIn = false; this.devices = ArrayList<DormWaterDevice>(); this.status = "已退出饮水服务。"; this.loadCaptcha()
    }
    func build() {
        Column {
            Row { Button("‹").width(44.vp).height(40.vp).onClick({ _ => this.onBack() }).id("dormWaterBack"); Text("宿舍饮水").fontSize(24.vp).fontWeight(FontWeight.Bold).layoutWeight(1).margin(left: 8.vp); if (this.loggedIn) { Button("退出").onClick({ _ => this.logout() }).id("dormWaterLogout") } }.width(100.percent)
            Text(this.status).fontSize(12.vp).fontColor(0xFF65738A).margin(top: 8.vp).id("dormWaterStatus")
            if (!this.loggedIn) {
                TextInput(placeholder: "手机号", text: this.phone).width(100.percent).height(44.vp).margin(top: 16.vp).onChange({ value => this.phone = value }).id("dormWaterPhone")
                Row {
                    TextInput(placeholder: "图片验证码", text: this.imageCode).layoutWeight(1).height(44.vp).onChange({ value => this.imageCode = value }).id("dormWaterImageCode")
                    if (this.captchaImage != "") { Image(this.captchaImage).width(140.vp).height(50.vp).objectFit(ImageFit.Fill).margin(left: 10.vp).onClick({ _ => this.loadCaptcha() }).id("dormWaterCaptcha") }
                }.width(100.percent).margin(top: 10.vp)
                TextInput(placeholder: "短信验证码", text: this.smsCode).width(100.percent).height(44.vp).margin(top: 10.vp).onChange({ value => this.smsCode = value }).id("dormWaterSmsCode")
                Row { Button(if (this.loading) { "处理中…" } else { "发送短信" }).layoutWeight(1).enabled(!this.loading).onClick({ _ => this.sendSms() }).id("dormWaterSendSms"); Button(if (this.loading) { "处理中…" } else { "登录" }).layoutWeight(1).margin(left: 8.vp).enabled(!this.loading).onClick({ _ => this.login() }).id("dormWaterLogin") }.width(100.percent).height(44.vp).margin(top: 14.vp)
            } else {
                Scroll { Column {
                    Row { TextInput(placeholder: "手动输入饮水设备 ID", text: this.deviceId).layoutWeight(1).onChange({ value => this.deviceId = value }).id("dormWaterDeviceIdInput"); Button("添加收藏").margin(left: 8.vp).enabled(!this.loading).onClick({ _ => this.addDevice() }).id("dormWaterAddDevice") }.width(100.percent).height(44.vp)
                    Text("扫码能力待系统 Scan Kit 探针确认；当前可安全手动添加设备 ID。").fontSize(12.vp).fontColor(0xFF65738A).margin(top: 6.vp)
                    ForEach(this.devices, itemGenerator: { device: DormWaterDevice, index: Int64 =>
                        Column {
                            Row { Text(device.name).fontSize(17.vp).fontWeight(FontWeight.Bold).layoutWeight(1); Text(if (this.activeDevice == device.id) { "供水中" } else { "设备" }).fontSize(12.vp).fontColor(if (this.activeDevice == device.id) { 0xFF2D8B66 } else { 0xFF65738A }) }.width(100.percent)
                            Text("ID：${device.id}").fontSize(12.vp).fontColor(0xFF65738A).margin(top: 5.vp)
                            Row { Button("状态").layoutWeight(1).onClick({ _ => this.check(device) }).id("dormWaterStatus_${index}"); Button(if (this.activeDevice == device.id) { "停止" } else { "开始" }).layoutWeight(1).margin(left: 7.vp).onClick({ _ => this.toggleWater(device) }).id("dormWaterToggle_${index}"); Button("移除").layoutWeight(1).margin(left: 7.vp).onClick({ _ => this.remove(index) }).id("dormWaterRemove_${index}") }.width(100.percent).height(38.vp).margin(top: 9.vp)
                        }.width(100.percent).padding(13.vp).margin(top: 9.vp).backgroundColor(0xFFFFFFFF).borderRadius(12.vp).id("dormWaterDevice_${index}")
                    })
                    Button(if (this.loading) { "刷新中…" } else { "刷新设备" }).width(100.percent).margin(top: 12.vp).enabled(!this.loading).onClick({ _ => this.loadDevices() }).id("dormWaterRefresh")
                }.width(100.percent) }.width(100.percent).layoutWeight(1).margin(top: 10.vp)
            }
        }.width(100.percent).height(100.percent).padding(18.vp).backgroundColor(0xFFF7F9FC).alignItems(HorizontalAlign.Start)
    }
}
