import 'package:firebase_auth/firebase_auth.dart' as fb;
import 'package:hive_flutter/hive_flutter.dart';
import '../../core/constants/feature_flags.dart';
import '../../domain/repositories/auth_repository.dart';

class AuthRepositoryImpl implements AuthRepository {
  static const _kUidKey = 'auth_uid';
  static const _kEmailKey = 'auth_email';

  fb.FirebaseAuth get _auth => fb.FirebaseAuth.instance;
  Box<dynamic> get _box => Hive.box<dynamic>('settings');

  @override
  Stream<String?> get authStateChanges {
    if (!kFirebaseEnabled) return Stream.value(null);
    return _auth.authStateChanges().map((u) => u?.uid);
  }

  @override
  String? get currentUid {
    if (!kFirebaseEnabled) return null;
    return _auth.currentUser?.uid ?? _box.get(_kUidKey) as String?;
  }

  @override
  String? get currentEmail {
    if (!kFirebaseEnabled) return null;
    return _auth.currentUser?.email ?? _box.get(_kEmailKey) as String?;
  }

  @override
  bool get isAuthenticated {
    if (!kFirebaseEnabled) return false;
    return _auth.currentUser != null;
  }

  @override
  Future<void> signUp({required String email, required String password}) async {
    final cred = await _auth.createUserWithEmailAndPassword(
      email: email.trim(),
      password: password,
    );
    await _box.put(_kUidKey, cred.user!.uid);
    await _box.put(_kEmailKey, email.trim());
  }

  @override
  Future<void> signIn({required String email, required String password}) async {
    final cred = await _auth.signInWithEmailAndPassword(
      email: email.trim(),
      password: password,
    );
    await _box.put(_kUidKey, cred.user!.uid);
    await _box.put(_kEmailKey, email.trim());
  }

  @override
  Future<void> signOut() async {
    await _auth.signOut();
    await _box.delete(_kUidKey);
    await _box.delete(_kEmailKey);
  }
}
