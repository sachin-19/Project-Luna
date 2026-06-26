import '../core/constants/enums.dart';
import '../core/utils/cycle_calculator.dart';
import '../domain/entities/cycle_entry.dart';
import '../domain/entities/mood_log.dart';
import '../domain/entities/symptom_log.dart';
import 'insight.dart';

/// Pure-Dart symptom pattern analysis engine.
///
/// All public API is the single static [compute] function — no state, no I/O.
/// The Riverpod provider layer handles data fetching; this class only crunches
/// the numbers. Runs on an isolate in production (see Phase 2 polish task).
///
/// Minimum data thresholds before each insight type activates:
///   Phase affinity     : 3 cycles + 2 occurrences of the symptom
///   Severity trend     : 4 cycles with the symptom logged
///   Co-occurrence      : 3 days with 2+ symptoms on the same day
///   Streak alert       : 4 consecutive days of fatigue / low mood
///   Absence alert      : symptom in [commonSymptoms] not yet logged this cycle
///   Cycle comparison   : 2 completed cycles for average + 1 active cycle
class InsightEngine {
  const InsightEngine._();

  static const int _minCyclesAffinity = 3;
  static const int _minOccurrencesAffinity = 2;
  static const int _minCyclesTrend = 4;
  static const int _minCoOccurrenceDays = 3;
  static const int _streakThreshold = 4;
  static const double _affinityThreshold = 2.0; // affinity score lower bound
  static const double _trendDeltaThreshold = 0.5; // minimum severity change

  /// Compute all insights from raw domain data.
  ///
  /// [cycles]         : all cycle entries, any order — sorted internally.
  /// [symptoms]       : symptom logs, any order.
  /// [moods]          : mood logs, any order.
  /// [commonSymptoms] : symptom name strings from [User.commonSymptoms].
  /// [today]          : injectable for unit tests; defaults to [DateTime.now()].
  static List<Insight> compute({
    required List<CycleEntry> cycles,
    required List<SymptomLog> symptoms,
    required List<MoodLog> moods,
    List<String> commonSymptoms = const [],
    DateTime? today,
  }) {
    final now = today ?? DateTime.now();
    final cutoff = now.subtract(const Duration(days: 183)); // ~6 months

    final recentCycles = cycles
        .where((c) {
          final start = DateTime.tryParse(c.startDate);
          return start != null && start.isAfter(cutoff);
        })
        .toList()
      ..sort((a, b) => a.startDate.compareTo(b.startDate));

    if (recentCycles.isEmpty) return [];

    final recentSymptoms = symptoms.where((s) {
      final d = DateTime.tryParse(s.date);
      return d != null && d.isAfter(cutoff);
    }).toList();

    final recentMoods = moods.where((m) {
      final d = DateTime.tryParse(m.date);
      return d != null && d.isAfter(cutoff);
    }).toList();

    final tagged = _tagWithPhase(recentSymptoms, recentCycles);
    final insights = <Insight>[];

    if (recentCycles.length >= _minCyclesAffinity) {
      insights.addAll(_phaseAffinity(tagged, recentCycles));
    }

    if (recentCycles.length >= _minCyclesTrend) {
      insights.addAll(_severityTrend(recentSymptoms, recentCycles));
    }

    insights.addAll(_coOccurrence(tagged, recentCycles));
    insights.addAll(_streakAlert(recentSymptoms, recentMoods, now));

    final active = recentCycles.lastOrNull;
    if (active != null && active.isOngoing && commonSymptoms.isNotEmpty) {
      insights.addAll(_absenceAlert(recentSymptoms, active, commonSymptoms, now));
    }

    if (recentCycles.length >= 2) {
      final comp = _cycleComparison(recentCycles, now);
      if (comp != null) insights.add(comp);
    }

    return insights;
  }

  // ── Phase computation ────────────────────────────────────────────────────────

  static List<({SymptomLog log, CyclePhase phase})> _tagWithPhase(
    List<SymptomLog> symptoms,
    List<CycleEntry> sortedCycles,
  ) {
    final result = <({SymptomLog log, CyclePhase phase})>[];

    for (final log in symptoms) {
      final date = DateTime.tryParse(log.date);
      if (date == null) continue;

      for (final cycle in sortedCycles) {
        final start = DateTime.tryParse(cycle.startDate);
        if (start == null) continue;

        final end = cycle.endDate != null
            ? DateTime.tryParse(cycle.endDate!) ?? start.add(const Duration(days: 28))
            : DateTime.now().add(const Duration(days: 1));

        if (!date.isBefore(start) && date.isBefore(end)) {
          final cycleLen = cycle.cycleLength ?? 28;
          final phase = CycleCalculator.phaseForDate(
            date,
            lastPeriodStart: start,
            cycleLength: cycleLen,
          );
          result.add((log: log, phase: phase));
          break;
        }
      }
    }

    return result;
  }

  // ── Insight 1: Phase affinity ────────────────────────────────────────────────

