import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../auth/application/auth_providers.dart';
import '../../scheduling/domain/booking.dart';
import '../../scheduling/domain/date_utils.dart';
import '../../scheduling/domain/slot.dart';
import '../data/booking_repository.dart';

// ─── Repository ──────────────────────────────────────────────────────────────

/// Provides the [BookingRepository] backed by the shared Firestore instance.
final bookingRepositoryProvider = Provider<BookingRepository>((ref) {
  return BookingRepository(ref.watch(firestoreProvider));
});

// ─── Stream providers ────────────────────────────────────────────────────────

/// Watches upcoming bookings (status=='booked', date >= today) for a client.
///
/// Family parameter: [clientUid].
final clientUpcomingBookingsProvider =
    StreamProvider.family<List<Booking>, String>((ref, clientUid) {
  final todayYmd = ymd(DateTime.now());
  return ref
      .watch(bookingRepositoryProvider)
      .watchClientUpcoming(clientUid, todayYmd: todayYmd);
});

/// Watches past and cancelled bookings for a client.
///
/// Family parameter: [clientUid].
final clientBookingHistoryProvider =
    StreamProvider.family<List<Booking>, String>((ref, clientUid) {
  final todayYmd = ymd(DateTime.now());
  return ref
      .watch(bookingRepositoryProvider)
      .watchClientHistory(clientUid, todayYmd: todayYmd);
});

/// Watches all sessions (booked + cancelled) for a trainer, ordered by
/// date then start.
///
/// Family parameter: [trainerUid].
final trainerSessionsProvider =
    StreamProvider.family<List<Booking>, String>((ref, trainerUid) {
  return ref
      .watch(bookingRepositoryProvider)
      .watchTrainerSessions(trainerUid);
});

// ─── Controller ──────────────────────────────────────────────────────────────

/// Handles booking creation with loading / error state.
///
/// Call [BookingController.book] to book a [Slot] for a client.
class BookingController extends AsyncNotifier<void> {
  @override
  Future<void> build() async {}

  /// Books [slot] for [clientUid].
  ///
  /// Sets [state] to [AsyncLoading] while the transaction runs, then to
  /// [AsyncData] on success or [AsyncError] on failure (e.g. slot taken /
  /// past slot).
  ///
  /// Returns `true` on success, `false` on error.
  Future<bool> book({
    required Slot slot,
    required String clientUid,
  }) async {
    final repo = ref.read(bookingRepositoryProvider);
    state = const AsyncLoading();
    state = await AsyncValue.guard(
      () => repo.createBooking(
        trainerUid: slot.trainerUid,
        clientUid: clientUid,
        date: slot.date,
        start: slot.start,
        end: slot.end,
      ),
    );
    return !state.hasError;
  }
}

/// Provider for [BookingController].
final bookingControllerProvider =
    AsyncNotifierProvider<BookingController, void>(BookingController.new);
