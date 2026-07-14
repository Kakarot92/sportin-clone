# Handoff: F103 — M11 Chat UI (conversation list, 1-on-1 thread, group class thread)

## Status
COMPLETE

## Assertions covered
AS-066: PASS — Client sends 1-on-1 message via OneOnOneChatScreen; send button disabled on empty/whitespace, enabled on text, calls chatControllerProvider.send; tested in chat_ui_test.dart
AS-067: PASS — Trainer threads shown in "My Chats" section; trainer reply tested via controller.send; ChatScreen section visible only to trainers; tested in chat_ui_test.dart
AS-069: PASS — Messages displayed via reverse: true + reversed list (newest at bottom); empty-thread placeholder shown; all message text visible via bubble widgets; tested in both chat_test.dart (existing) and chat_ui_test.dart (new)
AS-070: PASS — Thread ID uniqueness/determinism enforced (existing chat_test.dart); AppBar back button present on all pushed screens (regression guard test added)
AS-071: PASS — Non-joined group classes render SizedBox.shrink() in _JoinedGroupClassTile; joined classes render _GroupClassChatCard; trainer always sees their own classes via trainerGroupClassesProvider; tested in chat_ui_test.dart

## Files changed
lib/features/chat/presentation/chat_screen.dart
lib/features/chat/presentation/one_on_one_chat_screen.dart
lib/features/chat/presentation/group_chat_screen.dart
lib/features/chat/presentation/chat_thread_widgets.dart
lib/app/router.dart
test/chat_ui_test.dart

## Commands run
`dart analyze lib test` (0)
`flutter test` (0) — 171 tests pass, 0 failures

## Decisions made
- Shared `ChatMessageBubble` and `ChatInputBar` widgets extracted to `chat_thread_widgets.dart` (public names since Dart has no file-private scope) rather than duplicating ~80 lines across both thread screens.
- `reverse: true` + `messages.reversed.toList()` used for chat list (standard chat UI pattern, newest at bottom with index 0 at bottom).
- Trainer's display name via `trainerProvider(trainerUid)` for thread screen title — simplest and consistent regardless of who is viewing (spec recommends this).
- `_JoinedGroupClassTile` uses `revealIndex: 5 + i` (not 20 + i) so timers fire within the section-header animation window (248–708ms). Using index 20 caused tests to fail with "Timer still pending" because the 1080ms timer outlasted `pumpAndSettle`'s cascade window when the trainers list was empty.
- Trainer-only "My Chats" section conditional on `me.isTrainer`; clients only see trainer list + group classes.
- `DateFormat.yMMMEd('sr_Latn')` used throughout (never bare `'sr'` per existing codebase convention).
- Group class icon: bordered container with `Icons.groups_outlined` (kVolt) rather than KineticInitials since there's no text initial for a class.

## Out-of-scope work needed
- AS-068 (image/video attachments in chat) is not implemented — the input bar is text-only. Requires a separate file upload feature.
- AS-072 (push notifications for new chat messages) is not implemented — requires FCM background handler integration.
- Trainer thread list shows `clientUid.substring(0, 1)` as initials (no client display name available without a generic `userProvider`). A follow-up worker could add a `userProvider` (StreamProvider.family reading `users/{uid}`) to show proper client names in trainer's "My Chats" cards.
- No unread badge / unread count on chat list entries — not specified in the assigned assertions.

## Blockers
(none)

## Autonomous decisions
AUTONOMOUS_DECISION: Chose to show the "Chat with trainer" section for trainers as well (the spec says "simplest is to just always show it"). Trainers can see and tap their own entry which opens a thread with themselves — harmless edge case.
AUTONOMOUS_DECISION: Empty group class section shows `l10n.noChatsYet` when `upcomingGroupClassesProvider` returns an empty list. Per spec: "skip the whole section if the list is empty — your call." The section header always renders; only the items list is omitted/replaced with the empty-state text.

## Notes for the next worker
- The Reveal widget cascade in tests: `pumpAndSettle` keeps cascading as long as consecutive Reveal timer gaps are ≤100ms. Using `revealIndex: 20 + i` breaks the cascade when intermediate sections are empty. Stick to small starting indices (≤12) for list items in sections after the main headers.
- ChatScreen is a tab landing screen (NO AppBar) — this matches HomeScreen, TrainerDirectoryScreen, ProfileScreen. All PUSHED screens (thread/group) MUST have `appBar: AppBar()`.
- The `_JoinedGroupClassTile` pattern (ConsumerWidget that watches `isJoinedProvider` and returns `SizedBox.shrink()` if not joined) is the canonical AS-071 enforcement at the UI layer. Firestore rules enforce it at the data layer.
- No MCP tools were used (pure UI feature, no live Firestore schema inspection needed).
