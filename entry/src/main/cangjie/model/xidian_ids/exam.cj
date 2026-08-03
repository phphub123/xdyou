package ohos_app_cangjie_entry.model.xidian_ids

import std.regex.*
import std.time.*

public class ExamItem {
    public let subject: String
    public let time: String
    public let room: String
    public let seat: String
    public let kind: String
    public let courseId: String
    public let arranged: Bool
    public init(subject: String, time: String, room: String, seat: String, kind: String, courseId!: String = "", arranged!: Bool = true) {
        this.subject = subject; this.time = time; this.room = room; this.seat = seat; this.kind = kind
        this.courseId = courseId; this.arranged = arranged
    }
    public func startTime(): ?DateTime {
        if (!this.arranged) { return None }
        let pattern = Regex(#"^(\d{4}-\d{2}-\d{2})[^\d]*(\d{2}):(\d{2})"#)
        match (pattern.find(this.time, group: true)) {
            case Some(value) =>
                try { return Some(DateTime.parse("${value.matchString(1)} ${value.matchString(2)}:${value.matchString(3)}", "yyyy-MM-dd HH:mm")) }
                catch (_) { return None }
            case None => return None
        }
    }
}
