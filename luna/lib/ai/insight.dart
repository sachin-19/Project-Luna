import '../core/constants/enums.dart';

enum InsightType {
  phaseAffinity,  // symptom appears more in one phase
  severityTrend,  // symptom getting better or worse over time
  coOccurrence,   // two symptoms often appear together
  streakAlert,    // low energy / bad mood for N days in a row
  absenceAlert,   // usual symptom hasn't appeared this cycle
  cycleComparison, // current cycle is longer/shorter than average
}

/// A computed insight surfaced to the user on the Home and Insights screens.
///
/// Text is English; l10n keys will replace [title] and [body] in a later pass.
class Insight {
  const Insight({
    required this.type,
    required this.title,
    required this.body,
    this.phase,
    this.symptom,
  });

  final InsightType type;
  final String title;   // short headline: "Headaches & Luteal Phase"
  final String body;    // one-line explanation shown in the card
  final CyclePhase? phase;   // associated phase (for phaseAffinity)
  final Symptom? symptom;    // associated symptom (for symptom-specific types)
}
