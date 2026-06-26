# Architecture
## Luna — Period Tracker

---

## Overview

Luna uses Clean Architecture with three layers separated by strict import rules. A fourth isolated `ai/` directory feeds into the domain layer through use cases.

```
┌─────────────────────────────────────────────────────┐
│  Presentation Layer  (Flutter widgets + Riverpod)   │
│  screens/  widgets/  providers/                     │
└────────────────────────┬────────────────────────────┘
                         │ calls use cases
┌────────────────────────▼────────────────────────────┐
│  Domain Layer  (pure Dart — zero Flutter imports)   │
│  entities/  repositories (abstract)  usecases/      │
└──────────┬───────────────────────────┬──────────────┘
           │ implements                │ feeds insights via use cases
┌──────────▼──────────┐   ┌───────────▼───────────────┐
│  Data Layer         │   │  AI Layer                 │
│  Drift SQLite       │   │  TFLite cycle predictor   │
│  Firebase (opt-in)  │   │  Dart insight engine      │
│  Claude CF proxy    │   │  Claude chat wrapper      │
└─────────────────────┘   └───────────────────────────┘
```

**The rule that makes this work:** nothing in `domain/` imports anything from Flutter, `data/`, or `ai/`. Dependency injection at startup wires the concrete implementations to the abstract interfaces. This means every use case can be unit-tested without a Flutter engine, a database, or a network connection.

---

## Layer Rules

### Domain (`lib/domain/`)
- **Allowed imports:** `dart:core`, other domain files only
- **Forbidden:** `package:flutter/...`, `package:drift/...`, any data or AI package
- **Contains:** entities (plain Dart classes), repository interfaces (abstract), use cases (one per file)
- **Test approach:** pure Dart unit tests, run in milliseconds, no mocking needed for the layer itself

### Data (`lib/data/`)
- **Allowed imports:** domain interfaces it implements, Drift, Firebase, http
- **Contains:** Drift table definitions and DAOs, `CycleRepositoryImpl`, `SymptomRepositoryImpl`, Firebase sync service, Claude Cloud Function client
- **Wired to domain via:** dependency injection in `main.dart` using Riverpod `Provider`

### Presentation (`lib/presentation/`)
- **Allowed imports:** domain use cases (via Riverpod providers), Flutter, UI packages
- **Forbidden:** direct imports of data layer or AI layer
- **Contains:** screens, reusable widgets, Riverpod providers/notifiers

### AI (`lib/ai/`)
- **Allowed imports:** domain entities, tflite_flutter, http
- **Forbidden:** Flutter widgets, data layer (AI reads domain entities, not DB rows)
- **Contains:** `CyclePredictor` (TFLite wrapper), `InsightEngine` (pure Dart), `ClaudeChat` (Cloud Function client, guarded by `kClaudeEnabled`)
- **To disable entirely:** set `kClaudeEnabled = false` — zero other files change

---

## State Management

Riverpod 2 with code generation (`riverpod_annotation`).

```
CycleRepositoryProvider     → provides CycleRepository interface
    └── cycleNotifierProvider → AsyncNotifier, calls LogPeriod / GetCycles use cases
         └── currentPhaseProvider → derived, computed from active cycle entry
              └── todayCycleDayProvider → derived int
              └── phaseThemeProvider → derived ThemeData
```

All derived providers auto-update when `cycleNotifierProvider` changes. Logging a period invalidates the root; everything downstream rebuilds reactively.

---

## Navigation

GoRouter 13 with a `ShellRoute` wrapping the five bottom-nav tabs.

```
/ (redirect → /onboarding if !user.onboarded, else /home)
├── /onboarding
│   ├── /onboarding/identity
│   ├── /onboarding/cycle-basics
│   ├── /onboarding/history        (skippable)
│   ├── /onboarding/regularity     (skippable)
│   ├── /onboarding/reason         (skippable)
│   ├── /onboarding/symptoms       (skippable)
│   ├── /onboarding/lifestyle      (skippable)
│   └── /onboarding/notifications
└── /shell  (ShellRoute — bottom nav persists)
    ├── /home
    ├── /calendar
    ├── /log          (modal bottom sheet, not a full screen)
    ├── /insights
    └── /learn
        └── /learn/:articleId
    └── /settings
    └── /chat         (only rendered if kClaudeEnabled = true)
```

---

## Flutter Project Folder Map

