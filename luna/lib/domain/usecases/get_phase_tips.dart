import '../../core/constants/enums.dart';

class Tip {
  const Tip({
    required this.id,
    required this.text,
    required this.category,
  });
  final String id;
  final String text;
  final String category;
}

class PhaseTips {
  const PhaseTips({
    required this.phase,
    required this.tips,
    required this.currentIndex,
  });
  final CyclePhase phase;
  final List<Tip> tips;
  final int currentIndex;

  Tip get current {
    if (tips.isEmpty) throw StateError('No tips available for phase $phase');
    return tips[currentIndex % tips.length];
  }
}

/// Pure Dart use case — no Flutter imports.
/// The caller supplies the already-parsed JSON map and the cycle count;
/// this class handles tip list extraction and rotation.
class GetPhaseTips {
  const GetPhaseTips();

  PhaseTips execute(
    Map<String, dynamic> json,
    CyclePhase phase, {
    int cycleNumber = 0,
  }) {
    final key = _phaseKey(phase);
    final rawList = (json[key] as List).cast<Map<String, dynamic>>();
    final tips = rawList
        .map(
          (t) => Tip(
            id: t['id'] as String,
            text: t['text'] as String,
            category: t['category'] as String,
          ),
        )
        .toList();

    return PhaseTips(
      phase: phase,
      tips: tips,
      currentIndex: tips.isEmpty ? 0 : cycleNumber % tips.length,
    );
  }

  static String _phaseKey(CyclePhase phase) => switch (phase) {
        CyclePhase.menstrual => 'menstrual',
        CyclePhase.follicular => 'follicular',
        CyclePhase.ovulation => 'ovulation',
        CyclePhase.luteal => 'luteal',
      };
}
