# Cangjie HarmonyOS Project Template

Use `tools/create_project.py` as the entry point for creating or repairing projects.

The canonical template lives in:

```text
templates/cangjie-harmonyos-app/
```

The template contains real project files with placeholder tokens such as:

- `__APP_NAME__`
- `__BUNDLE_NAME__（另支持 __VENDOR__）`
- `__PACKAGE_NAME__`
- `__MODULE_NAME__`
- `__SDK_VERSION__`
- `__MODEL_VERSION__`

The project creation tool validates parameters, copies the template tree, replaces placeholders in text files, and copies binary media resources without modification.

For normal use from a project directory where this solution's skills have already been copied:

```bash
python <harmonyos-project-bootstrap-skill>/tools/create_project.py --target-dir . --app-name "Todo" --bundle-name "com.example.todo"
```

Use `--repair` to overwrite files owned by the template when a generated project is incomplete or structurally damaged.
