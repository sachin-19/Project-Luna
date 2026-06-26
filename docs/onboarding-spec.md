# Onboarding Specification
## Luna — Period Tracker

---

## Goal

Collect enough data on day one to make the prediction model and personalisation engine meaningfully accurate from the user's very first cycle. Every skippable screen displays a one-line benefit statement — users understand what they're trading before skipping.

**Required screens:** 1, 2, 8 (cannot be skipped)
**Skippable screens:** 3, 4, 5, 6, 7 (each has a prominent "Skip for now" link)

GoRouter gate: if `users.onboarded == false`, any route redirects to `/onboarding/identity`.

---

## Screen 1 — Identity
**Route:** `/onboarding/identity`
**Required:** Yes

**Fields:**
- First name (text input) — used in greetings only, never sent to any server
- Birth year (year picker, range: 1940–2013) — drives:
  - Age-appropriate AI chatbot responses
  - Youth safety mode activation (users born after 2008, i.e. under 18)
  - Content filtering in the Learn section

**Notes:**
- No last name, no email at this stage
- "Why do we ask?" info icon explains birth year usage

---

## Screen 2 — Cycle Basics
**Route:** `/onboarding/cycle-basics`
**Required:** Yes

**Fields:**
- **Last period start date** (date picker, max: today, min: 6 months ago)
  - This is the single most important piece of data — seeds the entire calendar
  - Default: opens to today; user scrolls back
- **Period duration** (segmented slider: 2 · 3 · 4 · 5 · 6 · 7 · 8+ days)
  - Default: 5 days
- **Cycle length** (slider: 21–45 days)
  - Default: 28
  - "I'm not sure" checkbox → sets to 28, marks `cycle_length_known = false` in DB, shows "Luna will learn your cycle over time"

---

## Screen 3 — Cycle History
**Route:** `/onboarding/history`
**Required:** No — skippable

**Benefit statement shown:** *"Adding past period dates makes Luna's first prediction 40% more accurate."*

**Fields:**
- Up to 5 past period start dates (date pickers, each individually removable)
- Dates auto-sorted descending
- Each date added updates a live accuracy indicator: "Prediction window: ±5 days → ±3 days → ±2 days" (simplified label, not exact math)

**Implementation note:** These dates are inserted as `cycle_entries` rows immediately on onboarding completion. The TFLite model receives these as seed history. Even 2 past dates dramatically improve the initial moving-average fallback.

---

## Screen 4 — Cycle Regularity
**Route:** `/onboarding/regularity`
**Required:** No — skippable

**Benefit statement:** *"Knowing your cycle's pattern helps Luna adjust predictions for you specifically."*

