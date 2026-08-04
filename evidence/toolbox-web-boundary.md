# Toolbox Web boundary evidence

Date: 2026-08-04

- `ToolboxWebPage` mounts the real source URL immediately and exposes stable IDs for Web history back, explicit return to the seven-row list, status, retry and the Web component.
- `WebviewController.canGoBack`, `goBack` and `reload` are guarded with `BusinessException`; page loading has a cancellable 25-second main-page timeout.
- SDK 6.1 Cangjie ArkWeb exposes page begin/end events but no resource-load error callback. The honest error boundary is therefore controller exception plus timeout; no successful page is fabricated.
- Dual-ABI Hvigor build completed successfully. The x86_64 HAP was installed and launched on `127.0.0.1:5557`.
- `acceptance/runtime/2026-08-04-toolbox-web-boundary/` passed 4/4 component assertions for Web, status, history back and list return.
- `evidence/runtime/2026-08-04-toolbox-web-boundary-hilog/` reports zero application-line FATAL and ERROR entries.

Authenticated school destinations still require their own valid sessions; this evidence verifies the navigation/loading/error boundary, not authenticated business completion.
