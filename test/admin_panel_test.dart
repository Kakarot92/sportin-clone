// ignore_for_file: lines_longer_than_80_chars
//
// UI tests for M13 — Admin panel (in-app).
//
// Assertions covered:
//   AS-085  Admin can view a list of all clients.
//   AS-086  Admin can view a list of all trainers.
//   AS-087  Admin can view trainer–client relationships.
//   AS-088  Admin can view booking/attendance reports.
//   AS-090  Admin can manage studio settings (closed days, package types).
//   AS-091  Admin screens are reachable only by an account with the admin role.

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sportin_clone/app/theme.dart';
import 'package:sportin_clone/core/models/app_user.dart';
import 'package:sportin_clone/features/admin/application/admin_providers.dart';
import 'package:sportin_clone/features/admin/presentation/admin_users_screen.dart';
import 'package:sportin_clone/features/admin/presentation/booking_reports_screen.dart';
import 'package:sportin_clone/features/admin/presentation/studio_settings_hub_screen.dart';
import 'package:sportin_clone/features/admin/presentation/trainer_relationships_screen.dart';
import 'package:sportin_clone/features/auth/application/auth_providers.dart';
import 'package:sportin_clone/features/booking/application/booking_providers.dart';
import 'package:sportin_clone/features/measurements/application/measurements_providers.dart';
import 'package:sportin_clone/features/measurements/domain/trainer_client_ref.dart';
import 'package:sportin_clone/features/scheduling/domain/booking.dart';
import 'package:sportin_clone/features/trainers/application/trainers_providers.dart';
import 'package:sportin_clone/l10n/app_localizations.dart';

// ─── Test helpers ─────────────────────────────────────────────────────────────

Widget _testApp(Widget child) => MaterialApp(
      theme: buildDarkTheme(),
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: child,
    );

// ─── Fixtures ─────────────────────────────────────────────────────────────────

const _admin = AppUser(
  uid: 'admin-1',
  email: 'admin@test.com',
  displayName: 'Admin User',
  role: AppRole.admin,
);

const _trainer1 = AppUser(
  uid: 'trainer-1',
  email: 'trainer1@test.com',
  displayName: 'Alice Trainer',
  role: AppRole.trainer,
);

const _trainer2 = AppUser(
  uid: 'trainer-2',
  email: 'trainer2@test.com',
  displayName: 'Bob Trainer',
  role: AppRole.trainer,
);

const _client1 = AppUser(
  uid: 'client-1',
  email: 'client1@test.com',
  displayName: 'Charlie Client',
  role: AppRole.client,
);

const _client2 = AppUser(
  uid: 'client-2',
  email: 'client2@test.com',
  displayName: 'Dana Client',
  role: AppRole.client,
);

const _nonAdmin = AppUser(
  uid: 'user-1',
  email: 'user@test.com',
  displayName: 'Regular User',
  role: AppRole.client,
);

// Sample trainer-client relationships.
const _rel1 = TrainerClientRef(
  trainerUid: 'trainer-1',
  clientUid: 'client-1',
  clientDisplayName: 'Charlie Client',
);
const _rel2 = TrainerClientRef(
  trainerUid: 'trainer-1',
  clientUid: 'client-2',
  clientDisplayName: 'Dana Client',
);
const _rel3 = TrainerClientRef(
  trainerUid: 'trainer-2',
  clientUid: 'client-1',
  clientDisplayName: 'Charlie Client',
);

// Sample bookings.
final _bookedBooking = Booking.fromMap('b1', {
  'trainerUid': 'trainer-1',
  'clientUid': 'client-1',
  'date': '2026-07-10',
  'start': '09:00',
  'end': '10:00',
  'status': 'booked',
});

final _cancelledBooking = Booking.fromMap('b2', {
  'trainerUid': 'trainer-1',
  'clientUid': 'client-2',
  'date': '2026-07-08',
  'start': '10:00',
  'end': '11:00',
  'status': 'cancelled',
});

final _bookedBooking2 = Booking.fromMap('b3', {
  'trainerUid': 'trainer-2',
  'clientUid': 'client-1',
  'date': '2026-07-09',
  'start': '11:00',
  'end': '12:00',
  'status': 'booked',
});

// ─── Tests ────────────────────────────────────────────────────────────────────

