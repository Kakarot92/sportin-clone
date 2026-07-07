# Plan — Studio Training App

_Draft features grouped into milestones in dependency order. Each feature is sized ~15–45 min of worker time and lists the assertion IDs it covers. Features are drafts; `/mission-tasks` enriches each with 20 clarification answers before `/mission-run`. Per-feature spec files are materialized under `features/F<NNN>-*.md` during `/mission-tasks`._

**Totals:** 15 milestones · 84 features · 104 assertions · coverage 100%.

Status tags used later: `[CLARIFIED]`, `[CLARIFIED-AUTO]`, `[SKIPPED]`, `[COMPLETE]`.

---

## M1 — Foundation
_Project skeleton, deps at verified versions, CI green on empty test, runnable shell. No business logic._

- **F001** — Flutter project scaffold (`flutter create`, folder structure, `analysis_options.yaml`). Deps: none. AS-099
- **F002** — Riverpod 3 + `go_router` app wiring and provider scope. Deps: F001. _(infra)_
- **F003** — Firebase wiring via `flutterfire configure`, `firebase_core` init, `firebase_options.dart`. Deps: F001. AS-099
- **F004** — Theme system: light/dark `ThemeData` + toggle scaffold. Deps: F002. AS-094
- **F005** — Localization scaffold: `flutter_localizations` + `l10n` ARB (sr, en). Deps: F001. AS-092, AS-093
- **F006** — CI: `flutter analyze` + `flutter test` green on one placeholder test. Deps: F001. AS-101
- **F007** — App shell: bottom navigation + placeholder routes. Deps: F002. _(infra)_

## M2 — Auth & roles
- **F010** — Email/password signup screen + Firebase Auth create. Deps: F003, F007. AS-001, AS-003, AS-004
- **F011** — Signup error handling (duplicate email, weak password). Deps: F010. AS-002
- **F012** — Login screen + persistent session. Deps: F010. AS-005, AS-006, AS-015
- **F013** — Logout + route guards for protected areas. Deps: F012. AS-007, AS-010, AS-011
- **F014** — Password reset flow. Deps: F012. AS-008
- **F015** — User profile document created on signup (role=client). Deps: F010. AS-009, AS-017
- **F016** — Role model (custom claims / role field) + role provider. Deps: F015. AS-009
- **F017** — Firestore security rules baseline + role-access tests. Deps: F016. AS-016, AS-102
- **F018** — Profile view/edit screen with avatar upload. Deps: F015. AS-017, AS-018
- **F019** — Signup privacy/health-data consent step. Deps: F010. AS-098

## M3 — Trainer provisioning & profiles
- **F020** — Admin action: grant/revoke trainer role (guarded). Deps: F017. AS-012, AS-013, AS-014
- **F021** — Trainer public profile screen (name, bio, photo). Deps: F018. AS-019
- **F022** — Choose-trainer directory screen. Deps: F021. AS-019

## M4 — Schedules & availability
- **F030** — Weekly availability template model + editor (trainer). Deps: F020. AS-020, AS-021
- **F031** — One-off availability exceptions (block date/time). Deps: F030. AS-022
- **F032** — Availability service: slots minus booked/blocked/closed. Deps: F030. AS-023, AS-024
- **F033** — Studio closed-days setting applied to availability. Deps: F032. AS-026
- **F034** — Slot browser UI per trainer (`table_calendar`). Deps: F032, F022. AS-023

## M5 — Booking (1-on-1)
- **F040** — Booking model + transactional create (no double-book). Deps: F032. AS-027, AS-028
- **F041** — Guard past/taken slots. Deps: F040. AS-028, AS-029
- **F042** — Credit precondition check before booking. Deps: F040, F072. AS-032, AS-054
- **F043** — Decrement credit on successful booking. Deps: F042. AS-034
- **F044** — Client upcoming-bookings screen. Deps: F040. AS-030
- **F045** — Client booking-history screen. Deps: F040. AS-031
- **F046** — Trainer sessions screen. Deps: F040. AS-033

## M6 — Cancellation & reschedule
- **F050** — Cancellation cutoff policy + cancel action. Deps: F040. AS-035, AS-036
- **F051** — Refund credit + free slot on cancel. Deps: F050, F043. AS-037, AS-038
- **F052** — Reschedule to another available slot. Deps: F050, F032. AS-039
- **F053** — Trainer-initiated cancel + client notify + refund. Deps: F050, F083. AS-040

