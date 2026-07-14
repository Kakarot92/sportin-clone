// ignore_for_file: lines_longer_than_80_chars
//
// UI tests for F113 — M12 measurements UI layer.
//
// Assertions covered:
//   AS-056  Client can add a measurement entry via the form.
//   AS-057  Only the client may write measurements; the trainer view is read-only.
//   AS-061  Weight chart is shown when 2+ weight entries exist.
//   AS-062  Client can edit and delete existing measurement entries.
//   AS-063  Trainer can view a client's measurements.
//   AS-064  Trainer cannot add/edit/delete measurements (no write actions in trainer view).
//   AS-065  Home dashboard summary shows sessions attended, active package, and latest measurement.

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sportin_clone/app/theme.dart';
import 'package:sportin_clone/core/models/app_user.dart';
import 'package:sportin_clone/features/auth/application/auth_providers.dart';
import 'package:sportin_clone/features/booking/application/booking_providers.dart';
import 'package:sportin_clone/features/home/presentation/home_screen.dart';
import 'package:sportin_clone/features/measurements/application/dashboard_summary.dart';
import 'package:sportin_clone/features/measurements/application/measurements_providers.dart';
import 'package:sportin_clone/features/measurements/domain/measurement_entry.dart';
import 'package:sportin_clone/features/measurements/domain/trainer_client_ref.dart';
import 'package:sportin_clone/features/measurements/presentation/client_measurements_screen.dart';
import 'package:sportin_clone/features/measurements/presentation/measurements_screen.dart';
import 'package:sportin_clone/features/measurements/presentation/my_clients_screen.dart';
import 'package:sportin_clone/features/packages/domain/client_package.dart';
import 'package:sportin_clone/features/packages/domain/package_type.dart';
import 'package:sportin_clone/l10n/app_localizations.dart';

// ─── Shared test helpers ─────────────────────────────────────────────────────

Widget _testApp(Widget child) => MaterialApp(
      theme: buildDarkTheme(),
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: child,
    );

// ─── Fixtures ────────────────────────────────────────────────────────────────

const _fakeClient = AppUser(
  uid: 'client-1',
  email: 'client@test.com',
  displayName: 'Test Client',
  role: AppRole.client,
);

const _fakeTrainer = AppUser(
  uid: 'trainer-1',
  email: 'trainer@test.com',
  displayName: 'Test Trainer',
  role: AppRole.trainer,
);

final _entryWithWeight = MeasurementEntry(
  id: 'e1',
  clientUid: 'client-1',
  date: '2026-07-01',
  weightKg: 82.5,
  note: 'Jutarnje merenje',
);

final _entryNoWeight = MeasurementEntry(
  id: 'e2',
  clientUid: 'client-1',
  date: '2026-07-10',
  bodyFatPercent: 18.0,
);

final _entryWithWeight2 = MeasurementEntry(
  id: 'e3',
  clientUid: 'client-1',
  date: '2026-07-15',
  weightKg: 81.0,
);

const _fakeClientRef = TrainerClientRef(
  trainerUid: 'trainer-1',
  clientUid: 'client-1',
  clientDisplayName: 'Test Client',
);

// ─── Fake controllers ─────────────────────────────────────────────────────────

class _OkMeasurementsController extends MeasurementsController {
  @override
  Future<bool> addEntry(MeasurementEntry e) async {
    state = const AsyncData(null);
    return true;
  }

  @override
  Future<bool> updateEntry(MeasurementEntry e) async {
    state = const AsyncData(null);
    return true;
  }

  @override
  Future<bool> deleteEntry(String id) async {
    state = const AsyncData(null);
    return true;
  }
}

class _FailMeasurementsController extends MeasurementsController {
  @override
  Future<bool> addEntry(MeasurementEntry e) async {
    await Future<void>.value();
    state = AsyncError(Exception('fail'), StackTrace.empty);
    return false;
  }

