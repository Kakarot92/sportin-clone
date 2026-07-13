import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:sportin_clone/app/kinetic.dart';
import 'package:sportin_clone/app/kinetic_effects.dart';
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
        body: me == null
            ? const Center(child: CircularProgressIndicator())
            : NestedScrollView(
                headerSliverBuilder: (context, _) => [
                  SliverToBoxAdapter(
                    child: Stack(
                      children: [
                        Positioned.fill(
                          child: Opacity(
                            opacity: 0.15,
                            child: SpeedLines(density: 16, seed: 13),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.fromLTRB(24, 16, 24, 0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Eyebrow('Termini'),
                              const SizedBox(height: 10),
                              DisplayTitle(l10n.myBookings),
                              const SizedBox(height: 16),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  SliverPersistentHeader(
                    pinned: true,
                    delegate: _TabBarDelegate(
                      TabBar(
                        labelColor: kVolt,
                        unselectedLabelColor: kMutedDark,
                        indicatorColor: kVolt,
                        indicatorWeight: 2,
                        labelStyle: GoogleFonts.interTight(
                          fontWeight: FontWeight.w800,
                          fontSize: 12,
                          letterSpacing: 1.4,
                        ),
                        tabs: [
                          Tab(text: l10n.upcoming.toUpperCase()),
                          Tab(text: l10n.history.toUpperCase()),
                        ],
                      ),
                    ),
                  ),
                ],
                body: TabBarView(
                  children: [
                    _UpcomingTab(uid: me.uid),
                    _HistoryTab(uid: me.uid),
                  ],
                ),
              ),
      ),
    );
  }
}

// ── Sliver tab bar delegate ───────────────────────────────────────────────────

class _TabBarDelegate extends SliverPersistentHeaderDelegate {
  const _TabBarDelegate(this.tabBar);

  final TabBar tabBar;

  @override
  double get minExtent => tabBar.preferredSize.height;

  @override
  double get maxExtent => tabBar.preferredSize.height;

  @override
  Widget build(
      BuildContext context, double shrinkOffset, bool overlapsContent) {
    return Container(
      color: Theme.of(context).scaffoldBackgroundColor,
      child: tabBar,
    );
  }

  @override
  bool shouldRebuild(_TabBarDelegate oldDelegate) => false;
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
        return ListView.builder(
          padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
          itemCount: bookings.length,
          itemBuilder: (_, i) => Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: Reveal(
              index: i,
              child: _BookingCard(booking: bookings[i]),
            ),
          ),
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
        return ListView.builder(
          padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
          itemCount: bookings.length,
          itemBuilder: (_, i) => Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: Reveal(
              index: i,
              child: _BookingCard(booking: bookings[i]),
            ),
          ),
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

    // Trainer name.
    final trainerName = ref
        .watch(trainerProvider(booking.trainerUid))
        .asData
        ?.value
        ?.displayName;

    final isCancelled = booking.status == 'cancelled';
    final badgeLabel = isCancelled ? l10n.statusCancelled : l10n.statusBooked;

    return Container(
      padding: const EdgeInsets.fromLTRB(16, 14, 12, 14),
      decoration: BoxDecoration(
        color: kInkElevated,
        border: Border.all(color: isCancelled ? kDanger.withValues(alpha: 0.4) : kLineDark),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Big Archivo Black time
                Text(
                  '${booking.start}–${booking.end}',
                  style: GoogleFonts.archivoBlack(
                    color: kOffWhite,
                    fontSize: 20,
                    height: 1.0,
                  ),
                ),
                const SizedBox(height: 4),
                Text(formattedDate, style: theme.textTheme.bodyMedium),
                if (trainerName != null && trainerName.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Text(trainerName, style: theme.textTheme.bodyMedium),
                ],
              ],
            ),
          ),
          const SizedBox(width: 8),
          // Status badge — kDanger tone for cancelled
          isCancelled
              ? _DangerBadge(badgeLabel)
              : VoltBadge(badgeLabel, filled: true),
        ],
      ),
    );
  }
}

/// Skewed danger-coloured badge for cancelled bookings.
class _DangerBadge extends StatelessWidget {
  const _DangerBadge(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Transform(
      transform: Matrix4.skewX(-0.2),
      alignment: Alignment.center,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        decoration: BoxDecoration(
          border: Border.all(color: kDanger, width: 1.5),
        ),
        child: Transform(
          transform: Matrix4.skewX(0.2),
          alignment: Alignment.center,
          child: Text(
            text.toUpperCase(),
            style: GoogleFonts.interTight(
              color: kDanger,
              fontWeight: FontWeight.w800,
              fontSize: 11,
              letterSpacing: 1,
            ),
          ),
        ),
      ),
    );
  }
}
