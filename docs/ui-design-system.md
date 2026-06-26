# UI Design System
## Luna — Period Tracker

---

## Core Principle: The App Breathes With the User

The entire visual identity — background colour, card surface, accent, text tint — shifts with the user's current cycle phase. This works in **both dark and light mode**. The user wakes up on day 14 and the app is teal and energetic whether they use dark or light theme. On day 20 it is violet and reflective. They never change a setting; the app just knows.

---

## Phase Identity

| Phase | Seed Color | Character | Typical days |
|---|---|---|---|
| **Menstrual** | `#E53E6A` deep rose | Grounding, rest-focused | 1–5 |
| **Follicular** | `#F97316` warm amber | Energising, growth | 6–13 |
| **Ovulation** | `#10B981` emerald | Vibrant, peak energy | 14–16 |
| **Luteal** | `#8B5CF6` soft violet | Reflective, nurturing | 17–28 |

---

## Full Phase Palette — Dark Mode

Dark backgrounds carry a subtle phase-hued tint. All phases start with the same deep darkness but each is pulled slightly toward its hue family. This makes the phase identity total — even the background communicates which phase you're in.

| Token | Menstrual | Follicular | Ovulation | Luteal |
|---|---|---|---|---|
| **Background** | `#1A0810` | `#1A1005` | `#071A13` | `#130D20` |
| **Surface** (cards) | `#2D1220` | `#2D1F08` | `#0D2B22` | `#1E1433` |
| **Surface raised** | `#3D1C30` | `#3D2D10` | `#153D30` | `#261A3F` |
| **Accent / Primary** | `#FF6B8A` | `#FB923C` | `#34D399` | `#A78BFA` |
| **On-surface text** | `#F8EEF2` | `#FEF3E8` | `#ECFDF8` | `#F0EBF8` |
| **Muted text** | `#9B6878` | `#9B7858` | `#4A9080` | `#9080B0` |
| **Gradient start** | `#E53E6A` | `#F97316` | `#10B981` | `#8B5CF6` |
| **Gradient end** | `#9B1B4A` | `#DC6803` | `#047857` | `#6D28D9` |

---

## Full Phase Palette — Light Mode

Light backgrounds are barely-tinted pastels — just enough to signal the phase without being garish. Accent colors are significantly darker than their dark-mode equivalents; this is required to meet WCAG AA contrast (4.5:1) on light backgrounds.

| Token | Menstrual | Follicular | Ovulation | Luteal |
|---|---|---|---|---|
| **Background** | `#FFF5F7` | `#FFFBF2` | `#F0FDF9` | `#F9F5FF` |
| **Surface** (cards) | `#FFE8EE` | `#FFF0D9` | `#D1FAF0` | `#EDE9FF` |
| **Surface raised** | `#FDDDE6` | `#FFE8C4` | `#BBFAE6` | `#E0D9FF` |
| **Accent / Primary** | `#B91C4A` | `#C2410C` | `#065F46` | `#5B21B6` |
| **On-surface text** | `#1A0010` | `#1A0F00` | `#001A10` | `#15002A` |
| **Muted text** | `#7A3050` | `#7A4520` | `#1A5040` | `#4A2070` |
| **Gradient start** | `#E53E6A` | `#F97316` | `#10B981` | `#8B5CF6` |
| **Gradient end** | `#C2185B` | `#EA6C00` | `#00897B` | `#7B1FA2` |

**Light mode gradients** (for cycle wheel) use the same start color as dark mode — the gradient reads well on both background types — but the end color is slightly adjusted to remain vibrant against the tinted surface.

---

## Flutter Implementation

### ThemeData Builder

