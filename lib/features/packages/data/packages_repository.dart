import 'package:cloud_firestore/cloud_firestore.dart';

import '../../scheduling/domain/date_utils.dart';
import '../domain/client_package.dart';
import '../domain/package_type.dart';

/// Firestore-backed repository for package type management and assignment.
///
/// Collections:
/// - `packageTypes/{autoId}` — admin-defined package/membership templates
/// - `clientPackages/{autoId}` — packages assigned to specific clients
class PackagesRepository {
  PackagesRepository(this._db);

  final FirebaseFirestore _db;

  // ─── Package types ────────────────────────────────────────────────────────

  /// Watches all package types, optionally filtering to active-only.
  ///
  /// Ordered by name. Use [activeOnly] = true for assignment dropdowns,
  /// false for the admin management screen (AS-047).
  Stream<List<PackageType>> watchPackageTypes({bool activeOnly = false}) {
    Query<Map<String, dynamic>> query = _db.collection('packageTypes');
    if (activeOnly) {
      query = query.where('active', isEqualTo: true);
    }
    return query.orderBy('name').snapshots().map(
          (snap) => snap.docs
              .map((d) => PackageType.fromMap(d.id, d.data()))
              .toList(),
        );
  }

  /// Creates a new package type (auto-id). Admin-only (AS-047).
  Future<void> createPackageType(PackageType type) {
    return _db.collection('packageTypes').add(
      type.toMap()..['createdAt'] = FieldValue.serverTimestamp(),
    );
  }

  /// Retires or re-activates a package type without deleting its history.
  Future<void> setPackageTypeActive(String id, bool active) {
    return _db.collection('packageTypes').doc(id).update({'active': active});
  }

  // ─── Client packages ─────────────────────────────────────────────────────

  /// Watches all packages assigned to [clientUid], newest first (AS-049).
  Stream<List<ClientPackage>> watchClientPackages(String clientUid) {
    return _db
        .collection('clientPackages')
        .where('clientUid', isEqualTo: clientUid)
        .orderBy('assignedAt', descending: true)
        .snapshots()
        .map((snap) => snap.docs
            .map((d) => ClientPackage.fromMap(d.id, d.data()))
            .toList());
  }

  /// Assigns a new package instance to [clientUid] (AS-048).
  ///
  /// Start date = today; expiry = today + [type.validityDays].
  Future<void> assignPackage({
    required String clientUid,
    required PackageType type,
    required String assignedByUid,
  }) async {
    final now = DateTime.now();
    await _db.collection('clientPackages').add({
      'clientUid': clientUid,
      'packageTypeId': type.id,
      'packageTypeName': type.name,
      'kind': type.kind == PackageKind.credits ? 'credits' : 'duration',
      'startDate': ymd(now),
      'expiryDate': ymd(now.add(Duration(days: type.validityDays))),
      if (type.kind == PackageKind.credits) 'remainingCredits': type.creditCount,
      'assignedAt': FieldValue.serverTimestamp(),
      'assignedBy': assignedByUid,
    });
  }

  /// Returns the first active [ClientPackage] for [clientUid], or null.
  ///
  /// Fetches all packages and filters in Dart — acceptable for the small
  /// number of packages a client typically has (mirrors the watchClientHistory
  /// pattern in [BookingRepository]).
  ///
  /// When multiple active packages exist, prefers the one with the latest
  /// expiry date.
  Future<ClientPackage?> getActivePackage(String clientUid) async {
    final snap = await _db
        .collection('clientPackages')
        .where('clientUid', isEqualTo: clientUid)
        .get();
    final active = snap.docs
        .map((d) => ClientPackage.fromMap(d.id, d.data()))
        .where((p) => p.isActive())
        .toList();
    if (active.isEmpty) return null;
    active.sort((a, b) => b.expiryDate.compareTo(a.expiryDate));
    return active.first;
  }
}
