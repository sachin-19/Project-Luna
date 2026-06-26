import '../entities/cycle_entry.dart';
import '../entities/period_day.dart';

abstract interface class CycleRepository {
  Stream<CycleEntry?> watchActiveCycle();
  Future<List<CycleEntry>> getAllCycles();
  Future<List<CycleEntry>> getLastNCycles(int n);
  Future<int> startCycle(String startDate, {bool isSeeded = false});
  Future<void> endCycle(int id, String endDate);
  /// Insert a fully-specified completed historical cycle. Returns the new row ID.
  Future<int> insertSeededCycle({
    required String startDate,
    required String endDate,
    required int periodLength,
    int? cycleLength,
  });
  Future<List<PeriodDay>> getPeriodDaysForCycle(int cycleId);
  Future<void> logPeriodDay(int cycleId, String date, String flow);
}
