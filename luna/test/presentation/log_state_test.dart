import 'package:flutter_test/flutter_test.dart';
import 'package:luna/core/constants/enums.dart';
import 'package:luna/presentation/providers/log_provider.dart';

void main() {
  group('LogState.hasAnyData', () {
    test('false when everything is empty', () {
      const state = LogState();
      expect(state.hasAnyData, isFalse);
    });

    test('true when flow is set', () {
      const state = LogState(flow: FlowIntensity.medium);
      expect(state.hasAnyData, isTrue);
    });

    test('true when mood is set', () {
      const state = LogState(mood: Mood.calm);
      expect(state.hasAnyData, isTrue);
    });

    test('true when a symptom is explicitly logged (not auto)', () {
      const state = LogState(
        symptoms: {Symptom.cramps: 3},
        autoSymptoms: {},
      );
      expect(state.hasAnyData, isTrue);
    });

    test('false when only auto-symptoms are present (user never interacted)', () {
      // initCommonSymptoms pre-fills symptoms and marks them all auto.
      // Tapping Save without interacting should be a no-op.
      const state = LogState(
        symptoms: {Symptom.cramps: 1, Symptom.bloating: 1},
        autoSymptoms: {Symptom.cramps, Symptom.bloating},
      );
      expect(state.hasAnyData, isFalse);
    });

    test('true when at least one symptom was explicitly interacted with', () {
      // User tapped cramps (removed from autoSymptoms) but bloating is still auto.
      const state = LogState(
        symptoms: {Symptom.cramps: 3, Symptom.bloating: 1},
        autoSymptoms: {Symptom.bloating},
      );
      expect(state.hasAnyData, isTrue);
    });

    test('true when auto-symptoms exist alongside a flow', () {
      const state = LogState(
        flow: FlowIntensity.light,
        symptoms: {Symptom.cramps: 1},
        autoSymptoms: {Symptom.cramps},
      );
      expect(state.hasAnyData, isTrue);
    });
  });
}
