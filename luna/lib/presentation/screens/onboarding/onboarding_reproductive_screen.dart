import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/enums.dart';
import '../../onboarding/onboarding_notifier.dart';
import 'widgets/onboarding_scaffold.dart';

const _reproductiveOptions = [
  (
    ReproductiveStatus.normal,
    'Not applicable',
    'None of the below apply to me',
  ),
  (
    ReproductiveStatus.tryingToConceive,
    'Trying to conceive',
    'Actively tracking fertility',
  ),
  (
    ReproductiveStatus.pregnant,
    'Currently pregnant',
    'Tracking for awareness',
  ),
  (
    ReproductiveStatus.postpartum,
    'Postpartum',
    'Gave birth in the last 12 months',
  ),
  (
    ReproductiveStatus.breastfeeding,
    'Breastfeeding',
    'Currently nursing',
  ),
  (
    ReproductiveStatus.perimenopause,
    'Perimenopause',
    'Cycles becoming less regular',
  ),
];

class OnboardingReproductiveScreen extends ConsumerStatefulWidget {
  const OnboardingReproductiveScreen({super.key});

  @override
  ConsumerState<OnboardingReproductiveScreen> createState() =>
      _OnboardingReproductiveScreenState();
}

class _OnboardingReproductiveScreenState
    extends ConsumerState<OnboardingReproductiveScreen> {
  late ReproductiveStatus _selected;

  @override
  void initState() {
    super.initState();
    _selected = ref.read(onboardingProvider).reproductiveStatus;
  }

  void _onContinue() {
    ref.read(onboardingProvider.notifier).setReproductiveStatus(_selected);
    context.push('/onboarding/biometrics');
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    return OnboardingScaffold(
      stepIndex: 4,
      title: 'Your reproductive health',
      subtitle:
          'Helps Luna choose the right prediction model for your situation.',
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: _reproductiveOptions.map((opt) {
          final sel = _selected == opt.$1;
          return GestureDetector(
            onTap: () => setState(() => _selected = opt.$1),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 150),
              margin: const EdgeInsets.only(bottom: 8),
              padding:
                  const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              decoration: BoxDecoration(
                color: sel ? cs.primaryContainer : cs.surface,
                border: Border.all(
                  color: sel ? cs.primary : cs.outlineVariant,
                  width: sel ? 2 : 1,
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
                          opt.$2,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: sel
                                ? cs.onPrimaryContainer
                                : cs.onSurface,
                            fontWeight:
                                sel ? FontWeight.w600 : FontWeight.normal,
                          ),
                        ),
                        Text(
                          opt.$3,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: sel
                                ? cs.onPrimaryContainer
                                : cs.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (sel)
                    Icon(Icons.check_circle_rounded,
                        color: cs.primary, size: 20),
                ],
              ),
            ),
          );
        }).toList(),
      ),
      primaryAction: FilledButton(
        onPressed: _onContinue,
        child: const Text('Continue'),
      ),
      secondaryAction: TextButton(
        onPressed: () => context.push('/onboarding/biometrics'),
        child: const Text('Skip for now'),
      ),
    );
  }
}
