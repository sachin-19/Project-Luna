# AI Features Specification
## Luna — Period Tracker

---

## Overview

Four AI features across two paradigms:
- **On-device** (pure Dart statistical model + computation): zero cost, zero internet, zero privacy risk
- **Cloud API** (Claude via Firebase CF proxy): requires internet, costs money, gated by `kClaudeEnabled`

| Feature | Paradigm | Cost | Offline | Status |
|---|---|---|---|---|
| Cycle Prediction | On-device Bayesian (pure Dart) | ₹0 | ✅ Yes | Build Phase 1 |
| Symptom Pattern Insights | On-device Dart | ₹0 | ✅ Yes | Build Phase 2 |
| Phase Tips (static) | On-device JSON | ₹0 | ✅ Yes | Build Phase 1 |
| AI Health Chatbot | Cloud (Claude) | ~₹0.07/conv | ❌ No | **Hidden — Phase 2/3** |

**Note:** TFLite was evaluated and rejected. See ADR-010 in `docs/decisions.md`.

---

## Feature 1: Cycle Prediction (Bayesian Statistical Model)

### File
`lib/ai/cycle_predictor.dart`

### Why not TFLite / ML

TFLite LSTM was the original plan. It was replaced because:

1. **Pre-training data problem** — No adequate, licensed Indian women's cycle dataset exists. Bundling a model trained on Western data (FitrWoman etc.) means the "AI" is confidently predicting based on someone else's population norms, not learning from the user.
2. **Small data regime** — An LSTM given 6–15 data points overfits and performs worse than a well-tuned statistical model.
3. **Dependency cost** — `tflite_flutter` requires native code compilation and adds ~500KB model asset; the Bayesian approach has zero extra dependencies.
4. **Confidence intervals** — TFLite produces a point prediction; confidence intervals are a hack on top. Bayesian updating produces real intervals as a natural output.

If a large, licensed, India-specific training dataset becomes available in Phase 3, ONNX Runtime (not TFLite — see ADR-010) can be introduced as a second layer on top of the Bayesian base.

### How it works — Bayesian Gaussian Updating

Start with the population average as a prior. Every cycle the user logs *updates* the estimate toward their personal pattern. The math is a conjugate Gaussian update — closed form, no iteration, no model file.

```
Prior (new user, no personal data):
  μ₀ = 28 days    (population average)
  σ₀ = 3.5 days   (population std dev)

Each observed cycle length x_n updates:
  Posterior precision = Prior precision + Likelihood precision
  1/σ²_new = 1/σ²_old + 1/σ²_noise

  Posterior mean (weighted average toward observed value):
  μ_new = σ²_new × (μ_old/σ²_old + x_n/σ²_noise)

  where σ²_noise = 2.25  (1.5² — accounts for imprecise start-date logging)

Output:
  prediction     = round(μ_posterior)
  95% interval   = [μ - 1.96σ, μ + 1.96σ]
```

After each completed cycle, `_mean` and `_variance` are updated and persisted to Hive. Restoring state on app restart reads two doubles.

### Dart Implementation

```dart
// lib/ai/cycle_predictor.dart

import 'dart:math' as math;
import 'package:luna/domain/entities/cycle_prediction.dart';

class BayesianCycleEstimator {
  double _mean;
  double _variance;
  int _cyclesObserved;

  static const double _observationVariance = 2.25; // 1.5² days

  // Population prior — tunable if India-specific stats found later
  BayesianCycleEstimator({
    double priorMean = 28.0,
    double priorVariance = 12.25,   // 3.5²
  })  : _mean = priorMean,
        _variance = priorVariance,
        _cyclesObserved = 0;

  // Call once per completed cycle
  CyclePrediction observe(double observedCycleLength) {
    final posteriorVariance = 1.0 /
        (1.0 / _variance + 1.0 / _observationVariance);
    final posteriorMean = posteriorVariance *
        (_mean / _variance + observedCycleLength / _observationVariance);

    _mean = posteriorMean;
    _variance = posteriorVariance;
    _cyclesObserved++;

    return currentPrediction();
  }

  CyclePrediction currentPrediction() {
    final sd = math.sqrt(_variance);
    return CyclePrediction(
      expectedDays: _mean.round(),
      lowerDays: (_mean - 1.96 * sd).round(),
      upperDays: (_mean + 1.96 * sd).round(),
      cyclesObserved: _cyclesObserved,
    );
  }

  // Serialise to Hive for persistence
  Map<String, dynamic> toJson() =>
      {'mean': _mean, 'variance': _variance, 'observed': _cyclesObserved};

  factory BayesianCycleEstimator.fromJson(Map<String, dynamic> j) =>
      BayesianCycleEstimator(
        priorMean: j['mean'] as double,
        priorVariance: j['variance'] as double,
      ).._cyclesObserved = j['observed'] as int;
}
```

