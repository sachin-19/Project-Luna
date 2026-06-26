import 'package:drift/drift.dart';

@DataClassName('UserRow')
class UsersTable extends Table {
  @override
  String get tableName => 'users';

  IntColumn get id => integer().autoIncrement()();
  TextColumn get displayName => text()();
  IntColumn get birthYear => integer()();
  IntColumn get avgCycleDays => integer().withDefault(const Constant(28))();
  IntColumn get avgPeriodDays => integer().withDefault(const Constant(5))();
  BoolColumn get cycleLengthKnown => boolean().withDefault(const Constant(true))();
  BoolColumn get onHormonalContraception => boolean().withDefault(const Constant(false))();
  BoolColumn get hasPcos => boolean().withDefault(const Constant(false))();
  BoolColumn get hasEndo => boolean().withDefault(const Constant(false))();
  TextColumn get trackingGoals => text().nullable()();
  TextColumn get commonSymptoms => text().nullable()();
  IntColumn get baselineStress => integer().nullable()();
  TextColumn get exerciseFrequency => text().nullable()();
  TextColumn get preferredLanguage => text().withDefault(const Constant('en'))();
  TextColumn get themeBrightness => text().withDefault(const Constant('light'))();
  BoolColumn get cloudSyncEnabled => boolean().withDefault(const Constant(false))();
  BoolColumn get notificationsPeriod => boolean().withDefault(const Constant(true))();
  BoolColumn get notificationsOvulation => boolean().withDefault(const Constant(true))();
  BoolColumn get notificationsDailyCheckin => boolean().withDefault(const Constant(true))();
  IntColumn get notificationLeadDays => integer().withDefault(const Constant(2))();
  BoolColumn get onboarded => boolean().withDefault(const Constant(false))();
  IntColumn get createdAt => integer()();
}
