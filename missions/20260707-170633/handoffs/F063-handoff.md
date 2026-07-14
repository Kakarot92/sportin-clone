# Handoff: F063 — M7 Group Classes UI

## Status
COMPLETE

## Assertions covered
AS-041: PASS — TrainerGroupClassesScreen shows creation form; notAuthorized guard; own class list with roster count; classCreated snackbar on success
AS-042: PASS — Join button visible on open class cards when not joined; joinedSuccess snackbar on tap
AS-043: PASS — classFull badge shown and join button absent on full classes; classFullError snackbar on ClassFullException
AS-044: PASS — spotsLeft(n) label rendered correctly with remainingSpots value from GroupClass
AS-045: PASS — Leave button visible when isJoined=true; confirm dialog shown; leftSuccess snackbar after confirm
AS-046: PASS — Join button absent and Leave shown when already joined; alreadyJoinedError snackbar on AlreadyJoinedException

## Files changed
lib/features/group_classes/presentation/group_classes_screen.dart (new)
lib/features/group_classes/presentation/trainer_group_classes_screen.dart (new)
lib/app/router.dart (added `/schedule/group-classes` and `/profile/group-classes` routes)
lib/features/trainers/presentation/trainer_directory_screen.dart (added group-classes entry point button below header)
lib/features/profile/presentation/profile_screen.dart (added trainer-only myGroupClasses OutlinedButton.icon entry)
test/group_classes_ui_test.dart (new — 16 tests)

## Commands run
`dart analyze lib test` (0) — no issues
`flutter test --no-pub` (0) — 107 tests passed (91 pre-existing + 16 new)
`git add ...` followed by `git commit` (0)

## Decisions made
- Mirrored `_BookingCard`/`_BookingCardState` ConsumerStatefulWidget pattern for `_GroupClassCard` to ensure safe `mounted`/`ScaffoldMessenger`-before-await handling.
- Used `find.textContaining(..., skipOffstage: false)` in trainer-screen tests because the class list renders below the creation form which exceeds the test viewport; the ListView(children:[]) mounts all widgets regardless.
- Used `find.byType(FilledButton)` to confirm the leave dialog rather than `find.text('Leave')` because the AlertDialog title and confirm button both carry the same l10n string.
- Adjusted trainer-card stagger indexes from `2 + i` to `3 + i` in `trainer_directory_screen.dart` after inserting the group-classes button at index 2.
- Reused `bookingSlotStart` from `booking_policy.dart` to build the `classStart` DateTime for `leave()`, exactly as spec instructed.
- Date formatting always uses `DateFormat.yMMMEd('sr_Latn')` (never bare `'sr'`) to match the Cyrillic-bug fix already applied throughout the app.
- The `_formatTime(TimeOfDay)` helper uses the same zero-padded "HH:mm" pattern from `availability_editor_screen.dart`.

## Out-of-scope work needed
- No delete/edit action for trainer's own classes (spec is read-only roster count for now).
- No group-class-specific chat room (AS-071 is in a separate feature).
- Trainer cannot cancel a group class from this screen (not in this feature scope).

## Blockers
(none)

## Autonomous decisions
AUTONOMOUS_DECISION: The leave confirm dialog uses the same l10n.leaveClass string for both the title and the confirm button, matching the "plain confirm" pattern described in the spec ("a plain confirm with l10n.leaveClass / l10n.cancel actions is fine, no new l10n key strictly required"). No new l10n key was added.

## Notes for the next worker
- All l10n keys for group classes were already present in both `app_en.arb` and `app_sr.arb` from a prior feature. No `flutter gen-l10n` was needed.
- The `GroupClassController.build()` returns `Future<void>` with a microtask before writing error state in fakes — this is needed to prevent the build microtask from resetting state after a synchronous error set (same pattern as cancellation_reschedule_ui_test.dart's fake controllers).
- No MCP tools were used (pure UI feature, no live Firestore schema inspection needed).
