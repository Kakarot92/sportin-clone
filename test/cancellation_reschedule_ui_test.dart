// ignore_for_file: lines_longer_than_80_chars
//
// UI tests for cancellation/reschedule feature (F052).
//
// Assertions covered:
//   AS-035  Client can cancel an upcoming booked session from My Bookings.
//   AS-036  Cancellation is blocked (button hidden / error shown) past cutoff.
//   AS-039  Client can reschedule a booking by navigating to the slot browser.
//   AS-040  Trainer can cancel a booked session from Trainer Sessions.

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sportin_clone/app/theme.dart';
import 'package:sportin_clone/core/models/app_user.dart';
import 'package:sportin_clone/core/models/trainer_profile.dart';
import 'package:sportin_clone/features/auth/application/auth_providers.dart';
import 'package:sportin_clone/features/booking/application/booking_providers.dart';
import 'package:sportin_clone/features/booking/domain/booking_exceptions.dart';
import 'package:sportin_clone/features/booking/presentation/my_bookings_screen.dart';
import 'package:sportin_clone/features/booking/presentation/trainer_sessions_screen.dart';
import 'package:sportin_clone/features/scheduling/application/scheduling_providers.dart';
import 'package:sportin_clone/features/scheduling/domain/booking.dart';
import 'package:sportin_clone/features/scheduling/domain/slot.dart';
import 'package:sportin_clone/features/scheduling/presentation/trainer_slots_screen.dart';
import 'package:sportin_clone/features/trainers/application/trainers_providers.dart';
import 'package:sportin_clone/l10n/app_localizations.dart';

// ─── Helpers ─────────────────────────────────────────────────────────────────

