import 'package:flutter/material.dart';
import '../../ai/insight.dart';
import '../../core/constants/enums.dart';

class InsightCard extends StatefulWidget {
  const InsightCard({super.key, required this.insight, this.compact = false});

  final Insight insight;

  /// Compact mode shows only the headline — used for the Home screen preview.
  /// Full mode (default) shows the body text and is used on the Insights screen.
  final bool compact;

  @override
  State<InsightCard> createState() => _InsightCardState();
}

class _InsightCardState extends State<InsightCard> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    final accentColor = _accentColor(widget.insight, cs);
    final icon = _icon(widget.insight.type);

    return GestureDetector(
      onTap: widget.compact ? null : () => setState(() => _expanded = !_expanded),
      child: AnimatedSize(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeInOut,
        child: Container(
          decoration: BoxDecoration(
            color: cs.surfaceContainerLow,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: cs.outlineVariant.withValues(alpha: 0.5)),
          ),
          clipBehavior: Clip.antiAlias,
          child: IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // ── Accent bar ──────────────────────────────────────────
                Container(width: 4, color: accentColor),

                // ── Content ─────────────────────────────────────────────
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 14, vertical: 12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(icon, size: 16, color: accentColor),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                widget.insight.title,
                                style: theme.textTheme.labelMedium?.copyWith(
                                  color: cs.onSurface,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                            if (!widget.compact)
                              Icon(
                                _expanded
                                    ? Icons.expand_less_rounded
                                    : Icons.expand_more_rounded,
                                size: 16,
                                color: cs.onSurfaceVariant,
                              ),
                          ],
                        ),
                        if (!widget.compact || _expanded) ...[
                          const SizedBox(height: 6),
                          Text(
                            widget.insight.body,
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: cs.onSurfaceVariant,
                              height: 1.4,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  static IconData _icon(InsightType type) => switch (type) {
        InsightType.phaseAffinity => Icons.loop_rounded,
        InsightType.severityTrend => Icons.trending_down_rounded,
        InsightType.coOccurrence => Icons.hub_outlined,
        InsightType.streakAlert => Icons.warning_amber_rounded,
        InsightType.absenceAlert => Icons.notifications_off_outlined,
        InsightType.cycleComparison => Icons.compare_arrows_rounded,
      };

  static Color _accentColor(Insight insight, ColorScheme cs) {
    // Phase-specific insights use the phase seed color.
    if (insight.phase != null) return insight.phase!.seedColor;
    // Streak alerts use error color — they need attention.
    if (insight.type == InsightType.streakAlert) return cs.error;
    // Cycle comparison uses secondary.
    if (insight.type == InsightType.cycleComparison) return cs.secondary;
    return cs.primary;
  }
}
