# Database Schema
## Luna — Period Tracker

All tables defined using Drift 2 (type-safe SQLite for Flutter).
Every query is code-generated — no raw SQL strings in the app.

---

## Table Overview

| Table | Purpose |
|---|---|
| `users` | Single-row user profile, onboarding state, preferences |
| `cycle_entries` | One row per menstrual cycle |
| `period_day_logs` | One row per day of bleeding within a cycle |
| `symptom_logs` | Individual symptom occurrences |
| `mood_logs` | Daily mood and energy snapshots |
| `health_notes` | Free-text journal entries |
| `ai_insights_cache` | Cached Claude / insight engine results |

---

## `users`

Single-row table (the app is single-user, local-only).

| Column | Type | Nullable | Default | Notes |
|---|---|---|---|---|
| `id` | INTEGER | No | auto | Primary key |
| `display_name` | TEXT | No | — | First name only |
| `birth_year` | INTEGER | No | — | Drives age-appropriate content; youth mode if under 18 |
| `avg_cycle_days` | INTEGER | No | 28 | Updated by predictor after each cycle |
| `avg_period_days` | INTEGER | No | 5 | Updated after each period end logged |
| `cycle_length_known` | BOOLEAN | No | true | False if user selected "I'm not sure" in onboarding |
| `on_hormonal_contraception` | BOOLEAN | No | false | Switches prediction to FixedIntervalPredictor |
| `has_pcos` | BOOLEAN | No | false | Activates extended cycle range in predictor |
| `has_endo` | BOOLEAN | No | false | Activates pain mapping in log sheet |
| `tracking_goals` | TEXT | Yes | null | JSON array of selected reasons (from onboarding Screen 5) |
| `common_symptoms` | TEXT | Yes | null | JSON array of pre-selected symptoms (from onboarding Screen 6) |
| `baseline_stress` | INTEGER | Yes | null | 1–5 scale from onboarding |
| `exercise_frequency` | TEXT | Yes | null | rarely / 1-2x / 3-4x / daily |
| `preferred_language` | TEXT | No | en | en or hi |
| `theme_brightness` | TEXT | No | dark | dark or light |
| `cloud_sync_enabled` | BOOLEAN | No | false | Firebase sync opt-in |
| `notifications_period` | BOOLEAN | No | true | |
| `notifications_ovulation` | BOOLEAN | No | true | |
| `notifications_daily_checkin` | BOOLEAN | No | true | |
| `notification_lead_days` | INTEGER | No | 2 | Days before predicted period to remind |
| `onboarded` | BOOLEAN | No | false | GoRouter gate — flipped to true at onboarding completion |
| `created_at` | INTEGER | No | — | Unix timestamp |

---

## `cycle_entries`

One row per menstrual cycle. A new row is created when the user logs a period start.

| Column | Type | Nullable | Default | Notes |
|---|---|---|---|---|
| `id` | INTEGER | No | auto | Primary key |
| `start_date` | TEXT | No | — | ISO 8601 date (YYYY-MM-DD) |
| `end_date` | TEXT | Yes | null | Set when user logs period end; null if current/ongoing |
| `cycle_length` | INTEGER | Yes | null | Computed when next cycle's start_date is logged |
| `period_length` | INTEGER | Yes | null | Computed from start_date and end_date |
| `notes` | TEXT | Yes | null | Optional free-text for the whole cycle |
| `is_seeded` | BOOLEAN | No | false | True if entered during onboarding (historical data) |
| `created_at` | INTEGER | No | — | Unix timestamp |

**Relationships:**
- Has many `period_day_logs`
- Has many `ai_insights_cache` rows

---

## `period_day_logs`

One row per day of bleeding. Linked to its parent cycle entry.

| Column | Type | Nullable | Default | Notes |
|---|---|---|---|---|
| `id` | INTEGER | No | auto | Primary key |
| `cycle_entry_id` | INTEGER | No | — | Foreign key → `cycle_entries.id` |
| `date` | TEXT | No | — | ISO 8601 date |
| `flow` | TEXT | No | — | Enum: spotting \| light \| medium \| heavy |

**Constraints:** unique on `(cycle_entry_id, date)` — one log per day per cycle.

---

## `symptom_logs`

