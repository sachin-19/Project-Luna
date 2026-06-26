import 'package:luna/l10n/app_localizations.dart';
import '../constants/enums.dart';

// Localized label accessors for every domain enum.
// Each method takes an AppLocalizations instance so the enum itself stays
// Flutter/context-free. Call with context.l10n from any widget.

extension CyclePhaseL10n on CyclePhase {
  String localizedName(AppLocalizations l) => switch (this) {
        CyclePhase.menstrual => l.phaseMenstrual,
        CyclePhase.follicular => l.phaseFollicular,
        CyclePhase.ovulation => l.phaseOvulation,
        CyclePhase.luteal => l.phaseLuteal,
      };

  String localizedCopy(AppLocalizations l) => switch (this) {
        CyclePhase.menstrual => l.copyMenstrual,
        CyclePhase.follicular => l.copyFollicular,
        CyclePhase.ovulation => l.copyOvulation,
        CyclePhase.luteal => l.copyLuteal,
      };
}

extension FlowIntensityL10n on FlowIntensity {
  String localizedLabel(AppLocalizations l) => switch (this) {
        FlowIntensity.spotting => l.flowSpotting,
        FlowIntensity.light => l.flowLight,
        FlowIntensity.medium => l.flowMedium,
        FlowIntensity.heavy => l.flowHeavy,
      };
}

extension SymptomL10n on Symptom {
  String localizedLabel(AppLocalizations l) => switch (this) {
        Symptom.cramps => l.symptomCramps,
        Symptom.headache => l.symptomHeadache,
        Symptom.bloating => l.symptomBloating,
        Symptom.fatigue => l.symptomFatigue,
        Symptom.backPain => l.symptomBackPain,
        Symptom.moodSwings => l.symptomMoodSwings,
        Symptom.breastTenderness => l.symptomBreastTenderness,
        Symptom.nausea => l.symptomNausea,
        Symptom.acne => l.symptomAcne,
        Symptom.foodCravings => l.symptomFoodCravings,
        Symptom.sleepChanges => l.symptomSleepChanges,
        Symptom.spotting => l.symptomSpotting,
      };
}

extension MoodL10n on Mood {
  String localizedLabel(AppLocalizations l) => switch (this) {
        Mood.happy => l.moodHappy,
        Mood.calm => l.moodCalm,
        Mood.sad => l.moodSad,
        Mood.anxious => l.moodAnxious,
        Mood.irritable => l.moodIrritable,
        Mood.energetic => l.moodEnergetic,
      };
}
