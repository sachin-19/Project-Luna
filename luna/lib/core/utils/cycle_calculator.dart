import 'dart:math' as math;
import '../constants/enums.dart';

/// Pure date and cycle mathematics. Zero Flutter imports.
/// Every public function here must have a corresponding unit test.
class CycleCalculator {
  const CycleCalculator._();

  // ── Phase boundaries ───────────────────────────────────────────────────────
  // Default phase lengths (days) — overridden by user's actual data over time.
  static const int _defaultCycleLength = 28;
  static const int _menstrualLength = 5;
  static const int _follicularEnd = 13;   // days 6–13
  static const int _ovulationEnd = 16;    // days 14–16
  // Luteal: days 17–end of cycle

  /// Returns which [CyclePhase] a given [cycleDay] falls in.
  /// [cycleDay] is 1-indexed (day 1 = first day of period).
  /// [cycleLength] is the user's personal average.
  static CyclePhase phaseForDay(int cycleDay, {int cycleLength = _defaultCycleLength}) {
    assert(cycleDay >= 1, 'cycleDay must be ≥ 1');
    final day = ((cycleDay - 1) % cycleLength) + 1;
    if (day <= _menstrualLength) return CyclePhase.menstrual;
    if (day <= _follicularEnd) return CyclePhase.follicular;
    if (day <= _ovulationEnd) return CyclePhase.ovulation;
    return CyclePhase.luteal;
  }

  /// Day of the current cycle, 1-indexed.
  /// Returns null if [lastPeriodStart] is in the future.
  static int? currentCycleDay(DateTime lastPeriodStart) {
    final today = _today();
    final diff = today.difference(_dateOnly(lastPeriodStart)).inDays;
    if (diff < 0) return null;
    return diff + 1;
  }

  /// Current [CyclePhase] based on [lastPeriodStart] and [cycleLength].
  static CyclePhase currentPhase(
    DateTime lastPeriodStart, {
    int cycleLength = _defaultCycleLength,
  }) {
    final day = currentCycleDay(lastPeriodStart) ?? 1;
    return phaseForDay(day, cycleLength: cycleLength);
  }

  /// Expected start date of the next period.
  /// Always returns a date that is today or in the future — if the simple
  /// lastPeriodStart + cycleLength lands in the past (e.g. the user entered a
  /// period from several cycles ago), we advance by cycleLength until the
  /// result is upcoming.
  static DateTime predictedNextStart(
    DateTime lastPeriodStart, {
    int cycleLength = _defaultCycleLength,
  }) {
    var next = _dateOnly(lastPeriodStart).add(Duration(days: cycleLength));
    final today = _today();
    while (next.isBefore(today)) {
      next = next.add(Duration(days: cycleLength));
    }
    return next;
  }

  /// Days since the predicted period start for the current cycle.
  /// Returns 0 if today is the predicted start day.
  /// Returns positive values when the period is late.
  /// Returns negative values when the period is not yet expected.
  static int daysFromPredictedStart(
    DateTime lastPeriodStart, {
    int cycleLength = _defaultCycleLength,
  }) {
    final today = _today();
    final predicted = _dateOnly(lastPeriodStart).add(Duration(days: cycleLength));
    return today.difference(predicted).inDays;
  }

  /// Days remaining until the next predicted period start.
  static int daysUntilNextPeriod(
    DateTime lastPeriodStart, {
    int cycleLength = _defaultCycleLength,
  }) {
    final next = predictedNextStart(lastPeriodStart, cycleLength: cycleLength);
    return next.difference(_today()).inDays;
  }

  /// Approximate ovulation date: cycle_length − 14 (standard calendar method).
  static DateTime approximateOvulationDate(
    DateTime lastPeriodStart, {
    int cycleLength = _defaultCycleLength,
  }) {
    return _dateOnly(lastPeriodStart)
        .add(Duration(days: cycleLength - 14));
  }

  /// Fertile window: 5 days before ovulation + ovulation day.
  static ({DateTime start, DateTime end}) fertileWindow(
    DateTime lastPeriodStart, {
    int cycleLength = _defaultCycleLength,
  }) {
    final ovulation = approximateOvulationDate(
      lastPeriodStart,
      cycleLength: cycleLength,
    );
    return (
      start: ovulation.subtract(const Duration(days: 5)),
      end: ovulation,
    );
  }

  /// Which [CyclePhase] a specific calendar [date] falls in, given the
  /// user's [lastPeriodStart] and [cycleLength].
  static CyclePhase phaseForDate(
    DateTime date, {
    required DateTime lastPeriodStart,
    int cycleLength = _defaultCycleLength,
  }) {
    final diff = _dateOnly(date).difference(_dateOnly(lastPeriodStart)).inDays;
    if (diff < 0) {
      // Before the tracked cycle — estimate by back-projecting.
      final wrappedDay = (diff % cycleLength) + cycleLength + 1;
      return phaseForDay(wrappedDay, cycleLength: cycleLength);
    }
    final cycleDay = (diff % cycleLength) + 1;
    return phaseForDay(cycleDay, cycleLength: cycleLength);
  }

  // ── Helpers ────────────────────────────────────────────────────────────────

  /// Strip time component — all calculations are date-only.
  static DateTime _dateOnly(DateTime dt) =>
      DateTime(dt.year, dt.month, dt.day);

