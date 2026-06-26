import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../ai/insight.dart';
import '../../ai/insight_engine.dart';
import '../../data/providers.dart';
import '../../domain/entities/cycle_entry.dart';
import '../../domain/entities/mood_log.dart';
import '../../domain/entities/symptom_log.dart';
import 'user_provider.dart';

/// Computes insights over the last 6 months of data.
/// Runs on a background isolate via [compute] to keep the UI thread free.
final insightsProvider = FutureProvider.autoDispose<List<Insight>>((ref) async {
  final cycleRepo = ref.watch(cycleRepositoryProvider);
  final symptomRepo = ref.watch(symptomRepositoryProvider);
  final moodRepo = ref.watch(moodRepositoryProvider);
  final user = ref.watch(userStreamProvider).valueOrNull;

  final now = DateTime.now();
  final sixMonthsAgo = now.subtract(const Duration(days: 183));
  final startStr = _iso(sixMonthsAgo);
  final endStr = _iso(now.add(const Duration(days: 1)));

  final cycles = await cycleRepo.getAllCycles();
  final symptoms = await symptomRepo.getSymptomsForRange(startStr, endStr);
  final moods = await moodRepo.getMoodsForRange(startStr, endStr);

  // Offload CPU-intensive computation to a background isolate.
  return compute(
    _runInsightEngine,
    _InsightParams(
      cycles: cycles,
      symptoms: symptoms,
      moods: moods,
      commonSymptoms: user?.commonSymptoms ?? [],
      today: now,
    ),
  );
});

// ── Isolate entry point ───────────────────────────────────────────────────────

/// Top-level function required by [compute] (no closures allowed).
List<Insight> _runInsightEngine(_InsightParams params) {
  return InsightEngine.compute(
    cycles: params.cycles,
    symptoms: params.symptoms,
    moods: params.moods,
    commonSymptoms: params.commonSymptoms,
    today: params.today,
  );
}

/// Sendable parameter bundle for the isolate.
class _InsightParams {
  const _InsightParams({
    required this.cycles,
    required this.symptoms,
    required this.moods,
    required this.commonSymptoms,
    required this.today,
  });

  final List<CycleEntry> cycles;
  final List<SymptomLog> symptoms;
  final List<MoodLog> moods;
  final List<String> commonSymptoms;
  final DateTime today;
}

// ── Helper ────────────────────────────────────────────────────────────────────

String _iso(DateTime d) =>
    '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';
