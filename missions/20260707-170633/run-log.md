# Run log — mission 20260707-170633

_Orchestrator progress log. Newest first._

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
