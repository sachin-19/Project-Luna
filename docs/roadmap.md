# Build Roadmap
## Luna — Period Tracker

---

## Status Legend
- `[ ]` Not started
- `[~]` In progress
- `[x]` Complete

---

## Phase 1 — MVP (Weeks 1–8) ✓ COMPLETE
*Goal: A fully usable period tracker that works offline, looks beautiful, and earns daily use.*

### Foundation (Week 1–2)
- [x] Flutter project created (`flutter create --platforms android luna`)
- [x] pubspec.yaml with all Phase 1 dependencies
- [x] `core/constants/feature_flags.dart` — `kClaudeEnabled = false`
- [x] `core/constants/enums.dart` — `CyclePhase`, `FlowIntensity`, `Mood`, `Symptom`
- [x] `core/theme/phase_themes.dart` — seed colors + `PhaseThemeExtension`
- [x] `core/theme/app_theme.dart` — `buildTheme(CyclePhase, Brightness)`
- [x] `core/router/app_router.dart` — all routes defined, onboarding gate
- [x] `core/utils/cycle_calculator.dart` — pure date math + `BayesianCycleEstimator`
- [x] `l10n/app_en.arb` and `l10n/app_hi.arb` — full strings (en + hi)

### Database (Week 2)
- [x] Drift `AppDatabase` class defined
- [x] All 7 table definitions (`@DataClassName` to avoid name collisions)
- [x] All 4 DAOs with initial queries (UserDao, CycleDao, SymptomDao, MoodDao)
- [x] `build_runner` generating type-safe query code
- [x] Schema version 1 migration strategy written
- [x] `UserRepositoryImpl`, `CycleRepositoryImpl`, `SymptomRepositoryImpl`, `MoodRepositoryImpl`

### Domain Layer (Week 2–3)
- [x] All 5 entity classes (CycleEntry, PeriodDay, SymptomLog, MoodLog, User)
- [x] All repository abstract interfaces
- [x] `BayesianCycleEstimator` persisted via `CycleEstimatorService` (Hive)
- [x] `SaveOnboarding` use case — writes all 8 screens of data to DB atomically
- [x] `currentPhaseProvider` — derives live phase from active cycle

### Onboarding Screens (Week 3–4)
- [x] Screen 1 — Identity
- [x] Screen 2 — Cycle Basics
- [x] Screen 3 — Cycle History (skippable)
- [x] Screen 4 — Regularity (skippable)
- [x] Screen 5 — Reproductive Status (skippable) ← NEW
- [x] Screen 6 — Biometrics: Height + Weight (skippable) ← NEW
- [x] Screen 7 — Reason (skippable)
- [x] Screen 8 — Common Symptoms (skippable)
- [x] Screen 9 — Lifestyle (skippable)
- [x] Screen 10 — Notifications (saves to DB + redirects to /home)
- [x] `OnboardingScaffold` — shared progress bar + layout (totalSteps updated to 10)
- [x] GoRouter gate: redirect to onboarding if `!user.onboarded`
- [x] Data written to DB atomically on Screen 10 completion

### Home Screen (Week 4–5)
- [x] `CycleWheel` — `CustomPainter` with four phase arcs + today needle
- [x] `CycleWheel` rotation animation (800ms ease-out-cubic on load)
- [x] Phase name display (Fraunces display font)
- [x] Phase motivational copy (from `PhaseThemeExtension`)
- [x] Quick-action chips: "Log today" / "See prediction" / "View tips"
- [x] App bar with Settings icon
- [x] `PredictionCard` — next period date range, confidence, cycles tracked
- [x] Phase insight tip card

### Calendar Screen (Week 5)
- [x] Month view with phase-coloured date cells
- [x] Period day highlighting (flow intensity colour intensity)
- [x] Predicted period days shown with outline style
- [x] Tap a date → bottom sheet with that day's logs

