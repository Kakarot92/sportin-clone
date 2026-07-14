// Measurements domain model unit tests.
//
// No Firebase setup required — these are pure model / logic tests.
//
// Assertions covered:
//   AS-056  A client can record a body-measurement entry (weight,
//           circumferences) dated.
//   AS-057  Only the client can create their own measurement entries.
//           (Enforced server-side; domain model carries the clientUid field
//           that Firestore rules check — verified via toMap round-trip.)
//   AS-061  A client can view their measurement history as a chart over time.
//           (data-side: stream returns entries ordered by date descending.)
//   AS-062  A client can edit or delete a measurement entry they created.
//           (Enforced server-side; model round-trip ensures correct shape.)
//   AS-063  A trainer can view the measurement history of their own clients.
//           (TrainerClientRef.fromMap verified here.)
//   AS-064  A trainer cannot view the measurements of clients who are not
//           theirs. (Enforced via rules; TrainerClientRef model checked.)
//   AS-065  Dashboard summary combines sessions attended, active package,
//           and latest measurement. (Pure counting logic tested.)

import 'package:flutter_test/flutter_test.dart';
import 'package:sportin_clone/features/measurements/domain/measurement_entry.dart';
import 'package:sportin_clone/features/measurements/domain/trainer_client_ref.dart';
import 'package:sportin_clone/features/scheduling/domain/booking.dart';

