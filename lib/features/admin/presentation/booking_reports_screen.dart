import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sportin_clone/app/kinetic.dart';
import 'package:sportin_clone/app/kinetic_effects.dart';
import 'package:sportin_clone/app/theme.dart';
import 'package:sportin_clone/features/auth/application/auth_providers.dart';
import 'package:sportin_clone/features/booking/application/booking_providers.dart';
import 'package:sportin_clone/features/scheduling/domain/booking.dart';
import 'package:sportin_clone/features/trainers/application/trainers_providers.dart';
import 'package:sportin_clone/l10n/app_localizations.dart';

/// Admin screen: booking/attendance statistics report (AS-088).
///
/// Shows:
///  - Total bookings loaded, active count, cancelled count (summary tiles)
///  - Per-trainer booking count
///  - Inline revenue placeholder (AS-089 deferred)
///
/// Route: /profile/admin-reports
/// Guard: admin-only (AS-091).
class BookingReportsScreen extends ConsumerWidget {
  const BookingReportsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final me = ref.watch(appUserProvider).asData?.value;

    if (me == null || !me.isAdmin) {
      return Scaffold(
        appBar: AppBar(),
        body: Center(child: Text(l10n.notAuthorized)),
      );
    }

    final bookingsAsync = ref.watch(allBookingsProvider);

    return Scaffold(
      appBar: AppBar(),
      body: bookingsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text(l10n.errorGeneric)),
        data: (bookings) => _ReportsBody(bookings: bookings),
      ),
    );
  }
}

// ── Body ──────────────────────────────────────────────────────────────────────

class _ReportsBody extends ConsumerWidget {
  const _ReportsBody({required this.bookings});

  final List<Booking> bookings;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);

    final total = bookings.length;
    final booked = bookings.where((b) => b.status == 'booked').length;
    final cancelled = bookings.where((b) => b.status == 'cancelled').length;

    // Group by trainerUid.
    final Map<String, int> byTrainer = {};
    for (final b in bookings) {
      byTrainer[b.trainerUid] = (byTrainer[b.trainerUid] ?? 0) + 1;
    }
    final trainerEntries = byTrainer.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    return ListView(
      padding: const EdgeInsets.fromLTRB(24, 0, 24, 32),
      children: [
        const Eyebrow('Admin'),
        const SizedBox(height: 10),
        DisplayTitle(l10n.bookingReports),
        const SizedBox(height: 24),

        // ── Summary tiles ──────────────────────────────────────────────────
        Row(
          children: [
            Expanded(
              child: _StatTile(
                label: l10n.totalBookings,
                child: CountUp(
                  value: total.toDouble(),
                  style: GoogleFonts.archivoBlack(
                    fontSize: 22,
                    color: kVolt,
                    height: 1.0,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _StatTile(
                label: l10n.bookedCount,
                child: CountUp(
                  value: booked.toDouble(),
                  style: GoogleFonts.archivoBlack(
                    fontSize: 22,
                    color: kOffWhite,
                    height: 1.0,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _StatTile(
                label: l10n.cancelledCount,
                child: CountUp(
                  value: cancelled.toDouble(),
                  style: GoogleFonts.archivoBlack(
                    fontSize: 22,
                    color: kDanger,
                    height: 1.0,
                  ),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 24),

        // ── Per-trainer breakdown ──────────────────────────────────────────
        if (trainerEntries.isNotEmpty) ...[
          SectionHeader(l10n.byTrainer),
          const SizedBox(height: 12),
          ...trainerEntries.map(
            (e) => _TrainerStatRow(
              trainerUid: e.key,
              count: e.value,
            ),
          ),
          const SizedBox(height: 28),
        ],

        // ── Revenue placeholder (AS-089 deferred) ─────────────────────────
        _RevenuePlaceholderCard(l10n: l10n, theme: theme),
      ],
    );
  }
}

// ── Stat tile (mirrors home screen _StatTile) ─────────────────────────────────

class _StatTile extends StatelessWidget {
  const _StatTile({required this.label, required this.child});

  final String label;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(12, 10, 12, 12),
      decoration: BoxDecoration(
        color: kInkElevated,
        border: Border.all(color: kLineDark),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label.toUpperCase(),
            style: GoogleFonts.interTight(
              fontSize: 9,
              color: kMutedDark,
              fontWeight: FontWeight.w700,
              letterSpacing: 1.2,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 6),
          child,
        ],
      ),
    );
  }
}

// ── Per-trainer row ───────────────────────────────────────────────────────────

class _TrainerStatRow extends ConsumerWidget {
  const _TrainerStatRow({required this.trainerUid, required this.count});

  final String trainerUid;
  final int count;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final trainerAsync = ref.watch(trainerProvider(trainerUid));
    final name = trainerAsync.asData?.value?.displayName ?? trainerUid;

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
      decoration: BoxDecoration(
        color: kInkElevated,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Theme.of(context).dividerColor),
      ),
      child: Row(
        children: [
          const Icon(Icons.person_outline, size: 16, color: kMutedDark),
          const SizedBox(width: 10),
          Expanded(
            child: Text(name, style: Theme.of(context).textTheme.bodyLarge),
          ),
          Text(
            count.toString(),
            style: GoogleFonts.archivoBlack(fontSize: 16, color: kVolt),
          ),
        ],
      ),
    );
  }
}

// ── Revenue coming-soon card (AS-089 deferred) ────────────────────────────────

class _RevenuePlaceholderCard extends StatelessWidget {
  const _RevenuePlaceholderCard({required this.l10n, required this.theme});

  final AppLocalizations l10n;
  final ThemeData theme;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: kInkElevated,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: kLineDark),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SectionHeader('Revenue'),
          const SizedBox(height: 16),
          Center(
            child: GhostText(
              '€',
              size: 52,
              color: kLineDark,
              strokeWidth: 1.2,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            l10n.revenueReportsComingSoon,
            textAlign: TextAlign.center,
            style: theme.textTheme.bodyMedium,
          ),
        ],
      ),
    );
  }
}
