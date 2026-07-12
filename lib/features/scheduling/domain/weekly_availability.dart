import 'time_range.dart';

/// A trainer's weekly recurring availability template.
///
/// Stored at `availabilityTemplates/{trainerUid}` in Firestore.
/// The [weekly] map uses Dart's `DateTime.weekday` convention:
/// 1 = Monday, 7 = Sunday.
class WeeklyAvailability {
  const WeeklyAvailability({
    required this.trainerUid,
    required this.slotMinutes,
    required this.weekly,
  });

  /// Named constructor that returns an empty (no working hours) template.
  ///
  /// Can be used as a constant when called with a compile-time-constant [uid].
  const WeeklyAvailability.empty(String uid)
      : trainerUid = uid,
        slotMinutes = 60,
        weekly = const <int, List<TimeRange>>{};

  final String trainerUid;

  /// Duration of each bookable slot in minutes (default 60).
  final int slotMinutes;

  /// Working windows per weekday (1–7). Each entry is a list of [TimeRange]s.
  final Map<int, List<TimeRange>> weekly;

  factory WeeklyAvailability.fromMap(String uid, Map<String, dynamic> map) {
    final weeklyRaw =
        (map['weekly'] as Map<String, dynamic>?) ?? <String, dynamic>{};
    final weekly = weeklyRaw.map((key, value) {
      final weekday = int.tryParse(key) ?? 0;
      final ranges = (value as List<dynamic>)
          .map((e) => TimeRange.fromMap(Map<String, dynamic>.from(e as Map)))
          .toList();
      return MapEntry(weekday, ranges);
    });
    return WeeklyAvailability(
      trainerUid: uid,
      slotMinutes: (map['slotMinutes'] as int?) ?? 60,
      weekly: weekly,
    );
  }

  /// Serialises to a Firestore-compatible map.
  ///
  /// Weekday keys are stored as string digits ("1".."7") per the data spec.
  Map<String, dynamic> toMap() {
    final weeklyMapped = weekly.map(
      (key, value) => MapEntry(
        key.toString(),
        value.map((r) => r.toMap()).toList(),
      ),
    );
    return {
      'trainerUid': trainerUid,
      'slotMinutes': slotMinutes,
      'weekly': weeklyMapped,
    };
  }

  WeeklyAvailability copyWith({
    String? trainerUid,
    int? slotMinutes,
    Map<int, List<TimeRange>>? weekly,
  }) {
    return WeeklyAvailability(
      trainerUid: trainerUid ?? this.trainerUid,
      slotMinutes: slotMinutes ?? this.slotMinutes,
      weekly: weekly ?? this.weekly,
    );
  }
}
