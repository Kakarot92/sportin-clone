import 'package:cloud_firestore/cloud_firestore.dart';

import '../domain/measurement_entry.dart';

/// Firestore-backed repository for client body-measurement entries.
///
/// Collections:
/// - `measurements/{autoId}` — one document per measurement entry
///
/// Security is enforced server-side via Firestore rules:
/// - Only the entry's owner may create/update/delete (AS-057, AS-062).
/// - The owner's trainer(s) — determined via `trainerClients` marker — may
///   read but never write (AS-063, AS-064).
class MeasurementsRepository {
  MeasurementsRepository(this._db);

  final FirebaseFirestore _db;

  // ─── Streams ─────────────────────────────────────────────────────────────

  /// Watches all measurement entries for [clientUid], newest first.
  ///
  /// Ordered descending by [MeasurementEntry.date] so callers receive the
  /// most recent reading at index 0 — convenient for "latest measurement"
  /// display (AS-061, AS-065).
  Stream<List<MeasurementEntry>> watchClientMeasurements(String clientUid) {
    return _db
        .collection('measurements')
        .where('clientUid', isEqualTo: clientUid)
        .orderBy('date', descending: true)
        .snapshots()
        .map((snap) => snap.docs
            .map((d) => MeasurementEntry.fromMap(d.id, d.data()))
            .toList());
  }

  // ─── Writes ──────────────────────────────────────────────────────────────

  /// Creates a new measurement entry (AS-056).
  ///
  /// [e.id] is ignored — Firestore auto-generates the document ID.
  Future<void> addEntry(MeasurementEntry e) {
    return _db.collection('measurements').add({
      ...e.toMap(),
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  /// Updates an existing measurement entry in place (AS-062).
  Future<void> updateEntry(MeasurementEntry e) {
    return _db.collection('measurements').doc(e.id).update(e.toMap());
  }

  /// Deletes the measurement entry with document ID [id] (AS-062).
  Future<void> deleteEntry(String id) {
    return _db.collection('measurements').doc(id).delete();
  }
}
