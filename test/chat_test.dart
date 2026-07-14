import 'package:flutter_test/flutter_test.dart';
import 'package:sportin_clone/features/chat/data/chat_repository.dart';
import 'package:sportin_clone/features/chat/domain/chat_message.dart';
import 'package:sportin_clone/features/chat/domain/chat_thread_summary.dart';

void main() {
  // ── AS-066 / AS-067: deterministic thread ID ─────────────────────────────
  //
  // The thread ID is the foundation of the participant-check security model:
  // a correct, stable ID is required for the Firestore security rules to
  // enforce AS-070 (only participants may read). We test the static helper
  // that clients and trainers use to address each other's thread.

  group('ChatRepository.oneOnOneThreadId (AS-066, AS-067, AS-070)', () {
    test(
      'AS-066 AS-067: oneOnOneThreadId produces "{trainerUid}_{clientUid}" '
      'matching the established codebase convention',
      () {
        expect(
          ChatRepository.oneOnOneThreadId('trainer-1', 'client-1'),
          equals('trainer-1_client-1'),
        );
      },
    );

    test(
      'AS-070: oneOnOneThreadId is deterministic — the same arguments always '
      'produce the same ID, so both participants address the same document',
      () {
        const trainerUid = 'trainerAbc';
        const clientUid = 'clientXyz';
        final id1 = ChatRepository.oneOnOneThreadId(trainerUid, clientUid);
        final id2 = ChatRepository.oneOnOneThreadId(trainerUid, clientUid);
        expect(id1, equals(id2));
      },
    );

    test(
      'AS-070: different trainer-client pairs produce different thread IDs '
      '(no cross-participant collision)',
      () {
        final idA = ChatRepository.oneOnOneThreadId('trainer-1', 'client-1');
        final idB = ChatRepository.oneOnOneThreadId('trainer-1', 'client-2');
        final idC = ChatRepository.oneOnOneThreadId('trainer-2', 'client-1');
        expect(idA, isNot(equals(idB)));
        expect(idA, isNot(equals(idC)));
        expect(idB, isNot(equals(idC)));
      },
    );
  });

  // ── AS-069: ChatMessage.fromMap — parsing and null-safety ────────────────

  group('ChatMessage.fromMap (AS-069)', () {
    test(
      'AS-069: fromMap correctly deserialises all fields when sentAt is null '
      '(optimistic write before server timestamp resolves — fallback to now)',
      () {
        // Simulate what happens immediately after a write: the server timestamp
        // has not yet resolved so Firestore returns null for sentAt.
        // We cannot import cloud_firestore Timestamp in a pure unit test
        // without Firebase initialisation, so we test the null-fallback branch.
        final map = {
          'senderUid': 'user-abc',
          'text': 'Hello world',
          'sentAt': null, // null triggers the fallback to DateTime.now()
        };
        // fromMap must not throw even when sentAt is null.
        final msg = ChatMessage.fromMap('msg-1', map);
        expect(msg.id, equals('msg-1'));
        expect(msg.senderUid, equals('user-abc'));
        expect(msg.text, equals('Hello world'));
        // sentAt falls back to DateTime.now(); just assert it is non-null and
        // within a reasonable range (within 5 seconds of now).
        expect(
          msg.sentAt.difference(DateTime.now()).abs().inSeconds,
          lessThanOrEqualTo(5),
        );
      },
    );

    test(
      'AS-069: fromMap does not throw when sentAt is null '
      '(optimistic local write before server timestamp resolves)',
      () {
        final map = {
          'senderUid': 'user-xyz',
          'text': 'First message',
          'sentAt': null,
        };
        expect(() => ChatMessage.fromMap('msg-null-ts', map), returnsNormally);
      },
    );

    test(
      'AS-069: fromMap uses safe defaults for missing optional fields',
      () {
        final msg = ChatMessage.fromMap('msg-empty', {});
        expect(msg.senderUid, equals(''));
        expect(msg.text, equals(''));
      },
    );
  });

  // ── AS-066 / AS-067: ChatThreadSummary.fromMap ───────────────────────────

  group('ChatThreadSummary.fromMap (AS-066, AS-067)', () {
    test(
      'AS-066 AS-067: fromMap correctly deserialises all fields',
      () {
        final map = {
          'trainerUid': 'trainer-djole',
          'clientUid': 'client-ana',
          'lastMessage': 'See you tomorrow!',
          'lastMessageAt': null, // null is handled gracefully
        };
        final summary = ChatThreadSummary.fromMap('trainer-djole_client-ana', map);
        expect(summary.threadId, equals('trainer-djole_client-ana'));
        expect(summary.trainerUid, equals('trainer-djole'));
        expect(summary.clientUid, equals('client-ana'));
        expect(summary.lastMessage, equals('See you tomorrow!'));
        // lastMessageAt is null when the timestamp has not yet resolved.
        expect(summary.lastMessageAt, isNull);
      },
    );

    test(
      'AS-069: fromMap does not throw when lastMessageAt is null '
      '(thread document written before server timestamp resolves)',
      () {
        final map = {
          'trainerUid': 'trainer-1',
          'clientUid': 'client-1',
          'lastMessage': 'Hi',
          'lastMessageAt': null,
        };
        expect(
          () => ChatThreadSummary.fromMap('trainer-1_client-1', map),
          returnsNormally,
        );
      },
    );

    test(
      'AS-066 AS-067: fromMap uses safe defaults for missing fields',
      () {
        final summary = ChatThreadSummary.fromMap('some-thread', {});
        expect(summary.threadId, equals('some-thread'));
        expect(summary.trainerUid, equals(''));
        expect(summary.clientUid, equals(''));
        expect(summary.lastMessage, equals(''));
        expect(summary.lastMessageAt, isNull);
      },
    );
  });

  // ── AS-070: thread ID isolation (no cross-read) ───────────────────────────
  //
  // Structural test: verify the thread ID convention ensures that a user
  // cannot accidentally address another pair's thread. Security rules enforce
  // this at the Firebase level, but the deterministic ID is the mechanism.

  group('Thread ID isolation (AS-070)', () {
    test(
      'AS-070: swapping trainer and client UIDs produces a different thread ID, '
      'ensuring trainer-as-client ambiguity cannot produce a cross-read',
      () {
        final idNormal = ChatRepository.oneOnOneThreadId('trainer-A', 'client-B');
        final idSwapped = ChatRepository.oneOnOneThreadId('client-B', 'trainer-A');
        // The two IDs must differ so the convention is unambiguous.
        expect(idNormal, isNot(equals(idSwapped)));
      },
    );
  });
}
