import 'package:flutter_test/flutter_test.dart';
import 'package:sportin_clone/features/booking/domain/booking_policy.dart';
import 'package:sportin_clone/features/scheduling/domain/booking.dart';

void main() {
  // ── AS-035 / AS-036: cancellation cutoff policy ───────────────────────────

  group('isPastCutoff', () {
    test(
      'AS-036: isPastCutoff returns false when slot is 20h away (well within '
      'the 12h cutoff — cancellation allowed)',
      () {
        final now = DateTime(2026, 7, 20, 8, 0);
        final slotStart = now.add(const Duration(hours: 20));
        expect(isPastCutoff(slotStart, now), isFalse);
      },
    );

    test(
      'AS-036: isPastCutoff returns true when slot is only 5h away (past the '
      '12h cutoff — cancellation NOT allowed)',
      () {
        final now = DateTime(2026, 7, 20, 8, 0);
        final slotStart = now.add(const Duration(hours: 5));
        expect(isPastCutoff(slotStart, now), isTrue);
      },
    );

    test(
      'AS-036: isPastCutoff boundary — exactly 12h before slot start returns '
      'false (exclusive boundary: user CAN still cancel at the cutoff moment)',
      () {
        final now = DateTime(2026, 7, 20, 8, 0);
        // slotStart is exactly 12h after now, so cutoffMoment == now.
        final slotStart = now.add(const Duration(hours: 12));
        // now.isAfter(cutoffMoment) == now.isAfter(now) == false
        expect(isPastCutoff(slotStart, now), isFalse);
      },
    );

    test(
      'AS-036: isPastCutoff returns true when 1 minute past the cutoff moment',
      () {
        final now = DateTime(2026, 7, 20, 8, 1); // 1 min past the cutoff
        final slotStart = DateTime(2026, 7, 20, 20, 0); // 11h59m away
        expect(isPastCutoff(slotStart, now), isTrue);
      },
    );

    test(
      'AS-036: custom cutoffHours parameter is respected',
      () {
        final now = DateTime(2026, 7, 20, 8, 0);
        final slotStart = now.add(const Duration(hours: 3));
        // With a 2h cutoff, 3h away should be fine.
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
      'AS-035: canCancelBooking returns true when slot is 20h away '
      '(returns the negation of isPastCutoff)',
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
      'AS-036: canCancelBooking returns false when slot is 5h away (past '
      'cutoff — negation of isPastCutoff)',
      () {
        final now = DateTime(2026, 7, 20, 8, 0);
        // Slot is at 13:00 on the same day — only 5h away.
        final booking = makeBooking('2026-07-20', '13:00');
        expect(canCancelBooking(booking, now: now), isFalse);
      },
    );

    test(
      'AS-036: canCancelBooking returns true at exactly the cutoff boundary '
      '(exclusive boundary consistent with isPastCutoff)',
      () {
        final now = DateTime(2026, 7, 20, 8, 0);
        // Slot exactly 12h later → canCancelBooking should return true.
        final booking = makeBooking('2026-07-20', '20:00');
        expect(canCancelBooking(booking, now: now), isTrue);
      },
    );
  });
}
