import 'package:cloud_firestore/cloud_firestore.dart';

/// A summary of a 1-on-1 chat thread between a trainer and a client.
///
/// Stored at `chats/{threadId}` in Firestore. The thread document is upserted
/// each time a message is sent, so it always reflects the most recent message.
///
/// [lastMessageAt] mirrors the same null-safety pattern as [ChatMessage.sentAt]:
/// a freshly-created thread document whose server timestamp has not yet
/// resolved will have a null timestamp — callers should handle null gracefully.
class ChatThreadSummary {
  const ChatThreadSummary({
    required this.threadId,
    required this.trainerUid,
    required this.clientUid,
    required this.lastMessage,
    this.lastMessageAt,
  });

  final String threadId;
  final String trainerUid;
  final String clientUid;
  final String lastMessage;
  final DateTime? lastMessageAt;

  factory ChatThreadSummary.fromMap(String id, Map<String, dynamic> map) {
    final ts = map['lastMessageAt'];
    return ChatThreadSummary(
      threadId: id,
      trainerUid: (map['trainerUid'] as String?) ?? '',
      clientUid: (map['clientUid'] as String?) ?? '',
      lastMessage: (map['lastMessage'] as String?) ?? '',
      // lastMessageAt may be null momentarily right after an optimistic local
      // write before the server timestamp resolves.
      lastMessageAt: ts is Timestamp ? ts.toDate() : null,
    );
  }
}
