import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../onboarding/onboarding_notifier.dart';
import 'widgets/onboarding_scaffold.dart';

class OnboardingBiometricsScreen extends ConsumerStatefulWidget {
  const OnboardingBiometricsScreen({super.key});

  @override
  ConsumerState<OnboardingBiometricsScreen> createState() =>
      _OnboardingBiometricsScreenState();
}

class _OnboardingBiometricsScreenState
    extends ConsumerState<OnboardingBiometricsScreen> {
  final _heightController = TextEditingController();
  final _weightController = TextEditingController();

  @override
  void initState() {
    super.initState();
    final data = ref.read(onboardingProvider);
    if (data.heightCm != null) {
      _heightController.text = data.heightCm.toString();
    }
    if (data.weightKg != null) {
      _weightController.text = data.weightKg!.toStringAsFixed(1);
    }
  }

  @override
  void dispose() {
    _heightController.dispose();
    _weightController.dispose();
    super.dispose();
  }

  void _onContinue() {
    final notifier = ref.read(onboardingProvider.notifier);
    final heightText = _heightController.text.trim();
    final weightText = _weightController.text.trim();

    final height = int.tryParse(heightText);
    final weight = double.tryParse(weightText);

    // Only save if both are provided and in plausible ranges.
    if (height != null && weight != null && height >= 100 && height <= 250 &&
        weight >= 20 && weight <= 300) {
      notifier.setHeightCm(height);
      notifier.setWeightKg(weight);
    } else {
      notifier.setHeightCm(null);
      notifier.setWeightKg(null);
    }
    context.push('/onboarding/reason');
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    return OnboardingScaffold(
      stepIndex: 5,
      title: 'Your measurements',
      subtitle:
          'Optional. Used to refine cycle predictions based on body composition.',
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Height (cm)',
            style: theme.textTheme.labelLarge?.copyWith(
              color: cs.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 8),
          TextField(
            controller: _heightController,
            keyboardType: TextInputType.number,
            inputFormatters: [
              FilteringTextInputFormatter.digitsOnly,
              LengthLimitingTextInputFormatter(3),
            ],
            decoration: InputDecoration(
              hintText: 'e.g. 163',
              suffixText: 'cm',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'Weight (kg)',
            style: theme.textTheme.labelLarge?.copyWith(
              color: cs.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 8),
          TextField(
            controller: _weightController,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            inputFormatters: [
              FilteringTextInputFormatter.allow(RegExp(r'^\d{0,3}(\.\d{0,1})?')),
            ],
            decoration: InputDecoration(
              hintText: 'e.g. 58.5',
              suffixText: 'kg',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Icon(Icons.lock_outline_rounded,
                  size: 14, color: cs.onSurfaceVariant),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  'Stored only on your device. Never shared.',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: cs.onSurfaceVariant,
                  ),
                ),
              ),
            ],
          ),
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
