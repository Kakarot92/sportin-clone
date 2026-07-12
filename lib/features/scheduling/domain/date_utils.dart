/// Formats a [DateTime] as "YYYY-MM-DD" (zero-padded, local date components).
String ymd(DateTime d) {
  final y = d.year.toString().padLeft(4, '0');
  final m = d.month.toString().padLeft(2, '0');
  final day = d.day.toString().padLeft(2, '0');
  return '$y-$m-$day';
}

/// Converts minutes-from-midnight to a "HH:mm" string (zero-padded).
String hhmm(int minutesFromMidnight) {
  final h = (minutesFromMidnight ~/ 60).toString().padLeft(2, '0');
  final min = (minutesFromMidnight % 60).toString().padLeft(2, '0');
  return '$h:$min';
}

/// Parses a "HH:mm" string into minutes from midnight.
int parseHhmm(String value) {
  final parts = value.split(':');
  final h = int.tryParse(parts[0]) ?? 0;
  final m = parts.length > 1 ? (int.tryParse(parts[1]) ?? 0) : 0;
  return h * 60 + m;
}
