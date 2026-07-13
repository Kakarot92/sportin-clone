import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sportin_clone/core/models/app_user.dart';
import 'package:sportin_clone/features/auth/application/auth_providers.dart';
import 'package:sportin_clone/features/booking/application/booking_providers.dart';
import 'package:sportin_clone/features/booking/domain/booking_exceptions.dart';
import 'package:sportin_clone/features/booking/presentation/my_bookings_screen.dart';
import 'package:sportin_clone/features/booking/presentation/trainer_sessions_screen.dart';
import 'package:sportin_clone/features/scheduling/domain/booking.dart';
import 'package:sportin_clone/features/trainers/application/trainers_providers.dart';
import 'package:sportin_clone/l10n/app_localizations.dart';

// ─── Helpers ─────────────────────────────────────────────────────────────────

/// Wraps [child] with the localisation delegates so l10n.* calls work.
/// Each test wraps this in a ProviderScope with its own overrides so that
/// the `Override` type does not need to be named explicitly.
Widget _testApp(Widget child) => MaterialApp(
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: child,
    );

// ─── Fixtures ────────────────────────────────────────────────────────────────

const _fakeClient = AppUser(
  uid: 'client-1',
  email: 'client@test.com',
  displayName: 'Test Client',
  role: AppRole.client,
);

const _fakeTrainer = AppUser(
  uid: 'trainer-1',
  email: 'trainer@test.com',
  displayName: 'Test Trainer',
  role: AppRole.trainer,
);

final _fakeUpcomingBooking = Booking(
  id: 'b1',
  trainerUid: 'trainer-1',
  clientUid: 'client-1',
  date: '2027-01-15',
  start: '10:00',
  end: '11:00',
  status: 'booked',
);

final _fakeHistoryBooking = Booking(
  id: 'b2',
  trainerUid: 'trainer-1',
  clientUid: 'client-1',
  date: '2026-06-01',
  start: '09:00',
  end: '10:00',
  status: 'cancelled',
);

// ─── Tests ───────────────────────────────────────────────────────────────────

