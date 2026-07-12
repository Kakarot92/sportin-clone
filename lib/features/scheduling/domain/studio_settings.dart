/// Studio-wide scheduling configuration.
///
/// Stored as a single document at `studioSettings/main` in Firestore.
class StudioSettings {
  const StudioSettings({
    required this.closedWeekdays,
    required this.closedDates,
  });

  /// No closed days — sensible default when the document doesn't exist yet.
  const StudioSettings.initial()
      : closedWeekdays = const <int>{},
        closedDates = const <String>{};

  /// Weekdays on which the studio is closed (1 = Monday … 7 = Sunday).
  final Set<int> closedWeekdays;

  /// Specific dates on which the studio is closed, formatted as "YYYY-MM-DD".
  final Set<String> closedDates;

  factory StudioSettings.fromMap(Map<String, dynamic> map) {
    final weekdays = (map['closedWeekdays'] as List<dynamic>?)
            ?.map((e) => e as int)
            .toSet() ??
        <int>{};
    final dates = (map['closedDates'] as List<dynamic>?)
            ?.map((e) => e as String)
            .toSet() ??
        <String>{};
    return StudioSettings(closedWeekdays: weekdays, closedDates: dates);
  }

  Map<String, dynamic> toMap() => {
        'closedWeekdays': closedWeekdays.toList(),
        'closedDates': closedDates.toList(),
      };
}
