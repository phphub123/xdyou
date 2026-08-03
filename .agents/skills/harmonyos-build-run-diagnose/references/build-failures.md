# Build Failure Patterns

## cjpm Incremental Cache Deserialization

Signature:

```text
Failed :entry:default@CompileCangjie
DataModelException: This data is not DataModelString.
cjpm.implement.DepModel::loadDepIncrementalCache
```

Treat this as a project-local cache/intermediate compatibility problem before editing application code.

Recovery:

1. Keep the relevant `build.log` excerpt.
2. Remove only paths inside the project root:
   - `.hvigor/cache`
   - `.hvigor/dependencyMap`
   - `entry/build/default/intermediates/cj`
   - `entry/build/default/intermediates/loader`
   - `entry/build/default/intermediates/source_map`
3. Rebuild with `build_recovery.py --retry`.
4. If it repeats, temporarily set `[profile.build] incremental = false` in `entry/cjpm.toml`, rebuild, and record whether the setting was kept.

## hdc Missing From PATH

Signature:

```text
hdc : The term 'hdc' is not recognized
```

Use the DevEco toolchains path directly or add it to the current shell PATH:

```powershell
$env:PATH = "C:\Program Files\Huawei\DevEco Studio\sdk\default\openharmony\toolchains;$env:PATH"
```

## stdx Package or Link Failure

Signatures include `stdx`, `cannot find library`, `package not found`, or `undefined symbol`.

Check:

1. Target platform matches the emulator/device ABI.
2. `entry/cjpm.toml` target config has the correct `bin-dependencies.path-option`.
3. x86_64 is used for emulator, aarch64 for most physical devices.
4. Rebuild after dependency path changes.

## ArkTS Habit Copied Into Cangjie

| Log or source clue | Likely cause | Fix |
| --- | --- | --- |
| `expected type name after ':'` with `{left: 20}` | ArkTS object literal used in Cangjie | Use named parameters, for example `.margin(left: 20.vp)` |
| `'trim' is not a member of struct 'String'` | JS/ArkTS String API assumed | Check Cangjie String docs; use `trimAscii()` when suitable |
| `'length' is not a member of class 'ObservedArrayList'` | JS array length used on observed list | Use `.size` |
| `'add' is not a member of class 'ObservedArrayList'` | Generic collection method assumed | Use `.append(value)` for appending items |
| Length/spacing overload mismatch | Missing unit or wrong numeric type | Use `.vp`, `.percent`, or documented option types |

Always inspect the source line before applying a pattern.
