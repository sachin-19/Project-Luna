import 'package:drift/drift.dart';

@DataClassName('CycleEntryRow')
class CycleEntriesTable extends Table {
  @override
  String get tableName => 'cycle_entries';

  IntColumn get id => integer().autoIncrement()();
  TextColumn get startDate => text()();
  TextColumn get endDate => text().nullable()();
  IntColumn get cycleLength => integer().nullable()();
  IntColumn get periodLength => integer().nullable()();
  TextColumn get notes => text().nullable()();
  BoolColumn get isSeeded => boolean().withDefault(const Constant(false))();
  IntColumn get createdAt => integer()();
}