```dart
// core/theme/app_theme.dart

import 'package:flutter/material.dart';
import 'phase_themes.dart';
import '../constants/enums.dart';

ThemeData buildTheme(CyclePhase phase, Brightness brightness) {
  // M3 generates all interactive colors (buttons, chips, ripples, focus rings)
  // with correct contrast ratios from the seed color.
  final baseScheme = ColorScheme.fromSeed(
    seedColor: phase.seedColor,
    brightness: brightness,
  );

  // We override only the surface/background tokens.
  // M3's generated values are too neutral — they lose the phase personality.
  final scheme = baseScheme.copyWith(
    surface: brightness == Brightness.dark
        ? phase.darkSurface
        : phase.lightSurface,
    surfaceContainerLowest: brightness == Brightness.dark
        ? phase.darkBackground
        : phase.lightBackground,
    surfaceContainerLow: brightness == Brightness.dark
        ? phase.darkSurfaceRaised
        : phase.lightSurfaceRaised,
    onSurface: brightness == Brightness.dark
        ? phase.darkText
        : phase.lightText,
    onSurfaceVariant: brightness == Brightness.dark
        ? phase.darkMuted
        : phase.lightMuted,
  );

  return ThemeData(
    colorScheme: scheme,
    useMaterial3: true,
    extensions: [PhaseThemeExtension.forPhase(phase, brightness)],
  );
}
```

### PhaseThemeExtension

Carries phase-specific tokens that M3 has no concept of — gradients, Lottie references, copy.

```dart
// core/theme/phase_themes.dart

@immutable
class PhaseThemeExtension extends ThemeExtension<PhaseThemeExtension> {
  const PhaseThemeExtension({
    required this.gradientStart,
    required this.gradientEnd,
    required this.lottieAsset,
    required this.phaseNameKey,      // l10n key, e.g. 'phase_menstrual'
    required this.motivationalKey,   // l10n key for motivational copy
    required this.brightness,
  });

  final Color gradientStart;
  final Color gradientEnd;
  final String lottieAsset;
  final String phaseNameKey;
  final String motivationalKey;
  final Brightness brightness;

  // Convenience accessor
  static PhaseThemeExtension of(BuildContext context) =>
      Theme.of(context).extension<PhaseThemeExtension>()!;

  static PhaseThemeExtension forPhase(CyclePhase phase, Brightness b) {
    return switch (phase) {
      CyclePhase.menstrual => PhaseThemeExtension(
          gradientStart: const Color(0xFFE53E6A),
          gradientEnd:   b == Brightness.dark
              ? const Color(0xFF9B1B4A)
              : const Color(0xFFC2185B),
          lottieAsset:   'assets/lottie/menstrual.json',
          phaseNameKey:  'phase_menstrual',
          motivationalKey: 'copy_menstrual',
          brightness: b,
        ),
      CyclePhase.follicular => PhaseThemeExtension(
          gradientStart: const Color(0xFFF97316),
          gradientEnd:   b == Brightness.dark
              ? const Color(0xFFDC6803)
              : const Color(0xFFEA6C00),
          lottieAsset:   'assets/lottie/follicular.json',
          phaseNameKey:  'phase_follicular',
          motivationalKey: 'copy_follicular',
          brightness: b,
        ),
      CyclePhase.ovulation => PhaseThemeExtension(
          gradientStart: const Color(0xFF10B981),
          gradientEnd:   b == Brightness.dark
              ? const Color(0xFF047857)
              : const Color(0xFF00897B),
          lottieAsset:   'assets/lottie/ovulation.json',
          phaseNameKey:  'phase_ovulation',
          motivationalKey: 'copy_ovulation',
          brightness: b,
        ),
      CyclePhase.luteal => PhaseThemeExtension(
          gradientStart: const Color(0xFF8B5CF6),
          gradientEnd:   b == Brightness.dark
              ? const Color(0xFF6D28D9)
              : const Color(0xFF7B1FA2),
          lottieAsset:   'assets/lottie/luteal.json',
          phaseNameKey:  'phase_luteal',
          motivationalKey: 'copy_luteal',
          brightness: b,
        ),
    };
  }

  @override
  PhaseThemeExtension copyWith({
    Color? gradientStart, Color? gradientEnd,
    String? lottieAsset, String? phaseNameKey,
    String? motivationalKey, Brightness? brightness,
  }) => PhaseThemeExtension(
    gradientStart:   gradientStart   ?? this.gradientStart,
    gradientEnd:     gradientEnd     ?? this.gradientEnd,
    lottieAsset:     lottieAsset     ?? this.lottieAsset,
    phaseNameKey:    phaseNameKey    ?? this.phaseNameKey,
    motivationalKey: motivationalKey ?? this.motivationalKey,
    brightness:      brightness      ?? this.brightness,
  );

  @override
  PhaseThemeExtension lerp(PhaseThemeExtension? other, double t) {
    if (other == null) return this;
    return PhaseThemeExtension(
      gradientStart:   Color.lerp(gradientStart, other.gradientStart, t)!,
      gradientEnd:     Color.lerp(gradientEnd, other.gradientEnd, t)!,
      lottieAsset:     other.lottieAsset,   // discrete — snap at midpoint
      phaseNameKey:    other.phaseNameKey,
      motivationalKey: other.motivationalKey,
      brightness:      other.brightness,
    );
  }
}
```