### Log Bottom Sheet (Week 5–6)
- [x] `DraggableScrollableSheet`, 75% height initial, full screen drag
- [x] 3 tabs: Period · Symptoms · Mood
- [x] Period tab: `FlowIntensitySelector` (4 flow levels, tap-to-select)
- [x] Symptoms tab: `FilterChip` grid, pre-seeded from user's `common_symptoms`
- [x] Severity slider per selected symptom (1–5)
- [x] Mood tab: 6 mood buttons + energy slider
- [x] Free-text note field (shared across tabs)
- [x] "Save" writes all three logs in a single DB transaction
- [x] Period tab: "Period ended today" button — explicitly closes active cycle with accurate `periodLength`
- [x] Period tab: window restriction — flow logs blocked for dates before `cycle.startDate`
- [x] Period tab: "Wrong start date? Edit" — corrects active cycle `startDate`, deletes orphaned logs (ADR-027)
- [x] No-period view: "Period still going? Correct end date" — 7-day edit window for last completed cycle (ADR-027)

### Phase Theming Integration (Week 6)
- [x] `AnimatedTheme` wrapping entire app in `app.dart`
- [x] `currentPhaseProvider` drives theme change automatically
- [x] `ThemeProvider` (Riverpod) exposes brightness toggle
- [x] Phase transition felt smoothly across all widgets

### Phase Tips — Static (Week 6–7)
- [x] `assets/data/phase_tips.json` — 60 tips × 4 phases, with Hindi translations
- [x] `GetPhaseTips` use case — returns 3 tips for current phase (rotated by cycle number)
- [x] Tips card on Home screen
- [x] Full tips list accessible from Home

### Notifications (Week 7)
- [x] Period reminder — 2 days before predicted start
- [x] Ovulation window alert
- [x] Daily check-in nudge (configurable time)
- [x] Notifications respect `users.notifications_*` toggles

### In-App Update System (Week 7)
- [x] `domain/entities/update_info.dart`
- [x] `data/remote/update_service.dart` — fetch + download via `dio`, `open_filex` install
- [x] `presentation/providers/update_provider.dart` — 500ms delay on mount, 24h cooldown for optional
- [x] `presentation/widgets/update_bottom_sheet.dart` — progress bar, mandatory lock, dismiss for optional
- [x] `AndroidManifest.xml` — `INTERNET` + `REQUEST_INSTALL_PACKAGES` + FileProvider
- [x] `android/app/src/main/res/xml/file_paths.xml` — external-files-path declaration
- [x] `update/version.json` — initial manifest at repo root
- [x] Release workflow documented and tested end-to-end on a device

### Polish & Testing (Week 8)
- [x] Hindi strings complete in `app_hi.arb` (37 keys added, wired across all screens)
- [x] Light mode fully tested (theme switcher rewrite verified on device)
- [x] All screens work without a logged cycle (empty states verified)
- [x] Unit tests: `cycle_calculator_test.dart` (27 tests) + `bayesian_estimator_test.dart` (24 tests, including new reproductive priors)
- [x] Widget test: onboarding flow end-to-end (15 tests in `onboarding_test.dart`)
- [x] APK build tested on a physical Android device (release build, 63.1 MB)

---

## Phase 2 — Intelligence (Weeks 9–14) ✓ COMPLETE
*Goal: The app learns the user. Predictions improve, patterns surface, AI tips personalise.*

### Bayesian Cycle Predictor — Full Version (Week 9–10)
*(Phase 1 ships the base estimator; this phase adds PCOS branch and UI polish)*
- [x] PCOS variant: Student-t prior, wider variance, outlier-resistant update
- [x] Hormonal contraception: fixed-interval mode, deterministic prediction
- [x] Confidence interval displayed as date range in all relevant UI surfaces
- [x] "Prediction accuracy" tracker: "Luna has predicted X of your last Y cycles within 3 days"
- [x] `lib/ai/cycle_predictor.dart` fully unit-tested including edge cases (very short/long cycles, gaps)

### Symptom Insight Engine (Week 10–11)
- [x] `lib/ai/insight_engine.dart` — phase affinity algorithm
- [x] All 6 insight types implemented
- [x] Minimum data thresholds enforced
- [x] `InsightCard` widget — accent bar, icon, one-line insight, expandable
- [x] Insights shown on Home screen (2 cards) + full list on Insights screen

### Insights Screen (Week 11–12)
- [x] Cycle length trend — `fl_chart LineChart`
- [x] Symptom frequency by phase — `fl_chart BarChart`
- [x] Mood over current cycle — `fl_chart LineChart`
- [x] Symptom-phase heatmap — custom Container widget grid
- [x] Phase distribution donut — `fl_chart PieChart`
- [x] Prediction accuracy tracker ("Luna has predicted X of your last Y cycles within 2 days")

