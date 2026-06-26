import 'package:drift/drift.dart';
import '../app_database.dart';
import '../tables/symptom_logs_table.dart';

part 'symptom_dao.g.dart';

@DriftAccessor(tables: [SymptomLogsTable])
class SymptomDao extends DatabaseAccessor<AppDatabase> with _$SymptomDaoMixin {
  SymptomDao(super.db);

  Stream<List<SymptomRow>> watchSymptomsForDate(String date) =>
      (select(symptomLogsTable)..where((t) => t.date.equals(date))).watch();

  Future<List<SymptomRow>> getSymptomsForRange(
    String startDate,
    String endDate,
  ) =>
      (select(symptomLogsTable)
            ..where((t) => t.date.isBetweenValues(startDate, endDate))
            ..orderBy([(t) => OrderingTerm.asc(t.date)]))
          .get();

  Future<int> upsertSymptom(SymptomLogsTableCompanion companion) =>
      into(symptomLogsTable).insert(
        companion,
        onConflict: DoUpdate(
          (_) => companion,
          target: [symptomLogsTable.date, symptomLogsTable.symptom],
        ),
      );

  Future<int> deleteSymptom(int id) =>
      (delete(symptomLogsTable)..where((t) => t.id.equals(id))).go();
}
