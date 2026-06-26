import '../entities/user.dart';

abstract interface class UserRepository {
  Stream<User?> watchUser();
  Future<User?> getUser();
  Future<void> saveUser(User user);
  Future<void> setOnboarded();
}
