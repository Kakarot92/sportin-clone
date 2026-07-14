import 'package:cloud_firestore/cloud_firestore.dart';

import 'package_type.dart';

/// A package instance assigned to a specific client.
///
/// Stored at `clientPackages/{autoId}` in Firestore.
/// Created by admins via [PackagesRepository.assignPackage] (AS-048).
class ClientPackage {
  const ClientPackage({
    required this.id,
    required this.clientUid,
    required this.packageTypeId,
    required this.packageTypeName,
    required this.kind,
    required this.assignedAt,
    required this.assignedBy,
    required this.startDate,
    required this.expiryDate,
    this.remainingCredits,
  });

  final String id;
  final String clientUid;
  final String packageTypeId;

  /// Denormalized for display without a join.
  final String packageTypeName;

  final PackageKind kind;
  final DateTime assignedAt;

  /// UID of the admin who assigned this package.
  final String assignedBy;

  /// Inclusive start date as "YYYY-MM-DD".
  final String startDate;

  /// Inclusive expiry date as "YYYY-MM-DD".
  final String expiryDate;

  /// Meaningful only when [kind] == [PackageKind.credits].
  final int? remainingCredits;

  factory ClientPackage.fromMap(String id, Map<String, dynamic> map) {
    final raw = map['assignedAt'];
    final DateTime assignedAt;
    if (raw is Timestamp) {
      assignedAt = raw.toDate();
    } else if (raw is int) {
      assignedAt = DateTime.fromMillisecondsSinceEpoch(raw);
    } else {
      assignedAt = DateTime.now();
    }

    return ClientPackage(
      id: id,
      clientUid: (map['clientUid'] as String?) ?? '',
      packageTypeId: (map['packageTypeId'] as String?) ?? '',
      packageTypeName: (map['packageTypeName'] as String?) ?? '',
      kind: packageKindFromString((map['kind'] as String?) ?? 'duration'),
      assignedAt: assignedAt,
      assignedBy: (map['assignedBy'] as String?) ?? '',
      startDate: (map['startDate'] as String?) ?? '',
      expiryDate: (map['expiryDate'] as String?) ?? '',
      remainingCredits: map['remainingCredits'] as int?,
    );
  }

  Map<String, dynamic> toMap() => {
        'clientUid': clientUid,
        'packageTypeId': packageTypeId,
        'packageTypeName': packageTypeName,
        'kind': kind == PackageKind.credits ? 'credits' : 'duration',
        'assignedAt': assignedAt.millisecondsSinceEpoch,
        'assignedBy': assignedBy,
        'startDate': startDate,
        'expiryDate': expiryDate,
        if (remainingCredits != null) 'remainingCredits': remainingCredits,
      };

  /// True when not expired AND (duration-kind OR remainingCredits > 0).
  ///
  /// Computed client-side (not stored) so it is always consistent — no stale
  /// "status" field to keep in sync (AS-053, AS-054).
  ///
  /// [expiryDate] is inclusive: valid through the end of that calendar day.
  bool isActive({DateTime? now}) {
    final today = now ?? DateTime.now();
    final expiry = DateTime.parse(expiryDate);
    // expired only AFTER the last second of the expiry day.
    final expired = today.isAfter(
      DateTime(expiry.year, expiry.month, expiry.day, 23, 59, 59),
    );
    if (expired) return false;
    if (kind == PackageKind.credits) return (remainingCredits ?? 0) > 0;
    return true;
  }
}
