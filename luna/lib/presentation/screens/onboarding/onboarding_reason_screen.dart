import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../onboarding/onboarding_notifier.dart';
import 'widgets/onboarding_scaffold.dart';

const _goals = [
  ('track_cycle', 'Track my cycle'),
  ('understand_symptoms', 'Understand my symptoms'),
  ('manage_pcos_endo', 'Manage PCOS or Endometriosis'),
  ('plan_pregnancy', 'Plan a pregnancy'),
  ('avoid_pregnancy', 'Avoid pregnancy'),
  ('wellbeing', 'Improve my overall wellbeing'),
  ('education', 'Learn more about my body'),
];

class OnboardingReasonScreen extends ConsumerStatefulWidget {
  const OnboardingReasonScreen({super.key});

  @override
  ConsumerState<OnboardingReasonScreen> createState() =>
      _OnboardingReasonScreenState();
}

class _OnboardingReasonScreenState
    extends ConsumerState<OnboardingReasonScreen> {
  late Set<String> _selected;

  @override
  void initState() {
    super.initState();
    _selected = Set.from(ref.read(onboardingProvider).trackingGoals);
  }

  void _onContinue() {
    ref
        .read(onboardingProvider.notifier)
        .setTrackingGoals(_selected.toList());
    context.push('/onboarding/symptoms');
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    return OnboardingScaffold(
      stepIndex: 4,
      title: 'Why are you here?',
      subtitle: 'Helps Luna show the most relevant features first.',
      body: Wrap(
        spacing: 10,
        runSpacing: 10,
        children: _goals.map((g) {
          final sel = _selected.contains(g.$1);
          return FilterChip(
            label: Text(g.$2),
            selected: sel,
            onSelected: (_) {
              setState(() {
                if (sel) {
                  _selected.remove(g.$1);
                } else {
                  _selected.add(g.$1);
                }
              });
            },
            selectedColor: cs.primaryContainer,
            checkmarkColor: cs.primary,
          );
        }).toList(),
      ),
      primaryAction: FilledButton(
        onPressed: _onContinue,
        child: const Text('Continue'),
      ),
      secondaryAction: TextButton(
        onPressed: () => context.push('/onboarding/symptoms'),
        child: const Text('Skip for now'),
      ),
    );
  }
}
