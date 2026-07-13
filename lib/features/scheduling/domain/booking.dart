/// A 1-on-1 session booking.
///
/// Stored at `bookings/{autoId}` in Firestore.
/// M4 uses bookings for the READ side only (filtering booked slots from
/// availability). Booking creation is implemented in M5.
class Booking {
  const Booking({
    required this.id,
    required this.trainerUid,
    required this.clientUid,
    required this.date,
    required this.start,
    required this.end,
    required this.status,
  });

  final String id;
  final String trainerUid;
  final String clientUid;

  /// Date as "YYYY-MM-DD".
  final String date;

  /// Slot start time as "HH:mm".
  final String start;

  /// Slot end time as "HH:mm".
  final String end;

  /// "booked" or "cancelled".
  final String status;

  factory Booking.fromMap(String id, Map<String, dynamic> map) {
    return Booking(
      id: id,
      trainerUid: (map['trainerUid'] as String?) ?? '',
      clientUid: (map['clientUid'] as String?) ?? '',
      date: (map['date'] as String?) ?? '',
      start: (map['start'] as String?) ?? '',
      end: (map['end'] as String?) ?? '',
      status: (map['status'] as String?) ?? 'booked',
    );
  }

  Map<String, dynamic> toMap() => {
        'trainerUid': trainerUid,
        'clientUid': clientUid,
        'date': date,
        'start': start,
        'end': end,
        'status': status,
      };

  /// Deterministic document ID for a booking slot.
  ///
  /// Two clients racing to book the same (trainer, date, start) will resolve
  /// to the same Firestore document, making the transaction idempotent and
  /// preventing double-bookings (AS-027, AS-028).
  ///
  /// Example: `bookingDocId('trainer-djole', '2026-07-13', '09:00')`
  /// returns `'trainer-djole_2026-07-13_0900'`.
  static String bookingDocId(
      String trainerUid, String date, String start) {
    final sanitizedStart = start.replaceAll(':', '');
    return '${trainerUid}_${date}_$sanitizedStart';
  }
}
