abstract interface class AuthRepository {
  Stream<String?> get authStateChanges;
  String? get currentUid;
  String? get currentEmail;
  bool get isAuthenticated;
  Future<void> signUp({required String email, required String password});
  Future<void> signIn({required String email, required String password});
  Future<void> signOut();
}
