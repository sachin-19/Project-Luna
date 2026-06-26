import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/constants/enums.dart';

/// Holds all in-progress onboarding answers across the 10 screens.
/// Written to the DB only when Screen 10 completes.
class OnboardingData {
  final String name;
  final int birthYear;
  final DateTime? lastPeriodStart;
  final int periodDays;
  final int cycleDays;
  final bool cycleLengthUnknown;
  final List<DateTime> pastPeriods;
  final List<int> pastPeriodDurations; // parallel to pastPeriods — duration in days
  final String? regularity;
  final bool hasPcos;
  final bool hasEndo;
  final List<String> trackingGoals;
  final List<String> commonSymptoms;
  final int? baselineStress;
  final String? exerciseFrequency;
  final bool onHormonalContraception;
  final ReproductiveStatus reproductiveStatus;
  final int? heightCm;
  final double? weightKg;
  final bool notifPeriod;
  final bool notifOvulation;
  final bool notifCheckin;

  const OnboardingData({
    this.name = '',
    this.birthYear = 1998,
    this.lastPeriodStart,
    this.periodDays = 5,
    this.cycleDays = 28,
    this.cycleLengthUnknown = false,
    this.pastPeriods = const [],
    this.pastPeriodDurations = const [],
    this.regularity,
    this.hasPcos = false,
    this.hasEndo = false,
    this.trackingGoals = const [],
    this.commonSymptoms = const [],
    this.baselineStress,
    this.exerciseFrequency,
    this.onHormonalContraception = false,
    this.reproductiveStatus = ReproductiveStatus.normal,
    this.heightCm,
    this.weightKg,
    this.notifPeriod = true,
    this.notifOvulation = true,
    this.notifCheckin = true,
  });

  OnboardingData copyWith({
    String? name,
    int? birthYear,
    DateTime? lastPeriodStart,
    int? periodDays,
    int? cycleDays,
    bool? cycleLengthUnknown,
    List<DateTime>? pastPeriods,
    List<int>? pastPeriodDurations,
    String? regularity,
    bool? hasPcos,
    bool? hasEndo,
    List<String>? trackingGoals,
    List<String>? commonSymptoms,
    int? baselineStress,
    String? exerciseFrequency,
    bool? onHormonalContraception,
    ReproductiveStatus? reproductiveStatus,
    int? heightCm,
    double? weightKg,
    bool? notifPeriod,
    bool? notifOvulation,
    bool? notifCheckin,
  }) =>
      OnboardingData(
        name: name ?? this.name,
        birthYear: birthYear ?? this.birthYear,
        lastPeriodStart: lastPeriodStart ?? this.lastPeriodStart,
        periodDays: periodDays ?? this.periodDays,
        cycleDays: cycleDays ?? this.cycleDays,
        cycleLengthUnknown: cycleLengthUnknown ?? this.cycleLengthUnknown,
        pastPeriods: pastPeriods ?? this.pastPeriods,
        pastPeriodDurations: pastPeriodDurations ?? this.pastPeriodDurations,
        regularity: regularity ?? this.regularity,
        hasPcos: hasPcos ?? this.hasPcos,
        hasEndo: hasEndo ?? this.hasEndo,
        trackingGoals: trackingGoals ?? this.trackingGoals,
        commonSymptoms: commonSymptoms ?? this.commonSymptoms,
        baselineStress: baselineStress ?? this.baselineStress,
        exerciseFrequency: exerciseFrequency ?? this.exerciseFrequency,
        onHormonalContraception:
            onHormonalContraception ?? this.onHormonalContraception,
        reproductiveStatus: reproductiveStatus ?? this.reproductiveStatus,
        heightCm: heightCm ?? this.heightCm,
        weightKg: weightKg ?? this.weightKg,
        notifPeriod: notifPeriod ?? this.notifPeriod,
        notifOvulation: notifOvulation ?? this.notifOvulation,
        notifCheckin: notifCheckin ?? this.notifCheckin,
      );
}

class OnboardingNotifier extends StateNotifier<OnboardingData> {
  OnboardingNotifier() : super(const OnboardingData());

  void setName(String v) => state = state.copyWith(name: v);
  void setBirthYear(int v) => state = state.copyWith(birthYear: v);
  void setLastPeriodStart(DateTime v) =>
      state = state.copyWith(lastPeriodStart: v);
  void setPeriodDays(int v) => state = state.copyWith(periodDays: v);
  void setCycleDays(int v) => state = state.copyWith(cycleDays: v);
  void setCycleLengthUnknown(bool v) =>
      state = state.copyWith(cycleLengthUnknown: v);
  void setPastPeriods(List<DateTime> v) =>
      state = state.copyWith(pastPeriods: v);
  void setPastPeriodDurations(List<int> v) =>
      state = state.copyWith(pastPeriodDurations: v);
  void setRegularity(String? v) => state = state.copyWith(regularity: v);
  void setHasPcos(bool v) => state = state.copyWith(hasPcos: v);
  void setHasEndo(bool v) => state = state.copyWith(hasEndo: v);
  void setTrackingGoals(List<String> v) =>
      state = state.copyWith(trackingGoals: v);
  void setCommonSymptoms(List<String> v) =>
      state = state.copyWith(commonSymptoms: v);
  void setBaselineStress(int? v) => state = state.copyWith(baselineStress: v);
  void setExerciseFrequency(String? v) =>
      state = state.copyWith(exerciseFrequency: v);
  void setOnHormonalContraception(bool v) =>
      state = state.copyWith(onHormonalContraception: v);
  void setReproductiveStatus(ReproductiveStatus v) =>
      state = state.copyWith(reproductiveStatus: v);
  void setHeightCm(int? v) => state = state.copyWith(heightCm: v);
  void setWeightKg(double? v) => state = state.copyWith(weightKg: v);
  void setNotifPeriod(bool v) => state = state.copyWith(notifPeriod: v);
  void setNotifOvulation(bool v) => state = state.copyWith(notifOvulation: v);
  void setNotifCheckin(bool v) => state = state.copyWith(notifCheckin: v);
}

final onboardingProvider =
    StateNotifierProvider<OnboardingNotifier, OnboardingData>(
  (ref) => OnboardingNotifier(),
);
