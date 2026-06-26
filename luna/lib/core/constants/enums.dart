import 'package:flutter/material.dart';

// ── Cycle ────────────────────────────────────────────────────────────────────

enum CyclePhase { menstrual, follicular, ovulation, luteal }

extension CyclePhaseTokens on CyclePhase {
  // Seed color fed into ColorScheme.fromSeed — drives the entire M3 palette.
  Color get seedColor => switch (this) {
        CyclePhase.menstrual => const Color(0xFFE53E6A),
        CyclePhase.follicular => const Color(0xFFF97316),
        CyclePhase.ovulation => const Color(0xFF10B981),
        CyclePhase.luteal => const Color(0xFF8B5CF6),
      };

  // ── Dark mode surfaces ───────────────────────────────────────────────────

  Color get darkBackground => switch (this) {
        CyclePhase.menstrual => const Color(0xFF1A0810),
        CyclePhase.follicular => const Color(0xFF1A1005),
        CyclePhase.ovulation => const Color(0xFF071A13),
        CyclePhase.luteal => const Color(0xFF130D20),
      };

  Color get darkSurface => switch (this) {
        CyclePhase.menstrual => const Color(0xFF2D1220),
        CyclePhase.follicular => const Color(0xFF2D1F08),
        CyclePhase.ovulation => const Color(0xFF0D2B22),
        CyclePhase.luteal => const Color(0xFF1E1433),
      };

  Color get darkSurfaceRaised => switch (this) {
        CyclePhase.menstrual => const Color(0xFF3D1C30),
        CyclePhase.follicular => const Color(0xFF3D2D10),
        CyclePhase.ovulation => const Color(0xFF153D30),
        CyclePhase.luteal => const Color(0xFF261A3F),
      };

  Color get darkOnSurface => switch (this) {
        CyclePhase.menstrual => const Color(0xFFF8EEF2),
        CyclePhase.follicular => const Color(0xFFFEF3E8),
        CyclePhase.ovulation => const Color(0xFFECFDF8),
        CyclePhase.luteal => const Color(0xFFF0EBF8),
      };

  Color get darkOnSurfaceVariant => switch (this) {
        CyclePhase.menstrual => const Color(0xFF9B6878),
        CyclePhase.follicular => const Color(0xFF9B7858),
        CyclePhase.ovulation => const Color(0xFF4A9080),
        CyclePhase.luteal => const Color(0xFF9080B0),
      };

  // ── Light mode surfaces ──────────────────────────────────────────────────

  Color get lightBackground => switch (this) {
        CyclePhase.menstrual => const Color(0xFFFFF5F7),
        CyclePhase.follicular => const Color(0xFFFFFBF2),
        CyclePhase.ovulation => const Color(0xFFF0FDF9),
        CyclePhase.luteal => const Color(0xFFF9F5FF),
      };

  Color get lightSurface => switch (this) {
        CyclePhase.menstrual => const Color(0xFFFFE8EE),
        CyclePhase.follicular => const Color(0xFFFFF0D9),
        CyclePhase.ovulation => const Color(0xFFD1FAF0),
        CyclePhase.luteal => const Color(0xFFEDE9FF),
      };

  Color get lightSurfaceRaised => switch (this) {
        CyclePhase.menstrual => const Color(0xFFFDDDE6),
        CyclePhase.follicular => const Color(0xFFFFE8C4),
        CyclePhase.ovulation => const Color(0xFFBBFAE6),
        CyclePhase.luteal => const Color(0xFFE0D9FF),
      };

  Color get lightOnSurface => switch (this) {
        CyclePhase.menstrual => const Color(0xFF1A0010),
        CyclePhase.follicular => const Color(0xFF1A0F00),
        CyclePhase.ovulation => const Color(0xFF001A10),
        CyclePhase.luteal => const Color(0xFF15002A),
      };

  Color get lightOnSurfaceVariant => switch (this) {
        CyclePhase.menstrual => const Color(0xFF7A3050),
        CyclePhase.follicular => const Color(0xFF7A4520),
        CyclePhase.ovulation => const Color(0xFF1A5040),
        CyclePhase.luteal => const Color(0xFF4A2070),
      };

  // ── Gradient pairs (cycle wheel + hero backgrounds) ─────────────────────

  Color get gradientStart => seedColor;

  Color gradientEnd(Brightness brightness) => switch (this) {
        CyclePhase.menstrual => brightness == Brightness.dark
            ? const Color(0xFF9B1B4A)
            : const Color(0xFFC2185B),
        CyclePhase.follicular => brightness == Brightness.dark
            ? const Color(0xFFDC6803)
            : const Color(0xFFEA6C00),
        CyclePhase.ovulation => brightness == Brightness.dark
            ? const Color(0xFF047857)
            : const Color(0xFF00897B),
        CyclePhase.luteal => brightness == Brightness.dark
            ? const Color(0xFF6D28D9)
            : const Color(0xFF7B1FA2),
      };

  // ── Display strings ──────────────────────────────────────────────────────

