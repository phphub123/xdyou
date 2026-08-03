# 阶段 4：论坛、扩展内容与系统能力

继续当前工作，按功能域逐一闭环：

1. 完整迁移 `external/ruisi_flutter/`：登录、版块、主题列表、详情、搜索、收藏、消息、发帖、验证码、表情。
2. 迁移主页中的 XDU Planet、Pig/Dashboard、更新通知等现存扩展入口。
3. 三语国际化、明暗主题、颜色设置、关于页与链接。
4. 本地通知与上课提醒。
5. 系统日历同步。
6. 课程表桌面卡片/服务能力，参考 `source/reference/android/widget/`。
7. 分享、文件选择、外部链接和应用重启等平台能力。

必须先查询并阅读对应 HarmonyOS/Cangjie API ref。若纯仓颉 API 确实缺失，输出带 ref、SDK 版本、失败探针和最小边界的提案；未经我批准不得引入 ArkTS。不能直接删除 Android/Flutter 特性。

每项 build/install/run/interaction 验收，补齐矩阵后停止。

