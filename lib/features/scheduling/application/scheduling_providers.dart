import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../auth/application/auth_providers.dart';
import '../data/availability_repository.dart';
import '../domain/availability_exception.dart';
import '../domain/availability_service.dart';
import '../domain/booking.dart';
import '../domain/slot.dart';
import '../domain/studio_settings.dart';
import '../domain/weekly_availability.dart';

// ─── Repository ─────────────────────────────────────────────────────────────

/// Provides the [AvailabilityRepository] backed by the shared Firestore instance.
///
/// Re-uses [firestoreProvider] from auth_providers — no second Firestore
/// instance is created.
final availabilityRepositoryProvider = Provider<AvailabilityRepository>((ref) {
  return AvailabilityRepository(ref.watch(firestoreProvider));
});

// ─── Stream providers ────────────────────────────────────────────────────────

/// Watches the weekly availability template for a trainer.
///
/// Emits `null` when the trainer has not yet defined a template.
final weeklyTemplateProvider =
    StreamProvider.family<WeeklyAvailability?, String>((ref, uid) {
  return ref.watch(availabilityRepositoryProvider).watchTemplate(uid);
});

/// Watches studio-wide scheduling settings (closed days / closed dates).
final studioSettingsProvider = StreamProvider<StudioSettings>((ref) {
  return ref.watch(availabilityRepositoryProvider).watchStudioSettings();
});

/// Watches the one-off availability exceptions for a trainer.
final trainerExceptionsProvider =
    StreamProvider.family<List<AvailabilityException>, String>((ref, uid) {
  return ref.watch(availabilityRepositoryProvider).watchExceptions(uid);
});

/// Watches active bookings for a trainer on a specific day.
final dayBookingsProvider =
    StreamProvider.family<List<Booking>, ({String trainerUid, DateTime day})>(
        (ref, param) {
  return ref
      .watch(availabilityRepositoryProvider)
      .watchBookingsForDay(param.trainerUid, param.day);
});

// ─── Derived provider ────────────────────────────────────────────────────────

/// Computes the list of available [Slot]s for a trainer on a given day.
///
/// Combines [weeklyTemplateProvider], [studioSettingsProvider],
/// [trainerExceptionsProvider], and [dayBookingsProvider] and delegates to
/// the pure [generateDaySlots] function.
///
/// Returns [AsyncLoading] when any upstream is still loading, or [AsyncError]
/// if any upstream fails. Uses [WeeklyAvailability.empty] when the trainer has
/// no template yet (produces no slots).
final availableSlotsProvider = Provider.family<AsyncValue<List<Slot>>,
    ({String trainerUid, DateTime day})>((ref, param) {
  final uid = param.trainerUid;
  final day = param.day;

  final templateAsync = ref.watch(weeklyTemplateProvider(uid));
  final studioAsync = ref.watch(studioSettingsProvider);
  final exceptionsAsync = ref.watch(trainerExceptionsProvider(uid));
  final bookingsAsync = ref.watch(
    dayBookingsProvider((trainerUid: uid, day: day)),
  );

  // Propagate loading state.
  if (templateAsync.isLoading ||
      studioAsync.isLoading ||
      exceptionsAsync.isLoading ||
      bookingsAsync.isLoading) {
    return const AsyncLoading();
  }

  // Propagate the first error encountered.
  if (templateAsync.hasError) {
    return AsyncValue.error(
      templateAsync.error!,
      templateAsync.stackTrace ?? StackTrace.empty,
    );
  }
  if (studioAsync.hasError) {
    return AsyncValue.error(
      studioAsync.error!,
      studioAsync.stackTrace ?? StackTrace.empty,
    );
  }
  if (exceptionsAsync.hasError) {
    return AsyncValue.error(
      exceptionsAsync.error!,
      exceptionsAsync.stackTrace ?? StackTrace.empty,
    );
  }
  if (bookingsAsync.hasError) {
    return AsyncValue.error(
      bookingsAsync.error!,
      bookingsAsync.stackTrace ?? StackTrace.empty,
    );
  }

  // All sources are ready — compute available slots.
  final template =
      templateAsync.asData?.value ?? WeeklyAvailability.empty(uid);
  final studio = studioAsync.asData!.value;
  final exceptions = exceptionsAsync.asData!.value;
  final bookings = bookingsAsync.asData!.value;

  return AsyncData(
    generateDaySlots(
      day: day,
      template: template,
      studio: studio,
      exceptions: exceptions,
      bookings: bookings,
    ),
  );
});
