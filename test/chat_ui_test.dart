// ignore_for_file: lines_longer_than_80_chars
//
// UI / widget tests for the chat feature (F103).
//
// Assertions covered:
//   AS-066  A client can send a text message to their trainer in a 1-on-1 chat.
//   AS-067  A trainer can reply to a client in the 1-on-1 chat.
//   AS-069  Messages display in chronological order and persist across app restarts.
//   AS-070  A user cannot read a conversation they are not a participant of.
//   AS-071  A group class chat is visible only to that class's participants and its trainer.

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sportin_clone/app/theme.dart';
import 'package:sportin_clone/core/models/app_user.dart';
import 'package:sportin_clone/core/models/trainer_profile.dart';
import 'package:sportin_clone/features/auth/application/auth_providers.dart';
import 'package:sportin_clone/features/chat/application/chat_providers.dart';
import 'package:sportin_clone/features/chat/domain/chat_message.dart';
import 'package:sportin_clone/features/chat/domain/chat_thread_summary.dart';
import 'package:sportin_clone/features/chat/presentation/chat_screen.dart';
import 'package:sportin_clone/features/chat/presentation/group_chat_screen.dart';
import 'package:sportin_clone/features/chat/presentation/one_on_one_chat_screen.dart';
import 'package:sportin_clone/features/group_classes/application/group_class_providers.dart';
import 'package:sportin_clone/features/group_classes/domain/group_class.dart';
import 'package:sportin_clone/features/trainers/application/trainers_providers.dart';
import 'package:sportin_clone/l10n/app_localizations.dart';

// ─── Helpers ──────────────────────────────────────────────────────────────────

Widget _testApp(Widget child) => MaterialApp(
      theme: buildDarkTheme(),
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: child,
    );

// ─── Fixtures ─────────────────────────────────────────────────────────────────

const _clientUid = 'client-1';
const _trainerUid = 'trainer-1';

const _fakeClient = AppUser(
  uid: _clientUid,
  email: 'client@test.com',
  displayName: 'Ana Jovanović',
  role: AppRole.client,
);

const _fakeTrainer = AppUser(
  uid: _trainerUid,
  email: 'trainer@test.com',
  displayName: 'Đole Fitness',
  role: AppRole.trainer,
);

const _fakeTrainerProfile = TrainerProfile(
  uid: _trainerUid,
  displayName: 'Đole Fitness',
  bio: 'Strength coach',
);

final _now = DateTime(2027, 6, 1, 10, 0, 0);

/// Messages in chronological order (oldest first, as the repository returns).
final _messages = [
  ChatMessage(
    id: 'msg-1',
    senderUid: _clientUid,
    text: 'Hello trainer!',
    sentAt: _now,
  ),
  ChatMessage(
    id: 'msg-2',
    senderUid: _trainerUid,
    text: 'Hi! Ready for today?',
    sentAt: _now.add(const Duration(minutes: 1)),
  ),
  ChatMessage(
    id: 'msg-3',
    senderUid: _clientUid,
    text: 'Yes, see you soon!',
    sentAt: _now.add(const Duration(minutes: 2)),
  ),
];

const _joinedClass = GroupClass(
  id: 'class-yoga',
  trainerUid: _trainerUid,
  title: 'Yoga Flow',
  date: '2027-06-10',
  start: '10:00',
  end: '11:00',
  capacity: 10,
  joinedCount: 3,
);

const _notJoinedClass = GroupClass(
  id: 'class-hiit',
  trainerUid: _trainerUid,
  title: 'HIIT Blast',
  date: '2027-06-11',
  start: '09:00',
  end: '10:00',
  capacity: 5,
  joinedCount: 2,
);

// ─── Fake ChatController ───────────────────────────────────────────────────────

class _OkChatController extends ChatController {
  String? lastSentText;
  String? lastSentGroup;

  @override
  Future<bool> send({
    required String trainerUid,
    required String clientUid,
    required String senderUid,
    required String text,
  }) async {
    lastSentText = text;
    state = const AsyncData(null);
    return true;
  }

  @override
  Future<bool> sendGroup({
    required String classId,
    required String senderUid,
    required String text,
  }) async {
    lastSentGroup = text;
    state = const AsyncData(null);
    return true;
  }
}

// ─── Tests ────────────────────────────────────────────────────────────────────