  @override
  Future<bool> deleteEntry(String id) async {
    await Future<void>.value();
    state = AsyncError(Exception('fail'), StackTrace.empty);
    return false;
  }
}

// ─── Dashboard summary factory ────────────────────────────────────────────────

DashboardSummary _fakeDashboardSummary({
  required int sessions,
  required String? packageName,
  required double? latestWeight,
}) {
  ClientPackage? pkg;
  if (packageName != null) {
    pkg = ClientPackage(
      id: 'pkg-1',
      clientUid: 'client-1',
      packageTypeId: 'type-1',
      packageTypeName: packageName,
      kind: PackageKind.credits,
      assignedAt: DateTime(2026, 1, 1),
      assignedBy: 'admin',
      startDate: '2026-01-01',
      expiryDate: '2027-01-01',
      remainingCredits: 10,
    );
  }

  MeasurementEntry? latest;
  if (latestWeight != null) {
    latest = MeasurementEntry(
      id: 'e-latest',
      clientUid: 'client-1',
      date: '2026-07-01',
      weightKg: latestWeight,
    );
  }

  return DashboardSummary(
    sessionsAttended: sessions,
    activePackage: pkg,
    latestMeasurement: latest,
  );
}

// ─── Tests ───────────────────────────────────────────────────────────────────

