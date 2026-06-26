import '../entities/symptom_log.dart';

abstract interface class SymptomRepository {
  Stream<List<SymptomLog>> watchSymptomsForDate(String date);
  Future<List<SymptomLog>> getSymptomsForRange(String startDate, String endDate);
  Future<void> logSymptom({
    required String date,
    required String symptom,
    required int severity,
    String? notes,
  });
  Future<void> deleteSymptom(int id);
}
