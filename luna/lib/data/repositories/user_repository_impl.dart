import 'dart:convert';
import 'package:drift/drift.dart';
import '../../core/constants/enums.dart';
import '../../domain/entities/user.dart';
import '../../domain/repositories/user_repository.dart';
import '../database/app_database.dart';
import '../database/daos/user_dao.dart';

class UserRepositoryImpl implements UserRepository {
  final UserDao _dao;

  UserRepositoryImpl(this._dao);

  @override
  Stream<User?> watchUser() => _dao.watchUser().map((r) => r?.toDomain());

  @override
  Future<User?> getUser() async {
    final row = await _dao.getUser();
    return row?.toDomain();
  }

  @override
  Future<void> saveUser(User user) => _dao.upsertUser(user.toCompanion());

  @override
  Future<void> setOnboarded() async {
    final existing = await _dao.getUser();
    if (existing == null) return;
    await _dao.upsertUser(
      UsersTableCompanion(
        id: Value(existing.id),
        onboarded: const Value(true),
      ),
    );
  }
}

extension _UserRowMapper on UserRow {
  User toDomain() => User(
        id: id,
        displayName: displayName,
        birthYear: birthYear,
        avgCycleDays: avgCycleDays,
        avgPeriodDays: avgPeriodDays,
        cycleLengthKnown: cycleLengthKnown,
        onHormonalContraception: onHormonalContraception,
        hasPcos: hasPcos,
        hasEndo: hasEndo,
        trackingGoals: trackingGoals != null
            ? List<String>.from(jsonDecode(trackingGoals!))
            : [],
        commonSymptoms: commonSymptoms != null
            ? List<String>.from(jsonDecode(commonSymptoms!))
            : [],
        baselineStress: baselineStress,
        exerciseFrequency: exerciseFrequency,
        preferredLanguage: preferredLanguage,
        themeBrightness: themeBrightness,
        cloudSyncEnabled: cloudSyncEnabled,
        notificationsPeriod: notificationsPeriod,
        notificationsOvulation: notificationsOvulation,
        notificationsDailyCheckin: notificationsDailyCheckin,
        notificationLeadDays: notificationLeadDays,
        onboarded: onboarded,
        reproductiveStatus: ReproductiveStatus.values.firstWhere(
          (e) => e.name == reproductiveStatus,
          orElse: () => ReproductiveStatus.normal,
        ),
        heightCm: heightCm,
        weightKg: weightKg,
        createdAt: createdAt,
      );
}

extension _UserMapper on User {
  UsersTableCompanion toCompanion() => UsersTableCompanion(
        id: id == 0 ? const Value.absent() : Value(id),
        displayName: Value(displayName),
        birthYear: Value(birthYear),
        avgCycleDays: Value(avgCycleDays),
        avgPeriodDays: Value(avgPeriodDays),
        cycleLengthKnown: Value(cycleLengthKnown),
        onHormonalContraception: Value(onHormonalContraception),
        hasPcos: Value(hasPcos),
        hasEndo: Value(hasEndo),
        trackingGoals: Value(
          trackingGoals.isNotEmpty ? jsonEncode(trackingGoals) : null,
        ),
        commonSymptoms: Value(
          commonSymptoms.isNotEmpty ? jsonEncode(commonSymptoms) : null,
        ),
        baselineStress: Value(baselineStress),
        exerciseFrequency: Value(exerciseFrequency),
        preferredLanguage: Value(preferredLanguage),
        themeBrightness: Value(themeBrightness),
        cloudSyncEnabled: Value(cloudSyncEnabled),
        notificationsPeriod: Value(notificationsPeriod),
        notificationsOvulation: Value(notificationsOvulation),
        notificationsDailyCheckin: Value(notificationsDailyCheckin),
        notificationLeadDays: Value(notificationLeadDays),
        onboarded: Value(onboarded),
        reproductiveStatus: Value(reproductiveStatus.name),
        heightCm: Value(heightCm),
        weightKg: Value(weightKg),
        createdAt: Value(createdAt),
      );
}
