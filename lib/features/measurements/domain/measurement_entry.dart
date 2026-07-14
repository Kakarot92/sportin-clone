/// A single body-measurement record entered by a client (AS-056, AS-062).
///
/// Stored at `measurements/{autoId}` in Firestore.
/// The [clientUid] field is the owner; Firestore rules enforce that only the
/// owner (or their trainer) may read, and only the owner may write (AS-057).
class MeasurementEntry {
  const MeasurementEntry({
    required this.id,
    required this.clientUid,
    required this.date,
    this.weightKg,
    this.bodyFatPercent,
    this.waistCm,
    this.chestCm,
    this.hipsCm,
    this.note = '',
  });

  /// Firestore document ID (auto-generated on creation).
  final String id;

  /// UID of the client who owns this entry.
  final String clientUid;

  /// Calendar date of the measurement as "YYYY-MM-DD".
  final String date;

  /// Body weight in kilograms.
  final double? weightKg;

  /// Body-fat percentage (0–100).
  final double? bodyFatPercent;

  /// Waist circumference in centimetres.
  final double? waistCm;

  /// Chest circumference in centimetres.
  final double? chestCm;

  /// Hip circumference in centimetres.
  final double? hipsCm;

  /// Optional free-text note attached to this entry.
  final String note;

  /// Deserialises a Firestore document into a [MeasurementEntry].
  ///
  /// Numeric fields come back as either [int] or [double] from Firestore;
  /// we cast via `(value as num?)?.toDouble()` to avoid runtime type errors.
  factory MeasurementEntry.fromMap(String id, Map<String, dynamic> map) {
    return MeasurementEntry(
      id: id,
      clientUid: (map['clientUid'] as String?) ?? '',
      date: (map['date'] as String?) ?? '',
      weightKg: (map['weightKg'] as num?)?.toDouble(),
      bodyFatPercent: (map['bodyFatPercent'] as num?)?.toDouble(),
      waistCm: (map['waistCm'] as num?)?.toDouble(),
      chestCm: (map['chestCm'] as num?)?.toDouble(),
      hipsCm: (map['hipsCm'] as num?)?.toDouble(),
      note: (map['note'] as String?) ?? '',
    );
  }

  /// Serialises to a Firestore-compatible map.
  ///
  /// Only non-null optional fields are included so Firestore documents stay
  /// compact. `note` is omitted when empty.
  Map<String, dynamic> toMap() => {
        'clientUid': clientUid,
        'date': date,
        if (weightKg != null) 'weightKg': weightKg,
        if (bodyFatPercent != null) 'bodyFatPercent': bodyFatPercent,
        if (waistCm != null) 'waistCm': waistCm,
        if (chestCm != null) 'chestCm': chestCm,
        if (hipsCm != null) 'hipsCm': hipsCm,
        if (note.isNotEmpty) 'note': note,
      };
}
