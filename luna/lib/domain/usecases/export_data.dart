import 'dart:convert';
import '../entities/cycle_entry.dart';
import '../entities/mood_log.dart';
import '../entities/symptom_log.dart';
import '../entities/user.dart';

/// Output of [ExportDataUseCase].
class ExportResult {
  const ExportResult({required this.jsonString, required this.csvString});

  /// Full JSON dump of all user data.
  final String jsonString;

  /// CSV of cycle history only — start date, end date, cycle length, period length.
  final String csvString;
}

/// Pure Dart use case — no Flutter imports.
///
/// Assembles user data into export-ready strings. The caller (ExportService)
/// is responsible for writing files and triggering the share sheet.
class ExportDataUseCase {
  const ExportDataUseCase();

  ExportResult execute({
    required User user,
    required List<CycleEntry> cycles,
    required List<SymptomLog> symptoms,
    required List<MoodLog> moods,
    required DateTime exportedAt,
  }) {
    return ExportResult(
      jsonString: _buildJson(user, cycles, symptoms, moods, exportedAt),
      csvString: _buildCsv(cycles),
    );
  }

  // ── JSON ────────────────────────────────────────────────────────────────

  String _buildJson(
    User user,
    List<CycleEntry> cycles,
    List<SymptomLog> symptoms,
    List<MoodLog> moods,
    DateTime exportedAt,
  ) {
    final doc = {
      'exportedAt': exportedAt.toIso8601String(),
      'version': '1.0',
      'user': _userToJson(user),
      'cycles': cycles.map(_cycleToJson).toList(),
      'symptoms': symptoms.map(_symptomToJson).toList(),
      'moods': moods.map(_moodToJson).toList(),
    };
    return const JsonEncoder.withIndent('  ').convert(doc);
  }

  Map<String, dynamic> _userToJson(User u) => {
        'displayName': u.displayName,
        'birthYear': u.birthYear,
        'avgCycleDays': u.avgCycleDays,
        'avgPeriodDays': u.avgPeriodDays,
        'hasPcos': u.hasPcos,
        'hasEndo': u.hasEndo,
        'trackingGoals': u.trackingGoals,
        'commonSymptoms': u.commonSymptoms,
        'preferredLanguage': u.preferredLanguage,
      };

  Map<String, dynamic> _cycleToJson(CycleEntry c) => {
        'startDate': c.startDate,
        'endDate': c.endDate,
        'cycleLength': c.cycleLength,
        'periodLength': c.periodLength,
        'isSeeded': c.isSeeded,
        if (c.notes?.isNotEmpty == true) 'notes': c.notes,
      };

  Map<String, dynamic> _symptomToJson(SymptomLog s) => {
        'date': s.date,
        'symptom': s.symptom,
        'severity': s.severity,
        if (s.notes?.isNotEmpty == true) 'notes': s.notes,
      };

  Map<String, dynamic> _moodToJson(MoodLog m) => {
        'date': m.date,
        'mood': m.mood,
        'energyLevel': m.energyLevel,
        if (m.notes?.isNotEmpty == true) 'notes': m.notes,
      };

  // ── CSV ────────────────────────────────────────────────────────────────

  String _buildCsv(List<CycleEntry> cycles) {
    final buf = StringBuffer();
    buf.writeln('Start Date,End Date,Cycle Length (days),Period Length (days),Seeded');

    for (final c in cycles) {
      final endDate = c.endDate ?? '';
      final cycleLen = c.cycleLength?.toString() ?? '';
      final periodLen = c.periodLength?.toString() ?? '';
      final seeded = c.isSeeded ? 'yes' : 'no';
      buf.writeln('${c.startDate},$endDate,$cycleLen,$periodLen,$seeded');
    }

    return buf.toString();
  }
}
