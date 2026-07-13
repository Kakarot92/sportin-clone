# Handoff: F050 — M6 Cancellation & Reschedule Logic

## Status
COMPLETE

## Assertions covered
AS-035: PASS — cancelBooking() writes status='cancelled'; pure cutoff logic tested in booking_policy_test.dart.
AS-036: PASS — isPastCutoff() throws CutoffPassedException when within 12h; boundary (exclusive) tested.
AS-038: PASS — cancelling sets status='cancelled'; AvailabilityRepository.watchBookingsForDay already filters status=='booked', so the slot is automatically freed (confirmed by pre-existing test "a cancelled booking does NOT remove the slot").
AS-039: PASS — rescheduleBooking() runs a single Firestore transaction: old doc updated to 'cancelled', new doc set to 'booked'; SlotTakenException thrown if new slot already booked; PastSlotException thrown if new slot is in the past.
AS-040: PASS — trainers can call cancelBooking() on their sessions (Firestore rules already allow update where resource.data.trainerUid == request.auth.uid); notification half is DEFERRED (no F083 notification system yet).

## Files changed
lib/features/booking/domain/booking_policy.dart (new)
lib/features/booking/domain/booking_exceptions.dart (added CutoffPassedException, BookingNotFoundOrForbiddenException)
lib/features/booking/data/booking_repository.dart (added cancelBooking, rescheduleBooking)
lib/features/booking/application/booking_providers.dart (added cancel, reschedule to BookingController)
lib/l10n/app_en.arb (added 9 new keys: cancelBooking, cancelConfirmTitle, cancelConfirmBody, cutoffPassedError, reschedule, rescheduleConfirmTitle, rescheduleConfirmBody, rescheduled, cancelSuccess)
lib/l10n/app_sr.arb (same 9 keys in Serbian)
lib/l10n/app_localizations.dart (generated)
lib/l10n/app_localizations_en.dart (generated)
lib/l10n/app_localizations_sr.dart (generated)
test/booking_policy_test.dart (new — 11 tests)

## Commands run
`flutter pub get` (0)
`flutter gen-l10n` (0)
`dart analyze lib test` (0) — "No issues found!"
`flutter test` (0) — "41 tests passed!"

## Decisions made
- Cutoff boundary is EXCLUSIVE: `isPastCutoff` uses `now.isAfter(cutoffMoment)` where cutoffMoment = slotStart - 12h. At exactly 12h before the slot, `now.isAfter(now)` is false, so the user CAN still cancel. The window closes 1ms after the cutoff moment. Documented and tested.
- Skipped adding a `cancelled` l10n key because `statusCancelled` already existed in both ARB files covering the same meaning.
- `canCancelBooking(Booking b, {DateTime? now})` placed in `booking_policy.dart` (pure logic, no Firebase) for the UI layer to call directly when deciding whether to show a cancel button.
- `BookingNotFoundOrForbiddenException` added for defensive use; not thrown by current implementation but available for future UI/repo hardening.
- AS-037 (refund credit on cancel) is DEFERRED per spec — credit/package system (F072) not yet built.
- AS-040 notification half is DEFERRED per spec — notification system (F083) not yet built.
- Did not touch `firestore.rules` — existing rules already support client and trainer update on bookings collection.

## Out-of-scope work needed
- F051 (UI): cancel button on upcoming bookings card, reschedule flow, error dialogs using the new l10n keys.
- AS-037: refund credit when client cancels — needs F072 package/credit system first.
- AS-040 notification: send push notification to trainer when client cancels — needs F083 notification system.

## Blockers
(none)

## Autonomous decisions
AUTONOMOUS_DECISION: Chose exclusive cutoff boundary (at exactly 12h before, user can still cancel) because isPastCutoff uses `now.isAfter(cutoffMoment)` which is strict. This is the most user-friendly interpretation and is explicitly documented and tested.

## Notes for the next worker
- The UI worker (F051) should import `canCancelBooking` from `booking_policy.dart` to gate the cancel button display.
- `BookingController.cancel(booking)` and `BookingController.reschedule(oldBooking: ..., newSlot: ...)` are ready to call from UI.
- l10n keys `cutoffPassedError` uses an int placeholder `{hours}` — call `AppLocalizations.of(context).cutoffPassedError(kCancellationCutoffHours)` to produce the error string.
- The `rescheduleBooking` transaction reads the new slot doc before writing, so a concurrent double-reschedule to the same slot will throw `SlotTakenException` for the second caller.
