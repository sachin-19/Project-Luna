import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/constants/enums.dart';
import '../../core/utils/cycle_calculator.dart';
import '../../data/providers.dart';
import 'user_provider.dart';

// ── Data models ───────────────────────────────────────────────────────────────

/// One entry on the cycle-length trend chart.
class CycleLengthPoint {
  final int cycleIndex; // 1-based
  final double days;
  const CycleLengthPoint(this.cycleIndex, this.days);
}

/// Symptom frequency bucketed by phase.
class SymptomPhaseData {
  final CyclePhase phase;
  final Map<Symptom, int> counts; // symptom → total occurrences
  const SymptomPhaseData(this.phase, this.counts);
}

/// One mood entry on the current-cycle mood line.
class MoodPoint {
  final int cycleDay;
  final double energyLevel; // 1–5
  final Mood? mood;
  const MoodPoint(this.cycleDay, this.energyLevel, this.mood);
}

/// Symptom × Phase heatmap cell.
class HeatmapCell {
  final Symptom symptom;
  final CyclePhase phase;
  final double score; // 0–1 normalised
  const HeatmapCell(this.symptom, this.phase, this.score);
}

/// Phase distribution: how many total days spent in each phase.
class PhaseSlice {
  final CyclePhase phase;
  final double fraction; // 0–1 summing to 1.0
  const PhaseSlice(this.phase, this.fraction);
}

// ── Providers ─────────────────────────────────────────────────────────────────

/// Last 12 cycle lengths for the trend chart.
final cycleLengthChartProvider =
    FutureProvider.autoDispose<List<CycleLengthPoint>>((ref) async {
  final cycles = await ref.watch(cycleRepositoryProvider).getAllCycles();
  final completed = cycles
      .where((c) => c.cycleLength != null && !c.isOngoing)
      .toList()
    ..sort((a, b) => a.startDate.compareTo(b.startDate));

  return completed
      .take(12)
      .toList()
      .asMap()
      .entries
      .map((e) => CycleLengthPoint(e.key + 1, (e.value.cycleLength!).toDouble()))
      .toList();
});

/// Symptom occurrences grouped by cycle phase over the last 6 months.
final symptomPhaseChartProvider =
    FutureProvider.autoDispose<List<SymptomPhaseData>>((ref) async {
  final cycleRepo = ref.watch(cycleRepositoryProvider);
  final symptomRepo = ref.watch(symptomRepositoryProvider);
  final user = ref.watch(userStreamProvider).valueOrNull;

  final now = DateTime.now();
  final cutoff = now.subtract(const Duration(days: 183));
  final startStr = _iso(cutoff);
  final endStr = _iso(now.add(const Duration(days: 1)));

  final cycles = await cycleRepo.getAllCycles();
  final symptoms = await symptomRepo.getSymptomsForRange(startStr, endStr);
  final cycleLen = user?.avgCycleDays ?? 28;

  final Map<CyclePhase, Map<Symptom, int>> counts = {
    for (final p in CyclePhase.values) p: {},
  };

  for (final s in symptoms) {
    final date = DateTime.tryParse(s.date);
    if (date == null) continue;
    final sym = _parseSymptom(s.symptom);
    if (sym == null) continue;

    // Find the cycle this date belongs to
    for (final cycle in cycles) {
      final start = DateTime.tryParse(cycle.startDate);
      if (start == null) continue;
      final end = cycle.endDate != null
          ? DateTime.tryParse(cycle.endDate!)!
          : now.add(const Duration(days: 1));
      if (!date.isBefore(start) && date.isBefore(end)) {
        final phase = CycleCalculator.phaseForDate(
          date,
          lastPeriodStart: start,
          cycleLength: cycle.cycleLength ?? cycleLen,
        );
        counts[phase]![sym] = (counts[phase]![sym] ?? 0) + 1;
        break;
      }
    }
  }

  return CyclePhase.values
      .map((p) => SymptomPhaseData(p, counts[p]!))
      .toList();
});

/// Mood and energy per cycle day for the current active cycle.
final moodChartProvider =
    FutureProvider.autoDispose<List<MoodPoint>>((ref) async {
  final cycleRepo = ref.watch(cycleRepositoryProvider);
  final moodRepo = ref.watch(moodRepositoryProvider);

  final activeCycle = await cycleRepo.getAllCycles()
      .then((c) => c.where((x) => x.isOngoing).firstOrNull);
  if (activeCycle == null) return [];

  final start = DateTime.tryParse(activeCycle.startDate);
  if (start == null) return [];

  final now = DateTime.now();
  final endStr = _iso(now.add(const Duration(days: 1)));
  final moods = await moodRepo.getMoodsForRange(activeCycle.startDate, endStr);

  return moods.map((m) {
    final date = DateTime.tryParse(m.date);
    if (date == null) return null;
    final day = date.difference(start).inDays + 1;
    Mood? mood;
    try {
      mood = Mood.values.firstWhere((e) => e.name == m.mood);
    } catch (_) {}
    return MoodPoint(day, m.energyLevel.toDouble(), mood);
  }).whereType<MoodPoint>().toList()
    ..sort((a, b) => a.cycleDay.compareTo(b.cycleDay));
});

/// Symptom × phase heatmap — normalised scores for all phase/symptom combos.
final symptomHeatmapProvider =
    FutureProvider.autoDispose<List<HeatmapCell>>((ref) async {
  final data = await ref.watch(symptomPhaseChartProvider.future);

  // Flatten all counts and normalise to 0–1
  double maxCount = 0;
  for (final d in data) {
    for (final c in d.counts.values) {
      if (c > maxCount) maxCount = c.toDouble();
    }
  }

  if (maxCount == 0) return [];

  final cells = <HeatmapCell>[];
  for (final d in data) {
    for (final entry in d.counts.entries) {
      if (entry.value == 0) continue;
      cells.add(HeatmapCell(entry.key, d.phase, entry.value / maxCount));
    }
  }
  return cells;
});

/// Phase distribution: percentage of all tracked days in each phase.
final phaseDistributionProvider =
    FutureProvider.autoDispose<List<PhaseSlice>>((ref) async {
  final cycles = await ref.watch(cycleRepositoryProvider).getAllCycles();
  final user = ref.watch(userStreamProvider).valueOrNull;
  final cycleLen = user?.avgCycleDays ?? 28;

  final Map<CyclePhase, int> dayCount = {
    for (final p in CyclePhase.values) p: 0,
  };

  for (final cycle in cycles) {
    final start = DateTime.tryParse(cycle.startDate);
    if (start == null) continue;
    final length = cycle.cycleLength ?? cycleLen;
    for (int d = 1; d <= length; d++) {
      final phase = CycleCalculator.phaseForDay(d, cycleLength: length);
      dayCount[phase] = dayCount[phase]! + 1;
    }
  }

  final total = dayCount.values.fold(0, (a, b) => a + b);
  if (total == 0) return [];

  return CyclePhase.values
      .map((p) => PhaseSlice(p, dayCount[p]! / total))
      .toList();
});

// ── Helpers ───────────────────────────────────────────────────────────────────

String _iso(DateTime d) =>
    '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';

Symptom? _parseSymptom(String name) {
  try {
    return Symptom.values.firstWhere((e) => e.name == name);
  } catch (_) {
    return null;
  }
}
