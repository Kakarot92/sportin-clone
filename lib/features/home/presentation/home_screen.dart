import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:sportin_clone/app/kinetic.dart';
import 'package:sportin_clone/app/theme.dart';
import 'package:sportin_clone/features/auth/application/auth_providers.dart';
import 'package:sportin_clone/features/booking/application/booking_providers.dart';
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
        child: ListView(
          padding: const EdgeInsets.fromLTRB(24, 24, 24, 32),
          children: [
            Eyebrow(l10n.homeWelcome),
            const SizedBox(height: 10),
            DisplayTitle(firstName.isEmpty ? 'Zdravo.' : 'Zdravo,\n$firstName.'),
            const SizedBox(height: 28),
            _NextTrainingCard(),
            const SizedBox(height: 32),
            SectionHeader(l10n.homeShortcuts),
            const SizedBox(height: 16),
            _ShortcutTile(
              icon: Icons.calendar_month,
              label: l10n.navSchedule,
              onTap: () => context.go('/schedule'),
            ),
            const SizedBox(height: 12),
            _ShortcutTile(
              icon: Icons.monitor_weight,
              label: l10n.navMeasurements,
              onTap: () => context.go('/measurements'),
            ),
            const SizedBox(height: 12),
            _ShortcutTile(
              icon: Icons.chat_bubble,
              label: l10n.navChat,
              onTap: () => context.go('/chat'),
            ),
          ],
        ),
      ),
    );
  }
}

class _NextTrainingCard extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final me = ref.watch(appUserProvider).asData?.value;

    // Watch upcoming bookings when user is available.
    final upcomingAsync = me != null
        ? ref.watch(clientUpcomingBookingsProvider(me.uid))
        : null;

    final soonest = upcomingAsync?.asData?.value.isNotEmpty == true
        ? upcomingAsync!.asData!.value.first
        : null;

    // Trainer name for soonest booking.
    final trainerName = soonest != null
        ? ref
            .watch(trainerProvider(soonest.trainerUid))
            .asData
            ?.value
            ?.displayName
        : null;

    String? formattedDate;
    if (soonest != null) {
      try {
        final dt = DateTime.parse(soonest.date);
        formattedDate = DateFormat.yMMMEd('sr').format(dt);
      } catch (_) {
        formattedDate = soonest.date;
      }
    }

    return GestureDetector(
      onTap: soonest != null ? () => context.push('/profile/bookings') : null,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: kInkElevated,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: Theme.of(context).dividerColor),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 10,
                  height: 10,
                  decoration:
                      const BoxDecoration(color: kVolt, shape: BoxShape.circle),
                ),
                const SizedBox(width: 10),
                Eyebrow(l10n.nextTraining),
              ],
            ),
            const SizedBox(height: 16),
            if (soonest != null) ...[
              Text(
                formattedDate ?? soonest.date,
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 4),
              Text(
                '${soonest.start}–${soonest.end}',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              if (trainerName != null && trainerName.isNotEmpty) ...[
                const SizedBox(height: 4),
                Text(
                  trainerName,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ],
            ] else ...[
              Text(l10n.noUpcomingTraining,
                  style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 16),
              VoltButton(
                label: l10n.bookTraining,
                icon: Icons.add,
                onPressed: () => context.go('/schedule'),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _ShortcutTile extends StatelessWidget {
  const _ShortcutTile({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 18),
        decoration: BoxDecoration(
          color: kInkElevated,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: Theme.of(context).dividerColor),
        ),
        child: Row(
          children: [
            Icon(icon, color: kVolt, size: 24),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                label.toUpperCase(),
                style: GoogleFonts.interTight(
                  fontWeight: FontWeight.w800,
                  letterSpacing: 1,
                  fontSize: 15,
                ),
              ),
            ),
            Icon(Icons.chevron_right,
                color: Theme.of(context).colorScheme.onSurface),
          ],
        ),
      ),
    );
  }
}
