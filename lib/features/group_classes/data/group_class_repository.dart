import 'package:cloud_firestore/cloud_firestore.dart';

import '../../booking/domain/booking_exceptions.dart';
import '../../booking/domain/booking_policy.dart';
import '../../scheduling/domain/date_utils.dart';
import '../domain/group_class.dart';
import '../domain/group_class_exceptions.dart';

/// Firestore-backed repository for group class creation and participation.
///
/// Collections:
/// - `groupClasses/{classId}` — class metadata (title, date, start, end,
///   capacity, joinedCount).
/// - `groupClasses/{classId}/participants/{clientUid}` — sub-collection;
///   a document's existence signals that the client has joined.
///
/// Capacity and duplicate-join enforcement are done atomically inside
/// Firestore transactions to prevent race conditions when many clients try
/// to join a class simultaneously.
class GroupClassRepository {
  GroupClassRepository(this._db);

  final FirebaseFirestore _db;

  // ─── Streams ──────────────────────────────────────────────────────────────

  /// Watches all upcoming group classes (date >= today), ordered by date
  /// then start time.
  ///
  /// Requires a composite index on (`date` ASC, `start` ASC) — added in
  /// `firestore.indexes.json`.
  Stream<List<GroupClass>> watchUpcomingClasses() {
    return _db
        .collection('groupClasses')
        .where('date', isGreaterThanOrEqualTo: ymd(DateTime.now()))
        .orderBy('date')
        .orderBy('start')
        .snapshots()
        .map((snap) =>
            snap.docs.map((d) => GroupClass.fromMap(d.id, d.data())).toList());
  }

  /// Watches all group classes created by [trainerUid], ordered by date then
  /// start time.
  ///
  /// Requires a composite index on (`trainerUid` ASC, `date` ASC, `start` ASC)
  /// — added in `firestore.indexes.json`.
  Stream<List<GroupClass>> watchTrainerClasses(String trainerUid) {
    return _db
        .collection('groupClasses')
        .where('trainerUid', isEqualTo: trainerUid)
        .orderBy('date')
        .orderBy('start')
        .snapshots()
        .map((snap) =>
            snap.docs.map((d) => GroupClass.fromMap(d.id, d.data())).toList());
  }

  /// Watches whether [clientUid] has joined the class [classId].
  ///
  /// Returns a stream of `true` (document exists → joined) or `false`.
  Stream<bool> watchIsJoined(String classId, String clientUid) {
    return _db
        .collection('groupClasses')
        .doc(classId)
        .collection('participants')
        .doc(clientUid)
        .snapshots()
        .map((d) => d.exists);
  }

  // ─── Mutations ────────────────────────────────────────────────────────────

  /// Creates a new group class in Firestore (AS-041).
  ///
  /// - Firestore auto-generates the document ID.
  /// - [gc.joinedCount] is ignored; new classes always start at 0.
  /// - [gc.id] is ignored; Firestore assigns the ID after creation.
  /// - A `createdAt` server timestamp is stored alongside the map fields.
  Future<void> createClass(GroupClass gc) {
    return _db.collection('groupClasses').add({
      ...gc.toMap(),
      'joinedCount': 0, // always reset — ignore any count passed in gc
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  /// Atomically joins a client to a group class (AS-042, AS-043, AS-044,
  /// AS-046).
  ///
  /// Throws:
  /// - [ClassFullException] if the class is at capacity (AS-043).
  /// - [AlreadyJoinedException] if [clientUid] has already joined (AS-046).
  Future<void> joinClass({
    required String classId,
    required String clientUid,
  }) async {
    final classRef = _db.collection('groupClasses').doc(classId);
    final participantRef = classRef.collection('participants').doc(clientUid);

    await _db.runTransaction((tx) async {
      // ── All reads first (Firestore transaction requirement) ──────────────
      final classSnap = await tx.get(classRef);
      final pSnap = await tx.get(participantRef);

      // ── Capacity check (AS-043) ──────────────────────────────────────────
      final capacity = classSnap.data()!['capacity'] as int;
      final joined = (classSnap.data()!['joinedCount'] as int?) ?? 0;
      if (joined >= capacity) {
        throw const ClassFullException();
      }

      // ── Duplicate-join check (AS-046) ────────────────────────────────────
      if (pSnap.exists) {
        throw const AlreadyJoinedException();
      }

      // ── Writes ──────────────────────────────────────────────────────────
      tx.set(participantRef, {'joinedAt': FieldValue.serverTimestamp()});
      tx.update(classRef, {'joinedCount': FieldValue.increment(1)});
    });
  }

  /// Atomically removes a client from a group class (AS-044, AS-045).
  ///
  /// Idempotent: if the participant document does not exist, the call is a
  /// no-op (defensive — the UI should already guard against this).
  ///
  /// Throws [CutoffPassedException] (from
  /// `booking/domain/booking_exceptions.dart`) if the class has already
  /// started (`kCancellationCutoffHours = 0`, so the cutoff moment equals the
  /// class start time; AS-045).
  Future<void> leaveClass({
    required String classId,
    required String clientUid,
    required DateTime classStart,
  }) async {
    // ── Cutoff guard (AS-045) ────────────────────────────────────────────────
    if (isPastCutoff(classStart, DateTime.now())) {
      throw const CutoffPassedException();
    }

    final classRef = _db.collection('groupClasses').doc(classId);
    final participantRef = classRef.collection('participants').doc(clientUid);

    await _db.runTransaction((tx) async {
      // ── All reads first ──────────────────────────────────────────────────
      final pSnap = await tx.get(participantRef);

      // Defensive no-op: if the client is not a participant, do nothing.
      if (!pSnap.exists) return;

      // ── Writes ──────────────────────────────────────────────────────────
      tx.delete(participantRef);
      tx.update(classRef, {'joinedCount': FieldValue.increment(-1)});
    });
  }
}
