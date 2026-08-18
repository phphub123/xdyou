package ohos_app_cangjie_entry.model.school_card

public class SchoolCardOverview {
    public let balance: String
    public init(balance: String) { this.balance = balance }
}

public class PaidRecord {
    public let place: String
    public let date: String
    public let money: String
    public init(place: String, date: String, money: String) {
        this.place = place
        this.date = date
        this.money = money
    }
}
