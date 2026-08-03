package ohos_app_cangjie_entry.model.xidian_ids

public class BookInfo {
    public let author: String
    public let isbn: String
    public let description: String
    public let bookName: String
    public let recordId: Int64
    public let publishYear: String
    public let publisher: String
    public let callNo: String
    public let availableCount: Int64
    public let storageCount: Int64
    public init(author: String, isbn: String, description: String, bookName: String,
        recordId: Int64, publishYear: String, publisher: String, callNo: String,
        availableCount: Int64, storageCount: Int64) {
        this.author = author; this.isbn = isbn; this.description = description
        this.bookName = bookName; this.recordId = recordId; this.publishYear = publishYear
        this.publisher = publisher; this.callNo = callNo
        this.availableCount = availableCount; this.storageCount = storageCount
    }
}

public class BookLocation {
    public let locationName: String
    public let callNo: String
    public let campus: String
    public let barcode: String
    public let processType: String
    public let borrowStatus: String
    public init(locationName: String, callNo: String, campus: String, barcode: String,
        processType: String, borrowStatus: String) {
        this.locationName = locationName; this.callNo = callNo; this.campus = campus
        this.barcode = barcode; this.processType = processType; this.borrowStatus = borrowStatus
    }
}
