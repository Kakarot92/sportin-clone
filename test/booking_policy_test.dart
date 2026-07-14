import 'package:flutter_test/flutter_test.dart';
import 'package:sportin_clone/features/booking/domain/booking_policy.dart';
import 'package:sportin_clone/features/scheduling/domain/booking.dart';

void main() {
  // ── AS-035 / AS-036: cancellation cutoff policy ───────────────────────────
  //
  // Policy (kCancellationCutoffHours = 0): cancellation and rescheduling are
  // allowed at any time before the session starts. The only block is when the
  // session has already started or is in the past.

  group('isPastCutoff', () {
    test(
      'AS-036: isPastCutoff returns false when slot is several hours in the '
      'future — cancellation is still allowed',
      () {
        final now = DateTime(2026, 7, 20, 8, 0);
        final slotStart = now.add(const Duration(hours: 5));
        expect(isPastCutoff(slotStart, now), isFalse);
      },
    );

    test(
      'AS-036: isPastCutoff returns false when slot is only minutes away — '
      'cancellation is still allowed right up to the start',
      () {
        final now = DateTime(2026, 7, 20, 8, 0);
        final slotStart = now.add(const Duration(minutes: 3));
        expect(isPastCutoff(slotStart, now), isFalse);
      },
    );

    test(
      'AS-036: isPastCutoff returns true when slot is in the past — '
      'session has already started, cancellation blocked',
      () {
        final now = DateTime(2026, 7, 20, 8, 0);
        final slotStart = now.subtract(const Duration(minutes: 30));
        expect(isPastCutoff(slotStart, now), isTrue);
      },
    );

    test(
      'AS-036: isPastCutoff boundary — slot starting exactly at now returns '
      'false (exclusive: user CAN still cancel at the exact start moment)',
      () {
        final now = DateTime(2026, 7, 20, 8, 0);
        // With cutoffHours = 0: cutoffMoment = slotStart.subtract(0h) = slotStart
        // now.isAfter(slotStart) == now.isAfter(now) == false
        final slotStart = now;
        expect(isPastCutoff(slotStart, now), isFalse);
      },
    );

    test(
      'AS-036: isPastCutoff returns true when slot started 1 minute ago',
      () {
        final slotStart = DateTime(2026, 7, 20, 8, 0); // session started at 08:00
        final now = DateTime(2026, 7, 20, 8, 1); // it is now 08:01 — 1 min late
        expect(isPastCutoff(slotStart, now), isTrue);
      },
    );

    test(
      'AS-036: custom cutoffHours parameter is respected',
      () {
        final now = DateTime(2026, 7, 20, 8, 0);
        final slotStart = now.add(const Duration(hours: 3));
        // With a 2h cutoff, 3h away should still be allowed.
        expect(isPastCutoff(slotStart, now, cutoffHours: 2), isFalse);
        // With a 4h cutoff, 3h away is past the cutoff.
        expect(isPastCutoff(slotStart, now, cutoffHours: 4), isTrue);
      },
    );
  });

  // ── bookingSlotStart parsing ──────────────────────────────────────────────

  group('bookingSlotStart', () {
    test(
      'AS-035: bookingSlotStart parses "2026-07-20" and "09:30" into '
      'DateTime(2026, 7, 20, 9, 30)',
      () {
        final result = bookingSlotStart('2026-07-20', '09:30');
        expect(result, equals(DateTime(2026, 7, 20, 9, 30)));
      },
    );

    test(
      'AS-035: bookingSlotStart parses midnight correctly',
      () {
        final result = bookingSlotStart('2026-01-01', '00:00');
        expect(result, equals(DateTime(2026, 1, 1, 0, 0)));
      },
    );

    test(
      'AS-035: bookingSlotStart parses end-of-day correctly',
      () {
        final result = bookingSlotStart('2026-12-31', '23:59');
        expect(result, equals(DateTime(2026, 12, 31, 23, 59)));
      },
    );
  });

  // ── canCancelBooking helper ───────────────────────────────────────────────

  group('canCancelBooking', () {
    Booking makeBooking(String date, String start) => Booking(
          id: 'test-id',
          trainerUid: 'trainer-001',
          clientUid: 'client-001',
          date: date,
          start: start,
          end: '10:00',
          status: 'booked',
        );

    test(
      'AS-035: canCancelBooking returns true when slot is several hours in '
      'the future — session has not yet started',
      () {
        final now = DateTime(2026, 7, 20, 8, 0);
        final slotStart = now.add(const Duration(hours: 20));
        final booking = makeBooking(
          '${slotStart.year}-'
          '${slotStart.month.toString().padLeft(2, '0')}-'
          '${slotStart.day.toString().padLeft(2, '0')}',
          '${slotStart.hour.toString().padLeft(2, '0')}:'
          '${slotStart.minute.toString().padLeft(2, '0')}',
        );
        expect(canCancelBooking(booking, now: now), isTrue);
      },
    );

    test(
      'AS-036: canCancelBooking returns false when slot is in the past — '
      'session has already started, cancellation blocked',
      () {
        final now = DateTime(2026, 7, 20, 8, 0);
        // Slot started 30 minutes ago.
        final booking = makeBooking('2026-07-20', '07:30');
        expect(canCancelBooking(booking, now: now), isFalse);
      },
    );

    test(
      'AS-036: canCancelBooking returns true at exactly the session start '
      'time (exclusive boundary — session start moment itself is still OK)',
      () {
        final now = DateTime(2026, 7, 20, 8, 0);
        // Slot starts exactly at now: cutoffMoment == slotStart == now,
        // now.isAfter(now) == false → isPastCutoff = false → canCancelBooking = true
        final booking = makeBooking('2026-07-20', '08:00');
        expect(canCancelBooking(booking, now: now), isTrue);
      },
    );

    test(
      'AS-036: canCancelBooking returns true for a slot just minutes away — '
      'no advance-notice window is enforced',
      () {
        final now = DateTime(2026, 7, 20, 8, 0);
        // Slot 3 minutes in the future → should still be cancellable.
        final booking = makeBooking('2026-07-20', '08:03');
        expect(canCancelBooking(booking, now: now), isTrue);
      },
    );
  });
}