  static List<Insight> _phaseAffinity(
    List<({SymptomLog log, CyclePhase phase})> tagged,
    List<CycleEntry> cycles,
  ) {
    final Map<Symptom, Map<CyclePhase, List<int>>> scores = {};

    for (final (:log, :phase) in tagged) {
      final symptom = _parseSymptom(log.symptom);
      if (symptom == null) continue;
      scores.putIfAbsent(symptom, () => {}).putIfAbsent(phase, () => []).add(log.severity);
    }

    final insights = <Insight>[];

    for (final entry in scores.entries) {
      final symptom = entry.key;
      final byPhase = entry.value;

      final total = byPhase.values.expand((v) => v).length;
      if (total < _minOccurrencesAffinity) continue;

      double maxScore = 0;
      CyclePhase? dominant;

      for (final e in byPhase.entries) {
        final count = e.value.length;
        final avgSev = e.value.reduce((a, b) => a + b) / count;
        final score = count * avgSev;
        if (score > maxScore) {
          maxScore = score;
          dominant = e.key;
        }
      }

      if (dominant == null || maxScore < _affinityThreshold) continue;
      if ((byPhase[dominant]?.length ?? 0) < _minOccurrencesAffinity) continue;

      final dominantCount = byPhase[dominant]!.length;
      final phaseName = _phaseName(dominant);

      final String body;
      if (byPhase.length == 1) {
        body = 'You only log ${symptom.label.toLowerCase()} during your $phaseName phase.';
      } else {
        final othersTotal = total - dominantCount;
        final ratio = othersTotal > 0 ? (dominantCount / (othersTotal / (byPhase.length - 1))) : double.infinity;
        final ratioText = ratio.isInfinite
            ? 'only during'
            : ratio >= 2
                ? '${ratio.toStringAsFixed(0)}× more during'
                : 'most often during';
        body = '${symptom.label} appears $ratioText your $phaseName phase.';
      }

      insights.add(Insight(
        type: InsightType.phaseAffinity,
        title: '${symptom.label} & ${dominant.displayName}',
        body: body,
        phase: dominant,
        symptom: symptom,
      ));
    }

    return insights;
  }

  // ── Insight 2: Severity trend ────────────────────────────────────────────────

  static List<Insight> _severityTrend(
    List<SymptomLog> symptoms,
    List<CycleEntry> sortedCycles,
  ) {
    // Map symptom → list of (cycleIndex, avgSeverityInThatCycle)
    final Map<Symptom, List<double>> byCycle = {};

    for (int i = 0; i < sortedCycles.length; i++) {
      final cycle = sortedCycles[i];
      final start = DateTime.tryParse(cycle.startDate);
      if (start == null) continue;

      final end = cycle.endDate != null
          ? DateTime.tryParse(cycle.endDate!) ?? start.add(const Duration(days: 28))
          : DateTime.now().add(const Duration(days: 1));

      final Map<Symptom, List<int>> inCycle = {};
      for (final s in symptoms) {
        final d = DateTime.tryParse(s.date);
        if (d == null || d.isBefore(start) || !d.isBefore(end)) continue;
        final sym = _parseSymptom(s.symptom);
        if (sym == null) continue;
        inCycle.putIfAbsent(sym, () => []).add(s.severity);
      }

      for (final e in inCycle.entries) {
        final avg = e.value.reduce((a, b) => a + b) / e.value.length;
        byCycle.putIfAbsent(e.key, () => []).add(avg);
      }
    }

    final insights = <Insight>[];

    for (final entry in byCycle.entries) {
      final symptom = entry.key;
      final avgs = entry.value;
      if (avgs.length < _minCyclesTrend) continue;

      final half = avgs.length ~/ 2;
      final firstAvg = avgs.take(half).reduce((a, b) => a + b) / half;
      final secondAvg = avgs.skip(half).reduce((a, b) => a + b) / (avgs.length - half);
      final delta = secondAvg - firstAvg;

      if (delta.abs() < _trendDeltaThreshold) continue;

      final direction = delta < 0 ? 'decreasing' : 'increasing';
      insights.add(Insight(
        type: InsightType.severityTrend,
        title: '${symptom.label} trend',
        body: 'Your ${symptom.label.toLowerCase()} severity has been $direction over the last ${avgs.length} cycles.',
        symptom: symptom,
      ));
    }

    return insights;
  }

  // ── Insight 3: Co-occurrence ─────────────────────────────────────────────────

  static List<Insight> _coOccurrence(
    List<({SymptomLog log, CyclePhase phase})> tagged,
    List<CycleEntry> cycles,
  ) {
    // Group valid symptoms by date
    final Map<String, Set<Symptom>> byDate = {};
    for (final (:log, phase: _) in tagged) {
      final sym = _parseSymptom(log.symptom);
      if (sym == null) continue;
      byDate.putIfAbsent(log.date, () => {}).add(sym);
    }

    final Map<String, int> pairCounts = {};
    for (final symptoms in byDate.values) {
      if (symptoms.length < 2) continue;
      final list = symptoms.toList()..sort((a, b) => a.index.compareTo(b.index));
      for (int i = 0; i < list.length; i++) {
        for (int j = i + 1; j < list.length; j++) {
          final key = '${list[i].name}|${list[j].name}';
          pairCounts[key] = (pairCounts[key] ?? 0) + 1;
        }
      }
    }

    final insights = <Insight>[];
    for (final entry in pairCounts.entries) {
      if (entry.value < _minCoOccurrenceDays) continue;
      final parts = entry.key.split('|');
      final a = _parseSymptom(parts[0]);
      final b = _parseSymptom(parts[1]);
      if (a == null || b == null) continue;

      insights.add(Insight(
        type: InsightType.coOccurrence,
        title: '${a.label} & ${b.label}',
        body: '${a.label} and ${b.label.toLowerCase()} often appear together for you (${entry.value} times in the last ${cycles.length} cycles).',
      ));
    }
    return insights;
  }

