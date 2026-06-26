import 'package:drift/drift.dart';
import '../app_database.dart';
import '../tables/mood_logs_table.dart';

part 'mood_dao.g.dart';

@DriftAccessor(tables: [MoodLogsTable])
class MoodDao extends DatabaseAccessor<AppDatabase> with _$MoodDaoMixin {
  MoodDao(super.db);

  Stream<MoodRow?> watchMoodForDate(String date) =>
      (select(moodLogsTable)..where((t) => t.date.equals(date)))
          .watchSingleOrNull();

  Future<List<MoodRow>> getMoodsForRange(
    String startDate,
    String endDate,
  ) =>
      (select(moodLogsTable)
            ..where((t) => t.date.isBetweenValues(startDate, endDate))
            ..orderBy([(t) => OrderingTerm.asc(t.date)]))
          .get();

  Future<int> upsertMood(MoodLogsTableCompanion companion) =>
      into(moodLogsTable).insert(
        companion,
        onConflict: DoUpdate(
          (_) => companion,
          target: [moodLogsTable.date],
        ),
      );
}
