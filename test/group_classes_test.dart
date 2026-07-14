import 'package:flutter_test/flutter_test.dart';
import 'package:sportin_clone/features/booking/domain/booking_policy.dart';
import 'package:sportin_clone/features/group_classes/domain/group_class.dart';

void main() {
  // ── AS-044: remainingSpots and isFull ────────────────────────────────────

  group('GroupClass.remainingSpots and isFull', () {
    test(
      'AS-044: remainingSpots returns capacity minus joinedCount when class '
      'has open spots; isFull is false',
      () {
        const gc = GroupClass(
          id: 'gc1',
          trainerUid: 'trainer-001',
          title: 'Yoga Flow',
          date: '2026-08-01',
          start: '10:00',
          end: '11:00',
          capacity: 10,
          joinedCount: 3,
        );
        expect(gc.remainingSpots, equals(7));
        expect(gc.isFull, isFalse);
      },
    );

    test(
      'AS-043 AS-044: remainingSpots is 0 and isFull is true when class '
      'is exactly at capacity',
      () {
        const gc = GroupClass(
          id: 'gc2',
          trainerUid: 'trainer-001',
          title: 'HIIT',
          date: '2026-08-02',
          start: '08:00',
          end: '09:00',
          capacity: 5,
          joinedCount: 5,
        );
        expect(gc.remainingSpots, equals(0));
        expect(gc.isFull, isTrue);
      },
    );

    test(
      'AS-043: remainingSpots is negative (edge case: over-capacity) and '
      'isFull is true — defensive behaviour',
      () {
        const gc = GroupClass(
          id: 'gc3',
          trainerUid: 'trainer-001',
          title: 'Pilates',
          date: '2026-08-03',
          start: '09:00',
          end: '10:00',
          capacity: 5,
          joinedCount: 6, // should not happen in practice but isFull must still be true
        );
        expect(gc.remainingSpots, equals(-1));
        expect(gc.isFull, isTrue);
      },
    );
  });

  // ── AS-041: fromMap / toMap round-trip ───────────────────────────────────

  group('GroupClass fromMap / toMap round-trip', () {
    test(
      'AS-041: toMap produces the expected map and fromMap restores all fields',
      () {
        const original = GroupClass(
          id: 'class-abc',
          trainerUid: 'trainer-xyz',
          title: 'Stretching',
          date: '2026-09-01',
          start: '07:30',
          end: '08:30',
          capacity: 12,
          joinedCount: 4,
        );

        final map = original.toMap();

        // Verify serialised map
        expect(map['trainerUid'], equals('trainer-xyz'));
        expect(map['title'], equals('Stretching'));
        expect(map['date'], equals('2026-09-01'));
        expect(map['start'], equals('07:30'));
        expect(map['end'], equals('08:30'));
        expect(map['capacity'], equals(12));
        expect(map['joinedCount'], equals(4));
        // 'id' is NOT included in the map (it is the Firestore document key)
        expect(map.containsKey('id'), isFalse);

        // Round-trip: deserialise the map back and compare field-by-field
        final restored = GroupClass.fromMap('class-abc', map);
        expect(restored.id, equals(original.id));
        expect(restored.trainerUid, equals(original.trainerUid));
        expect(restored.title, equals(original.title));
        expect(restored.date, equals(original.date));
        expect(restored.start, equals(original.start));
        expect(restored.end, equals(original.end));
        expect(restored.capacity, equals(original.capacity));
        expect(restored.joinedCount, equals(original.joinedCount));
      },
    );

    test(
      'AS-041: fromMap treats missing joinedCount as 0 (new class documents '
      'may omit the field)',
      () {
        final map = {
          'trainerUid': 'trainer-001',
          'title': 'Boxing',
          'date': '2026-10-01',
          'start': '18:00',
          'end': '19:00',
          'capacity': 8,
          // 'joinedCount' deliberately absent
        };
        final gc = GroupClass.fromMap('new-class', map);
        expect(gc.joinedCount, equals(0));
        expect(gc.remainingSpots, equals(8));
        expect(gc.isFull, isFalse);
      },
    );
  });

  // ── AS-045: reuse of isPastCutoff / bookingSlotStart for group-class times ─
  //
  // These are brief contextual tests to confirm the shared booking-policy
  // helpers behave correctly when applied to group-class start times. The full
  // suite lives in booking_policy_test.dart; we avoid duplicating it here.

  group('isPastCutoff used for group-class leave-cutoff (AS-045)', () {
    test(
      'AS-045: isPastCutoff returns false (leave is allowed) when the class '
      'start is a few minutes in the future',
      () {
        final now = DateTime(2026, 8, 1, 9, 55);
        final classStart = DateTime(2026, 8, 1, 10, 0); // 5 min from now
        expect(isPastCutoff(classStart, now), isFalse);
      },
    );

    test(
      'AS-045: isPastCutoff returns true (leave is blocked) when the class '
      'started a few minutes ago',
      () {
        final now = DateTime(2026, 8, 1, 10, 5);
        final classStart = DateTime(2026, 8, 1, 10, 0); // 5 min in the past
        expect(isPastCutoff(classStart, now), isTrue);
      },
    );

    test(
      'AS-045: bookingSlotStart correctly parses a group-class date/start pair',
      () {
        final result = bookingSlotStart('2026-08-01', '10:00');
        expect(result, equals(DateTime(2026, 8, 1, 10, 0)));
      },
    );
  });
}
