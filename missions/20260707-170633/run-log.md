# Run log — mission 20260707-170633

_Orchestrator progress log. Newest first._

## 2026-07-12 — M4 Schedules & availability — COMPLETE

Two serial workers under supervision:

- **Worker 1 (data+logic)** — `lib/features/scheduling/domain/` (TimeRange,
  WeeklyAvailability, AvailabilityException, StudioSettings, Slot, Booking,
  date_utils, pure `availability_service.generateDaySlots`), `.../data/
  availability_repository.dart`, `.../application/scheduling_providers.dart`.
  Firestore rules extended for `availabilityTemplates`, `availabilityExceptions`,
  `studioSettings`, `bookings` (read-only until M5) — validated + **deployed**
  via Firebase MCP. `test/availability_service_test.dart`: 11 cases green.
  Covers AS-020, AS-021, AS-022, AS-023, AS-024, AS-026.
- **Worker 2 (UI)** — `lib/features/scheduling/presentation/`
  (availability_editor_screen, studio_closed_days_screen, trainer_slots_screen),
  `table_calendar ^3.2.0`, routes in `lib/app/router.dart`
  (`/profile/availability` trainer-gated, `/profile/studio` admin-gated,
  `/schedule/trainer/:uid/slots`), entry buttons in profile + trainer profile.

Gate: `dart analyze lib test` clean; `flutter test` 12/12 pass. Commits
dd1cf86 (F030) + c6a2b63 (F034). Firebase MCP seeds: template for
`trainer-djole` (Mon–Thu 09–12 & 16–20, Fri 09–14, 60-min), `studioSettings`
closed Sundays. Verified live on Edge web build. AS-025 (Google Calendar busy)
intentionally deferred with the Google Calendar connection.

## 2026-07-07 — Design: Kinetik visual language applied

Client picked **Kinetik** from the 5-direction Design Lab. Implemented:
`lib/app/theme.dart` (Kinetik dark-first ColorScheme, Archivo Black + Inter
Tight via `google_fonts`, component themes) and `lib/app/kinetic.dart`
(Eyebrow, DisplayTitle, SectionHeader, VoltBadge, KineticField, VoltButton).
Reskinned login, signup, home, profile to match the reference screens; default
theme set to dark. Other screens inherit the theme. `dart analyze` clean,
`flutter test` green, APK builds. (Live emulator screenshot deferred — host
emulator unstable this session; earlier milestones ran on-device fine.)

## 2026-07-07 — M3 Trainer provisioning & profiles: code COMPLETE, rules verified

Features F020 (admin grant/revoke trainer), F021 (trainer public profile +
edit), F022 (choose-trainer directory). New `trainers/{uid}` public-profile
collection; Schedule tab now hosts the trainer directory → trainer profile.
Admin role-management screen + trainer bio-edit screen wired under Profile
(buttons gated by role). `flutter analyze` clean, `flutter test` green.

Firestore `trainers` rules deployed and REST-verified:
- AS-019 signed-in client can read the trainers collection (200)
- client CANNOT create a trainer profile (403)
- unauthenticated read denied (403)

Pending live demo of F020 (grant trainer) — needs an admin account (owner
seed). Directory shows real trainers once an admin grants the role.

## 2026-07-07 — M2 Auth & roles: COMPLETE, verified live

Features F010–F019 implemented. Verified without an emulator via the Firebase
REST API (Identity Toolkit + Firestore):

- AS-001 signUp works (Email/Password provider live)
- AS-005 signInWithPassword works
- AS-006 wrong password rejected (`INVALID_LOGIN_CREDENTIALS`)
- AS-009 user creates own `users/{uid}` profile as `client` (rule allows)
- AS-016 self role-escalation to `admin` DENIED with 403 (rule blocks it)

Also: `flutter analyze` clean, `flutter test` green (logged-out → login), login
and signup screens rendered live on the Android emulator earlier. Firestore
`(default)` database created (STANDARD, eur3-adjacent), `firestore.rules`
deployed successfully.

Pending: seed the studio owner as `admin` — needs the owner's email + a
one-time privileged write (Firebase Console doc edit, or a service-account
script). Not blocking further code.

## 2026-07-07 — M1 Foundation: COMPLETE, verified

Features F001–F007. Flutter 3.44.4 scaffold (Android+iOS), Firebase wired
(`flutterfire configure` → `firebase_options.dart`), Riverpod 3, light/dark
Material 3 theme, SR/EN localization (SR default), go_router 5-tab shell.
Verified: `flutter analyze` clean, `flutter test` green, debug APK built, app
run on Android emulator with live theme toggle + navigation (screenshots).

## Environment notes
- `claude` CLI not on PATH (VSCode extension) → Firebase MCP registered via
  project `.mcp.json`, not `claude mcp add`.
- `python3` fixed on Windows (real interpreter shim) so the pre-worker-exit
  hook works.
- Emulator UI-driving via adb is flaky/slow on this host; prefer REST/unit
  verification over adb tapping.
