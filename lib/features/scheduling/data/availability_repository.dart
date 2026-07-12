import 'package:cloud_firestore/cloud_firestore.dart';

import '../domain/availability_exception.dart';
import '../domain/booking.dart';
import '../domain/date_utils.dart';
import '../domain/studio_settings.dart';
import '../domain/weekly_availability.dart';

/// Firestore-backed repository for all scheduling data.
///
/// Collections:
/// - `availabilityTemplates/{trainerUid}` — weekly recurring templates
/// - `availabilityExceptions/{autoId}` — one-off blocks
/// - `studioSettings/main` — studio-wide closed days/dates
/// - `bookings/{autoId}` — READ-ONLY in M4; creation is added in M5
class AvailabilityRepository {
  AvailabilityRepository(this._db);

  final FirebaseFirestore _db;

  // ─── Weekly templates ────────────────────────────────────────────────────

  /// Watches the availability template for [trainerUid].
  ///
  /// Emits `null` when the trainer has not yet defined a template.
  Stream<WeeklyAvailability?> watchTemplate(String trainerUid) {
    return _db
        .collection('availabilityTemplates')
        .doc(trainerUid)
        .snapshots()
        .map((snap) => snap.exists
            ? WeeklyAvailability.fromMap(snap.id, snap.data()!)
            : null);
  }

  /// Saves (creates or merges) the weekly template for [t.trainerUid].
  ///
  /// Adds a server-side `updatedAt` timestamp on every save.
  Future<void> saveTemplate(WeeklyAvailability t) {
    final data = <String, dynamic>{
      ...t.toMap(),
      'updatedAt': FieldValue.serverTimestamp(),
    };
    return _db
        .collection('availabilityTemplates')
        .doc(t.trainerUid)
        .set(data, SetOptions(merge: true));
  }

  // ─── Exceptions ──────────────────────────────────────────────────────────

  /// Watches all one-off exceptions for [trainerUid], ordered by date.
  Stream<List<AvailabilityException>> watchExceptions(String trainerUid) {
    return _db
        .collection('availabilityExceptions')
        .where('trainerUid', isEqualTo: trainerUid)
        .orderBy('date')
        .snapshots()
        .map((snap) => snap.docs
            .map((d) => AvailabilityException.fromMap(d.id, d.data()))
            .toList());
  }

  /// Adds a new one-off exception. The document ID is auto-generated.
  Future<void> addException(AvailabilityException e) {
    final data = <String, dynamic>{
      ...e.toMap(),
      'createdAt': FieldValue.serverTimestamp(),
    };
    return _db.collection('availabilityExceptions').add(data);
  }

  /// Removes a one-off exception by its Firestore document [id].
  Future<void> removeException(String id) {
    return _db.collection('availabilityExceptions').doc(id).delete();
  }

  // ─── Studio settings ─────────────────────────────────────────────────────

  /// Watches the studio-wide settings document.
  ///
  /// Emits [StudioSettings.initial] (no closed days) when the document does
  /// not yet exist.
  Stream<StudioSettings> watchStudioSettings() {
    return _db
        .collection('studioSettings')
        .doc('main')
        .snapshots()
        .map((snap) => snap.exists
            ? StudioSettings.fromMap(snap.data()!)
            : const StudioSettings.initial());
  }

  /// Saves (creates or merges) the studio settings document.
  Future<void> saveStudioSettings(StudioSettings s) {
    final data = <String, dynamic>{
      ...s.toMap(),
      'updatedAt': FieldValue.serverTimestamp(),
    };
    return _db
        .collection('studioSettings')
        .doc('main')
        .set(data, SetOptions(merge: true));
  }

  // ─── Bookings (READ-ONLY in M4) ──────────────────────────────────────────

  /// Watches active ("booked") bookings for [trainerUid] on [day].
  ///
  /// Used by [availableSlotsProvider] to exclude already-taken slots from
  /// the availability calculation. Booking creation is implemented in M5.
  Stream<List<Booking>> watchBookingsForDay(String trainerUid, DateTime day) {
    return _db
        .collection('bookings')
        .where('trainerUid', isEqualTo: trainerUid)
        .where('date', isEqualTo: ymd(day))
        .where('status', isEqualTo: 'booked')
        .snapshots()
        .map((snap) =>
            snap.docs.map((d) => Booking.fromMap(d.id, d.data())).toList());
  }
}