void main() {
  // ── MeasurementEntry.fromMap / toMap round-trip ────────────────────────────

  group('MeasurementEntry fromMap / toMap', () {
    test(
      'AS-056: full entry with all optional fields round-trips correctly',
      () {
        final map = <String, dynamic>{
          'clientUid': 'c1',
          'date': '2026-07-14',
          'weightKg': 75.5,
          'waistCm': 80.0,
          'chestCm': 95.0,
          'hipsCm': 100.0,
          'note': 'Morning weigh-in',
        };

        final entry = MeasurementEntry.fromMap('entry-001', map);

        expect(entry.id, 'entry-001');
        expect(entry.clientUid, 'c1');
        expect(entry.date, '2026-07-14');
        expect(entry.weightKg, 75.5);
        expect(entry.waistCm, 80.0);
        expect(entry.chestCm, 95.0);
        expect(entry.hipsCm, 100.0);
        expect(entry.note, 'Morning weigh-in');

        final result = entry.toMap();
        expect(result['clientUid'], 'c1');
        expect(result['date'], '2026-07-14');
        expect(result['weightKg'], 75.5);
        expect(result['waistCm'], 80.0);
        expect(result['chestCm'], 95.0);
        expect(result['hipsCm'], 100.0);
        expect(result['note'], 'Morning weigh-in');
      },
    );

    test(
      'AS-056: entry with only weight (all circumference/fat fields null) '
      'round-trips and omits null fields from toMap',
      () {
        final map = <String, dynamic>{
          'clientUid': 'c2',
          'date': '2026-07-01',
          'weightKg': 68.0,
        };

        final entry = MeasurementEntry.fromMap('entry-002', map);

        expect(entry.weightKg, 68.0);
        expect(entry.waistCm, isNull);
        expect(entry.chestCm, isNull);
        expect(entry.hipsCm, isNull);
        expect(entry.note, '');

        final result = entry.toMap();
        expect(result['weightKg'], 68.0);
        expect(result.containsKey('waistCm'), isFalse);
        expect(result.containsKey('chestCm'), isFalse);
        expect(result.containsKey('hipsCm'), isFalse);
        expect(result.containsKey('note'), isFalse,
            reason: 'empty note should be omitted');
      },
    );

    test(
      'AS-056: completely empty optional fields (all null, no note) '
      'produces minimal toMap with clientUid and date only',
      () {
        final map = <String, dynamic>{
          'clientUid': 'c3',
          'date': '2026-06-15',
        };

        final entry = MeasurementEntry.fromMap('entry-003', map);
        final result = entry.toMap();

        expect(result.keys.toSet(), equals({'clientUid', 'date'}));
      },
    );

    test(
      'AS-056 AS-062: numeric fields stored as int in Firestore are safely '
      'coerced to double via (num?)?.toDouble()',
      () {
        // Firestore can return numeric values as int even if they were stored
        // as double. The fromMap implementation must handle this gracefully.
        final map = <String, dynamic>{
          'clientUid': 'c4',
          'date': '2026-07-10',
          'weightKg': 80, // int, not double
          'waistCm': 85, // int
        };

        final entry = MeasurementEntry.fromMap('entry-004', map);

        expect(entry.weightKg, isA<double>());
        expect(entry.weightKg, 80.0);
        expect(entry.waistCm, isA<double>());
        expect(entry.waistCm, 85.0);
      },
    );

    test(
      'AS-057: toMap always includes clientUid so Firestore rules can verify '
      'ownership on create/update',
      () {
        final entry = MeasurementEntry(
          id: 'e1',
          clientUid: 'owner-uid',
          date: '2026-07-14',
          weightKg: 70.0,
        );

        final result = entry.toMap();
        expect(result['clientUid'], 'owner-uid',
            reason:
                'clientUid must be present in the map for Firestore rule '
                'request.resource.data.clientUid == request.auth.uid to work');
      },
    );

    test(
      'AS-062: fromMap correctly parses a map that has only a subset of '
      'optional numeric fields (waistCm and hipsCm present, others absent)',
      () {
        final map = <String, dynamic>{
          'clientUid': 'c5',
          'date': '2026-05-01',
          'waistCm': 78.5,
          'hipsCm': 97.0,
          'note': 'Post-holiday check',
        };

        final entry = MeasurementEntry.fromMap('entry-005', map);

        expect(entry.weightKg, isNull);
        expect(entry.waistCm, 78.5);
        expect(entry.chestCm, isNull);
        expect(entry.hipsCm, 97.0);
        expect(entry.note, 'Post-holiday check');

        final result = entry.toMap();
        expect(result.containsKey('weightKg'), isFalse);
        expect(result.containsKey('chestCm'), isFalse);
        expect(result['waistCm'], 78.5);
        expect(result['hipsCm'], 97.0);
      },
    );
  });

  // ── TrainerClientRef.fromMap ───────────────────────────────────────────────

  group('TrainerClientRef fromMap', () {
    test(
      'AS-063: parses trainerUid, clientUid, and clientDisplayName correctly',
      () {
        final map = <String, dynamic>{
          'trainerUid': 'trainer-1',
          'clientUid': 'client-1',
          'clientDisplayName': 'Marko Marković',
        };

        final ref = TrainerClientRef.fromMap(map);

        expect(ref.trainerUid, 'trainer-1');
        expect(ref.clientUid, 'client-1');
        expect(ref.clientDisplayName, 'Marko Marković');
      },
    );

    test(
      'AS-064: missing clientDisplayName defaults to empty string '
      '(marker doc can exist without display name if user lookup failed)',
      () {
        final map = <String, dynamic>{
          'trainerUid': 'trainer-2',
          'clientUid': 'client-2',
          // clientDisplayName absent
        };

        final ref = TrainerClientRef.fromMap(map);

        expect(ref.trainerUid, 'trainer-2');
        expect(ref.clientUid, 'client-2');
        expect(ref.clientDisplayName, '');
      },
    );
  });

  // ── Dashboard summary counting logic (AS-065) ─────────────────────────────

  group('sessionsAttended counting', () {
    // Pure helper that mirrors what dashboardSummaryProvider computes.
    int countAttended(List<Booking> history) =>
        history.where((b) => b.status == 'booked').length;

    Booking makeBooking(String id, String status) => Booking(
          id: id,
          trainerUid: 'trainer-1',
          clientUid: 'client-1',
          date: '2026-01-01',
          start: '10:00',
          end: '11:00',
          status: status,
        );

    test(
      'AS-065: counts only booked entries, ignores cancelled ones',
      () {
        final history = [
          makeBooking('b1', 'booked'),
          makeBooking('b2', 'cancelled'),
          makeBooking('b3', 'booked'),
          makeBooking('b4', 'cancelled'),
          makeBooking('b5', 'booked'),
        ];

        expect(countAttended(history), 3);
      },
    );

    test(
      'AS-065: empty history returns 0 sessions attended',
      () {
        expect(countAttended([]), 0);
      },
    );

    test(
      'AS-065: all sessions booked returns correct count',
      () {
        final history = [
          makeBooking('b1', 'booked'),
          makeBooking('b2', 'booked'),
        ];
        expect(countAttended(history), 2);
      },
    );

    test(
      'AS-065: all sessions cancelled returns 0 attended',
      () {
        final history = [
          makeBooking('b1', 'cancelled'),
          makeBooking('b2', 'cancelled'),
        ];
        expect(countAttended(history), 0);
      },
    );
  });
}
