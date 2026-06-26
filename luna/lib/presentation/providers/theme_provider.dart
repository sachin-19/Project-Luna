import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';

const _boxKey = 'settings';
const _brightnessKey = 'brightness';

final themeModeProvider = StateNotifierProvider<ThemeModeNotifier, ThemeMode>(
  (ref) => ThemeModeNotifier(),
);

class ThemeModeNotifier extends StateNotifier<ThemeMode> {
  ThemeModeNotifier() : super(_load());

  static ThemeMode _load() {
    final box = Hive.box<dynamic>(_boxKey);
    final stored = box.get(_brightnessKey, defaultValue: 'light') as String;
    return switch (stored) {
      'light' => ThemeMode.light,
      'system' => ThemeMode.system,
      _ => ThemeMode.dark,
    };
  }

  Future<void> toggle() async {
    final next = state == ThemeMode.dark ? ThemeMode.light : ThemeMode.dark;
    state = next;
    final box = Hive.box<dynamic>(_boxKey);
    await box.put(_brightnessKey, next == ThemeMode.light ? 'light' : 'dark');
  }

  Future<void> set(ThemeMode mode) async {
    state = mode;
    final box = Hive.box<dynamic>(_boxKey);
    await box.put(
      _brightnessKey,
      switch (mode) {
        ThemeMode.light => 'light',
        ThemeMode.system => 'system',
        ThemeMode.dark => 'dark',
      },
    );
  }
}
