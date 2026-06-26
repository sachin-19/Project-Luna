import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:luna/l10n/app_localizations.dart';
import 'package:luna/presentation/onboarding/onboarding_notifier.dart';
import 'package:luna/presentation/screens/onboarding/onboarding_identity_screen.dart';
import 'package:luna/presentation/screens/onboarding/onboarding_cycle_basics_screen.dart';
import 'package:luna/presentation/screens/onboarding/widgets/onboarding_scaffold.dart';

// ── Helpers ───────────────────────────────────────────────────────────────────

/// Wraps [screen] in ProviderScope + MaterialApp + localization so widgets
/// that depend on Theme, GoRouter, or Riverpod can render without crashing.
Widget _wrap(Widget screen, {GoRouter? router}) {
  final r = router ??
      GoRouter(
        initialLocation: '/onboarding/identity',
        routes: [
          GoRoute(
            path: '/onboarding/identity',
            builder: (_, __) => const OnboardingIdentityScreen(),
          ),
          GoRoute(
            path: '/onboarding/cycle-basics',
            builder: (_, __) => const OnboardingCycleBasicsScreen(),
          ),
        ],
      );
  return ProviderScope(
    child: MaterialApp.router(
      routerConfig: r,
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [Locale('en'), Locale('hi')],
    ),
  );
}

// ── OnboardingNotifier unit tests ─────────────────────────────────────────────

