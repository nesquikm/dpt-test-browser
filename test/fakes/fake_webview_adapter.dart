import 'dart:async';

import 'package:dpt_test_browser/browser/webview_adapter.dart';

/// Test double for [WebviewAdapter].
///
/// Records [loadUrl] / [goBack] / [goForward] / [reload] calls so widget
/// tests can assert delegation, and exposes `emit*` methods so they can
/// drive deterministic event sequences without standing up a real webview.
class FakeWebviewAdapter implements WebviewAdapter {
  FakeWebviewAdapter();

  // ---------------------------------------------------------------------------
  // Recorded calls (read by tests)
  // ---------------------------------------------------------------------------

  final List<Uri> loadUrlCalls = <Uri>[];
  int goBackCalls = 0;
  int goForwardCalls = 0;
  int reloadCalls = 0;
  int disposeCalls = 0;

  bool get disposed => _disposed;

  // ---------------------------------------------------------------------------
  // Stream backing
  // ---------------------------------------------------------------------------

  final StreamController<Uri> _loadStartCtrl =
      StreamController<Uri>.broadcast();
  final StreamController<Uri> _loadFinishCtrl =
      StreamController<Uri>.broadcast();
  final StreamController<String> _titleChangedCtrl =
      StreamController<String>.broadcast();
  final StreamController<WebviewLoadError> _loadErrorCtrl =
      StreamController<WebviewLoadError>.broadcast();

  bool _disposed = false;

  @override
  Stream<Uri> get onLoadStart => _loadStartCtrl.stream;

  @override
  Stream<Uri> get onLoadFinish => _loadFinishCtrl.stream;

  @override
  Stream<String> get onTitleChanged => _titleChangedCtrl.stream;

  @override
  Stream<WebviewLoadError> get onLoadError => _loadErrorCtrl.stream;

  // ---------------------------------------------------------------------------
  // WebviewAdapter implementation
  // ---------------------------------------------------------------------------

  @override
  Future<void> loadUrl(Uri url) async {
    if (_disposed) return;
    loadUrlCalls.add(url);
  }

  @override
  Future<void> goBack() async {
    if (_disposed) return;
    goBackCalls++;
  }

  @override
  Future<void> goForward() async {
    if (_disposed) return;
    goForwardCalls++;
  }

  @override
  Future<void> reload() async {
    if (_disposed) return;
    reloadCalls++;
  }

  @override
  Future<void> dispose() async {
    if (_disposed) return;
    _disposed = true;
    disposeCalls++;
    await _loadStartCtrl.close();
    await _loadFinishCtrl.close();
    await _titleChangedCtrl.close();
    await _loadErrorCtrl.close();
  }

  // ---------------------------------------------------------------------------
  // Test event emitters
  // ---------------------------------------------------------------------------

  void emitLoadStart(Uri url) => _loadStartCtrl.add(url);
  void emitLoadFinish(Uri url) => _loadFinishCtrl.add(url);
  void emitTitleChanged(String title) => _titleChangedCtrl.add(title);
  void emitLoadError(WebviewLoadError error) => _loadErrorCtrl.add(error);
}
