package ohos_app_cangjie_entry.repository.xidian_ids

import std.collection.*
import std.convert.*
import ohos_app_cangjie_entry.repository.*
import ohos_app_cangjie_entry.model.xidian_ids.*

public class ClassTableSession {
    static let termUrl = "https://ehall.xidian.edu.cn/jwapp/sys/wdkb/modules/jshkcb/cxjcs.do"
    static let classUrl = "https://ehall.xidian.edu.cn/jwapp/sys/wdkb/modules/xskcb/xskcb.do"
    static let notArrangedUrl = "https://ehall.xidian.edu.cn/jwapp/sys/wdkb/modules/xskcb/cxxsllsywpk.do"
    let network = AcademicSession()

    public func load(semester: String, success: (ClassTableData) -> Unit, failure: (String) -> Unit): Unit {
        let parts = semester.split("-")
        if (parts.size != 3) { failure("Semester code must use YYYY-YYYY-N."); return }
        let snapshot = SessionStore().restore()
        if (!snapshot.loggedIn || snapshot.account == "") { failure("A real IDS/Ehall session is required before timetable data can load."); return }
        let year = parts[0] + "-" + parts[1]
        let term = parts[2]
        this.network.request(ClassTableSession.termUrl, "XN=${year}&XQ=${term}", { termBody =>
            try {
                let termRows = this.network.responseRows(termBody, "cxjcs")
                if (termRows.size() == 0) { failure("The timetable service returned no semester start date."); return }
                let termStartDay = this.network.field(termRows[0].asObject(), "XQKSRQ")
                this.loadArrangements(semester, snapshot.account, termStartDay, success, failure)
            } catch (e: Exception) { failure("Malformed semester-date response: ${e.message}") }
        }, failure)
    }

    func loadArrangements(semester: String, account: String, termStartDay: String, success: (ClassTableData) -> Unit, failure: (String) -> Unit): Unit {
        let form = "XNXQDM=${semester}&XH=${account}"
        this.network.request(ClassTableSession.classUrl, form, { body =>
            try {
                let courses = ArrayList<CourseSlot>()
                let rows = this.network.responseRows(body, "xskcb")
                var semesterLength: Int64 = 1
                var index: Int64 = 0
                while (index < rows.size()) {
                    let row = rows[index].asObject()
                    let flags = this.network.field(row, "SKZC")
                    if (flags.toArray().size > semesterLength) { semesterLength = flags.toArray().size }
                    courses.add(CourseSlot(
                        this.network.field(row, "KCM"), this.network.field(row, "KCH"), this.network.field(row, "KXH"),
                        this.network.field(row, "SKJS"), this.network.field(row, "JASMC"),
                        Int64.parse(this.network.field(row, "SKXQ")), Int64.parse(this.network.field(row, "KSJC")),
                        Int64.parse(this.network.field(row, "JSJC")), flags
                    ))
                    index += 1
                }
                this.loadNotArranged(semester, account, termStartDay, semesterLength, courses, success, failure)
            } catch (e: Exception) { failure("Malformed timetable response: ${e.message}") }
        }, failure)
    }

    func loadNotArranged(semester: String, account: String, termStartDay: String, semesterLength: Int64, courses: ArrayList<CourseSlot>, success: (ClassTableData) -> Unit, failure: (String) -> Unit): Unit {
        let form = "XNXQDM=${semester}&XH=${account}"
        this.network.request(ClassTableSession.notArrangedUrl, form, { body =>
            try {
                let result = ArrayList<NotArrangedCourse>()
                let rows = this.network.responseRows(body, "cxxsllsywpk")
                var index: Int64 = 0
                while (index < rows.size()) {
                    let row = rows[index].asObject()
                    result.add(NotArrangedCourse(
                        this.network.field(row, "KCM"), this.network.field(row, "KCH"),
                        this.network.field(row, "KXH"), this.network.field(row, "SKJS")
                    ))
                    index += 1
                }
                success(ClassTableData(semester, termStartDay, semesterLength, courses, result))
            } catch (e: Exception) { failure("Malformed unarranged-course response: ${e.message}") }
        }, failure)
    }
}