void main() {
  // ── AS-030: Client upcoming bookings ──────────────────────────────────────

  group('AS-030 MyBookingsScreen upcoming', () {
    testWidgets(
      'AS-030: shows upcoming booking time when client has one',
      (tester) async {
        await tester.pumpWidget(
          ProviderScope(
            overrides: [
              appUserProvider
                  .overrideWith((ref) => Stream.value(_fakeClient)),
              clientUpcomingBookingsProvider('client-1')
                  .overrideWith((ref) => Stream.value([_fakeUpcomingBooking])),
              clientBookingHistoryProvider('client-1')
                  .overrideWith((ref) => Stream.value([])),
              trainerProvider('trainer-1')
                  .overrideWith((ref) => Stream.value(null)),
            ],
            child: _testApp(const MyBookingsScreen()),
          ),
        );
        await tester.pumpAndSettle();

        // Upcoming tab is selected by default; booking row shows time range.
        expect(find.text('10:00–11:00'), findsOneWidget);
      },
    );

    testWidgets(
      'AS-030: shows empty-state text when client has no upcoming bookings',
      (tester) async {
        await tester.pumpWidget(
          ProviderScope(
            overrides: [
              appUserProvider
                  .overrideWith((ref) => Stream.value(_fakeClient)),
              clientUpcomingBookingsProvider('client-1')
                  .overrideWith((ref) => Stream.value([])),
              clientBookingHistoryProvider('client-1')
                  .overrideWith((ref) => Stream.value([])),
            ],
            child: _testApp(const MyBookingsScreen()),
          ),
        );
        await tester.pumpAndSettle();

        expect(find.text('You have no upcoming bookings.'), findsOneWidget);
      },
    );
  });

  // ── AS-031: Client booking history ────────────────────────────────────────

  group('AS-031 MyBookingsScreen history', () {
    testWidgets(
      'AS-031: history tab shows cancelled booking time range',
      (tester) async {
        await tester.pumpWidget(
          ProviderScope(
            overrides: [
              appUserProvider
                  .overrideWith((ref) => Stream.value(_fakeClient)),
              clientUpcomingBookingsProvider('client-1')
                  .overrideWith((ref) => Stream.value([])),
              clientBookingHistoryProvider('client-1')
                  .overrideWith(
                      (ref) => Stream.value([_fakeHistoryBooking])),
              trainerProvider('trainer-1')
                  .overrideWith((ref) => Stream.value(null)),
            ],
            child: _testApp(const MyBookingsScreen()),
          ),
        );
        await tester.pumpAndSettle();

        // Tap the History tab.
        await tester.tap(find.text('HISTORY'));
        await tester.pumpAndSettle();

        expect(find.text('09:00–10:00'), findsOneWidget);
      },
    );

    testWidgets(
      'AS-031: shows empty history text when client has no past bookings',
      (tester) async {
        await tester.pumpWidget(
          ProviderScope(
            overrides: [
              appUserProvider
                  .overrideWith((ref) => Stream.value(_fakeClient)),
              clientUpcomingBookingsProvider('client-1')
                  .overrideWith((ref) => Stream.value([])),
              clientBookingHistoryProvider('client-1')
                  .overrideWith((ref) => Stream.value([])),
            ],
            child: _testApp(const MyBookingsScreen()),
          ),
        );
        await tester.pumpAndSettle();

        await tester.tap(find.text('HISTORY'));
        await tester.pumpAndSettle();

        expect(find.text('No booking history.'), findsOneWidget);
      },
    );
  });

  // ── AS-033: Trainer sessions ───────────────────────────────────────────────

  group('AS-033 TrainerSessionsScreen', () {
    testWidgets(
      'AS-033: trainer sees booked session time',
      (tester) async {
        final session = Booking(
          id: 's1',
          trainerUid: 'trainer-1',
          clientUid: 'client-abc',
          date: '2027-01-15',
          start: '14:00',
          end: '15:00',
          status: 'booked',
        );

        await tester.pumpWidget(
          ProviderScope(
            overrides: [
              appUserProvider
                  .overrideWith((ref) => Stream.value(_fakeTrainer)),
              trainerSessionsProvider('trainer-1')
                  .overrideWith((ref) => Stream.value([session])),
            ],
            child: _testApp(const TrainerSessionsScreen()),
          ),
        );
        await tester.pumpAndSettle();

        expect(find.text('14:00–15:00'), findsOneWidget);
      },
    );

    testWidgets(
      'AS-033: shows empty-state text when trainer has no sessions',
      (tester) async {
        await tester.pumpWidget(
          ProviderScope(
            overrides: [
              appUserProvider
                  .overrideWith((ref) => Stream.value(_fakeTrainer)),
              trainerSessionsProvider('trainer-1')
                  .overrideWith((ref) => Stream.value([])),
            ],
            child: _testApp(const TrainerSessionsScreen()),
          ),
        );
        await tester.pumpAndSettle();

        expect(find.text('No sessions scheduled.'), findsOneWidget);
      },
    );

    testWidgets(
      'AS-033: non-trainer user sees not-authorized message',
      (tester) async {
        await tester.pumpWidget(
          ProviderScope(
            overrides: [
              appUserProvider
                  .overrideWith((ref) => Stream.value(_fakeClient)),
            ],
            child: _testApp(const TrainerSessionsScreen()),
          ),
        );
        await tester.pumpAndSettle();

        expect(
          find.text("You don't have access to this page."),
          findsOneWidget,
        );
      },
    );
  });

  // ── AS-027 / AS-028 / AS-029: booking exception types ────────────────────

  group('AS-027 AS-028 AS-029 booking exception types', () {
    test(
      'AS-028: SlotTakenException and PastSlotException are separate types',
      () {
        final Object e1 = const SlotTakenException();
        final Object e2 = const PastSlotException();
        // Each exception matches only its own type, not the other.
        expect(e1 is SlotTakenException, isTrue);
        expect(e1 is PastSlotException, isFalse);
        expect(e2 is PastSlotException, isTrue);
        expect(e2 is SlotTakenException, isFalse);
      },
    );

    test(
      'AS-029: PastSlotException implements Exception',
      () {
        final Object e = const PastSlotException();
        expect(e, isA<Exception>());
      },
    );

    test(
      'AS-027: SlotTakenException implements Exception',
      () {
        final Object e = const SlotTakenException();
        expect(e, isA<Exception>());
      },
    );
  });
}
