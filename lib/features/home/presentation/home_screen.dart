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
import 'package:sportin_clone/features/measurements/application/measurements_providers.dart';
import 'package:sportin_clone/features/trainers/application/trainers_providers.dart';
import 'package:sportin_clone/l10n/app_localizations.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final user = ref.watch(appUserProvider).asData?.value;
    final firstName = (user?.displayName ?? '').trim().split(' ').first;

    return Scaffold(
      body: SafeArea(
        bottom: false,
        child: SingleChildScrollView(
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 560),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(24, 20, 24, 0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Reveal(
                          index: 0,
                          child: Eyebrow(l10n.homeWelcome),
                        ),
                        const SizedBox(height: 6),
                        Reveal(
                          index: 1,
                          child: DisplayTitle(
                            firstName.isEmpty
                                ? 'Zdravo.'
                                : 'Zdravo,\n$firstName.',
                            size: 38,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 22),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Reveal(
                      index: 2,
                      child: const _SessionPoster(),
                    ),
                  ),
                  const SizedBox(height: 26),
                  Reveal(
                    index: 3,
                    child: const Marquee(
                      words: [
                        'SNAGA',
                        'KONDICIJA',
                        'DISCIPLINA',
                        'FOKUS',
                        'TEMPO',
                        'IZDRŽLJIVOST',
                      ],
                    ),
                  ),
                  const SizedBox(height: 26),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Reveal(
                          index: 4,
                          child: SectionHeader(l10n.homeShortcuts),
                        ),
                        const SizedBox(height: 14),
                        Reveal(
                          index: 5,
                          child: _QuickAction(
                            title: 'ZAKAŽI TERMIN',
                            sub: 'Izaberi trenera i zakaži trening',
                            onTap: () => context.go('/schedule'),
                          ),
                        ),
                        const SizedBox(height: 10),
                        Reveal(
                          index: 6,
                          child: _QuickAction(
                            title: 'MERENJA I NAPREDAK',
                            sub: 'Prati svoja telesna merenja',
                            onTap: () => context.go('/measurements'),
                          ),
                        ),
                        const SizedBox(height: 10),
                        Reveal(
                          index: 7,
                          child: _QuickAction(
                            title: 'PIŠI TRENERU',
                            sub: 'Chat poruke sa trenerom',
                            onTap: () => context.go('/chat'),
                          ),
                        ),
                        const SizedBox(height: 24),
                        // ── Dashboard summary (AS-065) ──────────────────────
                        if (user != null) ...[
                          Reveal(
                            index: 8,
                            child: SectionHeader('Pregled'),
                          ),
                          const SizedBox(height: 14),
                          Reveal(
                            index: 9,
                            child: _DashboardSummaryTiles(uid: user.uid),
                          ),
                        ],
                        const SizedBox(height: 32),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ── Next-training poster block ─────────────────────────────────────────────────

class _SessionPoster extends ConsumerWidget {
  const _SessionPoster();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final me = ref.watch(appUserProvider).asData?.value;
    final upcomingAsync = me != null
        ? ref.watch(clientUpcomingBookingsProvider(me.uid))
        : null;
    final soonest = upcomingAsync?.asData?.value.isNotEmpty == true
        ? upcomingAsync!.asData!.value.first
        : null;
    final trainerName = soonest != null
        ? ref
            .watch(trainerProvider(soonest.trainerUid))
            .asData
            ?.value
            ?.displayName
        : null;

    String weekday = '';
    String formattedDate = '';
    if (soonest != null) {
      try {
        final dt = DateTime.parse(soonest.date);
        weekday = DateFormat('EEEE', 'sr_Latn').format(dt);
        formattedDate = DateFormat.yMMMEd('sr_Latn').format(dt);
      } catch (_) {
        weekday = soonest.date;
        formattedDate = soonest.date;
      }
    }

    return Transform.rotate(
      angle: kTilt * 0.75,
      child: ClipPath(
        clipper: const DiagonalClipper(depth: 16),
        child: Container(
          width: double.infinity,
          color: kInkElevated,
          child: Stack(
            children: [
              const Positioned.fill(
                child: SpeedLines(density: 18, seed: 4, opacity: 0.9),
              ),
              if (soonest != null)
                Positioned(
                  right: -8,
                  bottom: 2,
                  child: GhostText(
                    soonest.start,
                    size: 88,
                    color: kLineDark,
                  ),
                ),
              Padding(
                padding: const EdgeInsets.fromLTRB(22, 28, 22, 30),
                child: soonest != null
                    ? Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              const PulseDot(size: 8),
                              const SizedBox(width: 8),
                              const Eyebrow('SLEDEĆI TRENING'),
                            ],
                          ),
                          const SizedBox(height: 12),
                          FittedBox(
                            fit: BoxFit.scaleDown,
                            alignment: Alignment.centerLeft,
                            child: Text(
                              weekday.toUpperCase(),
                              style: GoogleFonts.archivoBlack(
                                fontSize: 52,
                                color: kOffWhite,
                                height: 0.9,
                                letterSpacing: -1,
                              ),
                            ),
                          ),
                          FittedBox(
                            fit: BoxFit.scaleDown,
                            alignment: Alignment.centerLeft,
                            child: Text(
                              soonest.start,
                              style: GoogleFonts.archivoBlack(
                                fontSize: 52,
                                color: kVolt,
                                height: 0.9,
                                letterSpacing: -1,
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),
                          Container(height: 1, color: kLineDark),
                          const SizedBox(height: 12),
                          Wrap(
                            spacing: 14,
                            runSpacing: 6,
                            crossAxisAlignment: WrapCrossAlignment.center,
                            children: [
                              _meta(
                                Icons.calendar_today_rounded,
                                formattedDate.toUpperCase(),
                              ),
                            ],
                          ),
                          if (trainerName != null && trainerName.isNotEmpty) ...[
                            const SizedBox(height: 10),
                            Text(
                              'Trener: $trainerName',
                              style: GoogleFonts.interTight(
                                fontSize: 13.5,
                                color: kMutedDark,
                              ),
                            ),
                          ],
                        ],
                      )
                    : Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Eyebrow('SLEDEĆI TRENING'),
                          const SizedBox(height: 16),
                          Text(
                            'Nema zakazanih\ntreninga.',
                            style: GoogleFonts.archivoBlack(
                              fontSize: 28,
                              color: kOffWhite,
                              height: 0.9,
                            ),
                          ),
                          const SizedBox(height: 20),
                          VoltButton(
                            label: 'Zakaži termin',
                            icon: Icons.bolt_rounded,
                            onPressed: () => context.go('/schedule'),
                          ),
                        ],
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _meta(IconData icon, String text) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 12, color: kVolt),
        const SizedBox(width: 6),
        Text(
          text,
          style: GoogleFonts.interTight(
            fontSize: 10.5,
            letterSpacing: 1.4,
            fontWeight: FontWeight.w700,
            color: kOffWhite,
          ),
        ),
      ],
    );
  }
}

// ── Dashboard summary tiles (AS-065) ──────────────────────────────────────────

/// Three compact stat tiles: sessions attended, current package, latest weight.
class _DashboardSummaryTiles extends ConsumerWidget {
  const _DashboardSummaryTiles({required this.uid});

  final String uid;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final summaryAsync = ref.watch(dashboardSummaryProvider(uid));

    // While loading, render nothing — keep home layout unobtrusive.
    if (!summaryAsync.hasValue) return const SizedBox.shrink();

    final summary = summaryAsync.asData!.value;

    final latestWeight = summary.latestMeasurement?.weightKg;
    final latestDate = summary.latestMeasurement?.date;
    String latestLabel = '—';
    if (latestWeight != null) {
      latestLabel = '${kDec(latestWeight)} kg';
      if (latestDate != null) {
        try {
          final dt = DateTime.parse(latestDate);
          latestLabel +=
              '\n${DateFormat('d.M.', 'sr_Latn').format(dt)}';
        } catch (_) {}
      }
    }

    return Row(
      children: [
        Expanded(
          child: _StatTile(
            label: l10n.dashboardSessionsAttended,
            child: CountUp(
              value: summary.sessionsAttended.toDouble(),
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
            label: l10n.dashboardCurrentPackage,
            child: Text(
              summary.activePackage?.packageTypeName ?? l10n.noPackage,
              style: GoogleFonts.archivoBlack(
                fontSize: 13,
                color: summary.activePackage != null ? kOffWhite : kMutedDark,
                height: 1.1,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _StatTile(
            label: l10n.dashboardLatestMeasurement,
            child: Text(
              latestLabel,
              style: GoogleFonts.archivoBlack(
                fontSize: 13,
                color: latestWeight != null ? kOffWhite : kMutedDark,
                height: 1.1,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

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

// ── Quick-action row ───────────────────────────────────────────────────────────

class _QuickAction extends StatelessWidget {
  const _QuickAction({
    required this.title,
    required this.sub,
    required this.onTap,
  });

  final String title;
  final String sub;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: kInkElevated,
      shape: const RoundedRectangleBorder(
        side: BorderSide(color: kLineDark),
      ),
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: GoogleFonts.interTight(
                        fontSize: 11.5,
                        color: kOffWhite,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 2,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      sub,
                      style: GoogleFonts.interTight(
                        fontSize: 12.5,
                        color: kMutedDark,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              const Icon(
                Icons.arrow_outward_rounded,
                size: 18,
                color: kVolt,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
