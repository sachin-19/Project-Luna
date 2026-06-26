import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/constants/enums.dart';
import '../../data/database/app_database.dart';
import '../../data/database/database_provider.dart';
import 'log_bottom_sheet.dart';

/// Shows a read/edit summary for a specific [date].
/// Returns a [Future] that completes when the sheet is dismissed.
Future<void> showDayLogSheet(BuildContext context, DateTime date) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (_) => _DayLogSheet(date: date),
  );
}

class _DayLogSheet extends ConsumerStatefulWidget {
  final DateTime date;
  const _DayLogSheet({required this.date});

  @override
  ConsumerState<_DayLogSheet> createState() => _DayLogSheetState();
}

class _DayLogSheetState extends ConsumerState<_DayLogSheet> {
  List<PeriodDayRow> _periodDays = [];
  List<SymptomRow> _symptoms = [];
  MoodRow? _mood;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final db = ref.read(databaseProvider);
    final dateStr = _iso(widget.date);

    final period = await db.cycleDao.getPeriodDaysForRange(dateStr, dateStr);
    final symptoms = await db.symptomDao.getSymptomsForRange(dateStr, dateStr);
    final moods = await db.moodDao.getMoodsForRange(dateStr, dateStr);

    if (!mounted) return;
    setState(() {
      _periodDays = period;
      _symptoms = symptoms;
      _mood = moods.isNotEmpty ? moods.first : null;
      _loading = false;
    });
  }

  bool get _hasAnyLog =>
      _periodDays.isNotEmpty || _symptoms.isNotEmpty || _mood != null;

  bool get _isFuture {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    return widget.date.isAfter(today);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    return Container(
      decoration: BoxDecoration(
        color: cs.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: EdgeInsets.fromLTRB(
        20,
        12,
        20,
        MediaQuery.viewInsetsOf(context).bottom + 28,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Handle ─────────────────────────────────────────────────────
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

          // ── Date header ────────────────────────────────────────────────
          Row(
            children: [
              Text(
                _dateLabel(widget.date),
                style: theme.textTheme.titleLarge
                    ?.copyWith(fontWeight: FontWeight.w600),
              ),
              if (_isFuture) ...[
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: cs.surfaceContainerHigh,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    'Upcoming',
                    style: theme.textTheme.labelSmall
                        ?.copyWith(color: cs.onSurfaceVariant),
                  ),
                ),
              ],
            ],
          ),
          const SizedBox(height: 20),

          // ── Content ─────────────────────────────────────────────────────
          if (_loading) ...[
            const Center(
              child: Padding(
                padding: EdgeInsets.symmetric(vertical: 32),
                child: CircularProgressIndicator(),
              ),
            ),
          ] else if (!_hasAnyLog) ...[
            Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 24),
                child: Column(
                  children: [
                    Icon(Icons.event_note_outlined,
                        size: 40, color: cs.onSurfaceVariant),
                    const SizedBox(height: 10),
                    Text(
                      _isFuture
                          ? 'No logs yet for this day'
                          : 'Nothing logged for this day',
                      style: theme.textTheme.bodyMedium
                          ?.copyWith(color: cs.onSurfaceVariant),
                    ),
                  ],
                ),
              ),
            ),
          ] else ...[
            // ── Period ─────────────────────────────────────────────────
            if (_periodDays.isNotEmpty) ...[
              _SectionLabel(icon: Icons.water_drop_rounded, label: 'Period'),
              ..._periodDays.map((p) => _DataRow(
                    label: _flowLabel(p.flow),
                    dotColor: const Color(0xFFE53E6A),
                  )),
              const SizedBox(height: 14),
            ],

            // ── Mood ───────────────────────────────────────────────────
            if (_mood != null) ...[
              _SectionLabel(icon: Icons.mood_rounded, label: 'Mood'),
              _DataRow(
                label: _moodEmoji(_mood!.mood) + _moodLabel(_mood!.mood),
                sublabel: 'Energy ${_mood!.energyLevel}/5',
                dotColor: cs.secondary,
              ),
              if (_mood!.notes != null && _mood!.notes!.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(left: 16, top: 2, bottom: 4),
                  child: Text(
                    '"${_mood!.notes!}"',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: cs.onSurfaceVariant,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ),
              const SizedBox(height: 14),
            ],

            // ── Symptoms ───────────────────────────────────────────────
            if (_symptoms.isNotEmpty) ...[
              _SectionLabel(
                  icon: Icons.healing_rounded, label: 'Symptoms'),
              const SizedBox(height: 6),
              Wrap(
                spacing: 6,
                runSpacing: 6,
                children: _symptoms
                    .map((s) => _SymptomPill(
                          symptomDbValue: s.symptom,
                          severity: s.severity,
                        ))
                    .toList(),
              ),
              const SizedBox(height: 14),
            ],
          ],

          // ── Action button ──────────────────────────────────────────────
          if (!_isFuture) ...[
            const SizedBox(height: 4),
            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                onPressed: () async {
                  await showLogBottomSheet(context, date: widget.date);
                  // Reload summary after the edit sheet closes.
                  setState(() => _loading = true);
                  await _load();
                },
                icon: Icon(
                  _hasAnyLog ? Icons.edit_rounded : Icons.add_rounded,
                  size: 18,
                ),
                label: Text(_hasAnyLog ? 'Edit log' : 'Add log'),
              ),
            ),
          ],
        ],
      ),
    );
  }

  // ── Helpers ─────────────────────────────────────────────────────────────────

  static String _iso(DateTime d) =>
      '${d.year.toString().padLeft(4, '0')}-'
      '${d.month.toString().padLeft(2, '0')}-'
      '${d.day.toString().padLeft(2, '0')}';

  static String _dateLabel(DateTime d) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final date = DateTime(d.year, d.month, d.day);
    if (date == today) return 'Today';
    if (date == today.subtract(const Duration(days: 1))) return 'Yesterday';
    const months = [
      '',
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
    ];
    const days = ['', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    return '${days[d.weekday]}, ${months[d.month]} ${d.day}';
  }

  static String _flowLabel(String dbValue) {
    try {
      return FlowIntensity.values.byName(dbValue).label;
    } catch (_) {
      return dbValue;
    }
  }

  static String _moodLabel(String dbValue) {
    try {
      return ' ${Mood.values.byName(dbValue).label}';
    } catch (_) {
      return dbValue;
    }
  }

  static String _moodEmoji(String dbValue) {
    try {
      return Mood.values.byName(dbValue).emoji;
    } catch (_) {
      return '';
    }
  }
}