| Column | Type | Nullable | Default | Notes |
|---|---|---|---|---|
| `id` | INTEGER | No | auto | |
| `date` | TEXT | No | — | ISO 8601 date |
| `symptom` | TEXT | No | — | Enum: cramps \| headache \| bloating \| fatigue \| back_pain \| mood_swings \| breast_tenderness \| nausea \| acne \| food_cravings \| sleep_changes \| spotting |
| `severity` | INTEGER | No | — | 1–5 |
| `notes` | TEXT | Yes | null | Optional per-symptom note |
| `created_at` | INTEGER | No | — | |

**Constraints:** unique on `(date, symptom)` — one severity entry per symptom per day. Subsequent logs on the same day update the existing row.

---

## `mood_logs`

| Column | Type | Nullable | Default | Notes |
|---|---|---|---|---|
| `id` | INTEGER | No | auto | |
| `date` | TEXT | No | — | ISO 8601 date |
| `mood` | TEXT | No | — | Enum: happy \| calm \| sad \| anxious \| irritable \| energetic |
| `energy_level` | INTEGER | No | — | 1–5 |
| `notes` | TEXT | Yes | null | Free-text journal for the day |
| `created_at` | INTEGER | No | — | |

**Constraints:** unique on `date` — one mood entry per day (updated if re-logged).

---

## `health_notes`

Free-text journaling. Not tied to a specific cycle or symptom.

| Column | Type | Nullable | Default | Notes |
|---|---|---|---|---|
| `id` | INTEGER | No | auto | |
| `date` | TEXT | No | — | ISO 8601 date |
| `content` | TEXT | No | — | User's journal entry |
| `tags` | TEXT | Yes | null | JSON array of tag strings |
| `created_at` | INTEGER | No | — | |

---

## `ai_insights_cache`

Caches both the local insight engine results and any Claude-generated personalised content. Keyed by cycle entry and insight type — a new entry per cycle per type.

| Column | Type | Nullable | Default | Notes |
|---|---|---|---|---|
| `id` | INTEGER | No | auto | |
| `cycle_entry_id` | INTEGER | Yes | null | If cycle-specific; null for global insights |
| `insight_type` | TEXT | No | — | Enum: phase_affinity \| severity_trend \| co_occurrence \| personalised_tips \| chatbot_context |
| `content` | TEXT | No | — | JSON string — structure varies by type |
| `generated_at` | INTEGER | No | — | Unix timestamp |
| `is_stale` | BOOLEAN | No | false | Set true when underlying data changes; triggers regeneration |

---

## DAOs (Data Access Objects)

### CycleDao
- `watchActiveCycle()` — Stream of the current open cycle entry
- `getAllCycles()` — Future<List<CycleEntry>>, ordered by start_date DESC
- `insertCycle(CycleEntriesCompanion)` — start a new cycle
- `updateCycleEnd(int id, DateTime endDate)` — close current cycle
- `getLastNCycles(int n)` — for predictor input
- `getPeriodDaysForCycle(int cycleId)` — list of PeriodDayLog

### SymptomDao
- `watchSymptomsForDate(DateTime date)` — Stream
- `getSymptomsForRange(DateTime start, DateTime end)` — for insight engine
- `upsertSymptom(SymptomLogsCompanion)` — insert or update

### MoodDao
- `watchMoodForDate(DateTime date)` — Stream
- `getMoodsForRange(DateTime start, DateTime end)` — for correlation charts
- `upsertMood(MoodLogsCompanion)` — insert or update

### UserDao
- `watchUser()` — Stream<User?> (single row)
- `upsertUser(UsersCompanion)` — create or update profile
- `updatePhaseTheme(CyclePhase)` — for future: persist last-seen phase

---

## Schema Migration Strategy

Drift handles migrations via `MigrationStrategy` in the database class. Every schema change gets a migration step. Steps are numbered and never edited retroactively.

```dart
// database.dart
MigrationStrategy get migration => MigrationStrategy(
  onCreate: (m) => m.createAll(),
  onUpgrade: (m, from, to) async {
    if (from < 2) {
      // v2: added has_endo column to users
      await m.addColumn(users, users.hasEndo);
    }
    if (from < 3) {
      // v3: ...
    }
  },
);
```

Current schema version: **1** (initial)

---

## Change Log

| Version | Date | Change |
|---|---|---|
| 1 | 2026-06-24 | Initial schema — all 7 tables defined |
