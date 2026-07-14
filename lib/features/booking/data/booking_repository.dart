import 'package:cloud_firestore/cloud_firestore.dart';

import '../../packages/domain/client_package.dart';
import '../../packages/domain/package_type.dart';
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

  // ─── Private helpers ──────────────────────────────────────────────────────

  /// Finds the currently active [ClientPackage] for [clientUid], or null.
  ///
  /// Fetches all of the client's packages and filters in Dart — acceptable
  /// for the small number of packages a client typically accumulates (mirrors
  /// the [watchClientHistory] pattern).
  Future<ClientPackage?> _findActivePackage(String clientUid) async {
    final snap = await _db
        .collection('clientPackages')
        .where('clientUid', isEqualTo: clientUid)
        .get();
    final active = snap.docs
        .map((d) => ClientPackage.fromMap(d.id, d.data()))
        .where((p) => p.isActive())
        .toList();
    if (active.isEmpty) return null;
    active.sort((a, b) => b.expiryDate.compareTo(a.expiryDate));
    return active.first;
  }

  // ─── Booking creation ────────────────────────────────────────────────────

  /// Creates a booking for [clientUid] with [trainerUid] at [date]/[start].
  ///
  /// Steps:
  /// 1. Guard: if [start] on [date] is before `DateTime.now()`, throws
  ///    [PastSlotException] (AS-029).
  /// 2. Package gate: if the client has no active package, throws
  ///    [NoActivePackageException] (AS-032, AS-054).
  /// 3. Runs a Firestore transaction on the deterministic doc ID. If the slot
  ///    already has status `'booked'`, throws [SlotTakenException] (AS-028).
  ///    For credit-based packages: re-reads the package doc inside the
  ///    transaction and verifies credits > 0 (throws [NoActivePackageException]
  ///    if concurrently depleted), then decrements credits (AS-034).
  ///    Writes (or overwrites a cancelled doc) the booking document with
  ///    `status: 'booked'` and `packageId` set (AS-027).
  ///    Also upserts a `trainerClients/{trainerUid}_{clientUid}` marker so
  ///    that Firestore security rules can verify the trainer-client relationship
  ///    via `exists()` without a collection query (M12 AS-063, AS-064).
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

    // ── 2. Package gate (pre-transaction) ────────────────────────────────
    final activePackage = await _findActivePackage(clientUid);
    if (activePackage == null) {
      throw const NoActivePackageException();
    }

    // ── M12: pre-read client display name for trainer-client marker ───────
    // Done outside the transaction (same pattern as _findActivePackage above)
    // so the transaction body only needs writes and the minimal bookings read.
    String clientDisplayName = '';
    try {
      final userSnap =
          await _db.collection('users').doc(clientUid).get();
      clientDisplayName =
          (userSnap.data()?['displayName'] as String?) ?? '';
    } catch (_) {
      // Non-critical: if the read fails the marker still gets written, just
      // without a display name. The document is updated on the next booking.
    }

    // ── 3. Transactional write ────────────────────────────────────────────
    final docId = Booking.bookingDocId(trainerUid, ymd(date), start);
    final bookingRef = _db.collection('bookings').doc(docId);
    final trainerClientRef = _db
        .collection('trainerClients')
        .doc('${trainerUid}_$clientUid');

    await _db.runTransaction((tx) async {
      // ── All reads first ──────────────────────────────────────────────
      final snap = await tx.get(bookingRef);

      DocumentSnapshot<Map<String, dynamic>>? packageSnap;
      DocumentReference<Map<String, dynamic>>? packageRef;
      if (activePackage.kind == PackageKind.credits) {
        packageRef =
            _db.collection('clientPackages').doc(activePackage.id);
        packageSnap = await tx.get(packageRef);
      }

      // ── Checks (may throw to abort transaction) ──────────────────────
      if (snap.exists && (snap.data()!['status'] as String?) == 'booked') {
        throw const SlotTakenException();
      }

      if (activePackage.kind == PackageKind.credits) {
        final credits =
            (packageSnap?.data()?['remainingCredits'] as int?) ?? 0;
        if (packageSnap == null || !packageSnap.exists || credits <= 0) {
          throw const NoActivePackageException();
        }
        // ── Write: decrement credits ────────────────────────────────
        tx.update(packageRef!, {'remainingCredits': FieldValue.increment(-1)});
      }

      // ── Write: create booking ────────────────────────────────────
      tx.set(bookingRef, {
        'trainerUid': trainerUid,
        'clientUid': clientUid,
        'date': ymd(date),
        'start': start,
        'end': end,
        'status': 'booked',
        'packageId': activePackage.id,
        'createdAt': FieldValue.serverTimestamp(),
      });

      // ── Write: upsert trainer-client relationship marker (M12) ────
      // SetOptions(merge: true) makes this idempotent — repeat bookings
      // just refresh the timestamp without duplicating or erroring.
      tx.set(
        trainerClientRef,
        {
          'trainerUid': trainerUid,
          'clientUid': clientUid,
          'clientDisplayName': clientDisplayName,
          'firstBookedAt': FieldValue.serverTimestamp(),
        },
        SetOptions(merge: true),
      );
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

  /// Admin-only: watches all bookings across the studio, newest first.
  ///
  /// Single-field `orderBy('date', descending: true)` uses Firestore's
  /// auto-created index — no composite index needed (AS-088).
  Stream<List<Booking>> watchAllBookings({int limit = 200}) {
    return _db
        .collection('bookings')
        .orderBy('date', descending: true)
        .limit(limit)
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
  /// For credit-based bookings with a valid [Booking.packageId], refunds one
  /// credit back to the client's package (AS-037).
  ///
  /// Setting status to `'cancelled'` automatically frees the slot because
  /// [AvailabilityRepository.watchBookingsForDay] filters on
  /// `status == 'booked'` (AS-038).
  Future<void> cancelBooking(Booking booking) async {
    final slotStart = bookingSlotStart(booking.date, booking.start);
    if (isPastCutoff(slotStart, DateTime.now())) {
      throw const CutoffPassedException();
    }

    final bookingRef = _db.collection('bookings').doc(booking.id);

    await _db.runTransaction((tx) async {
      // ── All reads first ──────────────────────────────────────────────
      await tx.get(bookingRef);

      DocumentSnapshot<Map<String, dynamic>>? packageSnap;
      DocumentReference<Map<String, dynamic>>? packageRef;
      if (booking.packageId != null) {
        packageRef =
            _db.collection('clientPackages').doc(booking.packageId);
        packageSnap = await tx.get(packageRef);
      }

      // ── Writes ──────────────────────────────────────────────────────
      tx.update(bookingRef, {'status': 'cancelled'});

      // Refund one credit for credit-based bookings (AS-037).
      if (packageSnap != null &&
          packageRef != null &&
          packageSnap.exists) {
        final kindStr = packageSnap.data()!['kind'] as String?;
        if (kindStr == 'credits') {
          tx.update(
            packageRef,
            {'remainingCredits': FieldValue.increment(1)},
          );
        }
      }
    });
  }

  /// Atomically cancels [oldBooking] and books the new slot described by
  /// [newTrainerUid] / [newDate] / [newStart] / [newEnd] (AS-039).
  ///
  /// The [oldBooking.packageId] is carried forward to the new booking —
  /// rescheduling does not consume an additional credit or free one up.
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
        if (oldBooking.packageId != null) 'packageId': oldBooking.packageId,
        'createdAt': FieldValue.serverTimestamp(),
      });
    });
  }
}
