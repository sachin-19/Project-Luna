# Architecture Decision Records
## Luna — Period Tracker

> One entry per significant decision. Newest at the top. Never delete entries — mark superseded ones as `[SUPERSEDED by ADR-XXX]`.

---

## ADR-028 · Expanded onboarding: reproductive status + biometrics screens
**Date:** 2026-06-26
**Status:** Accepted

**Problem:** The original 8-screen onboarding collected cycle regularity and PCOS/endo status but nothing about postpartum, breastfeeding, perimenopause, or body composition. These are major confounders for cycle length prediction — a breastfeeding user's estimator should start at 45 days with high variance, not 28 days.

**Decision:** Add two new skippable screens between Regularity (screen 4) and Reason (previously screen 5):

1. **Screen 5 — Reproductive Status**: 6-option single-select (`normal`, `tryingToConceive`, `pregnant`, `postpartum`, `breastfeeding`, `perimenopause`). Stored in `users.reproductive_status`.

2. **Screen 6 — Biometrics**: Optional height (cm) and weight (kg). Plausibility range-checked (height 100–250 cm, weight 20–300 kg). Stored in `users.height_cm` and `users.weight_kg`. A privacy note ("Stored only on your device. Never shared.") is shown inline.

**Estimator prior branch logic** (applied in `SaveOnboarding` before any historical observations):

| Condition | Prior |
|---|---|
| `hasPcos = true` | PCOS: mean=35, σ²=144 (always takes priority) |
| `postpartum` | mean=35, σ²=225 (cycles slow to return) |
| `breastfeeding` | mean=45, σ²=400 (prolactin suppresses ovulation) |
| `perimenopause` | mean=40, σ²=225 (increasing variability) |
| `pregnant` | Default (predictions irrelevant during pregnancy) |
| `normal` / `tryingToConceive` + BMI < 18.5 | mean=30, σ²=49 (underweight irregularity) |
| `normal` / `tryingToConceive` + BMI 25–30 | mean=30, σ²=20.25 (slight lengthening) |
| `normal` / `tryingToConceive` + BMI ≥ 30 | mean=32, σ²=36 (obese, more irregular) |
| `normal` / `tryingToConceive` + normal BMI | Default (mean=28, σ²=12.25) |

**Data model additions:** `users` table: `reproductive_status TEXT DEFAULT 'normal'`, `height_cm INTEGER NULL`, `weight_kg REAL NULL`. `ReproductiveStatus` enum added to `core/constants/enums.dart`. `User` entity updated with 3 new fields. `OnboardingData` updated with 3 new fields and setters.

**Trade-off:** More screens increase drop-off risk. Both new screens are skippable (secondary "Skip for now" action) so no one is forced to answer. The prediction benefit is significant — a breastfeeding user starting at mean=28 would show false-positive "late period" warnings within the first post-partum cycle.

---

## ADR-027 · Cycle date editing with time-bounded windows
**Date:** 2026-06-26
**Status:** Accepted

**Problem:** Users who tapped "Period started" on the wrong date or tapped "Period ended today" too early had no way to correct the mistake. There was also no restriction preventing period flow logs from being saved on dates before the current cycle started, which would silently corrupt `periodLength`.

**Decision:**

1. **Active cycle start date editing**: Allow correcting `startDate` while the cycle is still open (no `endDate`). The new date must be ≤ today, ≤ 30 days back, and > the previous completed cycle's `endDate`. Any `period_day_logs` before the new start date are deleted. The Bayesian estimator is NOT touched — it only updates when a cycle closes via `StartNewCycle`.

2. **Completed cycle end date editing**: Allow correcting `endDate` of the **most recently completed** cycle within 7 days of it being set. The new date must be ≤ today, ≥ `cycleStart`, and < the next cycle's `startDate`. `period_day_logs` after the new end date are deleted; `periodLength` is recalculated from remaining rows. Only the most recent cycle is editable — editing older cycles would corrupt the Bayesian posterior (it's append-only).

3. **Period log window restriction**: `period_day_logs` may only be saved for dates within `[cycle.startDate, today]`. If a user opens the log sheet for a date before the current cycle's start, the Period tab shows an informational message instead of the flow selector.

**UI entry points:**
- "Wrong start date? Edit" — small `TextButton` in the Period tab when `isToday` and cycle is active.
- "Period still going? Correct end date" — small `TextButton` in the no-active-cycle view when `isToday` and the last completed cycle is within the 7-day edit window.

**Trade-off:** More permissive apps (Flo, Clue) allow editing any historical cycle date. Luna restricts this because the Bayesian estimator is an on-device append-only posterior — retroactive edits to `cycleLength` (start→next start) would leave the estimator in an inconsistent state relative to the database with no way to retrain.

---

## ADR-026 · Onboarding history seeding with period_day_logs and estimator observations
**Date:** 2026-06-26
**Status:** Accepted

