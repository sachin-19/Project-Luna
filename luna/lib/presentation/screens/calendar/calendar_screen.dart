import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/enums.dart';
import '../../../core/extensions/l10n.dart';
import '../../../core/utils/cycle_calculator.dart';
import '../../../data/database/app_database.dart';
import '../../providers/calendar_provider.dart';
import '../../providers/user_provider.dart';
import '../../widgets/day_log_sheet.dart';

class CalendarScreen extends ConsumerWidget {
  const CalendarScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final ym = ref.watch(calendarMonthProvider);
    final (year, month) = ym;
    final now = DateTime.now();

    final user = ref.watch(userStreamProvider).valueOrNull;
    final cycleLength = user?.avgCycleDays ?? 28;

    final allCycles = ref.watch(allCyclesProvider).valueOrNull ?? [];
    final periodDays =
        ref.watch(periodDaysForMonthProvider(ym)).valueOrNull ?? {};
    final moodDays =
        ref.watch(moodDaysForMonthProvider(ym)).valueOrNull ?? {};
    final symptomDays =
        ref.watch(symptomDaysForMonthProvider(ym)).valueOrNull ?? {};
    final predictedPeriodDays =
        ref.watch(predictedPeriodDaysProvider(ym)).valueOrNull ?? {};
    final loggedDays = {...moodDays, ...symptomDays};

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          // ── Month navigation app bar ──────────────────────────────────────
          SliverAppBar(
            floating: true,
            backgroundColor: Colors.transparent,
            elevation: 0,
            centerTitle: true,
            title: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: const Icon(Icons.chevron_left_rounded),
                  tooltip: 'Previous month',
                  onPressed: () {
                    final (y, m) = ref.read(calendarMonthProvider);
                    ref.read(calendarMonthProvider.notifier).state =
                        m > 1 ? (y, m - 1) : (y - 1, 12);
                  },
                ),
                Text(
                  _monthLabel(year, month),
                  style: theme.textTheme.titleMedium
                      ?.copyWith(fontWeight: FontWeight.w600),
                ),
                IconButton(
                  icon: const Icon(Icons.chevron_right_rounded),
                  tooltip: 'Next month',
                  onPressed: _canGoForward(year, month, now)
                      ? () {
                          final (y, m) = ref.read(calendarMonthProvider);
                          ref.read(calendarMonthProvider.notifier).state =
                              m < 12 ? (y, m + 1) : (y + 1, 1);
                        }
                      : null,
                ),
              ],
            ),
          ),

          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(12, 0, 12, 32),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _CalendarGrid(
                    year: year,
                    month: month,
                    today: now,
                    periodDays: periodDays,
                    loggedDays: loggedDays,
                    predictedPeriodDays: predictedPeriodDays,
                    allCycles: allCycles,
                    defaultCycleLength: cycleLength,
                    onDayTap: (date) async {
                      await showDayLogSheet(context, date);
                      // Refresh this month's indicators after the sheet closes.
                      ref.invalidate(periodDaysForMonthProvider(ym));
                      ref.invalidate(moodDaysForMonthProvider(ym));
                      ref.invalidate(symptomDaysForMonthProvider(ym));
                    },
                  ),
                  const SizedBox(height: 20),
                  if (allCycles.isEmpty)
                    _EmptyHint()
                  else
                    _CycleLegend(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Allow viewing up to 3 months forward (to see predicted phase/period).
  static bool _canGoForward(int year, int month, DateTime now) {
    final currentIdx = year * 12 + month;
    final nowIdx = now.year * 12 + now.month;
    return currentIdx < nowIdx + 3;
  }

  static String _monthLabel(int year, int month) {
    const months = [
      '',
      'January', 'February', 'March', 'April', 'May', 'June',
      'July', 'August', 'September', 'October', 'November', 'December',
    ];
    return '${months[month]} $year';
  }
}

// ── Calendar grid ─────────────────────────────────────────────────────────────

class _CalendarGrid extends StatelessWidget {
  final int year;
  final int month;
  final DateTime today;
  final Set<String> periodDays;
  final Set<String> loggedDays;
  final Set<String> predictedPeriodDays;
  final List<CycleEntryRow> allCycles;
  final int defaultCycleLength;
  final void Function(DateTime) onDayTap;

