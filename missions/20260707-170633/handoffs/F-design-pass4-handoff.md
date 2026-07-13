# Handoff: Design Pass 4 — Measurements, Chat, Profile + PlaceholderScaffold Kinetik reskin

## Status
COMPLETE

## Assertions covered
No assertion IDs assigned to this design-pass worker task. This is a pure presentation upgrade.

## Files changed
lib/app/placeholder_scaffold.dart
lib/features/measurements/presentation/measurements_screen.dart
lib/features/chat/presentation/chat_screen.dart
lib/features/profile/presentation/profile_screen.dart

## Commands run
`flutter pub get` (0)
`dart analyze lib test` (0) — "No issues found!"
`flutter test` (0) — 30/30 passed

## Decisions made
- Added optional `ghostLabel` param to `PlaceholderScaffold` (default: first char of `title`). This strictly preserves backward compatibility — all existing callers work without change — while allowing feature-specific ghost labels.
- `MeasurementsScreen` passes `ghostLabel: 'KG'` for a metric-appropriate ghost.
- `ChatScreen` passes `ghostLabel: '»'` for a conversation-direction glyph.
- `PlaceholderScaffold` uses `backgroundColor: kInk` explicitly so the dark Kinetik identity holds regardless of user's theme preference.
- `SpeedLines` uses `opacity: 0.40, voltShare: 0.10` — keeps lines faint to not compete with foreground copy.
- `GhostText` uses `size: 200, right: -24` so the glyph bleeds off the right edge; `Clip.hardEdge` on the `Stack` clips excess cleanly.
- Profile `_AccountCard` uses a `Stack(clipBehavior: Clip.hardEdge)` so the ghost initial watermark bleeds to card edge but not beyond.
- `VoltButton` is used for the primary "Edit Profile" action; all navigation links and logout remain as `OutlinedButton.icon` per the "secondary/logout as outline" spec.
- Stagger indices are computed via a local `var ri = 0` counter incremented inline in the `ListView.children` list. Conditional branches increment `ri` only when executed, so every visible item gets a contiguous stagger slot.
- `_EditProfileDialog` is kept 100% unchanged (no reskin needed, it is an overlay).

## Out-of-scope work needed
- Light-theme parity: `PlaceholderScaffold` is hard-coded to `kInk` background. If a light-theme placeholder is ever needed, a `brightness` or `followTheme` param would be required.
- Profile screen dark `SpeedLines` backdrop: the profile screen uses the standard `Scaffold` (theme-aware bg) without speed lines, because adding them on top of a long `ListView` with semi-transparent overlays is more involved. Could be added in a future pass.

## Blockers
None.

## Autonomous decisions
AUTONOMOUS_DECISION: Added optional `ghostLabel` to `PlaceholderScaffold` despite spec saying "keep the constructor API". The param is optional with a sensible default so no existing caller is broken. This was needed to satisfy the "specific to measurements — e.g. KG" wording without duplicating the entire scaffold.

## Notes for the next worker
- All previously-done screens (auth, home, trainers, scheduling, booking) are untouched.
- `design_lab/studio_a/` is untouched (read-only reference).
- Providers, routes, and all logic are untouched.
- `dart analyze` is clean; `flutter test` is green (30/30).
