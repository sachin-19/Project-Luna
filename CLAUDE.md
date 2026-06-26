# Luna — Period & Cycle Tracker
## Claude Context File

> This file is auto-loaded by Claude Code at the start of every session.
> Keep it current. Every significant decision, change, or new spec belongs here or in `docs/`.

---

## What We're Building

**Luna** is a period and menstrual cycle tracker Android app for women and girls of all ages (13–45+), built with Flutter. The closest reference point is the Flow app. India is the primary market. The app is free at launch, architected to be monetized later with minimal code change.

**Current status:** Planning & architecture complete. No Flutter project created yet. Ready to start coding.

---

## Project Structure (Repository)

```
Project Flow/           ← this repository root
├── CLAUDE.md           ← you are here (auto-loaded context)
├── docs/
│   ├── architecture.md         ← Clean Architecture, layer rules, folder map
│   ├── decisions.md            ← ADR log — every architectural decision recorded
│   ├── ui-design-system.md     ← Phase theming, full dark+light palette, typography
│   ├── onboarding-spec.md      ← 8-screen onboarding flow, all questions
│   ├── ai-features.md          ← All 4 AI features, accuracy notes, API proxy
│   ├── roadmap.md              ← Phase 1/2/3 feature lists, implementation order
│   ├── database-schema.md      ← All 7 Drift tables, columns, types, relationships
│   └── update-system.md        ← In-app APK update: version.json, download flow, manifest
└── luna/               ← Flutter project (to be created)
```

---

## Tech Stack (Locked)

| Layer | Technology |
|---|---|
| Framework | Flutter 3.x + Dart 3 (sound null safety) |
| State management | Riverpod 2 + riverpod_annotation (code-generated) |
| Navigation | GoRouter 13 (declarative, shell route for bottom nav) |
| Local database | Drift 2 (type-safe SQLite) |
| Settings/prefs | Hive Flutter |
| On-device ML | Pure Dart Bayesian estimator (no ML package — TFLite rejected, see ADR-010) |
| AI chatbot | Claude API via Firebase Cloud Function proxy *(hidden for now — no key yet)* |
| Cloud sync | Firebase (opt-in only, off by default) |
| In-app updates | Custom: `UpdateService` fetches `version.json`, `dio` downloads APK, `open_filex` installs |
| Charts | fl_chart 0.69 |
| Animations | flutter_animate 4 + Lottie |
| Fonts | Google Fonts — Fraunces (display) + Plus Jakarta Sans (body) + JetBrains Mono (data) |
| Notifications | flutter_local_notifications 17 |
| Secure storage | flutter_secure_storage 9 |

---

## Key Decisions (summary — full log in `docs/decisions.md`)

1. **Flutter over Native Kotlin** — cross-platform, iOS later requires near-zero extra work
2. **Local-first, Firebase opt-in** — health data stays on device by default; cloud sync is an explicit user choice
3. **Clean Architecture with isolated AI layer** — `ai/` directory has no presentation imports; swappable without touching domain or UI
4. **Claude API hidden behind feature flag** — `kClaudeEnabled = false` in `core/constants/feature_flags.dart`; full architecture exists, UI entry point commented out
5. **Phase theming via `colorSchemeSeed`** — one seed color per cycle phase drives the entire M3 color scheme; `AnimatedTheme` crossfades over 600ms on phase change
6. **Backend proxy for Claude** — Firebase Cloud Function holds the API key server-side; APK contains zero secrets
7. **Monetization-ready via `QuotaRepository` abstraction** — adding premium is a Firestore flag + RevenueCat SDK; no UI or chat logic changes needed
8. **India-first** — Hindi (`hi`) locale from day one, Indian helplines in safety section, IST timezone default, UPI-ready billing path
9. **TFLite rejected — Bayesian Gaussian updating in pure Dart**
10. **Phase theming covers both dark and light mode** — each has phase-tinted surfaces (not neutral black/white); light accent colors are darker variants of dark-mode seeds to maintain WCAG AA contrast (see ADR-012)
11. **In-app update system for APK distribution** — `UpdateService` fetches `version.json` on startup, `dio` downloads with progress, `open_filex` triggers system installer. Mandatory/optional distinction. 24h cooldown for optional. (see ADR-011) — no pre-training dataset needed, outperforms LSTM at low data volumes (< 15 cycles), natural confidence intervals, zero dependencies (see ADR-010)

---

## AI Features (summary — full spec in `docs/ai-features.md`)

| Feature | Runs where | Cost | Status |
|---|---|---|---|
| Cycle prediction | On-device (TFLite LSTM) | ₹0 | Build in Phase 1+2 |
| Symptom pattern insights | On-device (pure Dart) | ₹0 | Build in Phase 2 |
| Phase tips (static library) | On-device (JSON asset) | ₹0 | Build in Phase 1 |
| AI health chatbot | Firebase CF → Claude API | ~₹0.07/conversation | **Hidden — Phase 2/3** |

---

## Phase Theming (summary — full spec in `docs/ui-design-system.md`)

The entire app color scheme shifts with the user's current cycle phase.
`colorSchemeSeed` is set at the `MaterialApp` level; every M3 widget inherits it automatically.

| Phase | Seed color | Tone |
|---|---|---|
| Menstrual | `#E53E6A` | Deep rose |
| Follicular | `#F97316` | Warm amber |
| Ovulation | `#10B981` | Emerald |
| Luteal | `#8B5CF6` | Soft violet |

---

## Onboarding (summary — full spec in `docs/onboarding-spec.md`)

8 screens. 3 required, 5 skippable. Goal: seed the prediction model and personalization engine from day one.
Key insight: entering 2–3 past period dates on Screen 3 improves prediction accuracy ~40% immediately.
Contraceptive use (Screen 7) triggers a different prediction algorithm branch.

---

## Coding Conventions

- `domain/` has **zero Flutter imports** — pure Dart, testable headlessly
- No raw SQL — all queries through Drift-generated DAOs
- Feature flags live in `core/constants/feature_flags.dart`
- All Claude API calls guarded by `if (kClaudeEnabled)`
- Phase theming tokens accessed via `PhaseThemeExtension.of(context)`, never hardcoded hex in widgets
- Locale strings in `l10n/` — never hardcode user-facing strings in widget code
- One use case per file in `domain/usecases/`

---

## Documentation Rules (for Claude)

- **Every decision made in conversation → logged in `docs/decisions.md`** immediately
- **Every new spec or screen design → its own file in `docs/`**
- **Every implemented feature → status updated in `docs/roadmap.md`**
- **Every schema change → `docs/database-schema.md` updated**
- Do this without being asked. It is a standing instruction.
