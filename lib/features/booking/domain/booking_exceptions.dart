/// Thrown when the user attempts to book a slot that starts in the past.
class PastSlotException implements Exception {
  const PastSlotException();
}

/// Thrown when the target slot is already taken by another booking.
class SlotTakenException implements Exception {
  const SlotTakenException();
}

/// Thrown when the user attempts to cancel or reschedule a booking after the
/// cancellation cutoff has passed (AS-036).
class CutoffPassedException implements Exception {
  const CutoffPassedException();
}

/// Thrown defensively when a cancel/reschedule target document does not match
/// expectations (e.g. not found or belongs to a different user).
class BookingNotFoundOrForbiddenException implements Exception {
  const BookingNotFoundOrForbiddenException();
}

/// Thrown when a client has no active package or has run out of credits and
/// therefore cannot complete a booking (AS-032, AS-054).
class NoActivePackageException implements Exception {
  const NoActivePackageException();
}

/// Returns `true` if [slotStart] is strictly before [now].
///
/// Extracted as a pure function so it can be unit-tested without Firebase.
/// Used by [BookingRepository.createBooking] to guard against past-slot
/// bookings (AS-029).
bool isPastSlot(DateTime slotStart, DateTime now) => slotStart.isBefore(now);
