import 'package:drift/drift.dart';

@DataClassName('AiInsightRow')
class AiInsightsCacheTable extends Table {
  @override
  String get tableName => 'ai_insights_cache';

  IntColumn get id => integer().autoIncrement()();
  IntColumn get cycleEntryId => integer().nullable()();
  TextColumn get insightType => text()();
  TextColumn get content => text()(); // JSON
  IntColumn get generatedAt => integer()();
  BoolColumn get isStale => boolean().withDefault(const Constant(false))();
}
