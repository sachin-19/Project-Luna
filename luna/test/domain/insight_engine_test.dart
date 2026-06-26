import 'package:flutter_test/flutter_test.dart';
import 'package:luna/ai/insight.dart';
import 'package:luna/ai/insight_engine.dart';
import 'package:luna/core/constants/enums.dart';
import 'package:luna/domain/entities/cycle_entry.dart';
import 'package:luna/domain/entities/mood_log.dart';
import 'package:luna/domain/entities/symptom_log.dart';

// ── Test data helpers ─────────────────────────────────────────────────────────

CycleEntry cycle({
  required int id,
  required String startDate,
  String? endDate,
  int? cycleLength,
}) =>
    CycleEntry(
      id: id,
      startDate: startDate,
      endDate: endDate,
      cycleLength: cycleLength,
      createdAt: 0,
    );

SymptomLog symptom({
  required int id,
  required String date,
  required Symptom symptom,
  int severity = 3,
}) =>
    SymptomLog(
      id: id,
      date: date,
      symptom: symptom.name,
      severity: severity,
      createdAt: 0,
    );

MoodLog mood({
  required int id,
  required String date,
  required Mood mood,
  int energyLevel = 3,
}) =>
    MoodLog(
      id: id,
      date: date,
      mood: mood.name,
      energyLevel: energyLevel,
      createdAt: 0,
    );

// Fixed "today" used by all tests so results are deterministic
final _today = DateTime(2025, 6, 20);

