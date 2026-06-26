import 'dart:math' as math;
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/chart_provider.dart';
import '../../providers/estimator_provider.dart';
import '../../providers/insight_provider.dart';
import '../../widgets/insight_card.dart';
import '../../../core/constants/enums.dart';

class InsightsScreen extends ConsumerWidget {
  const InsightsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final prediction = ref.watch(cyclePredictionProvider);
    final insightsAsync = ref.watch(insightsProvider);
    final hasData = prediction.cyclesObserved >= 2;

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            floating: true,
            backgroundColor: Colors.transparent,
            elevation: 0,
            title: Text('Insights', style: theme.textTheme.titleMedium),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 40),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (!hasData) ...[
                    _UnlockCard(cyclesTracked: prediction.cyclesObserved),
                    const SizedBox(height: 20),
                  ],

                  // ── Summary cards ───────────────────────────────────────
                  _SummaryCard(
                    title: 'Average cycle',
                    value: '${prediction.expectedDays} days',
                    subtitle: hasData
                        ? 'Based on ${prediction.cyclesObserved} cycles'
                        : 'Track more cycles to refine',
                    icon: Icons.loop_rounded,
                  ),
                  const SizedBox(height: 12),
                  _SummaryCard(
                    title: 'Prediction range',
                    value: prediction.isFixed
                        ? '${prediction.expectedDays} days'
                        : '${prediction.lowerDays}–${prediction.upperDays} days',
                    subtitle: prediction.isFixed
                        ? 'Based on pill schedule'
                        : prediction.isConfident
                            ? 'High accuracy'
                            : 'Needs 6+ cycles for highest accuracy',
                    icon: Icons.insights_rounded,
                  ),

                  // ── Chart 1: Cycle length trend ─────────────────────────
                  const SizedBox(height: 28),
                  _ChartSection(
                    title: 'Cycle length over time',
                    child: _CycleLengthChart(ref: ref),
                  ),

                  // ── Chart 2: Symptom frequency by phase ─────────────────
                  const SizedBox(height: 24),
                  _ChartSection(
                    title: 'Symptom frequency by phase',
                    child: _SymptomPhaseChart(ref: ref),
                  ),

                  // ── Chart 3: Mood over current cycle ────────────────────
                  const SizedBox(height: 24),
                  _ChartSection(
                    title: 'Energy this cycle',
                    child: _MoodChart(ref: ref),
                  ),

                  // ── Chart 4: Symptom–phase heatmap ──────────────────────
                  const SizedBox(height: 24),
                  _ChartSection(
                    title: 'Symptom–phase heatmap',
                    child: _HeatmapChart(ref: ref),
                  ),

                  // ── Chart 5: Phase distribution donut ───────────────────
                  const SizedBox(height: 24),
                  _ChartSection(
                    title: 'Phase distribution',
                    child: _PhaseDonutChart(ref: ref),
                  ),

                  // ── Pattern insights ─────────────────────────────────────
                  const SizedBox(height: 28),
                  Text(
                    'Your patterns',
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 12),

                  insightsAsync.when(
                    loading: () => const Center(
                      child: Padding(
                        padding: EdgeInsets.all(24),
                        child: CircularProgressIndicator(),
                      ),
                    ),
                    error: (_, _) => const SizedBox.shrink(),
                    data: (insights) {
                      if (insights.isEmpty) {
                        return _EmptyInsights(hasData: hasData);
                      }
                      return Column(
                        children: [
                          for (int i = 0; i < insights.length; i++) ...[
                            InsightCard(insight: insights[i]),
                            if (i < insights.length - 1)
                              const SizedBox(height: 10),
                          ],
                        ],
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Chart section wrapper ─────────────────────────────────────────────────────

class _ChartSection extends StatelessWidget {
  final String title;
  final Widget child;
  const _ChartSection({required this.title, required this.child});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cs.surfaceContainerLow,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: cs.outlineVariant),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: theme.textTheme.labelMedium?.copyWith(
              color: cs.onSurfaceVariant,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 12),
          child,
        ],
      ),
    );
  }
}

// ── Chart 1: Cycle length line chart ─────────────────────────────────────────

class _CycleLengthChart extends StatelessWidget {
  final WidgetRef ref;
  const _CycleLengthChart({required this.ref});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final async = ref.watch(cycleLengthChartProvider);

