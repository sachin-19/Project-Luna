import 'package:drift/drift.dart' show Value;
import 'package:flutter/foundation.dart' show debugPrint;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/constants/enums.dart';
import '../../data/database/app_database.dart';
import '../../data/database/database_provider.dart';
import 'cycle_provider.dart';
import 'insight_provider.dart';

// ── State ─────────────────────────────────────────────────────────────────────

class LogState {
  final FlowIntensity? flow;
  final Map<Symptom, int> symptoms; // symptom → severity 1–5
  final Set<Symptom> autoSymptoms;  // pre-filled from profile, not yet confirmed
  final Mood? mood;
  final int energyLevel; // 1–5
  final String notes;
  final bool isSaving;
  final bool saved;

  const LogState({
    this.flow,
    this.symptoms = const {},
    this.autoSymptoms = const {},
    this.mood,
    this.energyLevel = 3,
    this.notes = '',
    this.isSaving = false,
    this.saved = false,
  });

  LogState copyWith({
    FlowIntensity? flow,
    bool clearFlow = false,
    Map<Symptom, int>? symptoms,
    Set<Symptom>? autoSymptoms,
    Mood? mood,
    bool clearMood = false,
    int? energyLevel,
    String? notes,
    bool? isSaving,
    bool? saved,
  }) {
    return LogState(
      flow: clearFlow ? null : (flow ?? this.flow),
      symptoms: symptoms ?? this.symptoms,
      autoSymptoms: autoSymptoms ?? this.autoSymptoms,
      mood: clearMood ? null : (mood ?? this.mood),
      energyLevel: energyLevel ?? this.energyLevel,
      notes: notes ?? this.notes,
      isSaving: isSaving ?? this.isSaving,
      saved: saved ?? this.saved,
    );
  }

  bool get hasAnyData {
    final hasExplicitSymptom =
        symptoms.keys.any((s) => !autoSymptoms.contains(s));
    return flow != null || hasExplicitSymptom || mood != null;
  }
}

// ── Notifier ──────────────────────────────────────────────────────────────────

class LogNotifier extends StateNotifier<LogState> {
  LogNotifier(this._ref, this._date) : super(const LogState());

  final Ref _ref;
  final DateTime _date;

  void initCommonSymptoms(List<String> commonSymptoms) {
    final initial = <Symptom, int>{};
    for (final s in commonSymptoms) {
      try {
        initial[Symptom.values.byName(s)] = 1;
      } catch (_) {}
    }
    if (initial.isNotEmpty && state.symptoms.isEmpty) {
      // Mark these as auto-populated — they won't be saved unless the user
      // explicitly interacts with them (toggles or changes severity).
      state = state.copyWith(
        symptoms: initial,
        autoSymptoms: initial.keys.toSet(),
      );
    }
  }

  void initFromExisting({
    FlowIntensity? flow,
    Map<Symptom, int> symptoms = const {},
    Mood? mood,
    int energyLevel = 3,
    String notes = '',
  }) {
    state = LogState(
      flow: flow,
      symptoms: Map<Symptom, int>.from(symptoms),
      mood: mood,
      energyLevel: energyLevel,
      notes: notes,
    );
  }

  /// Loads any existing logs for [_date] from the DB and pre-populates state.
  Future<void> loadExistingForDate() async {
    final db = _ref.read(databaseProvider);
    final dateStr = _dateIso(_date);

    final periodRows = await db.cycleDao.getPeriodDaysForRange(dateStr, dateStr);
    final moodRows = await db.moodDao.getMoodsForRange(dateStr, dateStr);
    final symptomRows = await db.symptomDao.getSymptomsForRange(dateStr, dateStr);

    final periodDay = periodRows.isNotEmpty ? periodRows.first : null;
    final moodRow = moodRows.isNotEmpty ? moodRows.first : null;

    final symptoms = <Symptom, int>{};
    for (final r in symptomRows) {
      try {
        symptoms[Symptom.values.byName(r.symptom)] = r.severity;
      } catch (_) {}
    }

    FlowIntensity? flow;
    if (periodDay != null) {
      try {
        flow = FlowIntensity.values.byName(periodDay.flow);
      } catch (_) {
        flow = FlowIntensity.medium;
      }
    }

    Mood? mood;
    if (moodRow != null) {
      try {
        mood = Mood.values.byName(moodRow.mood);
      } catch (_) {
        mood = Mood.calm;
      }
    }

    if (!mounted) return;
    state = LogState(
      flow: flow,
      symptoms: symptoms,
      mood: mood,
      energyLevel: moodRow?.energyLevel ?? 3,
      notes: moodRow?.notes ?? '',
    );
  }

  void setFlow(FlowIntensity flow) => state = state.copyWith(flow: flow);
  void clearFlow() => state = state.copyWith(clearFlow: true);