void main() {
  // ── AS-056: client can add a measurement entry ────────────────────────────

  group('AS-056 client add measurement entry', () {
    testWidgets(
      'AS-056: add-measurement button is visible on the measurements screen',
      (tester) async {
        await tester.pumpWidget(
          ProviderScope(
            overrides: [
              appUserProvider
                  .overrideWith((ref) => Stream.value(_fakeClient)),
              clientMeasurementsProvider('client-1')
                  .overrideWith((ref) => Stream.value([])),
            ],
            child: _testApp(const MeasurementsScreen()),
          ),
        );
        await tester.pumpAndSettle();

        // VoltButton with addMeasurement label is present (AS-056).
        expect(find.text('NEW MEASUREMENT'), findsOneWidget);
      },
    );

    testWidgets(
      'AS-056: tapping add-measurement opens a dialog with all input fields',
      (tester) async {
        await tester.pumpWidget(
          ProviderScope(
            overrides: [
              appUserProvider
                  .overrideWith((ref) => Stream.value(_fakeClient)),
              clientMeasurementsProvider('client-1')
                  .overrideWith((ref) => Stream.value([])),
            ],
            child: _testApp(const MeasurementsScreen()),
          ),
        );
        await tester.pumpAndSettle();

        await tester.tap(find.text('NEW MEASUREMENT'));
        await tester.pumpAndSettle();

        // Dialog title shown.
        expect(find.text('New measurement'), findsOneWidget);
        // Weight field present (AS-056).
        expect(find.text('WEIGHT (KG)'), findsOneWidget);
        // Note field present.
        expect(find.text('NOTE'), findsOneWidget);
      },
    );

    testWidgets(
      'AS-056: submitting the add form shows measurementSaved snackbar on success',
      (tester) async {
        await tester.pumpWidget(
          ProviderScope(
            overrides: [
              appUserProvider
                  .overrideWith((ref) => Stream.value(_fakeClient)),
              clientMeasurementsProvider('client-1')
                  .overrideWith((ref) => Stream.value([])),
              measurementsControllerProvider
                  .overrideWith(() => _OkMeasurementsController()),
            ],
            child: _testApp(const MeasurementsScreen()),
          ),
        );
        await tester.pumpAndSettle();

        await tester.tap(find.text('NEW MEASUREMENT'));
        await tester.pumpAndSettle();

        // Tap Save without filling fields (all fields are optional).
        await tester.tap(find.widgetWithText(FilledButton, 'Save'));
        await tester.pumpAndSettle();

        // measurementSaved snackbar shown (AS-056).
        expect(find.text('Measurement saved.'), findsOneWidget);
      },
    );

    testWidgets(
      'AS-056: failed addEntry shows errorGeneric snackbar',
      (tester) async {
        await tester.pumpWidget(
          ProviderScope(
            overrides: [
              appUserProvider
                  .overrideWith((ref) => Stream.value(_fakeClient)),
              clientMeasurementsProvider('client-1')
                  .overrideWith((ref) => Stream.value([])),
              measurementsControllerProvider
                  .overrideWith(() => _FailMeasurementsController()),
            ],
            child: _testApp(const MeasurementsScreen()),
          ),
        );
        await tester.pumpAndSettle();

        await tester.tap(find.text('NEW MEASUREMENT'));
        await tester.pumpAndSettle();

        await tester.tap(find.widgetWithText(FilledButton, 'Save'));
        await tester.pumpAndSettle();

        // Generic error snackbar shown when save fails (AS-056).
        expect(find.text('Something went wrong. Please try again.'),
            findsOneWidget);
      },
    );
  });

  // ── AS-057: only the client may write measurements ────────────────────────

  group('AS-057 client-only write access', () {
    testWidgets(
      'AS-057: client view has edit and delete action icons on entry cards',
      (tester) async {
        await tester.pumpWidget(
          ProviderScope(
            overrides: [
              appUserProvider
                  .overrideWith((ref) => Stream.value(_fakeClient)),
              clientMeasurementsProvider('client-1')
                  .overrideWith(
                      (ref) => Stream.value([_entryWithWeight])),
            ],
            child: _testApp(const MeasurementsScreen()),
          ),
        );
        await tester.pumpAndSettle();

        // Edit and delete icon buttons are visible (AS-057 — client CAN write).
        expect(find.byIcon(Icons.edit_outlined), findsOneWidget);
        expect(find.byIcon(Icons.delete_outline), findsOneWidget);
      },
    );

    testWidgets(
      'AS-057: trainer view (ClientMeasurementsScreen) has NO add button',
      (tester) async {
        await tester.pumpWidget(
          ProviderScope(
            overrides: [
              appUserProvider
                  .overrideWith((ref) => Stream.value(_fakeTrainer)),
              clientMeasurementsProvider('client-1')
                  .overrideWith(
                      (ref) => Stream.value([_entryWithWeight])),
            ],
            child: _testApp(const ClientMeasurementsScreen(
              clientUid: 'client-1',
              clientDisplayName: 'Test Client',
            )),
          ),
        );
        await tester.pumpAndSettle();

        // Trainer view must not show an add-measurement button (AS-057).
        expect(find.text('NEW MEASUREMENT'), findsNothing);
      },
    );
  });

  // ── AS-061: weight chart shown when 2+ weight entries ────────────────────

  group('AS-061 weight chart display', () {
    testWidgets(
      'AS-061: LineChart widget is present when 2 or more entries have weightKg',
      (tester) async {
        await tester.pumpWidget(
          ProviderScope(
            overrides: [
              appUserProvider
                  .overrideWith((ref) => Stream.value(_fakeClient)),
              clientMeasurementsProvider('client-1').overrideWith(
                  // Newest-first as per provider contract; chart reverses.
                  (ref) => Stream.value(
                      [_entryWithWeight2, _entryWithWeight])),
            ],
            child: _testApp(const MeasurementsScreen()),
          ),
        );
        await tester.pumpAndSettle();

        // fl_chart LineChart widget rendered (AS-061).
        expect(find.byType(LineChart), findsOneWidget);
      },
    );

    testWidgets(
      'AS-061: LineChart is absent when only one entry has weightKg',
      (tester) async {
        await tester.pumpWidget(
          ProviderScope(
            overrides: [
              appUserProvider
                  .overrideWith((ref) => Stream.value(_fakeClient)),
              clientMeasurementsProvider('client-1').overrideWith(
                  (ref) => Stream.value([_entryWithWeight])),
            ],
            child: _testApp(const MeasurementsScreen()),
          ),
        );
        await tester.pumpAndSettle();

        // Chart absent with only 1 weight entry (AS-061).
        expect(find.byType(LineChart), findsNothing);
      },
    );

    testWidgets(
      'AS-061: LineChart is absent when no entries have weightKg',
      (tester) async {
        await tester.pumpWidget(
          ProviderScope(
            overrides: [
              appUserProvider
                  .overrideWith((ref) => Stream.value(_fakeClient)),
              clientMeasurementsProvider('client-1').overrideWith(
                  (ref) => Stream.value([_entryNoWeight])),
            ],
            child: _testApp(const MeasurementsScreen()),
          ),
        );
        await tester.pumpAndSettle();

        expect(find.byType(LineChart), findsNothing);
      },
    );
  });

  // ── AS-062: client can edit and delete entries ────────────────────────────

  group('AS-062 client edit and delete entries', () {
    testWidgets(
      'AS-062: tapping the edit icon opens the edit dialog pre-filled with existing weight',
      (tester) async {
        await tester.pumpWidget(
          ProviderScope(
            overrides: [
              appUserProvider
                  .overrideWith((ref) => Stream.value(_fakeClient)),
              clientMeasurementsProvider('client-1')
                  .overrideWith(
                      (ref) => Stream.value([_entryWithWeight])),
            ],
            child: _testApp(const MeasurementsScreen()),
          ),
        );
        await tester.pumpAndSettle();

        // Tap the edit icon on the card.
        await tester.tap(find.byIcon(Icons.edit_outlined));
        await tester.pumpAndSettle();

        // Edit dialog title shown (AS-062).
        expect(find.text('Edit measurement'), findsOneWidget);
        // Pre-filled weight value is visible.
        expect(find.text('82.5'), findsOneWidget);
      },
    );

    testWidgets(
      'AS-062: confirming edit shows measurementSaved snackbar',
      (tester) async {
        await tester.pumpWidget(
          ProviderScope(
            overrides: [
              appUserProvider
                  .overrideWith((ref) => Stream.value(_fakeClient)),
              clientMeasurementsProvider('client-1')
                  .overrideWith(
                      (ref) => Stream.value([_entryWithWeight])),
              measurementsControllerProvider
                  .overrideWith(() => _OkMeasurementsController()),
            ],
            child: _testApp(const MeasurementsScreen()),
          ),
        );
        await tester.pumpAndSettle();

        await tester.tap(find.byIcon(Icons.edit_outlined));
        await tester.pumpAndSettle();

        await tester.tap(find.widgetWithText(FilledButton, 'Save'));
        await tester.pumpAndSettle();

        // measurementSaved shown after successful edit (AS-062).
        expect(find.text('Measurement saved.'), findsOneWidget);
      },
    );

    testWidgets(
      'AS-062: tapping the delete icon opens a confirmation dialog',
      (tester) async {
        await tester.pumpWidget(
          ProviderScope(
            overrides: [
              appUserProvider
                  .overrideWith((ref) => Stream.value(_fakeClient)),
              clientMeasurementsProvider('client-1')
                  .overrideWith(
                      (ref) => Stream.value([_entryWithWeight])),
            ],
            child: _testApp(const MeasurementsScreen()),
          ),
        );
        await tester.pumpAndSettle();

        await tester.tap(find.byIcon(Icons.delete_outline));
        await tester.pumpAndSettle();

        // Delete confirmation dialog shown — text appears in title AND in the
        // confirm button, so we check for at least one occurrence (AS-062).
        expect(find.text('Delete measurement'), findsAtLeastNWidgets(1));
      },
    );

    testWidgets(
      'AS-062: confirming delete shows measurementDeleted snackbar',
      (tester) async {
        await tester.pumpWidget(
          ProviderScope(
            overrides: [
              appUserProvider
                  .overrideWith((ref) => Stream.value(_fakeClient)),
              clientMeasurementsProvider('client-1')
                  .overrideWith(
                      (ref) => Stream.value([_entryWithWeight])),
              measurementsControllerProvider
                  .overrideWith(() => _OkMeasurementsController()),
            ],
            child: _testApp(const MeasurementsScreen()),
          ),
        );
        await tester.pumpAndSettle();

        await tester.tap(find.byIcon(Icons.delete_outline));
        await tester.pumpAndSettle();

        // Confirm deletion via FilledButton in the dialog.
        await tester
            .tap(find.widgetWithText(FilledButton, 'Delete measurement'));
        await tester.pumpAndSettle();

        // measurementDeleted snackbar shown (AS-062).
        expect(find.text('Measurement deleted.'), findsOneWidget);
      },
    );
  });

  // ── AS-063: trainer can view a client's measurements ─────────────────────

  group('AS-063 trainer reads client measurements', () {
    testWidgets(
      'AS-063: MyClientsScreen shows client names in trainer client list',
      (tester) async {
        await tester.pumpWidget(
          ProviderScope(
            overrides: [
              appUserProvider
                  .overrideWith((ref) => Stream.value(_fakeTrainer)),
              myClientsProvider('trainer-1')
                  .overrideWith(
                      (ref) => Stream.value([_fakeClientRef])),
            ],
            child: _testApp(const MyClientsScreen()),
          ),
        );
        await tester.pumpAndSettle();

        // Client name visible in the list (AS-063).
        expect(find.text('TEST CLIENT'), findsOneWidget);
      },
    );

    testWidgets(
      'AS-063: MyClientsScreen shows noClientsYet when list is empty',
      (tester) async {
        await tester.pumpWidget(
          ProviderScope(
            overrides: [
              appUserProvider
                  .overrideWith((ref) => Stream.value(_fakeTrainer)),
              myClientsProvider('trainer-1')
                  .overrideWith((ref) => Stream.value([])),
            ],
            child: _testApp(const MyClientsScreen()),
          ),
        );
        await tester.pumpAndSettle();

        expect(find.text("You don't have any clients yet."),
            findsOneWidget);
      },
    );

    testWidgets(
      'AS-063: MyClientsScreen shows notAuthorized when user is not a trainer',
      (tester) async {
        await tester.pumpWidget(
          ProviderScope(
            overrides: [
              appUserProvider
                  .overrideWith((ref) => Stream.value(_fakeClient)),
            ],
            child: _testApp(const MyClientsScreen()),
          ),
        );
        await tester.pumpAndSettle();

        expect(find.text("You don't have access to this page."),
            findsOneWidget);
      },
    );

    testWidgets(
      'AS-063: ClientMeasurementsScreen shows client measurement weight for trainer',
      (tester) async {
        await tester.pumpWidget(
          ProviderScope(
            overrides: [
              appUserProvider
                  .overrideWith((ref) => Stream.value(_fakeTrainer)),
              clientMeasurementsProvider('client-1').overrideWith(
                  (ref) => Stream.value([_entryWithWeight])),
            ],
            child: _testApp(const ClientMeasurementsScreen(
              clientUid: 'client-1',
              clientDisplayName: 'Test Client',
            )),
          ),
        );
        await tester.pumpAndSettle();

        // The weight value is shown in the read-only card (AS-063).
        expect(find.textContaining('82,5 kg'), findsOneWidget);
      },
    );
  });

  // ── AS-064: trainer cannot write measurements ─────────────────────────────

  group('AS-064 trainer read-only enforcement', () {
    testWidgets(
      'AS-064: ClientMeasurementsScreen has no edit or delete icon buttons',
      (tester) async {
        await tester.pumpWidget(
          ProviderScope(
            overrides: [
              appUserProvider
                  .overrideWith((ref) => Stream.value(_fakeTrainer)),
              clientMeasurementsProvider('client-1').overrideWith(
                  (ref) => Stream.value([_entryWithWeight])),
            ],
            child: _testApp(const ClientMeasurementsScreen(
              clientUid: 'client-1',
            )),
          ),
        );
        await tester.pumpAndSettle();

        // No edit or delete action icons in the trainer view (AS-064).
        expect(find.byIcon(Icons.edit_outlined), findsNothing);
        expect(find.byIcon(Icons.delete_outline), findsNothing);
      },
    );

    testWidgets(
      'AS-064: ClientMeasurementsScreen shows notAuthorized for non-trainer',
      (tester) async {
        await tester.pumpWidget(
          ProviderScope(
            overrides: [
              appUserProvider
                  .overrideWith((ref) => Stream.value(_fakeClient)),
              clientMeasurementsProvider('client-1').overrideWith(
                  (ref) => Stream.value([_entryWithWeight])),
            ],
            child: _testApp(const ClientMeasurementsScreen(
              clientUid: 'client-1',
            )),
          ),
        );
        await tester.pumpAndSettle();

        expect(find.text("You don't have access to this page."),
            findsOneWidget);
      },
    );
  });

  // ── AS-065: home dashboard summary ───────────────────────────────────────
  //
  // HomeScreen contains Marquee (infinite AnimationController.repeat()) and
  // Reveal (finite). pumpAndSettle never settles on infinite animations, so
  // all AS-065 tests use pump(Duration(seconds: 3)) instead — enough for
  // Reveal and CountUp to complete without waiting on the Marquee loop.

  group('AS-065 home dashboard summary', () {
    Future<void> pumpHome(
      WidgetTester tester,
      DashboardSummary summary,
    ) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            appUserProvider
                .overrideWith((ref) => Stream.value(_fakeClient)),
            clientUpcomingBookingsProvider('client-1')
                .overrideWith((ref) => Stream.value([])),
            dashboardSummaryProvider('client-1')
                .overrideWith((ref) => AsyncData(summary)),
          ],
          child: _testApp(const HomeScreen()),
        ),
      );
      // Pump enough frames for Reveal + CountUp to finish (1.1 s animation),
      // but do NOT call pumpAndSettle which times out on the Marquee loop.
      await tester.pump();
      await tester.pump(const Duration(seconds: 2));
    }

    testWidgets(
      'AS-065: dashboard shows sessions attended label and count',
      (tester) async {
        await pumpHome(
          tester,
          _fakeDashboardSummary(sessions: 5, packageName: null, latestWeight: null),
        );

        // Sessions label is shown (AS-065).
        expect(find.text('SESSIONS ATTENDED'), findsOneWidget);
        // CountUp renders the value after animation; '5' visible.
        expect(find.text('5'), findsOneWidget);
      },
    );

    testWidgets(
      'AS-065: dashboard shows active package name',
      (tester) async {
        await pumpHome(
          tester,
          _fakeDashboardSummary(sessions: 0, packageName: 'Gold', latestWeight: null),
        );

        // Active package name rendered (AS-065).
        expect(find.text('Gold'), findsOneWidget);
      },
    );

    testWidgets(
      'AS-065: dashboard shows noPackage when activePackage is null',
      (tester) async {
        await pumpHome(
          tester,
          _fakeDashboardSummary(sessions: 0, packageName: null, latestWeight: null),
        );

        // 'No package' shown when no active package (AS-065).
        expect(find.text('No package'), findsOneWidget);
      },
    );

    testWidgets(
      'AS-065: dashboard shows latest weight when measurement exists',
      (tester) async {
        await pumpHome(
          tester,
          _fakeDashboardSummary(sessions: 3, packageName: null, latestWeight: 80.5),
        );

        // Latest weight visible formatted in Serbian decimal style (AS-065).
        expect(find.textContaining('80,5 kg'), findsOneWidget);
      },
    );

    testWidgets(
      'AS-065: dashboard shows em-dash when no measurement exists',
      (tester) async {
        await pumpHome(
          tester,
          _fakeDashboardSummary(sessions: 0, packageName: null, latestWeight: null),
        );

        // Em-dash rendered when no latest measurement (AS-065).
        expect(find.text('—'), findsOneWidget);
      },
    );
  });
}
