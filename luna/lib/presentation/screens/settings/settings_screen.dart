import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:package_info_plus/package_info_plus.dart';
import '../../../core/constants/feature_flags.dart';
import '../../../core/theme/theme_switcher.dart';
import '../../../data/providers.dart';
import '../../../data/services/export_service.dart';
import '../../providers/auth_provider.dart';
import '../../providers/cycle_provider.dart';
import '../../providers/notification_provider.dart';
import '../../providers/theme_provider.dart';
import '../../providers/update_provider.dart';
import '../../providers/user_provider.dart';
import '../../widgets/update_bottom_sheet.dart';
import '../../../core/constants/enums.dart';
import '../../../domain/entities/user.dart';

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  late TextEditingController _nameCtrl;
  String _savedName = '';

  @override
  void initState() {
    super.initState();
    final user = ref.read(userStreamProvider).valueOrNull;
    _savedName = user?.displayName ?? '';
    _nameCtrl = TextEditingController(text: _savedName);
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    super.dispose();
  }

  /// Saves [updated] user and reschedules notifications for the new prefs.
  Future<void> _save(User updated) async {
    await ref.read(userRepositoryProvider).saveUser(updated);
    final cycle = ref.read(activeCycleProvider).valueOrNull;
    await ref.read(notificationServiceProvider).scheduleAll(updated, cycle);
  }

  Future<void> _saveName() async {
    final trimmed = _nameCtrl.text.trim();
    if (trimmed == _savedName || trimmed.isEmpty) return;
    final user = ref.read(userStreamProvider).valueOrNull;
    if (user == null) return;
    _savedName = trimmed;
    await ref.read(userRepositoryProvider).saveUser(
          user.copyWith(displayName: trimmed),
        );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final user = ref.watch(userStreamProvider).valueOrNull;
    final themeMode = ref.watch(themeModeProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 1,
      ),
      body: user == null
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.only(bottom: 32),
              children: [
                // ── Appearance ──────────────────────────────────────────────
                _SectionHeader(label: 'Appearance'),
                _ThemePicker(
                  current: themeMode,
                  onChanged: (mode) => animateThemeToggle(
                    context: context,
                    toggle: () =>
                        ref.read(themeModeProvider.notifier).set(mode),
                  ),
                ),
                const _Divider(),

                // ── Notifications ────────────────────────────────────────────
                _SectionHeader(label: 'Notifications'),
                _SwitchRow(
                  icon: Icons.water_drop_rounded,
                  iconColor: const Color(0xFFE53E6A),
                  title: 'Period reminder',
                  subtitle: '${user.notificationLeadDays} day${user.notificationLeadDays == 1 ? '' : 's'} before your period',
                  value: user.notificationsPeriod,
                  onChanged: (v) =>
                      _save(user.copyWith(notificationsPeriod: v)),
                ),
                if (user.notificationsPeriod) ...[
                  _LeadDaysRow(
                    days: user.notificationLeadDays,
                    onChanged: (d) =>
                        _save(user.copyWith(notificationLeadDays: d)),
                  ),
                ],
                _SwitchRow(
                  icon: Icons.favorite_rounded,
                  iconColor: const Color(0xFF10B981),
                  title: 'Ovulation alert',
                  subtitle: 'Know when your fertile window begins',
                  value: user.notificationsOvulation,
                  onChanged: (v) =>
                      _save(user.copyWith(notificationsOvulation: v)),
                ),
                _SwitchRow(
                  icon: Icons.edit_note_rounded,
                  iconColor: cs.tertiary,
                  title: 'Daily check-in',
                  subtitle: 'Gentle nudge to log how you feel (8 PM)',
                  value: user.notificationsDailyCheckin,
                  onChanged: (v) =>
                      _save(user.copyWith(notificationsDailyCheckin: v)),
                ),
                const _Divider(),

                // ── Profile ──────────────────────────────────────────────────
                _SectionHeader(label: 'Profile'),
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 4, 20, 12),
                  child: TextField(
                    controller: _nameCtrl,
                    decoration: InputDecoration(
                      labelText: 'Display name',
                      prefixIcon: const Icon(Icons.person_outline_rounded),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      suffixIcon: IconButton(
                        icon: const Icon(Icons.check_rounded),
                        tooltip: 'Save name',
                        onPressed: _saveName,
                      ),
                    ),
                    textInputAction: TextInputAction.done,
                    onEditingComplete: _saveName,
                  ),
                ),
                const _Divider(),

                // ── Account ──────────────────────────────────────────────────
                if (kFirebaseEnabled) ...[
                  _SectionHeader(label: 'Account'),
                  _AccountSection(),
                  const _Divider(),
                ],

                // ── Data ─────────────────────────────────────────────────────
                _SectionHeader(label: 'Data'),
                _ExportTiles(user: user),
                const _Divider(),

                // ── About ─────────────────────────────────────────────────────
                _SectionHeader(label: 'About'),
                _VersionTile(),
                _CheckUpdateTile(),
                _InfoRow(
                  icon: Icons.lock_outline_rounded,
                  title: 'Privacy',
                  subtitle: 'All data stays on your device. Cloud sync is off by default.',
                ),
                _InfoRow(
                  icon: Icons.favorite_outline_rounded,
                  title: 'Made for India',
                  subtitle: 'Luna is free, local-first, and designed with Indian users in mind.',
                ),
              ],
            ),
    );
  }
}

