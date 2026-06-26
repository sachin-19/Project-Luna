import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../ai/ai_insights_cache.dart';
import '../../ai/claude_chat.dart';
import '../../core/constants/enums.dart';
import '../../core/constants/feature_flags.dart';
import '../../data/database/app_database.dart';
import '../../data/database/database_provider.dart';
import '../../data/providers.dart';
import '../../domain/usecases/get_ai_insight.dart';
import '../../domain/usecases/get_phase_tips.dart';

export '../../domain/usecases/get_phase_tips.dart' show Tip, PhaseTips;
export '../../domain/usecases/get_ai_insight.dart' show PersonalizedTip, PersonalizedTips;

// ── Static tip provider (unchanged) ─────────────────────────────────────────

/// Loads tips for [phase] from the bundled JSON, rotating by current cycle day.
/// Day 1 of the cycle → tip #1, day 2 → tip #2, etc.
final phaseTipsProvider = FutureProvider.autoDispose
    .family<PhaseTips, CyclePhase>((ref, phase) async {
  final jsonStr = await rootBundle.loadString('assets/data/phase_tips.json');
  final data = jsonDecode(jsonStr) as Map<String, dynamic>;

  final db = ref.read(databaseProvider);
  final cycles = await db.cycleDao.getAllCycles();

  return const GetPhaseTips().execute(data, phase,
      cycleNumber: _currentCycleDayIndex(cycles));
});

// ── Personalized tip provider ─────────────────────────────────────────────

/// Returns personalized tips for [phase], using Claude when [kClaudeEnabled],
/// falling back to offline symptom-based selection.
///
/// Flow:
///   1. Check AiInsightsCache for this phase + cycle number.
///   2. Cache hit → return immediately.
///   3. Cache miss + kClaudeEnabled → call ClaudeChatService.
///      On success → store in cache → return personalized.
///      On failure → fall through to step 4.
///   4. Offline fallback: GetAiInsight.selectBySymptoms() using recent symptoms.
final personalizedTipsProvider = FutureProvider.autoDispose
    .family<PersonalizedTips, CyclePhase>((ref, phase) async {
  final jsonStr = await rootBundle.loadString('assets/data/phase_tips.json');
  final data = jsonDecode(jsonStr) as Map<String, dynamic>;

  final db = ref.read(databaseProvider);
  final cycles = await db.cycleDao.getAllCycles();
  final cycleNumber = _currentCycleDayIndex(cycles);

  // Build tip lookup map for cache restoration
  final phaseKey = _phaseKey(phase);
  final rawList = (data[phaseKey] as List).cast<Map<String, dynamic>>();
  final tipById = {
    for (final t in rawList)
      t['id'] as String: Tip(
        id: t['id'] as String,
        text: t['text'] as String,
        category: t['category'] as String,
      ),
  };

  final cacheKey = AiInsightsCache.buildKey(phaseKey, cycleNumber);

  // 1. Cache check
  final cached = AiInsightsCache.get(cacheKey, tipById);
  if (cached != null) {
    return PersonalizedTips(
      phase: phase,
      tips: cached,
      isPersonalized: cached.any((t) => t.why != null),
    );
  }

  // Evict stale cache entries from previous cycles
  await AiInsightsCache.evictStale(cacheKey);

  // Fetch recent symptoms (last 14 days) for offline scoring / Claude prompt
  final now = DateTime.now();
  final cutoff = now.subtract(const Duration(days: 14));
  final symptomRepo = ref.read(symptomRepositoryProvider);
  final recentLogs = await symptomRepo.getSymptomsForRange(
    _iso(cutoff),
    _iso(now.add(const Duration(days: 1))),
  );
  final recentSymptoms = recentLogs
      .map((s) {
        try {
          return Symptom.values.firstWhere((e) => e.name == s.symptom);
        } catch (_) {
          return null;
        }
      })
      .whereType<Symptom>()
      .toSet()
      .toList();

  // 2. Claude path (only when flag is on)
  if (kClaudeEnabled) {
    final tipSummaries = tipById.entries
        .take(30) // keep prompt compact
        .map((e) => {'id': e.key, 'text': e.value.text.substring(0, e.value.text.length.clamp(0, 80))})
        .toList();

    final claudeItems = await const ClaudeChatService().personalisePhraseTips(
      phase: phase,
      tipSummaries: tipSummaries,
      recentSymptoms: recentSymptoms.map((s) => s.name).toList(),
    );

    if (claudeItems.isNotEmpty) {
      final result = const GetAiInsight().fromClaudeResponse(
        phase: phase,
        json: data,
        claudeItems: claudeItems,
      );
      await AiInsightsCache.set(cacheKey, result.tips);
      return result;
    }
  }

  // 3. Offline fallback
  final fallback = const GetAiInsight().selectBySymptoms(
    data,
    phase,
    recentSymptoms,
    cycleNumber: cycleNumber,
  );
  // Cache the static result too — avoids recomputing on every rebuild
  await AiInsightsCache.set(cacheKey, fallback.tips);
  return fallback;
});

// ── Helpers ──────────────────────────────────────────────────────────────────

/// Returns a 0-indexed day offset from the start of the most recent cycle.
/// Day 1 of cycle → 0, day 2 → 1, etc.
/// Used so "Today's tip" badge aligns with the cycle day shown on the home screen.
/// [cycles] is assumed to be sorted DESC by startDate (as returned by getAllCycles()).
int _currentCycleDayIndex(List<CycleEntryRow> cycles) {
  if (cycles.isEmpty) return 0;
  final start = DateTime.parse(cycles.first.startDate);
  final today = DateTime.now();
  final diff = DateTime(today.year, today.month, today.day)
      .difference(DateTime(start.year, start.month, start.day))
      .inDays;
  return diff < 0 ? 0 : diff;
}

String _phaseKey(CyclePhase phase) => switch (phase) {
      CyclePhase.menstrual => 'menstrual',
      CyclePhase.follicular => 'follicular',
      CyclePhase.ovulation => 'ovulation',
      CyclePhase.luteal => 'luteal',
    };

String _iso(DateTime d) =>
    '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';
