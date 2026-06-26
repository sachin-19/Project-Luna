import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../../core/utils/cycle_calculator.dart';
import '../../domain/services/cycle_estimator_service.dart';

final cycleEstimatorServiceProvider = Provider<CycleEstimatorService>((ref) {
  final box = Hive.box<dynamic>('settings');
  return CycleEstimatorService(box);
});

/// Current prediction from the Bayesian estimator (or fixed-interval for pill users).
final cyclePredictionProvider = Provider<CyclePrediction>((ref) {
  return ref.watch(cycleEstimatorServiceProvider).currentPrediction;
});

/// How many of the last N cycles Luna predicted within 3 days.
final predictionAccuracyProvider =
    Provider<({int accurate, int total})>((ref) {
  return ref.watch(cycleEstimatorServiceProvider).accuracyStats;
});
