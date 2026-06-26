import 'dart:convert';
import 'package:http/http.dart' as http;
import '../core/constants/enums.dart';
import '../core/constants/feature_flags.dart';

/// Calls the Firebase Cloud Function proxy for Claude-powered features.
///
/// All public methods are no-ops when [kClaudeEnabled] is false —
/// callers always get an empty result and fall through to the static fallback.
///
/// When deploying:
///   1. Set the CF region + project in [_baseUrl].
///   2. Deploy `functions/src/personalise.js` (tip-selection endpoint).
///   3. Set kClaudeEnabled = true in feature_flags.dart.
class ClaudeChatService {
  const ClaudeChatService();

  // Replace with the actual deployed CF URL once Firebase project is set up.
  static const String _baseUrl =
      'https://us-central1-luna-app-placeholder.cloudfunctions.net';

  static const Duration _timeout = Duration(seconds: 12);

  /// Asks Claude to select and annotate the 3 most relevant tips for the user.
  ///
  /// [phase] — current cycle phase label (e.g. "luteal")
  /// [tipSummaries] — compact list of {id, text} objects from the local JSON
  ///   (keep under 3 000 chars to stay within token budget)
  /// [recentSymptoms] — symptom names from the last 14 days
  ///
  /// Returns a list of `{id, why}` maps, or empty list on any error.
  Future<List<Map<String, String>>> personalisePhraseTips({
    required CyclePhase phase,
    required List<Map<String, String>> tipSummaries,
    required List<String> recentSymptoms,
  }) async {
    if (!kClaudeEnabled) return [];

    try {
      final response = await http
          .post(
            Uri.parse('$_baseUrl/personalisePhraseTips'),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({
              'data': {
                'phase': _phaseLabel(phase),
                'tipSummaries': tipSummaries,
                'symptoms': recentSymptoms,
              },
            }),
          )
          .timeout(_timeout);

      if (response.statusCode != 200) return [];

      final body = jsonDecode(response.body) as Map<String, dynamic>;
      final result = body['result'];
      if (result == null) return [];

      return (result as List)
          .cast<Map<String, dynamic>>()
          .map((item) => {
                'id': (item['id'] as String?) ?? '',
                'why': (item['why'] as String?) ?? '',
              })
          .where((item) => item['id']!.isNotEmpty)
          .toList();
    } catch (_) {
      // Network error, timeout, parse error — silently fall through to static.
      return [];
    }
  }

  static String _phaseLabel(CyclePhase phase) => switch (phase) {
        CyclePhase.menstrual => 'menstrual',
        CyclePhase.follicular => 'follicular',
        CyclePhase.ovulation => 'ovulation',
        CyclePhase.luteal => 'luteal',
      };
}
