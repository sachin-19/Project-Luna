import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/providers.dart';

/// Corrects the end date of the most recently completed cycle.
///
/// Rules enforced:
///   • Only the most recently completed cycle may be edited.
///   • The edit window is [editWindowDays] days from the original end date.
///     After this window closes, the end date is locked.
///   • [newEndDate] must be ≤ today.
///   • [newEndDate] must be ≥ cycle startDate (a period must last at least 1 day).
///   • [newEndDate] must be < the next cycle's startDate (no overlap).
///
/// period_day_logs after [newEndDate] are deleted; [periodLength] is
/// recalculated from remaining rows. The Bayesian estimator is NOT updated —
/// it uses cycle length (start→start), which is unaffected by endDate changes.
class EditCycleEndDate {
  const EditCycleEndDate(this._ref);
  final Ref _ref;

  static const int editWindowDays = 7;

  Future<EditEndResult> execute(int cycleId, DateTime newEndDate) async {
    final repo = _ref.read(cycleRepositoryProvider);
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final newEnd =
        DateTime(newEndDate.year, newEndDate.month, newEndDate.day);

    // Load all cycles (newest-first) to find target + its successor.
    final cycles = await repo.getAllCycles();
    final targetIndex = cycles.indexWhere((c) => c.id == cycleId);

    if (targetIndex == -1) {
      return const EditEndFailure('Cycle not found.');
    }

    final target = cycles[targetIndex];

    if (target.endDate == null) {
      return const EditEndFailure(
        'Cycle is still active — use End Period instead.',
      );
    }

    // The cycle at targetIndex - 1 (lower index = newer) is the next cycle.
    final nextCycleStart = targetIndex > 0
        ? DateTime.parse(cycles[targetIndex - 1].startDate)
        : null;

    final result = validate(
      newEndDate: newEnd,
      today: today,
      cycleStart: target.startDateTime,
      originalEndDate: DateTime.parse(target.endDate!),
      nextCycleStart: nextCycleStart,
    );
    if (result is EditEndFailure) return result;

    await repo.updateCompletedCycleEnd(cycleId, _iso(newEnd));
    return const EditEndSuccess();
  }

  /// Pure validation — testable without a database.
  static EditEndResult validate({
    required DateTime newEndDate,
    required DateTime today,
    required DateTime cycleStart,
    required DateTime originalEndDate,
    DateTime? nextCycleStart,
    int editWindowDays = EditCycleEndDate.editWindowDays,
  }) {
    final newEnd =
        DateTime(newEndDate.year, newEndDate.month, newEndDate.day);
    final todayNorm = DateTime(today.year, today.month, today.day);
    final startNorm =
        DateTime(cycleStart.year, cycleStart.month, cycleStart.day);
    final origEnd = DateTime(
        originalEndDate.year, originalEndDate.month, originalEndDate.day);

    final windowClose = origEnd.add(Duration(days: editWindowDays));
    if (todayNorm.isAfter(windowClose)) {
      return const EditEndFailure(
        'The 7-day correction window has passed for this period.',
      );
    }

    if (newEnd.isAfter(todayNorm)) {
      return const EditEndFailure('End date cannot be in the future.');
    }

    if (newEnd.isBefore(startNorm)) {
      return const EditEndFailure(
        'End date cannot be before the period started.',
      );
    }

    if (nextCycleStart != null) {
      final nextStart = DateTime(
          nextCycleStart.year, nextCycleStart.month, nextCycleStart.day);
      if (!newEnd.isBefore(nextStart)) {
        return const EditEndFailure(
          'End date must be before the next period started.',
        );
      }
    }

    return const EditEndSuccess();
  }

  static String _iso(DateTime d) =>
      '${d.year.toString().padLeft(4, '0')}-'
      '${d.month.toString().padLeft(2, '0')}-'
      '${d.day.toString().padLeft(2, '0')}';
}

sealed class EditEndResult {
  const EditEndResult();
}

class EditEndSuccess extends EditEndResult {
  const EditEndSuccess();
}

class EditEndFailure extends EditEndResult {
  final String reason;
  const EditEndFailure(this.reason);
}

final editCycleEndDateProvider = Provider<EditCycleEndDate>(
  (ref) => EditCycleEndDate(ref),
);
