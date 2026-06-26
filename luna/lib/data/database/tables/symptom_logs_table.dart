import 'package:drift/drift.dart';

@DataClassName('SymptomRow')
class SymptomLogsTable extends Table {
  @override
  String get tableName => 'symptom_logs';

  IntColumn get id => integer().autoIncrement()();
  TextColumn get date => text()();
  TextColumn get symptom => text()();
  IntColumn get severity => integer()(); // 1–5
  TextColumn get notes => text().nullable()();
  IntColumn get createdAt => integer()();

  @override
  List<Set<Column>> get uniqueKeys => [
        {date, symptom},
      ];
}
