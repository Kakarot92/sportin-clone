# Handoff: F071 — M8 packages UI

## Status
COMPLETE

## Assertions covered
AS-032: PASS — NoActivePackageException in _bookSlot and _rescheduleSlot now maps to l10n.noActivePackageError; verified by UI test.
AS-047: PASS — PackageTypesScreen (admin guard, create-type form, list of all types) implemented and tested; domain round-trip tests already passing from prior work.
AS-048: PASS — AdminUsersScreen now shows assign-package icon for non-admin users; opens dialog with active-type dropdown; calls packageAdminControllerProvider.assign; tested.
AS-049: PASS — MyPackageScreen shows active package with remaining credits (credits-kind) or "Unlimited until {date}" (duration-kind), plus package history; tested.

## Files changed
lib/features/packages/presentation/package_types_screen.dart (new)
lib/features/packages/presentation/my_package_screen.dart (new)
lib/features/admin/presentation/admin_users_screen.dart (additive: assign-package icon + dialog)
lib/app/router.dart (additive: /profile/package and /profile/package-types routes)
lib/features/profile/presentation/profile_screen.dart (additive: myPackage + packageTypesTitle entries)
lib/features/scheduling/presentation/trainer_slots_screen.dart (additive: NoActivePackageException branch in both error maps)
test/packages_ui_test.dart (new — 15 UI tests covering AS-032, AS-047, AS-048, AS-049)

## Commands run
`dart analyze lib test` (0) — no issues
`flutter test` (0) — 83 tests, all pass (68 pre-existing + 15 new)
`git add ... && git commit` (0)

## Decisions made
- Used `SingleChildScrollView + Column` for PackageTypesScreen body (not ListView) to prevent lazy-rendering from hiding type cards off-screen in tests. ListView's SliverChildListDelegate skips building off-screen children, so find.text() would fail in tests even though the data was there.
- Watched `packageTypesProvider(true)` in `_UserRow.build()` (not `ref.read` at tap time) so the active-types list is populated by the time the assign button is tapped. `ref.read` in the onTap callback would return AsyncLoading because the StreamProvider hadn't emitted yet.
- Added `_AppUserPreloader` test helper that watches `appUserProvider` before TrainerSlotsScreen renders. TrainerSlotsScreen doesn't watch appUserProvider in build(), so `ref.read(appUserProvider)` inside `_bookSlot` would return AsyncLoading and bail early without showing the confirm dialog.
- Skipped active/inactive toggle for package types because `packageAdminControllerProvider` exposes no `setActive` method — displayed `active` as a badge only (per spec instruction to skip if no API surface).
- `_HistoryRow._statusLabel()` uses `statusDepleted` when kind==credits and remainingCredits==0 (non-expired) or `statusExpired` otherwise, matching the spec's tie-break rule.
- `MyPackageScreen` picks the active package with the latest `expiryDate` when multiple are active (via `fold` comparator), matching the spec's "prefer latest expiry" tie-break.

## Out-of-scope work needed
- AS-050/051/052: In-app card payment for packages — not implemented (deferred per plan.md).
- AS-037: Credit refund on cancellation — booking logic layer, not this feature.
- AS-034: Credit decrement on booking — booking logic layer, not this feature.
- Active/inactive toggle on package types: requires a new `setActive(type, active)` method on `packageAdminControllerProvider` (or `PackagesRepository`). Not exposed in current logic layer.
- Admin view of a specific client's package history (AS-055) — not implemented yet.

## Blockers
(none)

## Autonomous decisions
AUTONOMOUS_DECISION: Used `SingleChildScrollView + Column` instead of `ListView` in PackageTypesScreen to avoid Flutter's lazy viewport hiding off-screen items from `find.text()` in widget tests. ListView with explicit children still uses SliverChildListDelegate which is lazy. The spec said "keep it simple" so a non-lazy scroll container is equally valid and tests reliably.

## Notes for the next worker
- The `_AppUserPreloader` helper in `packages_ui_test.dart` is a pattern worth reusing in any test that taps a booking button in `TrainerSlotsScreen`, since that screen doesn't eagerly watch `appUserProvider` in its build method.
- `packageTypesProvider(false)` (all types) drives the admin screen; `packageTypesProvider(true)` (active only) drives the assignment dropdown in AdminUsersScreen. Both are StreamProvider.family — override in tests with `Stream.value([...])`.
- The `clientPackagesProvider(uid)` stream is ordered newest-first by the repository (see packages_repository.dart). `MyPackageScreen` finds the active package via `isActive()` and picks the one with the latest expiryDate when multiple active packages exist (edge case).