void main() {
  group('OnboardingNotifier', () {
    late ProviderContainer container;

    setUp(() {
      container = ProviderContainer();
    });

    tearDown(() {
      container.dispose();
    });

    test('starts with empty defaults', () {
      final data = container.read(onboardingProvider);
      expect(data.name, '');
      expect(data.birthYear, 1998);
      expect(data.periodDays, 5);
      expect(data.cycleDays, 28);
      expect(data.cycleLengthUnknown, isFalse);
      expect(data.hasPcos, isFalse);
      expect(data.hasEndo, isFalse);
      expect(data.notifPeriod, isTrue);
    });

    test('setName updates name', () {
      container.read(onboardingProvider.notifier).setName('Priya');
      expect(container.read(onboardingProvider).name, 'Priya');
    });

    test('setBirthYear updates birth year', () {
      container.read(onboardingProvider.notifier).setBirthYear(2000);
      expect(container.read(onboardingProvider).birthYear, 2000);
    });

    test('setPeriodDays and setCycleDays update cycle parameters', () {
      final notifier = container.read(onboardingProvider.notifier);
      notifier.setPeriodDays(7);
      notifier.setCycleDays(32);
      final data = container.read(onboardingProvider);
      expect(data.periodDays, 7);
      expect(data.cycleDays, 32);
    });

    test('setCycleLengthUnknown toggles the flag', () {
      container.read(onboardingProvider.notifier).setCycleLengthUnknown(true);
      expect(container.read(onboardingProvider).cycleLengthUnknown, isTrue);
    });

    test('setHasPcos / setHasEndo update flags independently', () {
      final notifier = container.read(onboardingProvider.notifier);
      notifier.setHasPcos(true);
      expect(container.read(onboardingProvider).hasPcos, isTrue);
      expect(container.read(onboardingProvider).hasEndo, isFalse);
      notifier.setHasEndo(true);
      expect(container.read(onboardingProvider).hasEndo, isTrue);
    });

    test('setLastPeriodStart stores date without time component issues', () {
      final date = DateTime(2024, 6, 15);
      container.read(onboardingProvider.notifier).setLastPeriodStart(date);
      expect(container.read(onboardingProvider).lastPeriodStart, date);
    });

    test('setPastPeriods stores list correctly', () {
      final periods = [DateTime(2024, 5, 1), DateTime(2024, 4, 3)];
      container.read(onboardingProvider.notifier).setPastPeriods(periods);
      expect(container.read(onboardingProvider).pastPeriods, periods);
    });

    test('multiple copyWith calls compose correctly (no state leakage)', () {
      final notifier = container.read(onboardingProvider.notifier);
      notifier.setName('Anjali');
      notifier.setBirthYear(1995);
      notifier.setPeriodDays(6);
      final data = container.read(onboardingProvider);
      expect(data.name, 'Anjali');
      expect(data.birthYear, 1995);
      expect(data.periodDays, 6);
      expect(data.cycleDays, 28); // untouched — should keep default
    });

    test('notification flags can be toggled independently', () {
      final notifier = container.read(onboardingProvider.notifier);
      notifier.setNotifPeriod(false);
      notifier.setNotifOvulation(false);
      final data = container.read(onboardingProvider);
      expect(data.notifPeriod, isFalse);
      expect(data.notifOvulation, isFalse);
      expect(data.notifCheckin, isTrue); // untouched
    });
  });

  // ── Widget smoke tests ──────────────────────────────────────────────────────

  group('OnboardingScaffold', () {
    testWidgets('renders title and progress bar', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            localizationsDelegates: const [
              AppLocalizations.delegate,
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            supportedLocales: const [Locale('en')],
            home: const OnboardingScaffold(
              stepIndex: 0,
              totalSteps: 8,
              title: 'Test title',
              body: SizedBox.shrink(),
            ),
          ),
        ),
      );
      await tester.pump();

      expect(find.text('Test title'), findsOneWidget);
      expect(find.byType(LinearProgressIndicator), findsOneWidget);
    });

    testWidgets('back button hidden on first step when showBack is false',
        (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            localizationsDelegates: const [
              AppLocalizations.delegate,
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            supportedLocales: const [Locale('en')],
            home: const OnboardingScaffold(
              stepIndex: 0,
              title: 'No back',
              showBack: false,
              body: SizedBox.shrink(),
            ),
          ),
        ),
      );
      await tester.pump();

      expect(
        find.byIcon(Icons.arrow_back_ios_new_rounded),
        findsNothing,
      );
    });
  });

  group('OnboardingIdentityScreen', () {
    testWidgets('renders name field and birth year picker', (tester) async {
      await tester.pumpWidget(_wrap(const OnboardingIdentityScreen()));
      await tester.pumpAndSettle();

      // Name text field should be present
      expect(find.byType(TextField), findsAtLeastNWidgets(1));
    });

    testWidgets('Continue button (FilledButton) disabled until name is entered',
        (tester) async {
      await tester.pumpWidget(_wrap(const OnboardingIdentityScreen()));
      await tester.pumpAndSettle();

      // The identity screen uses FilledButton with onPressed = null when name is empty.
      bool foundDisabled = false;
      for (final element in find.byType(FilledButton).evaluate()) {
        final widget = element.widget as FilledButton;
        if (widget.onPressed == null) {
          foundDisabled = true;
          break;
        }
      }
      expect(foundDisabled, isTrue,
          reason: 'Continue button should be disabled when name is empty');

      // Type a name
      await tester.enterText(find.byType(TextField).first, 'Meera');
      await tester.pump();

      // Now the button should be enabled
      bool foundEnabled = false;
      for (final element in find.byType(FilledButton).evaluate()) {
        final widget = element.widget as FilledButton;
        if (widget.onPressed != null) {
          foundEnabled = true;
          break;
        }
      }
      expect(foundEnabled, isTrue,
          reason: 'Continue button should enable after entering name');
    });

    testWidgets('navigates to cycle-basics after tapping Continue',
        (tester) async {
      String? lastRoute;
      final router = GoRouter(
        initialLocation: '/onboarding/identity',
        routes: [
          GoRoute(
            path: '/onboarding/identity',
            builder: (_, __) => const OnboardingIdentityScreen(),
          ),
          GoRoute(
            path: '/onboarding/cycle-basics',
            builder: (_, __) {
              lastRoute = '/onboarding/cycle-basics';
              return const Scaffold(body: Text('Cycle basics'));
            },
          ),
        ],
      );

      await tester.pumpWidget(_wrap(const OnboardingIdentityScreen(), router: router));
      await tester.pumpAndSettle();

      // Enter a name to enable the Continue button
      await tester.enterText(find.byType(TextField).first, 'Meera');
      await tester.pump();

      // Tap the enabled FilledButton
      final enabledButton = find.byWidgetPredicate(
        (w) => w is FilledButton && w.onPressed != null,
      );
      expect(enabledButton, findsAtLeastNWidgets(1));
      await tester.tap(enabledButton.first);
      await tester.pumpAndSettle();

      expect(lastRoute, '/onboarding/cycle-basics');
    });
  });
}
