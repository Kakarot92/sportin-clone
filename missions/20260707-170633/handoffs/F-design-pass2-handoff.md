# Handoff: Design Pass 2 — Kinetik reskin: Home, Nav transitions, Trainers

## Status
COMPLETE

## Assertions covered
No specific assertion IDs were assigned to this design-reskin task.

## Files changed
lib/features/home/presentation/home_screen.dart
lib/app/router.dart
lib/features/trainers/presentation/trainer_directory_screen.dart
lib/features/trainers/presentation/trainer_profile_screen.dart

## Commands run
`dart analyze lib test` (0) — No issues found
`flutter test` (0) — 30/30 tests passed

## Decisions made
- `_SessionPoster` is a `ConsumerWidget` placed inside `Reveal(index:2)` — watches `appUserProvider` and `clientUpcomingBookingsProvider(me.uid)` directly. Trainer name resolved via `trainerProvider(booking.trainerUid)`.
- Empty state in `_SessionPoster` shows "Nema zakazanih treninga." + skewed `VoltButton` "Zakaži termin" → `context.go('/schedule')`.
- Weekday formatted via `DateFormat('EEEE', 'sr').format(dt)` matching the existing `DateFormat.yMMMEd('sr')` pattern already in the codebase.
- Router: created top-level `_kineticPage(LocalKey, Widget) → CustomTransitionPage<void>` helper inlining the exact same curves as `kineticRoute` (easeOutCubic/easeInCubic, 420ms forward / 300ms reverse, Offset(0.08, 0) slide). Applied to `/schedule/trainer/:uid`, `/schedule/trainer/:uid/slots`, and all six `/profile/*` sub-routes. Tab routes and StatefulShellRoute left untouched.
- `TrainerDirectoryScreen`: kept `Column + Expanded` structure, added `Stack` body with faint `SpeedLines(opacity:0.18)` backdrop; `_TrainerCard` uses `Material + InkWell` (no border-radius, kLineDark border) with `KineticInitials`, Archivo Black 16px uppercase name, `kMutedDark` bio, volt `chevron_right_rounded`.
- `TrainerProfileScreen`: removed `AppBar`, added inline `IconButton(arrow_back)` with `context.pop()`. Hero `Stack` with `SpeedLines`, `GhostText(initial, size:150)`, `KineticInitials(size:64)`, and name split by space — first part `kOffWhite`, rest `kVolt` (Archivo Black 46px). `SectionHeader(l10n.trainerBio)` + bio text + `VoltButton(l10n.availableSlots)` in content section below. All wrapped in `Reveal` with staggered indices.
- `_SessionPoster` constructor written as `const _SessionPoster()` (no `{super.key}`) to avoid "optional parameter 'key' isn't ever given" lint warning.

## Out-of-scope work needed
- The Measurements, Chat, and Profile screens are not yet reskinned (later passes as noted in task brief).
- The NavigationBar at app shell level still uses Material 3 `NavigationBar` widget — could be replaced with the custom Kinetik nav bar from `studio_a/screens/shell.dart` in a future pass if desired.

## Blockers
(none)

## Autonomous decisions
AUTONOMOUS_DECISION: Used hardcoded Serbian sub-text for the three quick-action rows ("Izaberi trenera i zakaži trening", "Prati svoja telesna merenja", "Chat poruke sa trenerom") because no matching l10n keys exist and the studio_a reference also uses hardcoded SR copy.

## Notes for the next worker
- All Kinetik widgets (`Reveal`, `Marquee`, `SpeedLines`, `GhostText`, `PulseDot`, `DiagonalClipper`, `KineticInitials`) are in `lib/app/kinetic_effects.dart`. Typography widgets (`Eyebrow`, `DisplayTitle`, `SectionHeader`, `VoltButton`) are in `lib/app/kinetic.dart`. Theme constants (`kVolt`, `kInk`, `kInkElevated`, `kLineDark`, `kOffWhite`, `kMutedDark`, `kTilt`) are in `lib/app/theme.dart`.
- The `kineticRoute<T>` helper in `kinetic_effects.dart` produces a `PageRouteBuilder` for use with `Navigator.of(context).push(kineticRoute(...))` — NOT for go_router. For go_router pushed routes, use the `_kineticPage` helper now in `router.dart`.
