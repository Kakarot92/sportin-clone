import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:sportin_clone/app/kinetic.dart';
import 'package:sportin_clone/app/theme.dart';
import 'package:sportin_clone/features/auth/application/auth_providers.dart';
import 'package:sportin_clone/features/booking/application/booking_providers.dart';
import 'package:sportin_clone/features/trainers/application/trainers_providers.dart';
import 'package:sportin_clone/l10n/app_localizations.dart';

import '../../scheduling/domain/booking.dart';

/// Client-facing screen showing upcoming bookings and booking history.
///
/// Route: /profile/bookings
class MyBookingsScreen extends ConsumerWidget {
  const MyBookingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final me = ref.watch(appUserProvider).asData?.value;

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          bottom: TabBar(
            labelColor: kVolt,
            unselectedLabelColor: kMutedDark,
            indicatorColor: kVolt,
            tabs: [
              Tab(text: l10n.upcoming.toUpperCase()),
              Tab(text: l10n.history.toUpperCase()),
            ],
          ),
        ),
        body: me == null
            ? const Center(child: CircularProgressIndicator())
            : Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(24, 24, 24, 0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Eyebrow('Termini'),
                        const SizedBox(height: 10),
                        DisplayTitle(l10n.myBookings),
                        const SizedBox(height: 16),
                      ],
                    ),
                  ),
                  Expanded(
                    child: TabBarView(
                      children: [
                        _UpcomingTab(uid: me.uid),
                        _HistoryTab(uid: me.uid),
                      ],
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}

// ─── Upcoming tab ─────────────────────────────────────────────────────────────

class _UpcomingTab extends ConsumerWidget {
  const _UpcomingTab({required this.uid});

  final String uid;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final upcomingAsync = ref.watch(clientUpcomingBookingsProvider(uid));

    return upcomingAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (_, _) => Center(child: Text(l10n.errorGeneric)),
      data: (bookings) {
        if (bookings.isEmpty) {
          return Center(
            child: Text(
              l10n.noUpcomingBookings,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          );
        }
        return ListView.separated(
          padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
          itemCount: bookings.length,
          separatorBuilder: (_, _) => const SizedBox(height: 10),
          itemBuilder: (_, i) => _BookingCard(booking: bookings[i]),
        );
      },
    );
  }
}

// ─── History tab ──────────────────────────────────────────────────────────────

class _HistoryTab extends ConsumerWidget {
  const _HistoryTab({required this.uid});

  final String uid;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final historyAsync = ref.watch(clientBookingHistoryProvider(uid));

    return historyAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (_, _) => Center(child: Text(l10n.errorGeneric)),
      data: (bookings) {
        if (bookings.isEmpty) {
          return Center(
            child: Text(
              l10n.noBookingHistory,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          );
        }
        return ListView.separated(
          padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
          itemCount: bookings.length,
          separatorBuilder: (_, _) => const SizedBox(height: 10),
          itemBuilder: (_, i) => _BookingCard(booking: bookings[i]),
        );
      },
    );
  }
}

// ─── Booking card ─────────────────────────────────────────────────────────────

class _BookingCard extends ConsumerWidget {
  const _BookingCard({required this.booking});

  final Booking booking;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);

    // Parse date for display.
    final dateStr = booking.date; // "YYYY-MM-DD"
    String formattedDate = dateStr;
    try {
      final dt = DateTime.parse(dateStr);
      formattedDate = DateFormat.yMMMEd('sr').format(dt);
    } catch (_) {
      // fall back to raw string
    }

    // Trainer name (optional enhancement).
    final trainerName = ref
        .watch(trainerProvider(booking.trainerUid))
        .asData
        ?.value
        ?.displayName;

    final isCancelled = booking.status == 'cancelled';
    final badgeLabel =
        isCancelled ? l10n.statusCancelled : l10n.statusBooked;

    return Container(
      padding: const EdgeInsets.fromLTRB(16, 14, 12, 14),
      decoration: BoxDecoration(
        color: kInkElevated,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: theme.dividerColor),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(formattedDate, style: theme.textTheme.titleMedium),
                const SizedBox(height: 4),
                Text(
                  '${booking.start}–${booking.end}',
                  style: theme.textTheme.bodyMedium,
                ),
                if (trainerName != null && trainerName.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Text(trainerName,
                      style: theme.textTheme.bodyMedium),
                ],
              ],
            ),
          ),
          VoltBadge(
            badgeLabel,
            filled: !isCancelled,
          ),
        ],
      ),
    );
  }
}