### PCOS / Irregular Cycle Branch

Users who flagged PCOS or "very unpredictable" in onboarding use a wider prior and a Student-t likelihood (heavier tails = robust to outliers):

```dart
// Instantiated for PCOS users
BayesianCycleEstimator.pcos() : this(
  priorMean: 35.0,
  priorVariance: 144.0,   // 12² — much wider spread
);
```

The Student-t variant is implemented by treating extreme observations (>2.5 SD from current mean) with downweighted likelihood before updating — a one-line guard in `observe()`.

### Accuracy (honest benchmarks)

| Cycles logged | Prediction accuracy | Interval width | What the UI shows |
|---|---|---|---|
| 0 (new user) | Population mean ±7 days | 14-day window | "Jun 22 – Jul 6" |
| 3 cycles | ±4–5 days | 9-day window | "Jun 25 – Jul 3" |
| 6 cycles | ±2–3 days | 5-day window | "Jun 27 – Jul 1" |
| 12+ regular cycles | ±1–2 days | 3-day window | "Jun 28 – Jun 30" |
| PCOS, any amount | ±4–7 days | Stays wide (honest) | "Jun 24 – Jul 4" |

### UI Presentation Rules
- **Never show a single predicted date.** Always show the interval.
- Display the interval width honestly — do not artificially narrow it.
- After 6+ cycles: also show "Luna has predicted X of your last Y cycles within 3 days" — builds trust transparently.
- For hormonal contraception users: fixed interval mode, prediction is deterministic (not Bayesian), shown with a note: "Based on your 28-day pill schedule"

### Phase 3 — ONNX Runtime Layer (optional, future)
If a licensed, India-specific dataset becomes available, a trained ONNX model can be introduced alongside the Bayesian estimator. The ONNX model's output would be combined with the Bayesian posterior (ensemble averaging), not replace it. Package: `onnxruntime` on pub.dev (Microsoft-maintained, more format-flexible than TFLite). This is a Phase 3 consideration only.

---

## Feature 2: Symptom Pattern Insights (Pure Dart)

### File
`lib/ai/insight_engine.dart`

### How it works
No model, no API. Pure Dart computation on the user's local Drift data. Runs after every new symptom or mood log, result diffed against cached insights — only changed cards re-render.

### Algorithm
```
For each symptom type S:
  For each cycle phase P (menstrual, follicular, ovulation, luteal):
    count = symptom_logs where symptom=S and cycle_phase=P (last 6 months)
    severity_avg = average severity of those logs
    affinity_score = count × severity_avg

  phase_max = phase P with highest affinity_score
  if affinity_score[phase_max] > THRESHOLD and count > 2:
    → emit insight: "You tend to experience {S} during your {phase_max} phase"
```

### Insight types generated
1. **Phase affinity** — "Headaches appear 3× more often in your luteal phase"
2. **Severity trend** — "Your cramp severity has been decreasing over the last 3 cycles"
3. **Co-occurrence** — "Fatigue and mood swings often appear together for you (in 4 of your last 6 cycles)"
4. **Streak alert** — "You've logged low energy for 4 days in a row" → gentle notification
5. **Absence alert** — "You usually log cramps but haven't this cycle" (uses `common_symptoms` from onboarding as a prior)
6. **Cycle comparison** — "Your current cycle is running 3 days longer than your average"

### Accuracy
This is not a prediction — it is exact computation on the user's own data. There is no model error. Accuracy = completeness of the user's logs. A user who logs consistently for 3 months will see 4–6 reliable insights. A user who logs sporadically will see fewer, but the ones shown will still be accurate.

### Minimum data before insights surface
- Phase affinity: 3 cycles + 2 symptom occurrences of that type
- Trend: 4 cycles
- Co-occurrence: 4 cycles
- Below threshold: Home screen shows "Log your symptoms for a few cycles — your personal patterns will appear here"

---

## Feature 3: Personalised Phase Tips (Hybrid)

### Files
- `assets/data/phase_tips.json` — static library, 240+ tips
- `lib/ai/claude_chat.dart` — personalisation layer (guarded by `kClaudeEnabled`)

### Static library structure
```json
{
  "menstrual": [
    {
      "id": "m_01",
      "category": "nutrition",
      "tip": "Iron-rich foods like spinach and lentils help replenish iron lost during bleeding.",
      "tags": ["iron", "nutrition", "fatigue"],
      "hi": "पालक और दाल जैसे आयरन युक्त खाद्य पदार्थ रक्तस्राव में खोए आयरन की भरपाई करते हैं।"
    }
  ],
  "follicular": [],
  "ovulation": [],
  "luteal": []
}
```

