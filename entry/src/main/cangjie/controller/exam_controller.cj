package ohos_app_cangjie_entry.controller

import std.collection.*
import std.sort.*
import std.time.*
import ohos_app_cangjie_entry.model.xidian_ids.*
import ohos_app_cangjie_entry.repository.xidian_ids.*

public class ExamGroups {
    public let upcoming: ArrayList<ExamItem>
    public let unarranged: ArrayList<ExamItem>
    public let finished: ArrayList<ExamItem>
    public init(upcoming: ArrayList<ExamItem>, unarranged: ArrayList<ExamItem>, finished: ArrayList<ExamItem>) {
        this.upcoming = upcoming; this.unarranged = unarranged; this.finished = finished
    }
}

public class ExamController {
    var refreshing: Bool = false

    // 刷新指定学期的考试列表（防止重复请求）
    public func reloadExams(semester: String, success: (ArrayList<ExamItem>) -> Unit, failure: (String) -> Unit): Unit {
        if (this.refreshing) { return }
        this.refreshing = true
        AcademicSession().loadExams(semester, { exams => this.refreshing = false; success(exams) }, { message => this.refreshing = false; failure(message) })
    }

    // 按考试时间将考试分为即将进行、未安排、已结束三组并排序
    public func group(exams: ArrayList<ExamItem>): ExamGroups {
        let upcoming = ArrayList<ExamItem>()
        let unarranged = ArrayList<ExamItem>()
        let finished = ArrayList<ExamItem>()
        let now = DateTime.now()
        for (exam in exams) {
            match (exam.startTime()) {
                case Some(time) => if (time > now) { upcoming.add(exam) } else { finished.add(exam) }
                case None => unarranged.add(exam)
            }
        }
        sort(upcoming, by: { left: ExamItem, right: ExamItem => left.startTime().getOrThrow().compare(right.startTime().getOrThrow()) }, stable: true)
        sort(finished, by: { left: ExamItem, right: ExamItem => right.startTime().getOrThrow().compare(left.startTime().getOrThrow()) }, stable: true)
        return ExamGroups(upcoming, unarranged, finished)
    }
}