// ── Section header ─────────────────────────────────────────────────────────────

class _SectionHeader extends StatelessWidget {
  final String label;
  const _SectionHeader({required this.label});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 6),
      child: Text(
        label.toUpperCase(),
        style: theme.textTheme.labelSmall?.copyWith(
          color: cs.primary,
          fontWeight: FontWeight.w700,
          letterSpacing: 1.2,
        ),
      ),
    );
  }
}

class _Divider extends StatelessWidget {
  const _Divider();
  @override
  Widget build(BuildContext context) =>
      Divider(indent: 20, endIndent: 20, height: 1);
}

// ── Theme picker ───────────────────────────────────────────────────────────────

class _ThemePicker extends StatelessWidget {
  final ThemeMode current;
  final ValueChanged<ThemeMode> onChanged;
  const _ThemePicker({required this.current, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Theme',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const SizedBox(height: 10),
          SegmentedButton<ThemeMode>(
            segments: const [
              ButtonSegment(
                value: ThemeMode.dark,
                icon: Icon(Icons.dark_mode_rounded),
                label: Text('Dark'),
              ),
              ButtonSegment(
                value: ThemeMode.light,
                icon: Icon(Icons.light_mode_rounded),
                label: Text('Light'),
              ),
              ButtonSegment(
                value: ThemeMode.system,
                icon: Icon(Icons.brightness_auto_rounded),
                label: Text('Auto'),
              ),
            ],
            selected: {current},
            onSelectionChanged: (set) => onChanged(set.first),
            style: SegmentedButton.styleFrom(
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
          ),
        ],
      ),
    );
  }
}

// ── Switch row ─────────────────────────────────────────────────────────────────

class _SwitchRow extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String title;
  final String subtitle;
  final bool value;
  final ValueChanged<bool> onChanged;

  const _SwitchRow({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.subtitle,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return SwitchListTile(
      secondary: CircleAvatar(
        radius: 18,
        backgroundColor: iconColor.withValues(alpha: 0.15),
        child: Icon(icon, color: iconColor, size: 18),
      ),
      title: Text(title, style: theme.textTheme.bodyMedium),
      subtitle: Text(
        subtitle,
        style: theme.textTheme.bodySmall?.copyWith(
          color: Theme.of(context).colorScheme.onSurfaceVariant,
        ),
      ),
      value: value,
      onChanged: onChanged,
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 2),
    );
  }
}

// ── Lead-days stepper ──────────────────────────────────────────────────────────

