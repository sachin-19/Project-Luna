import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/usecases/start_new_cycle.dart';
import '../providers/cycle_provider.dart';

void showStartCycleSheet(BuildContext context) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (_) => const _StartCycleSheet(),
  );
}

class _StartCycleSheet extends ConsumerStatefulWidget {
  const _StartCycleSheet();

  @override
  ConsumerState<_StartCycleSheet> createState() => _StartCycleSheetState();
}

class _StartCycleSheetState extends ConsumerState<_StartCycleSheet> {
  late DateTime _selectedDate;
  bool _saving = false;

  static const int _maxDaysBack = 7;

  @override
  void initState() {
    super.initState();
    _selectedDate = _today();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final hasActiveCycle = ref.watch(activeCycleProvider).valueOrNull != null;

    return Container(
      padding: EdgeInsets.fromLTRB(
        24,
        12,
        24,
        MediaQuery.viewInsetsOf(context).bottom + 32,
      ),
      decoration: BoxDecoration(
        color: cs.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Handle
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

          const SizedBox(height: 24),

          Align(
            alignment: Alignment.centerLeft,
            child: Text(
              'When did it start?',
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          const SizedBox(height: 4),
          Align(
            alignment: Alignment.centerLeft,
            child: Text(
              'You can log up to 7 days back.',
              style: theme.textTheme.bodySmall?.copyWith(
                color: cs.onSurfaceVariant,
              ),
            ),
          ),

          const SizedBox(height: 36),

          // ── Date picker row ─────────────────────────────────────────────────
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _NavArrow(
                icon: Icons.chevron_left_rounded,
                enabled: _selectedDate.isAfter(
                  _today().subtract(Duration(days: _maxDaysBack)),
                ),
                onTap: () => setState(() {
                  _selectedDate =
                      _selectedDate.subtract(const Duration(days: 1));
                }),
              ),
              const SizedBox(width: 24),
              Column(
                children: [
                  Text(
                    _dateLabel(_selectedDate),
                    style: theme.textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                      color: cs.primary,
                    ),
                  ),
                  if (!_isToday(_selectedDate))
                    Text(
                      _dayMonthLabel(_selectedDate),
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: cs.onSurfaceVariant,
                      ),
                    ),
                ],
              ),
              const SizedBox(width: 24),
              _NavArrow(
                icon: Icons.chevron_right_rounded,
                enabled: !_isToday(_selectedDate),
                onTap: () => setState(() {
                  _selectedDate = _selectedDate.add(const Duration(days: 1));
                }),
              ),
            ],
          ),

          const SizedBox(height: 36),

          // ── Warning if a cycle is already open ──────────────────────────────
          if (hasActiveCycle)
            Container(
              margin: const EdgeInsets.only(bottom: 16),
              padding:
                  const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              decoration: BoxDecoration(
                color: cs.tertiaryContainer.withValues(alpha: 0.5),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.info_outline_rounded,
                    size: 16,
                    color: cs.onTertiaryContainer,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'This closes your current cycle and starts a new one.',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: cs.onTertiaryContainer,
                      ),
                    ),
                  ),
                ],
              ),
            ),

          // ── Start button ────────────────────────────────────────────────────
          SizedBox(
            width: double.infinity,
            child: FilledButton(
              onPressed: _saving ? null : _onStart,
              child: _saving
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Text('Start period'),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _onStart() async {
    setState(() => _saving = true);
    try {
      await ref.read(startNewCycleProvider).execute(_selectedDate);
      if (mounted) Navigator.of(context).pop();
    } catch (_) {
      if (mounted) {
        setState(() => _saving = false);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Could not start cycle. Please try again.'),
          ),
        );
      }
    }
  }

  // ── Date helpers ────────────────────────────────────────────────────────────

  static DateTime _today() {
    final n = DateTime.now();
    return DateTime(n.year, n.month, n.day);
  }

  static bool _isToday(DateTime d) {
    final t = _today();
    return d.year == t.year && d.month == t.month && d.day == t.day;
  }

  static bool _isYesterday(DateTime d) {
    final y = _today().subtract(const Duration(days: 1));
    return d.year == y.year && d.month == y.month && d.day == y.day;
  }

  static String _dateLabel(DateTime d) {
    if (_isToday(d)) return 'Today';
    if (_isYesterday(d)) return 'Yesterday';
    const days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    return days[d.weekday - 1];
  }

  static String _dayMonthLabel(DateTime d) {
    const months = [
      '',
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
    ];
    return '${months[d.month]} ${d.day}';
  }
}

class _NavArrow extends StatelessWidget {
  final IconData icon;
  final bool enabled;
  final VoidCallback onTap;

  const _NavArrow({
    required this.icon,
    required this.enabled,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return GestureDetector(
      onTap: enabled ? onTap : null,
      child: Container(
        width: 48,
        height: 48,
        decoration: BoxDecoration(
          color: enabled ? cs.surfaceContainerLow : cs.surfaceContainerLowest,
          shape: BoxShape.circle,
          border: Border.all(
            color: enabled ? cs.outline : cs.outlineVariant,
          ),
        ),
        child: Icon(
          icon,
          color: enabled ? cs.onSurface : cs.outlineVariant,
        ),
      ),
    );
  }
}
