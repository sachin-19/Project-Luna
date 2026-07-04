import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/constants/enums.dart';
import '../../core/extensions/enums_l10n.dart';
import '../../core/extensions/l10n.dart';
import '../../domain/usecases/edit_cycle_end_date.dart';
import '../../domain/usecases/edit_cycle_start_date.dart';
import '../../domain/usecases/start_new_cycle.dart';
import '../providers/cycle_provider.dart';
import '../providers/log_provider.dart';
import '../providers/user_provider.dart';

/// Opens the log sheet for [date] (defaults to today).
/// Returns a [Future] that completes when the sheet is dismissed.
Future<void> showLogBottomSheet(
  BuildContext context, {
  int initialTab = 0,
  DateTime? date,
}) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (_) => _LogSheet(
      initialTab: initialTab,
      date: _normalizeDate(date),
    ),
  );
}

DateTime _normalizeDate(DateTime? d) {
  final t = d ?? DateTime.now();
  return DateTime(t.year, t.month, t.day);
}

class _LogSheet extends ConsumerStatefulWidget {
  final int initialTab;
  final DateTime date;

  const _LogSheet({this.initialTab = 0, required this.date});

  @override
  ConsumerState<_LogSheet> createState() => _LogSheetState();
}

class _LogSheetState extends ConsumerState<_LogSheet>
    with SingleTickerProviderStateMixin {
  late final TabController _tabs;

  bool get _isToday {
    final now = DateTime.now();
    return widget.date.year == now.year &&
        widget.date.month == now.month &&
        widget.date.day == now.day;
  }

  @override
  void initState() {
    super.initState();
    _tabs = TabController(
      length: 3,
      vsync: this,
      initialIndex: widget.initialTab,
    );

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (!mounted) return;
      // Always load any existing logs first — today or past date.
      await ref
          .read(logNotifierProvider(widget.date).notifier)
          .loadExistingForDate();
      // For today only: if no symptoms were saved yet, suggest the user's
      // common ones from their profile as a starting point.
      if (_isToday && mounted) {
        final user = ref.read(userStreamProvider).valueOrNull;
        final common = user?.commonSymptoms;
        if (common != null) {
          ref
              .read(logNotifierProvider(widget.date).notifier)
              .initCommonSymptoms(common);
        }
      }
    });
  }

  @override
  void dispose() {
    _tabs.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final state = ref.watch(logNotifierProvider(widget.date));

    if (state.saved) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) Navigator.of(context).pop();
      });
    }

    return DraggableScrollableSheet(
      initialChildSize: 0.75,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      builder: (context, scrollController) => Container(
        decoration: BoxDecoration(
          color: cs.surface,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          children: [
            _SheetHeader(tabs: _tabs, date: widget.date),
            Expanded(
              child: TabBarView(
                controller: _tabs,
                children: [
                  _PeriodTab(
                    scrollController: scrollController,
                    date: widget.date,
                    isToday: _isToday,
                  ),
                  _SymptomsTab(
                    scrollController: scrollController,
                    date: widget.date,
                  ),
                  _MoodTab(
                    scrollController: scrollController,
                    date: widget.date,
                  ),
                ],
              ),
            ),
            _BottomActions(isSaving: state.isSaving, date: widget.date),
          ],
        ),
      ),
    );
  }
}

// ── Sheet header ──────────────────────────────────────────────────────────────

