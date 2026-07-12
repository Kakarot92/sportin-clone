# Handoff: F034 — M4 Scheduling UI

## Status
COMPLETE

## Assertions covered
AS-020: PASS — AvailabilityEditorScreen lets a trainer define weekly time ranges per weekday and save via saveTemplate
AS-021: PASS — Same screen loads existing template into local state; edits (add/remove ranges, change slotMinutes) are reflected in a save call
AS-022: PASS — Exceptions section in AvailabilityEditorScreen lets trainer add/remove one-off date blocks (all-day or time-range) via addException/removeException
AS-023: PASS — TrainerSlotsScreen watches availableSlotsProvider and shows only computed available slots for the selected day; tapping a slot shows "booking coming soon" SnackBar
AS-026: PASS — StudioClosedDaysScreen lets admin set closedWeekdays and closedDates; those feed into availableSlotsProvider (via studioSettingsProvider) which already excludes closed days from slots

## Files changed
lib/features/scheduling/presentation/availability_editor_screen.dart (new)
lib/features/scheduling/presentation/studio_closed_days_screen.dart (new)
lib/features/scheduling/presentation/trainer_slots_screen.dart (new)
lib/app/router.dart (added /profile/availability, /profile/studio, /schedule/trainer/:uid/slots routes)
lib/features/profile/presentation/profile_screen.dart (added trainer Moja dostupnost button and admin Studio closed days button)
lib/features/trainers/presentation/trainer_profile_screen.dart (added VoltButton for availableSlots → /schedule/trainer/$uid/slots)
pubspec.yaml (added table_calendar ^3.2.0)
pubspec.lock (updated)

## Commands run
`flutter pub add table_calendar` (0) — resolved to ^3.2.0
`dart analyze lib test` (0) — "No issues found!"
`flutter test` (0) — "All tests passed!" (12 tests)
`git commit` (0) — feat(F034): M4 scheduling UI

## Decisions made
- Removed `BuildContext context` parameters from async methods in AvailabilityEditorScreen (`_addTimeRange`, `_addException`) and used `this.context` (State.context) directly, with `if (!mounted) return` guards — satisfies the lint "Don't use BuildContext across async gaps guarded by an unrelated mounted check".
- Captured `ScaffoldMessenger.of(context)` before async gaps in all save/add methods to avoid context-across-gap lint.
- Used `error: (_, _)` (Dart 3 wildcard) instead of `(_, __)` to satisfy "Unnecessary use of multiple underscores" lint.
- TrainerSlotsScreen tapping a slot shows a hardcoded SnackBar "Rezervacija stiže uskoro" as specified — booking creation is M5.
- `availableSlotsProvider` returns `AsyncValue<List<Slot>>` (Provider.family, not StreamProvider), so the slots screen uses `.when()` on the Provider value directly — no extra async needed.
- TableCalendar `calendarFormat` fixed to month; `formatButtonVisible: false` so user cannot switch formats (keeps UI simple for M4).
- StudioClosedDaysScreen uses FilterChip with volt selectedColor for weekday toggles, matching the Kinetik palette.
- Date display in exceptions list uses `DateFormat.yMMMEd('sr')` from intl (already a dependency at 0.20.2).

## Out-of-scope work needed
- Actual booking creation (M5) — tapping a slot currently only shows a SnackBar.
- AS-024 (booked slot not shown) is covered by the data layer (availableSlotsProvider excludes booked slots) but the UI for M5 booking needs to exist for this to be observable end-to-end.
- AS-025 (Google Calendar busy slots) is deferred to the Google Calendar sync milestone.
- Profile photo / avatar upload (AS-017) not part of this feature.

## Blockers
(none)

## Autonomous decisions
AUTONOMOUS_DECISION: TrainerSlotsScreen drops the "twoWeeks" format toggle since the spec says "format month or twoWeeks" — I chose month-only with formatButtonVisible: false to keep the UI clean. The slot-browsing use case works equally well with just month view.

## Notes for the next worker
- The three new routes are nested correctly: `/profile/availability` and `/profile/studio` are siblings under `/profile` (same pattern as `trainer-edit` and `admin-users`). `/schedule/trainer/:uid/slots` is nested under the existing `/schedule/trainer/:uid` route.
- `availableSlotsProvider` is a `Provider.family` (not a StreamProvider), so it synchronously returns an `AsyncValue<List<Slot>>` combining upstream streams — use `.when()` directly on the watched value.
- The `table_calendar` version resolved to `^3.2.0` (latest compatible with the SDK constraint `^3.12.2`).
