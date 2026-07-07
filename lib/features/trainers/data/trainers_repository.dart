import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../core/models/trainer_profile.dart';

class TrainersRepository {
  TrainersRepository(this._db);

  final FirebaseFirestore _db;

  CollectionReference<Map<String, dynamic>> get _col =>
      _db.collection('trainers');

  Stream<List<TrainerProfile>> watchTrainers() {
    return _col.orderBy('displayName').snapshots().map(
          (snap) => snap.docs
              .map((d) => TrainerProfile.fromMap(d.id, d.data()))
              .toList(),
        );
  }

  Stream<TrainerProfile?> watchTrainer(String uid) {
    return _col.doc(uid).snapshots().map(
          (d) => d.exists ? TrainerProfile.fromMap(d.id, d.data()!) : null,
        );
  }

  Future<void> upsert(TrainerProfile profile) {
    return _col.doc(profile.uid).set(profile.toMap(), SetOptions(merge: true));
  }
}
