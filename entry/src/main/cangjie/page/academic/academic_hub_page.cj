package ohos_app_cangjie_entry.page.academic

import kit.ArkUI.*
import ohos.arkui.state_macro_manage.*
import std.collection.ArrayList
import ohos_app_cangjie_entry.repository.xidian_ids.*
import ohos_app_cangjie_entry.model.xidian_ids.*
import ohos_app_cangjie_entry.controller.*

import ohos_app_cangjie_entry.page.score.*
import ohos_app_cangjie_entry.page.exam.*
import ohos_app_cangjie_entry.page.classtable.*
import ohos_app_cangjie_entry.page.custom_class.*
import ohos_app_cangjie_entry.page.empty_classroom.*
@Component
public class AcademicHub {
    @State var tab: Int64 = 0
    func build() {
        Column {
            Row {
                Button("Timetable").layoutWeight(1).onClick({ _ => this.tab = 0 }).id("academicTabTimetable")
                Button("自定义").layoutWeight(1).onClick({ _ => this.tab = 4 }).id("academicTabCustomClass")
                Button("空教室").layoutWeight(1).onClick({ _ => this.tab = 3 }).id("academicTabEmptyClassroom")
                Button("Scores").layoutWeight(1).onClick({ _ => this.tab = 1 }).id("academicTabScores")
                Button("Exams").layoutWeight(1).onClick({ _ => this.tab = 2 }).id("academicTabExams")
            }.width(100.percent).padding(8.vp)
            if (this.tab == 0) { ClassTablePage() }
            else if (this.tab == 1) { ScorePage() }
            else if (this.tab == 2) { ExamPage() }
            else if (this.tab == 4) { CustomClassPage(onBack: { => this.tab = 0 }) }
            else { EmptyClassroomPage() }
        }.width(100.percent).height(100.percent)
    }
}

