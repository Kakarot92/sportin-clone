import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/models/app_user.dart';
import '../../auth/application/auth_providers.dart';
import '../data/admin_repository.dart';

final adminRepositoryProvider = Provider<AdminRepository>((ref) {
  return AdminRepository(ref.watch(firestoreProvider));
});

/// All users, for the admin role-management screen. Firestore rules restrict
/// this list to admins.
final allUsersProvider = StreamProvider<List<AppUser>>((ref) {
  return ref.watch(adminRepositoryProvider).watchAllUsers();
});
