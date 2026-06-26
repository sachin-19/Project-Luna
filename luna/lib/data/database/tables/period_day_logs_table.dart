import 'package:drift/drift.dart';
import 'cycle_entries_table.dart';

@DataClassName('PeriodDayRow')
class PeriodDayLogsTable extends Table {
  @override
  String get tableName => 'period_day_logs';

  IntColumn get id => integer().autoIncrement()();
  IntColumn get cycleEntryId =>
      integer().references(CycleEntriesTable, #id)();
  TextColumn get date => text()();
  TextColumn get flow => text()(); // spotting | light | medium | heavy

  @override
  List<Set<Column>> get uniqueKeys => [
        {cycleEntryId, date},
      ];
}
