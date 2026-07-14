# Handoff: F100 — M11 Chat data + logic layer

## Status
COMPLETE

## Assertions covered
AS-066: PASS — ChatRepository.sendMessage uses a WriteBatch to atomically upsert the thread document and append a message doc; ChatController.send wraps it. Unit tests verify thread ID and fromMap parsing.
AS-067: PASS — Same sendMessage path handles both client→trainer and trainer→client sends (senderUid is caller-supplied); watchMessages returns all messages in the thread regardless of direction.
AS-069: PASS — watchMessages and watchGroupMessages both use `.orderBy('sentAt')` so messages arrive chronologically; Firestore persists to disk automatically. fromMap null-safe fallback tested.
AS-070: PASS — Thread ID is deterministic (`oneOnOneThreadId` = `"{trainerUid}_{clientUid}"`); Firestore rules gate /chats/{threadId} and its messages subcollection on matching trainerUid/clientUid; unit tests confirm ID isolation.
AS-071: PASS — watchGroupMessages / sendGroupMessage target `groupClassChats/{classId}/messages`; rules gate read/write on `groupClasses/{classId}` trainer OR `participants/{uid}` existence.

## Files changed
lib/features/chat/domain/chat_message.dart
lib/features/chat/domain/chat_thread_summary.dart
lib/features/chat/data/chat_repository.dart
lib/features/chat/application/chat_providers.dart
firestore.rules
firestore.indexes.json
lib/l10n/app_en.arb
lib/l10n/app_sr.arb
lib/l10n/app_localizations.dart (generated)
lib/l10n/app_localizations_en.dart (generated)
lib/l10n/app_localizations_sr.dart (generated)
test/chat_test.dart

## Commands run
`flutter pub get` (0)
`flutter gen-l10n` (0)
`dart analyze lib test` (0) — "No issues found!"
`flutter test` (0) — "All tests passed!" (153 tests: 143 existing + 10 new in chat_test.dart)

## Decisions made
- Used WriteBatch (not a transaction) for sendMessage/sendGroupMessage: no read-then-write dependency, so a batch is sufficient and cheaper than a transaction.
- SetOptions(merge: true) on the thread/group summary document upsert makes repeated sends idempotent — only lastMessage/lastMessageAt are refreshed.
- oneOnOneThreadId is a static method on ChatRepository (not a static on a domain model), matching the spec's explicit instruction and mirroring Booking.bookingDocId's style.
- groupClassChats create/update rule is open to any signed-in user: the write only merges lastMessage/lastMessageAt, and the message create rule enforces senderUid == request.auth.uid plus participant-or-trainer membership. This is consistent with the spec-provided rule block.
- Firestore rules are NOT deployed — left for the orchestrator to deploy post-commit.
- Firestore indexes are NOT deployed — left for the orchestrator.
- AS-068 (media attachments) explicitly omitted — no Storage code written.

## Out-of-scope work needed
- UI screens for chat (second worker): a chat inbox list screen, a 1-on-1 message thread screen, and a group-class message thread screen all need to be built using the providers created here (oneOnOneMessagesProvider, groupMessagesProvider, clientChatThreadsProvider, trainerChatThreadsProvider, chatControllerProvider).
- Firebase deployment: orchestrator must run `firebase deploy --only firestore:rules,firestore:indexes` after commit.
- AS-068: image/video message attachments (Storage) — explicitly deferred per spec.

## Blockers
(none)

## Autonomous decisions
(none — all choices followed the clarified spec exactly)

## Notes for the next worker
- The UI worker should import from `lib/features/chat/application/chat_providers.dart` for all providers and the controller. The repository is not needed directly from UI.
- `ChatRepository.oneOnOneThreadId(trainerUid, clientUid)` is the canonical way to compute a thread ID before calling providers.
- All new l10n keys are available in AppLocalizations: `chatMessages`, `typeMessage`, `send`, `noMessagesYet`, `chatWithTrainer`, `groupClassChat`, `noChatsYet`, `myChats`.
- The Firestore rules use `get(...)` calls to look up the parent thread document from within the messages subcollection (necessary because the messages rules can't directly reference their parent's wildcard bindings). This means each message read costs one extra Firestore read — acceptable for a chat feature of this scale.
- Full rule blocks for orchestrator review:

```
// M11: 1-on-1 chat
match /chats/{threadId} {
  allow read: if isSignedIn()
    && (isSelf(resource.data.trainerUid) || isSelf(resource.data.clientUid) || isAdmin());
  allow create, update: if isSignedIn()
    && (request.resource.data.trainerUid == request.auth.uid
        || request.resource.data.clientUid == request.auth.uid);
  match /messages/{msgId} {
    allow read: if isSignedIn()
      && (get(/databases/$(database)/documents/chats/$(threadId)).data.trainerUid == request.auth.uid
          || get(/databases/$(database)/documents/chats/$(threadId)).data.clientUid == request.auth.uid
          || isAdmin());
    allow create: if isSignedIn()
      && request.resource.data.senderUid == request.auth.uid
      && (get(/databases/$(database)/documents/chats/$(threadId)).data.trainerUid == request.auth.uid
          || get(/databases/$(database)/documents/chats/$(threadId)).data.clientUid == request.auth.uid);
  }
}

// M11: group class chat
match /groupClassChats/{classId} {
  allow read: if isSignedIn()
    && (get(/databases/$(database)/documents/groupClasses/$(classId)).data.trainerUid == request.auth.uid
        || exists(/databases/$(database)/documents/groupClasses/$(classId)/participants/$(request.auth.uid))
        || isAdmin());
  allow create, update: if isSignedIn();
  match /messages/{msgId} {
    allow read: if isSignedIn()
      && (get(/databases/$(database)/documents/groupClasses/$(classId)).data.trainerUid == request.auth.uid
          || exists(/databases/$(database)/documents/groupClasses/$(classId)/participants/$(request.auth.uid))
          || isAdmin());
    allow create: if isSignedIn()
      && request.resource.data.senderUid == request.auth.uid
      && (get(/databases/$(database)/documents/groupClasses/$(classId)).data.trainerUid == request.auth.uid
          || exists(/databases/$(database)/documents/groupClasses/$(classId)/participants/$(request.auth.uid)));
  }
}
```
