package ohos_app_cangjie_entry.model.xidian_sport

import std.collection.*

public class SportItem {
    public let examName: String
    public let examUnit: String
    public let actualScore: String
    public let score: Float64
    public let rank: String
    public init(examName: String, examUnit: String, actualScore: String, score: Float64, rank: String) {
        this.examName = examName
        this.examUnit = examUnit
        this.actualScore = actualScore
        this.score = score
        this.rank = rank
    }
}

public class SportScoreOfYear {
    public let measureScoreId: String
    public let year: String
    public let totalScore: String
    public let rank: String
    public let gradeType: String
    public var moreInfo: String = ""
    public let details: ArrayList<SportItem> = ArrayList<SportItem>()
    public init(measureScoreId: String, year: String, totalScore: String, rank: String, gradeType: String) {
        this.measureScoreId = measureScoreId
        this.year = year
        this.totalScore = totalScore
        this.rank = rank
        this.gradeType = gradeType
    }
}

public class SportScore {
    public var total: String = "0.0"
    public var rank: String = ""
    public var detail: String = ""
    public let years: ArrayList<SportScoreOfYear> = ArrayList<SportScoreOfYear>()
    public func isFourYearsComplete(): Bool { this.years.size >= 4 }
    public func isQualified(): Bool { return this.rank != "不合格" && this.rank != "" }
}

public class SportClassItem {
    public let termName: String
    public let name: String
    public let teacher: String
    public let time: String
    public let place: String
    public let score: String
    public let classType: String
    public init(termName: String, name: String, teacher: String, time: String, place: String, score: String, classType: String) {
        this.termName = termName
        this.name = name
        this.teacher = teacher
        this.time = time
        this.place = place
        this.score = score
        this.classType = classType
    }
}
