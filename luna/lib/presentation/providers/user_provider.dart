import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/providers.dart';
import '../../domain/entities/user.dart';

final userStreamProvider = StreamProvider<User?>((ref) {
  return ref.watch(userRepositoryProvider).watchUser();
});
