package ohos_app_cangjie_entry.model.xidian_ids

import std.convert.*

public class ScoreItem {
    public let mark: Int64
    public let name: String
    public let semester: String
    public let score: String
    public let credit: String
    public let kind: String
    public let classStatus: String
    public let scoreStatus: String
    public let scoreTypeCode: Int64
    public let level: String
    public let isPassedValue: String
    public let classId: String
    public init(mark: Int64, name: String, semester: String, score: String, credit: String, kind: String, classStatus: String, scoreStatus: String, scoreTypeCode: Int64, level: String, isPassedValue: String, classId: String) {
        this.mark = mark; this.name = name; this.semester = semester; this.score = score; this.credit = credit
        this.kind = kind; this.classStatus = classStatus; this.scoreStatus = scoreStatus; this.scoreTypeCode = scoreTypeCode
        this.level = level; this.isPassedValue = isPassedValue; this.classId = classId
    }
    public func numericScore(): Float64 {
        try { return Float64.parse(this.score) } catch (_) { return 0.0 }
    }
    public func numericCredit(): Float64 {
        try { return Float64.parse(this.credit) } catch (_) { return 0.0 }
    }
    public func isFinished(): Bool { return this.score != "" && this.isPassedValue != "" && this.isPassedValue != "null" }
    public func isPassed(): Bool { return this.isPassedValue == "1" }
    public func oneDecimal(value: Float64): String {
        let scaled = Int64(value * 10.0 + 0.5)
        return "${scaled / 10}.${scaled % 10}"
    }
    public func displayCredit(): String { return this.oneDecimal(this.numericCredit()) }
    public func displayGpa(): String { return this.oneDecimal(this.gpa()) }
    public func displayScore(): String {
        if ((this.scoreTypeCode == 1 || this.scoreTypeCode == 2 || this.scoreTypeCode == 3) && this.level != "") { return this.level }
        if (this.score == "") { return "暂无" }
        try { return Int64(Float64.parse(this.score)).toString() } catch (_) { return this.score }
    }
    public func gpa(): Float64 {
        if (!this.isFinished()) { return 0.0 }
        if (this.scoreTypeCode == 1 || this.scoreTypeCode == 3) {
            if (this.level == "优秀") { return 4.0 }
            if (this.level == "通过") { return 3.2 }
            return 0.0
        }
        if (this.scoreTypeCode == 2) {
            if (this.level == "优秀") { return 4.0 }
            if (this.level == "良好") { return 3.8 }
            if (this.level == "中等") { return 3.2 }
            if (this.level == "及格") { return 2.4 }
            return 0.0
        }
        let value = this.numericScore()
        if (value >= 95.0) { return 4.0 }
        if (value >= 90.0) { return 3.9 }
        if (value >= 84.0) { return 3.8 }
        if (value >= 80.0) { return 3.6 }
        if (value >= 76.0) { return 3.4 }
        if (value >= 73.0) { return 3.2 }
        if (value >= 70.0) { return 3.0 }
        if (value >= 67.0) { return 2.7 }
        if (value >= 64.0) { return 2.4 }
        if (value >= 62.0) { return 2.2 }
        if (value >= 60.0) { return 2.0 }
        return 0.0
    }
}

public class ScoreSummary {
    public let count: Int64
    public let credit: Float64
    public let average: Float64
    public let gpa: Float64
    public init(count: Int64, credit: Float64, average: Float64, gpa: Float64) {
        this.count = count; this.credit = credit; this.average = average; this.gpa = gpa
    }
}