class _SheetHeader extends StatelessWidget {
  final TabController tabs;
  final DateTime date;
  const _SheetHeader({required this.tabs, required this.date});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    return Column(
      children: [
        const SizedBox(height: 12),
        Center(
          child: Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: cs.outlineVariant,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
        ),
        const SizedBox(height: 16),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Row(
            children: [
              Text(
                _title(context, date),
                style: theme.textTheme.titleLarge
                    ?.copyWith(fontWeight: FontWeight.w600),
              ),
              const Spacer(),
              Text(
                _dateFormatted(date),
                style: theme.textTheme.bodySmall
                    ?.copyWith(color: cs.onSurfaceVariant),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        TabBar(
          controller: tabs,
          tabs: [
            Tab(text: context.l10n.tabPeriod),
            Tab(text: context.l10n.tabSymptoms),
            Tab(text: context.l10n.tabMood),
          ],
        ),
      ],
    );
  }

  static String _title(BuildContext context, DateTime d) {
    final l = context.l10n;
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final date = DateTime(d.year, d.month, d.day);
    if (date == today) return l.logToday;
    if (date == today.subtract(const Duration(days: 1))) return l.logYesterday;
    return l.logFor(_dateFormatted(d));
  }

  static String _dateFormatted(DateTime d) {
    const months = [
      '',
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
    ];
    return '${months[d.month]} ${d.day}';
  }
}

// ── Period tab ────────────────────────────────────────────────────────────────

class _PeriodTab extends ConsumerWidget {
  final ScrollController scrollController;
  final DateTime date;
  final bool isToday;

  const _PeriodTab({
    required this.scrollController,
    required this.date,
    required this.isToday,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final state = ref.watch(logNotifierProvider(date));
    final notifier = ref.read(logNotifierProvider(date).notifier);
    final activeCycle = ref.watch(activeCycleProvider).valueOrNull;

    // ── No active cycle ───────────────────────────────────────────────────────
    if (activeCycle == null) {
      return _NoPeriodView(
        isToday: isToday,
        date: date,
        scrollController: scrollController,
      );
    }

    // ── Date is before cycle start → log not permitted ────────────────────────
    final cycleStart = activeCycle.startDateTime;
    if (date.isBefore(cycleStart)) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.calendar_today_outlined,
                  size: 48, color: cs.onSurfaceVariant),
              const SizedBox(height: 16),
              Text(
                context.l10n.periodDateBeforeCycleStart,
                style: theme.textTheme.titleMedium,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                context.l10n.periodDateBeforeCycleStartHint,
                style: theme.textTheme.bodySmall
                    ?.copyWith(color: cs.onSurfaceVariant),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      );
    }

    // ── Period ended (explicitly or beyond day 10) → treat same as no period ──
    // The cycle row stays open (endDate null) after "period ended" so phase
    // calculations keep working, but the Period tab should reflect that the
    // flow has stopped and offer "Period started today" for a new cycle.
    final cycleDay = date.difference(activeCycle.startDateTime).inDays + 1;
    final periodOver =
        activeCycle.periodLength != null || cycleDay > 10;

    if (periodOver) {
      return _NoPeriodView(
        isToday: isToday,
        date: date,
        scrollController: scrollController,
      );
    }

    // ── Date is within cycle window → show flow selector ──────────────────────
    return ListView(
      controller: scrollController,
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 8),
      children: [
        Text(
          context.l10n.flowIntensity,
          style: theme.textTheme.labelLarge
              ?.copyWith(color: cs.onSurfaceVariant),
        ),
        const SizedBox(height: 12),
        Row(
          children: FlowIntensity.values.map((intensity) {
            final selected = state.flow == intensity;
            return Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4),
                child: _FlowTile(
                  intensity: intensity,
                  selected: selected,
                  onTap: () => selected
                      ? notifier.clearFlow()
                      : notifier.setFlow(intensity),
                ),
              ),
            );
          }).toList(),
        ),
        if (state.flow == null) ...[
          const SizedBox(height: 20),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: cs.surfaceContainerLow,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                Icon(Icons.info_outline_rounded,
                    size: 16, color: cs.onSurfaceVariant),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    context.l10n.tapFlowLevel,
                    style: theme.textTheme.bodySmall
                        ?.copyWith(color: cs.onSurfaceVariant),
                  ),
                ),
              ],
            ),
          ),
        ],
        if (isToday) ...[
          const SizedBox(height: 20),
          _EndPeriodButton(date: date),
          const SizedBox(height: 8),
          _EditStartDateButton(activeCycleId: activeCycle.id),
        ],
      ],
    );
  }
}

// ── No-period view (extracted for clarity) ────────────────────────────────────

class _NoPeriodView extends ConsumerWidget {
  final bool isToday;
  final DateTime date;
  final ScrollController scrollController;

