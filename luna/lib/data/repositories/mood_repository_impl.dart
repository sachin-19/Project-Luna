import 'package:drift/drift.dart';
import '../../domain/entities/mood_log.dart';
import '../../domain/repositories/mood_repository.dart';
import '../database/app_database.dart';
import '../database/daos/mood_dao.dart';

class MoodRepositoryImpl implements MoodRepository {
  final MoodDao _dao;

  MoodRepositoryImpl(this._dao);

  @override
  Stream<MoodLog?> watchMoodForDate(String date) =>
      _dao.watchMoodForDate(date).map((r) => r?.toDomain());

  @override
  Future<List<MoodLog>> getMoodsForRange(
    String startDate,
    String endDate,
  ) async {
    final rows = await _dao.getMoodsForRange(startDate, endDate);
    return rows.map((r) => r.toDomain()).toList();
  }

  @override
  Future<void> logMood({
    required String date,
    required String mood,
    required int energyLevel,
    String? notes,
  }) {
    final now = DateTime.now().millisecondsSinceEpoch;
    return _dao.upsertMood(
      MoodLogsTableCompanion(
        date: Value(date),
        mood: Value(mood),
        energyLevel: Value(energyLevel),
        notes: Value(notes),
        createdAt: Value(now),
      ),
    );
  }
}

extension _MoodRowMapper on MoodRow {
  MoodLog toDomain() => MoodLog(
        id: id,
        date: date,
        mood: mood,
        energyLevel: energyLevel,
        notes: notes,
        createdAt: createdAt,
      );
}
