import 'package:cloud_firestore/cloud_firestore.dart';

import '../domain/trainer_client_ref.dart';

/// Firestore-backed repository for the trainer-client relationship markers.
///
/// Collection: `trainerClients/{trainerUid}_{clientUid}`
///
/// Documents are upserted (merge=true) each time a client books a trainer
/// inside [BookingRepository.createBooking] (AS-063, AS-064). The deterministic
/// document ID means security rules can call `exists()` with a known path
/// rather than running a query — which Firestore rules do not support.
class TrainerClientsRepository {
  TrainerClientsRepository(this._db);

  final FirebaseFirestore _db;

  // ─── Streams ─────────────────────────────────────────────────────────────

  /// Watches all clients that have ever booked [trainerUid], newest first.
  ///
  /// Ordered descending by `firstBookedAt` so the most recently acquired
  /// client appears first in list views (AS-063).
  Stream<List<TrainerClientRef>> watchMyClients(String trainerUid) {
    return _db
        .collection('trainerClients')
        .where('trainerUid', isEqualTo: trainerUid)
        .orderBy('firstBookedAt', descending: true)
        .snapshots()
        .map((snap) => snap.docs
            .map((d) => TrainerClientRef.fromMap(d.data()))
            .toList());
  }

  /// Watches ALL trainer-client relationships across the studio, newest first.
  ///
  /// Admin-only usage (AS-087). No `where` clause — single-field `orderBy`
  /// uses Firestore's auto-created index so no composite index is needed.
  Stream<List<TrainerClientRef>> watchAllRelationships() {
    return _db
        .collection('trainerClients')
        .orderBy('firstBookedAt', descending: true)
        .snapshots()
        .map((snap) => snap.docs
            .map((d) => TrainerClientRef.fromMap(d.data()))
            .toList());
  }

  // ─── Reads ────────────────────────────────────────────────────────────────

  /// Returns `true` if [trainerUid] has a `trainerClients` marker for
  /// [clientUid] (i.e. the client has booked this trainer at least once).
  ///
  /// This is a defensive client-side check; the real enforcement is via
  /// Firestore security rules, which use `exists()` on the same document
  /// path (AS-064).
  Future<bool> canTrainerView(String trainerUid, String clientUid) async {
    final doc = await _db
        .collection('trainerClients')
        .doc('${trainerUid}_$clientUid')
        .get();
    return doc.exists;
  }
}
