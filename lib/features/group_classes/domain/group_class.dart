/// A group fitness class offered by a trainer with a fixed participant capacity.
///
/// Stored in the `groupClasses` Firestore collection.
class GroupClass {
  const GroupClass({
    required this.id,
    required this.trainerUid,
    required this.title,
    required this.date,
    required this.start,
    required this.end,
    required this.capacity,
    this.joinedCount = 0,
  });

  final String id;
  final String trainerUid;

  /// Display title of the class (e.g. "Yoga Flow").
  final String title;

  /// ISO date string "YYYY-MM-DD".
  final String date;

  /// Start time string "HH:mm".
  final String start;

  /// End time string "HH:mm".
  final String end;

  /// Maximum number of participants.
  final int capacity;

  /// Number of participants who have joined. Updated atomically by
  /// [GroupClassRepository.joinClass] and [GroupClassRepository.leaveClass].
  final int joinedCount;

  // ── Derived properties ────────────────────────────────────────────────────

  /// How many spots are still available.
  ///
  /// Returns negative values for over-capacity edge cases (defensive — this
  /// should not normally occur because [joinClass] guards on the transaction).
  int get remainingSpots => capacity - joinedCount;

  /// `true` when [remainingSpots] is 0 or negative (AS-043).
  bool get isFull => remainingSpots <= 0;

  // ── Serialisation ─────────────────────────────────────────────────────────

  /// Deserialises a Firestore document snapshot into a [GroupClass].
  factory GroupClass.fromMap(String id, Map<String, dynamic> map) {
    return GroupClass(
      id: id,
      trainerUid: map['trainerUid'] as String,
      title: map['title'] as String,
      date: map['date'] as String,
      start: map['start'] as String,
      end: map['end'] as String,
      capacity: map['capacity'] as int,
      joinedCount: (map['joinedCount'] as int?) ?? 0,
    );
  }

  /// Serialises this [GroupClass] to a Firestore-compatible map.
  ///
  /// Note: [id] is omitted (Firestore document key, not a field).
  /// [joinedCount] is included so callers can persist the current count, but
  /// [GroupClassRepository.createClass] always overrides it with `0`.
  Map<String, dynamic> toMap() => {
        'trainerUid': trainerUid,
        'title': title,
        'date': date,
        'start': start,
        'end': end,
        'capacity': capacity,
        'joinedCount': joinedCount,
      };
}
