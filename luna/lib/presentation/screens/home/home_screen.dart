import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/enums.dart';
import '../../../core/extensions/enums_l10n.dart';
import '../../../core/extensions/l10n.dart';
import '../../../core/utils/cycle_calculator.dart';
import '../../../data/providers.dart';
import '../../providers/cycle_provider.dart';
import '../../providers/estimator_provider.dart';
import '../../providers/insight_provider.dart';
import '../../providers/notification_provider.dart';
import '../../providers/user_provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/tips_provider.dart';
import '../../../data/services/widget_service.dart';
import '../../widgets/insight_card.dart';
import '../../widgets/lottie_phase_animation.dart';
import '../../widgets/log_bottom_sheet.dart';
import '../../widgets/start_cycle_sheet.dart';
import '../../widgets/update_bottom_sheet.dart';
import 'widgets/cycle_wheel.dart';
import 'widgets/prediction_card.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen>
    with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (!mounted) return;
      await _repairBrokenCycleEnd();
      checkAndShowUpdateSheet(context, ref);
      _requestNotificationPermissionIfNeeded();
      _scheduleNotifications();
      _syncIfAuthenticated();
      _updateWidget();
    });
  }

  /// Requests the OS notification permission once on first home screen load.
  /// No-op if permission was already granted or if the user has all
  /// notification types disabled. Called before [_scheduleNotifications] so
  /// login users (who bypass onboarding) also get the system prompt.
  Future<void> _requestNotificationPermissionIfNeeded() async {
    final user = ref.read(userStreamProvider).valueOrNull;
    if (user == null) return;
    if (!user.notificationsPeriod &&
        !user.notificationsOvulation &&
        !user.notificationsDailyCheckin) return;
    await ref.read(notificationServiceProvider).requestPermission();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  /// Reschedules notifications when the app returns to the foreground.
  /// Handles the case where the OS cancelled pending alarms due to battery
  /// optimisation, Doze mode, or a force-stop between sessions.
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _scheduleNotifications();
    }
  }

  /// Schedules notifications on app start / resume using current DB state.
  /// Also called via ref.listen below whenever the active cycle changes.
  void _scheduleNotifications() {
    final user = ref.read(userStreamProvider).valueOrNull;
    final cycle = ref.read(activeCycleProvider).valueOrNull;
    if (user == null) return;
    ref.read(notificationServiceProvider).scheduleAll(user, cycle);
  }

  void _syncIfAuthenticated() {
    ref.read(syncNotifierProvider.notifier).sync();
  }

  /// Repairs a database state left by the old endPeriod() bug, which
  /// incorrectly set endDate on the active cycle when the period ended.
  /// watchActiveCycle() queries WHERE endDate IS NULL, so it returned null
  /// and the home screen was blank. This finds that cycle and re-opens it.
  ///
  /// Safe to run on every launch — it's a no-op once the cycle is already open
  /// or once the next period has been logged (which creates a newer cycle).
  Future<void> _repairBrokenCycleEnd() async {
    final db = ref.read(databaseProvider);
    final cycles = await db.cycleDao.getAllCycles(); // newest-first
    if (cycles.isEmpty) return;

    final mostRecent = cycles.first;
    if (mostRecent.endDate == null) return; // already open, nothing to fix

    // If any cycle started AFTER mostRecent.endDate, a new period was logged
    // via start_new_cycle.dart which correctly set that endDate — leave it.
    final hasNewerCycle = cycles
        .skip(1)
        .any((c) => c.startDate.compareTo(mostRecent.endDate!) > 0);
    if (hasNewerCycle) return;

    await db.cycleDao.clearCycleEndDate(mostRecent.id);
  }

  Future<void> _updateWidget() async {
    final user = ref.read(userStreamProvider).valueOrNull;
    final cycle = ref.read(activeCycleProvider).valueOrNull;
    final phase = ref.read(currentPhaseProvider);
    final cycleLength = user?.avgCycleDays ?? 28;
    final cycleDay = cycle != null
        ? CycleCalculator.currentCycleDay(cycle.startDateTime) ?? 0
        : 0;
    final daysUntil = cycle != null
        ? CycleCalculator.daysUntilNextPeriod(
            cycle.startDateTime,
            cycleLength: cycleLength,
          )
        : 0;
    await WidgetService.update(
      phase: phase,
      cycleDay: cycleDay,
      daysUntilPeriod: daysUntil,
      hasCycle: cycle != null,
      cycleStartDate: cycle?.startDateTime,
      cycleLength: cycleLength,
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    // Reschedule notifications whenever the active cycle changes mid-session
    // (e.g. after user starts a new cycle from the Start Period sheet).
    ref.listen(activeCycleProvider, (_, _) {
      _scheduleNotifications();
      _updateWidget();
    });

    final user = ref.watch(userStreamProvider).valueOrNull;
    final cycle = ref.watch(activeCycleProvider).valueOrNull;
    final phase = ref.watch(currentPhaseProvider);
    final prediction = ref.watch(cyclePredictionProvider);
    final daysFromPredicted = ref.watch(daysFromPredictedStartProvider);

    final cycleDay = cycle != null
        ? CycleCalculator.currentCycleDay(cycle.startDateTime) ?? 0
        : 0;
    final cycleLength = user?.avgCycleDays ?? 28;
    final avgPeriodDays = user?.avgPeriodDays ?? 5;
    final greeting = _greeting(user?.displayName);
    final hasActiveCycle = cycle != null;
    final isPeriodActive = hasActiveCycle && phase == CyclePhase.menstrual;

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          // ── App bar ──────────────────────────────────────────────────────
          SliverAppBar(
            floating: true,
            backgroundColor: Colors.transparent,
            elevation: 0,
            title: Text(
              greeting,
              style: theme.textTheme.titleMedium?.copyWith(
                color: cs.onSurface,
              ),
            ),
            actions: [
              IconButton(
                icon: const Icon(Icons.settings_outlined),
                onPressed: () => context.push('/settings'),
                tooltip: 'Settings',
              ),
            ],
          ),

          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                children: [
                  const SizedBox(height: 8),

                  // ── Phase / status header ────────────────────────────────
                  if (hasActiveCycle) ...[
                    Text(
                      phase.localizedName(context.l10n),
                      style: theme.textTheme.headlineLarge?.copyWith(
                        color: cs.onSurface,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      phase.localizedCopy(context.l10n),
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: cs.onSurfaceVariant,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ] else ...[
                    Text(
                      context.l10n.homeTrackYourCycle,
                      style: theme.textTheme.headlineLarge?.copyWith(
                        color: cs.onSurface,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      context.l10n.homeStartTrackingSubtitle,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: cs.onSurfaceVariant,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],

                  const SizedBox(height: 16),

                  // ── Phase Lottie animation ───────────────────────────────
                  if (hasActiveCycle)
                    LottiePhaseAnimation(phase: phase, size: 100),

                  const SizedBox(height: 16),

                  // ── Cycle wheel ─────────────────────────────────────────
                  CycleWheel(
                    cycleDay: cycleDay,
                    cycleLength: cycleLength,
                    currentPhase: phase,
                  ),

                  const SizedBox(height: 28),

                  // ── Quick actions ───────────────────────────────────────
                  _QuickActions(hasActiveCycle: hasActiveCycle),

                  const SizedBox(height: 24),

                  // ── No-cycle CTA ─────────────────────────────────────────
                  if (!hasActiveCycle) ...[
                    _NoCycleCard(),
                    const SizedBox(height: 32),
                  ],

                  // ── Prediction + insight (active cycle only) ─────────────
                  if (hasActiveCycle) ...[
                    // Period-expected card only makes sense outside the menstrual
                    // phase — during an active period, daysFromPredicted can't
                    // logically be ≥ 0 anyway, but guard it explicitly.
                    if (!isPeriodActive && daysFromPredicted >= 0) ...[
                      _PeriodExpectedCard(daysLate: daysFromPredicted),
                      const SizedBox(height: 16),
                    ],
                    // During an active period → show day count + estimated end.
                    // All other phases → show next-period prediction.
                    if (isPeriodActive)
                      _PeriodInProgressCard(
                        periodDay: cycleDay,
                        cycleStart: cycle.startDateTime,
                        avgPeriodDays: avgPeriodDays,
                      )
                    else
                      PredictionCard(
                        prediction: prediction,
                        lastPeriodStart: cycle.startDateTime,
                      ),
                    const SizedBox(height: 24),
                    _PhaseInsightCard(phase: phase),
                    const SizedBox(height: 16),
                    _InsightPreview(),
                    const SizedBox(height: 32),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  static String _greeting(String? name) {
    final hour = DateTime.now().hour;
    final timeStr = hour < 12
        ? 'Good morning'
        : hour < 17
            ? 'Good afternoon'
            : 'Good evening';
    return name != null && name.isNotEmpty ? '$timeStr, $name' : timeStr;
  }
}

// ── Quick actions ──────────────────────────────────────────────────────────────

class _QuickActions extends ConsumerWidget {
  final bool hasActiveCycle;
  const _QuickActions({required this.hasActiveCycle});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cs = Theme.of(context).colorScheme;

    return Row(
      children: [
        _ActionChip(
          icon: Icons.water_drop_rounded,
          label: hasActiveCycle ? 'Log period' : 'Start period',
          color: cs.primaryContainer,
          onTap: () => hasActiveCycle
              ? showLogBottomSheet(context, initialTab: 0)
              : showStartCycleSheet(context),
        ),
        const SizedBox(width: 10),
        _ActionChip(
          icon: Icons.mood_rounded,
          label: 'Log mood',
          color: cs.secondaryContainer,
          onTap: () => showLogBottomSheet(context, initialTab: 2),
        ),
        const SizedBox(width: 10),
        _ActionChip(
          icon: Icons.lightbulb_outline_rounded,
          label: 'Tips',
          color: cs.tertiaryContainer,
          onTap: () => context.push('/tips'),
        ),
      ],
    );
  }
}

class _ActionChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _ActionChip({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 14),
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            children: [
              Icon(icon, size: 22),
              const SizedBox(height: 4),
              Text(label, style: theme.textTheme.labelSmall),
            ],
          ),
        ),
      ),
    );
  }
}

// ── No-cycle CTA card ──────────────────────────────────────────────────────────

class _NoCycleCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            cs.primaryContainer.withValues(alpha: 0.85),
            cs.secondaryContainer.withValues(alpha: 0.45),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: cs.primary.withValues(alpha: 0.2)),
      ),
      child: Column(
        children: [
          Icon(Icons.water_drop_outlined, color: cs.primary, size: 36),
          const SizedBox(height: 12),
          Text(
            context.l10n.homeCycleStartsHere,
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w700,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 6),
          Text(
            context.l10n.homeCycleStartsSubtitle,
            style: theme.textTheme.bodySmall?.copyWith(
              color: cs.onSurfaceVariant,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: FilledButton.icon(
              onPressed: () => showStartCycleSheet(context),
              icon: const Icon(Icons.water_drop_rounded, size: 18),
              label: Text(context.l10n.periodStartedToday),
            ),
          ),
          const SizedBox(height: 8),
          TextButton(
            onPressed: () => showStartCycleSheet(context),
            child: Text(
              context.l10n.homeStartedFewDaysAgo,
              style: theme.textTheme.labelSmall?.copyWith(
                color: cs.onSurfaceVariant,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Insight preview (2 compact cards, links to full Insights screen) ──────────

class _InsightPreview extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final insightsAsync = ref.watch(insightsProvider);

    return insightsAsync.when(
      loading: () => const SizedBox.shrink(),
      error: (_, _) => const SizedBox.shrink(),
      data: (insights) {
        if (insights.isEmpty) return const SizedBox.shrink();
        final preview = insights.take(2).toList();

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(
                  'Your patterns',
                  style: theme.textTheme.labelMedium?.copyWith(
                    color: cs.onSurfaceVariant,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const Spacer(),
                GestureDetector(
                  onTap: () => context.push('/insights'),
                  child: Text(
                    'See all →',
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: cs.primary,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            for (int i = 0; i < preview.length; i++) ...[
              InsightCard(insight: preview[i], compact: true),
              if (i < preview.length - 1) const SizedBox(height: 8),
            ],
          ],
        );
      },
    );
  }
}

// ── Period in progress card ────────────────────────────────────────────────────

class _PeriodInProgressCard extends StatelessWidget {
  final int periodDay;
  final DateTime cycleStart;
  final int avgPeriodDays;

  const _PeriodInProgressCard({
    required this.periodDay,
    required this.cycleStart,
    required this.avgPeriodDays,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    const rose = Color(0xFFE53E6A);

    final estimatedEnd = DateTime(
      cycleStart.year,
      cycleStart.month,
      cycleStart.day,
    ).add(Duration(days: avgPeriodDays - 1));

    final today = DateTime.now();
    final todayOnly = DateTime(today.year, today.month, today.day);
    final daysLeft = estimatedEnd.difference(todayOnly).inDays;

    final String endLabel;
    if (daysLeft <= 0) {
      endLabel = 'Ending around today';
    } else if (daysLeft == 1) {
      endLabel = 'Expected to end tomorrow';
    } else {
      endLabel = 'Expected to end in $daysLeft days';
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: BoxDecoration(
        color: rose.withValues(alpha: 0.07),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: rose.withValues(alpha: 0.25)),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Period in progress',
                  style: theme.textTheme.labelMedium?.copyWith(
                    color: rose.withValues(alpha: 0.9),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Day $periodDay',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Icon(Icons.schedule_rounded,
                        size: 12, color: cs.onSurfaceVariant),
                    const SizedBox(width: 4),
                    Text(
                      endLabel,
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: cs.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          GestureDetector(
            onTap: () => showLogBottomSheet(context, initialTab: 0),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: rose.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.water_drop_rounded, color: rose, size: 16),
                  const SizedBox(width: 6),
                  Text(
                    'Log flow',
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: rose,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Period expected / late card ────────────────────────────────────────────────

class _PeriodExpectedCard extends StatelessWidget {
  final int daysLate; // 0 = expected today, 1+ = days past predicted start

  const _PeriodExpectedCard({required this.daysLate});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    const rose = Color(0xFFE53E6A);

    final headline = daysLate == 0
        ? 'Period expected today'
        : 'Period is $daysLate day${daysLate == 1 ? '' : 's'} late';

    final subtitle = daysLate >= 7
        ? 'Cycles can vary. Stress, illness, or lifestyle changes can delay things. If this is unusual for you, consider speaking to a doctor.'
        : 'Did it start? Log it to keep your predictions accurate.';

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: rose.withValues(alpha: 0.07),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: rose.withValues(alpha: 0.25)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(7),
                decoration: BoxDecoration(
                  color: rose.withValues(alpha: 0.14),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.water_drop_outlined, color: rose, size: 16),
              ),
              const SizedBox(width: 10),
              Text(
                headline,
                style: theme.textTheme.titleSmall?.copyWith(
                  color: rose,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            subtitle,
            style: theme.textTheme.bodySmall?.copyWith(color: cs.onSurfaceVariant),
          ),
          const SizedBox(height: 14),
          SizedBox(
            width: double.infinity,
            child: FilledButton.icon(
              onPressed: () => showStartCycleSheet(context),
              icon: const Icon(Icons.water_drop_rounded, size: 18),
              label: Text(daysLate == 0 ? 'Period started today' : 'Log period start'),
              style: FilledButton.styleFrom(
                backgroundColor: rose,
                foregroundColor: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Phase insight card ─────────────────────────────────────────────────────────

class _PhaseInsightCard extends ConsumerWidget {
  final CyclePhase phase;
  const _PhaseInsightCard({required this.phase});

  static String _fallback(CyclePhase phase) => switch (phase) {
        CyclePhase.menstrual =>
          'Iron-rich foods like spinach and lentils can help restore energy during your period.',
        CyclePhase.follicular =>
          'Oestrogen is rising — a great time to take on new challenges and social activities.',
        CyclePhase.ovulation =>
          'Your communication skills are at their peak. Great time for important conversations.',
        CyclePhase.luteal =>
          'Magnesium-rich foods like dark chocolate and nuts can ease PMS symptoms.',
      };

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    final tipsAsync = ref.watch(phaseTipsProvider(phase));
    final tipText = tipsAsync.maybeWhen(
      data: (t) => t.current.text,
      orElse: () => _fallback(phase),
    );

    return GestureDetector(
      onTap: () => context.push('/tips'),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              cs.primaryContainer.withValues(alpha: 0.6),
              cs.secondaryContainer.withValues(alpha: 0.3),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(Icons.tips_and_updates_outlined,
                color: cs.primary, size: 20),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        context.l10n.homePhaseTip,
                        style: theme.textTheme.labelMedium?.copyWith(
                          color: cs.primary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const Spacer(),
                      Text(
                        context.l10n.homeSeeAll,
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: cs.primary.withValues(alpha: 0.7),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    tipText,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: cs.onSurface,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
