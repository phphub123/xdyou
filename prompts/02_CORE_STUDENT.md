# 阶段 2：课程表、成绩、考试

继续当前工作，先读取规则、进度、映射和证据，并调用相关仓颉 skills/RAG。

按三个独立纵向切片依次完成，每个切片单独构建和设备验收：

1. 课程表：`controller/classtable_controller.dart`、`model/xidian_ids/classtable*`、`repository/xidian_ids/classtable_session.dart`、`page/classtable/**`。
2. 成绩：`controller/semester_controller.dart`、`model/xidian_ids/score*`、`repository/xidian_ids/score_session.dart`、`page/score/**`。
3. 考试：`controller/exam_controller.dart`、`model/xidian_ids/exam*`、`repository/xidian_ids/exam_session.dart`、`page/exam/**`。

要求真实接口、解析、缓存、加载/空/错误态、刷新、详情、滑动和课程时间布局均可用。禁止用演示 JSON 或空列表过关。先查询 HTTP/JSON/日期时间/列表渲染/滚动/状态主线程更新 API 并记录 ref。

使用同一账号和同一学期数据进行 Android/HarmonyOS 对照。数据内容、数量、排序、关键字段和交互必须一致；UI 截图接近。每个切片 PASS 后才开始下一个。

阶段完成后更新证据与矩阵并停止。

