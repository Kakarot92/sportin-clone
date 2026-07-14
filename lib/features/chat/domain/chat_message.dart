import 'package:cloud_firestore/cloud_firestore.dart';

/// A single text message in a 1-on-1 or group-class chat thread.
///
/// Stored at `chats/{threadId}/messages/{msgId}` (1-on-1) or
/// `groupClassChats/{classId}/messages/{msgId}` (group).
///
/// [sentAt] is populated from a Firestore server timestamp. Immediately after
/// an optimistic local write the server timestamp is null — fall back to
/// [DateTime.now()] so the UI does not receive a null date.
class ChatMessage {
  const ChatMessage({
    required this.id,
    required this.senderUid,
    required this.text,
    required this.sentAt,
  });

  final String id;
  final String senderUid;
  final String text;
  final DateTime sentAt;

  factory ChatMessage.fromMap(String id, Map<String, dynamic> map) {
    final ts = map['sentAt'];
    return ChatMessage(
      id: id,
      senderUid: (map['senderUid'] as String?) ?? '',
      text: (map['text'] as String?) ?? '',
      // sentAt may be null momentarily right after an optimistic local write
      // before the server timestamp resolves — fall back to DateTime.now().
      sentAt: ts is Timestamp ? ts.toDate() : DateTime.now(),
    );
  }
}