  String get displayName => switch (this) {
        CyclePhase.menstrual => 'Menstrual Phase',
        CyclePhase.follicular => 'Follicular Phase',
        CyclePhase.ovulation => 'Ovulation Phase',
        CyclePhase.luteal => 'Luteal Phase',
      };

  String get motivationalCopy => switch (this) {
        CyclePhase.menstrual => 'Rest. Your body is doing powerful work.',
        CyclePhase.follicular => 'Energy is building. A good time to start things.',
        CyclePhase.ovulation => 'You\'re at your peak. Make the most of it.',
        CyclePhase.luteal => 'Wind down gently. Nourish yourself.',
      };

  String get lottieAsset => switch (this) {
        CyclePhase.menstrual => 'assets/lottie/menstrual.json',
        CyclePhase.follicular => 'assets/lottie/follicular.json',
        CyclePhase.ovulation => 'assets/lottie/ovulation.json',
        CyclePhase.luteal => 'assets/lottie/luteal.json',
      };
}

// ── Logging ───────────────────────────────────────────────────────────────────

enum FlowIntensity { spotting, light, medium, heavy }

extension FlowIntensityLabel on FlowIntensity {
  String get label => switch (this) {
        FlowIntensity.spotting => 'Spotting',
        FlowIntensity.light => 'Light',
        FlowIntensity.medium => 'Medium',
        FlowIntensity.heavy => 'Heavy',
      };

  String get dbValue => name;
}

enum Symptom {
  cramps,
  headache,
  bloating,
  fatigue,
  backPain,
  moodSwings,
  breastTenderness,
  nausea,
  acne,
  foodCravings,
  sleepChanges,
  spotting,
}

extension SymptomLabel on Symptom {
  String get label => switch (this) {
        Symptom.cramps => 'Cramps',
        Symptom.headache => 'Headache',
        Symptom.bloating => 'Bloating',
        Symptom.fatigue => 'Fatigue',
        Symptom.backPain => 'Back Pain',
        Symptom.moodSwings => 'Mood Swings',
        Symptom.breastTenderness => 'Breast Tenderness',
        Symptom.nausea => 'Nausea',
        Symptom.acne => 'Acne',
        Symptom.foodCravings => 'Food Cravings',
        Symptom.sleepChanges => 'Sleep Changes',
        Symptom.spotting => 'Spotting',
      };

  String get emoji => switch (this) {
        Symptom.cramps => '🌊',
        Symptom.headache => '🤕',
        Symptom.bloating => '🫧',
        Symptom.fatigue => '😴',
        Symptom.backPain => '🔙',
        Symptom.moodSwings => '🎭',
        Symptom.breastTenderness => '💗',
        Symptom.nausea => '🤢',
        Symptom.acne => '✨',
        Symptom.foodCravings => '🍫',
        Symptom.sleepChanges => '🌙',
        Symptom.spotting => '🩸',
      };

  String get dbValue => name;
}

enum Mood { happy, calm, sad, anxious, irritable, energetic }

extension MoodLabel on Mood {
  String get label => switch (this) {
        Mood.happy => 'Happy',
        Mood.calm => 'Calm',
        Mood.sad => 'Sad',
        Mood.anxious => 'Anxious',
        Mood.irritable => 'Irritable',
        Mood.energetic => 'Energetic',
      };

  String get emoji => switch (this) {
        Mood.happy => '😊',
        Mood.calm => '😌',
        Mood.sad => '😢',
        Mood.anxious => '😰',
        Mood.irritable => '😤',
        Mood.energetic => '⚡',
      };

  String get dbValue => name;
}

// ── Contraception ─────────────────────────────────────────────────────────────

/// How the user manages contraception — drives which prediction algorithm is used.
/// Hormonal pill → fixed-interval mode (deterministic). All others → Bayesian.
enum ContraceptiveMethod {
  none,         // natural cycles
  hormonalPill, // combined/progestogen-only pill — fixed pill-schedule interval
  barrier,      // condoms, diaphragm — natural cycles
  copperIud,    // non-hormonal IUD — natural cycles
  hormonalIud,  // Mirena / implant — may suppress periods; treated as irregular Bayesian
  other,
}

extension ContraceptiveMethodLabel on ContraceptiveMethod {
  /// Whether this method should use the fixed-interval predictor.
  bool get isFixedInterval => this == ContraceptiveMethod.hormonalPill;

  /// Whether natural (Bayesian) prediction applies.
  bool get usesBayesian => !isFixedInterval;
}

// ── Reproductive status ───────────────────────────────────────────────────────

/// The user's current reproductive phase. Drives which Bayesian prior is used
/// at onboarding. PCOS (tracked separately via hasPcos) takes precedence.
enum ReproductiveStatus {
  normal,
  tryingToConceive,
  pregnant,
  postpartum,
  breastfeeding,
  perimenopause,
}

// ── Update system ─────────────────────────────────────────────────────────────

enum UpdateStatus { idle, checking, available, downloading, readyToInstall, error }
