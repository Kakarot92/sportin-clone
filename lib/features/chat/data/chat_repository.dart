import 'package:cloud_firestore/cloud_firestore.dart';

import '../domain/chat_message.dart';
import '../domain/chat_thread_summary.dart';

/// Firestore-backed repository for 1-on-1 and group-class chat messaging.
///
/// Collections:
/// - `chats/{threadId}` — 1-on-1 thread metadata (trainerUid, clientUid,
///   lastMessage, lastMessageAt). Thread ID is deterministic: see
///   [oneOnOneThreadId].
/// - `chats/{threadId}/messages/{msgId}` — individual messages for a
///   1-on-1 thread.
/// - `groupClassChats/{classId}` — group-class thread metadata.
/// - `groupClassChats/{classId}/messages/{msgId}` — individual messages for
///   a group-class thread.
///
/// Message ordering is by `sentAt` (AS-069 — chronological, persists across
/// restarts). Thread lists are ordered by `lastMessageAt` descending (most
/// recent conversation first).
class ChatRepository {
  ChatRepository(this._db);

  final FirebaseFirestore _db;

  // ─── Static helpers ──────────────────────────────────────────────────────────

  /// Deterministic thread ID for a 1-on-1 chat between a trainer and client.
  ///
  /// Mirrors [Booking.bookingDocId]'s convention of joining participant UIDs
  /// with an underscore, keeping trainer first so the format is consistent
  /// with the `trainerClients/{trainerUid}_{clientUid}` marker used elsewhere
  /// in this codebase.
  ///
  /// Example: `oneOnOneThreadId('trainer-djole', 'client-ana')`
  /// returns `'trainer-djole_client-ana'`.
  static String oneOnOneThreadId(String trainerUid, String clientUid) =>
      '${trainerUid}_$clientUid';

  // ─── 1-on-1 streams ─────────────────────────────────────────────────────────

  /// Watches all messages in a 1-on-1 thread, ordered chronologically
  /// (AS-069).
  ///
  /// Family parameter: [threadId] (use [oneOnOneThreadId] to compute it).
  Stream<List<ChatMessage>> watchMessages(String threadId) {
    return _db
        .collection('chats')
        .doc(threadId)
        .collection('messages')
        .orderBy('sentAt')
        .snapshots()
        .map((snap) =>
            snap.docs.map((d) => ChatMessage.fromMap(d.id, d.data())).toList());
  }

  /// Watches all 1-on-1 threads where [clientUid] is the client, ordered by
  /// most recent message first.
  ///
  /// Requires a composite index on (`clientUid` ASC, `lastMessageAt` DESC) —
  /// added in `firestore.indexes.json`.
  Stream<List<ChatThreadSummary>> watchClientThreads(String clientUid) {
    return _db
        .collection('chats')
        .where('clientUid', isEqualTo: clientUid)
        .orderBy('lastMessageAt', descending: true)
        .snapshots()
        .map((snap) => snap.docs
            .map((d) => ChatThreadSummary.fromMap(d.id, d.data()))
            .toList());
  }

  /// Watches all 1-on-1 threads where [trainerUid] is the trainer, ordered
  /// by most recent message first.
  ///
  /// Requires a composite index on (`trainerUid` ASC, `lastMessageAt` DESC) —
  /// added in `firestore.indexes.json`.
  Stream<List<ChatThreadSummary>> watchTrainerThreads(String trainerUid) {
    return _db
        .collection('chats')
        .where('trainerUid', isEqualTo: trainerUid)
        .orderBy('lastMessageAt', descending: true)
        .snapshots()
        .map((snap) => snap.docs
            .map((d) => ChatThreadSummary.fromMap(d.id, d.data()))
            .toList());
  }

  // ─── 1-on-1 mutations ───────────────────────────────────────────────────────

  /// Sends a text message from [senderUid] in the 1-on-1 thread between
  /// [trainerUid] and [clientUid] (AS-066, AS-067).
  ///
  /// Uses a [WriteBatch] (not a transaction) because there is no
  /// read-then-write dependency — we simply upsert the thread summary and
  /// append a new message document atomically.
  ///
  /// The thread document is upserted with [SetOptions.merge] so repeated
  /// sends only refresh the `lastMessage`/`lastMessageAt` fields without
  /// overwriting the participant UIDs.
  Future<void> sendMessage({
    required String trainerUid,
    required String clientUid,
    required String senderUid,
    required String text,
  }) async {
    final threadId = oneOnOneThreadId(trainerUid, clientUid);
    final threadRef = _db.collection('chats').doc(threadId);
    final msgRef = threadRef.collection('messages').doc();
    final batch = _db.batch();

    // Upsert thread summary document.
    batch.set(
      threadRef,
      {
        'trainerUid': trainerUid,
        'clientUid': clientUid,
        'lastMessage': text,
        'lastMessageAt': FieldValue.serverTimestamp(),
      },
      SetOptions(merge: true),
    );

    // Append new message.
    batch.set(msgRef, {
      'senderUid': senderUid,
      'text': text,
      'sentAt': FieldValue.serverTimestamp(),
    });

    await batch.commit();
  }

  // ─── Group-class streams ─────────────────────────────────────────────────────

  /// Watches all messages in a group-class thread, ordered chronologically
  /// (AS-069, AS-071).
  ///
  /// Family parameter: [classId] — the Firestore document ID of the group
  /// class (i.e. the same ID used in `groupClasses/{classId}`).
  Stream<List<ChatMessage>> watchGroupMessages(String classId) {
    return _db
        .collection('groupClassChats')
        .doc(classId)
        .collection('messages')
        .orderBy('sentAt')
        .snapshots()
        .map((snap) =>
            snap.docs.map((d) => ChatMessage.fromMap(d.id, d.data())).toList());
  }

  // ─── Group-class mutations ───────────────────────────────────────────────────

  /// Sends a text message from [senderUid] in the group-class thread for
  /// [classId] (AS-071).
  ///
  /// Uses the same [WriteBatch] pattern as [sendMessage]: upsert the group
  /// thread summary document and append a new message document atomically.
  Future<void> sendGroupMessage({
    required String classId,
    required String senderUid,
    required String text,
  }) async {
    final threadRef = _db.collection('groupClassChats').doc(classId);
    final msgRef = threadRef.collection('messages').doc();
    final batch = _db.batch();

    // Upsert group thread summary document.
    batch.set(
      threadRef,
      {
        'lastMessage': text,
        'lastMessageAt': FieldValue.serverTimestamp(),
      },
      SetOptions(merge: true),
    );

    // Append new message.
    batch.set(msgRef, {
      'senderUid': senderUid,
      'text': text,
      'sentAt': FieldValue.serverTimestamp(),
    });

    await batch.commit();
  }
}
