import '../../packages/domain/client_package.dart';
import '../domain/measurement_entry.dart';

/// A snapshot of key metrics shown on a client's dashboard (AS-065).
///
/// Combines attended-session count, active package, and latest measurement
/// from three separate Firestore streams via [dashboardSummaryProvider].
class DashboardSummary {
  const DashboardSummary({
    required this.sessionsAttended,
    required this.activePackage,
    required this.latestMeasurement,
  });

  /// Number of past sessions with status `'booked'` (i.e. attended / not
  /// cancelled) from the client's booking history.
  final int sessionsAttended;

  /// The client's currently active [ClientPackage], or `null` if none.
  final ClientPackage? activePackage;

  /// The most recent [MeasurementEntry] for the client, or `null` if none.
  final MeasurementEntry? latestMeasurement;
}
