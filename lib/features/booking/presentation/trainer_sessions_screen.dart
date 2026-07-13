import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:sportin_clone/app/kinetic.dart';
import 'package:sportin_clone/app/theme.dart';
import 'package:sportin_clone/features/auth/application/auth_providers.dart';
import 'package:sportin_clone/features/booking/application/booking_providers.dart';
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
        data: (sessions) => ListView.separated(
          padding: const EdgeInsets.fromLTRB(24, 24, 24, 32),
          itemCount: sessions.length + 1,
          separatorBuilder: (_, i) => SizedBox(height: i == 0 ? 24 : 10),
          itemBuilder: (context, i) {
            if (i == 0) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Eyebrow('Trener'),
                  const SizedBox(height: 10),
                  DisplayTitle(l10n.mySessions),
                  if (sessions.isEmpty) ...[
                    const SizedBox(height: 24),
                    Center(
                      child: Text(
                        l10n.noSessions,
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ),
                  ],
                ],
              );
            }
            return _SessionCard(session: sessions[i - 1]);
          },
        ),
      ),
    );
  }
}

// ─── Session card ─────────────────────────────────────────────────────────────

class _SessionCard extends StatelessWidget {
  const _SessionCard({required this.session});

  final Booking session;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);

    // Parse date for display.
    final dateStr = session.date; // "YYYY-MM-DD"
    String formattedDate = dateStr;
    try {
      final dt = DateTime.parse(dateStr);
      formattedDate = DateFormat.yMMMEd('sr').format(dt);
    } catch (_) {
      // fall back to raw string
    }

    final isCancelled = session.status == 'cancelled';
    final badgeLabel =
        isCancelled ? l10n.statusCancelled : l10n.statusBooked;

    // Show a shortened client uid (first 8 chars) if no name available.
    final clientShort = session.clientUid.length > 8
        ? session.clientUid.substring(0, 8)
        : session.clientUid;

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
                  '${session.start}–${session.end}',
                  style: theme.textTheme.bodyMedium,
                ),
                const SizedBox(height: 4),
                Text(
                  clientShort,
                  style: theme.textTheme.bodyMedium,
                ),
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