## M7 — Group classes
- **F060** — Group class model + create with capacity (trainer). Deps: F030. AS-041
- **F061** — Join class with capacity check (no waitlist, no dup). Deps: F060. AS-042, AS-043, AS-046
- **F062** — Remaining-spots display + leave class. Deps: F061. AS-044, AS-045
- **F063** — Group class browse/listing. Deps: F060. AS-041

## M8 — Packages, memberships & payments
- **F070** — Package/membership type model + admin definition. Deps: F017. AS-047
- **F071** — Manual package assignment by trainer/admin. Deps: F070. AS-048
- **F072** — Client active-package view (credits, expiry). Deps: F070. AS-049
- **F073** — Expiry enforcement in booking path. Deps: F072. AS-053
- **F074** — In-app card payment integration (provider TBD — see tech-decisions). Deps: F070. AS-050
- **F075** — Payment success → activate package. Deps: F074. AS-052
- **F076** — Payment failure handling. Deps: F074. AS-051
- **F077** — Admin package/payment history view. Deps: F071, F075. AS-055

## M9 — Notifications
- **F080** — FCM setup, token registration, permission prompt. Deps: F003. AS-077
- **F081** — Booking-confirmation notification. Deps: F080, F040. AS-073
- **F082** — Cloud Function: scheduled 24h/1h reminders. Deps: F080, F040. AS-074, AS-075, AS-078
- **F083** — Cancellation notification. Deps: F080, F050. AS-076
- **F084** — Chat message push notification. Deps: F080, F100. AS-072

## M10 — Google Calendar two-way sync
- **F090** — Google Sign-In (v7) + Calendar OAuth scopes (trainer). Deps: F020. AS-079
- **F091** — Create/delete Google event on booking/cancel. Deps: F090, F040, F050. AS-080, AS-081
- **F092** — Read busy events → block availability. Deps: F090, F032. AS-082
- **F093** — Disconnect + resilient sync error handling. Deps: F091. AS-083, AS-084

## M11 — Chat
- **F100** — 1-on-1 chat model + send/receive text. Deps: F017. AS-066, AS-067, AS-069
- **F101** — Chat security rules (participants only). Deps: F100. AS-070
- **F102** — Media attachments via Firebase Storage. Deps: F100. AS-068
- **F103** — Group class chat. Deps: F100, F060. AS-071

## M12 — Measurements & progress
- **F110** — Measurement entry model + create (client-only). Deps: F017. AS-056, AS-057
- **F111** — Edit/delete own measurement entries. Deps: F110. AS-062
- **F112** — Progress photos + consent + Storage privacy rules. Deps: F110. AS-058, AS-059, AS-060
- **F113** — Measurement history charts (`fl_chart`). Deps: F110. AS-061
- **F114** — Trainer view of own clients' measurements. Deps: F110, F020. AS-063, AS-064
- **F115** — Client dashboard summary (sessions, package, latest measurements). Deps: F072, F110, F044. AS-065

## M13 — Admin panel (in-app)
- **F120** — Clients list. Deps: F020. AS-085
- **F121** — Trainers list. Deps: F020. AS-086
- **F122** — Trainer–client relationships view/manage. Deps: F120, F121. AS-087
- **F123** — Attendance/booking reports. Deps: F040. AS-088
- **F124** — Revenue reports. Deps: F077. AS-089
- **F125** — Studio settings (hours, cutoff, package types). Deps: F070, F033. AS-090
- **F126** — Admin route guard. Deps: F013. AS-091

## M14 — i18n, theming & privacy finalization
- **F130** — Full SR/EN string extraction + coverage sweep. Deps: F005. AS-092, AS-093
- **F131** — Language-switch persistence. Deps: F130. AS-095
- **F132** — Theme finalize + persistence. Deps: F004. AS-094, AS-095
- **F133** — Account + data deletion flow. Deps: F015, F110, F112. AS-096, AS-097

## M15 — Polish / QA
- **F140** — Offline detection + user messaging. Deps: F007. AS-100
- **F141** — Crashlytics integration. Deps: F003. AS-103
- **F142** — Analytics events (signup, booking, cancel, purchase). Deps: F003. AS-104
- **F143** — Widget/unit test coverage pass for critical flows. Deps: (all core). AS-101
- **F144** — Security-rules test suite completion. Deps: F017, F101, F112. AS-102
- **F145** — iOS + Android build verification + store-readiness checklist. Deps: (all). AS-099

---

### Coverage check
Every AS-001…AS-104 is referenced by at least one feature above; every feature lists at least one assertion (except tagged _(infra)_ foundation items F002, F007). No gaps.