  const _NoPeriodView({
    required this.isToday,
    required this.date,
    required this.scrollController,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    // Check if the last completed cycle is within the edit window.
    final lastCycleAsync = isToday
        ? ref.watch(lastCompletedCycleProvider)
        : const AsyncData(null);
    final lastCycle = lastCycleAsync.valueOrNull;

    final bool canEditEndDate = () {
      if (lastCycle?.endDate == null) return false;
      final originalEnd = DateTime.parse(lastCycle!.endDate!);
      final windowClose = originalEnd
          .add(const Duration(days: EditCycleEndDate.editWindowDays));
      final today = DateTime.now();
      final todayNorm = DateTime(today.year, today.month, today.day);
      return !todayNorm.isAfter(windowClose);
    }();

    return ListView(
      controller: scrollController,
      padding: const EdgeInsets.all(32),
      children: [
        const SizedBox(height: 32),
        Icon(Icons.water_drop_outlined, size: 48, color: cs.primary),
        const SizedBox(height: 16),
        Text(
          context.l10n.noPeriodInProgress,
          style: theme.textTheme.titleMedium,
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 8),
        Text(
          isToday
              ? context.l10n.noPeriodStartBelow
              : context.l10n.noPeriodStartFromHome,
          style:
              theme.textTheme.bodySmall?.copyWith(color: cs.onSurfaceVariant),
          textAlign: TextAlign.center,
        ),
        if (isToday) ...[
          const SizedBox(height: 24),
          FilledButton.icon(
            onPressed: () async {
              final now = DateTime.now();
              await ref.read(startNewCycleProvider).execute(
                    DateTime(now.year, now.month, now.day),
                  );
            },
            icon: const Icon(Icons.water_drop_rounded, size: 18),
            label: Text(context.l10n.periodStartedToday),
          ),
          if (canEditEndDate && lastCycle != null) ...[
            const SizedBox(height: 12),
            _EditEndDateButton(cycleId: lastCycle.id),
          ],
        ],
      ],
    );
  }
}

// ── Edit start date button ────────────────────────────────────────────────────

class _EditStartDateButton extends ConsumerWidget {
  final int activeCycleId;
  const _EditStartDateButton({required this.activeCycleId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cs = Theme.of(context).colorScheme;
    return Center(
      child: TextButton.icon(
        onPressed: () => _pickAndApply(context, ref),
        icon: Icon(Icons.edit_calendar_outlined,
            size: 15, color: cs.onSurfaceVariant),
        label: Text(
          context.l10n.editStartDate,
          style: Theme.of(context)
              .textTheme
              .labelSmall
              ?.copyWith(color: cs.onSurfaceVariant),
        ),
        style: TextButton.styleFrom(
          padding:
              const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          minimumSize: Size.zero,
          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
        ),
      ),
    );
  }

  Future<void> _pickAndApply(BuildContext context, WidgetRef ref) async {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final earliest = today.subtract(
      const Duration(days: EditCycleStartDate.maxDaysBack),
    );

    final picked = await showDatePicker(
      context: context,
      helpText: context.l10n.editStartDateTitle,
      initialDate: today,
      firstDate: earliest,
      lastDate: today,
    );
    if (picked == null || !context.mounted) return;

    final result = await ref
        .read(editCycleStartDateProvider)
        .execute(activeCycleId, picked);

    if (!context.mounted) return;
    if (result is EditStartSuccess) {
      ref.invalidate(activeCycleProvider);
      Navigator.of(context).pop();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(context.l10n.editStartDateSuccess)),
      );
    } else if (result is EditStartFailure) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(context.l10n.editDateError(result.reason)),
        ),
      );
    }
  }
}

// ── Edit end date button ──────────────────────────────────────────────────────

class _EditEndDateButton extends ConsumerWidget {
  final int cycleId;
  const _EditEndDateButton({required this.cycleId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cs = Theme.of(context).colorScheme;
    return Center(
      child: TextButton.icon(
        onPressed: () => _pickAndApply(context, ref),
        icon: Icon(Icons.edit_calendar_outlined,
            size: 15, color: cs.onSurfaceVariant),
        label: Text(
          context.l10n.editEndDate,
          style: Theme.of(context)
              .textTheme
              .labelSmall
              ?.copyWith(color: cs.onSurfaceVariant),
        ),
        style: TextButton.styleFrom(
          padding:
              const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          minimumSize: Size.zero,
          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
        ),
      ),
    );
  }

  Future<void> _pickAndApply(BuildContext context, WidgetRef ref) async {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    final picked = await showDatePicker(
      context: context,
      helpText: context.l10n.editEndDateTitle,
      initialDate: today,
      firstDate: today.subtract(const Duration(days: 30)),
      lastDate: today,
    );
    if (picked == null || !context.mounted) return;

    final result = await ref
        .read(editCycleEndDateProvider)
        .execute(cycleId, picked);

    if (!context.mounted) return;
    if (result is EditEndSuccess) {
      ref.invalidate(lastCompletedCycleProvider);
      ref.invalidate(activeCycleProvider);
      Navigator.of(context).pop();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(context.l10n.editEndDateSuccess)),
      );
    } else if (result is EditEndFailure) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(context.l10n.editDateError(result.reason)),
        ),
      );
    }
  }
}

// ── End period button ─────────────────────────────────────────────────────────

class _EndPeriodButton extends ConsumerWidget {
  final DateTime date;
  const _EndPeriodButton({required this.date});

