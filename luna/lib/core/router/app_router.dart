import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../domain/entities/user.dart';
import '../../presentation/providers/user_provider.dart';
import '../../presentation/screens/calendar/calendar_screen.dart';
import '../../presentation/screens/home/home_screen.dart';
import '../../presentation/screens/insights/insights_screen.dart';
import '../../presentation/screens/learn/article_detail_screen.dart';
import '../../presentation/screens/learn/learn_screen.dart';
import '../../presentation/screens/onboarding/onboarding_identity_screen.dart';
import '../../presentation/screens/onboarding/onboarding_cycle_basics_screen.dart';
import '../../presentation/screens/onboarding/onboarding_history_screen.dart';
import '../../presentation/screens/onboarding/onboarding_regularity_screen.dart';
import '../../presentation/screens/onboarding/onboarding_reason_screen.dart';
import '../../presentation/screens/onboarding/onboarding_symptoms_screen.dart';
import '../../presentation/screens/onboarding/onboarding_lifestyle_screen.dart';
import '../../presentation/screens/onboarding/onboarding_notifications_screen.dart';
import '../../presentation/screens/auth/sign_up_screen.dart';
import '../../presentation/screens/settings/settings_screen.dart';
import '../../presentation/screens/tips/tips_screen.dart';
import '../../presentation/screens/welcome/welcome_screen.dart';
import '../../presentation/widgets/app_shell.dart';

// Bridges Riverpod user stream → GoRouter refresh so the redirect re-runs
// whenever the user's onboarded state changes (e.g. on app restart with saved data).
class _RouterNotifier extends ChangeNotifier {
  _RouterNotifier(Ref ref) {
    ref.listen<AsyncValue<User?>>(userStreamProvider, (_, _) {
      notifyListeners();
    });
  }
}

GoRouter buildRouter(Ref ref) {
  return GoRouter(
    initialLocation: '/',
    debugLogDiagnostics: false,
    refreshListenable: _RouterNotifier(ref),
    redirect: (context, state) {
      final userAsync = ref.read(userStreamProvider);
      return userAsync.when(
        data: (user) {
          final isOnboarded = user?.onboarded ?? false;
          final path = state.uri.path;
          final isWelcome = path == '/';
          final isOnboarding = path.startsWith('/onboarding');
          final isAuth = path.startsWith('/auth');

          // Auth screens (/auth/*) are always accessible — before and after onboarding.
          if (isAuth) return null;
          // Not yet onboarded: allow welcome + onboarding; redirect anything else to welcome.
          if (!isOnboarded && !isWelcome && !isOnboarding) return '/';
          // Already onboarded: skip welcome and onboarding, go straight to home.
          if (isOnboarded && (isWelcome || isOnboarding)) return '/home';
          return null;
        },
        loading: () => null,
        error: (_, _) => null,
      );
    },
    routes: [
      // ── Welcome ──────────────────────────────────────────────────────────
      GoRoute(
        path: '/',
        builder: (_, _) => const WelcomeScreen(),
      ),

      // ── Onboarding ───────────────────────────────────────────────────────
      GoRoute(
        path: '/onboarding/identity',
        builder: (context, state) => const OnboardingIdentityScreen(),
      ),
      GoRoute(
        path: '/onboarding/cycle-basics',
        builder: (context, state) => const OnboardingCycleBasicsScreen(),
      ),
      GoRoute(
        path: '/onboarding/history',
        builder: (context, state) => const OnboardingHistoryScreen(),
      ),
      GoRoute(
        path: '/onboarding/regularity',
        builder: (context, state) => const OnboardingRegularityScreen(),
      ),
      GoRoute(
        path: '/onboarding/reason',
        builder: (context, state) => const OnboardingReasonScreen(),
      ),
      GoRoute(
        path: '/onboarding/symptoms',
        builder: (context, state) => const OnboardingSymptomsScreen(),
      ),
      GoRoute(
        path: '/onboarding/lifestyle',
        builder: (context, state) => const OnboardingLifestyleScreen(),
      ),
      GoRoute(
        path: '/onboarding/notifications',
        builder: (context, state) => const OnboardingNotificationsScreen(),
      ),

      // ── Auth ─────────────────────────────────────────────────────────────
      GoRoute(
        path: '/auth/signup',
        builder: (_, _) => const SignUpScreen(),
      ),
      GoRoute(
        path: '/auth/signin',
        builder: (_, _) => const SignInScreen(),
      ),

      // ── Settings (outside shell — no bottom nav) ──────────────────────────
      GoRoute(
        path: '/settings',
        builder: (_, _) => const SettingsScreen(),
      ),

      // ── Article detail (outside shell — full-screen read) ─────────────────
      GoRoute(
        path: '/learn/article/:id',
        builder: (_, state) => ArticleDetailScreen(
          articleId: state.pathParameters['id'] ?? '',
        ),
      ),

      // ── Tips screen (outside shell — no bottom nav) ───────────────────────
      GoRoute(
        path: '/tips',
        builder: (_, _) => const TipsScreen(),
      ),

      // ── Main app — shell provides bottom nav + FAB ────────────────────────
      ShellRoute(
        builder: (context, state, child) => AppShell(child: child),
        routes: [
          GoRoute(
            path: '/home',
            builder: (_, _) => const HomeScreen(),
          ),
          GoRoute(
            path: '/calendar',
            builder: (_, _) => const CalendarScreen(),
          ),
          GoRoute(
            path: '/insights',
            builder: (_, _) => const InsightsScreen(),
          ),
          GoRoute(
            path: '/learn',
            builder: (_, _) => const LearnScreen(),
          ),
        ],
      ),
    ],
  );
}

// Provider so LunaApp can watch user state and get router rebuilds.
final routerProvider = Provider<GoRouter>((ref) => buildRouter(ref));