Widget _testApp(Widget child) => MaterialApp(
      theme: buildDarkTheme(),
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

const _fakeTrainerProfile = TrainerProfile(
  uid: 'trainer-1',
  displayName: 'Trainer Name',
);

/// A booking far in the future — session has not yet started, so it is
/// cancellable/reschedulable under the 0-hour cutoff policy.
final _cancellableBooking = Booking(
  id: 'b-cancel',
  trainerUid: 'trainer-1',
  clientUid: 'client-1',
  date: '2027-01-15',
  start: '10:00',
  end: '11:00',
  status: 'booked',
);

/// A booking in the distant past — session has already started/passed,
/// so cancellation is blocked. Injected via the upcoming override to
/// test that the button is hidden.
final _pastCutoffBooking = Booking(
  id: 'b-past',
  trainerUid: 'trainer-1',
  clientUid: 'client-1',
  date: '2020-01-01',
  start: '09:00',
  end: '10:00',
  status: 'booked',
);

// ─── Fake controllers ─────────────────────────────────────────────────────────

/// Fake that returns success on cancel().
class _OkCancelController extends BookingController {
  @override
  Future<bool> cancel(Booking booking) async {
    state = const AsyncData(null);
    return true;
  }
}

/// Fake that returns CutoffPassedException on cancel().
class _CutoffCancelController extends BookingController {
  @override
  Future<bool> cancel(Booking booking) async {
    // Yield one microtask so that the provider's build() future completes
    // first and its AsyncData(null) result is written before we overwrite
    // with AsyncError.  Without this, the build microtask fires after our
    // return and silently resets the error to AsyncData (AS-036).
    await Future<void>.value();
    state = AsyncError(const CutoffPassedException(), StackTrace.empty);
    return false;
  }
}

/// Fake that returns success on reschedule().
class _OkRescheduleController extends BookingController {
  @override
  Future<bool> reschedule({
    required Booking oldBooking,
    required Slot newSlot,
  }) async {
    state = const AsyncData(null);
    return true;
  }
}

/// Fake that returns SlotTakenException on reschedule().
class _SlotTakenRescheduleController extends BookingController {
  @override
  Future<bool> reschedule({
    required Booking oldBooking,
    required Slot newSlot,
  }) async {
    // Yield one microtask so that the provider's build() future completes
    // first and its AsyncData(null) result is written before we overwrite
    // with AsyncError.  Without this, the build microtask fires after our
    // return and silently resets the error to AsyncData (AS-039).
    await Future<void>.value();
    state = AsyncError(const SlotTakenException(), StackTrace.empty);
    return false;
  }
}

// ─── Tests ───────────────────────────────────────────────────────────────────

void main() {
  // ── AS-035: Client cancel action ─────────────────────────────────────────

  group('AS-035 client cancel booking', () {
    testWidgets(
      'AS-035: cancel action button is visible on a cancellable upcoming booking card',
      (tester) async {
        await tester.pumpWidget(
          ProviderScope(
            overrides: [
              appUserProvider.overrideWith((ref) => Stream.value(_fakeClient)),
              clientUpcomingBookingsProvider('client-1')
                  .overrideWith((ref) => Stream.value([_cancellableBooking])),
              clientBookingHistoryProvider('client-1')
                  .overrideWith((ref) => Stream.value([])),
              trainerProvider('trainer-1')
                  .overrideWith((ref) => Stream.value(_fakeTrainerProfile)),
            ],
            child: _testApp(const MyBookingsScreen()),
          ),
        );
        await tester.pumpAndSettle();

        // "Cancel session" button rendered on the upcoming card (AS-035).
        expect(find.text('Cancel session'), findsOneWidget);
      },
    );

    testWidgets(
      'AS-035: cancel confirm dialog shows the session start time',
      (tester) async {
        await tester.pumpWidget(
          ProviderScope(
            overrides: [
              appUserProvider.overrideWith((ref) => Stream.value(_fakeClient)),
              clientUpcomingBookingsProvider('client-1')
                  .overrideWith((ref) => Stream.value([_cancellableBooking])),
              clientBookingHistoryProvider('client-1')
                  .overrideWith((ref) => Stream.value([])),
              trainerProvider('trainer-1')
                  .overrideWith((ref) => Stream.value(null)),
            ],
            child: _testApp(const MyBookingsScreen()),
          ),
        );
        await tester.pumpAndSettle();

        await tester.tap(find.text('Cancel session'));
        await tester.pumpAndSettle();

        // Dialog title shown (AS-035).
        expect(find.text('Cancel session'), findsWidgets);
        // Dialog body contains the session start time.
        expect(find.textContaining('10:00'), findsAtLeastNWidgets(1));
      },
    );

    testWidgets(
      'AS-035: confirming cancel shows the cancel-success snackbar',
      (tester) async {
        await tester.pumpWidget(
          ProviderScope(
            overrides: [
              appUserProvider.overrideWith((ref) => Stream.value(_fakeClient)),
              clientUpcomingBookingsProvider('client-1')
                  .overrideWith((ref) => Stream.value([_cancellableBooking])),
              clientBookingHistoryProvider('client-1')
                  .overrideWith((ref) => Stream.value([])),
              trainerProvider('trainer-1')
                  .overrideWith((ref) => Stream.value(null)),
              bookingControllerProvider
                  .overrideWith(() => _OkCancelController()),
            ],
            child: _testApp(const MyBookingsScreen()),
          ),
        );
        await tester.pumpAndSettle();

        // Open the cancel dialog.
        await tester.tap(find.text('Cancel session'));
        await tester.pumpAndSettle();

        // Tap the confirm FilledButton inside the dialog (AS-035).
        await tester.tap(find.widgetWithText(FilledButton, 'Cancel session'));
        await tester.pumpAndSettle();

        // Success snackbar shown (AS-035).
        expect(find.text('Session cancelled.'), findsOneWidget);
      },
    );
  });

  // ── AS-036: Cancellation cutoff enforcement ───────────────────────────────

  group('AS-036 cancellation cutoff enforcement', () {
    testWidgets(
      'AS-036: cancel button is absent when the booking is past the cutoff',
      (tester) async {
        await tester.pumpWidget(
          ProviderScope(
            overrides: [
              appUserProvider.overrideWith((ref) => Stream.value(_fakeClient)),
              // Feed the past-cutoff booking into the upcoming list to
              // verify the UI hides the button when canCancelBooking() is
              // false regardless of list source (AS-036).
              clientUpcomingBookingsProvider('client-1')
                  .overrideWith((ref) => Stream.value([_pastCutoffBooking])),
              clientBookingHistoryProvider('client-1')
                  .overrideWith((ref) => Stream.value([])),
              trainerProvider('trainer-1')
                  .overrideWith((ref) => Stream.value(null)),
            ],
            child: _testApp(const MyBookingsScreen()),
          ),
        );
        await tester.pumpAndSettle();

        // Booking card is shown (the time range is visible).
        expect(find.text('09:00–10:00'), findsOneWidget);
        // Cancel button is NOT shown (AS-036).
        expect(find.text('Cancel session'), findsNothing);
      },
    );

    testWidgets(
      'AS-036: CutoffPassedException shows the cutoff-error snackbar',
      (tester) async {
        await tester.pumpWidget(
          ProviderScope(
            overrides: [
              appUserProvider.overrideWith((ref) => Stream.value(_fakeClient)),
              clientUpcomingBookingsProvider('client-1')
                  .overrideWith((ref) => Stream.value([_cancellableBooking])),
              clientBookingHistoryProvider('client-1')
                  .overrideWith((ref) => Stream.value([])),
              trainerProvider('trainer-1')
                  .overrideWith((ref) => Stream.value(null)),
              bookingControllerProvider
                  .overrideWith(() => _CutoffCancelController()),
            ],
            child: _testApp(const MyBookingsScreen()),
          ),
        );
        await tester.pumpAndSettle();

        await tester.tap(find.text('Cancel session'));
        await tester.pumpAndSettle();

        await tester.tap(find.widgetWithText(FilledButton, 'Cancel session'));
        // pumpAndSettle lets the dialog close animation play and the async
        // chain in _cancel() fully resolve before the assertion. The total
        // settling time (~300–400 ms fake clock) is well under the SnackBar's
        // 4-second auto-dismiss, so pumpAndSettle exits while the SnackBar is
        // still visible (AS-036).
        await tester.pumpAndSettle();

        // Cutoff-specific error shown — must mention the session has
        // already started (AS-036, new 0-hour policy message).
        expect(
          find.textContaining('already started'),
          findsOneWidget,
          reason: 'Tree texts: ${tester.widgetList<Text>(find.byType(Text)).map((t) => t.data ?? t.textSpan?.toPlainText() ?? "<null>").join(" | ")}',
        );
      },
    );
  });

  // ── AS-039: Client reschedule ─────────────────────────────────────────────

  group('AS-039 client reschedule booking', () {
    testWidgets(
      'AS-039: reschedule action button is visible on a cancellable upcoming booking',
      (tester) async {
        await tester.pumpWidget(
          ProviderScope(
            overrides: [
              appUserProvider.overrideWith((ref) => Stream.value(_fakeClient)),
              clientUpcomingBookingsProvider('client-1')
                  .overrideWith((ref) => Stream.value([_cancellableBooking])),
              clientBookingHistoryProvider('client-1')
                  .overrideWith((ref) => Stream.value([])),
              trainerProvider('trainer-1')
                  .overrideWith((ref) => Stream.value(null)),
            ],
            child: _testApp(const MyBookingsScreen()),
          ),
        );
        await tester.pumpAndSettle();

        // "Reschedule" button visible on the card (AS-039).
        expect(find.text('Reschedule'), findsOneWidget);
      },
    );

    testWidgets(
      'AS-039: TrainerSlotsScreen shows reschedule eyebrow when rescheduling is set',
      (tester) async {
        final today = DateTime.now();
        final normalizedToday = DateTime(today.year, today.month, today.day);
        final testSlot = Slot(
          trainerUid: 'trainer-1',
          date: normalizedToday,
          start: '09:00',
          end: '10:00',
        );
        final slotKey = (trainerUid: 'trainer-1', day: normalizedToday);

        await tester.pumpWidget(
          ProviderScope(
            overrides: [
              trainerProvider('trainer-1')
                  .overrideWith((ref) => Stream.value(_fakeTrainerProfile)),
              availableSlotsProvider(slotKey)
                  .overrideWith((ref) => AsyncData([testSlot])),
            ],
            child: _testApp(
              TrainerSlotsScreen(
                trainerUid: 'trainer-1',
                rescheduling: _cancellableBooking,
              ),
            ),
          ),
        );
        await tester.pumpAndSettle();

        // Reschedule eyebrow visible in the header (AS-039 mode indicator).
        expect(find.text('RESCHEDULE'), findsAtLeastNWidgets(1));
      },
    );

    testWidgets(
      'AS-039: tapping a slot in reschedule mode shows the reschedule confirm dialog',
      (tester) async {
        final today = DateTime.now();
        final normalizedToday = DateTime(today.year, today.month, today.day);
        final testSlot = Slot(
          trainerUid: 'trainer-1',
          date: normalizedToday,
          start: '09:00',
          end: '10:00',
        );
        final slotKey = (trainerUid: 'trainer-1', day: normalizedToday);

        await tester.pumpWidget(
          ProviderScope(
            overrides: [
              trainerProvider('trainer-1')
                  .overrideWith((ref) => Stream.value(_fakeTrainerProfile)),
              availableSlotsProvider(slotKey)
                  .overrideWith((ref) => AsyncData([testSlot])),
            ],
            child: _testApp(
              TrainerSlotsScreen(
                trainerUid: 'trainer-1',
                rescheduling: _cancellableBooking,
              ),
            ),
          ),
        );
        await tester.pumpAndSettle();

        // Slot block is rendered.
        expect(find.text('09:00'), findsOneWidget);

        // Tap the slot → reschedule confirm dialog appears (AS-039).
        await tester.tap(find.text('09:00'));
        await tester.pumpAndSettle();

        // Dialog title is the reschedule title, not the booking title.
        expect(find.text('Reschedule session'), findsOneWidget);
        expect(find.text('Confirm booking'), findsNothing);
      },
    );

    testWidgets(
      'AS-039: confirming reschedule shows the rescheduled snackbar',
      (tester) async {
        final today = DateTime.now();
        final normalizedToday = DateTime(today.year, today.month, today.day);
        final testSlot = Slot(
          trainerUid: 'trainer-1',
          date: normalizedToday,
          start: '09:00',
          end: '10:00',
        );
        final slotKey = (trainerUid: 'trainer-1', day: normalizedToday);

        await tester.pumpWidget(
          ProviderScope(
            overrides: [
              trainerProvider('trainer-1')
                  .overrideWith((ref) => Stream.value(_fakeTrainerProfile)),
              availableSlotsProvider(slotKey)
                  .overrideWith((ref) => AsyncData([testSlot])),
              bookingControllerProvider
                  .overrideWith(() => _OkRescheduleController()),
            ],
            child: _testApp(
              TrainerSlotsScreen(
                trainerUid: 'trainer-1',
                rescheduling: _cancellableBooking,
              ),
            ),
          ),
        );
        await tester.pumpAndSettle();

        await tester.tap(find.text('09:00'));
        await tester.pumpAndSettle();

        // Confirm the reschedule.
        await tester.tap(find.widgetWithText(FilledButton, 'Reschedule'));
        await tester.pumpAndSettle();

        // Success snackbar shown (AS-039).
        expect(find.text('Session moved.'), findsOneWidget);
      },
    );

    testWidgets(
      'AS-039: SlotTakenException during reschedule shows the slot-taken error',
      (tester) async {
        final today = DateTime.now();
        final normalizedToday = DateTime(today.year, today.month, today.day);
        final testSlot = Slot(
          trainerUid: 'trainer-1',
          date: normalizedToday,
          start: '09:00',
          end: '10:00',
        );
        final slotKey = (trainerUid: 'trainer-1', day: normalizedToday);

        await tester.pumpWidget(
          ProviderScope(
            overrides: [
              trainerProvider('trainer-1')
                  .overrideWith((ref) => Stream.value(_fakeTrainerProfile)),
              availableSlotsProvider(slotKey)
                  .overrideWith((ref) => AsyncData([testSlot])),
              bookingControllerProvider
                  .overrideWith(() => _SlotTakenRescheduleController()),
            ],
            child: _testApp(
              TrainerSlotsScreen(
                trainerUid: 'trainer-1',
                rescheduling: _cancellableBooking,
              ),
            ),
          ),
        );
        await tester.pumpAndSettle();

        await tester.tap(find.text('09:00'));
        await tester.pumpAndSettle();

        await tester.tap(find.widgetWithText(FilledButton, 'Reschedule'));
        // pumpAndSettle lets the dialog close animation play and the async
        // chain in _rescheduleSlot() fully resolve before the assertion. The
        // total settling time (~300–400 ms fake clock) is well under the
        // SnackBar's 4-second auto-dismiss, so the SnackBar is still visible
        // when pumpAndSettle returns (AS-039).
        await tester.pumpAndSettle();

        expect(
          find.text('That slot was just taken.'),
          findsOneWidget,
          reason: 'Tree texts: ${tester.widgetList<Text>(find.byType(Text)).map((t) => t.data ?? t.textSpan?.toPlainText() ?? "<null>").join(" | ")}',
        );
      },
    );
  });

  // ── AS-040: Trainer cancel session ───────────────────────────────────────

  group('AS-040 trainer cancel session', () {
    testWidgets(
      'AS-040: cancel action button is visible on a booked trainer session within cutoff',
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
              appUserProvider.overrideWith((ref) => Stream.value(_fakeTrainer)),
              trainerSessionsProvider('trainer-1')
                  .overrideWith((ref) => Stream.value([session])),
            ],
            child: _testApp(const TrainerSessionsScreen()),
          ),
        );
        await tester.pumpAndSettle();

        // Cancel button is rendered on the session card (AS-040).
        expect(find.text('Cancel session'), findsOneWidget);
      },
    );

    testWidgets(
      'AS-040: cancel action button is absent on a booked session past cutoff',
      (tester) async {
        final pastSession = Booking(
          id: 's-past',
          trainerUid: 'trainer-1',
          clientUid: 'client-abc',
          date: '2020-01-01',
          start: '09:00',
          end: '10:00',
          status: 'booked',
        );

        await tester.pumpWidget(
          ProviderScope(
            overrides: [
              appUserProvider.overrideWith((ref) => Stream.value(_fakeTrainer)),
              trainerSessionsProvider('trainer-1')
                  .overrideWith((ref) => Stream.value([pastSession])),
            ],
            child: _testApp(const TrainerSessionsScreen()),
          ),
        );
        await tester.pumpAndSettle();

        expect(find.text('09:00–10:00'), findsOneWidget);
        // Cancel button NOT shown for past-cutoff session (AS-040).
        expect(find.text('Cancel session'), findsNothing);
      },
    );

    testWidgets(
      'AS-040: cancel button absent on an already-cancelled session',
      (tester) async {
        final cancelledSession = Booking(
          id: 's-cancelled',
          trainerUid: 'trainer-1',
          clientUid: 'client-abc',
          date: '2027-01-15',
          start: '14:00',
          end: '15:00',
          status: 'cancelled',
        );

        await tester.pumpWidget(
          ProviderScope(
            overrides: [
              appUserProvider.overrideWith((ref) => Stream.value(_fakeTrainer)),
              trainerSessionsProvider('trainer-1')
                  .overrideWith((ref) => Stream.value([cancelledSession])),
            ],
            child: _testApp(const TrainerSessionsScreen()),
          ),
        );
        await tester.pumpAndSettle();

        // Card shown.
        expect(find.text('14:00–15:00'), findsOneWidget);
        // No cancel button on already-cancelled session.
        expect(find.text('Cancel session'), findsNothing);
      },
    );

    testWidgets(
      'AS-040: trainer cancel confirm dialog shows the session start time',
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
              appUserProvider.overrideWith((ref) => Stream.value(_fakeTrainer)),
              trainerSessionsProvider('trainer-1')
                  .overrideWith((ref) => Stream.value([session])),
            ],
            child: _testApp(const TrainerSessionsScreen()),
          ),
        );
        await tester.pumpAndSettle();

        await tester.tap(find.text('Cancel session'));
        await tester.pumpAndSettle();

        // Dialog title appears (AS-040).
        expect(find.text('Cancel session'), findsWidgets);
        // Dialog body references the session time.
        expect(find.textContaining('14:00'), findsAtLeastNWidgets(1));
      },
    );

    testWidgets(
      'AS-040: confirming trainer cancel shows the cancel-success snackbar',
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
              appUserProvider.overrideWith((ref) => Stream.value(_fakeTrainer)),
              trainerSessionsProvider('trainer-1')
                  .overrideWith((ref) => Stream.value([session])),
              bookingControllerProvider
                  .overrideWith(() => _OkCancelController()),
            ],
            child: _testApp(const TrainerSessionsScreen()),
          ),
        );
        await tester.pumpAndSettle();

        await tester.tap(find.text('Cancel session'));
        await tester.pumpAndSettle();

        await tester.tap(find.widgetWithText(FilledButton, 'Cancel session'));
        await tester.pumpAndSettle();

        // Cancel-success snackbar shown after trainer cancels (AS-040).
        expect(find.text('Session cancelled.'), findsOneWidget);
      },
    );
  });
}