```
luna/
├── android/                    ← Android-specific config
├── ios/                        ← iOS (empty until Phase 3)
├── assets/
│   ├── models/
│   │   └── cycle_predictor.tflite
│   ├── data/
│   │   └── phase_tips.json     ← 240+ tips, tagged by phase
│   ├── lottie/
│   │   ├── menstrual.json
│   │   ├── follicular.json
│   │   ├── ovulation.json
│   │   └── luteal.json
│   └── images/
├── l10n/
│   ├── app_en.arb              ← English strings
│   └── app_hi.arb              ← Hindi strings
├── lib/
│   ├── main.dart               ← ProviderScope, dependency injection
│   ├── app.dart                ← MaterialApp.router + AnimatedTheme
│   ├── core/
│   │   ├── constants/
│   │   │   ├── feature_flags.dart    ← kClaudeEnabled etc.
│   │   │   ├── app_strings.dart      ← non-l10n constants
│   │   │   └── enums.dart            ← CyclePhase, FlowIntensity, Mood…
│   │   ├── theme/
│   │   │   ├── app_theme.dart        ← ThemeData factory
│   │   │   ├── phase_themes.dart     ← seed colors + PhaseThemeExtension
│   │   │   └── text_styles.dart      ← Fraunces / PJS scale
│   │   ├── router/
│   │   │   └── app_router.dart       ← GoRouter definition
│   │   └── utils/
│   │       ├── cycle_calculator.dart ← pure date math, no state
│   │       └── date_extensions.dart  ← DateTime helpers
│   ├── domain/
│   │   ├── entities/
│   │   │   ├── cycle.dart
│   │   │   ├── period_log.dart
│   │   │   ├── symptom_log.dart
│   │   │   ├── mood_log.dart
│   │   │   └── user_profile.dart
│   │   ├── repositories/
│   │   │   ├── cycle_repository.dart
│   │   │   ├── symptom_repository.dart
│   │   │   ├── user_repository.dart
│   │   │   └── quota_repository.dart     ← monetization gate
│   │   └── usecases/
│   │       ├── log_period_start.dart
│   │       ├── log_period_end.dart
│   │       ├── log_symptoms.dart
│   │       ├── log_mood.dart
│   │       ├── predict_next_cycle.dart
│   │       ├── get_current_phase.dart
│   │       ├── get_symptom_patterns.dart
│   │       ├── get_phase_tips.dart
│   │       └── get_ai_insight.dart       ← guarded by kClaudeEnabled
│   ├── data/
│   │   ├── local/
│   │   │   ├── database.dart             ← Drift AppDatabase
│   │   │   ├── tables/
│   │   │   │   ├── users_table.dart
│   │   │   │   ├── cycle_entries_table.dart
│   │   │   │   ├── period_day_logs_table.dart
│   │   │   │   ├── symptom_logs_table.dart
│   │   │   │   ├── mood_logs_table.dart
│   │   │   │   ├── health_notes_table.dart
│   │   │   │   └── ai_insights_cache_table.dart
│   │   │   └── daos/
│   │   │       ├── cycle_dao.dart
│   │   │       ├── symptom_dao.dart
│   │   │       ├── mood_dao.dart
│   │   │       └── user_dao.dart
│   │   ├── remote/
│   │   │   ├── firebase_sync_service.dart
│   │   │   └── claude_cf_client.dart     ← guarded by kClaudeEnabled
│   │   └── repositories/
│   │       ├── cycle_repository_impl.dart
│   │       ├── symptom_repository_impl.dart
│   │       ├── user_repository_impl.dart
│   │       └── quota_repository_impl.dart
│   ├── presentation/
│   │   ├── screens/
│   │   │   ├── onboarding/
│   │   │   │   ├── identity_screen.dart
│   │   │   │   ├── cycle_basics_screen.dart
│   │   │   │   ├── history_screen.dart
│   │   │   │   ├── regularity_screen.dart
│   │   │   │   ├── reason_screen.dart
│   │   │   │   ├── symptoms_screen.dart
│   │   │   │   ├── lifestyle_screen.dart
│   │   │   │   └── notifications_screen.dart
│   │   │   ├── home/
│   │   │   │   └── home_screen.dart
│   │   │   ├── calendar/
│   │   │   │   └── calendar_screen.dart
│   │   │   ├── log/
│   │   │   │   └── log_bottom_sheet.dart
│   │   │   ├── insights/
│   │   │   │   └── insights_screen.dart
│   │   │   ├── learn/
│   │   │   │   ├── learn_screen.dart
│   │   │   │   └── article_screen.dart
│   │   │   ├── chat/
│   │   │   │   └── chat_screen.dart      ← only built if kClaudeEnabled
│   │   │   └── settings/
│   │   │       └── settings_screen.dart
│   │   ├── widgets/
│   │   │   ├── cycle_wheel.dart          ← CustomPainter
│   │   │   ├── phase_ribbon.dart
│   │   │   ├── symptom_chip_grid.dart
│   │   │   ├── flow_intensity_selector.dart
│   │   │   ├── insight_card.dart
│   │   │   └── phase_lottie.dart
│   │   └── providers/
│   │       ├── cycle_provider.dart
│   │       ├── ai_provider.dart
│   │       ├── theme_provider.dart
│   │       └── locale_provider.dart
│   └── ai/
│       ├── cycle_predictor.dart          ← TFLite wrapper
│       ├── insight_engine.dart           ← pure Dart pattern mining
│       └── claude_chat.dart             ← kClaudeEnabled guard
├── test/
│   ├── domain/
│   │   └── cycle_calculator_test.dart
│   └── ai/
│       └── insight_engine_test.dart
└── functions/                            ← Firebase Cloud Function (Node.js)
    └── src/
        └── chat.js                       ← Claude API proxy
```