  static DateTime _today() {
    final now = DateTime.now();
    return DateTime(now.year, now.month, now.day);
  }
}

// ── Bayesian cycle estimator ──────────────────────────────────────────────────

/// Learns the user's personal cycle length through Bayesian Gaussian updating.
/// Start with the population prior; every completed cycle refines the estimate.
///
/// State is two doubles ([_mean], [_variance]) — trivial to persist in Hive.
class BayesianCycleEstimator {
  BayesianCycleEstimator({
    double priorMean = 28.0,
    double priorVariance = 12.25, // 3.5²
  })  : _mean = priorMean,
        _variance = priorVariance,
        _cyclesObserved = 0;

  double _mean;
  double _variance;
  int _cyclesObserved;

  int get cyclesObserved => _cyclesObserved;
  double get currentMean => _mean;

  // Assumed day-to-day logging imprecision (1.5²).
  static const double _observationVariance = 2.25;

  // PCOS/irregular prior — wider spread, longer mean.
  factory BayesianCycleEstimator.pcos() =>
      BayesianCycleEstimator(priorMean: 35.0, priorVariance: 144.0);

  /// Call once per completed cycle with the observed length in days.
  /// Returns the updated [CyclePrediction].
  CyclePrediction observe(double observedCycleLength) {
    // Guard: extreme outliers get down-weighted (robust to data entry errors).
    final sd = math.sqrt(_variance);
    final zScore = (observedCycleLength - _mean).abs() / sd;
    final effectiveObservation = zScore > 2.5
        ? _mean + (observedCycleLength > _mean ? 2.5 : -2.5) * sd
        : observedCycleLength;

    // Conjugate Gaussian update — closed form, no iteration.
    final posteriorVariance =
        1.0 / (1.0 / _variance + 1.0 / _observationVariance);
    final posteriorMean = posteriorVariance *
        (_mean / _variance + effectiveObservation / _observationVariance);

    _mean = posteriorMean;
    _variance = posteriorVariance;
    _cyclesObserved++;

    return currentPrediction();
  }

  /// Current prediction without adding a new observation.
  CyclePrediction currentPrediction() {
    final sd = math.sqrt(_variance);
    return CyclePrediction(
      expectedDays: _mean.round(),
      lowerDays: (_mean - 1.96 * sd).round().clamp(18, 90),
      upperDays: (_mean + 1.96 * sd).round().clamp(18, 90),
      cyclesObserved: _cyclesObserved,
    );
  }

  Map<String, dynamic> toJson() => {
        'mean': _mean,
        'variance': _variance,
        'observed': _cyclesObserved,
      };

  factory BayesianCycleEstimator.fromJson(Map<String, dynamic> j) {
    final e = BayesianCycleEstimator(
      priorMean: (j['mean'] as num).toDouble(),
      priorVariance: (j['variance'] as num).toDouble(),
    );
    e._cyclesObserved = j['observed'] as int;
    return e;
  }
}

// ── Prediction mode ───────────────────────────────────────────────────────────

/// Whether the prediction is from the Bayesian estimator or a fixed pill schedule.
enum PredictionMode { bayesian, fixed }

/// Output of [BayesianCycleEstimator] or the fixed-interval predictor.
class CyclePrediction {
  const CyclePrediction({
    required this.expectedDays,
    required this.lowerDays,
    required this.upperDays,
    required this.cyclesObserved,
    this.mode = PredictionMode.bayesian,
  });

  final int expectedDays;  // predicted cycle length
  final int lowerDays;     // 95% confidence lower bound
  final int upperDays;     // 95% confidence upper bound
  final int cyclesObserved;
  final PredictionMode mode;

  bool get isFixed => mode == PredictionMode.fixed;

  /// True if interval is ≤ 4 days (Bayesian learned well) or if schedule is fixed.
  bool get isConfident => isFixed || (upperDays - lowerDays) <= 4;

  /// Human-readable interval: "Jun 28 – Jul 3".
  /// For fixed-interval predictions, lower == upper so this shows a single date.
  /// Advances by elapsed cycles so the displayed interval is always upcoming.
  String intervalLabel(DateTime lastPeriodStart) {
    final now = DateTime.now();
    final todayDate = DateTime(now.year, now.month, now.day);
    final base = DateTime(lastPeriodStart.year, lastPeriodStart.month, lastPeriodStart.day);

    // How many complete cycles have elapsed since lastPeriodStart?
    final daysPassed = todayDate.difference(base).inDays;
    final cyclesElapsed = daysPassed > 0 ? (daysPassed / expectedDays).floor() : 0;

    var lower = base.add(Duration(days: cyclesElapsed * expectedDays + lowerDays));
    var upper = base.add(Duration(days: cyclesElapsed * expectedDays + upperDays));

    // Safety: handle rounding edge — ensure upper is not still in the past.
    while (upper.isBefore(todayDate)) {
      lower = lower.add(Duration(days: expectedDays));
      upper = upper.add(Duration(days: expectedDays));
    }

    if (lowerDays == upperDays) return _fmt(lower);
    return '${_fmt(lower)} – ${_fmt(upper)}';
  }

  static String _fmt(DateTime d) {
    const months = [
      '', 'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    return '${months[d.month]} ${d.day}';
  }
}