  // ── Insight 4: Streak alert ──────────────────────────────────────────────────

  static List<Insight> _streakAlert(
    List<SymptomLog> symptoms,
    List<MoodLog> moods,
    DateTime today,
  ) {
    final insights = <Insight>[];

    int fatigueStreak = 0;
    for (int i = 0; i < _streakThreshold; i++) {
      final date = today.subtract(Duration(days: i));
      final key = _iso(date);
      if (symptoms.any((s) => s.date == key && s.symptom == Symptom.fatigue.name)) {
        fatigueStreak++;
      }
    }

    if (fatigueStreak >= _streakThreshold) {
      insights.add(const Insight(
        type: InsightType.streakAlert,
        title: 'Low energy streak',
        body: 'You\'ve logged fatigue for $_streakThreshold days in a row. Rest is important — be kind to yourself.',
      ));
    }

    final lowMoods = {Mood.sad.name, Mood.anxious.name, Mood.irritable.name};
    int lowMoodStreak = 0;
    for (int i = 0; i < _streakThreshold; i++) {
      final date = today.subtract(Duration(days: i));
      final key = _iso(date);
      final mood = moods.where((m) => m.date == key).firstOrNull;
      if (mood != null && lowMoods.contains(mood.mood)) lowMoodStreak++;
    }

    if (lowMoodStreak >= _streakThreshold) {
      insights.add(const Insight(
        type: InsightType.streakAlert,
        title: 'Mood check-in',
        body: 'You\'ve been logging low mood for $_streakThreshold days in a row. Consider reaching out to someone you trust.',
      ));
    }

    return insights;
  }

  // ── Insight 5: Absence alert ─────────────────────────────────────────────────

  static List<Insight> _absenceAlert(
    List<SymptomLog> symptoms,
    CycleEntry activeCycle,
    List<String> commonSymptomNames,
    DateTime today,
  ) {
    final start = DateTime.tryParse(activeCycle.startDate);
    if (start == null) return [];

    final cycleDay = today.difference(start).inDays + 1;
    if (cycleDay < 5) return []; // too early to flag absence

    // Symptoms logged this cycle
    final loggedThisCycle = symptoms
        .where((s) {
          final d = DateTime.tryParse(s.date);
          return d != null && !d.isBefore(start) && !d.isAfter(today);
        })
        .map((s) => s.symptom)
        .toSet();

    return commonSymptomNames
        .where((name) => !loggedThisCycle.contains(name))
        .map((name) {
          final sym = _parseSymptom(name);
          if (sym == null) return null;
          return Insight(
            type: InsightType.absenceAlert,
            title: 'No ${sym.label.toLowerCase()} yet',
            body: 'You usually experience ${sym.label.toLowerCase()}, but haven\'t logged it this cycle yet.',
            symptom: sym,
          );
        })
        .whereType<Insight>()
        .toList();
  }

  // ── Insight 6: Cycle comparison ──────────────────────────────────────────────

  static Insight? _cycleComparison(List<CycleEntry> sortedCycles, DateTime today) {
    final active = sortedCycles.lastOrNull;
    if (active == null || !active.isOngoing) return null;

    final completed = sortedCycles.where((c) => !c.isOngoing).toList();
    if (completed.isEmpty) return null;

    final validLengths = completed.map((c) => c.cycleLength).whereType<int>().toList();
    if (validLengths.isEmpty) return null;

    final start = DateTime.tryParse(active.startDate);
    if (start == null) return null;

    final currentDays = today.difference(start).inDays + 1;
    final avg = validLengths.reduce((a, b) => a + b) / validLengths.length;
    final delta = currentDays - avg;

    if (delta.abs() < 3) return null;

    final direction = delta > 0 ? 'longer' : 'shorter';
    return Insight(
      type: InsightType.cycleComparison,
      title: 'Cycle length',
      body: 'Your current cycle is running ${delta.abs().round()} days $direction than your average (${avg.round()} days).',
    );
  }

  // ── Helpers ──────────────────────────────────────────────────────────────────

  static Symptom? _parseSymptom(String name) {
    try {
      return Symptom.values.firstWhere((e) => e.name == name);
    } catch (_) {
      return null;
    }
  }

  static String _phaseName(CyclePhase phase) =>
      phase.displayName.toLowerCase().replaceAll(' phase', '');

  static String _iso(DateTime d) =>
      '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';
}
