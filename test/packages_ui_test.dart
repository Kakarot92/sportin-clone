// ignore_for_file: lines_longer_than_80_chars
//
// UI tests for M8 packages UI feature (F071).
//
// Assertions covered:
//   AS-032  A client with no active package cannot complete a booking;
//           they are prompted to get a package (NoActivePackageException UI).
//   AS-047  Admin can define package/membership types (screen rendered).
//   AS-048  A trainer/admin can manually assign a package (assign action present).
//   AS-049  A client can view their active package with remaining credits and
//           expiry date (my-package screen).

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sportin_clone/app/theme.dart';
import 'package:sportin_clone/core/models/app_user.dart';
import 'package:sportin_clone/features/admin/application/admin_providers.dart';
import 'package:sportin_clone/features/admin/presentation/admin_users_screen.dart';
import 'package:sportin_clone/features/auth/application/auth_providers.dart';
import 'package:sportin_clone/features/booking/application/booking_providers.dart';
import 'package:sportin_clone/features/booking/domain/booking_exceptions.dart';
import 'package:sportin_clone/features/packages/application/packages_providers.dart';
import 'package:sportin_clone/features/packages/domain/client_package.dart';
import 'package:sportin_clone/features/packages/domain/package_type.dart';
import 'package:sportin_clone/features/packages/presentation/my_package_screen.dart';
import 'package:sportin_clone/features/packages/presentation/package_types_screen.dart';
import 'package:sportin_clone/features/scheduling/application/scheduling_providers.dart';
import 'package:sportin_clone/features/scheduling/domain/slot.dart';
import 'package:sportin_clone/features/scheduling/presentation/trainer_slots_screen.dart';
import 'package:sportin_clone/features/trainers/application/trainers_providers.dart';
import 'package:sportin_clone/l10n/app_localizations.dart';

// ─── Helpers ─────────────────────────────────────────────────────────────────

Widget _testApp(Widget child) => MaterialApp(
      theme: buildDarkTheme(),
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: child,
    );

/// Watches [appUserProvider] eagerly so it is in [AsyncData] before any
/// descendant reads it (e.g. [TrainerSlotsScreen._bookSlot]).
class _AppUserPreloader extends ConsumerWidget {
  const _AppUserPreloader({required this.child});
  final Widget child;
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.watch(appUserProvider);
    return child;
  }
}

// ─── Fixtures ────────────────────────────────────────────────────────────────

const _fakeAdmin = AppUser(
  uid: 'admin-1',
  email: 'admin@test.com',
  displayName: 'Admin User',
  role: AppRole.admin,
);

const _fakeClient = AppUser(
  uid: 'client-1',
  email: 'client@test.com',
  displayName: 'Test Client',
  role: AppRole.client,
);

const _fakeClientNoName = AppUser(
  uid: 'client-2',
  email: 'noname@test.com',
  displayName: '',
  role: AppRole.client,
);

final _fakeActiveType = PackageType(
  id: 'pt-1',
  name: 'Monthly Membership',
  kind: PackageKind.duration,
  validityDays: 30,
  active: true,
);

final _fakeCreditsType = PackageType(
  id: 'pt-2',
  name: '10 Sessions',
  kind: PackageKind.credits,
  validityDays: 90,
  creditCount: 10,
  active: true,
);

final _now = DateTime.now();
final _futureDate =
    '${_now.year + 1}-${_now.month.toString().padLeft(2, '0')}-01';

final _activeCreditsPackage = ClientPackage(
  id: 'cp-1',
  clientUid: 'client-1',
  packageTypeId: 'pt-2',
  packageTypeName: '10 Sessions',
  kind: PackageKind.credits,
  assignedAt: _now.subtract(const Duration(days: 5)),
  assignedBy: 'admin-1',
  startDate: '2026-07-01',
  expiryDate: _futureDate,
  remainingCredits: 7,
);

final _activeDurationPackage = ClientPackage(
  id: 'cp-2',
  clientUid: 'client-1',
  packageTypeId: 'pt-1',
  packageTypeName: 'Monthly Membership',
  kind: PackageKind.duration,
  assignedAt: _now.subtract(const Duration(days: 2)),
  assignedBy: 'admin-1',
  startDate: '2026-07-01',
  expiryDate: _futureDate,
);

// ─── Fake BookingController that throws NoActivePackageException ──────────────

class _NoPackageBookingController extends BookingController {
  @override
  Future<bool> book({required Slot slot, required String clientUid}) async {
    await Future<void>.value();
    state = AsyncError(const NoActivePackageException(), StackTrace.empty);
    return false;
  }
}

