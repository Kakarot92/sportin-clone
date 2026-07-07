# Validation Contract — Studio Training App

_Flat, numbered, falsifiable behaviour assertions. Immutable once `APPROVED` exists. New requirements get new AS-NNN IDs; existing ones are never edited or renumbered._

## Auth & accounts

- AS-001: A visitor can create a client account with email and password.
- AS-002: A visitor cannot create an account with an email already in use; the app shows an error.
- AS-003: A visitor cannot submit signup with an invalid email format; the form shows a validation error.
- AS-004: A visitor cannot submit signup with a password below the minimum length; the form shows a validation error.
- AS-005: A registered user can log in with correct email and password.
- AS-006: A user cannot log in with an incorrect password; access is denied and an error is shown.
- AS-007: A logged-in user can log out, after which protected screens are inaccessible.
- AS-008: A user can request a password-reset email and set a new password.
- AS-009: A newly self-registered account has the "client" role by default.
- AS-010: A client cannot open trainer-only screens.
- AS-011: A client cannot open admin-only screens.
- AS-012: The admin/owner can grant the "trainer" role to an existing account.
- AS-013: The admin/owner can revoke the "trainer" role from an account.
- AS-014: A non-admin user cannot grant or revoke any role; the attempt is rejected.
- AS-015: A user session persists across app restarts until the user logs out.
- AS-016: Firestore security rules deny reads/writes not permitted for the user's role (enforced server-side, not only in the UI).

## Profiles

- AS-017: A user can view and edit their own profile (name, phone, avatar).
- AS-018: A user cannot edit another user's profile.
- AS-019: A trainer's public profile (name, bio, photo) is visible to clients choosing a trainer.

## Trainer schedules & availability

- AS-020: A trainer can define a weekly recurring availability template of days and time slots.
- AS-021: A trainer can edit their weekly availability template.
- AS-022: A trainer can add a one-off exception that blocks a specific date/time from availability.
- AS-023: A client sees only available (unbooked, non-blocked) slots for the selected trainer.
- AS-024: A slot that has just been booked no longer appears as available to other clients.
- AS-025: A slot that overlaps a busy event in the trainer's connected Google Calendar is not offered as available.
- AS-026: When the studio is marked closed for a day, no slots are offered that day.

## Booking — 1-on-1

- AS-027: A client can book an available 1-on-1 session with a chosen trainer at a chosen slot.
- AS-028: A client cannot book a slot that is already taken; it is shown as unavailable.
- AS-029: A client cannot book a slot in the past.
- AS-030: A client can view their upcoming bookings.
- AS-031: A client can view their past booking history.
- AS-032: A client with no active package/credit cannot complete a booking; they are prompted to get a package.
- AS-033: A trainer can view all sessions booked with them.
- AS-034: Completing a credit-based booking decrements the client's remaining credits by one.

## Cancellation & reschedule

- AS-035: A client can cancel a booking earlier than the cancellation cutoff.
- AS-036: A client cannot cancel a booking after the cutoff; the policy is explained.
- AS-037: Cancelling before the cutoff refunds the consumed credit to the client.
- AS-038: Cancelling a booking frees the slot for others to book.
- AS-039: A client can reschedule a booking to another available slot before the cutoff.
- AS-040: A trainer can cancel a session; the affected client is notified and the credit is refunded.

## Group classes

- AS-041: A trainer can create a group class with a date/time and a fixed capacity.
- AS-042: A client can join a group class that has open spots.
- AS-043: A client cannot join a group class that is full (no waitlist).
- AS-044: The remaining-spots count decreases as clients join a class.
- AS-045: A client can leave a group class before the cutoff, freeing a spot.
- AS-046: A client cannot join the same group class twice.

## Packages, memberships & payments

