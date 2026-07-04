import 'package:drift/drift.dart';
import '../app_database.dart';
import '../tables/cycle_entries_table.dart';
import '../tables/period_day_logs_table.dart';

part 'cycle_dao.g.dart';

@DriftAccessor(tables: [CycleEntriesTable, PeriodDayLogsTable])
class CycleDao extends DatabaseAccessor<AppDatabase> with _$CycleDaoMixin {
  CycleDao(super.db);

  Stream<CycleEntryRow?> watchActiveCycle() => (select(cycleEntriesTable)
        ..where((t) => t.endDate.isNull())
        ..orderBy([(t) => OrderingTerm.desc(t.startDate)])
        ..limit(1))
      .watchSingleOrNull();

  Future<List<CycleEntryRow>> getAllCycles() =>
      (select(cycleEntriesTable)
            ..orderBy([(t) => OrderingTerm.desc(t.startDate)]))
          .get();

  Future<List<CycleEntryRow>> getLastNCycles(int n) =>
      (select(cycleEntriesTable)
            ..where((t) => t.endDate.isNotNull())
            ..orderBy([(t) => OrderingTerm.desc(t.startDate)])
            ..limit(n))
          .get();

  Future<int> insertCycle(CycleEntriesTableCompanion companion) =>
      into(cycleEntriesTable).insert(companion);

  Future<void> updateCycleEnd(int id, String endDate, int periodLength) =>
      (update(cycleEntriesTable)..where((t) => t.id.equals(id))).write(
        CycleEntriesTableCompanion(
          endDate: Value(endDate),
          periodLength: Value(periodLength),
        ),
      );

  Future<void> updateCycleLength(int id, int cycleLength) =>
      (update(cycleEntriesTable)..where((t) => t.id.equals(id))).write(
        CycleEntriesTableCompanion(cycleLength: Value(cycleLength)),
      );

  /// Records how many days the menstrual flow lasted WITHOUT closing the cycle.
  /// The cycle row keeps endDate = null so phase calculations continue working
  /// for the follicular / ovulation / luteal days that follow.
  Future<void> updatePeriodLength(int id, int periodLength) =>
      (update(cycleEntriesTable)..where((t) => t.id.equals(id))).write(
        CycleEntriesTableCompanion(periodLength: Value(periodLength)),
      );

  Future<List<PeriodDayRow>> getPeriodDaysForCycle(int cycleId) =>
      (select(periodDayLogsTable)
            ..where((t) => t.cycleEntryId.equals(cycleId))
            ..orderBy([(t) => OrderingTerm.asc(t.date)]))
          .get();

  Future<List<PeriodDayRow>> getPeriodDaysForRange(
    String startDate,
    String endDate,
  ) =>
      (select(periodDayLogsTable)
            ..where((t) => t.date.isBetweenValues(startDate, endDate))
            ..orderBy([(t) => OrderingTerm.asc(t.date)]))
          .get();

  Future<int> upsertPeriodDay(PeriodDayLogsTableCompanion companion) =>
      into(periodDayLogsTable).insert(
        companion,
        onConflict: DoUpdate(
          (_) => companion,
          target: [periodDayLogsTable.cycleEntryId, periodDayLogsTable.date],
        ),
      );

  Future<void> updateCycleStart(int id, String newStartDate) =>
      (update(cycleEntriesTable)..where((t) => t.id.equals(id))).write(
        CycleEntriesTableCompanion(startDate: Value(newStartDate)),
      );

  /// Deletes period_day_logs for [cycleId] with date strictly before [date].
  Future<int> deletePeriodDaysBefore(int cycleId, String date) =>
      (delete(periodDayLogsTable)
            ..where((t) =>
                t.cycleEntryId.equals(cycleId) &
                t.date.isSmallerThanValue(date)))
          .go();

  /// Deletes period_day_logs for [cycleId] with date strictly after [date].
  Future<int> deletePeriodDaysAfter(int cycleId, String date) =>
      (delete(periodDayLogsTable)
            ..where((t) =>
                t.cycleEntryId.equals(cycleId) &
                t.date.isBiggerThanValue(date)))
          .go();
}