void main() {
  // ── Empty / threshold guards ───────────────────────────────────────────────

  group('InsightEngine — empty input', () {
    test('returns empty list when no cycles', () {
      final result = InsightEngine.compute(
        cycles: [],
        symptoms: [],
        moods: [],
        today: _today,
      );
      expect(result, isEmpty);
    });

    test('returns empty when only one cycle and no symptoms', () {
      final result = InsightEngine.compute(
        cycles: [cycle(id: 1, startDate: '2025-05-23', endDate: '2025-06-19', cycleLength: 27)],
        symptoms: [],
        moods: [],
        today: _today,
      );
      expect(result, isEmpty);
    });
  });

  // ── Phase affinity ─────────────────────────────────────────────────────────

  group('InsightEngine — phase affinity', () {
    test('emits phase affinity insight when symptom appears ≥2× in one phase over 3+ cycles', () {
      // 3 cycles, each with cramps on Day 1 (menstrual phase)
      final cycles = [
        cycle(id: 1, startDate: '2025-01-01', endDate: '2025-01-29', cycleLength: 28),
        cycle(id: 2, startDate: '2025-01-29', endDate: '2025-02-26', cycleLength: 28),
        cycle(id: 3, startDate: '2025-02-26', endDate: '2025-03-26', cycleLength: 28),
      ];
      // Day 1 of each cycle → menstrual phase
      final symptoms = [
        symptom(id: 1, date: '2025-01-01', symptom: Symptom.cramps, severity: 4),
        symptom(id: 2, date: '2025-01-29', symptom: Symptom.cramps, severity: 3),
        symptom(id: 3, date: '2025-02-26', symptom: Symptom.cramps, severity: 5),
      ];

      final result = InsightEngine.compute(
        cycles: cycles, symptoms: symptoms, moods: [], today: _today,
      );

      final affinity = result.where((i) => i.type == InsightType.phaseAffinity).toList();
      expect(affinity, isNotEmpty);
      expect(affinity.first.symptom, Symptom.cramps);
      expect(affinity.first.phase, CyclePhase.menstrual);
    });

    test('does NOT emit phase affinity when fewer than 3 cycles', () {
      final cycles = [
        cycle(id: 1, startDate: '2025-05-01', endDate: '2025-05-29', cycleLength: 28),
        cycle(id: 2, startDate: '2025-05-29', endDate: '2025-06-19', cycleLength: 21),
      ];
      final symptoms = [
        symptom(id: 1, date: '2025-05-01', symptom: Symptom.cramps, severity: 4),
        symptom(id: 2, date: '2025-05-29', symptom: Symptom.cramps, severity: 4),
      ];

      final result = InsightEngine.compute(
        cycles: cycles, symptoms: symptoms, moods: [], today: _today,
      );

      final affinity = result.where((i) => i.type == InsightType.phaseAffinity);
      expect(affinity, isEmpty);
    });

    test('does NOT emit phase affinity when symptom appears only once', () {
      final cycles = [
        cycle(id: 1, startDate: '2025-01-01', endDate: '2025-01-29', cycleLength: 28),
        cycle(id: 2, startDate: '2025-01-29', endDate: '2025-02-26', cycleLength: 28),
        cycle(id: 3, startDate: '2025-02-26', endDate: '2025-06-19', cycleLength: 112),
      ];
      // Only 1 cramp log → below minOccurrencesAffinity
      final symptoms = [
        symptom(id: 1, date: '2025-01-01', symptom: Symptom.cramps, severity: 3),
      ];

      final result = InsightEngine.compute(
        cycles: cycles, symptoms: symptoms, moods: [], today: _today,
      );

      final affinity = result.where((i) => i.type == InsightType.phaseAffinity);
      expect(affinity, isEmpty);
    });
  });

  // ── Severity trend ─────────────────────────────────────────────────────────

  group('InsightEngine — severity trend', () {
    test('emits decreasing trend when symptom severity drops over 4+ cycles', () {
      final cycles = [
        cycle(id: 1, startDate: '2025-01-01', endDate: '2025-01-29', cycleLength: 28),
        cycle(id: 2, startDate: '2025-01-29', endDate: '2025-02-26', cycleLength: 28),
        cycle(id: 3, startDate: '2025-02-26', endDate: '2025-03-26', cycleLength: 28),
        cycle(id: 4, startDate: '2025-03-26', endDate: '2025-04-23', cycleLength: 28),
      ];
      final symptoms = [
        symptom(id: 1, date: '2025-01-01', symptom: Symptom.cramps, severity: 5),
        symptom(id: 2, date: '2025-01-29', symptom: Symptom.cramps, severity: 4),
        symptom(id: 3, date: '2025-02-26', symptom: Symptom.cramps, severity: 2),
        symptom(id: 4, date: '2025-03-26', symptom: Symptom.cramps, severity: 1),
      ];

      final result = InsightEngine.compute(
        cycles: cycles, symptoms: symptoms, moods: [], today: _today,
      );

      final trend = result.where((i) => i.type == InsightType.severityTrend).toList();
      expect(trend, isNotEmpty);
      expect(trend.first.title, contains('trend'));
      expect(trend.first.body, contains('decreasing'));
    });

    test('emits increasing trend when symptom severity rises over 4+ cycles', () {
      final cycles = List.generate(
        4,
        (i) => cycle(
          id: i + 1,
          startDate: '2025-0${i + 1}-01',
          endDate: '2025-0${i + 1}-29',
          cycleLength: 28,
        ),
      );
      final symptoms = [
        symptom(id: 1, date: '2025-01-01', symptom: Symptom.headache, severity: 1),
        symptom(id: 2, date: '2025-02-01', symptom: Symptom.headache, severity: 2),
        symptom(id: 3, date: '2025-03-01', symptom: Symptom.headache, severity: 4),
        symptom(id: 4, date: '2025-04-01', symptom: Symptom.headache, severity: 5),
      ];

      final result = InsightEngine.compute(
        cycles: cycles, symptoms: symptoms, moods: [], today: _today,
      );

      final trend = result.where((i) =>
          i.type == InsightType.severityTrend && i.body.contains('increasing'));
      expect(trend, isNotEmpty);
    });

    test('does NOT emit trend when fewer than 4 cycles', () {
      final cycles = [
        cycle(id: 1, startDate: '2025-04-01', endDate: '2025-04-29', cycleLength: 28),
        cycle(id: 2, startDate: '2025-04-29', endDate: '2025-05-27', cycleLength: 28),
        cycle(id: 3, startDate: '2025-05-27', endDate: '2025-06-19', cycleLength: 23),
      ];
      final symptoms = [
        symptom(id: 1, date: '2025-04-01', symptom: Symptom.cramps, severity: 5),
        symptom(id: 2, date: '2025-04-29', symptom: Symptom.cramps, severity: 3),
        symptom(id: 3, date: '2025-05-27', symptom: Symptom.cramps, severity: 1),
      ];

      final result = InsightEngine.compute(
        cycles: cycles, symptoms: symptoms, moods: [], today: _today,
      );

      expect(result.where((i) => i.type == InsightType.severityTrend), isEmpty);
    });
  });

  // ── Co-occurrence ──────────────────────────────────────────────────────────

  group('InsightEngine — co-occurrence', () {
    test('emits co-occurrence when 2 symptoms appear together ≥3 times', () {
      final cycles = [
        cycle(id: 1, startDate: '2025-02-01', endDate: '2025-06-19', cycleLength: 28),
      ];
      // fatigue + moodSwings together on 3 days
      final symptoms = [
        symptom(id: 1, date: '2025-02-10', symptom: Symptom.fatigue),
        symptom(id: 2, date: '2025-02-10', symptom: Symptom.moodSwings),
        symptom(id: 3, date: '2025-02-20', symptom: Symptom.fatigue),
        symptom(id: 4, date: '2025-02-20', symptom: Symptom.moodSwings),
        symptom(id: 5, date: '2025-03-05', symptom: Symptom.fatigue),
        symptom(id: 6, date: '2025-03-05', symptom: Symptom.moodSwings),
      ];

      final result = InsightEngine.compute(
        cycles: cycles, symptoms: symptoms, moods: [], today: _today,
      );

      final co = result.where((i) => i.type == InsightType.coOccurrence).toList();
      expect(co, isNotEmpty);
      expect(co.first.title, contains('Fatigue'));
      expect(co.first.title, contains('Mood Swings'));
    });

    test('does NOT emit co-occurrence when pair appears fewer than 3 times', () {
      final cycles = [
        cycle(id: 1, startDate: '2025-03-01', endDate: '2025-06-19', cycleLength: 28),
      ];
      final symptoms = [
        symptom(id: 1, date: '2025-03-10', symptom: Symptom.fatigue),
        symptom(id: 2, date: '2025-03-10', symptom: Symptom.bloating),
        symptom(id: 3, date: '2025-03-20', symptom: Symptom.fatigue),
        symptom(id: 4, date: '2025-03-20', symptom: Symptom.bloating),
      ];

      final result = InsightEngine.compute(
        cycles: cycles, symptoms: symptoms, moods: [], today: _today,
      );

      expect(result.where((i) => i.type == InsightType.coOccurrence), isEmpty);
    });
  });

  // ── Streak alert ───────────────────────────────────────────────────────────

  group('InsightEngine — streak alert', () {
    test('emits fatigue streak alert after 4 consecutive fatigue days', () {
      // Log fatigue on today and 3 days before today
      final cycles = [
        cycle(id: 1, startDate: '2025-06-01', cycleLength: 28),
      ];
      final symptoms = List.generate(
        4,
        (i) => symptom(
          id: i + 1,
          date: _iso(_today.subtract(Duration(days: i))),
          symptom: Symptom.fatigue,
        ),
      );

      final result = InsightEngine.compute(
        cycles: cycles, symptoms: symptoms, moods: [], today: _today,
      );

      final streak = result.where((i) =>
          i.type == InsightType.streakAlert && i.title.contains('energy'));
      expect(streak, isNotEmpty);
    });

    test('emits low-mood streak after 4 consecutive low-mood days', () {
      final cycles = [
        cycle(id: 1, startDate: '2025-06-01', cycleLength: 28),
      ];
      final moods = List.generate(
        4,
        (i) => mood(
          id: i + 1,
          date: _iso(_today.subtract(Duration(days: i))),
          mood: Mood.sad,
        ),
      );

      final result = InsightEngine.compute(
        cycles: cycles, symptoms: [], moods: moods, today: _today,
      );

      final streak = result.where((i) =>
          i.type == InsightType.streakAlert &&
          i.title.toLowerCase().contains('mood'));
      expect(streak, isNotEmpty);
    });

    test('does NOT emit streak for only 3 days', () {
      final cycles = [cycle(id: 1, startDate: '2025-06-01', cycleLength: 28)];
      final symptoms = List.generate(
        3,
        (i) => symptom(
          id: i + 1,
          date: _iso(_today.subtract(Duration(days: i))),
          symptom: Symptom.fatigue,
        ),
      );

      final result = InsightEngine.compute(
        cycles: cycles, symptoms: symptoms, moods: [], today: _today,
      );

      expect(result.where((i) => i.type == InsightType.streakAlert), isEmpty);
    });
  });

  // ── Absence alert ──────────────────────────────────────────────────────────

  group('InsightEngine — absence alert', () {
    test('emits absence alert when commonSymptom not logged in current cycle (day 5+)', () {
      // Active cycle started 10 days ago
      final cycleStart = _iso(_today.subtract(const Duration(days: 10)));
      final cycles = [cycle(id: 1, startDate: cycleStart)];

      final result = InsightEngine.compute(
        cycles: cycles,
        symptoms: [], // nothing logged this cycle
        moods: [],
        commonSymptoms: [Symptom.cramps.name],
        today: _today,
      );

      final absence = result.where((i) => i.type == InsightType.absenceAlert);
      expect(absence, isNotEmpty);
    });

    test('does NOT emit absence alert on cycle day < 5', () {
      final cycleStart = _iso(_today.subtract(const Duration(days: 3)));
      final cycles = [cycle(id: 1, startDate: cycleStart)];

      final result = InsightEngine.compute(
        cycles: cycles,
        symptoms: [],
        moods: [],
        commonSymptoms: [Symptom.cramps.name],
        today: _today,
      );

      expect(result.where((i) => i.type == InsightType.absenceAlert), isEmpty);
    });

    test('does NOT emit absence alert when symptom already logged this cycle', () {
      final cycleStart = _iso(_today.subtract(const Duration(days: 10)));
      final cycles = [cycle(id: 1, startDate: cycleStart)];
      final symptoms = [
        symptom(id: 1, date: _iso(_today.subtract(const Duration(days: 8))),
            symptom: Symptom.cramps),
      ];

      final result = InsightEngine.compute(
        cycles: cycles,
        symptoms: symptoms,
        moods: [],
        commonSymptoms: [Symptom.cramps.name],
        today: _today,
      );

      expect(result.where((i) => i.type == InsightType.absenceAlert), isEmpty);
    });
  });

  // ── Cycle comparison ───────────────────────────────────────────────────────

  group('InsightEngine — cycle comparison', () {
    test('emits cycle comparison when current cycle is 3+ days longer than average', () {
      final completedStart = _iso(_today.subtract(const Duration(days: 60)));
      final completedEnd = _iso(_today.subtract(const Duration(days: 32)));
      final currentStart = _iso(_today.subtract(const Duration(days: 32)));

      final cycles = [
        // Completed 28-day cycle
        cycle(id: 1, startDate: completedStart, endDate: completedEnd, cycleLength: 28),
        // Active cycle running for 32 days (4 days over average)
        cycle(id: 2, startDate: currentStart),
      ];

      final result = InsightEngine.compute(
        cycles: cycles, symptoms: [], moods: [], today: _today,
      );

      final comp = result.where((i) => i.type == InsightType.cycleComparison).toList();
      expect(comp, isNotEmpty);
      expect(comp.first.body, contains('longer'));
    });

    test('does NOT emit cycle comparison when delta < 3 days', () {
      final completedStart = _iso(_today.subtract(const Duration(days: 56)));
      final completedEnd = _iso(_today.subtract(const Duration(days: 28)));
      final currentStart = _iso(_today.subtract(const Duration(days: 28)));

      final cycles = [
        cycle(id: 1, startDate: completedStart, endDate: completedEnd, cycleLength: 28),
        // Active: 28 days = same as average, delta = 0
        cycle(id: 2, startDate: currentStart),
      ];

      final result = InsightEngine.compute(
        cycles: cycles, symptoms: [], moods: [], today: _today,
      );

      expect(result.where((i) => i.type == InsightType.cycleComparison), isEmpty);
    });

    test('does NOT emit cycle comparison with only 1 cycle', () {
      final cycles = [cycle(id: 1, startDate: '2025-06-01')];

      final result = InsightEngine.compute(
        cycles: cycles, symptoms: [], moods: [], today: _today,
      );

      expect(result.where((i) => i.type == InsightType.cycleComparison), isEmpty);
    });
  });

  // ── Edge cases ─────────────────────────────────────────────────────────────

  group('InsightEngine — edge cases', () {
    test('ignores cycles older than 6 months', () {
      final oldStart = _iso(_today.subtract(const Duration(days: 400)));
      final oldEnd = _iso(_today.subtract(const Duration(days: 372)));
      final cycles = [
        cycle(id: 1, startDate: oldStart, endDate: oldEnd, cycleLength: 28),
      ];

      final result = InsightEngine.compute(
        cycles: cycles,
        symptoms: [
          symptom(id: 1, date: oldStart, symptom: Symptom.cramps),
        ],
        moods: [],
        today: _today,
      );

      expect(result, isEmpty);
    });

    test('handles invalid date strings without throwing', () {
      final cycles = [
        cycle(id: 1, startDate: '2025-06-01', cycleLength: 28),
        cycle(id: 2, startDate: 'not-a-date', cycleLength: 28),
      ];

      expect(
        () => InsightEngine.compute(
          cycles: cycles,
          symptoms: [
            symptom(id: 1, date: 'also-invalid', symptom: Symptom.cramps),
          ],
          moods: [],
          today: _today,
        ),
        returnsNormally,
      );
    });

    test('handles empty moods list without throwing', () {
      final cycles = [cycle(id: 1, startDate: '2025-06-01', cycleLength: 28)];

      expect(
        () => InsightEngine.compute(
          cycles: cycles, symptoms: [], moods: [], today: _today,
        ),
        returnsNormally,
      );
    });
  });
}

// ── Helper ────────────────────────────────────────────────────────────────────

String _iso(DateTime d) =>
    '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';
