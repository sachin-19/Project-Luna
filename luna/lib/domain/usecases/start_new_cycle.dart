import 'package:drift/drift.dart' show Value;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/database/app_database.dart';
import '../../data/database/database_provider.dart';
import '../../presentation/providers/estimator_provider.dart';

/// Starts a new cycle on [startDate].
///
/// If an open cycle already exists it is closed automatically:
///   • endDate  = day before [startDate]
///   • periodLength = count of logged period-day rows for that cycle
///   • cycleLength  = days between the two starts → fed to the Bayesian estimator
class StartNewCycle {
  StartNewCycle(this._ref);
  final Ref _ref;

  Future<void> execute(DateTime startDate) async {
    final db = _ref.read(databaseProvider);
    final estimator = _ref.read(cycleEstimatorServiceProvider);
    final startIso = _iso(startDate);

    // ── Close any open cycle ───────────────────────────────────────────────
    final openRow = await db.cycleDao.watchActiveCycle().first;
    if (openRow != null && openRow.startDate != startIso) {
      final previousStart = DateTime.parse(openRow.startDate);
      final cycleLength = startDate.difference(previousStart).inDays;

      if (cycleLength > 0) {
        final periodDays =
            await db.cycleDao.getPeriodDaysForCycle(openRow.id);
        await db.cycleDao.updateCycleEnd(
          openRow.id,
          _iso(startDate.subtract(const Duration(days: 1))),
          periodDays.length, // actual logged period days, not cycle length
        );
        await db.cycleDao.updateCycleLength(openRow.id, cycleLength);
        await estimator.observe(cycleLength.toDouble());
      }
    }

    // ── Start new cycle ────────────────────────────────────────────────────
    await db.cycleDao.insertCycle(
      CycleEntriesTableCompanion(
        startDate: Value(startIso),
        isSeeded: const Value(false),
        createdAt: Value(DateTime.now().millisecondsSinceEpoch),
      ),
    );
  }

  static String _iso(DateTime d) =>
      '${d.year.toString().padLeft(4, '0')}-'
      '${d.month.toString().padLeft(2, '0')}-'
      '${d.day.toString().padLeft(2, '0')}';
}

final startNewCycleProvider =
    Provider<StartNewCycle>((ref) => StartNewCycle(ref));