class _LeadDaysRow extends StatelessWidget {
  final int days;
  final ValueChanged<int> onChanged;
  const _LeadDaysRow({required this.days, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    return Padding(
      padding: const EdgeInsets.fromLTRB(60, 0, 20, 8),
      child: Row(
        children: [
          Text(
            'Remind me',
            style: theme.textTheme.bodySmall?.copyWith(color: cs.onSurfaceVariant),
          ),
          const Spacer(),
          IconButton(
            icon: const Icon(Icons.remove_rounded),
            iconSize: 18,
            visualDensity: VisualDensity.compact,
            onPressed: days > 1 ? () => onChanged(days - 1) : null,
          ),
          SizedBox(
            width: 28,
            child: Text(
              '$days',
              textAlign: TextAlign.center,
              style: theme.textTheme.titleSmall,
            ),
          ),
          IconButton(
            icon: const Icon(Icons.add_rounded),
            iconSize: 18,
            visualDensity: VisualDensity.compact,
            onPressed: days < 7 ? () => onChanged(days + 1) : null,
          ),
          Text(
            'day${days == 1 ? '' : 's'} before',
            style: theme.textTheme.bodySmall?.copyWith(color: cs.onSurfaceVariant),
          ),
        ],
      ),
    );
  }
}

// ── Info row ───────────────────────────────────────────────────────────────────

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  const _InfoRow({required this.icon, required this.title, required this.subtitle});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    return ListTile(
      leading: Icon(icon, color: cs.onSurfaceVariant, size: 22),
      title: Text(title, style: theme.textTheme.bodyMedium),
      subtitle: Text(
        subtitle,
        style: theme.textTheme.bodySmall?.copyWith(color: cs.onSurfaceVariant),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 2),
    );
  }
}

// ── Export tiles ──────────────────────────────────────────────────────────────

class _ExportTiles extends ConsumerStatefulWidget {
  final User user;
  const _ExportTiles({required this.user});

  @override
  ConsumerState<_ExportTiles> createState() => _ExportTilesState();
}

class _ExportTilesState extends ConsumerState<_ExportTiles> {
  bool _exportingJson = false;
  bool _exportingCsv = false;
  bool _exportingPdf = false;