**Problem:** The original `save_onboarding.dart` stored past period start dates in `cycle_entries` but never created `period_day_logs` for historical periods and never fed the Bayesian estimator with those cycle lengths. As a result, first predictions were always the cold population prior (28 days) regardless of how much history the user entered.

**Decision:** Rewrote `save_onboarding.dart` to:
1. Create `period_day_logs` (flow = 'medium') for every day of every historical period.
2. For completed cycles: call `estimator.observe(cycleLength)` in chronological order after inserting the cycle row.
3. Added per-period duration input (Slider, 2–10 days) to the onboarding history screen so actual period lengths are stored rather than a flat default.
4. Added `insertSeededCycle()` to `CycleRepository` for inserting completed historical cycles with all fields set.

---

## ADR-025 · "Period ended today" button in log sheet period tab
**Date:** 2026-06-26
**Status:** Accepted

**Problem:** Period end had no explicit UI path. The only way to close an active cycle was to start a new period, which set `endDate = newStart - 1 day`. Users whose period ended before starting the next one were stuck in the menstrual phase until the next period start was logged, regardless of actual flow end.

**Decision:** Add a full-width outlined "Period ended today" button at the bottom of the Period tab in the log bottom sheet. It is only shown when `hasActiveCycle && isToday`, so it never appears on past-date log views or when no cycle is active.

**Flow on tap:**
1. Confirmation `AlertDialog` ("End period?" with Cancel / End period).
2. `LogNotifier.endPeriod()`: saves today's flow log if one was selected, queries `getPeriodDaysForCycle()` for accurate `periodLength`, calls `updateCycleEnd(id, today, periodDays.length)`.
3. Sheet closes; snackbar confirms.

**`periodLength` accuracy:** uses the count of actual `period_day_logs` rows for this cycle, not date math — same approach as `StartNewCycle` use case.

**Reactive update:** `activeCycleProvider` is a Drift stream (`watchActiveCycle`); it emits `null` automatically when the cycle's `endDate` is set, so the home screen and phase providers update without manual invalidation.

**Affected files:**
- `lib/presentation/widgets/log_bottom_sheet.dart` — `_EndPeriodButton` widget
- `lib/presentation/providers/log_provider.dart` — `LogNotifier.endPeriod()`
- `l10n/app_en.arb`, `l10n/app_hi.arb` — 5 new strings

---

## ADR-023 · Drift upsert uses explicit `DoUpdate` conflict targets, not `insertOnConflictUpdate`
**Date:** 2026-06-25
**Status:** Accepted

**Problem:** `insertOnConflictUpdate` in Drift 2.x generates `ON CONFLICT DO UPDATE SET` SQL. When the companion does not include `id` (i.e., it is auto-increment and absent), the conflict target resolves to the primary key only. If the conflict fires on a *secondary* unique key (`uniqueKeys` — e.g. `(date, symptom)` in `symptom_logs`), SQLite raises an unhandled constraint violation and the entire `db.transaction()` block aborts, causing the save to fail silently (caught by `catch (_)`, returns false, shows "could not save" snackbar).

**Decision:** Replace all three `upsert*` DAO methods with `into(table).insert(companion, onConflict: DoUpdate((_) => companion, target: [...]))` using the exact columns from `uniqueKeys` as the conflict target. This generates `ON CONFLICT (col1, col2) DO UPDATE SET ...`, which correctly handles secondary unique-key conflicts.

**Affected DAOs:**
- `SymptomDao.upsertSymptom` → target `(date, symptom)`
- `CycleDao.upsertPeriodDay` → target `(cycleEntryId, date)`
- `MoodDao.upsertMood` → target `(date)`

**Side effects:** None. The UPDATE SET clause uses the incoming companion values (all columns except the absent `id`), preserving the existing row's primary key. Behaviour is identical to the intended upsert for all new inserts; for re-saves it now correctly updates the existing row instead of throwing.

**Also fixed in same release:**
- `LogState.hasAnyData` no longer counts auto-populated symptoms (pre-filled from profile, never explicitly interacted with) as real data; prevents a spurious save attempt when the user opens the log sheet and taps Save without touching anything.
- `LogNotifier.save()` now calls `_ref.invalidate(insightsProvider)` after a successful save, forcing the `FutureProvider.autoDispose` to re-compute on next watch — fixes Patterns/Insights screen not refreshing after logging.
- `catch (_)` → `catch (e, s)` + `debugPrint` in `save()` for diagnosability.

---

## ADR-024 · `period_day_logs` added to Firestore sync; credential manager popup suppressed on auto-sign-in
**Date:** 2026-06-25
**Status:** Accepted

