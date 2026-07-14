/// Kind of package: duration-based membership or session-credit pack.
enum PackageKind { duration, credits }

/// Parses a Firestore-stored string into [PackageKind].
PackageKind packageKindFromString(String v) =>
    v == 'credits' ? PackageKind.credits : PackageKind.duration;

/// Template for a type of package that can be assigned to clients.
///
/// Stored at `packageTypes/{autoId}` in Firestore.
/// Admins define types; trainers/admins assign instances to clients (AS-047).
class PackageType {
  const PackageType({
    required this.id,
    required this.name,
    required this.kind,
    required this.validityDays,
    this.creditCount,
    this.active = true,
  });

  final String id;
  final String name;
  final PackageKind kind;

  /// For duration kind: membership length.
  /// For credits kind: how long credits remain usable.
  final int validityDays;

  /// Required/meaningful only when [kind] == [PackageKind.credits].
  final int? creditCount;

  /// Inactive types are hidden from assignment dropdowns but kept for history.
  final bool active;

  factory PackageType.fromMap(String id, Map<String, dynamic> map) {
    return PackageType(
      id: id,
      name: (map['name'] as String?) ?? '',
      kind: packageKindFromString((map['kind'] as String?) ?? 'duration'),
      validityDays: (map['validityDays'] as int?) ?? 0,
      creditCount: map['creditCount'] as int?,
      active: (map['active'] as bool?) ?? true,
    );
  }

  Map<String, dynamic> toMap() => {
        'name': name,
        'kind': kind == PackageKind.credits ? 'credits' : 'duration',
        'validityDays': validityDays,
        if (creditCount != null) 'creditCount': creditCount,
        'active': active,
      };
}
