import 'package:drift/drift.dart';
import '../app_database.dart';
import '../tables/users_table.dart';

part 'user_dao.g.dart';

@DriftAccessor(tables: [UsersTable])
class UserDao extends DatabaseAccessor<AppDatabase> with _$UserDaoMixin {
  UserDao(super.db);

  Stream<UserRow?> watchUser() =>
      (select(usersTable)..limit(1)).watchSingleOrNull();

  Future<UserRow?> getUser() =>
      (select(usersTable)..limit(1)).getSingleOrNull();

  Future<int> upsertUser(UsersTableCompanion companion) =>
      into(usersTable).insertOnConflictUpdate(companion);
}
