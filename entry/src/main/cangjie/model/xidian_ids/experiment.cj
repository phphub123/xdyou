package ohos_app_cangjie_entry.model.xidian_ids

import std.collection.*
import std.time.*

public enum ExperimentType {
    | Physics
    | Others
}

public class RecognitionResult {
    public let label: String
    public let found: Bool
    public let rawUrl: String
    public init(label: String, found: Bool, rawUrl: String) {
        this.label = label
        this.found = found
        this.rawUrl = rawUrl
    }
}

public class ExperimentTimeRange {
    public let startAt: DateTime
    public let endAt: DateTime
    public init(startAt: DateTime, endAt: DateTime) {
        this.startAt = startAt
        this.endAt = endAt
    }
}

public class ExperimentData {
    public let experimentType: ExperimentType
    public let name: String
    public var score: ?RecognitionResult
    public let classroom: String
    public let timeRanges: ArrayList<ExperimentTimeRange>
    public let teacher: String
    public let reference: String
    public init(experimentType: ExperimentType, name: String, classroom: String,
        timeRanges: ArrayList<ExperimentTimeRange>, teacher: String,
        reference!: String = "", score!: ?RecognitionResult = None) {
        this.experimentType = experimentType
        this.name = name
        this.classroom = classroom
        this.timeRanges = timeRanges
        this.teacher = teacher
        this.reference = reference
        this.score = score
    }

    public func firstStart(): DateTime {
        if (this.timeRanges.size == 0) { return DateTime.now() }
        var value = this.timeRanges[0].startAt
        for (range in this.timeRanges) { if (range.startAt < value) { value = range.startAt } }
        return value
    }
}
