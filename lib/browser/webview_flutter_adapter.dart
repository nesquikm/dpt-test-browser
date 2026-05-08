import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:webview_flutter/webview_flutter.dart';

import 'package:dpt_test_browser/browser/webview_adapter.dart';

/// Builds the underlying [WebViewController]. Tests override this to inject
/// a fake controller; production callers leave it null and get the real
/// platform controller.
typedef WebViewControllerFactory = WebViewController Function();

/// `webview_flutter` ^4.13.1 implementation of [WebviewAdapter].
///
/// Wraps a [WebViewController] and fans its [NavigationDelegate] callbacks
/// out to the four streams declared on [WebviewAdapter].
class WebviewFlutterAdapter implements WebviewAdapter {
  WebviewFlutterAdapter({WebViewControllerFactory? controllerFactory})
      : _controller =
            (controllerFactory ?? WebViewController.new)() {
    _controller.setNavigationDelegate(
      NavigationDelegate(
        onPageStarted: _onPageStarted,
        onPageFinished: _onPageFinished,
        onWebResourceError: _onWebResourceError,
        onHttpError: _onHttpError,
      ),
    );
  }

  final WebViewController _controller;

  final StreamController<Uri> _loadStartCtrl =
      StreamController<Uri>.broadcast();
  final StreamController<Uri> _loadFinishCtrl =
      StreamController<Uri>.broadcast();
  final StreamController<String> _titleChangedCtrl =
      StreamController<String>.broadcast();
  final StreamController<WebviewLoadError> _loadErrorCtrl =
      StreamController<WebviewLoadError>.broadcast();

  String? _lastTitle;
  bool _disposed = false;

  /// The wrapped controller. Exposed so callers (e.g. `WebViewWidget`) can
  /// mount the platform view; tests rarely need it.
  WebViewController get controller => _controller;

  @override
  Stream<Uri> get onLoadStart => _loadStartCtrl.stream;

  @override
  Stream<Uri> get onLoadFinish => _loadFinishCtrl.stream;

  @override
  Stream<String> get onTitleChanged => _titleChangedCtrl.stream;

  @override
  Stream<WebviewLoadError> get onLoadError => _loadErrorCtrl.stream;

  @override
  Future<void> loadUrl(Uri url) async {
    if (_disposed) return;
    await _controller.loadRequest(url);
  }

  @override
  Future<void> goBack() async {
    if (_disposed) return;
    await _controller.goBack();
  }

  @override
  Future<void> goForward() async {
    if (_disposed) return;
    await _controller.goForward();
  }

  @override
  Future<void> reload() async {
    if (_disposed) return;
    await _controller.reload();
  }

  @override
  Future<void> dispose() async {
    if (_disposed) return;
    _disposed = true;
    await _loadStartCtrl.close();
    await _loadFinishCtrl.close();
    await _titleChangedCtrl.close();
    await _loadErrorCtrl.close();
  }

  // ---------------------------------------------------------------------------
  // NavigationDelegate handlers
  // ---------------------------------------------------------------------------

  void _onPageStarted(String url) {
    if (_disposed) return;
    final uri = Uri.tryParse(url);
    if (uri != null) _loadStartCtrl.add(uri);
  }

  Future<void> _onPageFinished(String url) async {
    if (_disposed) return;
    final uri = Uri.tryParse(url);
    if (uri != null) _loadFinishCtrl.add(uri);

    // webview_flutter 4.x has no native title-changed callback — poll once
    // per page-finish and emit only when the value actually changed.
    final title = await _controller.getTitle();
    if (_disposed) return;
    if (title != null && title.isNotEmpty && title != _lastTitle) {
      _lastTitle = title;
      _titleChangedCtrl.add(title);
    }
  }

  void _onWebResourceError(WebResourceError error) {
    if (_disposed) return;
    _loadErrorCtrl.add(WebviewLoadError(
      url: Uri(),
      code: error.errorCode,
      message: error.description,
    ));
  }

  void _onHttpError(HttpResponseError error) {
    if (_disposed) return;
    final response = error.response;
    final statusCode = response?.statusCode;
    _loadErrorCtrl.add(WebviewLoadError(
      url: response?.uri ?? Uri(),
      code: statusCode,
      message: statusCode != null ? 'HTTP $statusCode' : 'HTTP error',
    ));
  }

  /// Test hook: drives the same code path the platform invokes when an HTTP
  /// error fires. Needed because `webview_flutter` 4.13.1 does not expose
  /// the http-error callback as a public field on [NavigationDelegate].
  @visibleForTesting
  void debugDispatchHttpError(HttpResponseError error) => _onHttpError(error);
}
