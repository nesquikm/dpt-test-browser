# Changelog

All notable changes to this project will be documented in this file. The
format follows [Keep a Changelog](https://keepachangelog.com/en/1.1.0/) and
this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [1.1.0] — 2026-05-08 — "Skylight"

### Added
- `BrowserTab` model + `TabManagerCubit` — Freezed state container with
  open / close / select / navigate / setLoading / setTitle (STE-254).
- Platform-agnostic `WebviewAdapter` interface + `WebviewFlutterAdapter`
  implementation built on `webview_flutter` ^4.13.1; aligns iOS 13+ /
  Android `minSdk 24` / macOS 10.15+ targets and grants the macOS App
  Sandbox `network.client` entitlement (STE-256).
- `BrowserShell` UI — horizontal tab strip, back / forward / reload +
  URL `TextField` address bar, per-tab webview surface with inline error
  + Retry. `parseAddressBarInput` accepts bare hosts and prepends
  `https://` when the user omits the scheme (STE-257).

Total test count at release: 81 tests, 0 failures, 0 errors.
