import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'core/router/app_router.dart';
import 'core/theme/app_theme.dart';
import 'core/theme/theme_switcher.dart';
import 'l10n/app_localizations.dart';
import 'presentation/providers/theme_provider.dart';
import 'presentation/providers/cycle_provider.dart';


class LunaApp extends ConsumerWidget {
  const LunaApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeModeProvider);
    final phase = ref.watch(currentPhaseProvider);

    final router = ref.watch(routerProvider);

    // AnimatedTheme must live inside MaterialApp.router's builder so it can
    // read the theme MaterialApp has already resolved (light/dark + phase seed).
    // Wrapping MaterialApp.router itself has no effect — it establishes its own
    // internal Theme widget before the outer AnimatedTheme can intercept it.
    return MaterialApp.router(
      title: 'Luna',
      debugShowCheckedModeBanner: false,
      routerConfig: router,
      theme: buildTheme(phase, Brightness.light),
      darkTheme: buildTheme(phase, Brightness.dark),
      themeMode: themeMode,
      // RepaintBoundary lets theme_switcher capture the current frame
      // before a theme change so the circular reveal overlay can show it.
      // AnimatedTheme is removed — the reveal animation handles the visual.
      builder: (context, child) => RepaintBoundary(
        key: themeSwitcherKey,
        child: child!,
      ),
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
    );
  }
}
