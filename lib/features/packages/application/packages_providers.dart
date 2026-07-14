import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../auth/application/auth_providers.dart';
import '../data/packages_repository.dart';
import '../domain/client_package.dart';
import '../domain/package_type.dart';

// ─── Repository ──────────────────────────────────────────────────────────────

/// Provides the [PackagesRepository] backed by the shared Firestore instance.
final packagesRepositoryProvider = Provider<PackagesRepository>((ref) {
  return PackagesRepository(ref.watch(firestoreProvider));
});

// ─── Stream providers ────────────────────────────────────────────────────────

/// Watches package types.
///
/// Family parameter: [activeOnly].
/// Use `packageTypesProvider(true)` for assignment dropdowns (active only),
/// `packageTypesProvider(false)` for the admin management screen (AS-047).
final packageTypesProvider =
    StreamProvider.family<List<PackageType>, bool>((ref, activeOnly) {
  return ref
      .watch(packagesRepositoryProvider)
      .watchPackageTypes(activeOnly: activeOnly);
});

/// Watches all packages assigned to a client, newest first.
///
/// Family parameter: [clientUid] (AS-049).
final clientPackagesProvider =
    StreamProvider.family<List<ClientPackage>, String>((ref, clientUid) {
  return ref.watch(packagesRepositoryProvider).watchClientPackages(clientUid);
});

// ─── Controller ──────────────────────────────────────────────────────────────

/// Handles package-type creation and package assignment with loading/error
/// state. Admin-only operations (AS-047, AS-048).
class PackageAdminController extends AsyncNotifier<void> {
  @override
  Future<void> build() async {}

  /// Creates a new package type.
  ///
  /// Returns `true` on success, `false` on error.
  Future<bool> createType(PackageType type) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(
      () => ref.read(packagesRepositoryProvider).createPackageType(type),
    );
    return !state.hasError;
  }

  /// Assigns a package instance to a client.
  ///
  /// Returns `true` on success, `false` on error.
  Future<bool> assign({
    required String clientUid,
    required PackageType type,
    required String assignedByUid,
  }) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(
      () => ref.read(packagesRepositoryProvider).assignPackage(
            clientUid: clientUid,
            type: type,
            assignedByUid: assignedByUid,
          ),
    );
    return !state.hasError;
  }
}

/// Provider for [PackageAdminController].
final packageAdminControllerProvider =
    AsyncNotifierProvider<PackageAdminController, void>(
        PackageAdminController.new);
