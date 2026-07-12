import 'date_utils.dart';

/// A one-off block that removes availability for a trainer on a specific date.
///
/// Stored at `availabilityExceptions/{autoId}` in Firestore.
class AvailabilityException {
  const AvailabilityException({
    required this.id,
    required this.trainerUid,
    required this.date,
    required this.allDay,
    this.start,
    this.end,
  });

  final String id;
  final String trainerUid;

  /// The date that is blocked (time component is ignored; compare with [ymd]).
  final DateTime date;

  /// When true the entire day is blocked; [start]/[end] are irrelevant.
  final bool allDay;

  /// Start of the blocked window ("HH:mm"). Only present when [allDay] is false.
  final String? start;

  /// End of the blocked window ("HH:mm"). Only present when [allDay] is false.
  final String? end;

  factory AvailabilityException.fromMap(String id, Map<String, dynamic> map) {
    final dateStr = (map['date'] as String?) ?? '';
    final parts = dateStr.split('-');
    final date = parts.length == 3
        ? DateTime(
            int.tryParse(parts[0]) ?? 1970,
            int.tryParse(parts[1]) ?? 1,
            int.tryParse(parts[2]) ?? 1,
          )
        : DateTime(1970);
    return AvailabilityException(
      id: id,
      trainerUid: (map['trainerUid'] as String?) ?? '',
      date: date,
      allDay: (map['allDay'] as bool?) ?? false,
      start: map['start'] as String?,
      end: map['end'] as String?,
    );
  }

  Map<String, dynamic> toMap() {
    final m = <String, dynamic>{
      'trainerUid': trainerUid,
      'date': ymd(date),
      'allDay': allDay,
    };
    if (!allDay) {
      if (start != null) m['start'] = start;
      if (end != null) m['end'] = end;
    }
    return m;
  }
}
