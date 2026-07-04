import '../../core/constants/enums.dart';

class User {
  final int id;
  final String displayName;
  final int birthYear;
  final int avgCycleDays;
  final int avgPeriodDays;
  final bool cycleLengthKnown;
  final bool onHormonalContraception;
  final bool hasPcos;
  final bool hasEndo;
  final List<String> trackingGoals;
  final List<String> commonSymptoms;
  final int? baselineStress;
  final String? exerciseFrequency;
  final String preferredLanguage;
  final String themeBrightness;
  final bool cloudSyncEnabled;
  final bool notificationsPeriod;
  final bool notificationsOvulation;
  final bool notificationsDailyCheckin;
  final int notificationLeadDays;
  final bool onboarded;
  final ReproductiveStatus reproductiveStatus;
  final int? heightCm;
  final double? weightKg;
  final int createdAt;

  const User({
    required this.id,
    required this.displayName,
    required this.birthYear,
    this.avgCycleDays = 28,
    this.avgPeriodDays = 5,
    this.cycleLengthKnown = true,
    this.onHormonalContraception = false,
    this.hasPcos = false,
    this.hasEndo = false,
    this.trackingGoals = const [],
    this.commonSymptoms = const [],
    this.baselineStress,
    this.exerciseFrequency,
    this.preferredLanguage = 'en',
    this.themeBrightness = 'light',
    this.cloudSyncEnabled = false,
    this.notificationsPeriod = true,
    this.notificationsOvulation = true,
    this.notificationsDailyCheckin = true,
    this.notificationLeadDays = 2,
    this.onboarded = false,
    this.reproductiveStatus = ReproductiveStatus.normal,
    this.heightCm,
    this.weightKg,
    required this.createdAt,
  });

  bool get isYouth => (DateTime.now().year - birthYear) < 18;

  User copyWith({
    String? displayName,
    int? avgCycleDays,
    int? avgPeriodDays,
    bool? cycleLengthKnown,
    bool? onHormonalContraception,
    bool? hasPcos,
    bool? hasEndo,
    List<String>? trackingGoals,
    List<String>? commonSymptoms,
    int? baselineStress,
    String? exerciseFrequency,
    String? preferredLanguage,
    String? themeBrightness,
    bool? cloudSyncEnabled,
    bool? notificationsPeriod,
    bool? notificationsOvulation,
    bool? notificationsDailyCheckin,
    int? notificationLeadDays,
    bool? onboarded,
    ReproductiveStatus? reproductiveStatus,
    int? heightCm,
    double? weightKg,
  }) =>
      User(
        id: id,
        displayName: displayName ?? this.displayName,
        birthYear: birthYear,
        avgCycleDays: avgCycleDays ?? this.avgCycleDays,
        avgPeriodDays: avgPeriodDays ?? this.avgPeriodDays,
        cycleLengthKnown: cycleLengthKnown ?? this.cycleLengthKnown,
        onHormonalContraception:
            onHormonalContraception ?? this.onHormonalContraception,
        hasPcos: hasPcos ?? this.hasPcos,
        hasEndo: hasEndo ?? this.hasEndo,
        trackingGoals: trackingGoals ?? this.trackingGoals,
        commonSymptoms: commonSymptoms ?? this.commonSymptoms,
        baselineStress: baselineStress ?? this.baselineStress,
        exerciseFrequency: exerciseFrequency ?? this.exerciseFrequency,
        preferredLanguage: preferredLanguage ?? this.preferredLanguage,
        themeBrightness: themeBrightness ?? this.themeBrightness,
        cloudSyncEnabled: cloudSyncEnabled ?? this.cloudSyncEnabled,
        notificationsPeriod: notificationsPeriod ?? this.notificationsPeriod,
        notificationsOvulation:
            notificationsOvulation ?? this.notificationsOvulation,
        notificationsDailyCheckin:
            notificationsDailyCheckin ?? this.notificationsDailyCheckin,
        notificationLeadDays: notificationLeadDays ?? this.notificationLeadDays,
        onboarded: onboarded ?? this.onboarded,
        reproductiveStatus: reproductiveStatus ?? this.reproductiveStatus,
        heightCm: heightCm ?? this.heightCm,
        weightKg: weightKg ?? this.weightKg,
        createdAt: createdAt,
      );
}
