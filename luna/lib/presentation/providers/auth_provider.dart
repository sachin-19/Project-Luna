import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../../core/constants/feature_flags.dart';
import '../../data/providers.dart';
import '../../data/repositories/auth_repository_impl.dart';
import '../../data/services/sync_service.dart';
import '../../domain/repositories/auth_repository.dart';

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepositoryImpl();
});

/// Emits the current Firebase UID, or null when signed out / Firebase disabled.
final authStateProvider = StreamProvider<String?>((ref) {
  if (!kFirebaseEnabled) return Stream.value(null);
  return ref.watch(authRepositoryProvider).authStateChanges;
});

/// True when a user is signed in AND kFirebaseEnabled.
final isAuthenticatedProvider = Provider<bool>((ref) {
  if (!kFirebaseEnabled) return false;
  return ref.watch(authStateProvider).valueOrNull != null;
});

final syncServiceProvider = Provider<SyncService>((ref) {
  return SyncService(
    userRepo: ref.read(userRepositoryProvider),
    cycleRepo: ref.read(cycleRepositoryProvider),
    symptomRepo: ref.read(symptomRepositoryProvider),
    moodRepo: ref.read(moodRepositoryProvider),
  );
});

// ── Sync state ────────────────────────────────────────────────────────────────

class SyncState {
  final bool isSyncing;
  final DateTime? lastSyncTime;
  final String? error;

  const SyncState({
    this.isSyncing = false,
    this.lastSyncTime,
    this.error,
  });
}

class SyncNotifier extends Notifier<SyncState> {
  static const _kLastSyncKey = 'auth_last_sync';

  @override
  SyncState build() {
    final box = Hive.box<dynamic>('settings');
    final lastMs = box.get(_kLastSyncKey) as int?;
    return SyncState(
      lastSyncTime: lastMs != null
          ? DateTime.fromMillisecondsSinceEpoch(lastMs)
          : null,
    );
  }

  Future<void> sync() async {
    if (!kFirebaseEnabled) return;
    final uid = ref.read(authRepositoryProvider).currentUid;
    if (uid == null) return;
    state = SyncState(isSyncing: true, lastSyncTime: state.lastSyncTime);
    try {
      await ref.read(syncServiceProvider).pushAll(uid);
      final now = DateTime.now();
      Hive.box<dynamic>('settings')
          .put(_kLastSyncKey, now.millisecondsSinceEpoch);
      state = SyncState(isSyncing: false, lastSyncTime: now);
    } catch (e) {
      state = SyncState(
        isSyncing: false,
        lastSyncTime: state.lastSyncTime,
        error: e.toString(),
      );
    }
  }
}

final syncNotifierProvider =
    NotifierProvider<SyncNotifier, SyncState>(() => SyncNotifier());