  void setSeverity(Symptom symptom, int severity) {
    // Explicit severity change — remove from auto set so it gets saved.
    final updatedAuto = Set<Symptom>.from(state.autoSymptoms)..remove(symptom);
    state = state.copyWith(
      symptoms: {...state.symptoms, symptom: severity},
      autoSymptoms: updatedAuto,
    );
  }

  void toggleSymptom(Symptom symptom) {
    final updated = Map<Symptom, int>.from(state.symptoms);
    if (updated.containsKey(symptom)) {
      updated.remove(symptom);
    } else {
      updated[symptom] = 3;
    }
    // Explicit tap — remove from auto set regardless of add/remove direction.
    final updatedAuto = Set<Symptom>.from(state.autoSymptoms)..remove(symptom);
    state = state.copyWith(symptoms: updated, autoSymptoms: updatedAuto);
  }

  void setMood(Mood mood) => state = state.copyWith(mood: mood);
  void clearMood() => state = state.copyWith(clearMood: true);

  void setEnergy(int level) => state = state.copyWith(energyLevel: level);

  void setNotes(String notes) => state = state.copyWith(notes: notes);

  /// Saves any pending flow for today, counts logged period days, then closes
  /// the active cycle with today as the end date.
  Future<bool> endPeriod() async {
    final cycle = _ref.read(activeCycleProvider).valueOrNull;
    if (cycle == null) return false;
    try {
      final db = _ref.read(databaseProvider);
      final dateStr = _dateIso(_date);

      // Save today's flow first if the user selected one.
      if (state.flow != null) {
        await db.cycleDao.upsertPeriodDay(
          PeriodDayLogsTableCompanion.insert(
            cycleEntryId: cycle.id,
            date: dateStr,
            flow: state.flow!.dbValue,
          ),
        );
      }

      // Use actual logged days for periodLength — more accurate than date math.
      final periodDays = await db.cycleDao.getPeriodDaysForCycle(cycle.id);
      await db.cycleDao.updateCycleEnd(cycle.id, dateStr, periodDays.length);

      _ref.invalidate(insightsProvider);
      return true;
    } catch (e, s) {
      debugPrint('[LogNotifier.endPeriod] $e\n$s');
      return false;
    }
  }

  Future<bool> save() async {
    final cycle = _ref.read(activeCycleProvider).valueOrNull;
    if (!state.hasAnyData) return true;

    state = state.copyWith(isSaving: true);

    try {
      final db = _ref.read(databaseProvider);
      final dateStr = _dateIso(_date);
      final nowMs = DateTime.now().millisecondsSinceEpoch;

      await db.transaction(() async {
        // ── Period day ────────────────────────────────────────────────────
        if (state.flow != null && cycle != null) {
          await db.cycleDao.upsertPeriodDay(
            PeriodDayLogsTableCompanion.insert(
              cycleEntryId: cycle.id,
              date: dateStr,
              flow: state.flow!.dbValue,
            ),
          );
        }

        // ── Symptoms ──────────────────────────────────────────────────────
        for (final entry in state.symptoms.entries) {
          // Skip auto-populated suggestions the user never explicitly touched.
          if (state.autoSymptoms.contains(entry.key)) continue;
          await db.symptomDao.upsertSymptom(
            SymptomLogsTableCompanion.insert(
              date: dateStr,
              symptom: entry.key.dbValue,
              severity: entry.value,
              notes: Value(state.notes.isEmpty ? null : state.notes),
              createdAt: nowMs,
            ),
          );
        }

        // ── Mood ──────────────────────────────────────────────────────────
        if (state.mood != null) {
          await db.moodDao.upsertMood(
            MoodLogsTableCompanion.insert(
              date: dateStr,
              mood: state.mood!.dbValue,
              energyLevel: state.energyLevel,
              notes: Value(state.notes.isEmpty ? null : state.notes),
              createdAt: nowMs,
            ),
          );
        }
      });

      state = state.copyWith(isSaving: false, saved: true);
      _ref.invalidate(insightsProvider);
      return true;
    } catch (e, s) {
      debugPrint('[LogNotifier.save] $e\n$s');
      state = state.copyWith(isSaving: false);
      return false;
    }
  }

  static String _dateIso(DateTime date) {
    return '${date.year.toString().padLeft(4, '0')}-'
        '${date.month.toString().padLeft(2, '0')}-'
        '${date.day.toString().padLeft(2, '0')}';
  }
}

// ── Provider ──────────────────────────────────────────────────────────────────

// Parameterised by the date being logged (normalised to midnight).
// Each unique date gets its own auto-disposed instance.
final logNotifierProvider = StateNotifierProvider.autoDispose
    .family<LogNotifier, LogState, DateTime>(
  (ref, date) => LogNotifier(ref, date),
);
