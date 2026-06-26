import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../onboarding/onboarding_notifier.dart';
import 'widgets/onboarding_scaffold.dart';

class OnboardingIdentityScreen extends ConsumerStatefulWidget {
  const OnboardingIdentityScreen({super.key});

  @override
  ConsumerState<OnboardingIdentityScreen> createState() =>
      _OnboardingIdentityScreenState();
}

class _OnboardingIdentityScreenState
    extends ConsumerState<OnboardingIdentityScreen> {
  late final TextEditingController _nameCtrl;
  late int _birthYear;

  @override
  void initState() {
    super.initState();
    final data = ref.read(onboardingProvider);
    _nameCtrl = TextEditingController(text: data.name);
    _birthYear = data.birthYear;
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    super.dispose();
  }

  bool get _canContinue => _nameCtrl.text.trim().isNotEmpty;

  void _onContinue() {
    final notifier = ref.read(onboardingProvider.notifier);
    notifier.setName(_nameCtrl.text.trim());
    notifier.setBirthYear(_birthYear);
    context.push('/onboarding/cycle-basics');
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    return OnboardingScaffold(
      stepIndex: 0,
      title: "What's your name?",
      subtitle: 'This is just for greetings — never shared.',
      showBack: false,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TextField(
            controller: _nameCtrl,
            autofocus: true,
            textCapitalization: TextCapitalization.words,
            decoration: InputDecoration(
              hintText: 'First name',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            onChanged: (_) => setState(() {}),
          ),
          const SizedBox(height: 32),
          Text('Birth year', style: theme.textTheme.titleMedium),
          const SizedBox(height: 4),
          Text(
            'Used for age-appropriate content',
            style: theme.textTheme.bodySmall?.copyWith(
              color: cs.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 12),
          _BirthYearPicker(
            value: _birthYear,
            onChanged: (y) => setState(() => _birthYear = y),
          ),
        ],
      ),
      primaryAction: FilledButton(
        onPressed: _canContinue ? _onContinue : null,
        child: const Text('Continue'),
      ),
    );
  }
}

class _BirthYearPicker extends StatelessWidget {
  final int value;
  final ValueChanged<int> onChanged;

  const _BirthYearPicker({required this.value, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final years = List.generate(
      2013 - 1940 + 1,
      (i) => 2013 - i, // descending: newest birth years first
    );

    return Container(
      height: 160,
      decoration: BoxDecoration(
        border: Border.all(color: cs.outlineVariant),
        borderRadius: BorderRadius.circular(12),
      ),
      child: ListWheelScrollView.useDelegate(
        itemExtent: 44,
        controller: FixedExtentScrollController(
          initialItem: years.indexOf(value),
        ),
        onSelectedItemChanged: (i) => onChanged(years[i]),
        physics: const FixedExtentScrollPhysics(),
        childDelegate: ListWheelChildBuilderDelegate(
          childCount: years.length,
          builder: (context, i) {
            final year = years[i];
            final selected = year == value;
            return Center(
              child: Text(
                year.toString(),
                style: theme.textTheme.bodyLarge?.copyWith(
                  color: selected ? cs.primary : cs.onSurfaceVariant,
                  fontWeight:
                      selected ? FontWeight.w700 : FontWeight.normal,
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
