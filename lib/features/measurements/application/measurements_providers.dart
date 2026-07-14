import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../auth/application/auth_providers.dart';
import '../../booking/application/booking_providers.dart';
import '../../packages/application/packages_providers.dart';
import '../../packages/domain/client_package.dart';
import '../data/measurements_repository.dart';
import '../data/trainer_clients_repository.dart';
import '../domain/measurement_entry.dart';
import '../domain/trainer_client_ref.dart';
import 'dashboard_summary.dart';

// ─── Repositories ─────────────────────────────────────────────────────────────

/// Provides the [MeasurementsRepository] backed by the shared Firestore instance.
final measurementsRepositoryProvider = Provider<MeasurementsRepository>((ref) {
  return MeasurementsRepository(ref.watch(firestoreProvider));
});

/// Provides the [TrainerClientsRepository] backed by the shared Firestore instance.
final trainerClientsRepositoryProvider =
    Provider<TrainerClientsRepository>((ref) {
  return TrainerClientsRepository(ref.watch(firestoreProvider));
});

// ─── Stream providers ─────────────────────────────────────────────────────────

/// Watches all measurement entries for [clientUid], ordered newest first.
///
/// Family parameter: [clientUid] (AS-056, AS-061, AS-062).
final clientMeasurementsProvider =
    StreamProvider.family<List<MeasurementEntry>, String>((ref, clientUid) {
  return ref
      .watch(measurementsRepositoryProvider)
      .watchClientMeasurements(clientUid);
});

/// Watches all clients that have booked [trainerUid], newest first.
///
/// Family parameter: [trainerUid] (AS-063).
final myClientsProvider =
    StreamProvider.family<List<TrainerClientRef>, String>((ref, trainerUid) {
  return ref
      .watch(trainerClientsRepositoryProvider)
      .watchMyClients(trainerUid);
});

// ─── Dashboard summary provider ───────────────────────────────────────────────

/// Combines booking history, active package, and latest measurement into a
/// single [DashboardSummary] for [clientUid] (AS-065).
///
/// Pattern mirrors [availableSlotsProvider] in scheduling_providers.dart:
/// propagate loading/error from any upstream; emit [AsyncData] when all are
/// ready.
final dashboardSummaryProvider =
    Provider.family<AsyncValue<DashboardSummary>, String>((ref, clientUid) {
  final historyAsync = ref.watch(clientBookingHistoryProvider(clientUid));
  final packagesAsync = ref.watch(clientPackagesProvider(clientUid));
  final measurementsAsync = ref.watch(clientMeasurementsProvider(clientUid));

  // Propagate loading state.
  if (historyAsync.isLoading ||
      packagesAsync.isLoading ||
      measurementsAsync.isLoading) {
    return const AsyncLoading();
  }

  // Propagate the first error encountered.
  if (historyAsync.hasError) {
    return AsyncValue.error(
      historyAsync.error!,
      historyAsync.stackTrace ?? StackTrace.empty,
    );
  }
  if (packagesAsync.hasError) {
    return AsyncValue.error(
      packagesAsync.error!,
      packagesAsync.stackTrace ?? StackTrace.empty,
    );
  }
  if (measurementsAsync.hasError) {
    return AsyncValue.error(
      measurementsAsync.error!,
      measurementsAsync.stackTrace ?? StackTrace.empty,
    );
  }

  // All sources ready — compute the summary.
  final history = historyAsync.asData!.value;
  final packages = packagesAsync.asData!.value;
  final measurements = measurementsAsync.asData!.value;

  // Count attended sessions: history entries with status == 'booked' are past
  // sessions that were completed (not cancelled). The watchClientHistory stream
  // includes past-booked and all-cancelled; filter for booked only.
  final sessionsAttended = history.where((b) => b.status == 'booked').length;

  // Pick the first active package (packages already ordered newest-assigned
  // first, so we get the most relevant one).
  ClientPackage? activePackage;
  for (final p in packages) {
    if (p.isActive()) {
      activePackage = p;
      break;
    }
  }

  // Latest measurement is already at index 0 (ordered descending by date).
  final latestMeasurement = measurements.isNotEmpty ? measurements.first : null;

  return AsyncData(
    DashboardSummary(
      sessionsAttended: sessionsAttended,
      activePackage: activePackage,
      latestMeasurement: latestMeasurement,
    ),
  );
});

// ─── Controller ───────────────────────────────────────────────────────────────

/// Handles measurement-entry CRUD with loading/error state.
///
/// Mirrors [BookingController]'s exact style (AS-056, AS-062).
class MeasurementsController extends AsyncNotifier<void> {
  @override
  Future<void> build() async {}

  MeasurementsRepository get _repo => ref.read(measurementsRepositoryProvider);

  /// Adds a new measurement entry for the signed-in client (AS-056).
  ///
  /// Returns `true` on success, `false` on error.
  Future<bool> addEntry(MeasurementEntry e) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() => _repo.addEntry(e));
    return !state.hasError;
  }

  /// Updates an existing measurement entry (AS-062).
  ///
  /// Returns `true` on success, `false` on error.
  Future<bool> updateEntry(MeasurementEntry e) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() => _repo.updateEntry(e));
    return !state.hasError;
  }

  /// Deletes a measurement entry by [id] (AS-062).
  ///
  /// Returns `true` on success, `false` on error.
  Future<bool> deleteEntry(String id) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() => _repo.deleteEntry(id));
    return !state.hasError;
  }
}

/// Provider for [MeasurementsController].
final measurementsControllerProvider =
    AsyncNotifierProvider<MeasurementsController, void>(
        MeasurementsController.new);
