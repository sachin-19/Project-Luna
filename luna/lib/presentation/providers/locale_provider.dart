import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';

const _boxKey = 'settings';
const _localeKey = 'locale';

/// null means "follow device locale" (system default).
final localeModeProvider = StateNotifierProvider<LocaleModeNotifier, Locale?>(
  (ref) => LocaleModeNotifier(),
);

class LocaleModeNotifier extends StateNotifier<Locale?> {
  LocaleModeNotifier() : super(_load());

  static Locale? _load() {
    final box = Hive.box<dynamic>(_boxKey);
    final stored = box.get(_localeKey, defaultValue: 'system') as String;
    return localeFromCode(stored);
  }

  Future<void> set(Locale? locale) async {
    state = locale;
    final box = Hive.box<dynamic>(_boxKey);
    await box.put(_localeKey, locale == null ? 'system' : locale.languageCode);
  }
}

/// Converts a stored language code string to a [Locale].
/// Returns null for 'system' or any unrecognised value → follows device locale.
Locale? localeFromCode(String code) => switch (code) {
      'en' => const Locale('en'),
      'hi' => const Locale('hi'),
      _ => null,
    };
