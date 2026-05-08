# Technical Specification

## 1. Architecture

### System Overview

A single Flutter app with an embedded webview per tab. The tab manager owns a list of `Tab` records (id, title, url, history); the active tab's webview is rendered into the main content area. UI is driven by a Bloc/Cubit holding the tab list + active-tab pointer.

### Directory Structure

```
lib/
├── main.dart
├── browser/
│   ├── webview_adapter.dart       # platform-agnostic webview surface
│   └── webview_adapter_impl.dart  # concrete impl (TBD: webview_flutter vs flutter_inappwebview)
├── tabs/
│   ├── tab.dart                   # Tab model (Freezed)
│   ├── tab_manager_cubit.dart     # active-tab + open-tabs state
│   └── tab_manager_state.dart
├── ui/
│   ├── browser_shell.dart         # top-level shell widget
│   ├── tab_bar.dart               # tab strip
│   ├── address_bar.dart           # URL input + nav buttons
│   └── tab_view.dart              # webview container for active tab
└── shared/
    └── url.dart                   # URL parsing/validation helpers

test/
└── … mirrors lib/ with `*_test.dart`
```

### Key Design Decisions

| Decision | Choice | Rationale |
|----------|--------|-----------|
| State management | Bloc/Cubit | Toolkit's Flutter convention; bloc_test makes state-transition tests cheap |
| Webview package | TBD (M1 ADR) | `webview_flutter` covers iOS/Android cleanly but no macOS; `flutter_inappwebview` covers all three with one API |
| Models | Freezed + json_serializable | Idiomatic for Bloc state; codegen via `make codegen` (added when introduced) |
| Navigation | Single shell — no router yet | One screen: tab strip + active webview |

## 2. Data Model

```dart
// lib/tabs/tab.dart (TBD — Freezed)
@freezed
class BrowserTab with _$BrowserTab {
  const factory BrowserTab({
    required String id,
    required Uri url,
    String? title,
    @Default(false) bool isLoading,
  }) = _BrowserTab;
}
```

```dart
// lib/tabs/tab_manager_state.dart (TBD)
@freezed
class TabManagerState with _$TabManagerState {
  const factory TabManagerState({
    required IList<BrowserTab> tabs,
    required String? activeTabId,
  }) = _TabManagerState;
}
```

## 3. API / Interface Design

`TabManagerCubit` methods (all return `void`, mutate state):

- `openTab(Uri initialUrl)` — append new tab, activate it.
- `closeTab(String id)` — remove from list; if it was active, activate previous.
- `selectTab(String id)` — make `id` the active tab.
- `navigate(String id, Uri url)` — update tab's URL.
- `setLoading(String id, bool loading)` — surfaced from webview adapter callbacks.

`WebviewAdapter` interface (one impl per chosen package):

- `loadUrl(Uri url)`
- `goBack() / goForward() / reload()`
- streams: `onLoadStart`, `onLoadFinish`, `onTitleChanged`.

## 4. Key Patterns

### State Management
- `TabManagerCubit` owns top-level state. Per-webview controllers held inside the `TabView` widget; lifecycle tied to the tab's presence in the cubit list.

### Error Handling
- Failed page loads emit `onLoadError` from the adapter; the cubit marks the tab `isLoading: false` and the `TabView` renders an inline error widget.
- Invalid URL input in the address bar shows a snackbar; cubit state is unchanged.

### Testing Strategy
- Bloc unit tests (`bloc_test`) for `TabManagerCubit` state transitions.
- Widget tests for `TabBar`, `AddressBar` — pump cubit, fire events, expect rendered text.
- Webview adapter behind an interface so tests use a fake.

## 5. Dependencies

| Package | Version | Purpose |
|---------|---------|---------|
| flutter | sdk     | Framework |
| cupertino_icons | ^1.0.8 | Default Flutter app icons |
| flutter_test | sdk | Test runner (dev) |
| flutter_lints | ^6.0.0 | Lint rules (dev) |
| mocktail | ^1.0.5 | Mocking (dev) |
| bloc_test | ^10.0.0 | Bloc state-transition tests (dev) |
| flutter_bloc | TBD | State management (added in M1) |
| freezed / freezed_annotation | TBD | Data classes (added in M1) |
| build_runner | TBD | Codegen (dev, added in M1) |
| webview package | TBD (M1 ADR) | Webview embedding |

## 6. Risks & Considerations

- Webview package choice is platform-coverage-driven: `webview_flutter` skips macOS; `flutter_inappwebview` adds maintenance / API surface but covers all three. Decided in M1 ADR.
- iOS WKWebView has stricter cookie / cross-origin behavior than Android's WebView — feature parity must be tested per platform.
- macOS desktop webviews have keyboard / focus quirks distinct from mobile; widget tests cannot fully catch these — manual verification per platform expected.

## Architecture Decision Records

| Decision | Options Considered | Choice | Rationale |
|----------|-------------------|--------|-----------|
| State management | Bloc, Riverpod, Provider | Bloc/Cubit | Toolkit's Flutter convention; bloc_test affords cheap state-transition tests |
| Webview package | webview_flutter, flutter_inappwebview, desktop_webview_window | TBD (M1) | macOS coverage required; decision deferred to M1 |
