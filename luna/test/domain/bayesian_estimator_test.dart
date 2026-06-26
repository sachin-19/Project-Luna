import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:luna/core/constants/enums.dart';
import 'package:luna/core/utils/cycle_calculator.dart';

void main() {
  group('BayesianCycleEstimator — initial state', () {
    test('starts at population prior (28 days, 0 cycles observed)', () {
      final est = BayesianCycleEstimator();
      final pred = est.currentPrediction();

      expect(pred.expectedDays, 28);
      expect(pred.cyclesObserved, 0);
    });

    test('PCOS prior starts at 35 days with wider variance', () {
      final pcos = BayesianCycleEstimator.pcos();
      final pred = pcos.currentPrediction();

      expect(pred.expectedDays, 35);
      // 95% CI should be wide at start — more than 4 days on each side
      expect((pred.upperDays - pred.lowerDays) > 4, isTrue);
    });

    test('isConfident is false before any observations', () {
      expect(BayesianCycleEstimator().currentPrediction().isConfident, isFalse);
    });

    test('mode is bayesian by default', () {
      expect(
        BayesianCycleEstimator().currentPrediction().mode,
        PredictionMode.bayesian,
      );
    });
  });

  group('BayesianCycleEstimator.observe', () {
    test('cyclesObserved increments after each observation', () {
      final est = BayesianCycleEstimator();
      est.observe(28.0);
      expect(est.cyclesObserved, 1);
      est.observe(29.0);
      expect(est.cyclesObserved, 2);
    });

    test('observing the prior mean leaves mean unchanged', () {
      final est = BayesianCycleEstimator();
      final before = est.currentMean;
      est.observe(28.0);
      expect((est.currentMean - before).abs(), lessThan(0.5));
    });

    test('repeated short cycles pulls mean below 28', () {
      final est = BayesianCycleEstimator();
      for (int i = 0; i < 10; i++) {
        est.observe(24.0);
      }
      expect(est.currentMean, lessThan(28.0));
    });

    test('repeated long cycles pushes mean above 28', () {
      final est = BayesianCycleEstimator();
      for (int i = 0; i < 10; i++) {
        est.observe(35.0);
      }
      expect(est.currentMean, greaterThan(28.0));
    });

    test('variance shrinks with more observations (estimator gains confidence)', () {
      final est = BayesianCycleEstimator();
      for (int i = 0; i < 20; i++) {
        est.observe(28.0);
      }
      final pred = est.currentPrediction();
      expect((pred.upperDays - pred.lowerDays), lessThanOrEqualTo(4));
      expect(pred.isConfident, isTrue);
    });

    test('extreme outlier is down-weighted (robust update)', () {
      final est = BayesianCycleEstimator();
      final meanBefore = est.currentMean;
      est.observe(90.0);
      final shift = (est.currentMean - meanBefore).abs();
      expect(shift, lessThan(10.0));
    });

    // ── Edge cases added in Phase 2 ──────────────────────────────────────────

    test('very short cycle (18 days) is accepted and pulls mean down', () {
      final est = BayesianCycleEstimator();
      for (int i = 0; i < 6; i++) {
        est.observe(18.0);
      }
      expect(est.currentMean, lessThan(28.0));
      expect(est.currentPrediction().lowerDays, greaterThanOrEqualTo(18));
    });

    test('very long cycle (45 days) pulls mean up but stays below 90', () {
      final est = BayesianCycleEstimator();
      for (int i = 0; i < 6; i++) {
        est.observe(45.0);
      }
      expect(est.currentMean, greaterThan(28.0));
      expect(est.currentPrediction().upperDays, lessThanOrEqualTo(90));
    });

    test('single 0-day gap observation (logging error) is handled gracefully', () {
      final est = BayesianCycleEstimator();
      // A 0-day "cycle" would be a bug in logging — z-score will be huge → capped
      expect(() => est.observe(0.0), returnsNormally);
    });

    test('PCOS branch converges on 35 with irregular but valid inputs', () {
      final pcos = BayesianCycleEstimator.pcos();
      // Irregular cycles around 35 days
      for (final len in [31.0, 42.0, 28.0, 38.0, 35.0]) {
        pcos.observe(len);
      }
      final pred = pcos.currentPrediction();
      // Mean should remain in a plausible range for PCOS
      expect(pred.expectedDays, greaterThan(25));
      expect(pred.expectedDays, lessThan(50));
    });

    test('50 consistent 28-day cycles converge to near-28', () {
      final est = BayesianCycleEstimator();
      for (int i = 0; i < 50; i++) {
        est.observe(28.0);
      }
      expect(est.currentMean, closeTo(28.0, 0.1));
      expect(est.currentPrediction().isConfident, isTrue);
    });
  });

  group('BayesianCycleEstimator — persistence (JSON round-trip)', () {
    test('toJson / fromJson preserves state exactly', () {
      final original = BayesianCycleEstimator();
      original.observe(26.0);
      original.observe(30.0);
      original.observe(27.0);

      final json = original.toJson();
      final restored = BayesianCycleEstimator.fromJson(json);

      expect(restored.cyclesObserved, original.cyclesObserved);
      expect(restored.currentMean, closeTo(original.currentMean, 0.001));
      expect(
        restored.currentPrediction().expectedDays,
        original.currentPrediction().expectedDays,
      );
    });

    test('fromJson with fresh estimator data gives correct state', () {
      final json = {'mean': 28.0, 'variance': 12.25, 'observed': 0};
      final est = BayesianCycleEstimator.fromJson(json);
      expect(est.cyclesObserved, 0);
      expect(est.currentMean, closeTo(28.0, 0.001));
    });

    test('toJson produces a JSON-serialisable map', () {
      final est = BayesianCycleEstimator();
      est.observe(28.0);
      final encoded = jsonEncode(est.toJson());
      expect(encoded, isNotEmpty);
    });
  });

  group('CyclePrediction', () {
    test('intervalLabel formats start and end dates', () {
      const pred = CyclePrediction(
        expectedDays: 28,
        lowerDays: 26,
        upperDays: 30,
        cyclesObserved: 3,
      );
      // Use a start date far enough in the past that intervalLabel advances
      // by at least one cycle. The important thing is that:
      //  • the label is non-empty
      //  • it contains a range separator (lower ≠ upper so lowerDays ≠ upperDays)
      //  • both date parts are present (contains at least one month abbreviation)
      final start = DateTime(2024, 6, 1);
      final label = pred.intervalLabel(start);
      expect(label, isNotEmpty);
      // Range: lowerDays=26 ≠ upperDays=30 → output includes ' – '
      expect(label, contains('–'));
      // Output should contain at least one three-letter month abbreviation
      final monthAbbreviations = [
        'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
        'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
      ];
      expect(monthAbbreviations.any(label.contains), isTrue);
    });

    test('intervalLabel shows single date for fixed-interval prediction', () {
      const pred = CyclePrediction(
        expectedDays: 28,
        lowerDays: 28,
        upperDays: 28,
        cyclesObserved: 0,
        mode: PredictionMode.fixed,
      );
      final start = DateTime(2024, 6, 1);
      final label = pred.intervalLabel(start);
      // Should be a single date, not a range
      expect(label.contains('–'), isFalse);
    });

    test('isConfident is true when interval ≤ 4 days', () {
      const confident = CyclePrediction(
        expectedDays: 28,
        lowerDays: 26,
        upperDays: 30,
        cyclesObserved: 5,
      );
      expect(confident.isConfident, isTrue);
    });

    test('isConfident is false when interval > 4 days', () {
      const notConfident = CyclePrediction(
        expectedDays: 28,
        lowerDays: 22,
        upperDays: 34,
        cyclesObserved: 1,
      );
      expect(notConfident.isConfident, isFalse);
    });

    test('fixed-interval prediction is always isConfident', () {
      const fixed = CyclePrediction(
        expectedDays: 28,
        lowerDays: 28,
        upperDays: 28,
        cyclesObserved: 0,
        mode: PredictionMode.fixed,
      );
      expect(fixed.isConfident, isTrue);
      expect(fixed.isFixed, isTrue);
    });

    test('lowerDays and upperDays are clamped to [18, 90]', () {
      final est = BayesianCycleEstimator.pcos();
      final pred = est.currentPrediction();
      expect(pred.lowerDays, greaterThanOrEqualTo(18));
      expect(pred.upperDays, lessThanOrEqualTo(90));
    });
  });

  group('ContraceptiveMethod', () {
    test('hormonalPill.isFixedInterval is true', () {
      expect(ContraceptiveMethod.hormonalPill.isFixedInterval, isTrue);
    });

    test('none.isFixedInterval is false', () {
      expect(ContraceptiveMethod.none.isFixedInterval, isFalse);
    });

    test('barrier uses Bayesian prediction', () {
      expect(ContraceptiveMethod.barrier.usesBayesian, isTrue);
    });

    test('hormonalIud uses Bayesian prediction (irregular cycles)', () {
      expect(ContraceptiveMethod.hormonalIud.usesBayesian, isTrue);
    });
  });
}
