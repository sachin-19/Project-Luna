import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/extensions/l10n.dart';
import '../../../../core/utils/cycle_calculator.dart';
import '../../../providers/estimator_provider.dart';

class PredictionCard extends ConsumerWidget {
  final CyclePrediction prediction;
  final DateTime? lastPeriodStart;

  const PredictionCard({
    super.key,
    required this.prediction,
    this.lastPeriodStart,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final l = context.l10n;

    final start = lastPeriodStart;
    final label = start != null
        ? prediction.intervalLabel(start)
        : l.predictionKeepLogging;

    // Confidence line — differs for fixed-schedule vs Bayesian
    final String confidenceText;
    final Color confidenceColor;
    final IconData confidenceIcon;
    if (prediction.isFixed) {
      confidenceText = l.predictionFixedSchedule;
      confidenceColor = cs.primary;
      confidenceIcon = Icons.event_repeat_rounded;
    } else if (prediction.isConfident) {
      confidenceText = l.predictionHighAccuracy;
      confidenceColor = cs.primary;
      confidenceIcon = Icons.check_circle_outline_rounded;
    } else {
      confidenceText = l.predictionLearning;
      confidenceColor = cs.onSurfaceVariant;
      confidenceIcon = Icons.pending_outlined;
    }

    final accuracy = ref.watch(predictionAccuracyProvider);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: BoxDecoration(
        color: cs.surfaceContainerLow,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: cs.outlineVariant),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l.nextPeriodLabel,
                  style: theme.textTheme.labelMedium?.copyWith(
                    color: cs.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  label,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),

                // Confidence + cycles-tracked row
                Row(
                  children: [
                    Icon(confidenceIcon, size: 12, color: confidenceColor),
                    const SizedBox(width: 4),
                    Text(
                      confidenceText,
                      style: theme.textTheme.labelSmall
                          ?.copyWith(color: confidenceColor),
                    ),
                    if (prediction.cyclesObserved > 0 && !prediction.isFixed) ...[
                      const SizedBox(width: 8),
                      Text(
                        l.predictionCyclesTracked(prediction.cyclesObserved),
                        style: theme.textTheme.labelSmall
                            ?.copyWith(color: cs.onSurfaceVariant),
                      ),
                    ],
                  ],
                ),

                // Accuracy tracker — only shown once we have 3+ records
                if (accuracy.total >= 3) ...[
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      Icon(
                        Icons.analytics_outlined,
                        size: 12,
                        color: cs.onSurfaceVariant,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        l.predictionAccuracy(accuracy.accurate, accuracy.total),
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: cs.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
          Icon(Icons.calendar_month_rounded, color: cs.primary, size: 32),
        ],
      ),
    );
  }
}
