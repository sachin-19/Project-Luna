import 'package:flutter/material.dart';
import '../constants/enums.dart';

/// Phase-specific tokens that Material 3 has no concept of.
/// Access anywhere in the widget tree via [PhaseThemeExtension.of(context)].
@immutable
class PhaseThemeExtension extends ThemeExtension<PhaseThemeExtension> {
  const PhaseThemeExtension({
    required this.phase,
    required this.brightness,
    required this.gradientStart,
    required this.gradientEnd,
  });

  final CyclePhase phase;
  final Brightness brightness;
  final Color gradientStart;
  final Color gradientEnd;

  /// Shorthand accessor — throws if the extension is missing (should never
  /// happen if [buildTheme] is used everywhere).
  static PhaseThemeExtension of(BuildContext context) =>
      Theme.of(context).extension<PhaseThemeExtension>()!;

  static PhaseThemeExtension forPhase(CyclePhase phase, Brightness brightness) {
    return PhaseThemeExtension(
      phase: phase,
      brightness: brightness,
      gradientStart: phase.gradientStart,
      gradientEnd: phase.gradientEnd(brightness),
    );
  }

  @override
  PhaseThemeExtension copyWith({
    CyclePhase? phase,
    Brightness? brightness,
    Color? gradientStart,
    Color? gradientEnd,
  }) =>
      PhaseThemeExtension(
        phase: phase ?? this.phase,
        brightness: brightness ?? this.brightness,
        gradientStart: gradientStart ?? this.gradientStart,
        gradientEnd: gradientEnd ?? this.gradientEnd,
      );

  /// Called by [AnimatedTheme] during its 600ms crossfade.
  /// Colors interpolate smoothly; phase and brightness snap at t > 0.5.
  @override
  PhaseThemeExtension lerp(PhaseThemeExtension? other, double t) {
    if (other == null) return this;
    return PhaseThemeExtension(
      phase: t < 0.5 ? phase : other.phase,
      brightness: t < 0.5 ? brightness : other.brightness,
      gradientStart: Color.lerp(gradientStart, other.gradientStart, t)!,
      gradientEnd: Color.lerp(gradientEnd, other.gradientEnd, t)!,
    );
  }
}
