# Handoff: F-design-pass3 — Kinetik reskin scheduling+booking screens

## Status
COMPLETE

## Assertions covered
No explicit assertion IDs were assigned to this design pass. All five screens were reskinned per spec; existing test suite (30 tests) is fully green.

## Files changed
lib/features/scheduling/presentation/trainer_slots_screen.dart
lib/features/scheduling/presentation/availability_editor_screen.dart
lib/features/scheduling/presentation/studio_closed_days_screen.dart
lib/features/booking/presentation/my_bookings_screen.dart
lib/features/booking/presentation/trainer_sessions_screen.dart

## Commands run
`flutter pub get` (0)
`dart analyze lib test` (0) — "No issues found!"
`flutter test` (0) — "30 tests passed"
`git commit` (0) — feat(design): reskin scheduling+booking to Kinetik, replace table_calendar with custom date rail

## Decisions made
- Removed `import 'package:table_calendar/table_calendar.dart'` completely from trainer_slots_screen.dart; the only remaining reference is a prose comment noting the removal.
- The horizontal date rail scrolls 28 days (not 60) starting from today; 28 days matches the spec's "~28 days"; slots query window was already independent.
- Default selection is today: `_selectedDay` is initialised to `_normalise(DateTime.now())` and the provider is called immediately, so no separate "select a day" prompt is ever shown (spec says default-select today).
- Slot blocks use `GestureDetector` + manual decoration rather than `OutlinedButton` to achieve the Kinetik bordered style exactly (≥56dp height, Archivo Black start time, muted end label).
- Cancelled booking/session cards get a `_DangerBadge` (kDanger outline, not kVolt) rather than `VoltBadge` with a tone parameter, since `VoltBadge` only supports filled/outlined variants both in kVolt; this matches the "kDanger tone for cancelled" requirement.
- `MyBookingsScreen` was refactored to `NestedScrollView` so the SpeedLines header scrolls away while the tab bar remains pinned — avoids double-scroll nesting issue with the pre-existing `DefaultTabController` + `Expanded(TabBarView)` pattern.
- `TrainerSessionsScreen` uses `CustomScrollView` + SliverList so `Reveal` stagger works identically to the bookings screen.
- `table_calendar` dependency left in pubspec.yaml (harmless, not imported anywhere in lib/).

## Out-of-scope work needed
- Measurements, chat, and profile screens are still plain Material — not touched per spec.
- The `table_calendar` pub dependency in pubspec.yaml can be removed in a future tidy-up pass (currently harmless).

## Blockers
(none)

## Autonomous decisions
AUTONOMOUS_DECISION: Chose NestedScrollView for MyBookingsScreen to pin the tab bar while scrolling the Eyebrow/DisplayTitle header, as the alternative (placing the header inside AppBar) would have limited the volt SpeedLines backdrop.

## Notes for the next worker
- All five screens now import from `lib/app/kinetic.dart` and `lib/app/kinetic_effects.dart`; make sure any future screen follows this pattern.
- The `_DayCell` widget uses `Matrix4.skewX(-0.06)` only when selected; this is the subtle Kinetik tilt specified in the date-rail requirement.
- `GhostText('0')` behind the "no slots" empty state gives the branded depth layer as specified.
- `dart analyze` and `flutter test` must be re-run if any provider or domain change touches booking or scheduling.