    return async.when(
      loading: () => const _ChartPlaceholder(),
      error: (_, _) => const _ChartPlaceholder(),
      data: (points) {
        if (points.length < 2) {
          return _EmptyChart(
            message: 'Complete 2+ cycles to see your trend',
          );
        }

        final spots = points
            .map((p) => FlSpot(p.cycleIndex.toDouble(), p.days))
            .toList();

        final minY = (spots.map((s) => s.y).reduce(math.min) - 2).clamp(18.0, 100.0);
        final maxY = (spots.map((s) => s.y).reduce(math.max) + 2).clamp(18.0, 100.0);

        return SizedBox(
          height: 120,
          child: LineChart(
            LineChartData(
              minY: minY,
              maxY: maxY,
              gridData: FlGridData(show: false),
              borderData: FlBorderData(show: false),
              titlesData: FlTitlesData(
                leftTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    reservedSize: 28,
                    getTitlesWidget: (v, _) => Text(
                      '${v.toInt()}d',
                      style: TextStyle(
                          fontSize: 9, color: cs.onSurfaceVariant),
                    ),
                  ),
                ),
                bottomTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    getTitlesWidget: (v, _) => Text(
                      '#${v.toInt()}',
                      style: TextStyle(
                          fontSize: 9, color: cs.onSurfaceVariant),
                    ),
                  ),
                ),
                topTitles: AxisTitles(
                    sideTitles: SideTitles(showTitles: false)),
                rightTitles: AxisTitles(
                    sideTitles: SideTitles(showTitles: false)),
              ),
              lineBarsData: [
                LineChartBarData(
                  spots: spots,
                  isCurved: true,
                  color: cs.primary,
                  barWidth: 2,
                  dotData: FlDotData(show: spots.length <= 6),
                  belowBarData: BarAreaData(
                    show: true,
                    color: cs.primary.withValues(alpha: 0.1),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

// ── Chart 2: Symptom frequency by phase (grouped bar chart) ──────────────────

class _SymptomPhaseChart extends StatelessWidget {
  final WidgetRef ref;
  const _SymptomPhaseChart({required this.ref});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final async = ref.watch(symptomPhaseChartProvider);

    return async.when(
      loading: () => const _ChartPlaceholder(),
      error: (_, _) => const _ChartPlaceholder(),
      data: (phaseData) {
        // Find the top-5 most frequent symptoms across all phases
        final Map<Symptom, int> totals = {};
        for (final d in phaseData) {
          for (final e in d.counts.entries) {
            totals[e.key] = (totals[e.key] ?? 0) + e.value;
          }
        }

        if (totals.isEmpty) {
          return _EmptyChart(message: 'Log symptoms to see phase patterns');
        }

        final topSymptoms = (totals.entries.toList()
              ..sort((a, b) => b.value.compareTo(a.value)))
            .take(5)
            .map((e) => e.key)
            .toList();

        // Build bar groups: one per symptom, one bar per phase
        final groups = topSymptoms.asMap().entries.map((symEntry) {
          final sym = symEntry.value;
          final bars = phaseData.asMap().entries.map((phEntry) {
            final count = phEntry.value.counts[sym]?.toDouble() ?? 0;
            return BarChartRodData(
              toY: count,
              color: phEntry.value.phase.seedColor,
              width: 8,
              borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(4)),
            );
          }).toList();

          return BarChartGroupData(x: symEntry.key, barRods: bars);
        }).toList();

        final maxY = groups
                .expand((g) => g.barRods.map((r) => r.toY))
                .fold(0.0, math.max)
                .clamp(1.0, double.infinity) +
            1;

        return SizedBox(
          height: 150,
          child: BarChart(
            BarChartData(
              maxY: maxY,
              gridData: FlGridData(show: false),
              borderData: FlBorderData(show: false),
              titlesData: FlTitlesData(
                bottomTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    getTitlesWidget: (v, _) {
                      final idx = v.toInt();
                      if (idx < 0 || idx >= topSymptoms.length) {
                        return const SizedBox.shrink();
                      }
                      return Padding(
                        padding: const EdgeInsets.only(top: 4),
                        child: Text(
                          topSymptoms[idx].label.split(' ').first,
                          style: TextStyle(
                              fontSize: 8, color: cs.onSurfaceVariant),
                        ),
                      );
                    },
                  ),
                ),
                leftTitles: AxisTitles(
                    sideTitles: SideTitles(showTitles: false)),
                topTitles: AxisTitles(
                    sideTitles: SideTitles(showTitles: false)),
                rightTitles: AxisTitles(
                    sideTitles: SideTitles(showTitles: false)),
              ),
              barGroups: groups,
            ),
          ),
        );
      },
    );
  }
}

// ── Chart 3: Mood / energy line chart for current cycle ──────────────────────

class _MoodChart extends StatelessWidget {
  final WidgetRef ref;
  const _MoodChart({required this.ref});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final async = ref.watch(moodChartProvider);

