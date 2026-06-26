import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/enums.dart';
import '../../providers/cycle_provider.dart';
import '../../providers/tips_provider.dart';

class TipsScreen extends ConsumerStatefulWidget {
  const TipsScreen({super.key});

  @override
  ConsumerState<TipsScreen> createState() => _TipsScreenState();
}

class _TipsScreenState extends ConsumerState<TipsScreen> {
  CyclePhase? _selectedPhase; // null → use current cycle phase

  static const _phaseOrder = [
    CyclePhase.menstrual,
    CyclePhase.follicular,
    CyclePhase.ovulation,
    CyclePhase.luteal,
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    final currentPhase = ref.watch(currentPhaseProvider);
    final activePhase = _selectedPhase ?? currentPhase;
    final tipsAsync = ref.watch(phaseTipsProvider(activePhase));

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          // ── App bar ────────────────────────────────────────────────────────
          SliverAppBar(
            floating: true,
            backgroundColor: Colors.transparent,
            elevation: 0,
            title: Text(
              'Phase Tips',
              style: theme.textTheme.titleMedium
                  ?.copyWith(fontWeight: FontWeight.w600),
            ),
          ),

          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ── Phase selector ────────────────────────────────────────
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: _phaseOrder.map((phase) {
                        final isCurrent = phase == currentPhase;
                        final isSelected = phase == activePhase;
                        return Padding(
                          padding: const EdgeInsets.only(right: 8),
                          child: _PhaseChip(
                            phase: phase,
                            isSelected: isSelected,
                            isCurrent: isCurrent,
                            onTap: () =>
                                setState(() => _selectedPhase = phase),
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // ── Phase heading ─────────────────────────────────────────
                  Text(
                    activePhase.displayName,
                    style: theme.textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    activePhase == currentPhase
                        ? 'Your current phase'
                        : 'Tips for this phase',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: cs.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
          ),

          // ── Tips list ──────────────────────────────────────────────────────
          tipsAsync.when(
            loading: () => const SliverFillRemaining(
              child: Center(child: CircularProgressIndicator()),
            ),
            error: (_, _) => const SliverFillRemaining(
              child: Center(child: Text('Could not load tips.')),
            ),
            data: (phaseTips) => SliverPadding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 40),
              sliver: SliverList.separated(
                itemCount: phaseTips.tips.length,
                separatorBuilder: (_, _) => const SizedBox(height: 10),
                itemBuilder: (context, index) {
                  final tip = phaseTips.tips[index];
                  final isCurrent = index == phaseTips.currentIndex &&
                      activePhase == currentPhase;
                  return _TipCard(
                    tip: tip,
                    number: index + 1,
                    total: phaseTips.tips.length,
                    isFeatured: isCurrent,
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Phase selector chip ───────────────────────────────────────────────────────

class _PhaseChip extends StatelessWidget {
  final CyclePhase phase;
  final bool isSelected;
  final bool isCurrent;
  final VoidCallback onTap;

  const _PhaseChip({
    required this.phase,
    required this.isSelected,
    required this.isCurrent,
    required this.onTap,
  });

  static Color _phaseColor(CyclePhase p) => switch (p) {
        CyclePhase.menstrual => const Color(0xFFE53E6A),
        CyclePhase.follicular => const Color(0xFFF97316),
        CyclePhase.ovulation => const Color(0xFF10B981),
        CyclePhase.luteal => const Color(0xFF8B5CF6),
      };

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final color = _phaseColor(phase);

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected
              ? color.withValues(alpha: 0.15)
              : cs.surfaceContainerLow,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? color : cs.outlineVariant,
            width: isSelected ? 1.5 : 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 8,
              height: 8,
              decoration: BoxDecoration(
                color: color,
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 6),
            Text(
              phase.displayName,
              style: theme.textTheme.labelMedium?.copyWith(
                color: isSelected ? color : cs.onSurfaceVariant,
                fontWeight:
                    isSelected ? FontWeight.w600 : FontWeight.normal,
              ),
            ),
            if (isCurrent) ...[
              const SizedBox(width: 4),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  'Now',
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: color,
                    fontSize: 9,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

// ── Tip card ──────────────────────────────────────────────────────────────────

class _TipCard extends StatelessWidget {
  final Tip tip;
  final int number;
  final int total;
  final bool isFeatured;

  const _TipCard({
    required this.tip,
    required this.number,
    required this.total,
    required this.isFeatured,
  });

  static const _categoryIcons = {
    'nutrition': Icons.restaurant_rounded,
    'exercise': Icons.directions_run_rounded,
    'wellness': Icons.spa_rounded,
    'self_care': Icons.favorite_border_rounded,
    'mood': Icons.mood_rounded,
  };

  static const _categoryLabels = {
    'nutrition': 'Nutrition',
    'exercise': 'Exercise',
    'wellness': 'Wellness',
    'self_care': 'Self-care',
    'mood': 'Mood',
  };

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final icon = _categoryIcons[tip.category] ?? Icons.lightbulb_outline_rounded;
    final label = _categoryLabels[tip.category] ?? tip.category;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 250),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isFeatured
            ? cs.primaryContainer.withValues(alpha: 0.55)
            : cs.surfaceContainerLow,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isFeatured
              ? cs.primary.withValues(alpha: 0.35)
              : cs.outlineVariant.withValues(alpha: 0.5),
          width: isFeatured ? 1.5 : 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Header row ──────────────────────────────────────────────────
          Row(
            children: [
              // Number badge
              Container(
                width: 24,
                height: 24,
                decoration: BoxDecoration(
                  color: isFeatured
                      ? cs.primary
                      : cs.surfaceContainerHigh,
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Text(
                    '$number',
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: isFeatured ? cs.onPrimary : cs.onSurfaceVariant,
                      fontWeight: FontWeight.w700,
                      fontSize: 10,
                    ),
                  ),
                ),
              ),
              const Spacer(),
              if (isFeatured)
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: cs.primary.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    'Today\'s tip',
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: cs.primary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              const SizedBox(width: 8),
              // Category chip
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(icon, size: 12, color: cs.onSurfaceVariant),
                  const SizedBox(width: 4),
                  Text(
                    label,
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: cs.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 10),

          // ── Tip text ─────────────────────────────────────────────────────
          Text(
            tip.text,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: cs.onSurface,
              height: 1.45,
            ),
          ),
        ],
      ),
    );
  }
}
