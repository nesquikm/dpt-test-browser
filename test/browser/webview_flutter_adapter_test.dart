// AC-STE-256.2..AC-STE-256.5: WebviewFlutterAdapter behaviour.
//
// We mock the underlying [WebViewController] via mocktail so the tests
// stay platform-free (no MissingPluginException on the host VM) and assert
// delegation + NavigationDelegate fan-out deterministically.

import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:webview_flutter_platform_interface/webview_flutter_platform_interface.dart';

import 'package:dpt_test_browser/browser/webview_flutter_adapter.dart';

class _MockWebViewController extends Mock implements WebViewController {}

class _FakeNavigationDelegate extends Fake implements NavigationDelegate {}

class _TestWebViewPlatform extends WebViewPlatform {
  @override
  PlatformNavigationDelegate createPlatformNavigationDelegate(
    PlatformNavigationDelegateCreationParams params,
  ) =>
      _NoopPlatformNavigationDelegate(params);
}

class _NoopPlatformNavigationDelegate extends PlatformNavigationDelegate
    with MockPlatformInterfaceMixin {
  _NoopPlatformNavigationDelegate(super.params) : super.implementation();

  @override
  Future<void> setOnPageStarted(_) async {}
  @override
  Future<void> setOnPageFinished(_) async {}
  @override
  Future<void> setOnHttpError(_) async {}
  @override
  Future<void> setOnProgress(_) async {}
  @override
  Future<void> setOnWebResourceError(_) async {}
  @override
  Future<void> setOnNavigationRequest(_) async {}
  @override
  Future<void> setOnUrlChange(_) async {}
  @override
  Future<void> setOnHttpAuthRequest(_) async {}
  @override
  Future<void> setOnSSlAuthError(_) async {}
}

