import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../auth/application/auth_providers.dart';
import '../data/chat_repository.dart';
import '../domain/chat_message.dart';
import '../domain/chat_thread_summary.dart';

// ─── Repository ───────────────────────────────────────────────────────────────

/// Provides the [ChatRepository] backed by the shared Firestore instance.
final chatRepositoryProvider = Provider<ChatRepository>((ref) {
  return ChatRepository(ref.watch(firestoreProvider));
});

// ─── Stream providers ─────────────────────────────────────────────────────────

/// Watches all messages in a 1-on-1 chat thread, ordered chronologically
/// (AS-069).
///
/// Family parameter: [threadId] — compute via
/// [ChatRepository.oneOnOneThreadId].
final oneOnOneMessagesProvider =
    StreamProvider.family<List<ChatMessage>, String>((ref, threadId) {
  return ref.watch(chatRepositoryProvider).watchMessages(threadId);
});

/// Watches all messages in a group-class chat thread, ordered chronologically
/// (AS-069, AS-071).
///
/// Family parameter: [classId] — the Firestore document ID of the group class.
final groupMessagesProvider =
    StreamProvider.family<List<ChatMessage>, String>((ref, classId) {
  return ref.watch(chatRepositoryProvider).watchGroupMessages(classId);
});

/// Watches all 1-on-1 chat threads for a client, ordered by most recent
/// message first.
///
/// Family parameter: [clientUid].
final clientChatThreadsProvider =
    StreamProvider.family<List<ChatThreadSummary>, String>((ref, clientUid) {
  return ref.watch(chatRepositoryProvider).watchClientThreads(clientUid);
});

/// Watches all 1-on-1 chat threads for a trainer, ordered by most recent
/// message first.
///
/// Family parameter: [trainerUid].
final trainerChatThreadsProvider =
    StreamProvider.family<List<ChatThreadSummary>, String>((ref, trainerUid) {
  return ref.watch(chatRepositoryProvider).watchTrainerThreads(trainerUid);
});

// ─── Controller ───────────────────────────────────────────────────────────────

/// Handles chat message sending with loading / error state.
///
/// Mirrors [BookingController]'s exact style: each action sets [state] to
/// [AsyncLoading], runs the async operation via [AsyncValue.guard], and returns
/// `true` on success or `false` on error.
class ChatController extends AsyncNotifier<void> {
  @override
  Future<void> build() async {}

  ChatRepository get _repo => ref.read(chatRepositoryProvider);

  /// Sends a text message in the 1-on-1 thread between [trainerUid] and
  /// [clientUid] (AS-066, AS-067).
  ///
  /// Returns `true` on success, `false` on error.
  Future<bool> send({
    required String trainerUid,
    required String clientUid,
    required String senderUid,
    required String text,
  }) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(
      () => _repo.sendMessage(
        trainerUid: trainerUid,
        clientUid: clientUid,
        senderUid: senderUid,
        text: text,
      ),
    );
    return !state.hasError;
  }

  /// Sends a text message in the group-class thread for [classId] (AS-071).
  ///
  /// Returns `true` on success, `false` on error.
  Future<bool> sendGroup({
    required String classId,
    required String senderUid,
    required String text,
  }) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(
      () => _repo.sendGroupMessage(
        classId: classId,
        senderUid: senderUid,
        text: text,
      ),
    );
    return !state.hasError;
  }
}

/// Provider for [ChatController].
final chatControllerProvider =
    AsyncNotifierProvider<ChatController, void>(ChatController.new);
