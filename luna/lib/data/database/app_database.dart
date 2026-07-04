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
  int get schemaVersion => 2;

  @override
  MigrationStrategy get migration => MigrationStrategy(
        onCreate: (m) => m.createAll(),
        onUpgrade: (m, from, to) async {
          // v1 → v2: added reproductive_status, height_cm, weight_kg to users.
          // Uses PRAGMA to check first — a fresh install on the new schema
          // already has these columns at v1, so we must not try to add them again.
          if (from < 2) {
            final rows =
                await customSelect('PRAGMA table_info("users")').get();
            final existing =
                rows.map((r) => r.read<String>('name')).toSet();
            if (!existing.contains('reproductive_status')) {
              await m.addColumn(usersTable, usersTable.reproductiveStatus);
            }
            if (!existing.contains('height_cm')) {
              await m.addColumn(usersTable, usersTable.heightCm);
            }
            if (!existing.contains('weight_kg')) {
              await m.addColumn(usersTable, usersTable.weightKg);
            }
          }
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
