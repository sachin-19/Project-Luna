import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../onboarding/onboarding_notifier.dart';
import 'widgets/onboarding_scaffold.dart';

class OnboardingHistoryScreen extends ConsumerWidget {
  const OnboardingHistoryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final data = ref.watch(onboardingProvider);
    final dates = data.pastPeriods;
    final durations = data.pastPeriodDurations.isNotEmpty
        ? data.pastPeriodDurations
        : List.filled(dates.length, data.periodDays);

    return OnboardingScaffold(
      stepIndex: 2,
      title: 'Past period dates',
      subtitle:
          'Adding past dates makes Luna\'s first prediction 40% more accurate.',
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: cs.primaryContainer,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                Icon(Icons.insights_rounded,
                    color: cs.onPrimaryContainer, size: 18),
                const SizedBox(width: 8),
                Text(
                  'Prediction window: ${_accuracyLabel(dates.length)}',
                  style: theme.textTheme.labelMedium
                      ?.copyWith(color: cs.onPrimaryContainer),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Tap the duration badge on each entry to adjust how long that period lasted.',
            style: theme.textTheme.bodySmall
                ?.copyWith(color: cs.onSurfaceVariant),
          ),
          const SizedBox(height: 16),

          ...dates.asMap().entries.map(
                (e) => Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: _DateChip(
                    date: e.value,
                    durationDays: durations[e.key],
                    onRemove: () => _removeAt(ref, e.key, dates, durations),
                    onEditDuration: () => _editDuration(
                        context, ref, e.key, e.value, durations[e.key]),
                  ),
                ),
              ),

          if (dates.length < 5)
            OutlinedButton.icon(
              onPressed: () => _addDate(context, ref),
              icon: const Icon(Icons.add_rounded),
              label: const Text('Add past period'),
            ),
        ],
      ),
      primaryAction: FilledButton(
        onPressed: () => context.push('/onboarding/regularity'),
        child: const Text('Continue'),
      ),
      secondaryAction: TextButton(
        onPressed: () => context.push('/onboarding/regularity'),
        child: const Text('Skip for now'),
      ),
    );
  }

  // ── Actions ────────────────────────────────────────────────────────────────

  Future<void> _addDate(BuildContext context, WidgetRef ref) async {
    final data = ref.read(onboardingProvider);
    if (data.pastPeriods.length >= 5) return;

    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now().subtract(const Duration(days: 30)),
      firstDate: DateTime.now().subtract(const Duration(days: 365)),
      lastDate: DateTime.now().subtract(const Duration(days: 7)),
      helpText: 'Past period start date',
    );
    if (picked == null) return;

    final currentDates = ref.read(onboardingProvider).pastPeriods;
    final currentDurs = ref.read(onboardingProvider).pastPeriodDurations;
    final defaultDur = ref.read(onboardingProvider).periodDays;

    final newDates = [...currentDates, picked];
    final newDurs = [
      ...(currentDurs.isNotEmpty
          ? currentDurs
          : List.filled(currentDates.length, defaultDur)),
      defaultDur,
    ];

    // Keep sorted newest-first.
    final paired = List.generate(
      newDates.length,
      (i) => (date: newDates[i], dur: newDurs[i]),
    )..sort((a, b) => b.date.compareTo(a.date));

    final notifier = ref.read(onboardingProvider.notifier);
    notifier.setPastPeriods(paired.map((e) => e.date).toList());
    notifier.setPastPeriodDurations(paired.map((e) => e.dur).toList());
  }

  void _removeAt(WidgetRef ref, int index, List<DateTime> dates,
      List<int> durations) {
    final newDates = List<DateTime>.from(dates)..removeAt(index);
    final newDurs = List<int>.from(durations)..removeAt(index);
    final notifier = ref.read(onboardingProvider.notifier);
    notifier.setPastPeriods(newDates);
    notifier.setPastPeriodDurations(newDurs);
  }

  Future<void> _editDuration(BuildContext context, WidgetRef ref, int index,
      DateTime date, int currentDays) async {
    final result = await showDialog<int>(
      context: context,
      builder: (_) =>
          _DurationDialog(date: date, initialDays: currentDays),
    );
    if (result == null) return;
    final durations = List<int>.from(ref.read(onboardingProvider).pastPeriodDurations);
    if (index < durations.length) {
      durations[index] = result;
      ref.read(onboardingProvider.notifier).setPastPeriodDurations(durations);
    }
  }

  static String _accuracyLabel(int count) {
    if (count == 0) return '±5–7 days';
    if (count == 1) return '±4 days';
    if (count == 2) return '±3 days';
    if (count == 3) return '±2 days';
    return '±1–2 days';
  }
}

// ── Date chip ─────────────────────────────────────────────────────────────────

class _DateChip extends StatelessWidget {
  final DateTime date;
  final int durationDays;
  final VoidCallback onRemove;
  final VoidCallback onEditDuration;

  const _DateChip({
    required this.date,
    required this.durationDays,
    required this.onRemove,
    required this.onEditDuration,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    const months = [
      '', 'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    final dateLabel = '${date.day} ${months[date.month]} ${date.year}';

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: cs.surfaceContainerLow,
        border: Border.all(color: cs.outlineVariant),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Icon(Icons.water_drop_rounded, color: cs.primary, size: 16),
          const SizedBox(width: 10),
          Expanded(
            child: Text(dateLabel, style: theme.textTheme.bodyMedium),
          ),
          GestureDetector(
            onTap: onEditDuration,
            child: Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: cs.secondaryContainer,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    '$durationDays days',
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: cs.onSecondaryContainer,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(width: 4),
                  Icon(Icons.edit_rounded,
                      size: 11, color: cs.onSecondaryContainer),
                ],
              ),
            ),
          ),
          const SizedBox(width: 8),
          GestureDetector(
            onTap: onRemove,
            child: Icon(Icons.close_rounded,
                size: 16, color: cs.onSurfaceVariant),
          ),
        ],
      ),
    );
  }
}

// ── Duration edit dialog ──────────────────────────────────────────────────────

class _DurationDialog extends StatefulWidget {
  final DateTime date;
  final int initialDays;

  const _DurationDialog({required this.date, required this.initialDays});

  @override
  State<_DurationDialog> createState() => _DurationDialogState();
}

class _DurationDialogState extends State<_DurationDialog> {
  late int _days;

  @override
  void initState() {
    super.initState();
    _days = widget.initialDays;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    const months = [
      '', 'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    final dateLabel =
        '${widget.date.day} ${months[widget.date.month]}';

    return AlertDialog(
      title: Text('Duration for $dateLabel'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            '$_days days',
            style: theme.textTheme.headlineMedium
                ?.copyWith(color: theme.colorScheme.primary),
          ),
          Slider(
            value: _days.toDouble(),
            min: 2,
            max: 10,
            divisions: 8,
            label: '$_days days',
            onChanged: (v) => setState(() => _days = v.round()),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('2 days',
                  style: theme.textTheme.labelSmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant)),
              Text('10 days',
                  style: theme.textTheme.labelSmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant)),
            ],
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: () => Navigator.of(context).pop(_days),
          child: const Text('Done'),
        ),
      ],
    );
  }
}
