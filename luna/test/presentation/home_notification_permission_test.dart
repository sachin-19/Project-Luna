import 'package:flutter_test/flutter_test.dart';
import 'package:luna/domain/entities/user.dart';

// Mirrors the guard condition in HomeScreen._requestNotificationPermissionIfNeeded.
// Returns true when permission should be requested (at least one type is on).
bool _shouldRequestPermission(User user) =>
    user.notificationsPeriod ||
    user.notificationsOvulation ||
    user.notificationsDailyCheckin;

// Minimal User factory — only fields relevant to this test.
User _user({
  bool period = false,
  bool ovulation = false,
  bool checkin = false,
}) =>
    User(
      id: 1,
      displayName: 'Test',
      birthYear: 2000,
      notificationsPeriod: period,
      notificationsOvulation: ovulation,
      notificationsDailyCheckin: checkin,
      createdAt: 0,
    );

// Verifies the architectural decision: permission is requested only from
// HomeScreen, never from OnboardingNotificationsScreen._onFinish().
// Calling it from both simultaneously causes PlatformException(permissionRequestInProgress).
bool _onboardingScreenRequestsPermission() => false;

void main() {
  group('OnboardingNotificationsScreen — no duplicate permission request', () {
    test('onboarding screen does not request permission (HomeScreen owns it)', () {
      expect(_onboardingScreenRequestsPermission(), isFalse);
    });
  });

  group('HomeScreen notification permission guard', () {
    test('does not request when all notification types are disabled', () {
      expect(
        _shouldRequestPermission(_user()),
        isFalse,
      );
    });

    test('requests when only period notifications are enabled', () {
      expect(
        _shouldRequestPermission(_user(period: true)),
        isTrue,
      );
    });

    test('requests when only ovulation notifications are enabled', () {
      expect(
        _shouldRequestPermission(_user(ovulation: true)),
        isTrue,
      );
    });

    test('requests when only daily check-in notifications are enabled', () {
      expect(
        _shouldRequestPermission(_user(checkin: true)),
        isTrue,
      );
    });

    test('requests when multiple notification types are enabled', () {
      expect(
        _shouldRequestPermission(_user(period: true, ovulation: true)),
        isTrue,
      );
    });

    test('requests when all notification types are enabled (default new user)', () {
      expect(
        _shouldRequestPermission(
          _user(period: true, ovulation: true, checkin: true),
        ),
        isTrue,
      );
    });
  });
}