- AS-047: The admin can define package/membership types (duration-based e.g. 1/3/6 months, or session-credit packs).
- AS-048: A trainer/admin can manually assign a package to a client (for in-person payment).
- AS-049: A client can view their active package: remaining credits and expiry date.
- AS-050: A client can purchase a package in-app via card payment.
- AS-051: A failed card payment does not grant a package; the client sees an error.
- AS-052: A successful card payment activates the package immediately.
- AS-053: An expired package cannot be used to book sessions.
- AS-054: A booking is blocked when the client has no remaining credits or valid membership.
- AS-055: The admin can view a client's package and payment history.

## Measurements & progress

- AS-056: A client can record a body-measurement entry (weight, circumferences, body-fat %) dated.
- AS-057: Only the client can create their own measurement entries.
- AS-058: A client can attach progress photos to a measurement entry.
- AS-059: A client's progress photos are readable only by that client and their trainer.
- AS-060: A client must give explicit consent before uploading progress photos.
- AS-061: A client can view their measurement history as a chart over time.
- AS-062: A client can edit or delete a measurement entry they created.
- AS-063: A trainer can view the measurement history of their own clients.
- AS-064: A trainer cannot view the measurements of clients who are not theirs.
- AS-065: A client dashboard summarizes sessions attended, current package, and latest measurements.

## Chat

- AS-066: A client can send a text message to their trainer in a 1-on-1 chat.
- AS-067: A trainer can reply to a client in the 1-on-1 chat.
- AS-068: A user can send an image or video attachment in chat.
- AS-069: Messages display in chronological order and persist across app restarts.
- AS-070: A user cannot read a conversation they are not a participant of.
- AS-071: A group class chat is visible only to that class's participants and its trainer.
- AS-072: A user receives a push notification for a new chat message while the app is backgrounded.

## Notifications

- AS-073: A client receives a booking-confirmation notification after booking.
- AS-074: A client receives a reminder notification 24 hours before a session.
- AS-075: A client receives a reminder notification 1 hour before a session.
- AS-076: A client receives a notification when a trainer cancels their session.
- AS-077: A user can grant or deny notification permission; if denied, push is disabled but the app still works.
- AS-078: No reminder is sent for a cancelled session.

## Google Calendar two-way sync

- AS-079: A trainer can connect their Google account to enable calendar sync.
- AS-080: Booking a session creates a corresponding event in the trainer's Google Calendar.
- AS-081: Cancelling a session removes the corresponding Google Calendar event.
- AS-082: Busy events in the trainer's Google Calendar block those times from bookable availability.
- AS-083: A trainer can disconnect Google Calendar, after which no further sync occurs.
- AS-084: A Google Calendar sync failure does not block booking; the booking succeeds and the error is logged.

## Admin panel (in-app)

- AS-085: The admin can view a list of all clients.
- AS-086: The admin can view a list of all trainers.
- AS-087: The admin can view (and manage where applicable) trainer–client relationships.
- AS-088: The admin can view booking/attendance reports.
- AS-089: The admin can view revenue/payment reports.
- AS-090: The admin can manage studio settings (opening hours, cancellation cutoff, package types).
- AS-091: Admin screens are reachable only by an account with the admin role.

## Internationalization & theming

- AS-092: A user can switch the app language between Serbian and English.
- AS-093: Primary user-facing screens contain no hard-coded untranslated strings.
- AS-094: A user can switch between light and dark theme.
- AS-095: The selected language and theme persist across app restarts.

## Privacy & data

- AS-096: A user can request deletion of their account and associated data.
- AS-097: Deleting an account removes that user's measurement entries and progress photos.
- AS-098: Signup presents a privacy/consent notice covering health and body data.

## Non-functional & quality

- AS-099: The app builds and runs on both Android and iOS.
- AS-100: The app requires connectivity and shows a clear message when offline.
- AS-101: Critical flows (auth, booking, cancellation, measurements) are covered by unit/widget tests.
- AS-102: Firestore security rules have automated tests covering role-based access.
- AS-103: Uncaught errors and crashes are reported to Firebase Crashlytics.
- AS-104: Key events (signup, booking, cancellation, purchase) are logged to Firebase Analytics.