  Future<void> _export(ExportFormat format) async {
    final isJson = format == ExportFormat.json;
    if (isJson ? _exportingJson : _exportingCsv) return;
    setState(() => isJson ? _exportingJson = true : _exportingCsv = true);

    try {
      final cycleRepo    = ref.read(cycleRepositoryProvider);
      final symptomRepo  = ref.read(symptomRepositoryProvider);
      final moodRepo     = ref.read(moodRepositoryProvider);

      final cycles   = await cycleRepo.getAllCycles();
      final symptoms = await symptomRepo.getSymptomsForRange('1970-01-01', '2100-01-01');
      final moods    = await moodRepo.getMoodsForRange('1970-01-01', '2100-01-01');

      await const ExportService().share(
        user: widget.user,
        cycles: cycles,
        symptoms: symptoms,
        moods: moods,
        format: format,
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Export failed: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => isJson ? _exportingJson = false : _exportingCsv = false);
      }
    }
  }

  Future<void> _exportPdf() async {
    if (_exportingPdf) return;
    setState(() => _exportingPdf = true);
    try {
      final cycleRepo   = ref.read(cycleRepositoryProvider);
      final symptomRepo = ref.read(symptomRepositoryProvider);
      final moodRepo    = ref.read(moodRepositoryProvider);

      final now = DateTime.now();
      final from = now.subtract(const Duration(days: 90));
      final fromStr = '${from.year.toString().padLeft(4, '0')}-'
          '${from.month.toString().padLeft(2, '0')}-'
          '${from.day.toString().padLeft(2, '0')}';

      final cycles   = await cycleRepo.getAllCycles();
      final symptoms = await symptomRepo.getSymptomsForRange(fromStr, '2100-01-01');
      final moods    = await moodRepo.getMoodsForRange(fromStr, '2100-01-01');

      await const ExportService().sharePdf(
        user: widget.user,
        cycles: cycles,
        symptoms: symptoms,
        moods: moods,
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('PDF export failed: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _exportingPdf = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    return Column(
      children: [
        ListTile(
          leading: _exportingPdf
              ? const SizedBox(
                  width: 22,
                  height: 22,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : Icon(Icons.picture_as_pdf_outlined,
                  color: cs.primary, size: 22),
          title: Text('Doctor report (PDF)',
              style: theme.textTheme.bodyMedium),
          subtitle: Text('3-month cycle, symptom & mood summary',
              style: theme.textTheme.bodySmall
                  ?.copyWith(color: cs.onSurfaceVariant)),
          onTap: _exportPdf,
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 20, vertical: 2),
        ),
        ListTile(
          leading: _exportingJson
              ? const SizedBox(
                  width: 22,
                  height: 22,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : Icon(Icons.file_download_outlined,
                  color: cs.onSurfaceVariant, size: 22),
          title: Text('Export all data (JSON)',
              style: theme.textTheme.bodyMedium),
          subtitle: Text('Full health data in JSON format',
              style: theme.textTheme.bodySmall
                  ?.copyWith(color: cs.onSurfaceVariant)),
          onTap: () => _export(ExportFormat.json),
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 20, vertical: 2),
        ),
        ListTile(
          leading: _exportingCsv
              ? const SizedBox(
                  width: 22,
                  height: 22,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : Icon(Icons.table_chart_outlined,
                  color: cs.onSurfaceVariant, size: 22),
          title: Text('Export cycle history (CSV)',
              style: theme.textTheme.bodyMedium),
          subtitle: Text('Cycle dates and lengths for spreadsheets',
              style: theme.textTheme.bodySmall
                  ?.copyWith(color: cs.onSurfaceVariant)),
          onTap: () => _export(ExportFormat.csv),
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 20, vertical: 2),
        ),
      ],
    );
  }
}

// ── Account section ───────────────────────────────────────────────────────────

class _AccountSection extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final isAuth = ref.watch(isAuthenticatedProvider);
    final authRepo = ref.read(authRepositoryProvider);
    final syncState = ref.watch(syncNotifierProvider);

    if (!isAuth) {
      return Column(
        children: [
          ListTile(
            leading: CircleAvatar(
              radius: 18,
              backgroundColor: cs.primaryContainer,
              child: Icon(Icons.cloud_outlined, color: cs.primary, size: 18),
            ),
            title: Text('Create account & sync',
                style: theme.textTheme.bodyMedium),
            subtitle: Text(
              'Back up data and restore on any device',
              style: theme.textTheme.bodySmall
                  ?.copyWith(color: cs.onSurfaceVariant),
            ),
            trailing: const Icon(Icons.chevron_right_rounded),
            onTap: () => context.push('/auth/signup'),
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 20, vertical: 2),
          ),
          ListTile(
            leading: CircleAvatar(
              radius: 18,
              backgroundColor: cs.secondaryContainer,
              child: Icon(Icons.login_rounded,
                  color: cs.secondary, size: 18),
            ),
            title: Text('Sign in to existing account',
                style: theme.textTheme.bodyMedium),
            subtitle: Text(
              'Restore your data on this device',
              style: theme.textTheme.bodySmall
                  ?.copyWith(color: cs.onSurfaceVariant),
            ),
            trailing: const Icon(Icons.chevron_right_rounded),
            onTap: () => context.push('/auth/signin'),
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 20, vertical: 2),
          ),
        ],
      );
    }

    final email = authRepo.currentEmail ?? '—';
    final lastSync = syncState.lastSyncTime;
    final lastSyncText = lastSync == null
        ? 'Never synced'
        : 'Last sync: ${_formatSync(lastSync)}';

    return Column(
      children: [
        ListTile(
          leading: CircleAvatar(
            radius: 18,
            backgroundColor: cs.primaryContainer,
            child: Icon(Icons.cloud_done_rounded, color: cs.primary, size: 18),
          ),
          title: Text(email, style: theme.textTheme.bodyMedium),
          subtitle: Text(
            lastSyncText,
            style: theme.textTheme.bodySmall
                ?.copyWith(color: cs.onSurfaceVariant),
          ),
          trailing: syncState.isSyncing
              ? const SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : TextButton(
                  onPressed: () =>
                      ref.read(syncNotifierProvider.notifier).sync(),
                  child: const Text('Sync now'),
                ),
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 20, vertical: 2),
        ),
        if (syncState.error != null)
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 8),
            child: Text(
              'Sync failed: ${syncState.error}',
              style: theme.textTheme.bodySmall
                  ?.copyWith(color: cs.error),
            ),
          ),
        ListTile(
          leading: CircleAvatar(
            radius: 18,
            backgroundColor: cs.errorContainer,
            child: Icon(Icons.logout_rounded,
                color: cs.onErrorContainer, size: 18),
          ),
          title:
              Text('Sign out', style: theme.textTheme.bodyMedium),
          subtitle: Text(
            'Your local data is not deleted',
            style: theme.textTheme.bodySmall
                ?.copyWith(color: cs.onSurfaceVariant),
          ),
          onTap: () => _confirmSignOut(context, ref),
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 20, vertical: 2),
        ),
      ],
    );
  }

  String _formatSync(DateTime t) {
    final now = DateTime.now();
    final diff = now.difference(t);
    if (diff.inMinutes < 1) return 'Just now';
    if (diff.inHours < 1) return '${diff.inMinutes}m ago';
    if (diff.inDays < 1) return '${diff.inHours}h ago';
    return '${diff.inDays}d ago';
  }

  Future<void> _confirmSignOut(BuildContext context, WidgetRef ref) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Sign out?'),
        content: const Text(
            'Your data stays on this device. Sign in again to re-enable sync.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Sign out'),
          ),
        ],
      ),
    );
    if (confirmed == true) {
      await ref.read(authRepositoryProvider).signOut();
    }
  }
}

