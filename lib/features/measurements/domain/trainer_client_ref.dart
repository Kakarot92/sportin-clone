/// A lightweight marker linking a trainer to a client they have trained.
///
/// Stored at `trainerClients/{trainerUid}_{clientUid}` in Firestore.
/// The deterministic document ID (same technique as [Booking.bookingDocId])
/// allows Firestore security rules to use `exists()` for an O(1) authorisation
/// check without running a collection query (AS-063, AS-064).
///
/// Upserted (with [SetOptions.merge]) whenever a client books a trainer so
/// the record is always current and idempotent.
class TrainerClientRef {
  const TrainerClientRef({
    required this.trainerUid,
    required this.clientUid,
    required this.clientDisplayName,
  });

  /// UID of the trainer.
  final String trainerUid;

  /// UID of the client.
  final String clientUid;

  /// Denormalised display name of the client (for list display without join).
  final String clientDisplayName;

  /// Deserialises a Firestore document map into a [TrainerClientRef].
  factory TrainerClientRef.fromMap(Map<String, dynamic> map) {
    return TrainerClientRef(
      trainerUid: (map['trainerUid'] as String?) ?? '',
      clientUid: (map['clientUid'] as String?) ?? '',
      clientDisplayName: (map['clientDisplayName'] as String?) ?? '',
    );
  }
}
