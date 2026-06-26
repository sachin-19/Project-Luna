import 'dart:convert';
import 'package:hive_flutter/hive_flutter.dart';
import '../domain/usecases/get_ai_insight.dart';
import '../domain/usecases/get_phase_tips.dart';

/// Hive-backed cache for Claude-personalised tip selections.
///
/// Cache key: `'$phaseKey:$cycleNumber'`
/// Cache value: JSON list — [{id: String, why: String?}, ...]
/// TTL: entries are keyed by cycle number, so they expire naturally when
/// the user's cycle count increments.
class AiInsightsCache {
  static const _boxName = 'ai_cache';

  static Box<dynamic> get _box => Hive.box<dynamic>(_boxName);

  /// Returns the cached [PersonalizedTips] for this key, or null on cache miss.
  static List<PersonalizedTip>? get(String cacheKey, Map<String, Tip> tipById) {
    final raw = _box.get(cacheKey);
    if (raw == null) return null;

    try {
      final list = (jsonDecode(raw as String) as List).cast<Map<String, dynamic>>();
      final result = list
          .where((item) => tipById.containsKey(item['id']))
          .map((item) => PersonalizedTip(
                tip: tipById[item['id']]!,
                why: item['why'] as String?,
              ))
          .toList();
      return result.isEmpty ? null : result;
    } catch (_) {
      return null;
    }
  }

  /// Stores [tips] under [cacheKey].
  static Future<void> set(String cacheKey, List<PersonalizedTip> tips) async {
    final payload = jsonEncode(tips
        .map((t) => {'id': t.tip.id, 'why': t.why})
        .toList());
    await _box.put(cacheKey, payload);
  }

  /// Evicts all cache entries not matching the current [activeCacheKey].
  /// Called on phase transition to keep the box lean.
  static Future<void> evictStale(String activeCacheKey) async {
    final staleKeys = _box.keys.where((k) => k != activeCacheKey).toList();
    for (final k in staleKeys) {
      await _box.delete(k);
    }
  }

  static String buildKey(String phaseKey, int cycleNumber) =>
      '$phaseKey:$cycleNumber';
}
