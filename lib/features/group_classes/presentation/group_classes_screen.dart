import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:sportin_clone/app/kinetic.dart';
import 'package:sportin_clone/app/kinetic_effects.dart';
import 'package:sportin_clone/app/theme.dart';
import 'package:sportin_clone/features/auth/application/auth_providers.dart';
import 'package:sportin_clone/features/booking/domain/booking_exceptions.dart';
import 'package:sportin_clone/features/booking/domain/booking_policy.dart';
import 'package:sportin_clone/features/group_classes/application/group_class_providers.dart';
import 'package:sportin_clone/features/group_classes/domain/group_class.dart';
import 'package:sportin_clone/features/group_classes/domain/group_class_exceptions.dart';
import 'package:sportin_clone/features/trainers/application/trainers_providers.dart';
import 'package:sportin_clone/l10n/app_localizations.dart';

import '../../../core/models/app_user.dart';

/// Client-facing screen listing upcoming group classes with join/leave actions.
///
/// Route: /schedule/group-classes
/// Any signed-in user can view.
class GroupClassesScreen extends ConsumerWidget {
  const GroupClassesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final me = ref.watch(appUserProvider).asData?.value;
    final classesAsync = ref.watch(upcomingGroupClassesProvider);

    return Scaffold(
      appBar: AppBar(),
      body: Stack(
        children: [
          // Faint speed-lines backdrop — mirrors trainer_directory_screen.
          const Positioned.fill(
            child: SpeedLines(density: 14, seed: 5, opacity: 0.18),
          ),
          SafeArea(
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
                            child: Eyebrow(l10n.navSchedule),
                          ),
                          const SizedBox(height: 6),
                          Reveal(
                            index: 1,
                            child: DisplayTitle(l10n.groupClasses, size: 38),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),
                    Expanded(
                      child: classesAsync.when(
                        loading: () =>
                            const Center(child: CircularProgressIndicator()),
                        error: (_, _) =>
                            Center(child: Text(l10n.errorGeneric)),
                        data: (classes) {
                          if (classes.isEmpty) {
                            return Center(
                              child: Text(
                                l10n.noUpcomingClasses,
                                textAlign: TextAlign.center,
                                style:
                                    Theme.of(context).textTheme.bodyMedium,
                              ),
                            );
                          }
                          return ListView.separated(
                            padding:
                                const EdgeInsets.fromLTRB(24, 0, 24, 32),
                            itemCount: classes.length,
                            separatorBuilder: (_, _) =>
                                const SizedBox(height: 10),
                            itemBuilder: (context, i) => Reveal(
                              index: 2 + i,
                              child: _GroupClassCard(
                                groupClass: classes[i],
                                me: me,
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Group class card ─────────────────────────────────────────────────────────

/// Card for a single group class — shows title, date/time, trainer name,
/// spots indicator, and join/leave action buttons.
///
/// Mirrors the ConsumerStatefulWidget pattern from [my_bookings_screen.dart]'s
/// `_BookingCard` for safe mounted/ScaffoldMessenger-before-await handling.
class _GroupClassCard extends ConsumerStatefulWidget {
  const _GroupClassCard({
    required this.groupClass,
    required this.me,
  });

  final GroupClass groupClass;

  /// The current signed-in user. May be null while loading.
  final AppUser? me;

  @override
  ConsumerState<_GroupClassCard> createState() => _GroupClassCardState();
}

class _GroupClassCardState extends ConsumerState<_GroupClassCard> {
  /// Joins the current user to this group class (AS-042, AS-043, AS-046).
  Future<void> _join() async {
    final l10n = AppLocalizations.of(context);
    // Capture messenger before the async gap.
    final messenger = ScaffoldMessenger.of(context);

    final ok = await ref
        .read(groupClassControllerProvider.notifier)
        .join(
          classId: widget.groupClass.id,
          clientUid: widget.me!.uid,
        );

    if (!mounted) return;

    if (ok) {
      messenger.showSnackBar(SnackBar(content: Text(l10n.joinedSuccess)));
    } else {
      final err = ref.read(groupClassControllerProvider).error;
      final msg = err is ClassFullException
          ? l10n.classFullError
          : err is AlreadyJoinedException
              ? l10n.alreadyJoinedError
              : l10n.errorGeneric;
      messenger.showSnackBar(SnackBar(content: Text(msg)));
    }
  }

  /// Shows a confirm dialog then leaves the group class (AS-045).
  Future<void> _leave() async {
    final l10n = AppLocalizations.of(context);
    // Capture messenger before the async gap.
    final messenger = ScaffoldMessenger.of(context);

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l10n.leaveClass),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: Text(l10n.cancel),
          ),
          FilledButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: Text(l10n.leaveClass),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    final ok = await ref
        .read(groupClassControllerProvider.notifier)
        .leave(
          classId: widget.groupClass.id,
          clientUid: widget.me!.uid,
          classStart: bookingSlotStart(
            widget.groupClass.date,
            widget.groupClass.start,
          ),
        );

    if (!mounted) return;

    if (ok) {
      messenger.showSnackBar(SnackBar(content: Text(l10n.leftSuccess)));
    } else {
      final err = ref.read(groupClassControllerProvider).error;
      final msg = err is CutoffPassedException
          ? l10n.cutoffPassedError
          : l10n.errorGeneric;
      messenger.showSnackBar(SnackBar(content: Text(msg)));
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final gc = widget.groupClass;
    final me = widget.me;
    final theme = Theme.of(context);

    // Format date using sr_Latn to avoid the Cyrillic-rendering bug.
    String formattedDate = gc.date;
    try {
      final dt = DateTime.parse(gc.date);
      formattedDate = DateFormat.yMMMEd('sr_Latn').format(dt);
    } catch (_) {
      // fall back to raw string
    }

    // Trainer display name (may be loading/null).
    final trainerName = ref
        .watch(trainerProvider(gc.trainerUid))
        .asData
        ?.value
        ?.displayName;

    // Whether the current client has joined this class (AS-046, AS-045).
    final isJoined = me != null
        ? (ref
                .watch(
                  isJoinedProvider((classId: gc.id, clientUid: me.uid)),
                )
                .asData
                ?.value ??
            false)
        : false;

    return Container(
      padding: const EdgeInsets.fromLTRB(16, 14, 12, 14),
      decoration: BoxDecoration(
        color: kInkElevated,
        border: Border.all(color: kLineDark),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Title, date/time, trainer, spots ──
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Title in Archivo Black
                    Text(
                      gc.title,
                      style: GoogleFonts.archivoBlack(
                        color: kOffWhite,
                        fontSize: 18,
                        height: 1.1,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '$formattedDate · ${gc.start}–${gc.end}',
                      style: theme.textTheme.bodyMedium,
                    ),
                    if (trainerName != null && trainerName.isNotEmpty) ...[
                      const SizedBox(height: 2),
                      Text(
                        trainerName,
                        style: theme.textTheme.bodyMedium,
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(width: 8),
              // Spots indicator — badge if full (AS-043), text otherwise (AS-044).
              if (gc.isFull)
                VoltBadge(l10n.classFull, filled: false)
              else
                Padding(
                  padding: const EdgeInsets.only(top: 2),
                  child: Text(
                    l10n.spotsLeft(gc.remainingSpots),
                    style: GoogleFonts.interTight(
                      color: kVolt,
                      fontWeight: FontWeight.w700,
                      fontSize: 12,
                      letterSpacing: 0.8,
                    ),
                  ),
                ),
            ],
          ),

          // ── Action buttons (AS-042, AS-045, AS-046) ──
          if (me != null) ...[
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                if (isJoined)
                  // Leave button — danger-tinted outline (mirrors _ActionButton
                  // cancel style from my_bookings_screen.dart).
                  _ActionButton(
                    label: l10n.leaveClass,
                    color: kDanger,
                    onPressed: _leave,
                  )
                else if (!gc.isFull)
                  // Join button — volt-tinted outline.
                  _ActionButton(
                    label: l10n.joinClass,
                    color: kVolt,
                    onPressed: _join,
                  ),
                // If full and not joined: no action button — VoltBadge above suffices.
              ],
            ),
          ],
        ],
      ),
    );
  }
}

// ─── Small inline action button ───────────────────────────────────────────────

/// Compact sharp-cornered outline button — mirrors [my_bookings_screen.dart]'s
/// `_ActionButton` style exactly.
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
