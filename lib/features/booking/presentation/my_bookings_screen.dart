import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:sportin_clone/app/kinetic.dart';
import 'package:sportin_clone/app/kinetic_effects.dart';
import 'package:sportin_clone/app/theme.dart';
import 'package:sportin_clone/features/auth/application/auth_providers.dart';
import 'package:sportin_clone/features/booking/application/booking_providers.dart';
import 'package:sportin_clone/features/booking/domain/booking_exceptions.dart';
import 'package:sportin_clone/features/booking/domain/booking_policy.dart';
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
              child: _BookingCard(booking: bookings[i], isUpcoming: true),
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

class _BookingCard extends ConsumerStatefulWidget {
  const _BookingCard({required this.booking, this.isUpcoming = false});

  final Booking booking;

  /// When [isUpcoming] is true and the booking is within the cancellation
  /// cutoff, cancel and reschedule action buttons are shown.
  final bool isUpcoming;

  @override
  ConsumerState<_BookingCard> createState() => _BookingCardState();
}

class _BookingCardState extends ConsumerState<_BookingCard> {
  /// Prompts the user for confirmation, then cancels the booking.
  Future<void> _cancel() async {
    final l10n = AppLocalizations.of(context);
    // Capture messenger before the async gap (AS-035 safe pattern).
    final messenger = ScaffoldMessenger.of(context);

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l10n.cancelConfirmTitle),
        content: Text(l10n.cancelConfirmBody(widget.booking.start)),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: Text(l10n.cancel),
          ),
          FilledButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: Text(l10n.cancelBooking),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    final ok = await ref
        .read(bookingControllerProvider.notifier)
        .cancel(widget.booking);

    if (!mounted) return;

    if (ok) {
      messenger.showSnackBar(SnackBar(content: Text(l10n.cancelSuccess)));
    } else {
      final err = ref.read(bookingControllerProvider).error;
      final msg = err is CutoffPassedException
          ? l10n.cutoffPassedError
          : l10n.errorGeneric;
      messenger.showSnackBar(SnackBar(content: Text(msg)));
    }
  }

  /// Navigates to the trainer's slot browser in reschedule mode.
  void _reschedule() {
    context.push(
      '/schedule/trainer/${widget.booking.trainerUid}/slots',
      extra: widget.booking,
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);

    // Parse date for display.
    final dateStr = widget.booking.date; // "YYYY-MM-DD"
    String formattedDate = dateStr;
    try {
      final dt = DateTime.parse(dateStr);
      formattedDate = DateFormat.yMMMEd('sr_Latn').format(dt);
    } catch (_) {
      // fall back to raw string
    }

    // Trainer name.
    final trainerName = ref
        .watch(trainerProvider(widget.booking.trainerUid))
        .asData
        ?.value
        ?.displayName;

    final isCancelled = widget.booking.status == 'cancelled';
    final badgeLabel = isCancelled ? l10n.statusCancelled : l10n.statusBooked;

    // Show action buttons only when the session is upcoming, booked, and
    // has not yet started (AS-035, AS-036).
    final canCancel =
        widget.isUpcoming && !isCancelled && canCancelBooking(widget.booking);

    return Container(
      padding: const EdgeInsets.fromLTRB(16, 14, 12, 14),
      decoration: BoxDecoration(
        color: kInkElevated,
        border: Border.all(
            color: isCancelled ? kDanger.withValues(alpha: 0.4) : kLineDark),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Time, date, trainer and badge ──
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Big Archivo Black time
                    Text(
                      '${widget.booking.start}–${widget.booking.end}',
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

          // ── Cancel / Reschedule actions (AS-035, AS-039) ──
          if (canCancel) ...[
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                _ActionButton(
                  label: l10n.reschedule,
                  color: kVolt,
                  onPressed: _reschedule,
                ),
                const SizedBox(width: 8),
                _ActionButton(
                  label: l10n.cancelBooking,
                  color: kDanger,
                  onPressed: _cancel,
                ),
              ],
            ),
          ],

        ],
      ),
    );
  }
}

// ─── Small inline action button ───────────────────────────────────────────────

/// Compact sharp-cornered outline button for cancel/reschedule card actions.
/// Tap target is ≥48dp (enforced by [minimumSize]).
class _ActionButton extends StatelessWidget {
  const _ActionButton({
    required this.label,
    required this.color,
    required this.onPressed,
  });

  final String label;
  final Color color;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return OutlinedButton(
      style: OutlinedButton.styleFrom(
        foregroundColor: color,
        side: BorderSide(color: color),
        minimumSize: const Size(0, 48),
        padding: const EdgeInsets.symmetric(horizontal: 14),
        shape: const RoundedRectangleBorder(),
        textStyle: GoogleFonts.interTight(
          fontWeight: FontWeight.w700,
          fontSize: 12,
          letterSpacing: 0.6,
        ),
      ),
      onPressed: onPressed,
      child: Text(label),
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
