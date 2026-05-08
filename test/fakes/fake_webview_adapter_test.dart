// AC-STE-256.6: FakeWebviewAdapter sanity — each emit* method produces a
// stream event and call recording works as advertised.

import 'package:flutter_test/flutter_test.dart';

import 'package:dpt_test_browser/browser/webview_adapter.dart';
import '../fakes/fake_webview_adapter.dart';

void main() {
  group('FakeWebviewAdapter emit*', () {
    test('emitLoadStart produces an onLoadStart event', () async {
      final fake = FakeWebviewAdapter();
      final first = fake.onLoadStart.first;
      fake.emitLoadStart(Uri.parse('https://example.com'));
      expect(await first, equals(Uri.parse('https://example.com')));
      await fake.dispose();
    });

    test('emitLoadFinish produces an onLoadFinish event', () async {
      final fake = FakeWebviewAdapter();
      final first = fake.onLoadFinish.first;
      fake.emitLoadFinish(Uri.parse('https://example.com/done'));
      expect(await first, equals(Uri.parse('https://example.com/done')));
      await fake.dispose();
    });

    test('emitTitleChanged produces an onTitleChanged event', () async {
      final fake = FakeWebviewAdapter();
      final first = fake.onTitleChanged.first;
      fake.emitTitleChanged('Example');
      expect(await first, equals('Example'));
      await fake.dispose();
    });

    test('emitLoadError produces an onLoadError event', () async {
      final fake = FakeWebviewAdapter();
      final firstErr = fake.onLoadError.first;
      fake.emitLoadError(WebviewLoadError(
        url: Uri.parse('https://example.com'),
        code: -1,
        message: 'oops',
      ));
      final out = await firstErr;
      expect(out.url, equals(Uri.parse('https://example.com')));
      expect(out.code, equals(-1));
      expect(out.message, equals('oops'));
      await fake.dispose();
    });
  });

  group('FakeWebviewAdapter delegation recording', () {
    test('loadUrl appends to loadUrlCalls', () async {
      final fake = FakeWebviewAdapter();
      await fake.loadUrl(Uri.parse('https://a'));
      await fake.loadUrl(Uri.parse('https://b'));
      expect(fake.loadUrlCalls,
          equals([Uri.parse('https://a'), Uri.parse('https://b')]));
      await fake.dispose();
    });

    test('goBack/goForward/reload bump per-call counters', () async {
      final fake = FakeWebviewAdapter();
      await fake.goBack();
      await fake.goBack();
      await fake.goForward();
      await fake.reload();
      expect(fake.goBackCalls, equals(2));
      expect(fake.goForwardCalls, equals(1));
      expect(fake.reloadCalls, equals(1));
      await fake.dispose();
    });

    test('post-dispose mutators are no-ops', () async {
      final fake = FakeWebviewAdapter();
      await fake.dispose();
      await fake.loadUrl(Uri.parse('https://x'));
      await fake.goBack();
      expect(fake.loadUrlCalls, isEmpty);
      expect(fake.goBackCalls, equals(0));
      expect(fake.disposed, isTrue);
    });
  });
}