**Why `lerp` matters:** `AnimatedTheme` calls `lerp` during its 600ms crossfade. The `Color.lerp` on gradient colors produces a smooth intermediate color during the transition. Lottie asset and copy strings snap discretely at `t > 0.5`.

### AnimatedTheme in app.dart

```dart
// app.dart
Consumer(
  builder: (context, ref, child) {
    final phase    = ref.watch(currentPhaseProvider);
    final isDark   = ref.watch(themeProvider) == ThemeMode.dark;
    final brightness = isDark ? Brightness.dark : Brightness.light;

    return AnimatedTheme(
      data: buildTheme(phase, brightness),
      duration: const Duration(milliseconds: 600),
      curve: Curves.easeInOut,
      child: MaterialApp.router(routerConfig: appRouter),
    );
  },
)
```

---

## CyclePhase Extension (token access in code)

```dart
// core/constants/enums.dart

enum CyclePhase { menstrual, follicular, ovulation, luteal }

extension CyclePhaseTokens on CyclePhase {
  Color get seedColor => switch (this) {
    CyclePhase.menstrual  => const Color(0xFFE53E6A),
    CyclePhase.follicular => const Color(0xFFF97316),
    CyclePhase.ovulation  => const Color(0xFF10B981),
    CyclePhase.luteal     => const Color(0xFF8B5CF6),
  };

  Color get darkBackground => switch (this) {
    CyclePhase.menstrual  => const Color(0xFF1A0810),
    CyclePhase.follicular => const Color(0xFF1A1005),
    CyclePhase.ovulation  => const Color(0xFF071A13),
    CyclePhase.luteal     => const Color(0xFF130D20),
  };

  Color get darkSurface => switch (this) {
    CyclePhase.menstrual  => const Color(0xFF2D1220),
    CyclePhase.follicular => const Color(0xFF2D1F08),
    CyclePhase.ovulation  => const Color(0xFF0D2B22),
    CyclePhase.luteal     => const Color(0xFF1E1433),
  };

  Color get darkSurfaceRaised => switch (this) {
    CyclePhase.menstrual  => const Color(0xFF3D1C30),
    CyclePhase.follicular => const Color(0xFF3D2D10),
    CyclePhase.ovulation  => const Color(0xFF153D30),
    CyclePhase.luteal     => const Color(0xFF261A3F),
  };

  Color get darkText => switch (this) {
    CyclePhase.menstrual  => const Color(0xFFF8EEF2),
    CyclePhase.follicular => const Color(0xFFFEF3E8),
    CyclePhase.ovulation  => const Color(0xFFECFDF8),
    CyclePhase.luteal     => const Color(0xFFF0EBF8),
  };

  Color get darkMuted => switch (this) {
    CyclePhase.menstrual  => const Color(0xFF9B6878),
    CyclePhase.follicular => const Color(0xFF9B7858),
    CyclePhase.ovulation  => const Color(0xFF4A9080),
    CyclePhase.luteal     => const Color(0xFF9080B0),
  };

  Color get lightBackground => switch (this) {
    CyclePhase.menstrual  => const Color(0xFFFFF5F7),
    CyclePhase.follicular => const Color(0xFFFFFBF2),
    CyclePhase.ovulation  => const Color(0xFFF0FDF9),
    CyclePhase.luteal     => const Color(0xFFF9F5FF),
  };

  Color get lightSurface => switch (this) {
    CyclePhase.menstrual  => const Color(0xFFFFE8EE),
    CyclePhase.follicular => const Color(0xFFFFF0D9),
    CyclePhase.ovulation  => const Color(0xFFD1FAF0),
    CyclePhase.luteal     => const Color(0xFFEDE9FF),
  };

  Color get lightSurfaceRaised => switch (this) {
    CyclePhase.menstrual  => const Color(0xFFFDDDE6),
    CyclePhase.follicular => const Color(0xFFFFE8C4),
    CyclePhase.ovulation  => const Color(0xFFBBFAE6),
    CyclePhase.luteal     => const Color(0xFFE0D9FF),
  };

  Color get lightText => switch (this) {
    CyclePhase.menstrual  => const Color(0xFF1A0010),
    CyclePhase.follicular => const Color(0xFF1A0F00),
    CyclePhase.ovulation  => const Color(0xFF001A10),
    CyclePhase.luteal     => const Color(0xFF15002A),
  };

  Color get lightMuted => switch (this) {
    CyclePhase.menstrual  => const Color(0xFF7A3050),
    CyclePhase.follicular => const Color(0xFF7A4520),
    CyclePhase.ovulation  => const Color(0xFF1A5040),
    CyclePhase.luteal     => const Color(0xFF4A2070),
  };
}
```