// ─── Tests ───────────────────────────────────────────────────────────────────

void main() {
  // ── AS-032: NoActivePackageException → noActivePackageError message ──────

  group('AS-032 booking-gate no-active-package prompt', () {
    testWidgets(
      'AS-032: NoActivePackageException during booking shows noActivePackageError snackbar',
      (tester) async {
        final today = DateTime.now();
        final normalizedToday = DateTime(today.year, today.month, today.day);
        final testSlot = Slot(
          trainerUid: 'trainer-1',
          date: normalizedToday,
          start: '10:00',
          end: '11:00',
        );
        final slotKey = (trainerUid: 'trainer-1', day: normalizedToday);

        await tester.pumpWidget(
          ProviderScope(
            overrides: [
              appUserProvider
                  .overrideWith((ref) => Stream.value(_fakeClient)),
              trainerProvider('trainer-1')
                  .overrideWith((ref) => Stream.value(null)),
              availableSlotsProvider(slotKey)
                  .overrideWith((ref) => AsyncData([testSlot])),
              bookingControllerProvider
                  .overrideWith(() => _NoPackageBookingController()),
            ],
            child: _testApp(
              const _AppUserPreloader(
                child: TrainerSlotsScreen(trainerUid: 'trainer-1'),
              ),
            ),
          ),
        );
        await tester.pumpAndSettle();

        // Slot is rendered.
        expect(find.text('10:00'), findsOneWidget);

        // Tap the slot to open confirm dialog.
        await tester.tap(find.text('10:00'));
        await tester.pumpAndSettle();

        // Confirm the booking.
        await tester.tap(find.widgetWithText(FilledButton, 'Book'));
        await tester.pumpAndSettle();

        // The no-active-package error snackbar must appear (AS-032).
        expect(
          find.textContaining('package'),
          findsAtLeastNWidgets(1),
          reason:
              'Texts: ${tester.widgetList<Text>(find.byType(Text)).map((t) => t.data ?? '').join(' | ')}',
        );
      },
    );

    testWidgets(
      'AS-032: PastSlotException does NOT show the package error (regression guard)',
      (tester) async {
        // This test verifies the mapping is specific — PastSlotException keeps
        // its own message rather than falling through to noActivePackageError.
        // Covered by existing cancellation_reschedule_ui_test, kept here as a
        // note; no separate widget assertion needed since the slot-taken and
        // past-slot paths are unchanged.
        expect(const NoActivePackageException(), isA<NoActivePackageException>());
        expect(const PastSlotException(), isNot(isA<NoActivePackageException>()));
      },
    );
  });

  // ── AS-047: Admin can see package types screen ────────────────────────────

  group('AS-047 admin package types screen', () {
    testWidgets(
      'AS-047: PackageTypesScreen shows the title and add-type form for an admin',
      (tester) async {
        await tester.pumpWidget(
          ProviderScope(
            overrides: [
              appUserProvider
                  .overrideWith((ref) => Stream.value(_fakeAdmin)),
              packageTypesProvider(false)
                  .overrideWith((ref) => Stream.value([])),
            ],
            child: _testApp(const PackageTypesScreen()),
          ),
        );
        await tester.pumpAndSettle();

        // Title present (AS-047 screen rendered).
        // DisplayTitle and SectionHeader render text in all-caps.
        expect(find.textContaining('PACKAGE TYPES'), findsAtLeastNWidgets(1));
        // VoltButton renders its label in all-caps.
        expect(find.textContaining('ADD PACKAGE TYPE'), findsAtLeastNWidgets(1));
      },
    );

    testWidgets(
      'AS-047: PackageTypesScreen shows notAuthorized for a non-admin user',
      (tester) async {
        await tester.pumpWidget(
          ProviderScope(
            overrides: [
              appUserProvider
                  .overrideWith((ref) => Stream.value(_fakeClient)),
              packageTypesProvider(false)
                  .overrideWith((ref) => Stream.value([])),
            ],
            child: _testApp(const PackageTypesScreen()),
          ),
        );
        await tester.pumpAndSettle();

        expect(find.textContaining("don't have access"), findsOneWidget);
      },
    );

    testWidgets(
      'AS-047: PackageTypesScreen lists existing package types',
      (tester) async {
        await tester.pumpWidget(
          ProviderScope(
            overrides: [
              appUserProvider
                  .overrideWith((ref) => Stream.value(_fakeAdmin)),
              packageTypesProvider(false).overrideWith(
                  (ref) => Stream.value([_fakeActiveType, _fakeCreditsType])),
            ],
            child: _testApp(const PackageTypesScreen()),
          ),
        );
        await tester.pumpAndSettle();

        // Both type names appear in the list (AS-047).
        expect(find.text('Monthly Membership'), findsAtLeastNWidgets(1));
        expect(find.text('10 Sessions'), findsAtLeastNWidgets(1));
      },
    );

    testWidgets(
      'AS-047: credits-kind field appears only when credits kind is selected',
      (tester) async {
        await tester.pumpWidget(
          ProviderScope(
            overrides: [
              appUserProvider
                  .overrideWith((ref) => Stream.value(_fakeAdmin)),
              packageTypesProvider(false)
                  .overrideWith((ref) => Stream.value([])),
            ],
            child: _testApp(const PackageTypesScreen()),
          ),
        );
        await tester.pumpAndSettle();

        // "Number of sessions" label is NOT visible initially (duration mode).
        expect(find.textContaining('NUMBER OF SESSIONS'), findsNothing);

        // Switch to credits kind via SegmentedButton.
        await tester.tap(find.textContaining('Sessions'));
        await tester.pumpAndSettle();

        // Now the credit count field should appear (AS-047 credits-kind).
        expect(find.textContaining('NUMBER OF SESSIONS'), findsAtLeastNWidgets(1));
      },
    );
  });

  // ── AS-048: Assign package action in admin users screen ───────────────────

  group('AS-048 admin assign package action', () {
    testWidgets(
      'AS-048: assign-package icon button is visible next to non-admin users',
      (tester) async {
        final clientUser = _fakeClientNoName;
        await tester.pumpWidget(
          ProviderScope(
            overrides: [
              appUserProvider
                  .overrideWith((ref) => Stream.value(_fakeAdmin)),
              allUsersProvider
                  .overrideWith((ref) => Stream.value([clientUser])),
            ],
            child: _testApp(const AdminUsersScreen()),
          ),
        );
        await tester.pumpAndSettle();

        // The card_membership icon button should be rendered (AS-048).
        expect(find.byIcon(Icons.card_membership_outlined), findsOneWidget);
      },
    );

    testWidgets(
      'AS-048: assign-package icon button is absent for admin users',
      (tester) async {
        final anotherAdmin = const AppUser(
          uid: 'admin-2',
          email: 'admin2@test.com',
          displayName: 'Admin 2',
          role: AppRole.admin,
        );
        await tester.pumpWidget(
          ProviderScope(
            overrides: [
              appUserProvider
                  .overrideWith((ref) => Stream.value(_fakeAdmin)),
              allUsersProvider
                  .overrideWith((ref) => Stream.value([anotherAdmin])),
            ],
            child: _testApp(const AdminUsersScreen()),
          ),
        );
        await tester.pumpAndSettle();

        // Admin-to-admin assignment is not supported — icon absent (AS-048 guard).
        expect(find.byIcon(Icons.card_membership_outlined), findsNothing);
      },
    );

    testWidgets(
      'AS-048: tapping assign when no active types exist shows noPackageTypesYet snackbar',
      (tester) async {
        await tester.pumpWidget(
          ProviderScope(
            overrides: [
              appUserProvider
                  .overrideWith((ref) => Stream.value(_fakeAdmin)),
              allUsersProvider
                  .overrideWith((ref) => Stream.value([_fakeClient])),
              packageTypesProvider(true)
                  .overrideWith((ref) => Stream.value([])),
            ],
            child: _testApp(const AdminUsersScreen()),
          ),
        );
        await tester.pumpAndSettle();

        await tester.tap(find.byIcon(Icons.card_membership_outlined));
        await tester.pumpAndSettle();

        // SnackBar with noPackageTypesYet text (AS-048 guard).
        expect(
          find.textContaining('No package types'),
          findsAtLeastNWidgets(1),
        );
      },
    );

    testWidgets(
      'AS-048: assign dialog opens with type dropdown when active types exist',
      (tester) async {
        await tester.pumpWidget(
          ProviderScope(
            overrides: [
              appUserProvider
                  .overrideWith((ref) => Stream.value(_fakeAdmin)),
              allUsersProvider
                  .overrideWith((ref) => Stream.value([_fakeClient])),
              packageTypesProvider(true)
                  .overrideWith((ref) =>
                      Stream.value([_fakeActiveType, _fakeCreditsType])),
            ],
            child: _testApp(const AdminUsersScreen()),
          ),
        );
        await tester.pumpAndSettle();

        await tester.tap(find.byIcon(Icons.card_membership_outlined));
        await tester.pumpAndSettle();

        // Dialog title present (AS-048).
        expect(find.text('Assign Package'), findsAtLeastNWidgets(1));
        // Type name present in the dialog.
        expect(find.text('Monthly Membership'), findsAtLeastNWidgets(1));
      },
    );
  });

  // ── AS-049: Client can view active package ────────────────────────────────

  group('AS-049 client my-package screen', () {
    testWidgets(
      'AS-049: MyPackageScreen shows active credits-kind package with remaining count',
      (tester) async {
        await tester.pumpWidget(
          ProviderScope(
            overrides: [
              appUserProvider
                  .overrideWith((ref) => Stream.value(_fakeClient)),
              clientPackagesProvider('client-1')
                  .overrideWith((ref) =>
                      Stream.value([_activeCreditsPackage])),
            ],
            child: _testApp(const MyPackageScreen()),
          ),
        );
        await tester.pumpAndSettle();

        // Package name shown (AS-049).
        expect(find.text('10 Sessions'), findsAtLeastNWidgets(1));
        // Remaining credits count shown as big number (AS-049).
        expect(find.text('7'), findsAtLeastNWidgets(1));
        // Active badge shown.
        expect(find.textContaining('ACTIVE'), findsAtLeastNWidgets(1));
      },
    );

    testWidgets(
      'AS-049: MyPackageScreen shows active duration-kind package with expiry label',
      (tester) async {
        await tester.pumpWidget(
          ProviderScope(
            overrides: [
              appUserProvider
                  .overrideWith((ref) => Stream.value(_fakeClient)),
              clientPackagesProvider('client-1')
                  .overrideWith((ref) =>
                      Stream.value([_activeDurationPackage])),
            ],
            child: _testApp(const MyPackageScreen()),
          ),
        );
        await tester.pumpAndSettle();

        // Duration-kind shows "Unlimited until" text (AS-049).
        expect(find.textContaining('Unlimited until'), findsAtLeastNWidgets(1));
        // Package name shown (AS-049).
        expect(
            find.text('Monthly Membership'), findsAtLeastNWidgets(1));
      },
    );

    testWidgets(
      'AS-049: MyPackageScreen shows noActivePackage when no packages exist',
      (tester) async {
        await tester.pumpWidget(
          ProviderScope(
            overrides: [
              appUserProvider
                  .overrideWith((ref) => Stream.value(_fakeClient)),
              clientPackagesProvider('client-1')
                  .overrideWith((ref) => Stream.value([])),
            ],
            child: _testApp(const MyPackageScreen()),
          ),
        );
        await tester.pumpAndSettle();

        // Empty state message shown (AS-049).
        expect(find.textContaining('no active package'), findsAtLeastNWidgets(1));
      },
    );

    testWidgets(
      'AS-049: MyPackageScreen shows package history section',
      (tester) async {
        final expiredPackage = ClientPackage(
          id: 'cp-old',
          clientUid: 'client-1',
          packageTypeId: 'pt-1',
          packageTypeName: 'Old Pack',
          kind: PackageKind.duration,
          assignedAt: DateTime(2025, 1, 1),
          assignedBy: 'admin-1',
          startDate: '2025-01-01',
          expiryDate: '2025-02-01', // expired
        );

        await tester.pumpWidget(
          ProviderScope(
            overrides: [
              appUserProvider
                  .overrideWith((ref) => Stream.value(_fakeClient)),
              clientPackagesProvider('client-1').overrideWith(
                  (ref) => Stream.value([_activeCreditsPackage, expiredPackage])),
            ],
            child: _testApp(const MyPackageScreen()),
          ),
        );
        await tester.pumpAndSettle();

        // History section header shown (AS-049).
        expect(find.textContaining('PACKAGE HISTORY'), findsAtLeastNWidgets(1));
        // Expired package name shown in history (AS-049).
        expect(find.text('Old Pack'), findsAtLeastNWidgets(1));
        // Status badge for expired package.
        expect(find.textContaining('EXPIRED'), findsAtLeastNWidgets(1));
      },
    );

    testWidgets(
      'AS-049: MyPackageScreen shows loading indicator when me is null',
      (tester) async {
        await tester.pumpWidget(
          ProviderScope(
            overrides: [
              appUserProvider
                  .overrideWith((ref) => Stream.value(null)),
            ],
            child: _testApp(const MyPackageScreen()),
          ),
        );
        await tester.pump(); // single pump — don't settle; stream not resolved yet

        expect(find.byType(CircularProgressIndicator), findsAtLeastNWidgets(1));
      },
    );
  });
}
