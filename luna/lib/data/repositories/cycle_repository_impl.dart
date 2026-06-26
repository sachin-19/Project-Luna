import 'package:drift/drift.dart';
import '../../domain/entities/cycle_entry.dart';
import '../../domain/entities/period_day.dart';
import '../../domain/repositories/cycle_repository.dart';
import '../database/app_database.dart';
import '../database/daos/cycle_dao.dart';

class CycleRepositoryImpl implements CycleRepository {
  final CycleDao _dao;

  CycleRepositoryImpl(this._dao);

  @override
  Stream<CycleEntry?> watchActiveCycle() =>
      _dao.watchActiveCycle().map((r) => r?.toDomain());

  @override
  Future<List<CycleEntry>> getAllCycles() async {
    final rows = await _dao.getAllCycles();
    return rows.map((r) => r.toDomain()).toList();
  }

  @override
  Future<List<CycleEntry>> getLastNCycles(int n) async {
    final rows = await _dao.getLastNCycles(n);
    return rows.map((r) => r.toDomain()).toList();
  }

  @override
  Future<int> startCycle(String startDate, {bool isSeeded = false}) {
    final now = DateTime.now().millisecondsSinceEpoch;
    return _dao.insertCycle(
      CycleEntriesTableCompanion(
        startDate: Value(startDate),
        isSeeded: Value(isSeeded),
        createdAt: Value(now),
      ),
    );
  }

  @override
  Future<int> insertSeededCycle({
    required String startDate,
    required String endDate,
    required int periodLength,
    int? cycleLength,
  }) {
    final now = DateTime.now().millisecondsSinceEpoch;
    return _dao.insertCycle(
      CycleEntriesTableCompanion(
        startDate: Value(startDate),
        endDate: Value(endDate),
        periodLength: Value(periodLength),
        cycleLength:
            cycleLength != null ? Value(cycleLength) : const Value.absent(),
        isSeeded: const Value(true),
        createdAt: Value(now),
      ),
    );
  }

  @override
  Future<void> endCycle(int id, String endDate) async {
    final cycle = await _dao.getAllCycles().then(
          (list) => list.firstWhere((c) => c.id == id),
        );
    final start = DateTime.parse(cycle.startDate);
    final end = DateTime.parse(endDate);
    final periodLength = end.difference(start).inDays + 1;
    await _dao.updateCycleEnd(id, endDate, periodLength);
  }

  @override
  Future<List<PeriodDay>> getPeriodDaysForCycle(int cycleId) async {
    final rows = await _dao.getPeriodDaysForCycle(cycleId);
    return rows.map((r) => r.toDomain()).toList();
  }

  @override
  Future<void> logPeriodDay(int cycleId, String date, String flow) {
    return _dao.upsertPeriodDay(
      PeriodDayLogsTableCompanion(
        cycleEntryId: Value(cycleId),
        date: Value(date),
        flow: Value(flow),
      ),
    );
  }

  @override
  Future<void> updateActiveCycleStart(int cycleId, String newStartDate) async {
    await _dao.updateCycleStart(cycleId, newStartDate);
    await _dao.deletePeriodDaysBefore(cycleId, newStartDate);
  }

  @override
  Future<void> updateCompletedCycleEnd(int cycleId, String newEndDate) async {
    await _dao.deletePeriodDaysAfter(cycleId, newEndDate);
    final remaining = await _dao.getPeriodDaysForCycle(cycleId);
    await _dao.updateCycleEnd(cycleId, newEndDate, remaining.length);
  }
}

extension _CycleRowMapper on CycleEntryRow {
  CycleEntry toDomain() => CycleEntry(
        id: id,
        startDate: startDate,
        endDate: endDate,
        cycleLength: cycleLength,
        periodLength: periodLength,
        notes: notes,
        isSeeded: isSeeded,
        createdAt: createdAt,
      );
}

extension _PeriodDayRowMapper on PeriodDayRow {
  PeriodDay toDomain() => PeriodDay(
        id: id,
        cycleEntryId: cycleEntryId,
        date: date,
        flow: flow,
      );
}