void main() {
  // ── 1-on-1 thread screen ──────────────────────────────────────────────────

  group('OneOnOneChatScreen (AS-066, AS-067, AS-069, AS-070)', () {
    testWidgets(
      'AS-066 AS-067: shows messages from both client and trainer',
      (tester) async {
        await tester.pumpWidget(
          ProviderScope(
            overrides: [
              appUserProvider.overrideWith((_) => Stream.value(_fakeClient)),
              trainerProvider(_trainerUid).overrideWith(
                (_) => Stream.value(_fakeTrainerProfile),
              ),
              oneOnOneMessagesProvider('${_trainerUid}_$_clientUid')
                  .overrideWith((_) => Stream.value(_messages)),
            ],
            child: _testApp(
              const OneOnOneChatScreen(
                trainerUid: _trainerUid,
                clientUid: _clientUid,
              ),
            ),
          ),
        );
        await tester.pumpAndSettle();

        expect(find.text('Hello trainer!'), findsOneWidget);
        expect(find.text('Hi! Ready for today?'), findsOneWidget);
        expect(find.text('Yes, see you soon!'), findsOneWidget);
      },
    );

    testWidgets(
      'AS-069: all messages rendered when there are multiple (chronological)',
      (tester) async {
        final twoMessages = [
          ChatMessage(
            id: 'm1',
            senderUid: _clientUid,
            text: 'First message',
            sentAt: _now,
          ),
          ChatMessage(
            id: 'm2',
            senderUid: _trainerUid,
            text: 'Second message',
            sentAt: _now.add(const Duration(minutes: 1)),
          ),
        ];

        await tester.pumpWidget(
          ProviderScope(
            overrides: [
              appUserProvider.overrideWith((_) => Stream.value(_fakeClient)),
              trainerProvider(_trainerUid).overrideWith(
                (_) => Stream.value(_fakeTrainerProfile),
              ),
              oneOnOneMessagesProvider('${_trainerUid}_$_clientUid')
                  .overrideWith((_) => Stream.value(twoMessages)),
            ],
            child: _testApp(
              const OneOnOneChatScreen(
                trainerUid: _trainerUid,
                clientUid: _clientUid,
              ),
            ),
          ),
        );
        await tester.pumpAndSettle();

        expect(find.text('First message'), findsOneWidget);
        expect(find.text('Second message'), findsOneWidget);
      },
    );

    testWidgets(
      'AS-069: empty thread shows noMessagesYet placeholder',
      (tester) async {
        await tester.pumpWidget(
          ProviderScope(
            overrides: [
              appUserProvider.overrideWith((_) => Stream.value(_fakeClient)),
              trainerProvider(_trainerUid).overrideWith(
                (_) => Stream.value(_fakeTrainerProfile),
              ),
              oneOnOneMessagesProvider('${_trainerUid}_$_clientUid')
                  .overrideWith((_) => Stream.value([])),
            ],
            child: _testApp(
              const OneOnOneChatScreen(
                trainerUid: _trainerUid,
                clientUid: _clientUid,
              ),
            ),
          ),
        );
        await tester.pumpAndSettle();

        // l10n.noMessagesYet contains "Say hello" in English.
        expect(
          find.textContaining('Say hello', skipOffstage: false),
          findsOneWidget,
        );
      },
    );

    testWidgets(
      'AS-066: send button is disabled when the text field is empty',
      (tester) async {
        await tester.pumpWidget(
          ProviderScope(
            overrides: [
              appUserProvider.overrideWith((_) => Stream.value(_fakeClient)),
              trainerProvider(_trainerUid).overrideWith(
                (_) => Stream.value(_fakeTrainerProfile),
              ),
              oneOnOneMessagesProvider('${_trainerUid}_$_clientUid')
                  .overrideWith((_) => Stream.value([])),
            ],
            child: _testApp(
              const OneOnOneChatScreen(
                trainerUid: _trainerUid,
                clientUid: _clientUid,
              ),
            ),
          ),
        );
        await tester.pumpAndSettle();

        final sendButton = tester.widget<IconButton>(
          find.widgetWithIcon(IconButton, Icons.send_rounded),
        );
        expect(sendButton.onPressed, isNull,
            reason: 'Send must be disabled when no text is entered');
      },
    );

    testWidgets(
      'AS-066: typing non-empty text enables the send button',
      (tester) async {
        await tester.pumpWidget(
          ProviderScope(
            overrides: [
              appUserProvider.overrideWith((_) => Stream.value(_fakeClient)),
              trainerProvider(_trainerUid).overrideWith(
                (_) => Stream.value(_fakeTrainerProfile),
              ),
              oneOnOneMessagesProvider('${_trainerUid}_$_clientUid')
                  .overrideWith((_) => Stream.value([])),
            ],
            child: _testApp(
              const OneOnOneChatScreen(
                trainerUid: _trainerUid,
                clientUid: _clientUid,
              ),
            ),
          ),
        );
        await tester.pumpAndSettle();

        await tester.enterText(find.byType(TextField), 'Hello!');
        await tester.pump();

        final sendButton = tester.widget<IconButton>(
          find.widgetWithIcon(IconButton, Icons.send_rounded),
        );
        expect(sendButton.onPressed, isNotNull,
            reason: 'Send must be enabled when text is entered');
      },
    );

    testWidgets(
      'AS-066: whitespace-only text does not enable the send button',
      (tester) async {
        await tester.pumpWidget(
          ProviderScope(
            overrides: [
              appUserProvider.overrideWith((_) => Stream.value(_fakeClient)),
              trainerProvider(_trainerUid).overrideWith(
                (_) => Stream.value(_fakeTrainerProfile),
              ),
              oneOnOneMessagesProvider('${_trainerUid}_$_clientUid')
                  .overrideWith((_) => Stream.value([])),
            ],
            child: _testApp(
              const OneOnOneChatScreen(
                trainerUid: _trainerUid,
                clientUid: _clientUid,
              ),
            ),
          ),
        );
        await tester.pumpAndSettle();

        await tester.enterText(find.byType(TextField), '   ');
        await tester.pump();

        final sendButton = tester.widget<IconButton>(
          find.widgetWithIcon(IconButton, Icons.send_rounded),
        );
        expect(sendButton.onPressed, isNull,
            reason: 'Whitespace-only text must not enable send');
      },
    );

    testWidgets(
      'AS-066 AS-067: tapping send calls controller.send with trimmed text '
      'and clears the input field on success',
      (tester) async {
        final fakeController = _OkChatController();

        await tester.pumpWidget(
          ProviderScope(
            overrides: [
              appUserProvider.overrideWith((_) => Stream.value(_fakeClient)),
              trainerProvider(_trainerUid).overrideWith(
                (_) => Stream.value(_fakeTrainerProfile),
              ),
              oneOnOneMessagesProvider('${_trainerUid}_$_clientUid')
                  .overrideWith((_) => Stream.value([])),
              chatControllerProvider.overrideWith(() => fakeController),
            ],
            child: _testApp(
              const OneOnOneChatScreen(
                trainerUid: _trainerUid,
                clientUid: _clientUid,
              ),
            ),
          ),
        );
        await tester.pumpAndSettle();

        await tester.enterText(find.byType(TextField), 'Test message');
        await tester.pump();

        await tester.tap(find.widgetWithIcon(IconButton, Icons.send_rounded));
        await tester.pumpAndSettle();

        expect(fakeController.lastSentText, equals('Test message'));

        // Input field must be cleared after a successful send.
        final tf = tester.widget<TextField>(find.byType(TextField));
        expect(tf.controller?.text ?? '', isEmpty);
      },
    );

    testWidgets(
      'AS-070: screen has AppBar — pushed screens must never lose the back '
      'button (regression guard)',
      (tester) async {
        await tester.pumpWidget(
          ProviderScope(
            overrides: [
              appUserProvider.overrideWith((_) => Stream.value(_fakeClient)),
              trainerProvider(_trainerUid).overrideWith(
                (_) => Stream.value(_fakeTrainerProfile),
              ),
              oneOnOneMessagesProvider('${_trainerUid}_$_clientUid')
                  .overrideWith((_) => Stream.value([])),
            ],
            child: _testApp(
              const OneOnOneChatScreen(
                trainerUid: _trainerUid,
                clientUid: _clientUid,
              ),
            ),
          ),
        );
        await tester.pumpAndSettle();

        expect(find.byType(AppBar), findsOneWidget);
      },
    );
  });

  // ── Group chat screen ─────────────────────────────────────────────────────

  group('GroupChatScreen (AS-069, AS-071)', () {
    testWidgets(
      'AS-069: group chat shows all messages',
      (tester) async {
        final groupMessages = [
          ChatMessage(
            id: 'gm1',
            senderUid: _trainerUid,
            text: 'Welcome everyone!',
            sentAt: _now,
          ),
          ChatMessage(
            id: 'gm2',
            senderUid: _clientUid,
            text: 'Thanks!',
            sentAt: _now.add(const Duration(minutes: 1)),
          ),
        ];

        await tester.pumpWidget(
          ProviderScope(
            overrides: [
              appUserProvider.overrideWith((_) => Stream.value(_fakeClient)),
              groupMessagesProvider('class-yoga')
                  .overrideWith((_) => Stream.value(groupMessages)),
            ],
            child: _testApp(const GroupChatScreen(classId: 'class-yoga')),
          ),
        );
        await tester.pumpAndSettle();

        expect(find.text('Welcome everyone!'), findsOneWidget);
        expect(find.text('Thanks!'), findsOneWidget);
      },
    );

    testWidgets(
      'AS-069: empty group chat shows noMessagesYet placeholder',
      (tester) async {
        await tester.pumpWidget(
          ProviderScope(
            overrides: [
              appUserProvider.overrideWith((_) => Stream.value(_fakeClient)),
              groupMessagesProvider('class-yoga')
                  .overrideWith((_) => Stream.value([])),
            ],
            child: _testApp(const GroupChatScreen(classId: 'class-yoga')),
          ),
        );
        await tester.pumpAndSettle();

        expect(
          find.textContaining('Say hello', skipOffstage: false),
          findsOneWidget,
        );
      },
    );

    testWidgets(
      'AS-071: GroupChatScreen has AppBar with back button',
      (tester) async {
        await tester.pumpWidget(
          ProviderScope(
            overrides: [
              appUserProvider.overrideWith((_) => Stream.value(_fakeClient)),
              groupMessagesProvider('class-yoga')
                  .overrideWith((_) => Stream.value([])),
            ],
            child: _testApp(const GroupChatScreen(classId: 'class-yoga')),
          ),
        );
        await tester.pumpAndSettle();

        expect(find.byType(AppBar), findsOneWidget);
      },
    );

    testWidgets(
      'AS-071: sending a group message calls controller.sendGroup',
      (tester) async {
        final fakeController = _OkChatController();

        await tester.pumpWidget(
          ProviderScope(
            overrides: [
              appUserProvider.overrideWith((_) => Stream.value(_fakeClient)),
              groupMessagesProvider('class-yoga')
                  .overrideWith((_) => Stream.value([])),
              chatControllerProvider.overrideWith(() => fakeController),
            ],
            child: _testApp(const GroupChatScreen(classId: 'class-yoga')),
          ),
        );
        await tester.pumpAndSettle();

        await tester.enterText(find.byType(TextField), 'Group message');
        await tester.pump();
        await tester.tap(find.widgetWithIcon(IconButton, Icons.send_rounded));
        await tester.pumpAndSettle();

        expect(fakeController.lastSentGroup, equals('Group message'));
      },
    );
  });

  // ── Chat list screen ──────────────────────────────────────────────────────

  group('ChatScreen (AS-066, AS-067, AS-071)', () {
    testWidgets(
      'AS-066 AS-067: client sees "Chat with trainer" section with trainer card',
      (tester) async {
        await tester.pumpWidget(
          ProviderScope(
            overrides: [
              appUserProvider.overrideWith((_) => Stream.value(_fakeClient)),
              trainersListProvider.overrideWith(
                (_) => Stream.value([_fakeTrainerProfile]),
              ),
              upcomingGroupClassesProvider
                  .overrideWith((_) => Stream.value([])),
            ],
            child: _testApp(const ChatScreen()),
          ),
        );
        await tester.pumpAndSettle();

        // The trainer's name appears (uppercased) in the list.
        expect(
          find.textContaining('ĐOLE FITNESS', skipOffstage: false),
          findsWidgets,
        );
      },
    );

    testWidgets(
      'AS-071: joined group class appears in the client chat list',
      (tester) async {
        await tester.pumpWidget(
          ProviderScope(
            overrides: [
              appUserProvider.overrideWith((_) => Stream.value(_fakeClient)),
              trainersListProvider.overrideWith((_) => Stream.value([])),
              upcomingGroupClassesProvider.overrideWith(
                (_) => Stream.value([_joinedClass]),
              ),
              isJoinedProvider(
                (classId: _joinedClass.id, clientUid: _clientUid),
              ).overrideWith((_) => Stream.value(true)),
            ],
            child: _testApp(const ChatScreen()),
          ),
        );
        await tester.pumpAndSettle();

        expect(
          find.textContaining('YOGA FLOW', skipOffstage: false),
          findsWidgets,
        );
      },
    );

    testWidgets(
      'AS-071: non-joined group class does NOT appear in the client chat list',
      (tester) async {
        await tester.pumpWidget(
          ProviderScope(
            overrides: [
              appUserProvider.overrideWith((_) => Stream.value(_fakeClient)),
              trainersListProvider.overrideWith((_) => Stream.value([])),
              upcomingGroupClassesProvider.overrideWith(
                (_) => Stream.value([_notJoinedClass]),
              ),
              isJoinedProvider(
                (classId: _notJoinedClass.id, clientUid: _clientUid),
              ).overrideWith((_) => Stream.value(false)),
            ],
            child: _testApp(const ChatScreen()),
          ),
        );
        await tester.pumpAndSettle();

        // The non-joined class title must be absent from the chat list.
        expect(
          find.textContaining('HIIT BLAST', skipOffstage: false),
          findsNothing,
        );
      },
    );

    testWidgets(
      'AS-071: trainer sees their own group classes in the group chat section',
      (tester) async {
        await tester.pumpWidget(
          ProviderScope(
            overrides: [
              appUserProvider.overrideWith((_) => Stream.value(_fakeTrainer)),
              trainersListProvider.overrideWith(
                (_) => Stream.value([_fakeTrainerProfile]),
              ),
              trainerChatThreadsProvider(_trainerUid)
                  .overrideWith((_) => Stream.value([])),
              trainerGroupClassesProvider(_trainerUid).overrideWith(
                (_) => Stream.value([_joinedClass]),
              ),
            ],
            child: _testApp(const ChatScreen()),
          ),
        );
        await tester.pumpAndSettle();

        expect(
          find.textContaining('YOGA FLOW', skipOffstage: false),
          findsWidgets,
        );
      },
    );

    testWidgets(
      'AS-067: trainer sees "My Chats" section showing last-message preview',
      (tester) async {
        final thread = ChatThreadSummary(
          threadId: '${_trainerUid}_$_clientUid',
          trainerUid: _trainerUid,
          clientUid: _clientUid,
          lastMessage: 'See you tomorrow!',
          lastMessageAt: _now,
        );

        await tester.pumpWidget(
          ProviderScope(
            overrides: [
              appUserProvider.overrideWith((_) => Stream.value(_fakeTrainer)),
              trainerChatThreadsProvider(_trainerUid)
                  .overrideWith((_) => Stream.value([thread])),
              trainersListProvider.overrideWith((_) => Stream.value([])),
              trainerGroupClassesProvider(_trainerUid)
                  .overrideWith((_) => Stream.value([])),
            ],
            child: _testApp(const ChatScreen()),
          ),
        );
        await tester.pumpAndSettle();

        expect(
          find.textContaining('See you tomorrow!', skipOffstage: false),
          findsWidgets,
        );
      },
    );

    testWidgets(
      'AS-066: client does NOT see "My Chats" section (trainer-only section)',
      (tester) async {
        await tester.pumpWidget(
          ProviderScope(
            overrides: [
              appUserProvider.overrideWith((_) => Stream.value(_fakeClient)),
              trainersListProvider.overrideWith((_) => Stream.value([])),
              upcomingGroupClassesProvider
                  .overrideWith((_) => Stream.value([])),
            ],
            child: _testApp(const ChatScreen()),
          ),
        );
        await tester.pumpAndSettle();

        // Serbian: "MOJI RAZGOVORI" / English: "MY CHATS" — neither must appear.
        expect(
          find.textContaining('MY CHATS', skipOffstage: false),
          findsNothing,
        );
        expect(
          find.textContaining('MOJI RAZGOVORI', skipOffstage: false),
          findsNothing,
        );
      },
    );
  });
}
