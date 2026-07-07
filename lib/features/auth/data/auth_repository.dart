import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../../core/models/app_user.dart';

/// Wraps Firebase Auth and the `users/{uid}` Firestore profile document.
class AuthRepository {
  AuthRepository(this._auth, this._firestore);

  final FirebaseAuth _auth;
  final FirebaseFirestore _firestore;

  CollectionReference<Map<String, dynamic>> get _users =>
      _firestore.collection('users');

  User? get currentUser => _auth.currentUser;

  Stream<User?> authStateChanges() => _auth.authStateChanges();

  Stream<AppUser?> watchAppUser(String uid) {
    return _users.doc(uid).snapshots().map(
          (doc) => doc.exists ? AppUser.fromMap(uid, doc.data()!) : null,
        );
  }

  Future<void> signUp({
    required String email,
    required String password,
    required String displayName,
    required String phone,
  }) async {
    final cred = await _auth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );
    final user = cred.user!;
    await _users.doc(user.uid).set({
      'email': email,
      'displayName': displayName,
      'phone': phone,
      'role': AppRole.client.name,
      'consentAcceptedAt': FieldValue.serverTimestamp(),
      'createdAt': FieldValue.serverTimestamp(),
    });
    if (displayName.isNotEmpty) {
      await user.updateDisplayName(displayName);
    }
  }

  Future<void> signIn({
    required String email,
    required String password,
  }) {
    return _auth.signInWithEmailAndPassword(email: email, password: password);
  }

  Future<void> signOut() => _auth.signOut();

  Future<void> sendPasswordReset(String email) =>
      _auth.sendPasswordResetEmail(email: email);

  Future<void> updateProfile(
    String uid, {
    required String displayName,
    required String phone,
  }) {
    return _users.doc(uid).update({
      'displayName': displayName,
      'phone': phone,
    });
  }
}
