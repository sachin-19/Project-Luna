import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../onboarding/onboarding_notifier.dart';
import 'widgets/onboarding_scaffold.dart';

class OnboardingCycleBasicsScreen extends ConsumerStatefulWidget {
  const OnboardingCycleBasicsScreen({super.key});

  @override
  ConsumerState<OnboardingCycleBasicsScreen> createState() =>
      _OnboardingCycleBasicsScreenState();
}

class _OnboardingCycleBasicsScreenState
    extends ConsumerState<OnboardingCycleBasicsScreen> {
  late DateTime _lastPeriodStart;
  late int _periodDays;
  late int _cycleDays;
  late bool _cycleLengthUnknown;

  @override
  void initState() {
    super.initState();
    final data = ref.read(onboardingProvider);
    _lastPeriodStart = data.lastPeriodStart ?? DateTime.now();
    _periodDays = data.periodDays;
    _cycleDays = data.cycleDays;
    _cycleLengthUnknown = data.cycleLengthUnknown;
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _lastPeriodStart,
      firstDate: DateTime.now().subtract(const Duration(days: 180)),
      lastDate: DateTime.now(),
      helpText: 'When did your last period start?',
    );
    if (picked != null) setState(() => _lastPeriodStart = picked);
  }

  void _onContinue() {
    final notifier = ref.read(onboardingProvider.notifier);
    notifier.setLastPeriodStart(_lastPeriodStart);
    notifier.setPeriodDays(_periodDays);
    notifier.setCycleDays(_cycleDays);
    notifier.setCycleLengthUnknown(_cycleLengthUnknown);
    context.push('/onboarding/history');
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    return OnboardingScaffold(
      stepIndex: 1,
      title: 'Your cycle basics',
      subtitle: 'This seeds Luna\'s predictions from day one.',
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Last period start
          Text('Last period start date',
              style: theme.textTheme.titleMedium),
          const SizedBox(height: 8),
          GestureDetector(
            onTap: _pickDate,
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                border: Border.all(color: cs.outline),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  Icon(Icons.calendar_today_rounded,
                      color: cs.primary, size: 20),
                  const SizedBox(width: 12),
                  Text(
                    '${_lastPeriodStart.day} ${_monthName(_lastPeriodStart.month)} ${_lastPeriodStart.year}',
                    style: theme.textTheme.bodyLarge,
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 28),
          Text('Period duration: $_periodDays days',
              style: theme.textTheme.titleMedium),
          Slider(
            value: _periodDays.toDouble(),
            min: 2,
            max: 8,
            divisions: 6,
            label: '$_periodDays days',
            onChanged: (v) => setState(() => _periodDays = v.round()),
          ),

          const SizedBox(height: 28),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                _cycleLengthUnknown
                    ? 'Cycle length: not sure'
                    : 'Cycle length: $_cycleDays days',
                style: theme.textTheme.titleMedium,
              ),
            ],
          ),
          if (!_cycleLengthUnknown)
            Slider(
              value: _cycleDays.toDouble(),
              min: 21,
              max: 45,
              divisions: 24,
              label: '$_cycleDays days',
              onChanged: (v) => setState(() => _cycleDays = v.round()),
            ),
          Row(
            children: [
              Checkbox(
                value: _cycleLengthUnknown,
                onChanged: (v) =>
                    setState(() => _cycleLengthUnknown = v ?? false),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  "I'm not sure — Luna will learn my cycle over time",
                  style: theme.textTheme.bodyMedium,
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
    );
  }

  String _monthName(int m) => const [
        '', 'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
        'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
      ][m];
}