// ── Version tile ───────────────────────────────────────────────────────────────

class _VersionTile extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    return FutureBuilder<PackageInfo>(
      future: PackageInfo.fromPlatform(),
      builder: (context, snap) {
        final version = snap.hasData
            ? 'v${snap.data!.version} (${snap.data!.buildNumber})'
            : '—';
        return ListTile(
          leading: Icon(Icons.info_outline_rounded, color: cs.onSurfaceVariant, size: 22),
          title: Text('Version', style: theme.textTheme.bodyMedium),
          trailing: Text(
            version,
            style: theme.textTheme.bodySmall?.copyWith(color: cs.onSurfaceVariant),
          ),
          contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 2),
        );
      },
    );
  }
}

// ── Check-for-updates tile ─────────────────────────────────────────────────────

class _CheckUpdateTile extends ConsumerStatefulWidget {
  @override
  ConsumerState<_CheckUpdateTile> createState() => _CheckUpdateTileState();
}

class _CheckUpdateTileState extends ConsumerState<_CheckUpdateTile> {
  bool _checking = false;

  Future<void> _check() async {
    if (_checking) return;
    setState(() => _checking = true);
    try {
      await ref.read(updateNotifierProvider.notifier).forceCheck();
      if (!mounted) return;
      final status = ref.read(updateNotifierProvider).status;
      if (status == UpdateStatus.available) {
        showUpdateBottomSheet(context);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Luna is up to date.')),
        );
      }
    } finally {
      if (mounted) setState(() => _checking = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    return ListTile(
      leading: _checking
          ? const SizedBox(
              width: 22,
              height: 22,
              child: CircularProgressIndicator(strokeWidth: 2),
            )
          : Icon(Icons.system_update_outlined, color: cs.onSurfaceVariant, size: 22),
      title: Text('Check for updates', style: theme.textTheme.bodyMedium),
      onTap: _checking ? null : _check,
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 2),
    );
  }
}