**Field 1 — Regularity:**
Single-select options:
- Very regular (my period comes within 1–2 days of expected)
- Mostly regular (3–5 days variation)
- Irregular (hard to predict)
- Very unpredictable (I can't tell at all)

**Field 2 — Known conditions:**
- "Do you have PCOS or endometriosis?"
  Options: Yes — PCOS / Yes — Endometriosis / Yes — both / No / Prefer not to say

**Implementation note:** PCOS flag (`has_pcos = true`) activates a different prediction model branch that expects longer cycles (up to 90 days) and higher variance. Endo flag (`has_endo = true`) activates more detailed pain tracking options in the log sheet.

---

## Screen 5 — Your Reason
**Route:** `/onboarding/reason`
**Required:** No — skippable

**Benefit statement:** *"This helps Luna show you the most relevant features first."*

**Multi-select chips:**
- Track my cycle
- Understand my symptoms
- Manage PCOS or Endometriosis
- Plan a pregnancy
- Avoid pregnancy
- Improve my overall wellbeing
- Education (I want to learn more about my body)

**Implementation note:** Stored as a JSON array in `users.tracking_goals`. Used to:
- Reorder bottom nav features (fertility mode if "Plan a pregnancy" selected)
- Personalise the Learn section home page tags
- Inform the Claude chatbot's system prompt context (when enabled)

---

## Screen 6 — Common Symptoms
**Route:** `/onboarding/symptoms`
**Required:** No — skippable

**Benefit statement:** *"Your symptom chips in the daily log are pre-selected based on this. Makes logging take under 5 seconds."*

**Multi-select chip grid:**
| | | |
|---|---|---|
| Cramps | Headache | Bloating |
| Fatigue | Back pain | Mood swings |
| Breast tenderness | Nausea | Acne |
| Food cravings | Sleep changes | Spotting |

**Implementation note:** Selected symptoms are stored as `users.common_symptoms` JSON array. The log sheet pre-selects these chips by default. The insight engine also uses this as a prior — it expects to see these symptoms and will flag notable absences ("You usually log cramps but haven't this cycle").

---

## Screen 7 — Lifestyle Context
**Route:** `/onboarding/lifestyle`
**Required:** No — skippable

**Benefit statement:** *"Lifestyle factors affect your cycle. This helps Luna find patterns you might miss."*

**Field 1 — Typical stress level:**
1–5 icon scale (calm face to stressed face). Stored as `users.baseline_stress`.

**Field 2 — Exercise frequency:**
Single-select:
- Rarely or never
- 1–2 times a week
- 3–4 times a week
- Daily
Stored as `users.exercise_frequency`.

**Field 3 — Hormonal contraception:**
⚠️ **Critical field — changes the prediction algorithm.**
Single-select:
- None (I don't use hormonal contraception)
- Combined pill
- Progesterone-only pill (mini pill)
- Hormonal IUD (Mirena / Kyleena)
- Implant (Nexplanon)
- Contraceptive injection
- Vaginal ring
- I'm not sure

**Implementation note for contraception:**
- If any hormonal option selected → `users.on_hormonal_contraception = true`
- Prediction model switches to `FixedIntervalPredictor` (withdrawal bleeds on a known schedule)
- Phase calculation is simplified — no meaningful ovulation window
- UI shows a notice: "Because you're on hormonal contraception, Luna tracks your withdrawal bleeds rather than a natural cycle. Ovulation prediction is hidden."

---

## Screen 8 — Notifications
**Route:** `/onboarding/notifications`
**Required:** Yes (but all toggles can be turned off)

**Permission request:** Android `POST_NOTIFICATIONS` permission prompted here with a clear explanation before the system dialog.

**Toggles (all on by default):**
- Period reminder — "Remind me 2 days before my predicted period" (lead time configurable in Settings)
- Ovulation window alert — "Notify me when my fertile window begins"
- Daily check-in — "Gentle nudge to log how I'm feeling today" (time configurable)
- Streak reminders — "Encourage me to keep my logging streak"

**After this screen:** `users.onboarded = true` written to DB. GoRouter redirect clears and sends user to `/home`.

---

## Onboarding Progress Indicator

Linear progress bar at the top of all screens. Fills proportionally to required + answered optional screens.

Required screens count as 1.0 weight each.
Answered optional screens count as 0.5 weight each (reward for engaging).
Skipped optional screens count as 0 (no penalty).

This means a user who fills in everything reaches 100%. A user who skips everything skippable reaches ~60%. The visual incompleteness is intentional — it creates a subtle prompt to return and complete the profile later. "Complete your Luna profile" nudge shown on Home screen until 80%+ is reached.

---

## Data Written to DB on Onboarding Completion

| Table | Columns populated |
|---|---|
| `users` | `display_name`, `birth_year`, `avg_cycle_days`, `avg_period_days`, `on_hormonal_contraception`, `has_pcos`, `has_endo`, `tracking_goals`, `common_symptoms`, `baseline_stress`, `exercise_frequency`, `onboarded = true` |
| `cycle_entries` | One row per past date entered in Screen 3 (plus the current cycle from Screen 2) |
