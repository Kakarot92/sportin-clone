# Handoff: F044 — M5 Booking UI

## Status
COMPLETE

## Assertions covered
AS-027: PASS — Slot chip in TrainerSlotsScreen now shows confirm dialog then calls BookingController.book(); success shows "Booked" snackbar.
AS-028: PASS — SlotTakenException maps to l10n.slotTakenError in error snackbar; type-distinctness verified in booking_ui_test.dart.
AS-029: PASS — PastSlotException maps to l10n.pastSlotError in error snackbar; isPastSlot unit tests already pass in booking_logic_test.dart.
AS-030: PASS — MyBookingsScreen Upcoming tab watches clientUpcomingBookingsProvider; empty-state and row tests pass.
AS-031: PASS — MyBookingsScreen History tab watches clientBookingHistoryProvider; empty-state and row tests pass.
AS-033: PASS — TrainerSessionsScreen watches trainerSessionsProvider; trainer guard, empty-state and row tests pass.

## Files changed
lib/features/scheduling/presentation/trainer_slots_screen.dart
lib/features/booking/presentation/my_bookings_screen.dart
lib/features/booking/presentation/trainer_sessions_screen.dart
lib/app/router.dart
lib/features/profile/presentation/profile_screen.dart
lib/features/home/presentation/home_screen.dart
test/booking_ui_test.dart

## Commands run
`dart analyze lib test` (0) — No issues found
`flutter test` (0) — 30 tests passed

## Decisions made
- `trainer_slots_screen.dart` was already a `ConsumerStatefulWidget`; added imports for booking providers/exceptions, watched `trainerProvider` for trainer name in confirm dialog body.
- `my_bookings_screen.dart` uses `DefaultTabController` / `TabBar` / `TabBarView` with two tabs (Upcoming, History). Header (Eyebrow + DisplayTitle) lives above the `Expanded(TabBarView)` so it doesn't scroll away.
- `trainer_sessions_screen.dart` shows client UID truncated to 8 chars (no separate name lookup needed per spec).
- `_NextTrainingCard` in home_screen.dart converted from `StatelessWidget` to `ConsumerWidget`; when no upcoming booking it shows the original empty state with the VoltButton; when there is one it shows date/time/trainer name and tapping pushes `/profile/bookings`.
- Booking confirmation dialog uses `FilledButton` for the confirm action and `TextButton` for cancel, matching the project's dialog pattern from profile_screen.dart.
- `Override` is not exported from `flutter_riverpod` 3.3.2 (only specific symbols are re-exported). Test helper avoids naming the type — each test wraps with `ProviderScope` directly using list literals whose type is inferred.
- `VoltBadge(filled: false)` used for cancelled status (shows volt-outline treatment vs filled volt for booked).

## Out-of-scope work needed
- Cancellation action from client or trainer side (no cancel button implemented; the spec did not request it for this feature).
- Credits/payment integration is deferred per mission decisions.
- Push notifications for booking confirmation are out of scope.

## Blockers
(none)

## Autonomous decisions
AUTONOMOUS_DECISION: Trainer name in TrainerSessionsScreen row shown as clientUid substring — spec says "you may show booking.clientUid shortened, or just date/time"; chose shortened uid since no client-name lookup provider exists in scope.

## Notes for the next worker
- All l10n keys (book, bookConfirmTitle, bookConfirmBody, booked, slotTakenError, pastSlotError, myBookings, upcoming, history, mySessions, noUpcomingBookings, noBookingHistory, noSessions, statusBooked, statusCancelled) were already present in both app_en.arb and app_sr.arb and pre-generated — no `flutter gen-l10n` run was needed.
- `flutter_riverpod` 3.3.2 only exports a named allowlist of symbols; `Override` is not in it. Use list literals (type inferred) for ProviderScope overrides in tests.
- The booking logic layer (booking_providers.dart, booking_repository.dart, booking_exceptions.dart) was not touched.
