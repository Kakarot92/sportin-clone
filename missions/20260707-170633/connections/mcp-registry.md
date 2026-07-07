# MCP registry for workers

_Generated: 2026-07-07T15:45:00Z_  _Source: project `.mcp.json` (the `claude` CLI is not on PATH in this environment — VSCode extension — so servers are registered via `.mcp.json`; they load when the app is launched with `claude --dangerously-skip-permissions`)._

## MCP servers (workers may use during /mission-run)

| Service | MCP server name | Tool prefix | Worker use | Use during run for |
|---------|-----------------|-------------|------------|--------------------|
| Firebase | firebase | `mcp__firebase__*` | yes | Firestore structure, security rules, Auth, project introspection, live data checks, Functions/Storage config |

**Worker use:** `yes` = workers should call the Firebase MCP for live introspection when a feature touches Firestore/Auth/Storage/Functions.

## Non-MCP services (SDK / env only)

| Service | Env vars (names only) | SDK / notes |
|---------|-----------------------|-------------|
| Google Calendar | `GOOGLE_CALENDAR_ANDROID_CLIENT_ID`, `GOOGLE_CALENDAR_IOS_CLIENT_ID` | `google_sign_in` v7 + `googleapis` + `extension_google_sign_in_as_googleapis_auth`. OAuth clients created at Foundation (need package name / SHA‑1 / bundle ID). |
| Stripe | `STRIPE_PUBLISHABLE_KEY` (app), `STRIPE_SECRET_KEY` (Cloud Functions only) | `flutter_stripe`; provider decision pending. Optional Stripe MCP (`mcp.stripe.com`, restricted `rk_` key). |

_Note: not a completion marker. `connections/VERIFIED` is written only after Google Calendar and the Stripe decision are resolved (both currently deferred/pending)._
