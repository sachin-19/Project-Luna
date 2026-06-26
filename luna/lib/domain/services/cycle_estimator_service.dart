import 'dart:convert';
import 'package:hive_flutter/hive_flutter.dart';
import '../../core/constants/enums.dart';
import '../../core/utils/cycle_calculator.dart';

const _kKey = 'estimator_v2';

/// Accuracy record: absolute prediction error in days for one past cycle.
typedef _AccuracyRecord = int;

/// Persists the Bayesian estimator state, contraceptive mode, and prediction
/// accuracy history in Hive.
///
/// Call [observe] when a cycle completes.
/// Call [recordActualPeriodStart] when the user logs a new period (to track accuracy).
/// Call [setContraceptiveMethod] when the user changes their contraceptive method.
class CycleEstimatorService {
  final Box<dynamic> _box;
  late BayesianCycleEstimator _estimator;
  late ContraceptiveMethod _contraceptiveMethod;
  late int _pillCycleDays;
  late List<_AccuracyRecord> _accuracyHistory; // absolute errors (days), newest last

  CycleEstimatorService(this._box) {
    _loadAll();
  }

  // ── Getters ─────────────────────────────────────────────────────────────────

  BayesianCycleEstimator get estimator => _estimator;
  ContraceptiveMethod get contraceptiveMethod => _contraceptiveMethod;
  int get pillCycleDays => _pillCycleDays;

  /// Current prediction — fixed if on hormonal pill, Bayesian otherwise.
  CyclePrediction get currentPrediction {
    if (_contraceptiveMethod.isFixedInterval) {
      return CyclePrediction(
        expectedDays: _pillCycleDays,
        lowerDays: _pillCycleDays,
        upperDays: _pillCycleDays,
        cyclesObserved: _estimator.cyclesObserved,
        mode: PredictionMode.fixed,
      );
    }
    return _estimator.currentPrediction();
  }

  /// Accuracy stats over the stored history (max 12 cycles).
  /// [accurate] = cycles predicted within 3 days, [total] = cycles on record.
  ({int accurate, int total}) get accuracyStats {
    final total = _accuracyHistory.length;
    final accurate = _accuracyHistory.where((e) => e <= 3).length;
    return (accurate: accurate, total: total);
  }

  // ── Mutations ────────────────────────────────────────────────────────────────

  /// Switch to hormonal-pill fixed-interval mode or back to natural Bayesian.
  Future<void> setContraceptiveMethod(
    ContraceptiveMethod method, {
    int pillCycleDays = 28,
  }) async {
    _contraceptiveMethod = method;
    _pillCycleDays = pillCycleDays;
    await _saveAll();
  }

  /// Feed a completed cycle length (days) and persist.
  /// Not called for hormonal-pill users — their cycle length is fixed.
  Future<CyclePrediction> observe(double observedCycleLength) async {
    final prediction = _estimator.observe(observedCycleLength);
    await _saveAll();
    return prediction;
  }

  /// Record the accuracy of the last prediction vs the user's actual period start.
  /// Call this when the user confirms a new period on the log sheet.
  ///
  /// [predicted] — the date we expected the period to start.
  /// [actual]    — the date the user actually logged.
  Future<void> recordActualPeriodStart({
    required DateTime predicted,
    required DateTime actual,
  }) async {
    final errorDays = actual.difference(predicted).inDays.abs();
    // Keep the last 12 accuracy records.
    final updated = [..._accuracyHistory, errorDays];
    _accuracyHistory = updated.length > 12
        ? updated.sublist(updated.length - 12)
        : updated;
    await _saveAll();
  }

  /// Initialise to PCOS prior — wider variance, 35-day mean.
  Future<void> initPcos() async {
    _estimator = BayesianCycleEstimator.pcos();
    await _saveAll();
  }

  /// Reset to population prior. Pass [pcos] = true to use the PCOS prior.
  Future<void> reset({bool pcos = false}) async {
    _estimator = pcos ? BayesianCycleEstimator.pcos() : BayesianCycleEstimator();
    _accuracyHistory = [];
    await _saveAll();
  }

  // ── Persistence ──────────────────────────────────────────────────────────────

  void _loadAll() {
    final raw = _box.get(_kKey);
    if (raw is String) {
      try {
        final m = jsonDecode(raw) as Map<String, dynamic>;
        _estimator = BayesianCycleEstimator.fromJson(
          m['estimator'] as Map<String, dynamic>,
        );
        _contraceptiveMethod = ContraceptiveMethod.values.firstWhere(
          (e) => e.name == (m['contraceptive'] as String?),
          orElse: () => ContraceptiveMethod.none,
        );
        _pillCycleDays = (m['pillCycleDays'] as num?)?.toInt() ?? 28;
        _accuracyHistory = (m['accuracy'] as List<dynamic>?)
                ?.map((e) => (e as num).toInt())
                .toList() ??
            [];
        return;
      } catch (_) {
        // Fall through to defaults.
      }
    }

    // ── Legacy format migration (v1 stored estimator JSON at top level) ──────
    if (raw is String) {
      try {
        final m = jsonDecode(raw) as Map<String, dynamic>;
        if (m.containsKey('mean')) {
          _estimator = BayesianCycleEstimator.fromJson(m);
          _contraceptiveMethod = ContraceptiveMethod.none;
          _pillCycleDays = 28;
          _accuracyHistory = [];
          return;
        }
      } catch (_) {}
    }

    _estimator = BayesianCycleEstimator();
    _contraceptiveMethod = ContraceptiveMethod.none;
    _pillCycleDays = 28;
    _accuracyHistory = [];
  }

  Future<void> _saveAll() => _box.put(
        _kKey,
        jsonEncode({
          'estimator': _estimator.toJson(),
          'contraceptive': _contraceptiveMethod.name,
          'pillCycleDays': _pillCycleDays,
          'accuracy': _accuracyHistory,
        }),
      );
}
