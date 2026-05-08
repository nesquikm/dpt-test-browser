// AC-STE-254.1: BrowserTab Freezed equality + copyWith roundtrip.
import 'package:flutter_test/flutter_test.dart';
import 'package:dpt_test_browser/tabs/tab.dart';

void main() {
  group('BrowserTab', () {
    test('two instances with identical fields are == equal', () {
      final url = Uri.parse('https://example.com');
      final a = BrowserTab(id: 'tab-1', url: url);
      final b = BrowserTab(id: 'tab-1', url: url);

      expect(a, equals(b));
    });

    test('default isLoading is false', () {
      final tab = BrowserTab(id: 'tab-1', url: Uri.parse('https://example.com'));

      expect(tab.isLoading, isFalse);
    });

    test('default title is null', () {
      final tab = BrowserTab(id: 'tab-1', url: Uri.parse('https://example.com'));

      expect(tab.title, isNull);
    });

    test('instances with different ids are not equal', () {
      final url = Uri.parse('https://example.com');
      final a = BrowserTab(id: 'tab-1', url: url);
      final b = BrowserTab(id: 'tab-2', url: url);

      expect(a, isNot(equals(b)));
    });

    test('copyWith roundtrip preserves unchanged fields', () {
      final url = Uri.parse('https://example.com');
      final original = BrowserTab(id: 'tab-1', url: url, title: 'Example', isLoading: true);
      final copy = original.copyWith();

      expect(copy, equals(original));
    });

    test('copyWith updates url', () {
      final original = BrowserTab(id: 'tab-1', url: Uri.parse('https://example.com'));
      final newUrl = Uri.parse('https://flutter.dev');
      final updated = original.copyWith(url: newUrl);

      expect(updated.url, equals(newUrl));
      expect(updated.id, equals('tab-1'));
    });

    test('copyWith updates isLoading', () {
      final original = BrowserTab(id: 'tab-1', url: Uri.parse('https://example.com'));
      final updated = original.copyWith(isLoading: true);

      expect(updated.isLoading, isTrue);
      expect(updated.id, equals('tab-1'));
      expect(updated.url, equals(original.url));
    });

    test('copyWith updates title', () {
      final original = BrowserTab(id: 'tab-1', url: Uri.parse('https://example.com'));
      final updated = original.copyWith(title: 'Flutter');

      expect(updated.title, equals('Flutter'));
    });
  });
}