**Problem 1 — period_day_logs missing from cloud sync:**
`SyncService.pushAll()` and `restoreAll()` synced user profile, cycle entries, symptom_logs, and mood_logs, but omitted `period_day_logs` (per-day flow intensity). Restoring on a new device recovered the cycle shell but lost all flow data.

**Decision:** Push period days to a `period_day_logs` sub-collection. Document ID is `{cycleStartDate}_{date}` (e.g. `2024-05-28_2024-05-28`) — content-addressed and stable across devices. Each document stores `cycleStartDate`, `date`, and `flow`.

On restore, the cycle-restore loop now builds a `cycleStartDate → newLocalId` map. Period days are then restored using that map to re-link `cycleEntryId` (local auto-increment FK) correctly. If cycles were already present (partial restore scenario), the map is built from the existing local db instead.

**Problem 2 — "Save password?" popup on every auto-sign-in:**
`_tryAutoSignIn()` retrieved credentials from Android Credential Manager then called `_submit()`, which unconditionally called `CredentialService.saveCredentials()`. This triggered the OS "Save password?" bottom sheet even though the credentials were already stored.

**Decision:** Add `_fromCredentialManager` boolean flag to `_SignInScreenState`. Set it to `true` (with `try/finally` reset) before calling `_submit()` from `_tryAutoSignIn()`. In `_submit()`, skip `saveCredentials` when the flag is set. Manual sign-in (button tap) continues to save credentials as before.

**Affected files:**
- `lib/data/services/sync_service.dart` — pushAll + restoreAll extended
- `lib/presentation/screens/auth/sign_up_screen.dart` — `_SignInScreenState`

---

## ADR-022 · Doctor Export — PDF via `pdf` package
**Date:** 2026-06-25
**Status:** Accepted

**Problem:** Doctors and gynaecologists need a readable summary of a patient's cycle history, symptoms, and mood to inform clinical decisions. Raw JSON/CSV exports are not appropriate for a clinical handoff.

**Decision:** Generate a formatted A4 PDF using the `pdf` package (pure Dart, no native deps). The report covers the last 90 days and includes: cycle summary stats, cycle history table, symptom frequency bars, and mood distribution tiles. Shared via the standard Android share sheet (`share_plus`).

**Content window:** 90 days for symptoms and moods (precise query range passed to DAOs). For cycles: 90-day window, supplemented with up to 3 older cycles when fewer than 2 completed cycles fall in the window (avoids near-empty reports for users with long/irregular cycles).

