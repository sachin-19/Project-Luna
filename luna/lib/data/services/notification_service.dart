import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import '../../core/utils/cycle_calculator.dart';
import '../../domain/entities/cycle_entry.dart';
import '../../domain/entities/user.dart';

const _kChannelId = 'luna_reminders';
const _kChannelName = 'Luna reminders';
const _kChannelDesc = 'Period, ovulation, and daily check-in reminders';

abstract final class _Id {
  static const int periodReminder = 1;
  static const int ovulationAlert = 2;
  static const int dailyCheckin = 3;
}

/// Schedules and cancels all Luna notifications.
///
/// Call [init] once in main() after [tz.initializeTimeZones].
/// Call [scheduleAll] whenever the user or active cycle changes.
///
/// Scheduling strategy: all times are computed as local [DateTime] then
/// converted to UTC via [DateTime.toUtc] and wrapped in [tz.UTC].  This
/// avoids the [flutter_timezone] dependency while remaining correct for
/// India (no DST) and approximately correct for DST regions.
class NotificationService {
  const NotificationService();

  static final _plugin = FlutterLocalNotificationsPlugin();
  static bool _ready = false;

  // ── Init ──────────────────────────────────────────────────────────────────

  static Future<void> init() async {
    if (_ready) return;
    const androidInit = AndroidInitializationSettings('@mipmap/ic_launcher');
    const initSettings = InitializationSettings(android: androidInit);
    await _plugin.initialize(initSettings);
    _ready = true;
  }

  // ── Public API ────────────────────────────────────────────────────────────

  /// Requests OS notification permission. Returns whether granted.
  Future<bool> requestPermission() async {
    final android = _plugin.resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>();
    return await android?.requestNotificationsPermission() ?? false;
  }

  /// Cancels all pending notifications then reschedules based on [user]
  /// preferences and the current [cycle] dates.
  Future<void> scheduleAll(User user, CycleEntry? cycle) async {
    await _plugin.cancelAll();

    // Prefer exact alarms (fires on time even in Doze mode). Falls back to
    // inexact if the OS hasn't granted the exact-alarm permission yet.
    final mode = await _resolveScheduleMode();

    if (user.notificationsDailyCheckin) {
      await _scheduleDailyCheckin(mode);
    }

    if (cycle == null) return;

    final cycleLength = user.avgCycleDays;
    final leadDays = user.notificationLeadDays;
    final nextStart = CycleCalculator.predictedNextStart(
      cycle.startDateTime,
      cycleLength: cycleLength,
    );

    if (user.notificationsPeriod) {
      final reminderDay = nextStart.subtract(Duration(days: leadDays));
      await _schedulePeriodReminder(reminderDay, leadDays, mode);
    }

    if (user.notificationsOvulation) {
      final ovulation = CycleCalculator.approximateOvulationDate(
        cycle.startDateTime,
        cycleLength: cycleLength,
      );
      // Alert at the start of the fertile window (5 days before ovulation).
      final fertileStart = ovulation.subtract(const Duration(days: 5));
      await _scheduleOvulationAlert(fertileStart, mode);
    }
  }

  Future<void> cancelAll() => _plugin.cancelAll();

  // ── Individual schedulers ─────────────────────────────────────────────────

  Future<void> _schedulePeriodReminder(
    DateTime date,
    int leadDays,
    AndroidScheduleMode mode,
  ) async {
    final scheduled = _toUtcTZ(date, hour: 9);
    if (scheduled == null) return;

    await _plugin.zonedSchedule(
      _Id.periodReminder,
      'Your period is coming',
      leadDays == 1
          ? 'Expected tomorrow. Stock up on supplies.'
          : 'Expected in $leadDays days. Be prepared.',
      scheduled,
      _details(),
      androidScheduleMode: mode,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
    );
  }

  Future<void> _scheduleOvulationAlert(
    DateTime fertileWindowStart,
    AndroidScheduleMode mode,
  ) async {
    final scheduled = _toUtcTZ(fertileWindowStart, hour: 9);
    if (scheduled == null) return;

    await _plugin.zonedSchedule(
      _Id.ovulationAlert,
      'Fertile window starting',
      'Your most fertile days begin now. Peak fertility in about 5 days.',
      scheduled,
      _details(),
      androidScheduleMode: mode,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
    );
  }

  Future<void> _scheduleDailyCheckin(AndroidScheduleMode mode) async {
    final now = DateTime.now();
    var targetLocal = DateTime(now.year, now.month, now.day, 20); // 8 PM
    if (targetLocal.isBefore(now)) {
      targetLocal = targetLocal.add(const Duration(days: 1));
    }
    final scheduled = tz.TZDateTime.from(targetLocal.toUtc(), tz.UTC);

    await _plugin.zonedSchedule(
      _Id.dailyCheckin,
      'How are you feeling today?',
      'Take a moment to log your symptoms and mood.',
      scheduled,
      _details(),
      androidScheduleMode: mode,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      // Repeat at the same UTC hour daily — correct for India (no DST).
      matchDateTimeComponents: DateTimeComponents.time,
    );
  }

  // ── Helpers ───────────────────────────────────────────────────────────────

  /// Returns [exactAllowWhileIdle] if the OS has granted the exact-alarm
  /// permission (USE_EXACT_ALARM / SCHEDULE_EXACT_ALARM), otherwise falls back
  /// to [inexactAllowWhileIdle]. Exact alarms fire on time even during Doze;
  /// inexact alarms can be deferred by the OS for minutes or hours.
  static Future<AndroidScheduleMode> _resolveScheduleMode() async {
    final android = _plugin.resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>();
    final canExact = await android?.canScheduleExactNotifications() ?? false;
    return canExact
        ? AndroidScheduleMode.exactAllowWhileIdle
        : AndroidScheduleMode.inexactAllowWhileIdle;
  }

  /// Converts a local date's [hour]:00 to a UTC [tz.TZDateTime].
  /// Returns null if the resulting time is already in the past.
  tz.TZDateTime? _toUtcTZ(DateTime date, {required int hour}) {
    final localTarget = DateTime(date.year, date.month, date.day, hour);
    final utcTarget = localTarget.toUtc();
    final scheduled = tz.TZDateTime.from(utcTarget, tz.UTC);
    return scheduled.isAfter(tz.TZDateTime.now(tz.UTC)) ? scheduled : null;
  }

  static NotificationDetails _details() => const NotificationDetails(
        android: AndroidNotificationDetails(
          _kChannelId,
          _kChannelName,
          channelDescription: _kChannelDesc,
          importance: Importance.high,
          priority: Priority.high,
          icon: '@mipmap/ic_launcher',
        ),
      );
}
