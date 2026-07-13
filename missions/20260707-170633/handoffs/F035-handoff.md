# Handoff: F035 — Kinetik effects library + auth screens reskin

## Status
COMPLETE

## Assertions covered
AS-094: PASS — Dark Kinetik theme applied to all auth screens (kInk scaffold, volt accent, Archivo Black display); visual token consistency maintained.
AS-101: PASS — All 30 tests pass including widget_test.dart finding Key('login-screen') and no NavigationBar when logged out.

## Files changed
lib/app/kinetic_effects.dart (new)
lib/app/kinetic.dart
lib/app/theme.dart
lib/features/auth/presentation/login_screen.dart
lib/features/auth/presentation/signup_screen.dart
lib/features/auth/presentation/reset_password_screen.dart
lib/features/auth/presentation/splash_screen.dart
missions/20260707-170633/handoffs/F035-handoff.md

## Commands run
`flutter pub get` (0)
`dart analyze lib test` (0) — "No issues found!"
`flutter test` (0) — "+30: All tests passed!"

## Decisions made
- Used F035 as the feature identifier for this ad-hoc design pass (no spec file was generated; the task was assigned directly by the orchestrator).
- Ported all effects from design_lab/studio_a/widgets/effects.dart with color remapping: StudioATheme.ink→kOffWhite, StudioATheme.bg→kInk, StudioATheme.surface→kInkElevated, StudioATheme.surfaceRaised→kField, StudioATheme.inkDim→kMutedDark, StudioATheme.line→kLineDark, StudioATheme.volt→kVolt.
- VoltButton converted from StatelessWidget to StatefulWidget using GestureDetector + AnimatedScale for skew press-state tracking; kept identical public API (label, icon, onPressed, loading) so all 8 callers across scheduling, home, trainers screens continue to work without changes.
- SectionHeader: wrapped the 14×14 volt square in Transform(Matrix4.skewX(-0.35)) per spec.
- Login screen uses both SpeedLines and rotated GhostText "ĐOLE" (mirroring studio_a login pattern); signup uses SpeedLines + GhostText "NALOG" at top-right; reset uses SpeedLines + GhostText "RESET" at top-left; splash uses SpeedLines + Archivo Black brand word + PulseDot.
- Added ConstrainedBox(maxWidth: 520) + Center wrapper to all auth screens for responsive layout on wide viewports.
- kDec() helper added to lib/app/theme.dart (used by CountUp in kinetic_effects.dart).
- Did NOT port StudioAIconButton and StudioASectionLabel as separate classes per spec instructions.
- Did NOT port StudioAVoltButton as a separate class — the skew technique was instead applied directly to the existing VoltButton.

## Out-of-scope work needed
- Remaining screens (home, profile, trainers, scheduling, booking) are not yet reskinned with Kinetik effects — that is a future design pass.
- The Marquee widget is ported but not yet used in any real screen (only available for future use).
- The DiagonalClipper, CountUp, KineticInitials widgets are ported and available but not yet applied to any real screen.
- StudioAIconButton is not ported — the existing IconButton is still bare; a future pass could add a hairline-bordered square variant.

## Blockers
(none)

## Autonomous decisions
AUTONOMOUS_DECISION: Chose F035 as the feature number since this design pass had no assigned spec file in missions/<id>/features/. The number is available (gap between M4 F034 and M5 F040).
AUTONOMOUS_DECISION: Signup screen back-navigation uses IconButton(Icons.arrow_back) pointing to /login, since the original used AppBar() which conflicted with the new Stack-based layout (AppBar would sit below the SpeedLines layer in the Stack). Removed AppBar, replaced with an inline back button wrapped in Reveal(index:0, dy:-14).

## Notes for the next worker
- kinetic_effects.dart exports: SpeedLines, Marquee, CountUp, Reveal, DiagonalClipper, GhostText, PulseDot, KineticInitials, kineticRoute, kTilt (const double).
- The kDec() helper is in lib/app/theme.dart (not in kinetic_effects.dart itself).
- VoltButton is now a StatefulWidget — any callers that held a const VoltButton(...) with super.key will still compile (the const constructor is preserved on the class but the build is stateful).
- All auth screens import both kinetic.dart and kinetic_effects.dart — keep both imports when modifying those screens.
- widget_test.dart tests Key('login-screen') on the Scaffold — that key is on the Scaffold in login_screen.dart and must not be moved or removed.
