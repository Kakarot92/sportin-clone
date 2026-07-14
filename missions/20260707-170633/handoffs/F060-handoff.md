# Handoff: F060 — M7 Group Classes data + logic layer

## Status
COMPLETE

## Assertions covered
AS-041: PASS — GroupClass domain model created; createClass() persists to Firestore with joinedCount=0
AS-042: PASS — joinClass() transaction adds participant doc and increments joinedCount
AS-043: PASS — joinClass() throws ClassFullException when joined >= capacity (inside transaction)
AS-044: PASS — joinClass increments / leaveClass decrements joinedCount atomically; remainingSpots computed correctly
AS-045: PASS — leaveClass() calls isPastCutoff(classStart, now); throws CutoffPassedException if class started
AS-046: PASS — joinClass() checks participant doc existence inside transaction; throws AlreadyJoinedException if already joined

## Files changed
lib/features/group_classes/domain/group_class.dart
lib/features/group_classes/domain/group_class_exceptions.dart
lib/features/group_classes/data/group_class_repository.dart
lib/features/group_classes/application/group_class_providers.dart
firestore.rules
firestore.indexes.json
lib/l10n/app_en.arb
lib/l10n/app_sr.arb
lib/l10n/app_localizations.dart
lib/l10n/app_localizations_en.dart
lib/l10n/app_localizations_sr.dart
test/group_classes_test.dart

## Commands run
`flutter pub get` (0)
`flutter gen-l10n` (0)
`dart analyze lib test` (0) — "No issues found!"
`flutter test` (0) — "91 tests passed" (83 existing + 8 new)
`git commit` (0)

## Decisions made
- Reused `CutoffPassedException` from `booking/domain/booking_exceptions.dart` for the "class already started, cannot leave" case (AS-045) — same semantic meaning, avoids a duplicate near-identical exception type as specified.
- Reused `isPastCutoff` and `bookingSlotStart` from `booking_policy.dart` directly — these are generic pure functions not tied to the `Booking` type.
- Reused `ymd()` from `scheduling/domain/date_utils.dart` for today's date in the `watchUpcomingClasses()` query.
- Reused `firestoreProvider` from `auth/application/auth_providers.dart` — no new provider created.
- `createClass()` always sets `joinedCount: 0` and ignores any value passed in `gc`, and lets Firestore auto-generate the document ID.
- `leaveClass()` is idempotent: if the participant doc does not exist, the transaction is a no-op (defensive, since the UI should already gate this path).
- Two composite indexes added to `firestore.indexes.json` for the `watchUpcomingClasses` and `watchTrainerClasses` queries (date+start, and trainerUid+date+start).
- Firestore rules added before the catch-all `/{document=**}` block, scoped narrowly so clients can only touch `joinedCount` via `affectedKeys().hasOnly(['joinedCount'])`.
- `spotsLeft` l10n key uses `{n}` with `type: int` placeholders metadata matching the existing `unlimitedUntil` pattern in both ARB files.
- Generated l10n files (`app_localizations*.dart`) included in commit since `flutter gen-l10n` was run and they are checked into the repo.

## Out-of-scope work needed
- UI screens for group classes (listing, create form, join/leave actions) — a second worker handles that (F061 or similar).
- Firestore rules and indexes deployment — orchestrator deploys after commit.
- Trainer-cancel of a group class (removing all participants, refunding, etc.) is not specified in AS-041–046 and was not implemented.

## Blockers
(none)

## Autonomous decisions
AUTONOMOUS_DECISION: Included generated l10n dart files (app_localizations*.dart) in the commit because they are tracked in the repo and running flutter gen-l10n modified them — omitting them would leave the repo in a dirty/inconsistent state.

## Notes for the next worker
- The `GroupClass` const constructor enables use in const contexts (tests, mock data).
- The `isJoinedProvider` family parameter is a named record `({String classId, String clientUid})` — callers must pass `(classId: '...', clientUid: '...')` (named fields, not positional).
- `groupClassControllerProvider` follows the exact same `AsyncNotifier<void>` / `AsyncValue.guard` pattern as `bookingControllerProvider` — the UI layer can mirror the booking UI patterns.
- No Firebase emulator was used; all logic is pure-Dart model/domain code testable without Firebase.
