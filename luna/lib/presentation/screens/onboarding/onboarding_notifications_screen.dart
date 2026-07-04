import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../onboarding/onboarding_notifier.dart';
import '../../../domain/usecases/save_onboarding.dart';
import 'widgets/onboarding_scaffold.dart';

class OnboardingNotificationsScreen extends ConsumerStatefulWidget {
  const OnboardingNotificationsScreen({super.key});

  @override
  ConsumerState<OnboardingNotificationsScreen> createState() =>
      _OnboardingNotificationsScreenState();
}

class _OnboardingNotificationsScreenState
    extends ConsumerState<OnboardingNotificationsScreen> {
  late bool _period;
  late bool _ovulation;
  late bool _checkin;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    final data = ref.read(onboardingProvider);
    _period = data.notifPeriod;
    _ovulation = data.notifOvulation;
    _checkin = data.notifCheckin;
  }

  Future<void> _onFinish() async {
    if (_saving) return;
    setState(() => _saving = true);

    try {
      final notifier = ref.read(onboardingProvider.notifier);
      notifier.setNotifPeriod(_period);
      notifier.setNotifOvulation(_ovulation);
      notifier.setNotifCheckin(_checkin);

      final data = ref.read(onboardingProvider);
      await ref.read(saveOnboardingProvider).execute(data);

      // Do NOT call requestPermission() here — saving with onboarded:true causes
      // GoRouter to redirect to /home immediately, which also calls
      // requestPermission() via HomeScreen.initState(). Calling it twice
      // simultaneously throws PlatformException(permissionRequestInProgress).
      // HomeScreen handles permission for both new users and returning users.

      if (mounted) context.go('/home');
    } catch (e, st) {
      debugPrint('SaveOnboarding error: $e\n$st');
      if (mounted) {
        setState(() => _saving = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Could not save your data: $e'),
            duration: const Duration(seconds: 10),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    return OnboardingScaffold(
      stepIndex: 9,
      title: 'Stay in the loop',
      subtitle: 'Luna works best when it can remind you at the right times.',
      body: Column(
        children: [
          _NotifTile(
            icon: Icons.water_drop_rounded,
            iconColor: cs.primary,
            title: 'Period reminder',
            subtitle: '2 days before your predicted period',
            value: _period,
            onChanged: (v) => setState(() => _period = v),
            theme: theme,
          ),
          _NotifTile(
            icon: Icons.favorite_rounded,
            iconColor: Colors.green,
            title: 'Ovulation alert',
            subtitle: 'When your fertile window begins',
            value: _ovulation,
            onChanged: (v) => setState(() => _ovulation = v),
            theme: theme,
          ),
          _NotifTile(
            icon: Icons.edit_note_rounded,
            iconColor: cs.tertiary,
            title: 'Daily check-in',
            subtitle: 'Gentle nudge to log how you feel',
            value: _checkin,
            onChanged: (v) => setState(() => _checkin = v),
            theme: theme,
          ),
        ],
      ),
      primaryAction: FilledButton(
        onPressed: _saving ? null : _onFinish,
        child: _saving
            ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(strokeWidth: 2),
              )
            : const Text("Let's go!"),
      ),
    );
  }
}

class _NotifTile extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String title;
  final String subtitle;
  final bool value;
  final ValueChanged<bool> onChanged;
  final ThemeData theme;

  const _NotifTile({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.subtitle,
    required this.value,
    required this.onChanged,
    required this.theme,
  });

  @override
  Widget build(BuildContext context) {
    final cs = theme.colorScheme;
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Container(
        decoration: BoxDecoration(
          color: cs.surfaceContainerLow,
          borderRadius: BorderRadius.circular(12),
        ),
        child: SwitchListTile(
          secondary: CircleAvatar(
            backgroundColor: iconColor.withValues(alpha: 0.15),
            child: Icon(icon, color: iconColor, size: 20),
          ),
          title: Text(title, style: theme.textTheme.bodyMedium),
          subtitle: Text(
            subtitle,
            style: theme.textTheme.bodySmall
                ?.copyWith(color: cs.onSurfaceVariant),
          ),
          value: value,
          onChanged: onChanged,
        ),
      ),
    );
  }
}
