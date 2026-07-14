import '../../scheduling/domain/booking.dart';

/// Cancellation/reschedule cutoff in hours before the session start.
///
/// Set to 0: cancellation and rescheduling are allowed at any point up
/// until the session's actual start time. Once the session has started
/// (or is in the past), `isPastCutoff` returns true and the action is
/// blocked. There is no longer an advance-notice window.
const int kCancellationCutoffHours = 0;

/// Returns `true` when [now] is strictly after
/// `slotStart - cutoffHours` — i.e. the window to cancel/reschedule has
/// closed.
///
/// With the default [cutoffHours] of 0 this is equivalent to
/// `now.isAfter(slotStart)`: the window is open all the way up to the
/// moment the session starts.
///
/// **Boundary behaviour (exclusive):** when [now] equals the cutoff moment
/// exactly, this returns `false` (the user can still cancel). The window
/// closes only once [now] is strictly after the cutoff moment.
bool isPastCutoff(
  DateTime slotStart,
  DateTime now, {
  int cutoffHours = kCancellationCutoffHours,
}) {
  final cutoffMoment = slotStart.subtract(Duration(hours: cutoffHours));
  return now.isAfter(cutoffMoment);
}

/// Builds the slot-start [DateTime] from a [Booking]'s [date] ("YYYY-MM-DD")
/// and [start] ("HH:mm") strings.
DateTime bookingSlotStart(String date, String start) {
  final dateParts = date.split('-');
  final timeParts = start.split(':');
  return DateTime(
    int.parse(dateParts[0]), // year
    int.parse(dateParts[1]), // month
    int.parse(dateParts[2]), // day
    int.parse(timeParts[0]), // hour
    int.parse(timeParts[1]), // minute
  );
}

/// Convenience helper: returns `true` when the booking can still be cancelled
/// or rescheduled — i.e. the session has not yet started.
///
/// With the default `kCancellationCutoffHours = 0` this is equivalent to
/// checking that the session's start time is in the future.
///
/// Accepts an optional [now] for testing; defaults to [DateTime.now()].
bool canCancelBooking(Booking b, {DateTime? now}) {
  final slotStart = bookingSlotStart(b.date, b.start);
  return !isPastCutoff(slotStart, now ?? DateTime.now());
}
