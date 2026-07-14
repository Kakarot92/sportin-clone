import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:sportin_clone/app/kinetic.dart';
import 'package:sportin_clone/app/kinetic_effects.dart';
import 'package:sportin_clone/app/theme.dart';
import 'package:sportin_clone/features/auth/application/auth_providers.dart';
import 'package:sportin_clone/features/booking/application/booking_providers.dart';
import 'package:sportin_clone/features/booking/domain/booking_exceptions.dart';
import 'package:sportin_clone/features/booking/domain/booking_policy.dart';
import 'package:sportin_clone/l10n/app_localizations.dart';

import '../../scheduling/domain/booking.dart';

/// Trainer-facing screen showing all their sessions (booked + cancelled).
///
/// Route: /profile/sessions
/// Guard: trainer-only
class TrainerSessionsScreen extends ConsumerWidget {
  const TrainerSessionsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final me = ref.watch(appUserProvider).asData?.value;

    if (me == null || !me.isTrainer) {
      return Scaffold(
        appBar: AppBar(),
        body: Center(child: Text(l10n.notAuthorized)),
      );
    }

    final sessionsAsync = ref.watch(trainerSessionsProvider(me.uid));

    return Scaffold(
      appBar: AppBar(),
      body: sessionsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (_, _) => Center(child: Text(l10n.errorGeneric)),
        data: (sessions) => CustomScrollView(
          slivers: [
            SliverToBoxAdapter(
              child: Stack(
                children: [
                  Positioned.fill(
                    child: Opacity(
                      opacity: 0.15,
                      child: SpeedLines(density: 16, seed: 21),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(24, 16, 24, 20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Eyebrow('Trener'),
                        const SizedBox(height: 10),
                        DisplayTitle(l10n.mySessions),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            if (sessions.isEmpty)
              SliverFillRemaining(
                child: Center(
                  child: Text(
                    l10n.noSessions,
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ),
              )
            else
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(24, 0, 24, 32),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, i) => Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: Reveal(
                        index: i,
                        child: _SessionCard(session: sessions[i]),
                      ),
                    ),
                    childCount: sessions.length,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

// ─── Session card ─────────────────────────────────────────────────────────────

class _SessionCard extends ConsumerStatefulWidget {
  const _SessionCard({required this.session});

  final Booking session;

  @override
  ConsumerState<_SessionCard> createState() => _SessionCardState();
}

class _SessionCardState extends ConsumerState<_SessionCard> {
  /// Prompts for confirmation, then cancels the session (AS-040).
  Future<void> _cancel() async {
    final l10n = AppLocalizations.of(context);
    // Capture messenger before the async gap.
    final messenger = ScaffoldMessenger.of(context);

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l10n.cancelConfirmTitle),
        content: Text(l10n.cancelConfirmBody(widget.session.start)),
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
        .cancel(widget.session);

    if (!mounted) return;

    if (ok) {
      messenger.showSnackBar(SnackBar(content: Text(l10n.cancelSuccess)));
    } else {
      final err = ref.read(bookingControllerProvider).error;
      final msg = err is CutoffPassedException
          ? l10n.cutoffPassedError(kCancellationCutoffHours)
          : l10n.errorGeneric;
      messenger.showSnackBar(SnackBar(content: Text(msg)));
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);

    // Parse date for display.
    final dateStr = widget.session.date; // "YYYY-MM-DD"
    String formattedDate = dateStr;
    try {
      final dt = DateTime.parse(dateStr);
      formattedDate = DateFormat.yMMMEd('sr_Latn').format(dt);
    } catch (_) {
      // fall back to raw string
    }

    final isCancelled = widget.session.status == 'cancelled';
    final badgeLabel = isCancelled ? l10n.statusCancelled : l10n.statusBooked;

    // Show client UID (abbreviated) since no client name is available here.
    final clientShort = widget.session.clientUid.length > 8
        ? widget.session.clientUid.substring(0, 8)
        : widget.session.clientUid;

    // Show cancel button only for booked sessions within the cutoff (AS-040).
    final canCancel = !isCancelled && canCancelBooking(widget.session);

    // When the session is in the future, not cancelled, but the cutoff window
    // has already passed, show a muted note so the trainer knows why the
    // cancel button is absent (Bug-2 fix).
    final sessionStart =
        bookingSlotStart(widget.session.date, widget.session.start);
    final showCutoffNote = !isCancelled &&
        !canCancelBooking(widget.session) &&
        sessionStart.isAfter(DateTime.now());

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
          // ── Time, date, client and badge ──
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Big Archivo Black time
                    Text(
                      '${widget.session.start}–${widget.session.end}',
                      style: GoogleFonts.archivoBlack(
                        color: kOffWhite,
                        fontSize: 20,
                        height: 1.0,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(formattedDate, style: theme.textTheme.bodyMedium),
                    const SizedBox(height: 4),
                    Text(
                      clientShort,
                      style: theme.textTheme.bodyMedium,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              isCancelled
                  ? _DangerBadge(badgeLabel)
                  : VoltBadge(badgeLabel, filled: true),
            ],
          ),

          // ── Cancel action (AS-040) ──
          if (canCancel) ...[
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                OutlinedButton(
                  style: OutlinedButton.styleFrom(
                    foregroundColor: kDanger,
                    side: const BorderSide(color: kDanger),
                    minimumSize: const Size(0, 48),
                    padding: const EdgeInsets.symmetric(horizontal: 14),
                    shape: const RoundedRectangleBorder(),
                    textStyle: GoogleFonts.interTight(
                      fontWeight: FontWeight.w700,
                      fontSize: 12,
                      letterSpacing: 0.6,
                    ),
                  ),
                  onPressed: _cancel,
                  child: Text(l10n.cancelBooking),
                ),
              ],
            ),
          ],

          // ── Cutoff-locked note (Bug-2 fix) ──
          // Upcoming session that is no longer cancellable: tell the trainer
          // why the cancel button is absent instead of silently hiding it.
          if (showCutoffNote) ...[
            const SizedBox(height: 8),
            Row(
              children: [
                const Icon(
                  Icons.lock_clock_outlined,
                  color: kMutedDark,
                  size: 14,
                ),
                const SizedBox(width: 4),
                Flexible(
                  child: Text(
                    l10n.cutoffPassedError(kCancellationCutoffHours),
                    style: theme.textTheme.bodySmall
                        ?.copyWith(color: kMutedDark),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

/// Skewed danger-coloured badge for cancelled sessions.
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