  const _CalendarGrid({
    required this.year,
    required this.month,
    required this.today,
    required this.periodDays,
    required this.loggedDays,
    required this.predictedPeriodDays,
    required this.allCycles,
    required this.defaultCycleLength,
    required this.onDayTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    final firstDay = DateTime(year, month, 1);
    final lastDay = DateTime(year, month + 1, 0);
    final startOffset = firstDay.weekday % 7; // Sunday = 0
    final rows = ((startOffset + lastDay.day) / 7).ceil();

    return Column(
      children: [
        // ── Day-of-week headers ──────────────────────────────────────────
        Row(
          children: ['S', 'M', 'T', 'W', 'T', 'F', 'S'].map((d) {
            return Expanded(
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Text(
                    d,
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: cs.onSurfaceVariant,
                    ),
                  ),
                ),
              ),
            );
          }).toList(),
        ),

        // ── Date rows ────────────────────────────────────────────────────
        ...List.generate(rows, (row) {
          return Row(
            children: List.generate(7, (col) {
              final dayNum = row * 7 + col - startOffset + 1;
              if (dayNum < 1 || dayNum > lastDay.day) {
                return const Expanded(child: SizedBox(height: 52));
              }
              final date = DateTime(year, month, dayNum);
              final dateStr = _iso(date);
              final isToday = _sameDay(date, today);
              final todayMidnight =
                  DateTime(today.year, today.month, today.day);
              final isFuture = date.isAfter(todayMidnight);
              final phase =
                  _phaseForDate(date, allCycles, defaultCycleLength);
              final hasPeriod = periodDays.contains(dateStr);
              final hasLog = loggedDays.contains(dateStr);
              final isPredicted = predictedPeriodDays.contains(dateStr);

              return Expanded(
                child: _DayCell(
                  date: date,
                  isToday: isToday,
                  isFuture: isFuture,
                  phase: phase,
                  hasPeriod: hasPeriod,
                  hasLog: hasLog,
                  isPredictedPeriod: isPredicted,
                  onTap: () => onDayTap(date),
                ),
              );
            }),
          );
        }),
      ],
    );
  }

  // Finds which cycle contains [date] and returns its phase.
  // allCycles is ordered newest-first so the first match wins.
  static CyclePhase? _phaseForDate(
    DateTime date,
    List<CycleEntryRow> cycles,
    int defaultCycleLength,
  ) {
    for (final cycle in cycles) {
      final start = DateTime.parse(cycle.startDate);
      if (date.isBefore(start)) continue;

      final endStr = cycle.endDate;
      if (endStr != null) {
        final end = DateTime.parse(endStr);
        if (!date.isBefore(end)) continue; // date >= end → belongs to next cycle
      }

      final len = cycle.cycleLength ?? defaultCycleLength;
      return CycleCalculator.phaseForDate(
        date,
        lastPeriodStart: start,
        cycleLength: len,
      );
    }
    return null;
  }

  static bool _sameDay(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;

  static String _iso(DateTime d) =>
      '${d.year.toString().padLeft(4, '0')}-'
      '${d.month.toString().padLeft(2, '0')}-'
      '${d.day.toString().padLeft(2, '0')}';
}

// ── Day cell ──────────────────────────────────────────────────────────────────

class _DayCell extends StatelessWidget {
  final DateTime date;
  final bool isToday;
  final bool isFuture;
  final CyclePhase? phase;
  final bool hasPeriod;
  final bool hasLog;
  final bool isPredictedPeriod;
  final VoidCallback onTap;

  const _DayCell({
    required this.date,
    required this.isToday,
    required this.isFuture,
    required this.phase,
    required this.hasPeriod,
    required this.hasLog,
    required this.isPredictedPeriod,
    required this.onTap,
  });

  static Color? _phaseColor(CyclePhase? p) => switch (p) {
        CyclePhase.menstrual => const Color(0xFFE53E6A),
        CyclePhase.follicular => const Color(0xFFF97316),
        CyclePhase.ovulation => const Color(0xFF10B981),
        CyclePhase.luteal => const Color(0xFF8B5CF6),
        null => null,
      };

