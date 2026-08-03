# CJHybridComponent UI Embedding

Use this reference when an ArkTS page embeds a Cangjie component.

## Shape

ArkTS page:

```typescript
import { CJHybridComponent } from '@cangjie/cjhybridcomponent';

@Entry
@Component
struct Index {
  build() {
    Row() {
      CJHybridComponent({
        library: 'ohos_app_cangjie_entry',
        component: 'EntryView'
      })
    }
    .height('100%')
    .width('100%')
  }
}
```

Cangjie component:

```cangjie
@HybridComponentEntry
@Component
class EntryView {
    func build() {
        Text("Hello Hybrid")
    }
}
```

## Tooling

Create a wrapper page from the project root:

```powershell
python <cangjie-arkts-interop-skill>/tools/add_hybrid_component.py --component MetricsPanel --page metrics --title "Cangjie Metrics"
```

Then route to `pages/metrics` from ArkTS or embed `CJHybridComponent` directly in an existing ArkTS page.

## Alignment Rules

- `library` equals `cjpm.toml` `[package].name`, not the `lib*.so` import string.
- `component` equals the Cangjie component class name.
- The ArkTS wrapper page must be listed in `main_pages.json`.
- Use ArkTS for router/page lifecycle and Cangjie for embedded component UI.
- If Cangjie needs ArkTS router behavior, pass callbacks through an interop boundary instead of calling ArkTS router directly.
- Add `@cangjie/cjhybridcomponent` to `entry/oh-package.json5` only for mixed UI component use.
- The Cangjie component appears in the UI tree under an ArkTS common/native container such as `__Common__`; assert business text inside it, not only the wrapper page.

## Build and Runtime Notes

- `@cangjie/cjhybridcomponent` may emit ArkTS lint warnings from its own implementation and a `page_show` resource-name conflict warning. Treat these as non-blocking when `BUILD SUCCESSFUL` and UI assertions pass.
- A Cangjie hybrid component is not a full Cangjie page. It has no independent page lifecycle and does not own ArkTS router behavior.
- Prefer an ArkTS wrapper page for routing. Inline embedding into an existing ArkTS page is also valid when the layout is simple.
