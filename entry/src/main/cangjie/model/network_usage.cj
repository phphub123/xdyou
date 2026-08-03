package ohos_app_cangjie_entry.model

public class CurrentUserNetInfo {
    public let userName: String
    public let realName: String
    public let productsName: String
    public let onlineIp: String
    public let onlineDeviceTotal: String
    public let sumBytes: Int64
    public let remainBytes: Int64
    public let bytesIn: Int64
    public let bytesOut: Int64
    public let userBalance: Int64
    public let walletBalance: Int64
    public init(userName: String, realName: String, productsName: String, onlineIp: String,
        onlineDeviceTotal: String, sumBytes: Int64, remainBytes: Int64, bytesIn: Int64,
        bytesOut: Int64, userBalance: Int64, walletBalance: Int64) {
        this.userName=userName; this.realName=realName; this.productsName=productsName
        this.onlineIp=onlineIp; this.onlineDeviceTotal=onlineDeviceTotal
        this.sumBytes=sumBytes; this.remainBytes=remainBytes; this.bytesIn=bytesIn
        this.bytesOut=bytesOut; this.userBalance=userBalance; this.walletBalance=walletBalance
    }
}
