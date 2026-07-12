# Tech decisions

_All versions verified via web search on 2026-07-07 (see inline annotations). Re-verify at `/mission-connect` before install._

## Stack

- Language: Dart 3.9.x (bundled with Flutter stable)  <!-- verified against https://docs.flutter.dev/release/release-notes as of 2026-07-07 -->
- Framework: Flutter 3.44.x (stable channel)  <!-- verified against https://docs.flutter.dev/release/release-notes as of 2026-07-07 -->
- Backend: Firebase (serverless) + Cloud Functions for scheduled/secure logic  <!-- per discovery Q22=d, Q11=d; orchestrator choice -->
- Database: Cloud Firestore  <!-- chosen over Realtime DB for structured booking/query needs; verified https://firebase.google.com/docs/firestore as of 2026-07-07 -->
- Auth: Firebase Authentication (email/password)  <!-- verified https://firebase.google.com/docs/auth as of 2026-07-07 -->
- File storage: Firebase Storage (avatars, chat media, progress photos)
- Push: Firebase Cloud Messaging  <!-- verified https://firebase.google.com/docs/cloud-messaging as of 2026-07-07 -->
- Cloud Functions runtime: Node.js 22 (reminders, payment webhooks, Google Calendar sync)  <!-- verify supported runtime at https://firebase.google.com/docs/functions as of connect -->

## Libraries used

_Pin these at install via `flutter pub add`; versions below are the current stable as verified on pub.dev / Firebase release notes on 2026-07-07 (FlutterFire BoM 4.16.0)._

- `firebase_core: ^4.11.0`  <!-- https://firebase.google.com/support/release-notes/flutter -->
- `firebase_auth: ^6.5.3`  <!-- same BoM -->
- `cloud_firestore: ^6.6.0`  <!-- same BoM -->
- `firebase_storage: ^13.4.3`  <!-- same BoM -->
- `firebase_messaging: ^16.4.0`  <!-- same BoM -->
- `cloud_functions: ^6.3.3`  <!-- same BoM -->
- `firebase_crashlytics: ^5.2.4`  <!-- same BoM; discovery Q13=a -->
- `firebase_analytics: ^12.4.3`  <!-- same BoM; discovery Q14=a -->
- `flutter_riverpod: ^3.3.2` — state management (compile-safe, no BuildContext coupling)  <!-- https://pub.dev/packages/flutter_riverpod -->
- `go_router` — declarative routing + guards; pin latest at `flutter pub add go_router`  <!-- verify at connect -->
- `table_calendar: ^3.2.0` — availability/slot calendar UI  <!-- https://pub.dev/packages/table_calendar -->
- `fl_chart: ^1.2.0` — measurement progress charts  <!-- https://pub.dev/packages/fl_chart -->
- `flutter_local_notifications: ^21.0.0` — local reminder display alongside FCM  <!-- https://pub.dev/packages/flutter_local_notifications -->
- `google_sign_in: ^7.2.0` — Google auth for Calendar (NOTE: v7 API differs significantly from v5/v6)  <!-- https://pub.dev/packages/google_sign_in -->
- `googleapis` + `googleapis_auth` — Google Calendar REST access; pin latest at install  <!-- https://docs.flutter.dev/data-and-backend/google-apis -->
- `flutter_localizations` (SDK) + `intl` — SR/EN localization
- Payments: `flutter_stripe` (candidate) — card payments for memberships; **see External services note on store policy**. Pin at connect.

## Libraries explicitly avoided

- Realtime Database — Firestore chosen for richer querying of bookings/schedules.
- `provider` / raw `setState` for app state — superseded by Riverpod for testability and scale.
- `bloc` — viable, but Riverpod chosen for less boilerplate given team size; single choice to keep the codebase consistent.
- `google_sign_in` v5/v6 patterns from memory — **v7 is current and changed the sign-in API**; workers must follow v7 docs, not older tutorials.
- In-app-purchase (`in_app_purchase`) for memberships — memberships are for real-world, in-person training (a physical service), which both Apple and Google allow to be sold via external card processors; IAP is generally reserved for digital goods. To confirm during connect/tasks.

