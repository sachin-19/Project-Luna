import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'database/database_provider.dart';
import 'repositories/user_repository_impl.dart';
import 'repositories/cycle_repository_impl.dart';
import 'repositories/symptom_repository_impl.dart';
import 'repositories/mood_repository_impl.dart';
import '../domain/repositories/user_repository.dart';
import '../domain/repositories/cycle_repository.dart';
import '../domain/repositories/symptom_repository.dart';
import '../domain/repositories/mood_repository.dart';

final userRepositoryProvider = Provider<UserRepository>((ref) {
  final db = ref.watch(databaseProvider);
  return UserRepositoryImpl(db.userDao);
});

final cycleRepositoryProvider = Provider<CycleRepository>((ref) {
  final db = ref.watch(databaseProvider);
  return CycleRepositoryImpl(db.cycleDao);
});

final symptomRepositoryProvider = Provider<SymptomRepository>((ref) {
  final db = ref.watch(databaseProvider);
  return SymptomRepositoryImpl(db.symptomDao);
});

final moodRepositoryProvider = Provider<MoodRepository>((ref) {
  final db = ref.watch(databaseProvider);
  return MoodRepositoryImpl(db.moodDao);
});
