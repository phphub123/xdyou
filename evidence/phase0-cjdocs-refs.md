# Phase 0 cjdocs references

Commands used the writable copy and Python 3.11.9:

```powershell
& C:\Users\21768\AppData\Local\Programs\Python\Python311\python.exe .agents\skills\cangjie-harmonyos-knowledge\rag\cjdocs.py --index-dir C:\tmp\xdyou-cjdocs doctor
& C:\Users\21768\AppData\Local\Programs\Python\Python311\python.exe .agents\skills\cangjie-harmonyos-knowledge\rag\cjdocs.py --index-dir C:\tmp\xdyou-cjdocs query "ArkUI Button TextInput state onClick" --top-k 8
```

- doctor: SQLite 3.45.1, FTS5 trigram enabled, 649 documents, 12,575 sections, and 5,955 symbols.
- read ref: `docs/API/arkui-cj/cj-text-input-textinput.md#init-resourcestr-resourcestr-textinputcontroller`.
  - Conclusion: `TextInput` uses named `placeholder:`, `text:`, and `controller:` parameters.
- read ref: `docs/API/ArkData/cj-apis-preferences.md#static-func-getpreferences-uiabilitycontext-string`.
  - Conclusion: obtain a `Preferences` instance from `UIAbilityContext`; persistence work will use this API after the environment gate passes.
- Query also matched `docs/API/arkui-cj/cj-button-picker-button.md` and PromptAction references; use explicit ArkUI units and documented click signatures.
