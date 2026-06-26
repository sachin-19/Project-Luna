import 'package:drift/drift.dart';

@DataClassName('HealthNoteRow')
class HealthNotesTable extends Table {
  @override
  String get tableName => 'health_notes';

  IntColumn get id => integer().autoIncrement()();
  TextColumn get date => text()();
  TextColumn get content => text()();
  TextColumn get tags => text().nullable()(); // JSON array
  IntColumn get createdAt => integer()();
}
