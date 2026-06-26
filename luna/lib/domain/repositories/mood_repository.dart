import '../entities/mood_log.dart';

abstract interface class MoodRepository {
  Stream<MoodLog?> watchMoodForDate(String date);
  Future<List<MoodLog>> getMoodsForRange(String startDate, String endDate);
  Future<void> logMood({
    required String date,
    required String mood,
    required int energyLevel,
    String? notes,
  });
}
