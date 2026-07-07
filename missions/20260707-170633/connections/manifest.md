# Connection Manifest

_Generated: 2026-07-07T15:35:00Z_  _MCP/auth state web-verified 2026-07-07._

The orchestrator runs every install/registration/config command. You only create accounts in a browser and paste credentials/choices in chat.

| # | Service | Type | What I'll set up | What I need from you | Status |
|---|---------|------|------------------|----------------------|--------|
| 1 | **Firebase** (Firestore, Auth, Storage, FCM, Functions, Crashlytics, Analytics) | mcp + api | Register Firebase MCP (`claude mcp add firebase` → `npx firebase-tools mcp`); install FlutterFire CLI; run `flutterfire configure`; wire `firebase_core` + `firebase_options.dart`; enable used services. Covers AS-001–016, 056–072, 073–078, 103–104. | (1) Create a Firebase project at console.firebase.google.com and give me the **project ID**. (2) Upgrade it to the **Blaze** plan (Cloud Functions + scheduled reminders require it). (3) Authenticate the Firebase CLI — I'll start `firebase login`, you approve in the browser. | PENDING |
| 2 | **Google Cloud — Calendar API + OAuth** | oauth-app | Enable Calendar API on the same GCP project; wire `google_sign_in` v7 + `googleapis` + `extension_google_sign_in_as_googleapis_auth`; store client IDs in config. Covers AS-079–084. | Enable **Google Calendar API**; configure OAuth consent screen; create **OAuth Client IDs** (Android: package + SHA‑1 I'll give you; iOS: bundle ID) and paste the IDs. _(Deferred until the app scaffold exists — needs package name/SHA‑1.)_ | PENDING (after Foundation) |
| 3 | **Payments — Stripe** (candidate) | api + mcp | Add `flutter_stripe` to the app; keep Stripe **secret in Cloud Functions config** (never in the app); optionally register Stripe MCP (`mcp.stripe.com`, restricted `rk_` key). Covers AS-050–052, 055. | Decision: confirm **Stripe** vs store IAP (memberships are for in-person service → external card processors are allowed). Then: Stripe account + **restricted key (`rk_`)** + publishable key. | PENDING (decision first) |
| 4 | **App Store Connect + Google Play** | browser | Build/signing config; store listing scaffolding. Covers AS-099 (release). | Apple Developer + Google Play developer accounts (only needed at release time). | DEFERRED (release phase) |

## Sequencing note

`flutterfire configure` and the Android/iOS OAuth client IDs require the Flutter app scaffold (package name, bundle ID, SHA‑1) to exist. So connect proceeds in two waves:

- **Now (accounts & credentials):** Firebase project + Blaze + CLI login (service 1); Stripe decision + keys (service 3).
- **At Foundation (M1 of run):** `flutterfire configure`, OAuth client IDs (service 2), and `.env`/config wiring — once `flutter create` has produced the package/bundle identifiers.
