import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/providers.dart';

/// Corrects the start date of the currently active (open) cycle.
///
/// Rules enforced:
///   • [newStartDate] must be ≤ today.
///   • [newStartDate] must be within [maxDaysBack] days of today.
///   • [newStartDate] must be strictly after the previous completed cycle's
///     end date (no overlapping cycles).
///
/// Any period_day_logs before [newStartDate] are deleted — they now fall
/// outside the corrected cycle window. Logs on or after [newStartDate] are
/// kept. The Bayesian estimator is NOT touched because it only updates when
/// a cycle closes.
class EditCycleStartDate {
  const EditCycleStartDate(this._ref);
  final Ref _ref;

  static const int maxDaysBack = 30;

  Future<EditStartResult> execute(int cycleId, DateTime newStartDate) async {
    final repo = _ref.read(cycleRepositoryProvider);
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final newStart =
        DateTime(newStartDate.year, newStartDate.month, newStartDate.day);

    final previous = await repo.getLastNCycles(1);
    final previousEnd = previous.isNotEmpty && previous.first.endDate != null
        ? DateTime.parse(previous.first.endDate!)
        : null;

    final result = validate(
      newStartDate: newStart,
      today: today,
      previousCycleEndDate: previousEnd,
    );
    if (result is EditStartFailure) return result;

    await repo.updateActiveCycleStart(cycleId, _iso(newStart));
    return const EditStartSuccess();
  }

  /// Pure validation — testable without a database.
  static EditStartResult validate({
    required DateTime newStartDate,
    required DateTime today,
    DateTime? previousCycleEndDate,
    int maxDaysBack = EditCycleStartDate.maxDaysBack,
  }) {
    final newStart =
        DateTime(newStartDate.year, newStartDate.month, newStartDate.day);
    final todayNorm = DateTime(today.year, today.month, today.day);

    if (newStart.isAfter(todayNorm)) {
      return const EditStartFailure('Start date cannot be in the future.');
    }

    final earliest = todayNorm.subtract(Duration(days: maxDaysBack));
    if (newStart.isBefore(earliest)) {
      return EditStartFailure(
        'Start date cannot be more than $maxDaysBack days ago.',
      );
    }

    if (previousCycleEndDate != null) {
      final prevEnd = DateTime(
        previousCycleEndDate.year,
        previousCycleEndDate.month,
        previousCycleEndDate.day,
      );
      if (!newStart.isAfter(prevEnd)) {
        return const EditStartFailure(
          'Start date must be after the previous period ended.',
        );
      }
    }

    return const EditStartSuccess();
  }

  static String _iso(DateTime d) =>
      '${d.year.toString().padLeft(4, '0')}-'
      '${d.month.toString().padLeft(2, '0')}-'
      '${d.day.toString().padLeft(2, '0')}';
}

sealed class EditStartResult {
  const EditStartResult();
}

class EditStartSuccess extends EditStartResult {
  const EditStartSuccess();
}

class EditStartFailure extends EditStartResult {
  final String reason;
  const EditStartFailure(this.reason);
}

final editCycleStartDateProvider = Provider<EditCycleStartDate>(
  (ref) => EditCycleStartDate(ref),
);
