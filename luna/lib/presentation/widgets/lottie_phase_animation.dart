import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import '../../core/constants/enums.dart';

/// Plays the Lottie animation for a given [CyclePhase].
///
/// Falls back to a plain phase-coloured circle if the asset is missing,
/// malformed, or the Lottie package fails to parse it.
class LottiePhaseAnimation extends StatelessWidget {
  const LottiePhaseAnimation({
    super.key,
    required this.phase,
    this.size = 120,
    this.repeat = true,
  });

  final CyclePhase phase;
  final double size;

  /// Whether the animation should loop. Set to false for one-shot transitions.
  final bool repeat;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: Lottie.asset(
        phase.lottieAsset,
        width: size,
        height: size,
        fit: BoxFit.contain,
        repeat: repeat,
        errorBuilder: (context, error, stackTrace) {
          // Fallback: tinted phase circle — ensures the UI is never broken
          return _FallbackCircle(color: phase.seedColor, size: size);
        },
      ),
    );
  }
}

class _FallbackCircle extends StatelessWidget {
  final Color color;
  final double size;
  const _FallbackCircle({required this.color, required this.size});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        shape: BoxShape.circle,
        border: Border.all(color: color.withValues(alpha: 0.4), width: 2),
      ),
      child: Icon(Icons.water_drop_rounded, color: color, size: size * 0.4),
    );
  }
}
