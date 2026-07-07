import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../core/models/app_user.dart';

/// Admin-only operations over the `users` and `trainers` collections.
class AdminRepository {
  AdminRepository(this._db);

  final FirebaseFirestore _db;

  Stream<List<AppUser>> watchAllUsers() {
    return _db.collection('users').orderBy('displayName').snapshots().map(
          (snap) =>
              snap.docs.map((d) => AppUser.fromMap(d.id, d.data())).toList(),
        );
  }

  /// Grants or revokes the trainer role: updates `users/{uid}.role` and
  /// creates/removes the public `trainers/{uid}` profile accordingly.
  Future<void> setTrainer(AppUser user, {required bool isTrainer}) async {
    final usersDoc = _db.collection('users').doc(user.uid);
    final trainerDoc = _db.collection('trainers').doc(user.uid);
    await usersDoc.update({'role': isTrainer ? 'trainer' : 'client'});
    if (isTrainer) {
      await trainerDoc.set(
        {'displayName': user.displayName, 'bio': '', 'photoUrl': ''},
        SetOptions(merge: true),
      );
    } else {
      await trainerDoc.delete();
    }
  }
}