**Design:** A4, 50px horizontal margins, rose (#E53E6A) accent for section headers and symptom bars, Helvetica built-in fonts (no font embedding = smaller file). Footer disclaimer on every page.

**Architecture:**
- `lib/data/services/pdf_service.dart` — builds `Uint8List` from user + data. Zero Flutter imports (pure Dart).
- `ExportService.sharePdf()` — calls `PdfService`, writes to temp directory, shares via `Share.shareXFiles`.
- `settings_screen.dart` — "Doctor report (PDF)" tile at the top of the Data section, with loading spinner while generating.

**New package:** `pdf: ^3.11.x` (pure Dart, no native Android/iOS code)
**New file:** `lib/data/services/pdf_service.dart`
**Modified:** `lib/data/services/export_service.dart`, `lib/presentation/screens/settings/settings_screen.dart`
**APK size delta:** +1.8 MB (71.3 MB total)

---

## ADR-021 · Android Home Screen Widget — Glance API + WorkManager
**Date:** 2026-06-25
**Status:** Accepted

**Problem:** Users need cycle-phase context at a glance without opening the app. A home screen widget should show the current phase, cycle day, and days until next period, and stay accurate even when the app hasn't been opened in days.

**Decision:** Implement a native Android widget using Jetpack Glance 1.1.0 (Compose-like declarative API for app widgets). Use WorkManager `PeriodicWorkRequest` (1-day interval) for the daily background recalculation. Bridge Flutter → native via the `home_widget` package (writes to `HomeWidgetPreferences` SharedPreferences).

**Architecture:**
- **Flutter side:** `lib/data/services/widget_service.dart` — `WidgetService.update()` writes 7 keys to SharedPreferences via `home_widget` package and triggers `HomeWidget.updateWidget()`. Called from `HomeScreen.initState()` and whenever `activeCycleProvider` changes.
- **Kotlin — widget:** `LunaWidget.kt` (GlanceAppWidget) reads SharedPreferences on every render; `LunaWidgetReceiver.kt` (GlanceAppWidgetReceiver) is the system entry point.
- **Kotlin — daily update:** `LunaWidgetUpdateWorker.kt` (CoroutineWorker) recalculates `luna_cycle_day` and `luna_days_until_period` from the stored epoch-ms cycle start date, then calls `LunaWidget().updateAll()`. Scheduled in `MainActivity.onCreate()` via `WorkManager.enqueueUniquePeriodicWork(KEEP)`.

**SharedPreferences keys (file: `HomeWidgetPreferences`):**
| Key | Type | Content |
|---|---|---|
| `luna_phase` | String | `"menstrual"` \| `"follicular"` \| `"ovulation"` \| `"luteal"` |
| `luna_phase_name` | String | e.g. `"Menstrual Phase"` |
| `luna_cycle_day` | Int | Current day (1-indexed), 0 if no cycle |
| `luna_days_until_period` | Int | Days until predicted next period |
| `luna_has_cycle` | Boolean | Whether an active cycle exists |
| `luna_cycle_start_ms` | String | Epoch ms of cycle start (for WorkManager recalc) |
| `luna_cycle_length` | Int | User's average cycle length (default 28) |

**Visual design:** Phase-tinted dark background matching app dark-mode colors per phase; white cycle day number (26sp bold); phase name in phase accent color; "N days until period" in 70%-opacity white.

**Build changes:**
- `settings.gradle.kts` — added `org.jetbrains.kotlin.plugin.compose:2.3.20`
- `app/build.gradle.kts` — `buildFeatures { compose = true }`, Glance 1.1.0, WorkManager 2.9.1
- `AndroidManifest.xml` — `LunaWidgetReceiver` registered with `APPWIDGET_UPDATE` intent filter + provider metadata
- APK size delta: +0.8 MB (69.5 MB total)

**New files:** `LunaWidget.kt`, `LunaWidgetReceiver.kt`, `LunaWidgetUpdateWorker.kt`, `res/xml/luna_widget_info.xml`, `res/values/strings.xml`, `lib/data/services/widget_service.dart`

---

## ADR-020 · Android Credential Manager — Passkey / Password Autofill
**Date:** 2026-06-25
**Status:** Accepted

**Problem:** Entering an email + password on every login is friction. Users on an Android device with biometrics expect to authenticate with fingerprint or face ID once they've created an account.

**Decision:** Integrate `credential_manager 2.0.8` (wraps `androidx.credentials`). Feature uses **password credentials only** — no passkeys (passkeys require a FIDO2 relying-party server and domain-linked `assetlinks.json`, which Luna doesn't have yet).

**Flow:**
- **After sign-up:** `CredentialService.instance.saveCredentials(email, password)` — fires Android's "Save password?" bottom sheet over the onboarding screen.
- **Sign-in screen opens:** `_tryAutoSignIn()` calls `CredentialService.instance.getCredentials()` — Android shows the saved-account picker with biometric confirmation. On success, fields are auto-filled and `_submit()` fires automatically.
- **After manual sign-in:** `saveCredentials()` fires again to keep credentials fresh (or prompt save if first time on this device).

**What "biometric login" means here:** Android's Credential Manager gates `getCredentials()` behind the device lock screen (fingerprint / face / PIN). The user picks their saved account, confirms with biometrics → app gets the plaintext email+password → Firebase `signInWithEmailAndPassword`. No crypto key material leaves the device. True passkeys (zero-knowledge challenge/response) are a future phase once a relying-party backend exists.

**New package:** `credential_manager: ^2.0.8`
**New file:** `lib/data/services/credential_service.dart`
**Modified:** `lib/presentation/screens/auth/sign_up_screen.dart`

---

## ADR-019 · Email-First Auth — No Anonymous Sessions
**Date:** 2026-06-25
**Status:** Accepted — supersedes ADR-002 (cloud sync architecture, not data-local-first principle)

**Problem:** ADR-002 planned anonymous Firebase auth by default, with an optional email link step later. This creates a critical failure mode: if a user enables sync but never links an email and then changes phones or factory resets, the anonymous UID is gone and their Firestore data is permanently unrecoverable.

**Decision:** Show an explicit choice on the welcome screen:
1. **"Create account & sync"** — Firebase email/password sign-up → Firestore sync active
2. **"Sign in to existing account"** — Firebase email/password sign-in → restore or push
3. **"Continue without account"** — local Drift only, no Firebase

No anonymous sessions. Cloud sync requires an email-authenticated account.

**Sync behaviour:**
- **Sign-up** → user goes through onboarding → HomeScreen triggers `SyncService.pushAll(uid)` on first mount
- **Sign-in on new device** (local DB empty) → `SyncService.restoreAll(uid)` pulls Firestore → writes to Drift → router sees `user.onboarded = true` → redirects to `/home`
- **Sign-in on existing device** (local DB has data) → `SyncService.pushAll(uid)` backs up local data to Firestore
- **App start** → `HomeScreen._syncIfAuthenticated()` calls `SyncNotifier.sync()` (full push) on every mount

**Sync is full push, not incremental:** Every `pushAll()` overwrites Firestore with current local state. Firestore is a backup layer, not the source of truth — Drift is. This avoids conflict resolution complexity. Incremental delta sync (track dirty rows) can be added in a later phase.

**Firestore document structure:**
```
users/{uid}/                 → User profile fields
users/{uid}/cycles/{id}      → CycleEntry
users/{uid}/symptom_logs/{id} → SymptomLog
users/{uid}/mood_logs/{id}   → MoodLog
```

**Gated by `kFirebaseEnabled`:** All Firebase code (auth screens, sync, init) is behind this flag. Set to `false` by default. Flip to `true` after adding `google-services.json` to `android/app/`. Welcome screen shows the three-option layout only when the flag is `true`; it falls back to the original "Get started" button otherwise.

**New packages:** `firebase_core ^3.6.0`, `firebase_auth ^5.3.1`, `cloud_firestore ^5.4.3`

---

## ADR-018 · InsightEngine Computation on Background Isolate
**Date:** 2026-06-25
**Status:** Accepted

**Problem:** `InsightEngine.compute()` iterates over all cycles, symptoms, and moods in memory to produce 6 insight types. On a device with 2+ years of data this is a meaningful CPU spike on the main thread, causing frame drops at the moment the Insights screen mounts.

**Decision:** Move the computation to a background isolate via Flutter's `compute()` helper:
- Top-level function `_runInsightEngine(_InsightParams params)` (top-level required — closures are not sendable across isolates)
- `_InsightParams` data class holds `cycles, symptoms, moods, commonSymptoms, today` — all plain Dart objects, no Flutter/platform types
- Called from `insightsProvider` as `compute(_runInsightEngine, params)` which returns a `Future`

**Consequence:** The provider returns an `AsyncValue` with a loading state on first mount. The UI shows `SizedBox.shrink()` during the brief computation window (~20–80ms depending on data volume) rather than blocking the frame scheduler.

**Test implication:** `insight_engine_test.dart` tests `InsightEngine.compute()` directly (synchronous) — the `compute()` wrapper is not tested, which is intentional. The isolate wrapper is trivial infrastructure; the algorithm is what needs coverage.

---

## ADR-017 · Custom Markdown Renderer — No flutter_markdown Dependency
**Date:** 2026-06-25
**Status:** Accepted

**Problem:** Article detail content is stored as simple Markdown (headings, bullets, bold, italic). A full Markdown renderer is needed for `ArticleDetailScreen`.

**Decision:** Implement `SimpleMarkdownBody` as a custom widget rather than adding `flutter_markdown` to pubspec:
- Block-level: `##` → `titleSmall` (primary color), `#` → `titleMedium`, `- ` → bullet row, else `bodyMedium` paragraph
- Inline: `_InlineMarkdown` parses `**bold**` and `*italic*` via `RegExp(r'\*\*(.+?)\*\*|\*(.+?)\*')` into `TextSpan` with `FontWeight.bold` / `FontStyle.italic`
- ~80 lines, zero additional dependencies

**Why not flutter_markdown:** The package adds ~500 KB to the APK and pulls in `markdown` as a transitive dependency. Our content is author-controlled JSON with a small known subset of syntax — a full spec parser is unnecessary scope. The custom renderer also respects the app's `TextTheme` and `ColorScheme` automatically, whereas `flutter_markdown` requires `MarkdownStyleSheet` overrides to match Material 3.

**Limitation accepted:** No inline links, tables, or code blocks. Article content authored to stay within the supported subset.

---

## ADR-016 · Claude Phase-Tips Personalisation — Layered Architecture
**Date:** 2026-06-25
**Status:** Accepted

**Problem:** The phase tips feature needed a "personalise with Claude" layer that: (a) works fully offline, (b) doesn't break when `kClaudeEnabled = false`, (c) doesn't hit the network on every render, (d) keeps domain layer free of Flutter/HTTP imports.

**Decision:** Three-layer design:
1. **`domain/usecases/get_ai_insight.dart`** — pure Dart offline scorer. Maps `Symptom → tip categories`, returns top-3 tips by affinity score. No network, no Flutter imports.
2. **`ai/ai_insights_cache.dart`** — Hive `'ai_cache'` box keyed by `'$phase:$cycleNumber'`. Cache entries expire automatically when the cycle count increments (no explicit TTL needed).
3. **`ai/claude_chat.dart`** — HTTP POST to Firebase CF `/personalisePhraseTips`. Short-circuits to `[]` when `kClaudeEnabled = false`. Failures return `[]` silently, caller falls back to offline scorer.

Provider flow: cache hit → return | Claude path (if enabled) → cache + return | offline scorer → cache + return.

**Consequences:** The static tip rotation continues to work untouched. The offline scorer improves tip relevance with zero network cost. Claude personalisation drops in without touching any UI or domain code — flip one flag and deploy one CF to enable.

---

## ADR-015 · l10n Output Directory — `output-dir: lib/l10n`
**Date:** 2026-06-24
**Status:** Accepted

**Problem:** `flutter gen-l10n` without an explicit `output-dir` defaults to writing generated files into the ARB source directory (`l10n/` at repo root). Files outside `lib/` are not importable as `package:luna/...`. Every file using `AppLocalizations` failed to compile.

**Decision:** Add `output-dir: lib/l10n` to `l10n.yaml`. Generated files now land in `lib/l10n/app_localizations.dart`, importable as `package:luna/l10n/app_localizations.dart`. ARB source files remain in root `l10n/` — that directory is for translator editing, not compilation.

---

## ADR-014 · Enum L10n via Extension Methods, not BuildContext on Enums
**Date:** 2026-06-24
**Status:** Accepted

**Problem:** Domain enums (`CyclePhase`, `FlowIntensity`, `Symptom`, `Mood`) need localized display strings. Two bad paths: (1) add `localizedName(BuildContext)` on each enum → imports Flutter into domain layer, violating the no-Flutter-in-domain rule. (2) hardcode English strings → blocks Hindi.

**Decision:** Companion extension methods in `lib/core/extensions/enums_l10n.dart`, taking `AppLocalizations` as a parameter:

```dart
extension CyclePhaseL10n on CyclePhase {
  String localizedName(AppLocalizations l) => switch (this) {
    CyclePhase.menstrual => l.phaseMenstrual, ...
  };
}
```

**Call-site:** `phase.localizedName(context.l10n)` — readable at the widget, context-free at the enum. Supported by a `BuildContext.l10n` shorthand in `lib/core/extensions/l10n.dart`. `AppLocalizations` is a generated pure-Dart class with no Flutter dependency, so the extension file stays clean.

---

## ADR-013 · Theme Toggle Animation — clipPath + evenOdd, not saveLayer
**Date:** 2026-06-24
**Status:** Accepted — supersedes implementation approach from ADR-007

**Problem:** The circular-reveal toggle used `canvas.saveLayer()` + `BlendMode.clear`. This allocates a full-screen GPU offscreen `RenderTarget` every frame — ~8 MB at 3× DPR, reallocated at 60 fps. Caused visible jank on flagship hardware.

**Decision:** Replace with `clipPath + PathFillType.evenOdd`:

```dart
final path = Path()
  ..addRect(Rect.fromLTWH(0, 0, size.width, size.height))
  ..addOval(Rect.fromCircle(center: center, radius: holeRadius));
path.fillType = PathFillType.evenOdd;
canvas.clipPath(path);
canvas.drawImageRect(image, src, dst, paint);
```

A point inside both rect and circle = 2 crossings (even) = outside clip = not drawn (new theme shows through). A point inside rect only = 1 crossing (odd) = inside clip = old screenshot drawn. `clipPath` uses the GPU stencil buffer — no offscreen allocation.

**Additional optimisations:** screenshot capture capped at `min(devicePixelRatio, 2.0)`, `FilterQuality.low` on `drawImageRect`, duration 350ms, `Curves.easeOutCubic`. Animation must be profiled in release mode — debug JIT adds 5–10× overhead to custom painters.

---

## ADR-012 · Phase-Tinted Surfaces in Both Dark and Light Mode
**Date:** 2026-06-24
**Status:** Accepted

**Decision:** Both dark and light mode use phase-tinted surface and background colors rather than neutral blacks/whites. The phase identity is carried through the entire color stack — not just the accent color.

**Dark mode:** Each phase has a unique dark background (subtle phase-hued dark, not a flat plum). Cards sit on a slightly lighter version of the same hue family.

**Light mode:** Backgrounds are barely-tinted pastels (e.g. `#FFF5F7` for menstrual — barely pink). Cards sit on a visibly but softly tinted surface. Accent colors in light mode are significantly darker than their dark-mode equivalents to maintain WCAG AA contrast on light backgrounds.

**Implementation:** `ColorScheme.fromSeed()` generates all interactive-element colors (buttons, chips, ripples) with correct contrast ratios from the seed. We then `.copyWith()` only the surface/background tokens, overriding M3's neutral defaults with our phase-tinted values.

**Why not let M3 generate everything:** M3's auto-generated light surfaces are near-white and auto-generated dark surfaces are near-black. Both strip the phase personality from the background layer. The copyWith approach keeps M3's accessibility guarantees on interactive elements while letting us own the surface aesthetic.

**Full per-phase palette:** documented in `docs/ui-design-system.md`.

---

## ADR-011 · In-App Update System for APK Distribution
**Date:** 2026-06-24
**Status:** Accepted

**Context:** Luna will initially be distributed as a direct APK download, not via Google Play Store. The Google Play In-App Updates API is therefore unavailable.

**Decision:** Build a custom update system consisting of:
1. A `version.json` manifest hosted at a static URL (GitHub Releases recommended)
2. An `UpdateService` in the app that fetches the manifest on startup
3. An `UpdateBottomSheet` that appears when a newer build number is detected
4. APK download via `dio` with a progress bar
5. `open_filex` to trigger Android's system install dialog

**Mandatory vs optional:** `is_mandatory` field in the manifest. Mandatory updates lock the dialog (no dismiss). Optional updates can be deferred.

**Check frequency:** Optional updates checked at most once per 24 hours (last-check timestamp in Hive) to avoid server hammering. Mandatory updates always checked on every app open.

**Timing:** Check runs 500ms after app open on a background isolate — does not block the UI or delay the home screen.

**Hosting:** GitHub Releases provides free, versioned hosting. The APK and `version.json` are both uploaded as release assets. URL pattern is stable and predictable.

**Android requirements:**
- `REQUEST_INSTALL_PACKAGES` permission in AndroidManifest
- FileProvider configured in AndroidManifest (required to share the downloaded file with the system installer on Android 7+)
- `file_paths.xml` resource defining the download directory

**New packages:** `package_info_plus`, `dio`, `path_provider`, `open_filex`
**Note:** `path_provider` was already planned. `dio` replaces `http` for the update download only; Claude API calls continue using `http`.

---

## ADR-010 · TFLite Rejected — Bayesian Estimator Chosen for Cycle Prediction
**Date:** 2026-06-24
**Status:** Accepted — supersedes part of ADR-008

**Decision:** Replace the planned TFLite LSTM cycle predictor with a Bayesian Gaussian updating model implemented in pure Dart.

**Reasons TFLite was rejected:**
1. No adequate licensed Indian cycle dataset exists to pre-train a meaningful model. Bundling a model trained on Western data (FitrWoman, Apple Women's Health Study) would make confident predictions based on someone else's population — worse than a good statistical method.
2. With 6–15 user data points (typical first year), an LSTM overfits and underperforms simple statistical methods.
3. `tflite_flutter` requires native code compilation and adds ~500KB model asset with no accuracy benefit at low data volumes.
4. TFLite produces a point prediction; confidence intervals are a bolt-on hack. Bayesian updating produces real uncertainty as a natural output.

**Bayesian approach chosen because:**
- No pre-trained model needed — learns entirely from the user's own data
- Pure Dart — zero new dependencies, fully unit-testable
- Confidence intervals emerge naturally (posterior variance = display directly as date range)
- Performs best in exactly the data-sparse regime users are in for the first 6–12 months
- PCOS variant (wider Student-t prior) handles irregular cycles honestly
- State persists as two doubles in Hive — trivial to restore

**If ML becomes appropriate in future (Phase 3):**
ONNX Runtime (`onnxruntime` pub.dev package, Microsoft-maintained) is preferred over TFLite if a licensed India-specific dataset is sourced. ONNX accepts models trained in PyTorch, scikit-learn, or XGBoost — more flexible than TFLite's TF-only ecosystem. Would be added as a second layer on top of the Bayesian base, not replacing it.

**pubspec.yaml change:** Remove `tflite_flutter`. Remove `assets/models/` directory entirely.

---

## ADR-009 · Enhanced Onboarding — Data Collection Strategy
**Date:** 2026-06-24
**Status:** Accepted

**Decision:** Replace the minimal 3-question onboarding with an 8-screen flow. Three screens are required; five are skippable. Goal is to maximise prediction accuracy and personalisation from day one without creating friction for users who just want to get started.

**Key screens and their impact:**
- Screen 3 (past period dates) → improves prediction accuracy ~40% immediately
- Screen 7 (contraceptive use) → triggers a different prediction algorithm branch; hormonal contraception means the user has withdrawal bleeds, not natural cycles — the model must know this

**Reasoning:** Getting accurate predictions early drives retention. Every skippable screen includes a one-line benefit statement so users understand the tradeoff before skipping.

**Full spec:** `docs/onboarding-spec.md`

---

## ADR-008 · AI Accuracy — Honest Benchmarks Documented
**Date:** 2026-06-24
**Status:** Accepted

**Decision:** Document honest accuracy expectations in codebase and show confidence intervals in the UI rather than single predicted dates.

**Accuracy benchmarks:**
| Data | Cycle prediction accuracy |
|---|---|
| 1–2 cycles | ±5–7 days (same as moving average) |
| 3–5 cycles | ±3–4 days |
| 6–12 cycles | ±2–3 days |
| 12+ cycles | ±1–2 days |

**Symptom insights:** Not a prediction problem — it's exact computation on logged data. Accuracy = how consistently the user logs. Zero model error.

**UI implication:** Show predicted period as a date range ("Jun 28 – Jul 3"), never a single date, until 12+ cycles of data exist.

---

## ADR-007 · Phase Theming via colorSchemeSeed
**Date:** 2026-06-24
**Status:** Accepted

**Decision:** Use Material 3 `colorSchemeSeed` at the `MaterialApp` level, driven by the user's current cycle phase. Wrap the app in `AnimatedTheme` with a 600ms `easeInOut` crossfade so the transition is felt, not jarring.

**Phase seed colors:**
- Menstrual: `#E53E6A`
- Follicular: `#F97316`
- Ovulation: `#10B981`
- Luteal: `#8B5CF6`

**Reasoning:** M3's color generation algorithm derives a full 30-color harmonized scheme from a single seed. Every widget — FAB, nav bar, buttons, sliders — picks up the phase tint automatically with zero per-widget styling needed. A `PhaseThemeExtension` carries additional phase-specific tokens (gradient pair, Lottie animation reference, motivational copy) that aren't part of standard M3.

---

## ADR-006 · Claude Chat Hidden Behind Feature Flag
**Date:** 2026-06-24
**Status:** Accepted

**Context:** No Anthropic API key available at development start.

**Decision:** Add `const kClaudeEnabled = false` in `core/constants/feature_flags.dart`. All Claude-related code (Cloud Function, `claude_chat.dart` wrapper, `ChatQuotaService`, chat screen) is fully implemented but the UI entry point (the chat tab in bottom nav) does not render when the flag is false. No `if (kClaudeEnabled)` scattered through business logic — only at the navigation/routing layer.

**To enable:** Set `kClaudeEnabled = true`, deploy the Firebase Cloud Function with the Anthropic API key in environment config, done.

---

## ADR-005 · Monetization-Ready Architecture
**Date:** 2026-06-24
**Status:** Accepted

**Decision:** All quota logic lives behind a `QuotaRepository` abstract interface in the domain layer. The current free-tier implementation returns 10 messages/day from a Firestore counter. To add premium:
1. Add RevenueCat SDK
2. Update `QuotaRepositoryImpl.isPremium()` to check subscription status
3. Return `999` instead of `10` for premium users

No UI changes. No chat logic changes. One interface implementation update.

**India note:** RevenueCat's Google Play integration handles UPI, net banking, and cards automatically.

---

## ADR-004 · Firebase Cloud Function as API Proxy
**Date:** 2026-06-24
**Status:** Accepted

**Context:** Bundling an Anthropic API key in an APK is a security vulnerability. The key can be extracted from the APK binary in under 2 minutes with `apktool`.

**Decision:** All Claude API calls are routed through a Firebase Cloud Function. The function:
- Validates Firebase Auth UID
- Checks the user's daily quota in Firestore
- Strips identifying data before the API call (no name, no dates — only phase name, symptom list, question text)
- Calls the Anthropic API with the key stored in Firebase environment config
- Returns the response and decrements the quota counter

**Cost estimate (claude-haiku-4-5-20251001):** ~₹1,800/month for 1,000 daily active users sending 10 messages each. Firebase Functions free tier covers infra up to 2M invocations/month.

---

## ADR-003 · India-First Localisation
**Date:** 2026-06-24
**Status:** Accepted

**Decision:** Hindi (`hi`) locale supported from day one alongside English (`en`). Not an afterthought migration.

**Specifics:**
- All user-facing strings in `l10n/` ARB files from the first widget
- Default timezone: `Asia/Kolkata`
- Safety section helplines: iCall (9152987821), Vandrevala Foundation (1860-2662-345), NIMHANS
- POCSO Act awareness content in the young users section
- Age gate: users under 18 (from `birth_year`) see a simplified safety-first view with parental guidance content
- Future billing: RevenueCat + Google Play handles UPI automatically

---

## ADR-002 · Local-First Data, Firebase Opt-In
**Date:** 2026-06-24
**Status:** Accepted

**Decision:** All health data is stored locally in Drift SQLite by default. Firebase Firestore sync is an explicit opt-in toggle shown during onboarding and accessible in Settings. Defaulting to off.

**Reasoning:** Period tracking data is among the most sensitive personal health data. Users in India are increasingly privacy-aware. Trust is built by default-private, not by requiring users to opt out. The `cloud_sync_enabled` column in the `users` table acts as the gate; the sync service checks it before every write.

---

## ADR-001 · Flutter over Native Kotlin
**Date:** 2026-06-24
**Status:** Accepted

**Decision:** Build with Flutter + Dart rather than native Android Kotlin + Jetpack Compose.

**Reasoning:**
- iOS expansion later requires near-zero additional work
- Material 3 theming (the phase-shifting color system) is equally powerful in Flutter
- Dart 3 with sound null safety reduces entire classes of runtime errors
- The team (currently solo) avoids maintaining two codebases if iOS is added
- Flutter's widget testing infrastructure is strong enough for health-critical logic

**Tradeoff accepted:** Slightly less deep Android OS integration (e.g. lock screen widgets require the Glance API separately in Phase 3, not trivial). Acceptable given the benefit.