---

## Typography

| Role | Font | Weight | Size | Usage |
|---|---|---|---|---|
| Display | Fraunces | 300–400 | 32–57sp | Phase name, screen heroes |
| Body | Plus Jakarta Sans | 400–600 | 14–16sp | All body copy, labels |
| Data | JetBrains Mono | 400 | 11–13sp | Dates, cycle day numbers, % |

---

## Navigation

5-tab `NavigationBar` (Material 3). Centre "Log" tab is styled as a floating action item.

**Tabs:** Home · Calendar · **Log** · Insights · Learn

Settings accessed via icon in Home app bar. Chat tab only rendered when `kClaudeEnabled = true`.

---

## Motion

| Surface | Animation | Duration | Trigger |
|---|---|---|---|
| Full app | `AnimatedTheme` crossfade | 600ms easeInOut | Phase change (once/day typically) |
| Home cycle wheel | Arc draw + needle rotate | 800ms ease-out-cubic | Screen mount |
| Phase Lottie | Play once on first open | 1200–2000ms | Per session |
| Charts (fl_chart) | Draw left-to-right | 500ms ease-out | Screen mount |
| Log bottom sheet | Slide up | 300ms ease-out | FAB tap |

All animations respect `MediaQuery.disableAnimations` — if true, skip to final state immediately.

---

## Motivational Copy per Phase

All strings live in `l10n/` ARB files. These are the English defaults.

| Phase | Display name | Motivational copy |
|---|---|---|
| Menstrual | Menstrual Phase | "Rest. Your body is doing powerful work." |
| Follicular | Follicular Phase | "Energy is building. A good time to start things." |
| Ovulation | Ovulation Phase | "You're at your peak. Make the most of it." |
| Luteal | Luteal Phase | "Wind down gently. Nourish yourself." |

Hindi versions in `app_hi.arb`:
- मासिक धर्म — "विश्राम करें। आपका शरीर शक्तिशाली काम कर रहा है।"
- फॉलिक्युलर — "ऊर्जा बढ़ रही है। नई शुरुआत का अच्छा समय है।"
- ओव्युलेशन — "आप अपने चरम पर हैं। इसका भरपूर उपयोग करें।"
- ल्यूटियल — "धीरे-धीरे आराम करें। अपना ख्याल रखें।"

---

## Component Specs

### Cycle Wheel
- `CustomPainter`, square aspect ratio, max 320dp wide
- Four arcs proportional to phase day-lengths, stroke 24dp, 4dp gap between phases
- Arc colors: current phase uses full gradient; other phases at 25% opacity
- Centre: cycle day number (Fraunces 300, 48sp) + "Day X of Y" (JetBrains Mono 11sp)
- Today needle: 12dp filled circle on the arc rim, phase accent color
- Works equally well on dark tinted backgrounds and light tinted backgrounds

### Insight Cards
- `Card` elevation 0, border `1dp outlineVariant`
- Left accent bar: 3dp, phase gradient start color
- Dismissible with swipe-left (marks insight as seen, removes for 7 days)

### Symptom Chips
- Material 3 `FilterChip` — fills with `secondaryContainer` when selected
- Leading emoji icon per symptom
- `Wrap` layout, `spacing: 8, runSpacing: 8`

### Flow Intensity Selector
- 4 custom tap targets in a row: Spotting · Light · Medium · Heavy
- Droplet icon, progressively fuller fill to communicate intensity
- Selected: phase accent fill, white icon, slight scale-up (1.05)
