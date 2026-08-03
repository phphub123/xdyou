# XDYou 两人 Git 协作约定

## 分支

- `main`：只接受已构建、可安装且更新验收记录的集成结果。
- `develop`：双方日常集成分支。
- `feature/<owner>/<slice>`：一个纵向功能切片一个分支，例如 `feature/partner/campus-card`。
- `fix/<owner>/<issue>`：独立缺陷修复。

禁止双方直接在同一个功能分支工作，也不要直接向 `main` 提交。

## 每次开始

```powershell
git switch develop
git pull --ff-only
git switch -c feature/<owner>/<slice>
```

同机并行开发建议为第二位开发者创建独立 worktree：

```powershell
git worktree add <另一个空目录> -b feature/partner/<slice> develop
```

## 功能切片提交门禁

每个分支必须同时包含：

1. `model/repository/controller/page` 的完整纵向实现；
2. 稳定组件 `.id()`；
3. 双 ABI 构建结果；
4. `migration/file-name-map.csv` 更新；
5. `acceptance/acceptance-matrix.csv` 更新；
6. 不含账号、密码、Cookie、Token、付款二维码或原始响应正文。

提交信息使用 `feat(area): ...`、`fix(area): ...`、`test(area): ...`、`docs(area): ...`。

## 合并

功能分支先同步 `develop`，解决冲突并重新构建：

```powershell
git fetch origin
git rebase origin/develop
git push --force-with-lease
```

审查通过后合并到 `develop`。阶段门禁全部通过后，再由 `develop` 合并到 `main` 并打标签。

## 高冲突文件

`entry/src/main/cangjie/index.cj`、`acceptance/acceptance-matrix.csv`、
`migration/file-name-map.csv` 由合并者集中处理。功能开发者优先新增独立文件，避免顺手重排这些文件。

## 外部阻塞

真实 IDS、校园网、独立业务账号或验证码不可用时，代码仍可完成并构建，但验收只能标记
`IN_PROGRESS` 或 `BLOCKED_EXTERNAL`，不得用假 Cookie、演示数据或静态成功绕过。
