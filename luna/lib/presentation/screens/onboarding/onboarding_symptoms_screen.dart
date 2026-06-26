import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../onboarding/onboarding_notifier.dart';
import 'widgets/onboarding_scaffold.dart';

const _symptoms = [
  'cramps', 'headache', 'bloating', 'fatigue',
  'back_pain', 'mood_swings', 'breast_tenderness', 'nausea',
  'acne', 'food_cravings', 'sleep_changes', 'spotting',
];

const _symptomLabels = {
  'cramps': 'Cramps',
  'headache': 'Headache',
  'bloating': 'Bloating',
  'fatigue': 'Fatigue',
  'back_pain': 'Back Pain',
  'mood_swings': 'Mood Swings',
  'breast_tenderness': 'Breast Tenderness',
  'nausea': 'Nausea',
  'acne': 'Acne',
  'food_cravings': 'Food Cravings',
  'sleep_changes': 'Sleep Changes',
  'spotting': 'Spotting',
};

class OnboardingSymptomsScreen extends ConsumerStatefulWidget {
  const OnboardingSymptomsScreen({super.key});

  @override
  ConsumerState<OnboardingSymptomsScreen> createState() =>
      _OnboardingSymptomsScreenState();
}

class _OnboardingSymptomsScreenState
    extends ConsumerState<OnboardingSymptomsScreen> {
  late Set<String> _selected;

  @override
  void initState() {
    super.initState();
    _selected = Set.from(ref.read(onboardingProvider).commonSymptoms);
  }

  void _onContinue() {
    ref
        .read(onboardingProvider.notifier)
        .setCommonSymptoms(_selected.toList());
    context.push('/onboarding/lifestyle');
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    return OnboardingScaffold(
      stepIndex: 5,
      title: 'Common symptoms',
      subtitle:
          'Pre-selects your log chips — makes logging take under 5 seconds.',
      body: Wrap(
        spacing: 10,
        runSpacing: 10,
        children: _symptoms.map((s) {
          final sel = _selected.contains(s);
          return FilterChip(
            label: Text(_symptomLabels[s] ?? s),
            selected: sel,
            onSelected: (_) {
              setState(() {
                if (sel) {
                  _selected.remove(s);
                } else {
                  _selected.add(s);
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
        onPressed: () => context.push('/onboarding/lifestyle'),
        child: const Text('Skip for now'),
      ),
    );
  }
}
