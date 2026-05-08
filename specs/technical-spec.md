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
│   └── webview_flutter_adapter.dart  # concrete impl over `webview_flutter` package
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
| Webview package | `webview_flutter` ^4.13.1 | Official Flutter team package; supports iOS 13+, Android SDK 24+, macOS 10.15+ — single dep covers all targets, smaller API surface than `flutter_inappwebview` |
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
| webview_flutter | ^4.13.1 | Webview embedding (official Flutter package; iOS 13+ / Android SDK 24+ / macOS 10.15+) |

## 6. Risks & Considerations

- Platform deployment targets locked by `webview_flutter` 4.13.1: iOS 13+, Android `minSdkVersion` 24, macOS 10.15+. Flutter's defaults must be aligned (iOS Podfile, `android/app/build.gradle.kts`, `macos/Runner/AppInfo.xcconfig`) before any webview test can run on device.
- `webview_flutter` 4.x splits responsibilities across `WebViewController` + per-platform `PlatformWebViewControllerCreationParams`. Tab-state mapping (per-tab controller lifecycle, restore on tab re-select) is non-trivial — covered by the cubit + adapter design but warrants integration tests, not just unit.
- iOS WKWebView has stricter cookie / cross-origin behavior than Android's WebView — feature parity must be tested per platform.
- macOS desktop webviews have keyboard / focus quirks distinct from mobile; widget tests cannot fully catch these — manual verification per platform expected.
- Disposing a webview controller on tab close is async; back-to-back close+open of the last tab is a known race-prone path — must be covered by cubit tests.

## Architecture Decision Records

| Decision | Options Considered | Choice | Rationale |
|----------|-------------------|--------|-----------|
| State management | Bloc, Riverpod, Provider | Bloc/Cubit | Toolkit's Flutter convention; bloc_test affords cheap state-transition tests |
| Webview package | webview_flutter, flutter_inappwebview, hybrid (webview_flutter + macOS-specific) | `webview_flutter` ^4.13.1 | Official Flutter team package; current 4.x line covers iOS 13+, Android SDK 24+, macOS 10.15+ — a single dep covers all three target platforms. Smaller API surface than `flutter_inappwebview` (cookies / JS bridge / devtools not in scope for the M1 simple browser). Hybrid rejected as needless abstraction once `webview_flutter` is single-package sufficient. |