    return async.when(
      loading: () => const _ChartPlaceholder(),
      error: (_, _) => const _ChartPlaceholder(),
      data: (points) {
        if (points.isEmpty) {
          return _EmptyChart(message: 'Log mood to see energy trends');
        }

        final spots = points
            .map((p) => FlSpot(p.cycleDay.toDouble(), p.energyLevel))
            .toList();

        return SizedBox(
          height: 110,
          child: LineChart(
            LineChartData(
              minY: 1,
              maxY: 5,
              gridData: FlGridData(show: false),
              borderData: FlBorderData(show: false),
              titlesData: FlTitlesData(
                leftTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    reservedSize: 24,
                    getTitlesWidget: (v, _) => Text(
                      '${v.toInt()}',
                      style: TextStyle(
                          fontSize: 9, color: cs.onSurfaceVariant),
                    ),
                  ),
                ),
                bottomTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    getTitlesWidget: (v, _) => Text(
                      'D${v.toInt()}',
                      style: TextStyle(
                          fontSize: 9, color: cs.onSurfaceVariant),
                    ),
                  ),
                ),
                topTitles: AxisTitles(
                    sideTitles: SideTitles(showTitles: false)),
                rightTitles: AxisTitles(
                    sideTitles: SideTitles(showTitles: false)),
              ),
              lineBarsData: [
                LineChartBarData(
                  spots: spots,
                  isCurved: true,
                  color: cs.secondary,
                  barWidth: 2,
                  dotData: FlDotData(show: spots.length <= 10),
                  belowBarData: BarAreaData(
                    show: true,
                    color: cs.secondary.withValues(alpha: 0.1),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

// ── Chart 4: Symptom–phase heatmap (custom paint) ────────────────────────────

class _HeatmapChart extends StatelessWidget {
  final WidgetRef ref;
  const _HeatmapChart({required this.ref});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final theme = Theme.of(context);
    final async = ref.watch(symptomHeatmapProvider);

    return async.when(
      loading: () => const _ChartPlaceholder(),
      error: (_, _) => const _ChartPlaceholder(),
      data: (cells) {
        if (cells.isEmpty) {
          return _EmptyChart(message: 'Log symptoms in 3+ cycles to see the heatmap');
        }

        // Build a grid: symptoms (rows) × phases (columns)
        final symptoms = cells.map((c) => c.symptom).toSet().toList()
          ..sort((a, b) => a.index.compareTo(b.index));
        final phases = CyclePhase.values;
        final cellSize = 28.0;
        final labelW = 80.0;

        return SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Phase headers
              Row(
                children: [
                  SizedBox(width: labelW),
                  ...phases.map(
                    (p) => SizedBox(
                      width: cellSize,
                      child: Text(
                        p.displayName.split(' ').first.substring(0, 3),
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: p.seedColor,
                          fontWeight: FontWeight.w700,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              // Symptom rows
              ...symptoms.map((sym) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 3),
                  child: Row(
                    children: [
                      SizedBox(
                        width: labelW,
                        child: Text(
                          sym.label,
                          style: theme.textTheme.labelSmall?.copyWith(
                            color: cs.onSurfaceVariant,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      ...phases.map((phase) {
                        final cell = cells.where(
                          (c) => c.symptom == sym && c.phase == phase,
                        ).firstOrNull;
                        final score = cell?.score ?? 0;
                        return Container(
                          width: cellSize - 2,
                          height: cellSize - 2,
                          margin: const EdgeInsets.symmetric(horizontal: 1),
                          decoration: BoxDecoration(
                            color: phase.seedColor.withValues(alpha: score * 0.9 + 0.05),
                            borderRadius: BorderRadius.circular(4),
                          ),
                        );
                      }),
                    ],
                  ),
                );
              }),
            ],
          ),
        );
      },
    );
  }
}

// ── Chart 5: Phase distribution donut ────────────────────────────────────────

class _PhaseDonutChart extends StatelessWidget {
  final WidgetRef ref;
  const _PhaseDonutChart({required this.ref});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final async = ref.watch(phaseDistributionProvider);

    return async.when(
      loading: () => const _ChartPlaceholder(),
      error: (_, _) => const _ChartPlaceholder(),
      data: (slices) {
        if (slices.isEmpty) {
          return _EmptyChart(message: 'Complete a cycle to see phase distribution');
        }

        return Row(
          children: [
            SizedBox(
              width: 140,
              height: 140,
              child: PieChart(
                PieChartData(
                  sectionsSpace: 2,
                  centerSpaceRadius: 40,
                  sections: slices.map((s) {
                    return PieChartSectionData(
                      value: s.fraction * 100,
                      color: s.phase.seedColor,
                      radius: 28,
                      title: '',
                    );
                  }).toList(),
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: slices.map((s) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 6),
                    child: Row(
                      children: [
                        Container(
                          width: 10,
                          height: 10,
                          decoration: BoxDecoration(
                            color: s.phase.seedColor,
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            s.phase.displayName
                                .replaceAll(' Phase', ''),
                            style: theme.textTheme.labelSmall,
                          ),
                        ),
                        Text(
                          '${(s.fraction * 100).toStringAsFixed(0)}%',
                          style: theme.textTheme.labelSmall?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  );
                }).toList(),
              ),
            ),
          ],
        );
      },
    );
  }
}

// ── Supporting widgets ────────────────────────────────────────────────────────

class _ChartPlaceholder extends StatelessWidget {
  const _ChartPlaceholder();
  @override
  Widget build(BuildContext context) => const SizedBox(
        height: 80,
        child: Center(child: CircularProgressIndicator()),
      );
}

class _EmptyChart extends StatelessWidget {
  final String message;
  const _EmptyChart({required this.message});
  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return SizedBox(
      height: 72,
      child: Center(
        child: Text(
          message,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: cs.onSurfaceVariant,
              ),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}

class _UnlockCard extends StatelessWidget {
  final int cyclesTracked;
  const _UnlockCard({required this.cyclesTracked});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cs.primaryContainer.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: cs.primary.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          Icon(Icons.lock_outline_rounded, color: cs.primary, size: 28),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Track 2 cycles to unlock insights',
                  style: theme.textTheme.titleSmall,
                ),
                const SizedBox(height: 8),
                LinearProgressIndicator(
                  value: cyclesTracked / 2,
                  borderRadius: BorderRadius.circular(4),
                ),
                const SizedBox(height: 4),
                Text(
                  '$cyclesTracked of 2 cycles tracked',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: cs.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SummaryCard extends StatelessWidget {
  final String title;
  final String value;
  final String subtitle;
  final IconData icon;

  const _SummaryCard({
    required this.title,
    required this.value,
    required this.subtitle,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cs.surfaceContainerLow,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: cs.outlineVariant),
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: cs.primaryContainer,
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: cs.onPrimaryContainer, size: 20),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: theme.textTheme.labelMedium?.copyWith(
                    color: cs.onSurfaceVariant,
                  ),
                ),
                Text(
                  value,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                Text(subtitle, style: theme.textTheme.bodySmall),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _EmptyInsights extends StatelessWidget {
  final bool hasData;
  const _EmptyInsights({required this.hasData});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: cs.surfaceContainerLow,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: cs.outlineVariant),
      ),
      child: Column(
        children: [
          Icon(Icons.auto_awesome_outlined, color: cs.primary, size: 32),
          const SizedBox(height: 12),
          Text(
            hasData
                ? 'Patterns will appear here as you keep logging'
                : 'Log symptoms for 3+ cycles to see personalised patterns',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: cs.onSurfaceVariant,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
