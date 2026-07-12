import 'date_utils.dart';

/// A bookable time slot for a given trainer on a specific day.
///
/// Equality is defined on (trainerUid, date-as-YYYY-MM-DD, start) so that the
/// same logical slot produced from overlapping windows is deduplicated.
class Slot {
  const Slot({
    required this.trainerUid,
    required this.date,
    required this.start,
    required this.end,
  });

  final String trainerUid;
  final DateTime date;

  /// Slot start time as "HH:mm".
  final String start;

  /// Slot end time as "HH:mm".
  final String end;

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Slot &&
        other.trainerUid == trainerUid &&
        ymd(other.date) == ymd(date) &&
        other.start == start;
  }

  @override
  int get hashCode => Object.hash(trainerUid, ymd(date), start);

  @override
  String toString() =>
      'Slot($trainerUid, ${ymd(date)}, $start–$end)';
}
