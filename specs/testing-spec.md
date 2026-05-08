# Testing Specification

## 1. Test Framework

- **Runner:** `flutter_test`
- **Mocking:** `mocktail` (NOT mockito)
- **Bloc testing:** `bloc_test`
- **Coverage:** `fvm flutter test --coverage` → `coverage/lcov.info`

## 2. Test Structure

**Layout policy: `tests/-mirror`** — `test/` mirrors `lib/`, one `*_test.dart` per source file (Flutter convention; overrides toolkit default of `src/`-co-located).

```
lib/
├── tabs/
│   ├── tab.dart
│   └── tab_manager_cubit.dart
└── ui/
    └── tab_bar.dart

test/
├── tabs/
│   ├── tab_test.dart
│   └── tab_manager_cubit_test.dart
└── ui/
    └── tab_bar_test.dart
```

## 3. Conventions

### Naming
- Files: `*_test.dart`
- Test groups: `group('TabManagerCubit', ...)` per class under test.
- Test names: `'<verb> <expected behavior> when <precondition>'`.

### What to Test
- Cubit state transitions (`bloc_test` — `act` → `expect` lists of states).
- Widget rendering & user interaction (pump → tap → expect).
- URL parsing / validation in `lib/shared/url.dart`.
- Webview adapter happy-path via fake adapter.

### What NOT to Test
- Real network — webview HTTP traffic is out of scope for unit tests.
- Generated files (`*.g.dart`, `*.freezed.dart`).
- Third-party widgets / framework internals.
- Platform UI (golden tests deferred — manual verification per platform in M1).

## 4. Coverage Targets

| Layer   | Target | Minimum |
|---------|--------|---------|
| `lib/tabs/`   | ≥ 90% | 80% |
| `lib/browser/` | ≥ 85% | 75% |
| `lib/ui/`     | ≥ 70% | 60% |
| Overall | ≥ 75% | 65% |

## 5. Test Data

- **URL fixtures:** `test/fixtures/urls.dart` — known-good and malformed URLs for parser tests.
- **Fake webview adapter:** `test/fakes/fake_webview_adapter.dart` — implements the `WebviewAdapter` interface, exposes `emitLoadStart` / `emitLoadFinish` / `emitTitleChanged` / `emitLoadError` to drive the four streams synchronously.
- **Frozen time:** not needed in M1 (no time-sensitive logic).
