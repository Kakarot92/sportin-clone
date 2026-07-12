import 'package:flutter_test/flutter_test.dart';
import 'package:sportin_clone/features/scheduling/domain/availability_exception.dart';
import 'package:sportin_clone/features/scheduling/domain/availability_service.dart';
import 'package:sportin_clone/features/scheduling/domain/booking.dart';
import 'package:sportin_clone/features/scheduling/domain/date_utils.dart';
import 'package:sportin_clone/features/scheduling/domain/studio_settings.dart';
import 'package:sportin_clone/features/scheduling/domain/time_range.dart';
import 'package:sportin_clone/features/scheduling/domain/weekly_availability.dart';

void main() {
  // January 8 2024 is a Monday (DateTime.weekday == 1).
  final monday = DateTime(2024, 1, 8);

  const trainerUid = 'trainer-001';
  const emptyStudio = StudioSettings.initial();

  /// Template: Mon 09:00–12:00, 60-minute slots.
  final monTemplate = WeeklyAvailability(
    trainerUid: trainerUid,
    slotMinutes: 60,
    weekly: {
      1: [const TimeRange(start: '09:00', end: '12:00')],
    },
  );

  // ─── AS-020 / AS-023: basic slot generation ──────────────────────────────

  test(
    'AS-020 AS-023: Mon 09:00–12:00 with 60-min slots generates 3 slots '
    '(09:00, 10:00, 11:00)',
    () {
      final slots = generateDaySlots(
        day: monday,
        template: monTemplate,
        studio: emptyStudio,
        exceptions: [],
        bookings: [],
      );

      expect(slots.length, 3);
      expect(slots[0].start, '09:00');
      expect(slots[0].end, '10:00');
      expect(slots[1].start, '10:00');
      expect(slots[1].end, '11:00');
      expect(slots[2].start, '11:00');
      expect(slots[2].end, '12:00');
      // All slots belong to the correct trainer.
      expect(slots.every((s) => s.trainerUid == trainerUid), isTrue);
    },
  );

  // ─── AS-024: booked slot is removed ─────────────────────────────────────

  test(
    'AS-024: an existing booking for 10:00–11:00 removes the 10:00 slot',
    () {
      final booking = Booking(
        id: 'b1',
        trainerUid: trainerUid,
        clientUid: 'client-001',
        date: ymd(monday),
        start: '10:00',
        end: '11:00',
        status: 'booked',
      );

      final slots = generateDaySlots(
        day: monday,
        template: monTemplate,
        studio: emptyStudio,
        exceptions: [],
        bookings: [booking],
      );

      expect(slots.length, 2);
      expect(slots.map((s) => s.start).toList(), ['09:00', '11:00']);
    },
  );

  test(
    'AS-024: a cancelled booking does NOT remove the slot',
    () {
      final cancelled = Booking(
        id: 'b2',
        trainerUid: trainerUid,
        clientUid: 'client-002',
        date: ymd(monday),
        start: '10:00',
        end: '11:00',
        status: 'cancelled',
      );

      final slots = generateDaySlots(
        day: monday,
        template: monTemplate,
        studio: emptyStudio,
        exceptions: [],
        bookings: [cancelled],
      );

      // Cancelled booking must not reduce available slots.
      expect(slots.length, 3);
    },
  );

  // ─── AS-022: exception removes slot ─────────────────────────────────────

  test(
    'AS-022: a time-range exception for 09:00–10:00 removes the 09:00 slot',
    () {
      final exception = AvailabilityException(
        id: 'ex1',
        trainerUid: trainerUid,
        date: monday,
        allDay: false,
        start: '09:00',
        end: '10:00',
      );

      final slots = generateDaySlots(
        day: monday,
        template: monTemplate,
        studio: emptyStudio,
        exceptions: [exception],
        bookings: [],
      );

      expect(slots.length, 2);
      expect(slots.map((s) => s.start).toList(), ['10:00', '11:00']);
    },
  );

  test(
    'AS-022: exception for a different trainer does not affect slots',
    () {
      final exception = AvailabilityException(
        id: 'ex-other',
        trainerUid: 'trainer-999', // different trainer
        date: monday,
        allDay: false,
        start: '09:00',
        end: '10:00',
      );

      final slots = generateDaySlots(
        day: monday,
        template: monTemplate,
        studio: emptyStudio,
        exceptions: [exception],
        bookings: [],
      );

      expect(slots.length, 3);
    },
  );

  // ─── AS-026: studio closed weekday ──────────────────────────────────────

  test(
    'AS-026: studio closed for Monday returns empty slot list',
    () {
      final studio = StudioSettings(
        closedWeekdays: {monday.weekday},
        closedDates: const <String>{},
      );

      final slots = generateDaySlots(
        day: monday,
        template: monTemplate,
        studio: studio,
        exceptions: [],
        bookings: [],
      );

      expect(slots, isEmpty);
    },
  );

  // ─── AS-026: studio closed specific date ────────────────────────────────

  test(
    'AS-026: studio closed on the specific date returns empty slot list',
    () {
      final studio = StudioSettings(
        closedWeekdays: const <int>{},
        closedDates: {ymd(monday)},
      );

      final slots = generateDaySlots(
        day: monday,
        template: monTemplate,
        studio: studio,
        exceptions: [],
        bookings: [],
      );

      expect(slots, isEmpty);
    },
  );

  // ─── AS-026: all-day trainer exception ──────────────────────────────────

  test(
    'AS-026: all-day exception for the trainer returns empty slot list',
    () {
      final exception = AvailabilityException(
        id: 'ex-allday',
        trainerUid: trainerUid,
        date: monday,
        allDay: true,
      );

      final slots = generateDaySlots(
        day: monday,
        template: monTemplate,
        studio: emptyStudio,
        exceptions: [exception],
        bookings: [],
      );

      expect(slots, isEmpty);
    },
  );

  // ─── No windows for the selected weekday ────────────────────────────────

  test(
    'A day with no working windows in the template returns empty slot list',
    () {
      // Template only has Monday; Tuesday has no entry.
      final tuesday = DateTime(2024, 1, 9);

      final slots = generateDaySlots(
        day: tuesday,
        template: monTemplate,
        studio: emptyStudio,
        exceptions: [],
        bookings: [],
      );

      expect(slots, isEmpty);
    },
  );

  // ─── Edge cases ─────────────────────────────────────────────────────────

  test(
    'WeeklyAvailability.empty produces no slots regardless of day',
    () {
      final emptyTemplate = WeeklyAvailability.empty(trainerUid);

      final slots = generateDaySlots(
        day: monday,
        template: emptyTemplate,
        studio: emptyStudio,
        exceptions: [],
        bookings: [],
      );

      expect(slots, isEmpty);
    },
  );

  test(
    'Slots are returned in ascending start-time order',
    () {
      final slots = generateDaySlots(
        day: monday,
        template: monTemplate,
        studio: emptyStudio,
        exceptions: [],
        bookings: [],
      );

      for (var i = 0; i < slots.length - 1; i++) {
        expect(
          slots[i].start.compareTo(slots[i + 1].start),
          lessThan(0),
          reason: 'Slot at index $i should start before slot at index ${i + 1}',
        );
      }
    },
  );
}
