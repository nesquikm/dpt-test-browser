// AC-STE-257.4: parseAddressBarInput behaviour.

import 'package:flutter_test/flutter_test.dart';

import 'package:dpt_test_browser/shared/url.dart';

void main() {
  group('parseAddressBarInput', () {
    test('full URL with scheme parses unchanged', () {
      expect(
        parseAddressBarInput('https://flutter.dev/docs'),
        equals(Uri.parse('https://flutter.dev/docs')),
      );
    });

    test('bare host prepends https://', () {
      expect(
        parseAddressBarInput('example.com'),
        equals(Uri.parse('https://example.com')),
      );
    });

    test('host-with-path prepends https://', () {
      expect(
        parseAddressBarInput('example.com/path?q=1'),
        equals(Uri.parse('https://example.com/path?q=1')),
      );
    });

    test('http (non-https) scheme is preserved', () {
      expect(
        parseAddressBarInput('http://example.com'),
        equals(Uri.parse('http://example.com')),
      );
    });

    test('leading/trailing whitespace is trimmed', () {
      expect(
        parseAddressBarInput('   example.com   '),
        equals(Uri.parse('https://example.com')),
      );
    });

    test('empty input returns null', () {
      expect(parseAddressBarInput(''), isNull);
    });

    test('whitespace-only input returns null', () {
      expect(parseAddressBarInput('   '), isNull);
    });

    test('garbage with spaces (not a host) returns null', () {
      expect(parseAddressBarInput('not a url'), isNull);
    });

    test('about:blank-style scheme is preserved', () {
      // about: scheme has empty authority; we accept it as a valid Uri.
      // (Caller may still reject it for UX reasons; helper just parses.)
      expect(
        parseAddressBarInput('about:blank'),
        equals(Uri.parse('about:blank')),
      );
    });
  });
}
