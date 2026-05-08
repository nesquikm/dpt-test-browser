import 'package:freezed_annotation/freezed_annotation.dart';

part 'webview_adapter.freezed.dart';

/// Value type carrying the data we surface for a failed page load.
///
/// `url` is non-nullable to keep callers from having to null-check, but the
/// platform may not tell us which URL failed (a pure transport-layer
/// `WebResourceError` carries `errorCode` + `description` only). In that
/// case the adapter populates `url` with `Uri()` (empty URI) — display code
/// should treat an empty `Uri.toString()` as "URL unknown".
@freezed
abstract class WebviewLoadError with _$WebviewLoadError {
  const factory WebviewLoadError({
    required Uri url,
    int? code,
    required String message,
  }) = _WebviewLoadError;
}

/// Platform-agnostic surface the rest of the app uses to drive an embedded
/// webview. One concrete impl per webview package; tests use a fake.
abstract class WebviewAdapter {
  Future<void> loadUrl(Uri url);
  Future<void> goBack();
  Future<void> goForward();
  Future<void> reload();

  /// Releases the underlying controller and closes all four streams.
  /// Calling any adapter method post-dispose is a no-op (does not throw).
  Future<void> dispose();

  Stream<Uri> get onLoadStart;
  Stream<Uri> get onLoadFinish;
  Stream<String> get onTitleChanged;
  Stream<WebviewLoadError> get onLoadError;
}

typedef WebviewAdapterFactory = WebviewAdapter Function();