  static const _rose = Color(0xFFE53E6A);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return SizedBox(
      width: double.infinity,
      child: OutlinedButton.icon(
        onPressed: () => _confirm(context, ref),
        icon: const Icon(Icons.check_circle_outline_rounded, size: 18),
        label: Text(context.l10n.periodEndedToday),
        style: OutlinedButton.styleFrom(
          foregroundColor: _rose,
          side: const BorderSide(color: _rose),
          padding: const EdgeInsets.symmetric(vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
    );
  }

  Future<void> _confirm(BuildContext context, WidgetRef ref) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(context.l10n.periodEndConfirmTitle),
        content: Text(context.l10n.periodEndConfirmBody),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: Text(context.l10n.cancel),
          ),
          FilledButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            style: FilledButton.styleFrom(backgroundColor: _rose),
            child: Text(context.l10n.periodEndConfirm),
          ),
        ],
      ),
    );
    if (confirmed != true || !context.mounted) return;

    final notifier = ref.read(logNotifierProvider(date).notifier);
    final success = await notifier.endPeriod();
    if (!context.mounted) return;

    // Cache l10n string and ScaffoldMessenger before popping the sheet.
    final successMsg = context.l10n.periodEndedSuccess;
    final messenger = ScaffoldMessenger.of(context);
    Navigator.of(context).pop();
    if (success) {
      messenger.showSnackBar(SnackBar(content: Text(successMsg)));
    }
  }
}

class _FlowTile extends StatelessWidget {
  final FlowIntensity intensity;
  final bool selected;
  final VoidCallback onTap;

  const _FlowTile({
    required this.intensity,
    required this.selected,
    required this.onTap,
  });

