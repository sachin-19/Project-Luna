import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../../core/constants/enums.dart';
import '../../data/remote/update_service.dart';
import '../../domain/entities/update_info.dart';

const _kLastDismissedKey = 'update_last_dismissed_ms';
const _kCooldownDuration = Duration(hours: 24);

// ── State ─────────────────────────────────────────────────────────────────────

class UpdateState {
  const UpdateState({
    this.status = UpdateStatus.idle,
    this.info,
    this.progress = 0.0,
    this.error,
  });

  final UpdateStatus status;
  final UpdateInfo? info;
  final double progress;
  final String? error;

  UpdateState copyWith({
    UpdateStatus? status,
    UpdateInfo? info,
    double? progress,
    String? error,
  }) =>
      UpdateState(
        status: status ?? this.status,
        info: info ?? this.info,
        progress: progress ?? this.progress,
        error: error,
      );
}

// ── Notifier ──────────────────────────────────────────────────────────────────

class UpdateNotifier extends StateNotifier<UpdateState> {
  UpdateNotifier(this._service) : super(const UpdateState());

  final UpdateService _service;

  /// Called once on app start (after 500ms delay so the home screen settles).
  Future<void> checkForUpdate() async {
    if (state.status != UpdateStatus.idle) return;

    state = state.copyWith(status: UpdateStatus.checking);

    final info = await _service.fetchUpdateInfo();
    if (info == null) {
      state = state.copyWith(status: UpdateStatus.idle);
      return;
    }

    final newer = await _service.isUpdateAvailable(info.latestVersion);
    if (!newer) {
      state = state.copyWith(status: UpdateStatus.idle);
      return;
    }

    // For optional updates respect the 24-hour cooldown.
    if (!info.isMandatory && _isWithinCooldown()) {
      state = state.copyWith(status: UpdateStatus.idle);
      return;
    }

    state = state.copyWith(status: UpdateStatus.available, info: info);
  }

  Future<void> startDownload() async {
    final info = state.info;
    if (info == null) return;

    state = state.copyWith(status: UpdateStatus.downloading, progress: 0.0);

    try {
      await _service.downloadAndInstall(
        info,
        onProgress: (p) {
          state = state.copyWith(progress: p);
        },
      );
      state = state.copyWith(
          status: UpdateStatus.readyToInstall, progress: 1.0);
    } catch (e) {
      state = state.copyWith(
          status: UpdateStatus.error, error: e.toString());
    }
  }

  /// Used by the manual "Check for updates" button in Settings.
  /// Always runs a fresh check regardless of current state or cooldown.
  Future<void> forceCheck() async {
    state = const UpdateState();
    state = state.copyWith(status: UpdateStatus.checking);

    final info = await _service.fetchUpdateInfo();
    if (info == null) {
      state = state.copyWith(status: UpdateStatus.idle);
      return;
    }

    final newer = await _service.isUpdateAvailable(info.latestVersion);
    if (!newer) {
      state = state.copyWith(status: UpdateStatus.idle);
      return;
    }

    state = state.copyWith(status: UpdateStatus.available, info: info);
  }

  void dismissOptional() {
    final info = state.info;
    if (info == null || info.isMandatory) return;
    Hive.box<dynamic>('settings').put(
      _kLastDismissedKey,
      DateTime.now().millisecondsSinceEpoch,
    );
    state = const UpdateState();
  }

  bool _isWithinCooldown() {
    final raw = Hive.box<dynamic>('settings').get(_kLastDismissedKey);
    if (raw is! int) return false;
    final last = DateTime.fromMillisecondsSinceEpoch(raw);
    return DateTime.now().difference(last) < _kCooldownDuration;
  }
}

// ── Providers ─────────────────────────────────────────────────────────────────

final updateServiceProvider = Provider<UpdateService>((ref) => UpdateService());

final updateNotifierProvider =
    StateNotifierProvider<UpdateNotifier, UpdateState>((ref) {
  return UpdateNotifier(ref.read(updateServiceProvider));
});
