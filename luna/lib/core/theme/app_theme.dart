import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../constants/enums.dart';
import 'phase_themes.dart';

/// Builds a complete [ThemeData] for the given [phase] and [brightness].
///
/// Strategy:
/// 1. [ColorScheme.fromSeed] generates all interactive-element colors with
///    correct M3 contrast ratios from the phase seed color.
/// 2. We [copyWith] only the surface/background tokens to phase-tinted values —
///    M3's auto-generated surfaces are too neutral and lose phase personality.
/// 3. [PhaseThemeExtension] carries phase-specific tokens (gradients, etc.)
///    that have no M3 equivalent.
ThemeData buildTheme(CyclePhase phase, Brightness brightness) {
  final isDark = brightness == Brightness.dark;

  final baseScheme = ColorScheme.fromSeed(
    seedColor: phase.seedColor,
    brightness: brightness,
  );

  final scheme = baseScheme.copyWith(
    surface: isDark ? phase.darkSurface : phase.lightSurface,
    surfaceContainerLowest:
        isDark ? phase.darkBackground : phase.lightBackground,
    surfaceContainerLow:
        isDark ? phase.darkSurfaceRaised : phase.lightSurfaceRaised,
    surfaceContainer: isDark ? phase.darkSurfaceRaised : phase.lightSurfaceRaised,
    onSurface: isDark ? phase.darkOnSurface : phase.lightOnSurface,
    onSurfaceVariant:
        isDark ? phase.darkOnSurfaceVariant : phase.lightOnSurfaceVariant,
  );

  final textTheme = _buildTextTheme(scheme);

  return ThemeData(
    colorScheme: scheme,
    useMaterial3: true,
    textTheme: textTheme,
    extensions: [PhaseThemeExtension.forPhase(phase, brightness)],

    // Scaffold uses our phase-tinted background, not M3's default.
    scaffoldBackgroundColor: scheme.surfaceContainerLowest,

    // AppBar inherits surface color so it blends with phase background.
    appBarTheme: AppBarTheme(
      backgroundColor: scheme.surfaceContainerLowest,
      foregroundColor: scheme.onSurface,
      elevation: 0,
      scrolledUnderElevation: 0,
      centerTitle: false,
      titleTextStyle: textTheme.titleLarge?.copyWith(
        color: scheme.onSurface,
        fontWeight: FontWeight.w600,
      ),
    ),

    // Cards use the mid-level surface.
    cardTheme: CardThemeData(
      color: scheme.surface,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(
          color: scheme.outlineVariant.withValues(alpha: 0.5),
        ),
      ),
    ),

    // Navigation bar uses raised surface.
    navigationBarTheme: NavigationBarThemeData(
      backgroundColor: scheme.surfaceContainerLow,
      indicatorColor: scheme.secondaryContainer,
      labelTextStyle: WidgetStatePropertyAll(
        textTheme.labelSmall?.copyWith(fontWeight: FontWeight.w600),
      ),
    ),

    // Bottom sheet.
    bottomSheetTheme: BottomSheetThemeData(
      backgroundColor: scheme.surface,
      modalBackgroundColor: scheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
    ),

    // Chips.
    chipTheme: ChipThemeData(
      backgroundColor: scheme.surfaceContainerLow,
      selectedColor: scheme.secondaryContainer,
      labelStyle: textTheme.labelMedium,
      side: BorderSide(color: scheme.outlineVariant.withValues(alpha: 0.5)),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    ),

    // FilledButton is the primary action button.
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        minimumSize: const Size(double.infinity, 52),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        textStyle: textTheme.labelLarge?.copyWith(fontWeight: FontWeight.w600),
      ),
    ),

    // Input fields.
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: scheme.surfaceContainerLow,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide(color: scheme.primary, width: 1.5),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
    ),
  );
}

TextTheme _buildTextTheme(ColorScheme scheme) {
  // Fraunces for display — emotive, slightly literary serif.
  // Plus Jakarta Sans for body — geometric, warm, readable on small screens.
  // JetBrains Mono for data labels — dates, numbers, percentages.
  return TextTheme(
    displayLarge: GoogleFonts.fraunces(
      fontSize: 57,
      fontWeight: FontWeight.w300,
      color: scheme.onSurface,
      height: 1.1,
    ),
    displayMedium: GoogleFonts.fraunces(
      fontSize: 45,
      fontWeight: FontWeight.w300,
      color: scheme.onSurface,
      height: 1.15,
    ),
    displaySmall: GoogleFonts.fraunces(
      fontSize: 36,
      fontWeight: FontWeight.w400,
      color: scheme.onSurface,
      height: 1.2,
    ),
    headlineLarge: GoogleFonts.fraunces(
      fontSize: 32,
      fontWeight: FontWeight.w400,
      color: scheme.onSurface,
    ),
    headlineMedium: GoogleFonts.fraunces(
      fontSize: 28,
      fontWeight: FontWeight.w400,
      color: scheme.onSurface,
    ),
    headlineSmall: GoogleFonts.fraunces(
      fontSize: 24,
      fontWeight: FontWeight.w400,
      color: scheme.onSurface,
    ),
    titleLarge: GoogleFonts.plusJakartaSans(
      fontSize: 22,
      fontWeight: FontWeight.w600,
      color: scheme.onSurface,
    ),
    titleMedium: GoogleFonts.plusJakartaSans(
      fontSize: 16,
      fontWeight: FontWeight.w600,
      color: scheme.onSurface,
    ),
    titleSmall: GoogleFonts.plusJakartaSans(
      fontSize: 14,
      fontWeight: FontWeight.w600,
      color: scheme.onSurface,
    ),
    bodyLarge: GoogleFonts.plusJakartaSans(
      fontSize: 16,
      fontWeight: FontWeight.w400,
      color: scheme.onSurface,
    ),
    bodyMedium: GoogleFonts.plusJakartaSans(
      fontSize: 14,
      fontWeight: FontWeight.w400,
      color: scheme.onSurface,
    ),
    bodySmall: GoogleFonts.plusJakartaSans(
      fontSize: 12,
      fontWeight: FontWeight.w400,
      color: scheme.onSurfaceVariant,
    ),
    labelLarge: GoogleFonts.plusJakartaSans(
      fontSize: 14,
      fontWeight: FontWeight.w600,
      color: scheme.onSurface,
    ),
    labelMedium: GoogleFonts.plusJakartaSans(
      fontSize: 12,
      fontWeight: FontWeight.w500,
      color: scheme.onSurface,
    ),
    labelSmall: GoogleFonts.jetBrainsMono(
      fontSize: 11,
      fontWeight: FontWeight.w400,
      color: scheme.onSurfaceVariant,
      letterSpacing: 0.3,
    ),
  );
}