void main() {
  setUpAll(() {
    WebViewPlatform.instance = _TestWebViewPlatform();
    registerFallbackValue(_FakeNavigationDelegate());
    registerFallbackValue(Uri.parse('https://example.com'));
  });

  late _MockWebViewController controller;

  WebviewFlutterAdapter newAdapter() {
    controller = _MockWebViewController();
    when(() => controller.setNavigationDelegate(any()))
        .thenAnswer((_) async {});
    when(() => controller.loadRequest(any())).thenAnswer((_) async {});
    when(() => controller.goBack()).thenAnswer((_) async {});
    when(() => controller.goForward()).thenAnswer((_) async {});
    when(() => controller.reload()).thenAnswer((_) async {});
    when(() => controller.getTitle()).thenAnswer((_) async => null);
    return WebviewFlutterAdapter(controllerFactory: () => controller);
  }

  NavigationDelegate capturedDelegate() {
    return verify(() => controller.setNavigationDelegate(captureAny()))
        .captured
        .last as NavigationDelegate;
  }

  // ---------------------------------------------------------------------------
  // AC-STE-256.2: ctor wires a NavigationDelegate via the injected controller.
  // ---------------------------------------------------------------------------
  group('WebviewFlutterAdapter ctor', () {
    test('installs a NavigationDelegate on the underlying controller', () {
      final adapter = newAdapter();
      expect(capturedDelegate(), isNotNull);
      adapter.dispose();
    });
  });

  // ---------------------------------------------------------------------------
  // AC-STE-256.3: loadUrl/goBack/goForward/reload delegate to the controller.
  // ---------------------------------------------------------------------------
  group('WebviewFlutterAdapter delegation', () {
    test('loadUrl forwards the Uri to controller.loadRequest', () async {
      final adapter = newAdapter();
      final url = Uri.parse('https://example.com/path?q=1');

      await adapter.loadUrl(url);

      verify(() => controller.loadRequest(url)).called(1);
      await adapter.dispose();
    });

    test('goBack delegates to controller.goBack', () async {
      final adapter = newAdapter();
      await adapter.goBack();
      verify(() => controller.goBack()).called(1);
      await adapter.dispose();
    });

    test('goForward delegates to controller.goForward', () async {
      final adapter = newAdapter();
      await adapter.goForward();
      verify(() => controller.goForward()).called(1);
      await adapter.dispose();
    });

    test('reload delegates to controller.reload', () async {
      final adapter = newAdapter();
      await adapter.reload();
      verify(() => controller.reload()).called(1);
      await adapter.dispose();
    });
  });

  // ---------------------------------------------------------------------------
  // AC-STE-256.4: NavigationDelegate callbacks fan out to streams.
  // ---------------------------------------------------------------------------
  group('WebviewFlutterAdapter NavigationDelegate fan-out', () {
    test('onPageStarted fires onLoadStart with the parsed Uri', () async {
      final adapter = newAdapter();
      final delegate = capturedDelegate();

      final firstUri = adapter.onLoadStart.first;
      delegate.onPageStarted!('https://example.com/start');

      expect(await firstUri, equals(Uri.parse('https://example.com/start')));
      await adapter.dispose();
    });

    test('onPageFinished fires onLoadFinish with the parsed Uri', () async {
      final adapter = newAdapter();
      final delegate = capturedDelegate();

      final firstUri = adapter.onLoadFinish.first;
      delegate.onPageFinished!('https://example.com/finish');

      expect(await firstUri, equals(Uri.parse('https://example.com/finish')));
      await adapter.dispose();
    });

    test('onPageFinished emits onTitleChanged when the title becomes non-null',
        () async {
      final adapter = newAdapter();
      when(() => controller.getTitle()).thenAnswer((_) async => 'Example');
      final delegate = capturedDelegate();

      final firstTitle = adapter.onTitleChanged.first;
      delegate.onPageFinished!('https://example.com/');

      expect(await firstTitle, equals('Example'));
      await adapter.dispose();
    });

    test('onPageFinished does not re-emit onTitleChanged for unchanged titles',
        () async {
      final adapter = newAdapter();
      when(() => controller.getTitle()).thenAnswer((_) async => 'Example');
      final delegate = capturedDelegate();

      final emitted = <String>[];
      final sub = adapter.onTitleChanged.listen(emitted.add);

      delegate.onPageFinished!('https://a/');
      await Future<void>.delayed(Duration.zero);
      delegate.onPageFinished!('https://a/'); // same title -> no re-emit
      await Future<void>.delayed(Duration.zero);

      expect(emitted, equals(['Example']));
      await sub.cancel();
      await adapter.dispose();
    });

    test('onWebResourceError fans out to onLoadError', () async {
      final adapter = newAdapter();
      final delegate = capturedDelegate();

      final firstErr = adapter.onLoadError.first;
      delegate.onWebResourceError!(
        WebResourceError(errorCode: -2, description: 'host unreachable'),
      );

      final err = await firstErr;
      expect(err.code, equals(-2));
      expect(err.message, equals('host unreachable'));
      await adapter.dispose();
    });

    test('http-error fans out to onLoadError with status-code message',
        () async {
      // webview_flutter 4.13.1 does not expose `onHttpError` as a public
      // field on NavigationDelegate (the wiring is platform-private), so
      // we drive the internal handler via the visibleForTesting hook.
      final adapter = newAdapter();

      final firstErr = adapter.onLoadError.first;
      adapter.debugDispatchHttpError(
        HttpResponseError(
          response: WebResourceResponse(
            uri: Uri.parse('https://example.com/missing'),
            statusCode: 404,
          ),
        ),
      );

      final err = await firstErr;
      expect(err.url, equals(Uri.parse('https://example.com/missing')));
      expect(err.code, equals(404));
      expect(err.message, equals('HTTP 404'));
      await adapter.dispose();
    });

    test('http-error with null response defaults message to "HTTP error"',
        () async {
      final adapter = newAdapter();

      final firstErr = adapter.onLoadError.first;
      adapter.debugDispatchHttpError(HttpResponseError());

      final err = await firstErr;
      expect(err.url, equals(Uri.parse('')));
      expect(err.code, isNull);
      expect(err.message, equals('HTTP error'));
      await adapter.dispose();
    });
  });

  // ---------------------------------------------------------------------------
  // AC-STE-256.5: dispose closes streams + post-dispose calls are no-ops.
  // ---------------------------------------------------------------------------
  group('WebviewFlutterAdapter dispose', () {
    test('dispose closes all four streams', () async {
      final adapter = newAdapter();

      final loadStartDone = adapter.onLoadStart.drain<void>();
      final loadFinishDone = adapter.onLoadFinish.drain<void>();
      final titleChangedDone = adapter.onTitleChanged.drain<void>();
      final loadErrorDone = adapter.onLoadError.drain<void>();

      await adapter.dispose();

      // drain Futures complete only when the streams are closed.
      await Future.wait<void>([
        loadStartDone,
        loadFinishDone,
        titleChangedDone,
        loadErrorDone,
      ]).timeout(const Duration(seconds: 1));
    });

    test('post-dispose loadUrl/goBack/goForward/reload are no-ops', () async {
      final adapter = newAdapter();
      await adapter.dispose();

      await adapter.loadUrl(Uri.parse('https://example.com'));
      await adapter.goBack();
      await adapter.goForward();
      await adapter.reload();

      verifyNever(() => controller.loadRequest(any()));
      verifyNever(() => controller.goBack());
      verifyNever(() => controller.goForward());
      verifyNever(() => controller.reload());
    });

    test('post-dispose NavigationDelegate callbacks emit nothing (do not throw)',
        () async {
      final adapter = newAdapter();
      final delegate = capturedDelegate();

      await adapter.dispose();

      // Calling the captured callbacks after dispose must not throw on a
      // closed StreamController; the adapter guards each handler.
      delegate.onPageStarted!('https://example.com');
      delegate.onPageFinished!('https://example.com');
      delegate.onWebResourceError!(
        WebResourceError(errorCode: 0, description: ''),
      );
      adapter.debugDispatchHttpError(
        HttpResponseError(
          response: WebResourceResponse(
            uri: Uri.parse('https://example.com'),
            statusCode: 500,
          ),
        ),
      );
    });

    test('dispose is idempotent', () async {
      final adapter = newAdapter();
      await adapter.dispose();
      await adapter.dispose(); // must not throw
    });
  });
}