## File layout

```
lib/
  main.dart
  firebase_options.dart
  app/            (router, theme, localization, app shell)
  core/           (models, services, providers, security helpers)
  features/
    auth/  profile/  trainers/  schedule/  booking/  classes/
    packages/  payments/  measurements/  chat/  notifications/
    calendar_sync/  admin/  dashboard/
  l10n/           (app_en.arb, app_sr.arb)
functions/        (Cloud Functions: reminders, payments webhook, calendar sync)
test/             (unit + widget tests)
firestore.rules   (+ firestore.rules test suite)
storage.rules
```

## External services needed
_The `/mission-connect` phase consumes this list. Prefer MCP where available._

- **Firebase** — official MCP available: `npx -y firebase-tools mcp` (register via `claude mcp add`). Needs: a Firebase project (prod), `flutterfire configure`, service-account for Functions deploy.  <!-- https://firebase.google.com/docs/ai-assistance/mcp-server -->
- **Google Cloud / Google Calendar API** — enable Calendar API + OAuth consent screen + OAuth client IDs (Android/iOS). Needs: OAuth client credentials. No dedicated MCP; use `googleapis`.
- **Payment processor (Stripe candidate)** — needs publishable + secret keys; secret key used only in Cloud Functions, never in the app. No official MCP assumed; verify at connect. Decision pending store-policy confirmation.
- **Apple Developer + Google Play** — for distribution (discovery Q21=a: both stores). Needs: developer accounts (user-provided, browser-only).

## How to run the app
```
flutter run
```

## How to run tests
```
flutter test
```

## How to run linter
```
flutter analyze
```

## How to run type-check
```
dart analyze
```

## Conventions

- **Architecture:** feature-first folders under `lib/features/<feature>/` with `data/`, `domain/`, `presentation/` sub-splits where a feature grows.
- **State:** Riverpod providers/notifiers; no business logic in widgets; async state modeled as data+loading+error.
- **Models:** immutable Dart classes with `fromJson`/`toJson`; Firestore mapping in a repository layer, not in widgets.
- **Security:** every collection touched by a feature ships matching `firestore.rules` + a rules test. Role checks are enforced in rules, not only in UI.
- **Secrets:** never in the app bundle or markdown. Payment secret keys and Google service credentials live in Cloud Functions config / `.env` (gitignored).
- **Naming:** files `snake_case.dart`; classes `PascalCase`; providers suffixed `Provider`.
- **Localization:** no hard-coded user-facing strings; all via `AppLocalizations` (ARB). SR is the default locale.
- **Errors/logging:** user-friendly messages in UI; technical errors to Crashlytics; key funnel events to Analytics.
- **Time zones:** store timestamps in UTC; render in the studio's local time (Europe/Belgrade).
- **Testing:** every core flow (auth, booking, cancellation, measurements) gets unit/widget tests; workers must keep `flutter test` and `flutter analyze` green before exit.

## Design handoff

Discovery Q13 = "client provides designs." Timing (non-blocking for approval/connect):

- **Early (any time before `/mission-run` UI work):** brand foundation — colors (hex), font, logo, light/dark palette. Feeds the theme (F004/F132) and dashboard/shell look.
- **Per screen (before or during `/mission-run` for each feature):** mockups for login, choose-trainer, slot calendar, booking, measurements + charts, chat, admin.
- **Accepted formats:** Figma link, screenshots/images, or a style-guide (hex + font + spacing) plus references to specific sportIN screens to emulate.
- **Fallback if design is late:** workers implement a clean Material 3 baseline against the chosen light/dark theme, to be re-skinned when designs arrive.
- **Status:** _received. Client chose **Kinetik** (of 5 Design-Lab directions): volt-yellow `#CCFF00` on near-black `#0B0B0C`, Archivo Black display + Inter Tight body, huge uppercase headlines, numbers-as-heroes, dark-first. Implemented as the app theme (`lib/app/theme.dart` + `lib/app/kinetic.dart`) and applied to login/signup/home/profile. Remaining screens inherit the theme; art-direct per screen as features land._
