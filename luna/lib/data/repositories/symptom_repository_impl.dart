import 'package:drift/drift.dart';
import '../../domain/entities/symptom_log.dart';
import '../../domain/repositories/symptom_repository.dart';
import '../database/app_database.dart';
import '../database/daos/symptom_dao.dart';

class SymptomRepositoryImpl implements SymptomRepository {
  final SymptomDao _dao;

  SymptomRepositoryImpl(this._dao);

  @override
  Stream<List<SymptomLog>> watchSymptomsForDate(String date) =>
      _dao.watchSymptomsForDate(date).map(
            (rows) => rows.map((r) => r.toDomain()).toList(),
          );

  @override
  Future<List<SymptomLog>> getSymptomsForRange(
    String startDate,
    String endDate,
  ) async {
    final rows = await _dao.getSymptomsForRange(startDate, endDate);
    return rows.map((r) => r.toDomain()).toList();
  }

  @override
  Future<void> logSymptom({
    required String date,
    required String symptom,
    required int severity,
    String? notes,
  }) {
    final now = DateTime.now().millisecondsSinceEpoch;
    return _dao.upsertSymptom(
      SymptomLogsTableCompanion(
        date: Value(date),
        symptom: Value(symptom),
        severity: Value(severity),
        notes: Value(notes),
        createdAt: Value(now),
      ),
    );
  }

  @override
  Future<void> deleteSymptom(int id) => _dao.deleteSymptom(id);
}

extension _SymptomRowMapper on SymptomRow {
  SymptomLog toDomain() => SymptomLog(
        id: id,
        date: date,
        symptom: symptom,
        severity: severity,
        notes: notes,
        createdAt: createdAt,
      );
}