  static const _periodRose = Color(0xFFE53E6A);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final color = _phaseColor(phase);

    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.translucent,
      child: SizedBox(
        height: 52,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // ── Main circle ─────────────────────────────────────────────
            Stack(
              alignment: Alignment.center,
              children: [
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: isToday
                        ? cs.primary
                        : isPredictedPeriod
                            ? _periodRose.withValues(alpha: 0.07)
                            : (color != null && !isFuture)
                                ? color.withValues(alpha: 0.18)
                                : null,
                    border: isToday || isPredictedPeriod
                        ? null // today: no border; predicted: drawn by CustomPaint
                        : (color != null && isFuture)
                            ? Border.all(
                                color: color.withValues(alpha: 0.30),
                                width: 1,
                              )
                            : hasPeriod
                                ? Border.all(
                                    color: _periodRose.withValues(alpha: 0.6),
                                    width: 1.5,
                                  )
                                : null,
                  ),
                  child: Center(
                    child: Text(
                      '${date.day}',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: isToday
                            ? cs.onPrimary
                            : (isFuture && !isPredictedPeriod)
                                ? cs.onSurface.withValues(alpha: 0.35)
                                : cs.onSurface,
                        fontWeight:
                            isToday || hasPeriod || isPredictedPeriod
                                ? FontWeight.w600
                                : FontWeight.normal,
                      ),
                    ),
                  ),
                ),
                // Dashed circle overlay for predicted period days
                if (isPredictedPeriod)
                  SizedBox(
                    width: 36,
                    height: 36,
                    child: CustomPaint(
                      painter: _DashedCirclePainter(
                        _periodRose.withValues(alpha: 0.65),
                      ),
                    ),
                  ),
              ],
            ),

            // ── Log indicator dots ───────────────────────────────────────
            const SizedBox(height: 2),
            SizedBox(
              height: 6,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (hasPeriod)
                    _dot(isToday
                        ? cs.onPrimary.withValues(alpha: 0.8)
                        : _periodRose),
                  if (hasLog) ...[
                    if (hasPeriod) const SizedBox(width: 3),
                    _dot(isToday
                        ? cs.onPrimary.withValues(alpha: 0.6)
                        : cs.secondary),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _dot(Color color) => Container(
        width: 5,
        height: 5,
        decoration: BoxDecoration(color: color, shape: BoxShape.circle),
      );
}

// ── Dashed circle painter ─────────────────────────────────────────────────────

class _DashedCirclePainter extends CustomPainter {
  final Color color;
  const _DashedCirclePainter(this.color);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5
      ..strokeCap = StrokeCap.round;

    final center = Offset(size.width / 2, size.height / 2);
    final radius = (math.min(size.width, size.height) / 2) - 1.0;
    const dashCount = 14;
    const gapFraction = 0.38;
    const fullAngle = 2 * math.pi;
    const dashSweep = fullAngle / dashCount * (1 - gapFraction);

    for (int i = 0; i < dashCount; i++) {
      final startAngle =
          (i * fullAngle / dashCount) - (math.pi / 2); // start at top
      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        startAngle,
        dashSweep,
        false,
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(_DashedCirclePainter old) => old.color != color;
}

// ── Legend & empty hint ───────────────────────────────────────────────────────

class _CycleLegend extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Wrap(
          spacing: 16,
          runSpacing: 8,
          children: const [
            _LegendDot(color: Color(0xFFE53E6A), label: 'Menstrual'),
            _LegendDot(color: Color(0xFFF97316), label: 'Follicular'),
            _LegendDot(color: Color(0xFF10B981), label: 'Ovulation'),
            _LegendDot(color: Color(0xFF8B5CF6), label: 'Luteal'),
          ],
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            Container(
              width: 5,
              height: 5,
              decoration: const BoxDecoration(
                color: Color(0xFFE53E6A),
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 6),
            Text(context.l10n.calendarPeriodLogged, style: theme.textTheme.bodySmall),
            const SizedBox(width: 16),
            Container(
              width: 5,
              height: 5,
              decoration: BoxDecoration(
                color: cs.secondary,
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 6),
            Text(context.l10n.calendarMoodLogged,
                style: theme.textTheme.bodySmall),
          ],
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            SizedBox(
              width: 16,
              height: 16,
              child: CustomPaint(
                painter: _DashedCirclePainter(
                  const Color(0xFFE53E6A).withValues(alpha: 0.65),
                ),
              ),
            ),
            const SizedBox(width: 6),
            Text(context.l10n.calendarPredictedPeriod, style: theme.textTheme.bodySmall),
          ],
        ),
      ],
    );
  }
}

class _LegendDot extends StatelessWidget {
  final Color color;
  final String label;
  const _LegendDot({required this.color, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 6),
        Text(label, style: Theme.of(context).textTheme.bodySmall),
      ],
    );
  }
}

class _EmptyHint extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cs.surfaceContainerLow,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          Icon(Icons.water_drop_outlined, color: cs.primary, size: 22),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              context.l10n.calendarStartTracking,
              style: theme.textTheme.bodySmall,
            ),
          ),
        ],
      ),
    );
  }
}
