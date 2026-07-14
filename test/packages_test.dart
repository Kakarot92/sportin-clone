// Packages domain model unit tests.
//
// No Firebase setup required — these are pure model/logic tests.
//
// Assertions covered:
//   AS-047  Admin can define package/membership types.
//   AS-048  A trainer/admin can manually assign a package to a client.
//   AS-049  A client can view their active package with remaining credits and
//           expiry date. (isActive logic tested here.)
//   AS-053  An expired package cannot be used to book sessions.
//   AS-054  A booking is blocked when the client has no remaining credits or
//           valid membership.

import 'package:flutter_test/flutter_test.dart';
import 'package:sportin_clone/features/packages/domain/client_package.dart';
import 'package:sportin_clone/features/packages/domain/package_type.dart';

void main() {
  // Fixed "now" used throughout — noon on the current test date so we have
  // a stable reference for before/today/after comparisons.
  final now = DateTime(2026, 7, 14, 12, 0, 0);

  // ── ClientPackage.isActive ──────────────────────────────────────────────────

  group('ClientPackage.isActive', () {
    ClientPackage makeDuration({
      required String expiryDate,
    }) =>
        ClientPackage(
          id: 'p-dur',
          clientUid: 'c1',
          packageTypeId: 'pt1',
          packageTypeName: 'Monthly',
          kind: PackageKind.duration,
          assignedAt: now.subtract(const Duration(days: 5)),
          assignedBy: 'admin1',
          startDate: '2026-07-09',
          expiryDate: expiryDate,
        );

    ClientPackage makeCredits({
      required String expiryDate,
      required int remainingCredits,
    }) =>
        ClientPackage(
          id: 'p-cred',
          clientUid: 'c1',
          packageTypeId: 'pt2',
          packageTypeName: '10 Sessions',
          kind: PackageKind.credits,
          assignedAt: now.subtract(const Duration(days: 5)),
          assignedBy: 'admin1',
          startDate: '2026-07-09',
          expiryDate: expiryDate,
          remainingCredits: remainingCredits,
        );

    test(
      'AS-049 AS-053: duration-kind with expiry in the future is active',
      () {
        final pkg = makeDuration(expiryDate: '2026-08-14');
        expect(pkg.isActive(now: now), isTrue);
      },
    );

    test(
      'AS-053: duration-kind with expiry yesterday (2026-07-13) is not active',
      () {
        // now = 2026-07-14 12:00 → isAfter(2026-07-13 23:59:59) → expired
        final pkg = makeDuration(expiryDate: '2026-07-13');
        expect(pkg.isActive(now: now), isFalse);
      },
    );

    test(
      'AS-049 AS-054: credits-kind with expiry in future and remainingCredits=3 '
      'is active',
      () {
        final pkg = makeCredits(expiryDate: '2026-08-14', remainingCredits: 3);
        expect(pkg.isActive(now: now), isTrue);
      },
    );

    test(
      'AS-054: credits-kind with expiry in future but remainingCredits=0 '
      'is NOT active',
      () {
        final pkg = makeCredits(expiryDate: '2026-08-14', remainingCredits: 0);
        expect(pkg.isActive(now: now), isFalse);
      },
    );

    test(
      'AS-053: credits-kind with expiryDate == today (2026-07-14) at noon '
      'is still active — expiry is inclusive through end of day',
      () {
        // now = 2026-07-14 12:00; expired check:
        //   now.isAfter(DateTime(2026,7,14,23,59,59)) → false → not expired.
        final pkg = makeCredits(expiryDate: '2026-07-14', remainingCredits: 1);
        expect(
          pkg.isActive(now: now),
          isTrue,
          reason: 'expiryDate is inclusive: package valid through end of day',
        );
      },
    );
  });

  // ── PackageType fromMap/toMap round-trip ───────────────────────────────────

  group('PackageType fromMap/toMap round-trip', () {
    test(
      'AS-047: duration-kind round-trips correctly',
      () {
        final map = <String, dynamic>{
          'name': 'Monthly Membership',
          'kind': 'duration',
          'validityDays': 30,
          'active': true,
        };
        final type = PackageType.fromMap('pt1', map);

        expect(type.id, 'pt1');
        expect(type.name, 'Monthly Membership');
        expect(type.kind, PackageKind.duration);
        expect(type.validityDays, 30);
        expect(type.creditCount, isNull);
        expect(type.active, isTrue);

        final result = type.toMap();
        expect(result['name'], 'Monthly Membership');
        expect(result['kind'], 'duration');
        expect(result['validityDays'], 30);
        expect(result['active'], isTrue);
        expect(result.containsKey('creditCount'), isFalse,
            reason: 'creditCount absent for duration-kind');
      },
    );

    test(
      'AS-047: credits-kind round-trips correctly',
      () {
        final map = <String, dynamic>{
          'name': '10 Sessions Pack',
          'kind': 'credits',
          'validityDays': 90,
          'creditCount': 10,
          'active': true,
        };
        final type = PackageType.fromMap('pt2', map);

        expect(type.id, 'pt2');
        expect(type.kind, PackageKind.credits);
        expect(type.creditCount, 10);
        expect(type.validityDays, 90);

        final result = type.toMap();
        expect(result['kind'], 'credits');
        expect(result['creditCount'], 10);
        expect(result['validityDays'], 90);
      },
    );

    test(
      'AS-047: inactive package type round-trips active=false',
      () {
        final map = <String, dynamic>{
          'name': 'Old Pack',
          'kind': 'credits',
          'validityDays': 60,
          'creditCount': 5,
          'active': false,
        };
        final type = PackageType.fromMap('pt3', map);
        expect(type.active, isFalse);
        expect(type.toMap()['active'], isFalse);
      },
    );
  });

  // ── ClientPackage fromMap/toMap round-trip ─────────────────────────────────

  group('ClientPackage fromMap/toMap round-trip', () {
    test(
      'AS-049: credits-kind ClientPackage round-trips correctly',
      () {
        final assignedAtMs =
            DateTime(2026, 7, 1, 10, 0).millisecondsSinceEpoch;
        final map = <String, dynamic>{
          'clientUid': 'c1',
          'packageTypeId': 'pt2',
          'packageTypeName': '10 Sessions',
          'kind': 'credits',
          'assignedAt': assignedAtMs,
          'assignedBy': 'admin1',
          'startDate': '2026-07-01',
          'expiryDate': '2026-09-29',
          'remainingCredits': 7,
        };
        final pkg = ClientPackage.fromMap('cp1', map);

        expect(pkg.id, 'cp1');
        expect(pkg.clientUid, 'c1');
        expect(pkg.packageTypeId, 'pt2');
        expect(pkg.packageTypeName, '10 Sessions');
        expect(pkg.kind, PackageKind.credits);
        expect(pkg.remainingCredits, 7);
        expect(pkg.startDate, '2026-07-01');
        expect(pkg.expiryDate, '2026-09-29');
        expect(pkg.assignedBy, 'admin1');

        final result = pkg.toMap();
        expect(result['clientUid'], 'c1');
        expect(result['kind'], 'credits');
        expect(result['remainingCredits'], 7);
        expect(result['expiryDate'], '2026-09-29');
        expect(result.containsKey('remainingCredits'), isTrue);
      },
    );

    test(
      'AS-048 AS-049: duration-kind ClientPackage round-trips correctly '
      '— remainingCredits absent',
      () {
        final assignedAtMs =
            DateTime(2026, 7, 1, 10, 0).millisecondsSinceEpoch;
        final map = <String, dynamic>{
          'clientUid': 'c2',
          'packageTypeId': 'pt1',
          'packageTypeName': 'Monthly',
          'kind': 'duration',
          'assignedAt': assignedAtMs,
          'assignedBy': 'admin1',
          'startDate': '2026-07-01',
          'expiryDate': '2026-07-31',
        };
        final pkg = ClientPackage.fromMap('cp2', map);

        expect(pkg.kind, PackageKind.duration);
        expect(pkg.remainingCredits, isNull);

        final result = pkg.toMap();
        expect(result['kind'], 'duration');
        expect(result.containsKey('remainingCredits'), isFalse,
            reason: 'remainingCredits absent for duration-kind');
      },
    );
  });
}
