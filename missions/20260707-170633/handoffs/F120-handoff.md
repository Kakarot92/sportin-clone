# Handoff: F120 — M13 Admin panel (in-app)

## Status
COMPLETE

## Assertions covered
AS-085: PASS — AdminUsersScreen with Clients filter shows only isClient users; tested.
AS-086: PASS — AdminUsersScreen with Trainer filter shows only isTrainer users; tested.
AS-087: PASS — TrainerRelationshipsScreen groups all trainerClients by trainer and lists client names; tested.
AS-088: PASS — BookingReportsScreen shows total/booked/cancelled stats and per-trainer breakdown; tested.
AS-090: PASS — StudioSettingsHubScreen links to /profile/studio (closed days) and /profile/package-types; tested.
AS-091: PASS — All four new screens check `me.isAdmin` and return "not authorized" for non-admins; tested.

## Files changed
lib/l10n/app_en.arb
lib/l10n/app_sr.arb
lib/l10n/app_localizations.dart
lib/l10n/app_localizations_en.dart
lib/l10n/app_localizations_sr.dart
lib/features/admin/presentation/admin_users_screen.dart
lib/features/admin/presentation/trainer_relationships_screen.dart (new)
lib/features/admin/presentation/studio_settings_hub_screen.dart (new)
lib/features/admin/presentation/booking_reports_screen.dart (new)
lib/features/measurements/data/trainer_clients_repository.dart
lib/features/measurements/application/measurements_providers.dart
lib/features/booking/data/booking_repository.dart
lib/features/booking/application/booking_providers.dart
lib/app/router.dart
lib/features/profile/presentation/profile_screen.dart
test/admin_panel_test.dart (new)

## Commands run
`flutter gen-l10n` (0)
`dart analyze lib test` (0) — "No issues found!"
`flutter test test/admin_panel_test.dart` (0) — 17/17 passed
`flutter test` (0) — 188/188 passed (171 pre-existing + 17 new)
`git add ... && git commit` (0)

## Decisions made
- AdminUsersScreen converted from ConsumerWidget to ConsumerStatefulWidget to hold `_filter` state locally; this is the minimal change approach rather than lifting filter state into a provider.
- SegmentedButton filter uses values 'all'/'clients'/'trainers'; "Svi"/"Klijenti" are new keys; "Treneri" reuses existing `roleTrainer` key as instructed (not `roleTrainerSwitch`, which has label "Trainer" without the plural nuance — but for the button label it works fine).
- TrainerRelationshipsScreen: when `trainerProvider` returns null (e.g. trainer not in `trainers` collection), the section header falls back to the raw `trainerUid`. This is an acceptable graceful degradation — the trainerClients collection stores the trainerUid and the trainer profile should exist.
- BookingReportsScreen: revenue placeholder is an inline Kinetik card (kInkElevated border, SectionHeader + GhostText + body text) on the same scroll as the stats — NOT a separate route. This satisfies the spec's "simplest is same screen" guidance.
- New data methods use single-field `orderBy` only (no `where` + different-field `orderBy` combo), so no composite Firestore indexes are needed. Verified by reading both methods before adding.
- AS-089 (revenue reports) explicitly deferred: a `_RevenuePlaceholderCard` inline widget with `l10n.revenueReportsComingSoon` text is shown instead of fabricated numbers.
- ProfileScreen: kept the existing direct links to /profile/studio and /profile/package-types in addition to the new hub, so admins still have one-tap access to those screens (the spec says "do not change any existing entry").

## Out-of-scope work needed
- AS-089 (revenue reports): requires a payment provider and price field on PackageType. A future worker can add this once Stripe/payment is integrated.
- Firestore security rules for `trainerClients` collection currently allow any signed-in user to read (consistent with existing bookings rules). A future security pass could restrict `watchAllRelationships` to admins at the rules level.
- The `trainerProvider` family returns a `TrainerProfile?` from the `trainers` Firestore collection. If a user has the `trainer` role but no profile doc in `trainers`, the section header in TrainerRelationshipsScreen shows the raw UID. A future worker could add a fallback that reads from `users` collection.

## Blockers
(none)

## Autonomous decisions
AUTONOMOUS_DECISION: Kept existing direct /profile/studio and /profile/package-types buttons in profile_screen.dart alongside the new hub, since the spec says "do not change any existing entry." The hub is an additional entry point, not a replacement.
AUTONOMOUS_DECISION: Used `find.text('Trainer').first` in test AS-086 because SegmentedButton segment "Trainer" and per-row roleTrainerSwitch "Trainer" both appear; `.first` reliably targets the header segment since it's rendered before list items.

## Notes for the next worker
- `dart analyze lib test` clean, `flutter test` 188/188 as of commit 554e8ea.
- No composite Firestore indexes were added or needed — both new queries use single-field `orderBy` which is auto-indexed by Firestore.
- The l10n generation is idempotent: running `flutter gen-l10n` again is safe.
- All four new screens include `appBar: AppBar()` in their Scaffold (guarded path AND unauthorized path).
