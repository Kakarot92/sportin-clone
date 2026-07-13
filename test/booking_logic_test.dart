import 'package:flutter_test/flutter_test.dart';
import 'package:sportin_clone/features/booking/domain/booking_exceptions.dart';
import 'package:sportin_clone/features/scheduling/domain/booking.dart';

void main() {
  // ── AS-027 / AS-028: deterministic booking doc ID ─────────────────────────

  group('Booking.bookingDocId', () {
    test(
      'AS-027 AS-028: bookingDocId removes colons from start and joins fields with underscores',
      () {
        expect(
          Booking.bookingDocId('t', '2026-07-13', '09:00'),
          equals('t_2026-07-13_0900'),
        );
      },
    );

    test(
      'AS-027 AS-028: bookingDocId with real trainer uid and time',
      () {
        expect(
          Booking.bookingDocId('trainer-djole', '2026-07-13', '09:00'),
          equals('trainer-djole_2026-07-13_0900'),
        );
      },
    );

    test(
      'AS-027 AS-028: two calls with the same arguments produce the same doc ID (idempotent)',
      () {
        final id1 = Booking.bookingDocId('trainer-abc', '2026-08-01', '14:30');
        final id2 = Booking.bookingDocId('trainer-abc', '2026-08-01', '14:30');
        expect(id1, equals(id2));
      },
    );

    test(
      'AS-028: different slots produce different doc IDs',
      () {
        final id1 = Booking.bookingDocId('trainer-abc', '2026-08-01', '09:00');
        final id2 = Booking.bookingDocId('trainer-abc', '2026-08-01', '10:00');
        expect(id1, isNot(equals(id2)));
      },
    );
  });

  // ── AS-029: past-slot guard ───────────────────────────────────────────────

  group('isPastSlot', () {
    test(
      'AS-029: isPastSlot returns true when slotStart is before now',
      () {
        final now = DateTime(2026, 7, 13, 10, 0);
        final pastSlot = DateTime(2026, 7, 13, 9, 0);
        expect(isPastSlot(pastSlot, now), isTrue);
      },
    );

    test(
      'AS-029: isPastSlot returns false when slotStart is after now',
      () {
        final now = DateTime(2026, 7, 13, 10, 0);
        final futureSlot = DateTime(2026, 7, 13, 11, 0);
        expect(isPastSlot(futureSlot, now), isFalse);
      },
    );

    test(
      'AS-029: isPastSlot returns false when slotStart equals now (boundary)',
      () {
        final now = DateTime(2026, 7, 13, 10, 0);
        // isBefore returns false for equal times — boundary should not block.
        expect(isPastSlot(now, now), isFalse);
      },
    );

    test(
      'AS-029: isPastSlot returns true for a slot from a previous day',
      () {
        final now = DateTime(2026, 7, 13, 8, 0);
        final yesterday = DateTime(2026, 7, 12, 23, 59);
        expect(isPastSlot(yesterday, now), isTrue);
      },
    );
  });
}