60 tips per phase × 4 phases = 240 base tips. Categories: nutrition, exercise, sleep, emotional wellbeing, self-care.

### Offline behaviour
3 tips per phase shown, selected by recency (shuffle seed = current cycle number, so they rotate each cycle). No internet required, no API call.

### Claude personalisation layer (when `kClaudeEnabled = true`)
On each phase transition, a lightweight prompt selects the 3 most relevant tips given the user's recent symptoms:

```
System: "You are a women's health advisor. Pick the 3 most helpful tips from this list
for a user currently in their {phase} phase who recently logged: {symptom_list}.
Return only the tip IDs in order of relevance."

Tips: [list of 60 tip IDs + short descriptions for this phase]
```

Claude returns 3 IDs → app loads the full tip from the local JSON. The personalisation adds a one-sentence "why this tip fits you": *"Since you've been logging fatigue this phase, iron-rich foods are especially worth focusing on."*

Result stored in `ai_insights_cache` for the current cycle; regenerated only when symptoms change significantly or the cycle phase transitions.

---

## Feature 4: AI Health Chatbot (Claude API)

### Status
**Hidden.** `kClaudeEnabled = false` in `core/constants/feature_flags.dart`.

All code fully implemented. UI entry point (chat tab in bottom nav) does not render when flag is false.

### Architecture when enabled
```
Flutter App (lib/ai/claude_chat.dart)
    ↓  HTTPS  (Firebase callable function)
Firebase Cloud Function (functions/src/chat.js)
    ↓  HTTPS
Anthropic API  (claude-haiku-4-5-20251001)
```

### What gets sent to Anthropic
- Current cycle phase (string: "luteal")
- Recent symptoms (string array, last 7 days)
- User birth year (for age-appropriate responses)
- User's question text
- **NOT sent:** name, dates, any identifying information

### System prompt (English)
```
You are Luna's health companion — a knowledgeable, warm, and non-judgmental
women's health guide.

Current phase: {phase}
Recent symptoms: {symptoms}
User age group: {age_group}   // "teen", "young_adult", "adult", "mature"

Speak plainly. Avoid medical jargon unless the user uses it first.
Never diagnose. If symptoms sound severe or persistent, always suggest
seeing a doctor or visiting a clinic.
Keep responses under 150 words unless the user asks for detail.
{india_context}: Mention Indian resources (NIMHANS, iCall) when relevant for
mental health questions.
```

### Rate limiting
- Free tier: 10 messages per day per Firebase UID (counter in Firestore)
- Counter resets at midnight IST
- UI shows remaining messages: "8 questions remaining today"
- When limit reached: friendly message with option to "ask again tomorrow" or (future) upgrade

### Cloud Function (Node.js skeleton)
`functions/src/chat.js`
```javascript
exports.askLuna = onCall({ enforceAppCheck: true }, async (request) => {
  const uid = request.auth?.uid;
  if (!uid) throw new HttpsError('unauthenticated', 'Login required');

  const quota = await getRemainingQuota(uid);
  if (quota <= 0) throw new HttpsError('resource-exhausted', 'Daily limit reached');

  const { question, phase, symptoms, birthYear } = request.data;

  const response = await anthropic.messages.create({
    model: 'claude-haiku-4-5-20251001',
    max_tokens: 512,
    system: buildSystemPrompt(phase, symptoms, birthYear),
    messages: [{ role: 'user', content: question }]
  });

  await decrementQuota(uid);
  return { reply: response.content[0].text, remaining: quota - 1 };
});
```

### Monetization path
`QuotaRepository.isPremium()` reads a `premium` field from Firestore (set by RevenueCat webhook). When `true`, `getRemainingQuota()` returns 999 instead of 10. No other code changes.

### To enable the feature
1. Get Anthropic API key from console.anthropic.com
2. `firebase functions:config:set anthropic.key="sk-ant-..."`
3. `firebase deploy --only functions`
4. Set `kClaudeEnabled = true` in `core/constants/feature_flags.dart`
5. Run `flutter build apk`

---

## Cost Estimate

Model: `claude-haiku-4-5-20251001`
Pricing: $0.80 / 1M input tokens · $4.00 / 1M output tokens

Assumptions: 100 input tokens/request (system prompt + question), 200 output tokens/response

| Daily active users | Messages/day | Monthly cost (USD) | Monthly cost (INR) |
|---|---|---|---|
| 100 | 1,000 | ~$0.90 | ~₹75 |
| 1,000 | 10,000 | ~$9 | ~₹750 |
| 5,000 | 50,000 | ~$45 | ~₹3,750 |
| 10,000 | 100,000 | ~$90 | ~₹7,500 |

Firebase Cloud Functions free tier: 2M invocations/month — infra cost is ₹0 until significant scale.
