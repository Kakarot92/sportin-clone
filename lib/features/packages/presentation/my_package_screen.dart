import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:sportin_clone/app/kinetic.dart';
import 'package:sportin_clone/app/kinetic_effects.dart';
import 'package:sportin_clone/app/theme.dart';
import 'package:sportin_clone/features/auth/application/auth_providers.dart';
import 'package:sportin_clone/features/packages/application/packages_providers.dart';
import 'package:sportin_clone/features/packages/domain/client_package.dart';
import 'package:sportin_clone/features/packages/domain/package_type.dart';
import 'package:sportin_clone/l10n/app_localizations.dart';

/// Client screen showing the active package and package history.
///
/// Route: /profile/package
class MyPackageScreen extends ConsumerWidget {
  const MyPackageScreen({super.key});

  /// Formats a "YYYY-MM-DD" date string using the Serbian locale.
  String _formatDate(String ymd) {
    try {
      final dt = DateTime.parse(ymd);
      return DateFormat.yMMMEd('sr_Latn').format(dt);
    } catch (_) {
      return ymd;
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final me = ref.watch(appUserProvider).asData?.value;

    if (me == null) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    final packagesAsync = ref.watch(clientPackagesProvider(me.uid));

    return Scaffold(
      appBar: AppBar(),
      body: packagesAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (_, _) => Center(child: Text(l10n.errorGeneric)),
        data: (packages) {
          final activePackage = packages
              .where((p) => p.isActive())
              .toList()
              .fold<ClientPackage?>(null, (best, p) {
            if (best == null) return p;
            return p.expiryDate.compareTo(best.expiryDate) > 0 ? p : best;
          });

          final history = packages.where((p) => !p.isActive()).toList();

          return ListView(
            padding: const EdgeInsets.fromLTRB(24, 0, 24, 32),
            children: [
              // ── Header with SpeedLines ──────────────────────────────────
              Stack(
                children: [
                  Positioned.fill(
                    child: Opacity(
                      opacity: 0.15,
                      child: SpeedLines(density: 16, seed: 7),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 16, bottom: 8),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Eyebrow('Termini'),
                        const SizedBox(height: 10),
                        DisplayTitle(l10n.myPackage),
                        const SizedBox(height: 16),
                      ],
                    ),
                  ),
                ],
              ),

              // ── Active package card ─────────────────────────────────────
              Reveal(
                index: 0,
                child: activePackage != null
                    ? _ActivePackageCard(
                        pkg: activePackage,
                        formatDate: _formatDate,
                      )
                    : _NoPackageCard(),
              ),
              const SizedBox(height: 28),

              // ── Package history ─────────────────────────────────────────
              Reveal(
                index: 1,
                child: SectionHeader(l10n.packageHistory),
              ),
              const SizedBox(height: 12),
              if (history.isEmpty)
                Reveal(
                  index: 2,
                  child: Text(
                    l10n.noPackageHistory,
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                )
              else
                ...history.asMap().entries.map((e) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Reveal(
                      index: e.key + 2,
                      child: _HistoryRow(
                        pkg: e.value,
                        formatDate: _formatDate,
                      ),
                    ),
                  );
                }),
            ],
          );
        },
      ),
    );
  }
}

// ── Active package card ───────────────────────────────────────────────────────

class _ActivePackageCard extends StatelessWidget {
  const _ActivePackageCard({
    required this.pkg,
    required this.formatDate,
  });

  final ClientPackage pkg;
  final String Function(String) formatDate;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final isCredits = pkg.kind == PackageKind.credits;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: kInkElevated,
        border: Border.all(color: kVolt, width: 1.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Package name (big)
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Text(
                  pkg.packageTypeName,
                  style: GoogleFonts.archivoBlack(
                    color: kOffWhite,
                    fontSize: 22,
                    height: 1.0,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              VoltBadge(l10n.statusActive),
            ],
          ),
          const SizedBox(height: 16),

          // For credits kind: big remaining count + expiry
          if (isCredits) ...[
            Text(
              l10n.remainingCredits.toUpperCase(),
              style: GoogleFonts.interTight(
                color: kMutedDark,
                fontSize: 11,
                fontWeight: FontWeight.w700,
                letterSpacing: 1.6,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              '${pkg.remainingCredits ?? 0}',
              style: GoogleFonts.archivoBlack(
                color: kVolt,
                fontSize: 52,
                height: 0.95,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              '${l10n.packageExpiry}: ${formatDate(pkg.expiryDate)}',
              style: theme.textTheme.bodyMedium,
            ),
          ] else ...[
            // For duration kind: "Unlimited until {date}"
            Text(
              l10n.unlimitedUntil(formatDate(pkg.expiryDate)),
              style: GoogleFonts.interTight(
                color: kOffWhite,
                fontSize: 16,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

// ── No active package card ────────────────────────────────────────────────────

class _NoPackageCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: kInkElevated,
        border: Border.all(color: kLineDark),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.noActivePackage,
            style: GoogleFonts.archivoBlack(
              color: kOffWhite,
              fontSize: 18,
              height: 1.1,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            l10n.getPackagePrompt,
            style: theme.textTheme.bodyMedium,
          ),
        ],
      ),
    );
  }
}

// ── History row ───────────────────────────────────────────────────────────────

class _HistoryRow extends StatelessWidget {
  const _HistoryRow({required this.pkg, required this.formatDate});

  final ClientPackage pkg;
  final String Function(String) formatDate;

  String _statusLabel(AppLocalizations l10n) {
    if (pkg.kind == PackageKind.credits &&
        (pkg.remainingCredits ?? 0) == 0 &&
        pkg.isActive()) {
      // depleted but not yet expired (edge case — treat as depleted)
      return l10n.statusDepleted;
    }
    if (pkg.kind == PackageKind.credits && (pkg.remainingCredits ?? 0) == 0) {
      // Check if it's depleted (credits gone) vs expired (date passed)
      final now = DateTime.now();
      final expiry = DateTime.parse(pkg.expiryDate);
      final expired = now.isAfter(
        DateTime(expiry.year, expiry.month, expiry.day, 23, 59, 59),
      );
      return expired ? l10n.statusExpired : l10n.statusDepleted;
    }
    return l10n.statusExpired;
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final statusLabel = _statusLabel(l10n);

    return Container(
      padding: const EdgeInsets.fromLTRB(14, 10, 12, 10),
      decoration: BoxDecoration(
        color: kInkElevated,
        border: Border.all(color: kLineDark),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(pkg.packageTypeName, style: theme.textTheme.titleMedium),
                const SizedBox(height: 2),
                Text(
                  '${formatDate(pkg.startDate)} – ${formatDate(pkg.expiryDate)}',
                  style: theme.textTheme.bodyMedium,
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          _MutedBadge(statusLabel),
        ],
      ),
    );
  }
}

/// Muted (outline) status badge for history rows.
class _MutedBadge extends StatelessWidget {
  const _MutedBadge(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Transform(
      transform: Matrix4.skewX(-0.2),
      alignment: Alignment.center,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          border: Border.all(color: kMutedDark, width: 1.0),
        ),
        child: Transform(
          transform: Matrix4.skewX(0.2),
          alignment: Alignment.center,
          child: Text(
            text.toUpperCase(),
            style: GoogleFonts.interTight(
              color: kMutedDark,
              fontWeight: FontWeight.w800,
              fontSize: 10,
              letterSpacing: 1,
            ),
          ),
        ),
      ),
    );
  }
}
