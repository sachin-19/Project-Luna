import 'package:credential_manager/credential_manager.dart';
import 'package:flutter/foundation.dart';

/// Wraps Android Credential Manager for password save + biometric retrieve.
///
/// All public methods are fire-and-forget safe: they never throw.
/// Silently no-ops on unsupported platforms (e.g. web, desktop).
class CredentialService {
  CredentialService._();
  static final CredentialService instance = CredentialService._();

  final _mgr = CredentialManager();
  bool _initialized = false;

  Future<bool> _ensureInit() async {
    if (_initialized) return true;
    if (!_mgr.isSupportedPlatform) return false;
    try {
      await _mgr.init(preferImmediatelyAvailableCredentials: false);
      _initialized = true;
      return true;
    } catch (e) {
      if (kDebugMode) debugPrint('CredentialService.init: $e');
      return false;
    }
  }

  /// Prompts Android to save [email] + [password] to Google Password Manager.
  /// Shows "Save password?" bottom sheet — user can dismiss without impact.
  Future<void> saveCredentials(String email, String password) async {
    if (!await _ensureInit()) return;
    try {
      await _mgr.savePasswordCredentials(
        PasswordCredential(username: email, password: password),
      );
    } on CredentialException catch (e) {
      // 301 = user dismissed "Save password?" — expected, silent.
      if (kDebugMode) {
        debugPrint('CredentialService.save: ${e.code} ${e.message}');
      }
    } catch (e) {
      if (kDebugMode) debugPrint('CredentialService.save: $e');
    }
  }

  /// Shows the Android credential picker with biometric confirmation.
  /// Returns the saved [PasswordCredential], or null if none saved / cancelled.
  Future<PasswordCredential?> getCredentials() async {
    if (!await _ensureInit()) return null;
    try {
      final result = await _mgr.getCredentials(
        fetchOptions: FetchOptionsAndroid(passwordCredential: true),
      );
      return result.passwordCredential;
    } on CredentialException catch (e) {
      // 201 = user cancelled, 202 = none found → both silent.
      if (kDebugMode) {
        debugPrint('CredentialService.get: ${e.code} ${e.message}');
      }
      return null;
    } catch (e) {
      if (kDebugMode) debugPrint('CredentialService.get: $e');
      return null;
    }
  }
}
