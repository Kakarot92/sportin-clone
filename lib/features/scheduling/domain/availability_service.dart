import 'availability_exception.dart';
import 'booking.dart';
import 'date_utils.dart';
import 'slot.dart';
import 'studio_settings.dart';
import 'weekly_availability.dart';

/// Pure, side-effect-free function that computes available [Slot]s for a
/// single trainer on a given [day].
///
/// Algorithm:
/// 1. Return [] if the studio is closed on that weekday.
/// 2. Return [] if the studio is closed on that specific date.
/// 3. Filter [exceptions] to this trainer + date. Return [] if any is all-day.
/// 4. Get the trainer's working windows for [day.weekday] from [template].
/// 5. Slice each window into [template.slotMinutes]-long candidates.
/// 6. Drop candidates overlapping any non-all-day exception time range.
/// 7. Drop candidates overlapping any active booking (status == "booked").
/// 8. Return remaining slots sorted by start time, deduplicated.
List<Slot> generateDaySlots({
  required DateTime day,
  required WeeklyAvailability template,
  required StudioSettings studio,
  required List<AvailabilityException> exceptions,
  required List<Booking> bookings,
}) {
  // Step 1: Studio closed weekday.
  if (studio.closedWeekdays.contains(day.weekday)) return const [];

  // Step 2: Studio closed date.
  final dayStr = ymd(day);
  if (studio.closedDates.contains(dayStr)) return const [];

  // Step 3: Trainer exceptions for this day.
  final dayExceptions = exceptions
      .where(
          (e) => e.trainerUid == template.trainerUid && ymd(e.date) == dayStr)
      .toList();
  if (dayExceptions.any((e) => e.allDay)) return const [];

  // Step 4: Working windows for this weekday.
  final windows = template.weekly[day.weekday] ?? [];

  // Pre-filter bookings to this trainer, date and "booked" status.
  final dayBookings = bookings
      .where((b) =>
          b.trainerUid == template.trainerUid &&
          b.date == dayStr &&
          b.status == 'booked')
      .toList();

  // Steps 5–8: Generate candidates and remove blocked ones.
  // Using a Set<Slot> for automatic deduplication (Slot equality = trainerUid +
  // date-as-ymd + start).
  final slots = <Slot>{};

  for (final window in windows) {
    int startMin = window.startMinutes;
    while (startMin + template.slotMinutes <= window.endMinutes) {
      final endMin = startMin + template.slotMinutes;

      // Step 6: Drop if overlaps a non-all-day exception.
      final blockedByException = dayExceptions.any((e) {
        if (e.allDay) return false;
        final exStart = parseHhmm(e.start ?? '00:00');
        final exEnd = parseHhmm(e.end ?? '00:00');
        return startMin < exEnd && endMin > exStart;
      });

      if (!blockedByException) {
        // Step 7: Drop if overlaps an active booking.
        final blockedByBooking = dayBookings.any((b) {
          final bStart = parseHhmm(b.start);
          final bEnd = parseHhmm(b.end);
          return startMin < bEnd && endMin > bStart;
        });

        if (!blockedByBooking) {
          slots.add(
            Slot(
              trainerUid: template.trainerUid,
              date: day,
              start: hhmm(startMin),
              end: hhmm(endMin),
            ),
          );
        }
      }

      startMin += template.slotMinutes;
    }
  }

  // Step 8: Sort ascending by start string (HH:mm lexicographic == numeric order).
  return slots.toList()..sort((a, b) => a.start.compareTo(b.start));
}
