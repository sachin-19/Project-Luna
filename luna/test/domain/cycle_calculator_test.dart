import 'package:flutter_test/flutter_test.dart';
import 'package:luna/core/constants/enums.dart';
import 'package:luna/core/utils/cycle_calculator.dart';

void main() {
  group('CycleCalculator.phaseForDay', () {
    test('day 1 is menstrual', () {
      expect(CycleCalculator.phaseForDay(1), CyclePhase.menstrual);
    });

    test('day 5 is menstrual (last menstrual day)', () {
      expect(CycleCalculator.phaseForDay(5), CyclePhase.menstrual);
    });

    test('day 6 is follicular', () {
      expect(CycleCalculator.phaseForDay(6), CyclePhase.follicular);
    });

    test('day 13 is follicular (last follicular day)', () {
      expect(CycleCalculator.phaseForDay(13), CyclePhase.follicular);
    });

    test('day 14 is ovulation', () {
      expect(CycleCalculator.phaseForDay(14), CyclePhase.ovulation);
    });

    test('day 16 is ovulation (last ovulation day)', () {
      expect(CycleCalculator.phaseForDay(16), CyclePhase.ovulation);
    });

    test('day 17 is luteal', () {
      expect(CycleCalculator.phaseForDay(17), CyclePhase.luteal);
    });

    test('day 28 is luteal (last day of default cycle)', () {
      expect(CycleCalculator.phaseForDay(28), CyclePhase.luteal);
    });

    test('day 29 wraps to menstrual (day 1 of next cycle)', () {
      expect(CycleCalculator.phaseForDay(29), CyclePhase.menstrual);
    });

    test('respects custom cycle length', () {
      // With a 35-day cycle, day 20 is still luteal (17+)
      expect(
        CycleCalculator.phaseForDay(20, cycleLength: 35),
        CyclePhase.luteal,
      );
    });
  });

  group('CycleCalculator.currentCycleDay', () {
    test('returns 1 when lastPeriodStart is today', () {
      final today = DateTime.now();
      final result = CycleCalculator.currentCycleDay(
        DateTime(today.year, today.month, today.day),
      );
      expect(result, 1);
    });

    test('returns null when lastPeriodStart is in the future', () {
      final tomorrow = DateTime.now().add(const Duration(days: 1));
      expect(CycleCalculator.currentCycleDay(tomorrow), isNull);
    });

    test('returns correct day for 5 days ago', () {
      final fiveDaysAgo = DateTime.now().subtract(const Duration(days: 5));
      final result = CycleCalculator.currentCycleDay(fiveDaysAgo);
      expect(result, 6);
    });

    test('ignores time component — only date matters', () {
      final today = DateTime.now();
      final todayAtMidnight = DateTime(today.year, today.month, today.day);
      final todayAtNoon = DateTime(today.year, today.month, today.day, 12);
      expect(
        CycleCalculator.currentCycleDay(todayAtMidnight),
        CycleCalculator.currentCycleDay(todayAtNoon),
      );
    });
  });

  group('CycleCalculator.predictedNextStart', () {
    test('result is always today or in the future', () {
      final longAgo = DateTime.now().subtract(const Duration(days: 90));
      final next = CycleCalculator.predictedNextStart(longAgo, cycleLength: 28);
      final today = DateTime.now();
      final todayDate = DateTime(today.year, today.month, today.day);
      expect(next.isBefore(todayDate), isFalse);
    });

    test('period started yesterday — next is 27 days from now', () {
      final yesterday = DateTime.now().subtract(const Duration(days: 1));
      final next = CycleCalculator.predictedNextStart(yesterday, cycleLength: 28);
      final expected = DateTime.now().add(const Duration(days: 27));
      expect(next.year, expected.year);
      expect(next.month, expected.month);
      expect(next.day, expected.day);
    });

    test('period far in the past — next is within one cycleLength of today', () {
      final longAgo = DateTime.now().subtract(const Duration(days: 60));
      final next = CycleCalculator.predictedNextStart(longAgo, cycleLength: 28);
      final today = DateTime.now();
      final todayDate = DateTime(today.year, today.month, today.day);
      final daysAway = next.difference(todayDate).inDays;
      expect(daysAway, greaterThanOrEqualTo(0));
      expect(daysAway, lessThan(28));
    });
  });

  group('CycleCalculator.daysUntilNextPeriod', () {
    test('always returns a non-negative value, even for old lastPeriodStart', () {
      final longAgo = DateTime.now().subtract(const Duration(days: 60));
      final result = CycleCalculator.daysUntilNextPeriod(longAgo);
      expect(result, greaterThanOrEqualTo(0));
      expect(result, lessThan(28)); // advanced to current cycle
    });

    test('returns 27 for period started yesterday with 28-day cycle', () {
      final yesterday = DateTime.now().subtract(const Duration(days: 1));
      final result = CycleCalculator.daysUntilNextPeriod(yesterday);
      expect(result, 27);
    });
  });

  group('CycleCalculator.approximateOvulationDate', () {
    test('is cycleLength − 14 days from start', () {
      final start = DateTime(2024, 6, 1);
      final ovulation =
          CycleCalculator.approximateOvulationDate(start, cycleLength: 28);
      expect(ovulation, DateTime(2024, 6, 15));
    });
  });

  group('CycleCalculator.fertileWindow', () {
    test('ends on ovulation day and starts 5 days before', () {
      final start = DateTime(2024, 6, 1);
      final window =
          CycleCalculator.fertileWindow(start, cycleLength: 28);
      expect(window.end, DateTime(2024, 6, 15));
      expect(window.start, DateTime(2024, 6, 10));
    });
  });

  group('CycleCalculator.daysFromPredictedStart', () {
    test('returns 0 when today is exactly the predicted start', () {
      final today = DateTime.now();
      final todayDate = DateTime(today.year, today.month, today.day);
      final start = todayDate.subtract(const Duration(days: 28));
      expect(
        CycleCalculator.daysFromPredictedStart(start, cycleLength: 28),
        0,
      );
    });

    test('returns positive when past predicted start (period late)', () {
      final today = DateTime.now();
      final todayDate = DateTime(today.year, today.month, today.day);
      // Last period 31 days ago → 3 days late on a 28-day cycle
      final start = todayDate.subtract(const Duration(days: 31));
      expect(
        CycleCalculator.daysFromPredictedStart(start, cycleLength: 28),
        3,
      );
    });

    test('returns negative when period not yet expected', () {
      final today = DateTime.now();
      final todayDate = DateTime(today.year, today.month, today.day);
      // Last period 10 days ago → 18 days until predicted start
      final start = todayDate.subtract(const Duration(days: 10));
      expect(
        CycleCalculator.daysFromPredictedStart(start, cycleLength: 28),
        -18,
      );
    });

    test('works with non-default cycle length', () {
      final today = DateTime.now();
      final todayDate = DateTime(today.year, today.month, today.day);
      // Last period 36 days ago with 35-day cycle → 1 day late
      final start = todayDate.subtract(const Duration(days: 36));
      expect(
        CycleCalculator.daysFromPredictedStart(start, cycleLength: 35),
        1,
      );
    });
  });

  group('currentPhaseProvider bug fix — overdue cycle stays in luteal', () {
    // phaseForDay with capping: day 29 capped to 28 → luteal (not menstrual).
    test('day 29 capped to cycleLength(28) stays in luteal', () {
      const cycleLength = 28;
      final capped = 29.clamp(1, cycleLength);
      expect(
        CycleCalculator.phaseForDay(capped, cycleLength: cycleLength),
        CyclePhase.luteal,
      );
    });

    test('day 35 capped to cycleLength(28) stays in luteal', () {
      const cycleLength = 28;
      final capped = 35.clamp(1, cycleLength);
      expect(
        CycleCalculator.phaseForDay(capped, cycleLength: cycleLength),
        CyclePhase.luteal,
      );
    });
  });

  group('CycleCalculator.phaseForDate', () {
    test('same day as period start → menstrual', () {
      final start = DateTime(2024, 6, 1);
      final phase = CycleCalculator.phaseForDate(
        start,
        lastPeriodStart: start,
      );
      expect(phase, CyclePhase.menstrual);
    });

    test('14 days after start → ovulation', () {
      final start = DateTime(2024, 6, 1);
      final phase = CycleCalculator.phaseForDate(
        DateTime(2024, 6, 15),
        lastPeriodStart: start,
      );
      expect(phase, CyclePhase.ovulation);
    });

    test('date before period start wraps correctly', () {
      // One day before the period start should map to the last luteal day
      final start = DateTime(2024, 6, 10);
      final phase = CycleCalculator.phaseForDate(
        DateTime(2024, 6, 9),
        lastPeriodStart: start,
      );
      // Day before start → cycleDay 28 → luteal
      expect(phase, CyclePhase.luteal);
    });
  });
}