  Color _dotColor(FlowIntensity i) => switch (i) {
        FlowIntensity.spotting => const Color(0xFFFFB3C6),
        FlowIntensity.light => const Color(0xFFFF6B9D),
        FlowIntensity.medium => const Color(0xFFE53E6A),
        FlowIntensity.heavy => const Color(0xFF9B0034),
      };

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final dotColor = _dotColor(intensity);

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: selected ? cs.primaryContainer : cs.surfaceContainerLow,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: selected ? cs.primary : cs.outlineVariant,
            width: selected ? 2 : 1,
          ),
        ),
        child: Column(
          children: [
            Container(
              width: 24,
              height: 24,
              decoration: BoxDecoration(color: dotColor, shape: BoxShape.circle),
            ),
            const SizedBox(height: 6),
            Text(
              intensity.localizedLabel(context.l10n),
              style: theme.textTheme.labelSmall?.copyWith(
                color: selected ? cs.onPrimaryContainer : cs.onSurfaceVariant,
                fontWeight: selected ? FontWeight.w600 : FontWeight.normal,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

// ── Symptoms tab ──────────────────────────────────────────────────────────────

class _SymptomsTab extends ConsumerWidget {
  final ScrollController scrollController;
  final DateTime date;
  const _SymptomsTab({required this.scrollController, required this.date});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final state = ref.watch(logNotifierProvider(date));
    final notifier = ref.read(logNotifierProvider(date).notifier);

    return ListView(
      controller: scrollController,
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 8),
      children: [
        Text(
          context.l10n.whatAreYouFeeling,
          style: theme.textTheme.labelLarge
              ?.copyWith(color: cs.onSurfaceVariant),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: Symptom.values.map((symptom) {
            final selected = state.symptoms.containsKey(symptom);
            return FilterChip(
              avatar:
                  Text(symptom.emoji, style: const TextStyle(fontSize: 14)),
              label: Text(symptom.localizedLabel(context.l10n)),
              selected: selected,
              onSelected: (_) => notifier.toggleSymptom(symptom),
            );
          }).toList(),
        ),
        if (state.symptoms.isNotEmpty) ...[
          const SizedBox(height: 20),
          Text(
            context.l10n.severity,
            style: theme.textTheme.labelLarge
                ?.copyWith(color: cs.onSurfaceVariant),
          ),
          const SizedBox(height: 8),
          ...state.symptoms.entries.map(
            (entry) => _SeverityRow(
              symptom: entry.key,
              label: entry.key.localizedLabel(context.l10n),
              severity: entry.value,
              onChanged: (v) => notifier.setSeverity(entry.key, v),
            ),
          ),
        ],
      ],
    );
  }
}

class _SeverityRow extends StatelessWidget {
  final Symptom symptom;
  final String label;
  final int severity;
  final ValueChanged<int> onChanged;

  const _SeverityRow({
    required this.symptom,
    required this.label,
    required this.severity,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          SizedBox(
            width: 120,
            child: Text(
              '${symptom.emoji} $label',
              style: theme.textTheme.bodySmall,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          Expanded(
            child: Slider(
              value: severity.toDouble(),
              min: 1,
              max: 5,
              divisions: 4,
              onChanged: (v) => onChanged(v.round()),
            ),
          ),
          SizedBox(
            width: 32,
            child: Text(
              '$severity/5',
              style: theme.textTheme.labelSmall
                  ?.copyWith(color: cs.onSurfaceVariant),
              textAlign: TextAlign.end,
            ),
          ),
        ],
      ),
    );
  }
}

// ── Mood tab ──────────────────────────────────────────────────────────────────

class _MoodTab extends ConsumerWidget {
  final ScrollController scrollController;
  final DateTime date;
  const _MoodTab({required this.scrollController, required this.date});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final state = ref.watch(logNotifierProvider(date));
    final notifier = ref.read(logNotifierProvider(date).notifier);

    return ListView(
      controller: scrollController,
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 8),
      children: [
        Text(
          context.l10n.howAreYouFeeling,
          style: theme.textTheme.labelLarge
              ?.copyWith(color: cs.onSurfaceVariant),
        ),
        const SizedBox(height: 12),
        GridView.count(
          crossAxisCount: 3,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          mainAxisSpacing: 8,
          crossAxisSpacing: 8,
          childAspectRatio: 1.1,
          children: Mood.values.map((mood) {
            final selected = state.mood == mood;
            return GestureDetector(
              onTap: () =>
                  selected ? notifier.clearMood() : notifier.setMood(mood),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 180),
                decoration: BoxDecoration(
                  color: selected
                      ? cs.secondaryContainer
                      : cs.surfaceContainerLow,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: selected ? cs.secondary : cs.outlineVariant,
                    width: selected ? 2 : 1,
                  ),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(mood.emoji, style: const TextStyle(fontSize: 26)),
                    const SizedBox(height: 4),
                    Text(
                      mood.localizedLabel(context.l10n),
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: selected
                            ? cs.onSecondaryContainer
                            : cs.onSurfaceVariant,
                        fontWeight:
                            selected ? FontWeight.w600 : FontWeight.normal,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }).toList(),
        ),
        const SizedBox(height: 24),
        Row(
          children: [
            const Text('🔋', style: TextStyle(fontSize: 18)),
            const SizedBox(width: 8),
            Text(
              context.l10n.energy,
              style: theme.textTheme.labelLarge?.copyWith(color: cs.onSurface),
            ),
            const Spacer(),
            Text(
              _energyLabel(state.energyLevel),
              style: theme.textTheme.labelMedium?.copyWith(color: cs.primary),
            ),
          ],
        ),
        Slider(
          value: state.energyLevel.toDouble(),
          min: 1,
          max: 5,
          divisions: 4,
          onChanged: (v) => notifier.setEnergy(v.round()),
        ),
      ],
    );
  }

  String _energyLabel(int level) => switch (level) {
        1 => 'Drained',
        2 => 'Low',
        3 => 'Okay',
        4 => 'Good',
        _ => 'High',
      };
}

// ── Bottom actions ────────────────────────────────────────────────────────────

class _BottomActions extends ConsumerWidget {
  final bool isSaving;
  final DateTime date;
  const _BottomActions({required this.isSaving, required this.date});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final notifier = ref.read(logNotifierProvider(date).notifier);

    return Container(
      padding: EdgeInsets.fromLTRB(
        20,
        12,
        20,
        MediaQuery.viewInsetsOf(context).bottom + 20,
      ),
      decoration: BoxDecoration(
        color: cs.surface,
        border: Border(top: BorderSide(color: cs.outlineVariant)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            decoration: InputDecoration(
              hintText: context.l10n.addNoteHint,
              prefixIcon: const Icon(Icons.edit_note_rounded),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: cs.outlineVariant),
              ),
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              isDense: true,
            ),
            maxLines: 2,
            style: theme.textTheme.bodySmall,
            onChanged: notifier.setNotes,
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: FilledButton(
              onPressed: isSaving
                  ? null
                  : () async {
                      final success = await notifier.save();
                      if (!success && context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(context.l10n.logSaveError),
                          ),
                        );
                      }
                    },
              child: isSaving
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : Text(context.l10n.saveLog),
            ),
          ),
        ],
      ),
    );
  }
}
