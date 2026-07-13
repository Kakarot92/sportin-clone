/// Thrown when the user attempts to book a slot that starts in the past.
class PastSlotException implements Exception {
  const PastSlotException();
}

/// Thrown when the target slot is already taken by another booking.
class SlotTakenException implements Exception {
  const SlotTakenException();
}

/// Returns `true` if [slotStart] is strictly before [now].
///
/// Extracted as a pure function so it can be unit-tested without Firebase.
/// Used by [BookingRepository.createBooking] to guard against past-slot
/// bookings (AS-029).
bool isPastSlot(DateTime slotStart, DateTime now) => slotStart.isBefore(now);