### Personalised Phase Tips with Claude (Week 12)
- [x] `lib/ai/claude_chat.dart` — stub implemented, guarded by `kClaudeEnabled`
- [x] `GetAiInsight` use case — offline symptom-affinity scorer; Claude path when flag on
- [x] `ai_insights_cache` write/read for tips (Hive `'ai_cache'` box, cycle-scoped key)
- [x] Offline fallback (static library tips) verified working

### Learn Screen — Health Library (Week 13)
- [x] Article model and local JSON asset (13 articles in `assets/data/articles.json`)
- [x] Articles tagged by: phase, topic (nutrition/exercise/emotional/safety)
- [x] Home page of Learn: featured article + topic/phase filter chips
- [x] Article detail screen (custom `SimpleMarkdownBody` Markdown renderer)
- [x] Safety section: Indian helplines, body safety basics, POCSO awareness
- [x] Youth content gate: users under 18 see age-appropriate content

### Data Export (Week 13–14)
- [x] Export as JSON — full data dump (pretty-printed, all entities)
- [x] Export as CSV — cycle history only
- [x] Share via Android share sheet (`share_plus`)

### Phase 2 Polish (Week 14)
- [x] Insight engine tests: `insight_engine_test.dart` (22 tests — all 6 insight types covered)
- [x] Lottie animations: minimal placeholder JSON per phase; real animations to source from lottiefiles.com pre-launch *(runtime asset swap, no code change needed — `errorBuilder` fallback always active)*
- [x] Performance: insights engine runs on background isolate via `compute()` (see `insight_provider.dart`)
- [~] Fraunces + Plus Jakarta Sans font verification — requires visual check on a physical Android device; cannot be automated

---

## Phase 3 — Platform (Weeks 15–20) ← CURRENT
*Goal: Sync, extend, and prepare for Play Store.*

### Firebase Cloud Sync (Week 15)
- [ ] Firebase project created
- [ ] `firebase_auth` — anonymous auth by default, email sign-in optional
- [ ] `cloud_firestore` — sync triggered only when `cloud_sync_enabled = true`
- [ ] Conflict resolution: device wins (last-write wins on cycle entries)
- [ ] Sync status indicator in Settings

### Android Home Screen Widget (Week 16)
- [x] Glance API widget — shows current phase, cycle day, days until next period
- [x] Updates daily (WorkManager `PeriodicWorkRequest`, 1-day interval)

### Claude Chat Screen (Week 17)
- [ ] `kClaudeEnabled` flipped to `true` (API key in Firebase environment config)
- [ ] `functions/src/chat.js` Cloud Function deployed
- [ ] Chat screen UI — bubble layout, phase context shown above input
- [ ] Quota UI — "8 questions remaining today"
- [ ] Age-appropriate system prompts verified

### Doctor Export — PDF (Week 17–18)
- [x] PDF generation of 3-month cycle + symptom summary
- [x] Share via Android share sheet

### Play Store Release (Week 19–20)
- [ ] Privacy policy page (required for health apps)
- [ ] Play Store listing: screenshots, description (English + Hindi)
- [ ] App signing configured
- [ ] App Check enabled on Firebase
- [ ] Final QA on 3 Android devices (budget / mid-range / flagship)

---

## Future Features (Post-Launch)

These are designed into the architecture but not in any phase:

| Feature | Notes |
|---|---|
| iOS expansion | Flutter = near-zero extra work; add HealthKit integration |
| Wear OS companion | Phase tile + quick log on the watch |
| PCOS/Endo deep tracking | Pain mapping, separate symptom vocabulary |
| Fertility mode | BBT, CM, OPK logging; fertile window confidence |
| Pregnancy mode | Week-by-week tracker replacing cycle wheel |
| Perimenopause mode | Irregular cycle tolerance, hot flash logging |
| Anonymous community | Phase-gated forums, moderated by Claude content filters |
| Partner/doctor sharing | Phase share link, gynaecologist PDF |
| Nutrition planner | Phase-specific meal suggestions |
| Period product tracker | Usage logging, smart change reminders |
| Health Connect integration | Pull heart rate and sleep data for cycle correlations |
| Federated model update | Improved TFLite model via Firebase Remote Config |
| Streak and gamification | Consistency rewards, logging badges |
| Premium tier | RevenueCat + Google Play billing; unlimited Claude chat |
