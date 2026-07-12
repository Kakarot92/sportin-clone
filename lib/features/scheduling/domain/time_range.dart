import 'date_utils.dart';

/// A half-open time interval [start, end) stored as "HH:mm" strings.
class TimeRange {
  const TimeRange({required this.start, required this.end});

  /// Start time as "HH:mm".
  final String start;

  /// End time as "HH:mm".
  final String end;

  /// Minutes from midnight for [start].
  int get startMinutes => parseHhmm(start);

  /// Minutes from midnight for [end].
  int get endMinutes => parseHhmm(end);

  factory TimeRange.fromMap(Map<String, dynamic> map) {
    return TimeRange(
      start: (map['start'] as String?) ?? '00:00',
      end: (map['end'] as String?) ?? '00:00',
    );
  }

  Map<String, dynamic> toMap() => {'start': start, 'end': end};
}
