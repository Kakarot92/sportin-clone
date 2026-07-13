# Handoff: F040 — M5 Booking Logic Layer

## Status
COMPLETE

## Assertions covered
AS-027: PASS — Booking creation uses a Firestore transaction with a deterministic doc ID; a successful write produces a 'booked' document.
AS-028: PASS — Transaction reads the target doc first; throws SlotTakenException (caught in controller) if status == 'booked', preventing double-book.
AS-029: PASS — createBooking parses the slot DateTime and calls isPastSlot(); throws PastSlotException before the transaction if the slot is in the past.

## Files changed
lib/features/booking/domain/booking_exceptions.dart
lib/features/booking/data/booking_repository.dart
lib/features/booking/application/booking_providers.dart
lib/features/scheduling/domain/booking.dart
lib/l10n/app_en.arb
lib/l10n/app_sr.arb
lib/l10n/app_localizations.dart
lib/l10n/app_localizations_en.dart
lib/l10n/app_localizations_sr.dart
firestore.rules
test/booking_logic_test.dart

## Commands run
`flutter pub get` (0)
`flutter gen-l10n` (0)
`dart analyze lib test` (0) — "No issues found!"
`flutter test` (0) — "20 tests passed"

## Decisions made
- `bookingDocId` added as a static method on `Booking` (the domain model) rather than in the repository, making it accessible to tests without needing Firebase.
- `isPastSlot(DateTime slotStart, DateTime now)` placed in `lib/features/booking/domain/booking_exceptions.dart` alongside `PastSlotException`/`SlotTakenException` since all three are closely related booking-domain concepts.
- `watchClientHistory` uses a single Firestore query (clientUid==, orderBy date desc) and filters `date < todayYmd OR status=='cancelled'` in Dart rather than running two Firestore queries. This avoids needing a composite index for an OR pattern and keeps the implementation simple; documented in code comments.
- Firestore rules for the `bookings/{id}` block replaced exactly as specified: create (client, status==booked), update (client/trainer/admin), delete (admin only). The existing `allow read: if isSignedIn()` is preserved.
- Generated l10n files (app_localizations*.dart) committed alongside the arb sources since they are checked into this repo (no CI generation step observed).
- `bookConfirmBody` uses ICU placeholders `{time}` and `{trainer}` with the standard ARB `@`-metadata block (type: String for both).
- Credits/packages gates (AS-032, AS-034, AS-054) intentionally NOT implemented per scope limit.

## Out-of-scope work needed
- UI screens for booking (F041 — separate worker): needs `bookingControllerProvider`, `clientUpcomingBookingsProvider`, `clientBookingHistoryProvider`, `trainerSessionsProvider`, l10n keys `book`, `bookConfirmTitle`, `bookConfirmBody`, `slotTakenError`, `pastSlotError`, `myBookings`, `upcoming`, `history`, `mySessions`, `noUpcomingBookings`, `noBookingHistory`, `noSessions`, `statusBooked`, `statusCancelled` (all now available).
- Cancellation logic: no `cancelBooking` method was implemented; the Firestore update rule allows the client/trainer to update a booking, but a service method + UI for cancellation are deferred.
- Composite Firestore indexes: `watchClientUpcoming` (clientUid + status + date + start) and `watchTrainerSessions` (trainerUid + date + start) will need composite indexes deployed via `firestore.indexes.json` for production. The orchestrator or a follow-up worker should add them.
- Firestore rules deployment: not deployed — orchestrator handles `firebase deploy --only firestore:rules`.

## Blockers
(none)

## Autonomous decisions
AUTONOMOUS_DECISION: Placed `isPastSlot` in `booking_exceptions.dart` rather than a separate `booking_utils.dart` because the spec said "(in domain)" without specifying a file, and the function is tightly coupled to `PastSlotException`.

AUTONOMOUS_DECISION: Committed generated l10n output files (`app_localizations*.dart`) because the repo already contains them (observed in prior commits) and no CI generation pipeline was detected.

## Notes for the next worker
- The booking feature lives under `lib/features/booking/` (domain, data, application layers). No `presentation/` layer was created — that's for the UI worker.
- `Booking.bookingDocId` and `isPastSlot` are pure functions with no Firebase deps — use them directly in tests.
- The `SlotTakenException` and `PastSlotException` have `const` constructors; the `BookingController` surfaces them via `state.error` after a failed `book()` call.
- `trainerSessionsProvider` uses `trainerUid` as the family param (String) and returns ALL bookings (booked + cancelled) ordered by date/start — so the trainer can see their full session list.
- `clientUpcomingBookingsProvider` and `clientBookingHistoryProvider` recompute `todayYmd = ymd(DateTime.now())` each time they are built; this is acceptable since providers rebuild when invalidated.
