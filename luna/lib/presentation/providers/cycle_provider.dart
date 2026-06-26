import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/providers.dart';
import '../../domain/entities/cycle_entry.dart';
import '../../core/constants/enums.dart';
import '../../core/utils/cycle_calculator.dart';
import 'user_provider.dart';

/// The most recently completed cycle (endDate IS NOT NULL), or null if none.
/// Auto-disposed; invalidate after editing a completed cycle's end date to
/// force a fresh load.
final lastCompletedCycleProvider = FutureProvider.autoDispose<CycleEntry?>((ref) async {
  final cycles = await ref.read(cycleRepositoryProvider).getLastNCycles(1);
  return cycles.isNotEmpty ? cycles.first : null;
});

final activeCycleProvider = StreamProvider<CycleEntry?>((ref) {
  return ref.watch(cycleRepositoryProvider).watchActiveCycle();
});

/// Derives the current cycle phase from the active cycle's start date.
/// Uses the user's personal average cycle length for accurate phase boundaries.
/// Returns [CyclePhase.menstrual] as the default when no active cycle exists.
///
/// Caps the cycle day at [cycleLength] so that overdue cycles (where the
/// predicted period start has passed but hasn't been logged yet) remain in
/// the luteal phase rather than wrapping back to menstrual.
final currentPhaseProvider = Provider<CyclePhase>((ref) {
  final cycleAsync = ref.watch(activeCycleProvider);
  final user = ref.watch(userStreamProvider).valueOrNull;
  final cycleLength = user?.avgCycleDays ?? 28;

  return cycleAsync.when(
    data: (cycle) {
      if (cycle == null) return CyclePhase.menstrual;
      final raw = CycleCalculator.currentCycleDay(cycle.startDateTime) ?? 1;
      // Cap at cycleLength: overdue days stay in luteal, not wrap to menstrual.
      final day = raw.clamp(1, cycleLength);
      return CycleCalculator.phaseForDay(day, cycleLength: cycleLength);
    },
    loading: () => CyclePhase.menstrual,
    error: (_, _) => CyclePhase.menstrual,
  );
});

/// Days since the predicted period start for the current cycle.
///   >= 0 → period is expected or late (show the period-expected card)
///   < 0  → period not yet due
final daysFromPredictedStartProvider = Provider<int>((ref) {
  final cycleAsync = ref.watch(activeCycleProvider);
  final user = ref.watch(userStreamProvider).valueOrNull;
  final cycleLength = user?.avgCycleDays ?? 28;

  return cycleAsync.when(
    data: (cycle) {
      if (cycle == null) return -1;
      return CycleCalculator.daysFromPredictedStart(
        cycle.startDateTime,
        cycleLength: cycleLength,
      );
    },
    loading: () => -1,
    error: (_, _) => -1,
  );
});
