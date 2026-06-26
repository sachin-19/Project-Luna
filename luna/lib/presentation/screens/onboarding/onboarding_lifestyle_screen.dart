import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../onboarding/onboarding_notifier.dart';
import 'widgets/onboarding_scaffold.dart';

const _exerciseOptions = [
  ('rarely', 'Rarely or never'),
  ('1_2x', '1–2 times a week'),
  ('3_4x', '3–4 times a week'),
  ('daily', 'Daily'),
];

const _contraceptionOptions = [
  ('none', 'None'),
  ('combined_pill', 'Combined pill'),
  ('mini_pill', 'Progesterone-only pill (mini pill)'),
  ('hormonal_iud', 'Hormonal IUD'),
  ('implant', 'Implant'),
  ('injection', 'Contraceptive injection'),
  ('ring', 'Vaginal ring'),
  ('unsure', "I'm not sure"),
];

class OnboardingLifestyleScreen extends ConsumerStatefulWidget {
  const OnboardingLifestyleScreen({super.key});

  @override
  ConsumerState<OnboardingLifestyleScreen> createState() =>
      _OnboardingLifestyleScreenState();
}

class _OnboardingLifestyleScreenState
    extends ConsumerState<OnboardingLifestyleScreen> {
  int _stress = 3;
  String? _exercise;
  String _contraception = 'none';

  @override
  void initState() {
    super.initState();
    final data = ref.read(onboardingProvider);
    _stress = data.baselineStress ?? 3;
    _exercise = data.exerciseFrequency;
    _contraception = data.onHormonalContraception ? 'combined_pill' : 'none';
  }

  void _onContinue() {
    final notifier = ref.read(onboardingProvider.notifier);
    notifier.setBaselineStress(_stress);
    notifier.setExerciseFrequency(_exercise);
    notifier.setOnHormonalContraception(_contraception != 'none');
    context.push('/onboarding/notifications');
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    return OnboardingScaffold(
      stepIndex: 8,
      title: 'Lifestyle context',
      subtitle: 'Lifestyle factors affect your cycle. Helps Luna find patterns.',
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Stress
          Text('Typical stress level', style: theme.textTheme.titleMedium),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: List.generate(
              5,
              (i) {
                final level = i + 1;
                final sel = _stress == level;
                return GestureDetector(
                  onTap: () => setState(() => _stress = level),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 120),
                    width: 52,
                    height: 52,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: sel ? cs.primaryContainer : cs.surface,
                      border: Border.all(
                        color: sel ? cs.primary : cs.outlineVariant,
                        width: sel ? 2 : 1,
                      ),
                    ),
                    child: Center(
                      child: Text(
                        ['😊', '🙂', '😐', '😟', '😰'][i],
                        style: const TextStyle(fontSize: 22),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 28),

          // Exercise
          Text('Exercise frequency', style: theme.textTheme.titleMedium),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _exerciseOptions.map((opt) {
              final sel = _exercise == opt.$1;
              return ChoiceChip(
                label: Text(opt.$2),
                selected: sel,
                onSelected: (_) =>
                    setState(() => _exercise = sel ? null : opt.$1),
                selectedColor: cs.primaryContainer,
              );
            }).toList(),
          ),
          const SizedBox(height: 28),

          // Contraception
          Text('Hormonal contraception',
              style: theme.textTheme.titleMedium),
          const SizedBox(height: 4),
          Text(
            'Changes how Luna predicts your cycle',
            style: theme.textTheme.bodySmall
                ?.copyWith(color: cs.onSurfaceVariant),
          ),
          const SizedBox(height: 12),
          ..._contraceptionOptions.map(
            (opt) => GestureDetector(
              onTap: () => setState(() => _contraception = opt.$1),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 120),
                margin: const EdgeInsets.only(bottom: 8),
                padding: const EdgeInsets.symmetric(
                    horizontal: 14, vertical: 12),
                decoration: BoxDecoration(
                  color: _contraception == opt.$1
                      ? cs.primaryContainer
                      : cs.surface,
                  border: Border.all(
                    color: _contraception == opt.$1
                        ? cs.primary
                        : cs.outlineVariant,
                    width: _contraception == opt.$1 ? 2 : 1,
                  ),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        opt.$2,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: _contraception == opt.$1
                              ? cs.onPrimaryContainer
                              : cs.onSurface,
                          fontWeight: _contraception == opt.$1
                              ? FontWeight.w600
                              : FontWeight.normal,
                        ),
                      ),
                    ),
                    if (_contraception == opt.$1)
                      Icon(Icons.check_circle_rounded,
                          color: cs.primary, size: 18),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
      primaryAction: FilledButton(
        onPressed: _onContinue,
        child: const Text('Continue'),
      ),
      secondaryAction: TextButton(
        onPressed: () => context.push('/onboarding/notifications'),
        child: const Text('Skip for now'),
      ),
    );
  }
}