// ── Small reusable widgets ────────────────────────────────────────────────────

class _SectionLabel extends StatelessWidget {
  final IconData icon;
  final String label;
  const _SectionLabel({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        children: [
          Icon(icon, size: 15, color: cs.primary),
          const SizedBox(width: 5),
          Text(
            label,
            style: theme.textTheme.labelMedium?.copyWith(
              color: cs.primary,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class _DataRow extends StatelessWidget {
  final String label;
  final String? sublabel;
  final Color dotColor;
  const _DataRow({required this.label, this.sublabel, required this.dotColor});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 3),
      child: Row(
        children: [
          Container(
            width: 7,
            height: 7,
            decoration:
                BoxDecoration(color: dotColor, shape: BoxShape.circle),
          ),
          const SizedBox(width: 8),
          Text(label, style: theme.textTheme.bodyMedium),
          if (sublabel != null) ...[
            const SizedBox(width: 8),
            Text(
              sublabel!,
              style: theme.textTheme.bodySmall
                  ?.copyWith(color: cs.onSurfaceVariant),
            ),
          ],
        ],
      ),
    );
  }
}

class _SymptomPill extends StatelessWidget {
  final String symptomDbValue;
  final int severity;
  const _SymptomPill(
      {required this.symptomDbValue, required this.severity});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    String emoji = '';
    String label = symptomDbValue;
    try {
      final s = Symptom.values.byName(symptomDbValue);
      emoji = s.emoji;
      label = s.label;
    } catch (_) {}

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: cs.surfaceContainerHigh,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: cs.outlineVariant),
      ),
      child: Text(
        '$emoji $label · $severity/5',
        style: theme.textTheme.labelSmall,
      ),
    );
  }
}
