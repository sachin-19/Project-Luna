import 'dart:io';
import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'tables/users_table.dart';
import 'tables/cycle_entries_table.dart';
import 'tables/period_day_logs_table.dart';
import 'tables/symptom_logs_table.dart';
import 'tables/mood_logs_table.dart';
import 'tables/health_notes_table.dart';
import 'tables/ai_insights_cache_table.dart';
import 'daos/user_dao.dart';
import 'daos/cycle_dao.dart';
import 'daos/symptom_dao.dart';
import 'daos/mood_dao.dart';

part 'app_database.g.dart';

@DriftDatabase(
  tables: [
    UsersTable,
    CycleEntriesTable,
    PeriodDayLogsTable,
    SymptomLogsTable,
    MoodLogsTable,
    HealthNotesTable,
    AiInsightsCacheTable,
  ],
  daos: [UserDao, CycleDao, SymptomDao, MoodDao],
)
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());

  AppDatabase.forTesting(super.executor);

  @override
  int get schemaVersion => 1;

  @override
  MigrationStrategy get migration => MigrationStrategy(
        onCreate: (m) => m.createAll(),
        onUpgrade: (m, from, to) async {
          // Future migrations numbered here as schema evolves.
        },
      );
}

LazyDatabase _openConnection() {
  return LazyDatabase(() async {
    final dir = await getApplicationDocumentsDirectory();
    final file = File(p.join(dir.path, 'luna.sqlite'));
    return NativeDatabase.createInBackground(file);
  });
}
