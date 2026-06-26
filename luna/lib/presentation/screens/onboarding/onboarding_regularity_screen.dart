import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../onboarding/onboarding_notifier.dart';
import 'widgets/onboarding_scaffold.dart';

const _regularityOptions = [
  ('very_regular', 'Very regular', 'Period comes within 1–2 days of expected'),
  ('mostly_regular', 'Mostly regular', '3–5 days variation'),
  ('irregular', 'Irregular', 'Hard to predict'),
  ('unpredictable', 'Very unpredictable', "I can't tell at all"),
];

const _conditionOptions = [
  ('none', 'No'),
  ('pcos', 'Yes — PCOS'),
  ('endo', 'Yes — Endometriosis'),
  ('both', 'Yes — both'),
  ('prefer_not', 'Prefer not to say'),
];

class OnboardingRegularityScreen extends ConsumerStatefulWidget {
  const OnboardingRegularityScreen({super.key});

  @override
  ConsumerState<OnboardingRegularityScreen> createState() =>
      _OnboardingRegularityScreenState();
}

class _OnboardingRegularityScreenState
    extends ConsumerState<OnboardingRegularityScreen> {
  String? _regularity;
  String _condition = 'none';

  @override
  void initState() {
    super.initState();
    final data = ref.read(onboardingProvider);
    _regularity = data.regularity;
    if (data.hasPcos && data.hasEndo) {
      _condition = 'both';
    } else if (data.hasPcos) {
      _condition = 'pcos';
    } else if (data.hasEndo) {
      _condition = 'endo';
    }
  }

  void _onContinue() {
    final notifier = ref.read(onboardingProvider.notifier);
    notifier.setRegularity(_regularity);
    notifier.setHasPcos(_condition == 'pcos' || _condition == 'both');
    notifier.setHasEndo(_condition == 'endo' || _condition == 'both');
    context.push('/onboarding/reason');
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    return OnboardingScaffold(
      stepIndex: 3,
      title: 'Your cycle pattern',
      subtitle: 'Knowing your pattern helps Luna adjust predictions for you.',
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('How regular is your cycle?',
              style: theme.textTheme.titleMedium),
          const SizedBox(height: 12),
          ..._regularityOptions.map((opt) => _SelectTile(
                label: opt.$2,
                subtitle: opt.$3,
                selected: _regularity == opt.$1,
                onTap: () => setState(() => _regularity = opt.$1),
                cs: cs,
                theme: theme,
              )),
          const SizedBox(height: 28),
          Text('Do you have PCOS or endometriosis?',
              style: theme.textTheme.titleMedium),
          const SizedBox(height: 12),
          ..._conditionOptions.map((opt) => _SelectTile(
                label: opt.$2,
                selected: _condition == opt.$1,
                onTap: () => setState(() => _condition = opt.$1),
                cs: cs,
                theme: theme,
              )),
          const SizedBox(height: 8),
        ],
      ),
      primaryAction: FilledButton(
        onPressed: _onContinue,
        child: const Text('Continue'),
      ),
      secondaryAction: TextButton(
        onPressed: () => context.push('/onboarding/reason'),
        child: const Text('Skip for now'),
      ),
    );
  }
}

class _SelectTile extends StatelessWidget {
  final String label;
  final String? subtitle;
  final bool selected;
  final VoidCallback onTap;
  final ColorScheme cs;
  final ThemeData theme;

  const _SelectTile({
    required this.label,
    this.subtitle,
    required this.selected,
    required this.onTap,
    required this.cs,
    required this.theme,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: selected ? cs.primaryContainer : cs.surface,
          border: Border.all(
            color: selected ? cs.primary : cs.outlineVariant,
            width: selected ? 2 : 1,
          ),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color:
                          selected ? cs.onPrimaryContainer : cs.onSurface,
                      fontWeight:
                          selected ? FontWeight.w600 : FontWeight.normal,
                    ),
                  ),
                  if (subtitle != null)
                    Text(
                      subtitle!,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: selected
                            ? cs.onPrimaryContainer
                            : cs.onSurfaceVariant,
                      ),
                    ),
                ],
              ),
            ),
            if (selected)
              Icon(Icons.check_circle_rounded,
                  color: cs.primary, size: 20),
          ],
        ),
      ),
    );
  }
}
