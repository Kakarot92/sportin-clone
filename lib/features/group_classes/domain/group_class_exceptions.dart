/// Thrown when a client attempts to join a group class that has no remaining
/// spots (AS-043).
///
/// [ClassFullException] is distinct from [AlreadyJoinedException] — the class
/// itself is at capacity, not that the client has already joined it.
class ClassFullException implements Exception {
  const ClassFullException();
}

/// Thrown when a client attempts to join a group class they have already
/// joined (AS-046).
///
/// Duplicate-join prevention is enforced atomically inside a Firestore
/// transaction in [GroupClassRepository.joinClass].
class AlreadyJoinedException implements Exception {
  const AlreadyJoinedException();
}

// NOTE: [CutoffPassedException] from
// `lib/features/booking/domain/booking_exceptions.dart` is reused for the
// "cannot leave a class that has already started" case (AS-045). It is not
// redefined here to avoid duplicate near-identical exception types.
