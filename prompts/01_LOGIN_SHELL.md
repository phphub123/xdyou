# 阶段 1：登录、会话、主页壳与设置

继续当前工作。先读取 `AGENTS.md`、`migration/progress.md`、已有构建日志和 `evidence/skill-and-rag-usage.md`，再调用本阶段相关 skills。

本阶段完成一个真实纵向切片：

1. 迁移 `main.dart` 的初始化、首登判断、持久化偏好、主题/三语入口和异常展示。
2. 迁移 `page/login/`、IDS/Ehall 登录主链、Cookie 会话、滑块/手工验证码路径。
3. 迁移 `page/homepage/home.dart` 的五个主导航入口和 `page/setting/` 基础设置。
4. 保持 `LoginWindow`、`IDSSession`、`EhallSession`、`loginEhall`、`HomePage`、`SettingWindow` 等名称；例外登记映射。
5. 不允许用固定账号、假登录成功或静态主页替代真实会话。

先查询并阅读本地知识库中与 TextInput、Button、状态更新、HTTP、TLS、Cookie、持久化、网络权限、路由、Web/验证码有关的 ref，再编码。

验收：

- 清除数据后进入登录页；
- 密码可见性切换、空密码校验、加载态、错误态工作；
- 真实学生账号可登录并进入五栏主页壳；
- 关闭重开仍能读取登录态；退出/清数据回到登录；
- Android/HarmonyOS 保存同状态成对截图；
- 构建、安装、启动、目标进程和 hilog 证据齐全。

通过后更新所有迁移文档和验收矩阵，停止等待下一阶段。

