import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../auth/application/auth_providers.dart';
import '../data/group_class_repository.dart';
import '../domain/group_class.dart';

// ─── Repository ──────────────────────────────────────────────────────────────

/// Provides the [GroupClassRepository] backed by the shared Firestore instance.
final groupClassRepositoryProvider = Provider<GroupClassRepository>((ref) {
  return GroupClassRepository(ref.watch(firestoreProvider));
});

// ─── Stream providers ────────────────────────────────────────────────────────

/// Watches all upcoming group classes (date >= today), ordered by date then
/// start time.
final upcomingGroupClassesProvider = StreamProvider<List<GroupClass>>((ref) {
  return ref.watch(groupClassRepositoryProvider).watchUpcomingClasses();
});

/// Watches all group classes created by a trainer, ordered by date then start.
///
/// Family parameter: [trainerUid].
final trainerGroupClassesProvider =
    StreamProvider.family<List<GroupClass>, String>((ref, trainerUid) {
  return ref
      .watch(groupClassRepositoryProvider)
      .watchTrainerClasses(trainerUid);
});

/// Watches whether a specific client has joined a specific group class.
///
/// Family parameter: a record `({String classId, String clientUid})`.
final isJoinedProvider =
    StreamProvider.family<bool, ({String classId, String clientUid})>(
        (ref, args) {
  return ref
      .watch(groupClassRepositoryProvider)
      .watchIsJoined(args.classId, args.clientUid);
});

// ─── Controller ──────────────────────────────────────────────────────────────

/// Handles group class creation and join/leave actions with loading/error state.
class GroupClassController extends AsyncNotifier<void> {
  @override
  Future<void> build() async {}

  /// Creates a new group class (AS-041).
  ///
  /// Sets [state] to [AsyncLoading] while the write runs, then to [AsyncData]
  /// on success or [AsyncError] on failure.
  ///
  /// Returns `true` on success, `false` on error.
  Future<bool> createClass(GroupClass gc) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(
      () => ref.read(groupClassRepositoryProvider).createClass(gc),
    );
    return !state.hasError;
  }

  /// Joins [clientUid] to [classId] (AS-042, AS-043, AS-044, AS-046).
  ///
  /// Returns `true` on success, `false` on error (e.g. class full /
  /// already joined).
  Future<bool> join({
    required String classId,
    required String clientUid,
  }) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(
      () => ref
          .read(groupClassRepositoryProvider)
          .joinClass(classId: classId, clientUid: clientUid),
    );
    return !state.hasError;
  }

  /// Removes [clientUid] from [classId] (AS-044, AS-045).
  ///
  /// Returns `true` on success, `false` on error (e.g. class already started).
  Future<bool> leave({
    required String classId,
    required String clientUid,
    required DateTime classStart,
  }) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(
      () => ref.read(groupClassRepositoryProvider).leaveClass(
            classId: classId,
            clientUid: clientUid,
            classStart: classStart,
          ),
    );
    return !state.hasError;
  }
}

/// Provider for [GroupClassController].
final groupClassControllerProvider =
    AsyncNotifierProvider<GroupClassController, void>(GroupClassController.new);
