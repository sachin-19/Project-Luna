import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:luna/presentation/providers/locale_provider.dart';

void main() {
  group('localeFromCode', () {
    test('"en" returns English locale', () {
      expect(localeFromCode('en'), const Locale('en'));
    });

    test('"hi" returns Hindi locale', () {
      expect(localeFromCode('hi'), const Locale('hi'));
    });

    test('"system" returns null (follow device)', () {
      expect(localeFromCode('system'), isNull);
    });

    test('unknown code returns null (fallback to system)', () {
      expect(localeFromCode('fr'), isNull);
      expect(localeFromCode(''), isNull);
      expect(localeFromCode('auto'), isNull);
    });

    test('returned Locale has correct language code', () {
      expect(localeFromCode('en')!.languageCode, 'en');
      expect(localeFromCode('hi')!.languageCode, 'hi');
    });

    test('round-trips: code → Locale → languageCode → Locale', () {
      for (final code in ['en', 'hi']) {
        final locale = localeFromCode(code)!;
        final restored = localeFromCode(locale.languageCode);
        expect(restored, locale);
      }
    });
  });
}
