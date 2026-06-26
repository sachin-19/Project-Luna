import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/constants/enums.dart';
import '../../data/providers.dart';
import '../../domain/entities/user.dart';
import '../../presentation/onboarding/onboarding_notifier.dart';
import '../../presentation/providers/estimator_provider.dart';

/// Atomically saves all onboarding data to the DB on Screen 8 completion.
///
/// For each period entered (current + seeded history):
///   - Creates a cycle_entries row with proper startDate, endDate, periodLength,
///     and cycleLength (gap to the next cycle start).
///   - Creates period_day_logs for every day of that period (flow = medium),
///     up to today for the current period if it is still active.
///   - Feeds completed cycle lengths to the Bayesian estimator so predictions
///     are immediately calibrated from the user's own history.
class SaveOnboarding {
  final Ref _ref;

  SaveOnboarding(this._ref);

  Future<void> execute(OnboardingData data) async {
    final userRepo = _ref.read(userRepositoryProvider);
    final cycleRepo = _ref.read(cycleRepositoryProvider);
    final estimator = _ref.read(cycleEstimatorServiceProvider);

    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    // ── 1. Save user row ────────────────────────────────────────────────────
    await userRepo.saveUser(User(
      id: 0,
      displayName: data.name.trim(),
      birthYear: data.birthYear,
      avgCycleDays: data.cycleLengthUnknown ? 28 : data.cycleDays,
      avgPeriodDays: data.periodDays,
      cycleLengthKnown: !data.cycleLengthUnknown,
      onHormonalContraception: data.onHormonalContraception,
      hasPcos: data.hasPcos,
      hasEndo: data.hasEndo,
      trackingGoals: data.trackingGoals,
      commonSymptoms: data.commonSymptoms,
      baselineStress: data.baselineStress,
      exerciseFrequency: data.exerciseFrequency,
      notificationsPeriod: data.notifPeriod,
      notificationsOvulation: data.notifOvulation,
      notificationsDailyCheckin: data.notifCheckin,
      onboarded: true,
      reproductiveStatus: data.reproductiveStatus,
      heightCm: data.heightCm,
      weightKg: data.weightKg,
      createdAt: now.millisecondsSinceEpoch,
    ));

    // ── 2. Initialise estimator prior before any observations ────────────────
    // Priority: PCOS > postpartum > breastfeeding > perimenopause > BMI > default.
    // PCOS is a permanent condition and always takes precedence.
    if (data.hasPcos) {
      await estimator.initPcos();
    } else {
      switch (data.reproductiveStatus) {
        case ReproductiveStatus.postpartum:
          await estimator.initPostpartum();
        case ReproductiveStatus.breastfeeding:
          await estimator.initBreastfeeding();
        case ReproductiveStatus.perimenopause:
          await estimator.initPerimenopause();
        case ReproductiveStatus.pregnant:
          // Predictions are irrelevant during pregnancy; keep default prior.
          break;
        case ReproductiveStatus.normal:
        case ReproductiveStatus.tryingToConceive:
          // Apply BMI-adjusted prior if height + weight were provided.
          if (data.heightCm != null && data.weightKg != null) {
            await estimator.applyBmiPrior(data.heightCm!, data.weightKg!);
          }
      }
    }

    // ── 3. Build sorted list of all period entries (oldest first) ────────────
    final entries = <_Entry>[];

    // Seeded historical periods from Screen 3.
    for (int i = 0; i < data.pastPeriods.length; i++) {
      entries.add(_Entry(
        start: data.pastPeriods[i],
        duration: i < data.pastPeriodDurations.length
            ? data.pastPeriodDurations[i]
            : data.periodDays,
        isSeeded: true,
      ));
    }

    // Current period from Screen 2.
    final currentStart = data.lastPeriodStart ?? today;
    entries.add(_Entry(
      start: currentStart,
      duration: data.periodDays,
      isSeeded: false,
    ));

    // Sort chronological, oldest first.
    entries.sort((a, b) => a.start.compareTo(b.start));

    // Clamp each entry's duration so it doesn't overlap the next cycle's start.
    // e.g. 8-day duration but next period starts in 5 days → clamp to 5.
    for (int i = 0; i < entries.length - 1; i++) {
      final gap = entries[i + 1].start.difference(entries[i].start).inDays;
      if (entries[i].duration > gap) {
        entries[i] = _Entry(
          start: entries[i].start,
          duration: gap,
          isSeeded: entries[i].isSeeded,
        );
      }
    }

    // ── 4. Insert each cycle + its period day logs ────────────────────────────
    for (int i = 0; i < entries.length; i++) {
      final e = entries[i];
      final isLast = i == entries.length - 1;

      final endDateRaw = e.start.add(Duration(days: e.duration - 1));
      // Cap the end date at today — we can't log future days.
      final effectiveEnd =
          endDateRaw.isAfter(today) ? today : endDateRaw;
      // Still active if this is the last entry and the period hasn't finished yet.
      final isActive = isLast && endDateRaw.isAfter(today);

      // Cycle length = gap to the next cycle's start (null for the last entry
      // since we don't yet know when the next period will begin).
      final int? cycleLen = i + 1 < entries.length
          ? entries[i + 1].start.difference(e.start).inDays
          : null;

      // Insert cycle_entries row.
      final int cycleId;
      if (isActive) {
        // Open cycle — no endDate yet.
        cycleId = await cycleRepo.startCycle(_iso(e.start), isSeeded: false);
      } else {
        cycleId = await cycleRepo.insertSeededCycle(
          startDate: _iso(e.start),
          endDate: _iso(effectiveEnd),
          periodLength: e.duration,
          cycleLength: cycleLen,
        );
        // Feed this cycle length to the Bayesian estimator so first-open
        // predictions use real personal history, not just the population prior.
        if (cycleLen != null && cycleLen > 0) {
          await estimator.observe(cycleLen.toDouble());
        }
      }

      // Insert period_day_logs for every day of this period.
      // For active periods this covers start → today (remaining days logged live).
      // Flow defaults to 'medium' — actual flow for past periods is unknown.
      final daysToLog = effectiveEnd.difference(e.start).inDays + 1;
      for (int d = 0; d < daysToLog; d++) {
        final dayDate = e.start.add(Duration(days: d));
        await cycleRepo.logPeriodDay(cycleId, _iso(dayDate), 'medium');
      }
    }
  }

  static String _iso(DateTime d) =>
      '${d.year.toString().padLeft(4, '0')}-'
      '${d.month.toString().padLeft(2, '0')}-'
      '${d.day.toString().padLeft(2, '0')}';
}

final saveOnboardingProvider = Provider<SaveOnboarding>(
  (ref) => SaveOnboarding(ref),
);

// ── Internal ──────────────────────────────────────────────────────────────────

class _Entry {
  final DateTime start;
  final int duration;
  final bool isSeeded;
  const _Entry({required this.start, required this.duration, required this.isSeeded});
}