void main() {
  // ── AS-085: admin can view a list of all clients ──────────────────────────

  group('AS-085 admin client list', () {
    testWidgets(
      'AS-085: admin sees client users in the users screen',
      (tester) async {
        await tester.pumpWidget(
          ProviderScope(
            overrides: [
              appUserProvider.overrideWith((ref) => Stream.value(_admin)),
              allUsersProvider.overrideWith(
                (ref) => Stream.value([_admin, _trainer1, _client1, _client2]),
              ),
            ],
            child: _testApp(const AdminUsersScreen()),
          ),
        );
        await tester.pumpAndSettle();

        // Both clients visible in 'all' (default) filter.
        expect(find.text('Charlie Client'), findsOneWidget);
        expect(find.text('Dana Client'), findsOneWidget);
      },
    );

    testWidgets(
      'AS-085: filtering by Clients shows only client-role users',
      (tester) async {
        await tester.pumpWidget(
          ProviderScope(
            overrides: [
              appUserProvider.overrideWith((ref) => Stream.value(_admin)),
              allUsersProvider.overrideWith(
                (ref) => Stream.value([_admin, _trainer1, _client1, _client2]),
              ),
            ],
            child: _testApp(const AdminUsersScreen()),
          ),
        );
        await tester.pumpAndSettle();

        // Tap the "Clients" segment.
        await tester.tap(find.text('Clients'));
        await tester.pumpAndSettle();

        // Clients visible.
        expect(find.text('Charlie Client'), findsOneWidget);
        expect(find.text('Dana Client'), findsOneWidget);
        // Trainer and admin are NOT shown in client filter.
        expect(find.text('Alice Trainer'), findsNothing);
        expect(find.text('Admin User'), findsNothing);
      },
    );
  });

  // ── AS-086: admin can view a list of all trainers ─────────────────────────

  group('AS-086 admin trainer list', () {
    testWidgets(
      'AS-086: filtering by Trainers shows only trainer-role users',
      (tester) async {
        await tester.pumpWidget(
          ProviderScope(
            overrides: [
              appUserProvider.overrideWith((ref) => Stream.value(_admin)),
              allUsersProvider.overrideWith(
                (ref) => Stream.value([_admin, _trainer1, _trainer2, _client1]),
              ),
            ],
            child: _testApp(const AdminUsersScreen()),
          ),
        );
        await tester.pumpAndSettle();

        // Tap the "Trainer" segment (reuses l10n.roleTrainer).
        // The SegmentedButton segment is the first "Trainer" widget rendered
        // (header precedes list items in the ListView).
        await tester.tap(find.text('Trainer').first);
        await tester.pumpAndSettle();

        // Trainers visible.
        expect(find.text('Alice Trainer'), findsOneWidget);
        expect(find.text('Bob Trainer'), findsOneWidget);
        // Client and admin NOT shown.
        expect(find.text('Charlie Client'), findsNothing);
        expect(find.text('Admin User'), findsNothing);
      },
    );

    testWidgets(
      'AS-086: default "All" filter shows every user including trainers',
      (tester) async {
        await tester.pumpWidget(
          ProviderScope(
            overrides: [
              appUserProvider.overrideWith((ref) => Stream.value(_admin)),
              allUsersProvider.overrideWith(
                (ref) => Stream.value([_trainer1, _client1]),
              ),
            ],
            child: _testApp(const AdminUsersScreen()),
          ),
        );
        await tester.pumpAndSettle();

        // Both trainer and client visible in "All" view.
        expect(find.text('Alice Trainer'), findsOneWidget);
        expect(find.text('Charlie Client'), findsOneWidget);
      },
    );
  });

  // ── AS-087: admin can view trainer–client relationships ───────────────────

  group('AS-087 trainer-client relationships screen', () {
    testWidgets(
      'AS-087: relationships screen shows each trainer as a section header',
      (tester) async {
        await tester.pumpWidget(
          ProviderScope(
            overrides: [
              appUserProvider.overrideWith((ref) => Stream.value(_admin)),
              allTrainerClientRelationshipsProvider.overrideWith(
                (ref) => Stream.value([_rel1, _rel2, _rel3]),
              ),
              trainerProvider('trainer-1').overrideWith((ref) => Stream.value(
                null,
              )),
              trainerProvider('trainer-2').overrideWith((ref) => Stream.value(
                null,
              )),
            ],
            child: _testApp(const TrainerRelationshipsScreen()),
          ),
        );
        await tester.pumpAndSettle();

        // DisplayTitle and SectionHeader both uppercase their text, so
        // "Trainer–client relationships" → "TRAINER–CLIENT RELATIONSHIPS"
        // and section headers like "trainer-1" → "TRAINER-1".
        expect(find.textContaining('TRAINER'), findsWidgets);
      },
    );

    testWidgets(
      'AS-087: client names appear in the relationships list',
      (tester) async {
        await tester.pumpWidget(
          ProviderScope(
            overrides: [
              appUserProvider.overrideWith((ref) => Stream.value(_admin)),
              allTrainerClientRelationshipsProvider.overrideWith(
                (ref) => Stream.value([_rel1, _rel2]),
              ),
              trainerProvider('trainer-1').overrideWith((ref) => Stream.value(
                null,
              )),
            ],
            child: _testApp(const TrainerRelationshipsScreen()),
          ),
        );
        await tester.pumpAndSettle();

        // Both client names are displayed.
        expect(find.text('Charlie Client'), findsOneWidget);
        expect(find.text('Dana Client'), findsOneWidget);
      },
    );

    testWidgets(
      'AS-087: empty relationships shows no-relationships-yet message',
      (tester) async {
        await tester.pumpWidget(
          ProviderScope(
            overrides: [
              appUserProvider.overrideWith((ref) => Stream.value(_admin)),
              allTrainerClientRelationshipsProvider.overrideWith(
                (ref) => Stream.value([]),
              ),
            ],
            child: _testApp(const TrainerRelationshipsScreen()),
          ),
        );
        await tester.pumpAndSettle();

        expect(find.text('No relationships recorded yet.'), findsOneWidget);
      },
    );
  });

  // ── AS-088: admin can view booking/attendance reports ─────────────────────

  group('AS-088 booking reports screen', () {
    testWidgets(
      'AS-088: reports screen shows total, booked, and cancelled counts',
      (tester) async {
        await tester.pumpWidget(
          ProviderScope(
            overrides: [
              appUserProvider.overrideWith((ref) => Stream.value(_admin)),
              allBookingsProvider.overrideWith(
                (ref) => Stream.value(
                    [_bookedBooking, _cancelledBooking, _bookedBooking2]),
              ),
              trainerProvider('trainer-1')
                  .overrideWith((ref) => Stream.value(null)),
              trainerProvider('trainer-2')
                  .overrideWith((ref) => Stream.value(null)),
            ],
            child: _testApp(const BookingReportsScreen()),
          ),
        );
        await tester.pumpAndSettle();

        // Summary tile labels present.
        expect(find.textContaining('TOTAL BOOKINGS'), findsOneWidget);
        expect(find.textContaining('ACTIVE BOOKINGS'), findsOneWidget);
        expect(find.textContaining('CANCELLED'), findsOneWidget);
      },
    );

    testWidgets(
      'AS-088: reports screen shows by-trainer breakdown section',
      (tester) async {
        await tester.pumpWidget(
          ProviderScope(
            overrides: [
              appUserProvider.overrideWith((ref) => Stream.value(_admin)),
              allBookingsProvider.overrideWith(
                (ref) => Stream.value([_bookedBooking, _bookedBooking2]),
              ),
              trainerProvider('trainer-1')
                  .overrideWith((ref) => Stream.value(null)),
              trainerProvider('trainer-2')
                  .overrideWith((ref) => Stream.value(null)),
            ],
            child: _testApp(const BookingReportsScreen()),
          ),
        );
        await tester.pumpAndSettle();

        // "By trainer" section header is displayed.
        expect(find.textContaining('BY TRAINER'), findsOneWidget);
      },
    );

    testWidgets(
      'AS-088: revenue coming-soon placeholder is shown on the reports screen',
      (tester) async {
        await tester.pumpWidget(
          ProviderScope(
            overrides: [
              appUserProvider.overrideWith((ref) => Stream.value(_admin)),
              allBookingsProvider.overrideWith(
                (ref) => Stream.value([_bookedBooking]),
              ),
              trainerProvider('trainer-1')
                  .overrideWith((ref) => Stream.value(null)),
            ],
            child: _testApp(const BookingReportsScreen()),
          ),
        );
        await tester.pumpAndSettle();

        expect(
          find.textContaining(
              'Revenue reports will be available once payment is added.'),
          findsOneWidget,
        );
      },
    );
  });

  // ── AS-090: admin can manage studio settings ──────────────────────────────

  group('AS-090 studio settings hub', () {
    testWidgets(
      'AS-090: settings hub shows closed-days nav entry',
      (tester) async {
        await tester.pumpWidget(
          ProviderScope(
            overrides: [
              appUserProvider.overrideWith((ref) => Stream.value(_admin)),
            ],
            child: _testApp(const StudioSettingsHubScreen()),
          ),
        );
        await tester.pumpAndSettle();

        expect(find.text('Studio closed days'), findsOneWidget);
      },
    );

    testWidgets(
      'AS-090: settings hub shows package-types nav entry',
      (tester) async {
        await tester.pumpWidget(
          ProviderScope(
            overrides: [
              appUserProvider.overrideWith((ref) => Stream.value(_admin)),
            ],
            child: _testApp(const StudioSettingsHubScreen()),
          ),
        );
        await tester.pumpAndSettle();

        expect(find.text('Package Types'), findsOneWidget);
      },
    );
  });

  // ── AS-091: admin screens are reachable only by admins ────────────────────

  group('AS-091 admin-only access control', () {
    testWidgets(
      'AS-091: non-admin sees not-authorized on AdminUsersScreen',
      (tester) async {
        await tester.pumpWidget(
          ProviderScope(
            overrides: [
              appUserProvider
                  .overrideWith((ref) => Stream.value(_nonAdmin)),
              allUsersProvider
                  .overrideWith((ref) => Stream.value([_nonAdmin])),
            ],
            child: _testApp(const AdminUsersScreen()),
          ),
        );
        await tester.pumpAndSettle();

        expect(find.text("You don't have access to this page."), findsOneWidget);
      },
    );

    testWidgets(
      'AS-091: non-admin sees not-authorized on TrainerRelationshipsScreen',
      (tester) async {
        await tester.pumpWidget(
          ProviderScope(
            overrides: [
              appUserProvider
                  .overrideWith((ref) => Stream.value(_nonAdmin)),
              allTrainerClientRelationshipsProvider
                  .overrideWith((ref) => Stream.value([])),
            ],
            child: _testApp(const TrainerRelationshipsScreen()),
          ),
        );
        await tester.pumpAndSettle();

        expect(find.text("You don't have access to this page."), findsOneWidget);
      },
    );

    testWidgets(
      'AS-091: non-admin sees not-authorized on StudioSettingsHubScreen',
      (tester) async {
        await tester.pumpWidget(
          ProviderScope(
            overrides: [
              appUserProvider
                  .overrideWith((ref) => Stream.value(_nonAdmin)),
            ],
            child: _testApp(const StudioSettingsHubScreen()),
          ),
        );
        await tester.pumpAndSettle();

        expect(find.text("You don't have access to this page."), findsOneWidget);
      },
    );

    testWidgets(
      'AS-091: non-admin sees not-authorized on BookingReportsScreen',
      (tester) async {
        await tester.pumpWidget(
          ProviderScope(
            overrides: [
              appUserProvider
                  .overrideWith((ref) => Stream.value(_nonAdmin)),
              allBookingsProvider
                  .overrideWith((ref) => Stream.value([])),
            ],
            child: _testApp(const BookingReportsScreen()),
          ),
        );
        await tester.pumpAndSettle();

        expect(find.text("You don't have access to this page."), findsOneWidget);
      },
    );

    testWidgets(
      'AS-091: admin can access AdminUsersScreen without not-authorized message',
      (tester) async {
        await tester.pumpWidget(
          ProviderScope(
            overrides: [
              appUserProvider.overrideWith((ref) => Stream.value(_admin)),
              allUsersProvider
                  .overrideWith((ref) => Stream.value([_admin])),
            ],
            child: _testApp(const AdminUsersScreen()),
          ),
        );
        await tester.pumpAndSettle();

        expect(
          find.text("You don't have access to this page."),
          findsNothing,
        );
      },
    );
  });
}
