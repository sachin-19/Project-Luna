import 'package:drift/drift.dart';

@DataClassName('MoodRow')
class MoodLogsTable extends Table {
  @override
  String get tableName => 'mood_logs';

  IntColumn get id => integer().autoIncrement()();
  TextColumn get date => text()(); // unique — one mood per day
  TextColumn get mood => text()(); // happy | calm | sad | anxious | irritable | energetic
  IntColumn get energyLevel => integer()(); // 1–5
  TextColumn get notes => text().nullable()();
  IntColumn get createdAt => integer()();

  @override
  List<Set<Column>> get uniqueKeys => [
        {date},
      ];
}
