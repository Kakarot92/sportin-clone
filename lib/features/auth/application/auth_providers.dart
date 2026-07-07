import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/models/app_user.dart';
import '../data/auth_repository.dart';

final firebaseAuthProvider =
    Provider<FirebaseAuth>((ref) => FirebaseAuth.instance);

final firestoreProvider =
    Provider<FirebaseFirestore>((ref) => FirebaseFirestore.instance);

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepository(
    ref.watch(firebaseAuthProvider),
    ref.watch(firestoreProvider),
  );
});

/// Emits the signed-in Firebase user (or null). Drives route guards.
final authStateChangesProvider = StreamProvider<User?>((ref) {
  return ref.watch(authRepositoryProvider).authStateChanges();
});

/// The current user's Firestore profile (role, name, phone), or null.
final appUserProvider = StreamProvider<AppUser?>((ref) {
  final user = ref.watch(authStateChangesProvider).asData?.value;
  if (user == null) return Stream.value(null);
  return ref.watch(authRepositoryProvider).watchAppUser(user.uid);
});

/// Handles auth actions (signup/login/logout/reset) with loading/error state.
class AuthController extends AsyncNotifier<void> {
  @override
  Future<void> build() async {}

  AuthRepository get _repo => ref.read(authRepositoryProvider);

  Future<void> signUp({
    required String email,
    required String password,
    required String displayName,
    required String phone,
  }) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(
      () => _repo.signUp(
        email: email,
        password: password,
        displayName: displayName,
        phone: phone,
      ),
    );
  }

  Future<void> signIn({
    required String email,
    required String password,
  }) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(
      () => _repo.signIn(email: email, password: password),
    );
  }

  Future<void> signOut() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(_repo.signOut);
  }

  Future<bool> sendPasswordReset(String email) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() => _repo.sendPasswordReset(email));
    return !state.hasError;
  }

  Future<bool> updateProfile({
    required String uid,
    required String displayName,
    required String phone,
  }) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(
      () => _repo.updateProfile(uid, displayName: displayName, phone: phone),
    );
    return !state.hasError;
  }
}

final authControllerProvider =
    AsyncNotifierProvider<AuthController, void>(AuthController.new);
