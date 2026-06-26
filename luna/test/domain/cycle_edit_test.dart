import 'package:flutter_test/flutter_test.dart';
import 'package:luna/domain/usecases/edit_cycle_start_date.dart';
import 'package:luna/domain/usecases/edit_cycle_end_date.dart';

// All tests use the static validate() methods which are pure functions —
// no database, no Riverpod, no mocks required.

void main() {
  // ── Helpers ────────────────────────────────────────────────────────────────
  DateTime date(int year, int month, int day) => DateTime(year, month, day);

  // ── EditCycleStartDate.validate ────────────────────────────────────────────

  group('EditCycleStartDate.validate — valid cases', () {
    test('same day as today is accepted', () {
      final today = date(2026, 6, 26);
      final result = EditCycleStartDate.validate(
        newStartDate: today,
        today: today,
      );
      expect(result, isA<EditStartSuccess>());
    });

    test('yesterday is accepted', () {
      final today = date(2026, 6, 26);
      final result = EditCycleStartDate.validate(
        newStartDate: date(2026, 6, 25),
        today: today,
      );
      expect(result, isA<EditStartSuccess>());
    });

    test('maxDaysBack ago is accepted', () {
      final today = date(2026, 6, 26);
      final result = EditCycleStartDate.validate(
        newStartDate: today.subtract(const Duration(days: 30)),
        today: today,
      );
      expect(result, isA<EditStartSuccess>());
    });

    test('day after previous cycle end is accepted', () {
      final today = date(2026, 6, 26);
      final prevEnd = date(2026, 6, 10);
      final result = EditCycleStartDate.validate(
        newStartDate: date(2026, 6, 11),
        today: today,
        previousCycleEndDate: prevEnd,
      );
      expect(result, isA<EditStartSuccess>());
    });

    test('no previous cycle — no overlap constraint', () {
      final today = date(2026, 6, 26);
      final result = EditCycleStartDate.validate(
        newStartDate: date(2026, 6, 20),
        today: today,
        previousCycleEndDate: null,
      );
      expect(result, isA<EditStartSuccess>());
    });
  });

  group('EditCycleStartDate.validate — failure cases', () {
    test('tomorrow is rejected as future', () {
      final today = date(2026, 6, 26);
      final result = EditCycleStartDate.validate(
        newStartDate: date(2026, 6, 27),
        today: today,
      );
      expect(result, isA<EditStartFailure>());
    });

    test('31 days ago is rejected (beyond maxDaysBack=30)', () {
      final today = date(2026, 6, 26);
      final result = EditCycleStartDate.validate(
        newStartDate: today.subtract(const Duration(days: 31)),
        today: today,
      );
      expect(result, isA<EditStartFailure>());
    });

    test('same day as previous cycle end is rejected (must be strictly after)', () {
      final today = date(2026, 6, 26);
      final prevEnd = date(2026, 6, 20);
      final result = EditCycleStartDate.validate(
        newStartDate: prevEnd,
        today: today,
        previousCycleEndDate: prevEnd,
      );
      expect(result, isA<EditStartFailure>());
    });

    test('day before previous cycle end is rejected', () {
      final today = date(2026, 6, 26);
      final prevEnd = date(2026, 6, 20);
      final result = EditCycleStartDate.validate(
        newStartDate: date(2026, 6, 19),
        today: today,
        previousCycleEndDate: prevEnd,
      );
      expect(result, isA<EditStartFailure>());
    });

    test('custom maxDaysBack=7 rejects 8 days ago', () {
      final today = date(2026, 6, 26);
      final result = EditCycleStartDate.validate(
        newStartDate: today.subtract(const Duration(days: 8)),
        today: today,
        maxDaysBack: 7,
      );
      expect(result, isA<EditStartFailure>());
    });

    test('custom maxDaysBack=7 accepts 7 days ago', () {
      final today = date(2026, 6, 26);
      final result = EditCycleStartDate.validate(
        newStartDate: today.subtract(const Duration(days: 7)),
        today: today,
        maxDaysBack: 7,
      );
      expect(result, isA<EditStartSuccess>());
    });
  });

  group('EditCycleStartDate.validate — failure message content', () {
    test('future date failure has descriptive message', () {
      final today = date(2026, 6, 26);
      final result = EditCycleStartDate.validate(
        newStartDate: date(2026, 6, 28),
        today: today,
      );
      expect((result as EditStartFailure).reason, isNotEmpty);
      expect(result.reason.toLowerCase(), contains('future'));
    });

    test('overlap failure has descriptive message', () {
      final today = date(2026, 6, 26);
      final result = EditCycleStartDate.validate(
        newStartDate: date(2026, 6, 18),
        today: today,
        previousCycleEndDate: date(2026, 6, 20),
      );
      expect((result as EditStartFailure).reason, isNotEmpty);
      expect(result.reason.toLowerCase(), contains('previous'));
    });
  });

  // ── EditCycleEndDate.validate ──────────────────────────────────────────────

  group('EditCycleEndDate.validate — valid cases', () {
    test('same as original end date is accepted', () {
      final today = date(2026, 6, 26);
      final result = EditCycleEndDate.validate(
        newEndDate: date(2026, 6, 24),
        today: today,
        cycleStart: date(2026, 6, 20),
        originalEndDate: date(2026, 6, 24),
      );
      expect(result, isA<EditEndSuccess>());
    });

    test('moving end date forward by 2 days is accepted', () {
      final today = date(2026, 6, 26);
      final result = EditCycleEndDate.validate(
        newEndDate: date(2026, 6, 26),
        today: today,
        cycleStart: date(2026, 6, 20),
        originalEndDate: date(2026, 6, 24),
      );
      expect(result, isA<EditEndSuccess>());
    });

    test('moving end date back by 2 days is accepted', () {
      final today = date(2026, 6, 26);
      final result = EditCycleEndDate.validate(
        newEndDate: date(2026, 6, 22),
        today: today,
        cycleStart: date(2026, 6, 20),
        originalEndDate: date(2026, 6, 24),
      );
      expect(result, isA<EditEndSuccess>());
    });

    test('same day as cycle start is accepted (1-day period)', () {
      final today = date(2026, 6, 26);
      final result = EditCycleEndDate.validate(
        newEndDate: date(2026, 6, 20),
        today: today,
        cycleStart: date(2026, 6, 20),
        originalEndDate: date(2026, 6, 24),
      );
      expect(result, isA<EditEndSuccess>());
    });

    test('one day before next cycle start is accepted', () {
      final today = date(2026, 6, 26);
      final result = EditCycleEndDate.validate(
        newEndDate: date(2026, 6, 22),
        today: today,
        cycleStart: date(2026, 6, 20),
        originalEndDate: date(2026, 6, 22),
        nextCycleStart: date(2026, 6, 23),
      );
      expect(result, isA<EditEndSuccess>());
    });
  });

  group('EditCycleEndDate.validate — failure cases', () {
    test('edit window expired (8 days after original end) is rejected', () {
      final originalEnd = date(2026, 6, 15);
      // today is 8 days after the original end → window closed after day 7
      final today = originalEnd.add(const Duration(days: 8));
      final result = EditCycleEndDate.validate(
        newEndDate: date(2026, 6, 16),
        today: today,
        cycleStart: date(2026, 6, 10),
        originalEndDate: originalEnd,
      );
      expect(result, isA<EditEndFailure>());
    });

    test('exactly 7 days after original end is still within window', () {
      final originalEnd = date(2026, 6, 15);
      final today = originalEnd.add(const Duration(days: 7));
      final result = EditCycleEndDate.validate(
        newEndDate: date(2026, 6, 16),
        today: today,
        cycleStart: date(2026, 6, 10),
        originalEndDate: originalEnd,
      );
      expect(result, isA<EditEndSuccess>());
    });

    test('future end date is rejected', () {
      final today = date(2026, 6, 26);
      final result = EditCycleEndDate.validate(
        newEndDate: date(2026, 6, 28),
        today: today,
        cycleStart: date(2026, 6, 20),
        originalEndDate: date(2026, 6, 25),
      );
      expect(result, isA<EditEndFailure>());
    });

    test('end date before cycle start is rejected', () {
      final today = date(2026, 6, 26);
      final result = EditCycleEndDate.validate(
        newEndDate: date(2026, 6, 19),
        today: today,
        cycleStart: date(2026, 6, 20),
        originalEndDate: date(2026, 6, 24),
      );
      expect(result, isA<EditEndFailure>());
    });

    test('end date same as next cycle start is rejected (must be strictly before)', () {
      final today = date(2026, 6, 26);
      final result = EditCycleEndDate.validate(
        newEndDate: date(2026, 6, 23),
        today: today,
        cycleStart: date(2026, 6, 20),
        originalEndDate: date(2026, 6, 22),
        nextCycleStart: date(2026, 6, 23),
      );
      expect(result, isA<EditEndFailure>());
    });

    test('end date after next cycle start is rejected', () {
      final today = date(2026, 6, 26);
      final result = EditCycleEndDate.validate(
        newEndDate: date(2026, 6, 25),
        today: today,
        cycleStart: date(2026, 6, 20),
        originalEndDate: date(2026, 6, 22),
        nextCycleStart: date(2026, 6, 23),
      );
      expect(result, isA<EditEndFailure>());
    });
  });

  group('EditCycleEndDate.validate — failure message content', () {
    test('window-expired failure has descriptive message', () {
      final originalEnd = date(2026, 6, 15);
      final today = originalEnd.add(const Duration(days: 10));
      final result = EditCycleEndDate.validate(
        newEndDate: date(2026, 6, 16),
        today: today,
        cycleStart: date(2026, 6, 10),
        originalEndDate: originalEnd,
      );
      expect((result as EditEndFailure).reason, isNotEmpty);
      expect(result.reason.toLowerCase(), contains('window'));
    });

    test('overlap-with-next-cycle failure has descriptive message', () {
      final today = date(2026, 6, 26);
      final result = EditCycleEndDate.validate(
        newEndDate: date(2026, 6, 24),
        today: today,
        cycleStart: date(2026, 6, 20),
        originalEndDate: date(2026, 6, 22),
        nextCycleStart: date(2026, 6, 23),
      );
      expect((result as EditEndFailure).reason, isNotEmpty);
      expect(result.reason.toLowerCase(), contains('next'));
    });
  });

  // ── Cross-use-case: no estimator corruption ────────────────────────────────

  group('Estimator safety', () {
    // These tests document the invariant that neither edit touches the estimator.
    // The estimator reads cycleLength (start→next start), which is computed in
    // StartNewCycle.execute(). Editing startDate or endDate of a closed cycle
    // doesn't call StartNewCycle, so the estimator is never touched.
    // These tests simply verify the validate() methods succeed for the normal
    // edit cases — confirming edits are allowed and will reach the use case
    // body (which does NOT call estimator.observe()).

    test('correcting start date one day earlier succeeds validation', () {
      final today = date(2026, 6, 26);
      final result = EditCycleStartDate.validate(
        newStartDate: date(2026, 6, 24),
        today: today,
        previousCycleEndDate: date(2026, 6, 20),
      );
      expect(result, isA<EditStartSuccess>());
    });

    test('extending period end by 1 day succeeds validation', () {
      final today = date(2026, 6, 26);
      final result = EditCycleEndDate.validate(
        newEndDate: date(2026, 6, 25),
        today: today,
        cycleStart: date(2026, 6, 20),
        originalEndDate: date(2026, 6, 24),
      );
      expect(result, isA<EditEndSuccess>());
    });
  });
}
