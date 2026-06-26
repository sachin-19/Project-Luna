import '../../core/constants/enums.dart';
import 'get_phase_tips.dart';

/// A [Tip] with an optional personalisation snippet added by Claude.
class PersonalizedTip {
  const PersonalizedTip({required this.tip, this.why});

  final Tip tip;

  /// One-sentence Claude-generated "why this tip fits you right now" snippet.
  /// Null when running in offline / static mode.
  final String? why;
}

/// Result of personalisation — 3 tips selected for the current phase.
class PersonalizedTips {
  const PersonalizedTips({
    required this.phase,
    required this.tips,
    required this.isPersonalized,
  });

  final CyclePhase phase;
  final List<PersonalizedTip> tips;

  /// True when Claude selected + annotated these tips; false = static fallback.
  final bool isPersonalized;

  PersonalizedTip get current => tips.isNotEmpty ? tips.first : throw StateError('No tips');
}

/// Pure-Dart use case — no Flutter imports.
///
/// Selects the 3 most relevant phase tips for the user's recent symptoms
/// using a category-affinity score. Used as the offline fallback when
/// [kClaudeEnabled] is false or Claude is unreachable.
class GetAiInsight {
  const GetAiInsight();

  PersonalizedTips selectBySymptoms(
    Map<String, dynamic> json,
    CyclePhase phase,
    List<Symptom> recentSymptoms, {
    int cycleNumber = 0,
  }) {
    final key = _phaseKey(phase);
    final rawList = (json[key] as List).cast<Map<String, dynamic>>();
    final tips = rawList
        .map((t) => Tip(
              id: t['id'] as String,
              text: t['text'] as String,
              category: t['category'] as String,
            ))
        .toList();

    if (tips.isEmpty) {
      return PersonalizedTips(phase: phase, tips: [], isPersonalized: false);
    }

    final scored = tips.map((t) => (tip: t, score: _score(t, recentSymptoms))).toList();

    // Sort: highest score first; ties broken by rotating with cycleNumber
    final indexed = scored.asMap().entries.toList()
      ..sort((a, b) {
        final diff = b.value.score.compareTo(a.value.score);
        if (diff != 0) return diff;
        // Rotation tie-break: advance index by cycleNumber so each cycle surfaces different tips
        return ((a.key + cycleNumber) % tips.length)
            .compareTo((b.key + cycleNumber) % tips.length);
      });

    final selected = indexed
        .take(3)
        .map((e) => PersonalizedTip(tip: e.value.tip))
        .toList();

    return PersonalizedTips(phase: phase, tips: selected, isPersonalized: false);
  }

  /// Constructs [PersonalizedTips] from tip IDs + Claude-generated snippets.
  /// Called by the presentation layer after a successful Claude response.
  PersonalizedTips fromClaudeResponse({
    required CyclePhase phase,
    required Map<String, dynamic> json,
    required List<Map<String, String>> claudeItems, // [{id, why}, ...]
  }) {
    final key = _phaseKey(phase);
    final rawList = (json[key] as List).cast<Map<String, dynamic>>();
    final tipById = {
      for (final t in rawList)
        t['id'] as String: Tip(
          id: t['id'] as String,
          text: t['text'] as String,
          category: t['category'] as String,
        ),
    };

    final selected = claudeItems
        .where((item) => tipById.containsKey(item['id']))
        .take(3)
        .map((item) => PersonalizedTip(
              tip: tipById[item['id']]!,
              why: item['why']?.isNotEmpty == true ? item['why'] : null,
            ))
        .toList();

    if (selected.isEmpty) return PersonalizedTips(phase: phase, tips: [], isPersonalized: false);

    return PersonalizedTips(phase: phase, tips: selected, isPersonalized: true);
  }

  // ── Scoring ───────────────────────────────────────────────────────────────

  static int _score(Tip tip, List<Symptom> symptoms) {
    if (symptoms.isEmpty) return 0;
    final affinities = symptoms.expand((s) => _categoryAffinity[s] ?? []).toSet();
    return affinities.contains(tip.category) ? 1 : 0;
  }

  /// Symptom → preferred tip categories for offline ranking.
  static const Map<Symptom, List<String>> _categoryAffinity = {
    Symptom.cramps: ['wellness', 'nutrition'],
    Symptom.fatigue: ['nutrition', 'self_care'],
    Symptom.bloating: ['nutrition', 'wellness'],
    Symptom.headache: ['wellness', 'nutrition'],
    Symptom.moodSwings: ['mood', 'self_care'],
    Symptom.backPain: ['exercise', 'wellness'],
    Symptom.nausea: ['nutrition', 'wellness'],
    Symptom.sleepChanges: ['self_care', 'wellness'],
    Symptom.foodCravings: ['nutrition'],
    Symptom.acne: ['nutrition', 'wellness'],
    Symptom.breastTenderness: ['self_care', 'wellness'],
    Symptom.spotting: ['wellness'],
  };

  static String _phaseKey(CyclePhase phase) => switch (phase) {
        CyclePhase.menstrual => 'menstrual',
        CyclePhase.follicular => 'follicular',
        CyclePhase.ovulation => 'ovulation',
        CyclePhase.luteal => 'luteal',
      };
}
