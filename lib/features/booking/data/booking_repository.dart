import 'package:cloud_firestore/cloud_firestore.dart';

import '../../scheduling/domain/booking.dart';
import '../../scheduling/domain/date_utils.dart';
import '../domain/booking_exceptions.dart';
import '../domain/booking_policy.dart';

/// Firestore-backed repository for booking creation and querying.
///
/// Collections:
/// - `bookings/{deterministic-id}` — 1-on-1 session bookings
///
/// The document ID is deterministic (see [Booking.bookingDocId]) so that
/// concurrent booking attempts for the same slot collide on the same document
/// inside a Firestore transaction, preventing double-bookings (AS-027, AS-028).
class BookingRepository {
  BookingRepository(this._db);

  final FirebaseFirestore _db;

  // ─── Booking creation ────────────────────────────────────────────────────

  /// Creates a booking for [clientUid] with [trainerUid] at [date]/[start].
  ///
  /// Steps:
  /// 1. Guard: if [start] on [date] is before `DateTime.now()`, throws
  ///    [PastSlotException] (AS-029).
  /// 2. Runs a Firestore transaction on the deterministic doc ID. If the slot
  ///    already has status `'booked'`, throws [SlotTakenException] (AS-028).
  ///    Otherwise writes (or overwrites a cancelled doc) the booking document
  ///    with `status: 'booked'` (AS-027).
  Future<void> createBooking({
    required String trainerUid,
    required String clientUid,
    required DateTime date,
    required String start,
    required String end,
  }) async {
    // ── 1. Past-slot guard ────────────────────────────────────────────────
    final timeParts = start.split(':');
    final slotStart = DateTime(
      date.year,
      date.month,
      date.day,
      int.parse(timeParts[0]),
      int.parse(timeParts[1]),
    );
    if (isPastSlot(slotStart, DateTime.now())) {
      throw const PastSlotException();
    }

    // ── 2. Transactional write ────────────────────────────────────────────
    final docId = Booking.bookingDocId(trainerUid, ymd(date), start);
    final ref = _db.collection('bookings').doc(docId);

    await _db.runTransaction((tx) async {
      final snap = await tx.get(ref);
      if (snap.exists && (snap.data()!['status'] as String?) == 'booked') {
        throw const SlotTakenException();
      }
      tx.set(ref, {
        'trainerUid': trainerUid,
        'clientUid': clientUid,
        'date': ymd(date),
        'start': start,
        'end': end,
        'status': 'booked',
        'createdAt': FieldValue.serverTimestamp(),
      });
    });
  }

  // ─── Streams ─────────────────────────────────────────────────────────────

  /// Watches upcoming (status=='booked', date >= today) bookings for a client.
  ///
  /// Returns a stream ordered by date then start time.
  Stream<List<Booking>> watchClientUpcoming(
    String clientUid, {
    required String todayYmd,
  }) {
    return _db
        .collection('bookings')
        .where('clientUid', isEqualTo: clientUid)
        .where('status', isEqualTo: 'booked')
        .where('date', isGreaterThanOrEqualTo: todayYmd)
        .orderBy('date')
        .orderBy('start')
        .snapshots()
        .map((snap) =>
            snap.docs.map((d) => Booking.fromMap(d.id, d.data())).toList());
  }

  /// Watches past and cancelled bookings for a client.
  ///
  /// Fetches all bookings for [clientUid] ordered by date descending, then
  /// filters in Dart for entries where `date < todayYmd` OR `status ==
  /// 'cancelled'`. This avoids a Firestore OR query (which would require
  /// multiple composite indexes or unsupported syntax) at the cost of
  /// fetching slightly more data — acceptable for this use-case.
  Stream<List<Booking>> watchClientHistory(
    String clientUid, {
    required String todayYmd,
  }) {
    return _db
        .collection('bookings')
        .where('clientUid', isEqualTo: clientUid)
        .orderBy('date', descending: true)
        .snapshots()
        .map((snap) {
      final all =
          snap.docs.map((d) => Booking.fromMap(d.id, d.data())).toList();
      return all
          .where((b) => b.date.compareTo(todayYmd) < 0 || b.status == 'cancelled')
          .toList();
    });
  }

  /// Watches all sessions (booked and cancelled) for a trainer, ordered by
  /// date then start time.
  Stream<List<Booking>> watchTrainerSessions(String trainerUid) {
    return _db
        .collection('bookings')
        .where('trainerUid', isEqualTo: trainerUid)
        .orderBy('date')
        .orderBy('start')
        .snapshots()
        .map((snap) =>
            snap.docs.map((d) => Booking.fromMap(d.id, d.data())).toList());
  }

  // ─── Cancellation & reschedule (AS-035, AS-036, AS-038, AS-039, AS-040) ──

  /// Cancels [booking] by setting its status to `'cancelled'`.
  ///
  /// Throws [CutoffPassedException] if the session has already started or
  /// is in the past (`kCancellationCutoffHours = 0`; AS-036).
  ///
  /// Setting status to `'cancelled'` automatically frees the slot because
  /// [AvailabilityRepository.watchBookingsForDay] filters on
  /// `status == 'booked'` (AS-038).
  Future<void> cancelBooking(Booking booking) async {
    final slotStart = bookingSlotStart(booking.date, booking.start);
    if (isPastCutoff(slotStart, DateTime.now())) {
      throw const CutoffPassedException();
    }
    await _db
        .collection('bookings')
        .doc(booking.id)
        .update({'status': 'cancelled'});
  }

  /// Atomically cancels [oldBooking] and books the new slot described by
  /// [newTrainerUid] / [newDate] / [newStart] / [newEnd] (AS-039).
  ///
  /// Throws:
  /// - [CutoffPassedException] if the OLD slot's cutoff has passed.
  /// - [PastSlotException] if the NEW slot is in the past.
  /// - [SlotTakenException] if the NEW slot is already booked.
  Future<void> rescheduleBooking({
    required Booking oldBooking,
    required String newTrainerUid,
    required DateTime newDate,
    required String newStart,
    required String newEnd,
  }) async {
    // 1. Cutoff check on OLD booking.
    final oldSlotStart = bookingSlotStart(oldBooking.date, oldBooking.start);
    if (isPastCutoff(oldSlotStart, DateTime.now())) {
      throw const CutoffPassedException();
    }

    // 2. Past-slot guard on NEW slot.
    final newSlotStart = bookingSlotStart(ymd(newDate), newStart);
    if (isPastSlot(newSlotStart, DateTime.now())) {
      throw const PastSlotException();
    }

    // 3. Single atomic transaction: cancel old + book new.
    final oldRef = _db.collection('bookings').doc(oldBooking.id);
    final newDocId =
        Booking.bookingDocId(newTrainerUid, ymd(newDate), newStart);
    final newRef = _db.collection('bookings').doc(newDocId);

    await _db.runTransaction((tx) async {
      final newSnap = await tx.get(newRef);
      if (newSnap.exists &&
          (newSnap.data()!['status'] as String?) == 'booked') {
        throw const SlotTakenException();
      }
      tx.update(oldRef, {'status': 'cancelled'});
      tx.set(newRef, {
        'trainerUid': newTrainerUid,
        'clientUid': oldBooking.clientUid,
        'date': ymd(newDate),
        'start': newStart,
        'end': newEnd,
        'status': 'booked',
        'createdAt': FieldValue.serverTimestamp(),
      });
    });
  }
}
