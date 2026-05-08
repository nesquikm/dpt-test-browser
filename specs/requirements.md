# Requirements

## 1. Overview

**dpt-test-browser** is a simple tabbed web browser built with Flutter, targeting macOS desktop, iOS, and Android. The goal is a minimal, embedded-webview browsing experience: open URLs in tabs, switch between tabs, navigate (back/forward/reload), and close tabs.

The project also serves as a reference / smoke-test target for the dev-process-toolkit Flutter scaffolding flow.

## 2. Functional Requirements (cross-cutting only)

<!-- Per-FR detail lives in `specs/frs/<id>.md`. Cross-cutting concerns only here. -->

- **Webview policy:** all URL loads happen inside an embedded webview owned by the active tab. The app never opens an external browser.
- **State persistence:** open tabs and current URLs persist across app launches (M2+).
- **Platform parity:** every browsing feature behaves identically across macOS / iOS / Android. Platform-specific affordances (toolbar style, gestures) may differ, but core flows must not.

## 3. Non-Functional Requirements

### NFR-1: Performance
- Tab switch ≤ 100 ms (perceived) on the primary platform (macOS).
- Cold start ≤ 2 s on a recent dev machine.
- Webview frame render must not block UI thread.

### NFR-2: Security
- All webviews run with default sandboxing for the platform (WKWebView on iOS/macOS, Chromium WebView on Android).
- No injection of arbitrary JS into untrusted pages.
- No persistence of passwords or form auto-fill in M1.

### NFR-3: Availability
- App must launch and show a usable empty browser even with no network.
- A failed page load must not crash the tab — show an inline error UI.

## 4. Edge Cases

<!-- Filled by /spec-write and /implement as discovered. -->

## Security / Abuse Cases

| Attacker Goal | Attack Vector | Mitigation |
|--------------|---------------|------------|
| <!-- TBD --> | <!-- TBD --> | <!-- TBD --> |

## 5. Out of Scope

- Sync across devices.
- Account/login.
- Extensions / plugins.
- Bookmarks (deferred to M2+).
- Private / incognito mode (deferred to M2+).
- Download manager.
- Custom DNS / proxy.

## 6. Traceability Matrix

| Requirement | Implementation | Tests |
|-------------|---------------|-------|
