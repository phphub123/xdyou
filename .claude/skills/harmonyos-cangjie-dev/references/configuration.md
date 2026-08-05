# Layered Configuration

All present layers load; **later layers override earlier ones**. Effective order (low → high):

1. Built-in defaults and auto-detection
2. User config: `~/.harmonyos-cangjie/config.toml`
3. Project config, in load order: `<project>/harmonyos-cangjie.toml` → `<project>/.claude/harmonyos-cangjie.toml` → `<project>/.agents/harmonyos-cangjie.toml`
4. File pointed to by `HARMONYOS_CANGJIE_CONFIG` (the only environment hook; there are no per-field env overrides)
5. CLI arguments

Most projects need no config at all: toolchain paths auto-discover (default DevEco install; newest version under `~/.cangjie-sdk/<version>/cangjie`), devices auto-resolve (sole online target, emulator ports `5555/5557/5554/5559` probed via `hdc tconn`), and app metadata is detected from project files.

Use `user-config.example.toml` and `project-config.example.toml` (in this references/ directory, shipped with the skill) as templates.

## User Config

Use user config for machine-local or sensitive defaults:

```toml
[toolchain]
deveco_home = "C:/Program Files/Huawei/DevEco Studio"
# cangjie_sdk：仅在需要覆盖自动发现（~/.cangjie-sdk 下最高版本）时才设置
# cangjie_sdk = "~/.cangjie-sdk/6.1/cangjie"
hdc = "C:/Program Files/Huawei/DevEco Studio/sdk/default/openharmony/toolchains/hdc.exe"
ohpm_registry = "https://ohpm.openharmony.cn/ohpm/"
strict_ssl = true

[device]
# target：仅在多设备在线需要钉住其一时才设置（默认自动解析唯一在线设备/扫描模拟器端口）
# target = "127.0.0.1:5557"

[rag]
ai_provider = "aliyun"
api_key_env = "DASHSCOPE_API_KEY"
version = "default"
llm_model = "deepseek-v4-pro"
embedding_model = "text-embedding-v4"
```

Do not store real API keys in config files. Set `DASHSCOPE_API_KEY` in the shell when AI is needed. Do not configure RAG docs or index paths; the knowledge base is packaged inside the `cangjie-harmonyos-knowledge` skill.

## Project Config

Use project config for repeatable project defaults. For the common case of developing an existing HarmonyOS project, do not configure `[new_project]`; build, run, UI, hilog, and RAG tools should read the existing project files and only need `[rag]` or occasional `[runtime]` overrides.

Configure `[new_project]` only when creating a new project from the packaged templates or when repeatedly repairing a template-owned project with fixed identities:

```toml
# [new_project]
# app_name = "Cangjie App"
# bundle_name = "com.example.myapplication"
# package_name = "ohos_app_cangjie_entry"
# module_name = "entry"
# vendor = "example"
# sdk_version = "6.1.0(23)"
# model_version = "6.1.0"

[rag]
version = "default"
```

## Advanced Runtime Overrides

Do not ask the user to configure runtime fields first. Build, UI, and hilog tools should detect:

- `bundle` from `AppScope/app.json5`
- `module` from root `build-profile.json5`
- `ability` from `<module>/src/main/module.json5`
- `hap` from `<module>/build/**/*.hap`

Use `[runtime]` only when detection is ambiguous, the app has multiple launch targets, or the agent must force a specific build output:

```toml
[runtime]
bundle = "com.example.myapplication"
ability = "EntryAbility"
module = "entry"
hap = "entry/build/default/outputs/default/entry-default-unsigned.hap"
```

## Fallback Behavior

- RAG works offline without config or API keys.
- RAG docs and index paths are skill-local and work under any skills container such as `.claude/skills` or `.agents/skills`.
- AI RAG features require a configured API key env var or explicit key. If absent, vector/synthesis features degrade or are skipped.
- Build works without config only when DevEco Studio and the Cangjie SDK are installed at default paths.
- Runtime tools work without runtime config when `hdc` is on `PATH` or installed at the default DevEco path and app metadata can be detected from the project.
