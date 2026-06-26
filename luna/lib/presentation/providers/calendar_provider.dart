import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/database/app_database.dart';
import '../../data/database/database_provider.dart';

/// The calendar month currently being viewed, as (year, month).
/// Not auto-disposed so month navigation persists when switching tabs.
final calendarMonthProvider = StateProvider<(int, int)>((ref) {
  final now = DateTime.now();
  return (now.year, now.month);
});

/// All cycle entries (newest first), used for phase shading across past months.
/// Auto-disposed so it re-fetches fresh data each time the calendar opens.
final allCyclesProvider = FutureProvider.autoDispose<List<CycleEntryRow>>(
  (ref) => ref.watch(databaseProvider).cycleDao.getAllCycles(),
);

/// ISO-8601 date strings (yyyy-MM-dd) of days in [ym] that have period logs.
final periodDaysForMonthProvider = FutureProvider.autoDispose
    .family<Set<String>, (int, int)>((ref, ym) async {
  final db = ref.watch(databaseProvider);
  final rows = await db.cycleDao.getPeriodDaysForRange(
    _monthStart(ym.$1, ym.$2),
    _monthEnd(ym.$1, ym.$2),
  );
  return rows.map((r) => r.date).toSet();
});

/// ISO-8601 date strings of days in [ym] that have mood logs.
final moodDaysForMonthProvider = FutureProvider.autoDispose
    .family<Set<String>, (int, int)>((ref, ym) async {
  final db = ref.watch(databaseProvider);
  final rows = await db.moodDao.getMoodsForRange(
    _monthStart(ym.$1, ym.$2),
    _monthEnd(ym.$1, ym.$2),
  );
  return rows.map((r) => r.date).toSet();
});

/// ISO-8601 date strings of days in [ym] that have symptom logs.
final symptomDaysForMonthProvider = FutureProvider.autoDispose
    .family<Set<String>, (int, int)>((ref, ym) async {
  final db = ref.watch(databaseProvider);
  final rows = await db.symptomDao.getSymptomsForRange(
    _monthStart(ym.$1, ym.$2),
    _monthEnd(ym.$1, ym.$2),
  );
  return rows.map((r) => r.date).toSet();
});

/// ISO date strings of days in [ym] that fall inside the predicted period window.
/// The window is computed from the most recent cycle: startDate + cycleLength
/// for [cycleLength] days, using the recorded periodLength (or 5 as fallback).
/// Returns an empty set if the predicted window starts today or earlier.
final predictedPeriodDaysProvider = FutureProvider.autoDispose
    .family<Set<String>, (int, int)>((ref, ym) async {
  final cycles = await ref.watch(allCyclesProvider.future);
  if (cycles.isEmpty) return {};

  final last = cycles.first; // newest-first order
  final lastStart = DateTime.parse(last.startDate);
  final cycleLen = last.cycleLength ?? 28;
  final periodLen = last.periodLength ?? 5;

  final predictedStart = lastStart.add(Duration(days: cycleLen));
  final predictedEnd =
      predictedStart.add(Duration(days: periodLen - 1));

  final now = DateTime.now();
  final today = DateTime(now.year, now.month, now.day);
  if (!predictedStart.isAfter(today)) return {};

  final result = <String>{};
  var day = predictedStart;
  while (!day.isAfter(predictedEnd)) {
    if (day.year == ym.$1 && day.month == ym.$2) {
      result.add(_iso(day));
    }
    day = day.add(const Duration(days: 1));
  }
  return result;
});

// ── Helpers ───────────────────────────────────────────────────────────────────

String _monthStart(int year, int month) =>
    '${year.toString().padLeft(4, '0')}-'
    '${month.toString().padLeft(2, '0')}-01';

String _monthEnd(int year, int month) {
  final lastDay = DateTime(year, month + 1, 0).day;
  return '${year.toString().padLeft(4, '0')}-'
      '${month.toString().padLeft(2, '0')}-'
      '${lastDay.toString().padLeft(2, '0')}';
}

String _iso(DateTime d) =>
    '${d.year.toString().padLeft(4, '0')}-'
    '${d.month.toString().padLeft(2, '0')}-'
    '${d.day.toString().padLeft(2, '0')}';
