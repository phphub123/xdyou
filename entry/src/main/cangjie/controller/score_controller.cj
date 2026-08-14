package ohos_app_cangjie_entry.controller

import std.collection.*
import ohos_app_cangjie_entry.model.score.*
import ohos_app_cangjie_entry.repository.academic.*

public class ScoreController {
    var refreshing: Bool = false

    // 刷新成绩列表（防止重复请求）
    public func reloadScores(success: (ArrayList<ScoreItem>) -> Unit, failure: (String) -> Unit): Unit {
        if (this.refreshing) { return }
        this.refreshing = true
        AcademicSession().loadScores({ scores => this.refreshing = false; success(scores) }, { message => this.refreshing = false; failure(message) })
    }

    // 按学期、课程性质、关键词过滤成绩列表
    public func filtered(scores: ArrayList<ScoreItem>, semester: String, kind: String, search: String): ArrayList<ScoreItem> {
        let result = ArrayList<ScoreItem>()
        for (score in scores) {
            let semesterMatches = semester == "" || score.semester == semester
            let kindMatches = kind == "" || score.classStatus == kind
            let searchMatches = search == "" || score.name.contains(search)
            if (semesterMatches && kindMatches && searchMatches) { result.add(score) }
        }
        return result
    }

    // 统计已完成课程的数量、总学分及加权平均分和绩点
    public func summarize(scores: ArrayList<ScoreItem>): ScoreSummary {
        var count: Int64 = 0
        var credit: Float64 = 0.0
        var weightedScore: Float64 = 0.0
        var weightedGpa: Float64 = 0.0
        for (score in scores) {
            if (score.isFinished()) {
                let itemCredit = score.numericCredit()
                credit += itemCredit
                weightedScore += score.numericScore() * itemCredit
                weightedGpa += score.gpa() * itemCredit
                count += 1
            }
        }
        if (credit == 0.0) { return ScoreSummary(count, 0.0, 0.0, 0.0) }
        return ScoreSummary(count, credit, weightedScore / credit, weightedGpa / credit)
    }
}
