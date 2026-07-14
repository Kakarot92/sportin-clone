import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sportin_clone/app/kinetic.dart';
import 'package:sportin_clone/app/kinetic_effects.dart';
import 'package:sportin_clone/app/theme.dart';
import 'package:sportin_clone/features/auth/application/auth_providers.dart';
import 'package:sportin_clone/features/booking/application/booking_providers.dart';
import 'package:sportin_clone/features/booking/domain/booking_exceptions.dart';
import 'package:sportin_clone/features/scheduling/application/scheduling_providers.dart';
import 'package:sportin_clone/features/scheduling/domain/booking.dart';
import 'package:sportin_clone/features/scheduling/domain/slot.dart';
import 'package:sportin_clone/features/trainers/application/trainers_providers.dart';
import 'package:sportin_clone/l10n/app_localizations.dart';

/// Client-facing screen that shows available slots for a given trainer.
///
/// Route: /schedule/trainer/:uid/slots
/// Kinetik design: horizontal date rail + volt slot blocks (no table_calendar).
///
/// When [rescheduling] is non-null the screen operates in "reschedule mode":
/// the header changes to signal the context and tapping a slot triggers a
/// reschedule-confirm dialog instead of the normal booking dialog (AS-039).
class TrainerSlotsScreen extends ConsumerStatefulWidget {
  const TrainerSlotsScreen({
    super.key,
    required this.trainerUid,
    this.rescheduling,
  });

  final String trainerUid;

  /// When set, the screen is in reschedule mode: the user is moving this
  /// existing booking to a new slot instead of creating a fresh booking.
  final Booking? rescheduling;

  @override
  ConsumerState<TrainerSlotsScreen> createState() => _TrainerSlotsScreenState();
}

class _TrainerSlotsScreenState extends ConsumerState<TrainerSlotsScreen> {
  late DateTime _selectedDay;
  late List<DateTime> _days;

  bool get _isRescheduling => widget.rescheduling != null;

  @override
  void initState() {
    super.initState();
    final today = _normalise(DateTime.now());
    _selectedDay = today;
    // Build 28 days starting from today.
    _days = List.generate(28, (i) => today.add(Duration(days: i)));
  }

  /// Normalises a DateTime to midnight (date-only comparison).
  DateTime _normalise(DateTime d) => DateTime(d.year, d.month, d.day);

  /// Short weekday label (Mon, Tue …) for a 1-indexed weekday.
  String _weekdayLabel(AppLocalizations l10n, DateTime d) {
    switch (d.weekday) {
      case 1:
        return l10n.weekdayMon;
      case 2:
        return l10n.weekdayTue;
      case 3:
        return l10n.weekdayWed;
      case 4:
        return l10n.weekdayThu;
      case 5:
        return l10n.weekdayFri;
      case 6:
        return l10n.weekdaySat;
      case 7:
        return l10n.weekdaySun;
      default:
        return '';
    }
  }

  // ── Normal booking flow ──────────────────────────────────────────────────────

  Future<void> _bookSlot(Slot slot, String trainerName) async {
    final l10n = AppLocalizations.of(context);
    final me = ref.read(appUserProvider).asData?.value;
    if (me == null) return;

    final messenger = ScaffoldMessenger.of(context);

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l10n.bookConfirmTitle),
        content: Text(l10n.bookConfirmBody(slot.start, trainerName)),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: Text(l10n.cancel),
          ),
          FilledButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: Text(l10n.book),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    final ok = await ref
        .read(bookingControllerProvider.notifier)
        .book(slot: slot, clientUid: me.uid);

    if (!mounted) return;

    if (ok) {
      messenger.showSnackBar(SnackBar(content: Text(l10n.booked)));
    } else {
      final err = ref.read(bookingControllerProvider).error;
      final msg = err is SlotTakenException
          ? l10n.slotTakenError
          : err is PastSlotException
              ? l10n.pastSlotError
              : err is NoActivePackageException
                  ? l10n.noActivePackageError
                  : l10n.errorGeneric;
      messenger.showSnackBar(SnackBar(content: Text(msg)));
    }
  }

  // ── Reschedule flow (AS-039) ─────────────────────────────────────────────────

  Future<void> _rescheduleSlot(Slot slot, String trainerName) async {
    final l10n = AppLocalizations.of(context);
    final messenger = ScaffoldMessenger.of(context);

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l10n.rescheduleConfirmTitle),
        content: Text(l10n.rescheduleConfirmBody(slot.start, trainerName)),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: Text(l10n.cancel),
          ),
          FilledButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: Text(l10n.reschedule),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    final ok = await ref
        .read(bookingControllerProvider.notifier)
        .reschedule(oldBooking: widget.rescheduling!, newSlot: slot);

    if (!mounted) return;

    if (ok) {
      messenger.showSnackBar(SnackBar(content: Text(l10n.rescheduled)));
      if (Navigator.canPop(context)) Navigator.of(context).pop();
    } else {
      final err = ref.read(bookingControllerProvider).error;
      final msg = err is SlotTakenException
          ? l10n.slotTakenError
          : err is PastSlotException
              ? l10n.pastSlotError
              : err is CutoffPassedException
                  ? l10n.cutoffPassedError
                  : err is NoActivePackageException
                      ? l10n.noActivePackageError
                      : l10n.errorGeneric;
      messenger.showSnackBar(SnackBar(content: Text(msg)));
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final today = _normalise(DateTime.now());

    // Trainer name for header + confirm dialog.
    final trainerName = ref
            .watch(trainerProvider(widget.trainerUid))
            .asData
            ?.value
            ?.displayName ??
        '';

    // Slots for the selected day.
    final slotsValue = ref.watch(availableSlotsProvider(
        (trainerUid: widget.trainerUid, day: _selectedDay)));

    return Scaffold(
      appBar: AppBar(),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Header with SpeedLines backdrop ──
          Stack(
            children: [
              Positioned.fill(
                child: Opacity(
                  opacity: 0.18,
                  child: SpeedLines(density: 18, seed: 42),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 4, 24, 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Eyebrow changes to "RESCHEDULE" in reschedule mode (AS-039).
                    Eyebrow(_isRescheduling ? l10n.reschedule : l10n.navSchedule),
                    const SizedBox(height: 8),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Flexible(
                          child: DisplayTitle(
                              trainerName.isEmpty ? '—' : trainerName),
                        ),
                        if (_isRescheduling) ...[
                          const SizedBox(width: 12),
                          VoltBadge(l10n.reschedule, filled: false),
                        ],
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),

          // ── Horizontal date rail ──
          SizedBox(
            height: 80,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: _days.length,
              itemBuilder: (context, i) {
                final day = _days[i];
                final isSelected = day == _selectedDay;
                final isToday = day == today;
                return _DayCell(
                  day: day,
                  label: _weekdayLabel(l10n, day),
                  isSelected: isSelected,
                  isToday: isToday,
                  onTap: () {
                    if (_selectedDay != day) {
                      setState(() => _selectedDay = day);
                    }
                  },
                );
              },
            ),
          ),

          const SizedBox(height: 20),

          // ── Slots section ──
          Expanded(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(24, 0, 24, 32),
              children: [
                SectionHeader(l10n.availableSlots),
                const SizedBox(height: 16),
                _buildSlotContent(context, l10n, slotsValue, trainerName),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSlotContent(
    BuildContext context,
    AppLocalizations l10n,
    AsyncValue<List<Slot>> slotsValue,
    String trainerName,
  ) {
    return slotsValue.when(
      loading: () => const Center(
        child: Padding(
          padding: EdgeInsets.all(32),
          child: CircularProgressIndicator(),
        ),
      ),
      error: (_, _) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 24),
        child: Text(l10n.errorGeneric,
            style: Theme.of(context).textTheme.bodyMedium),
      ),
      data: (slots) {
        if (slots.isEmpty) {
          return SizedBox(
            height: 140,
            child: Stack(
              alignment: Alignment.center,
              children: [
                Positioned(
                  child: Opacity(
                    opacity: 0.08,
                    child: GhostText('0', size: 120, color: kVolt),
                  ),
                ),
                Text(
                  l10n.noSlotsForDay,
                  style: Theme.of(context).textTheme.bodyMedium,
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          );
        }
        return Wrap(
          spacing: 10,
          runSpacing: 10,
          children: slots.asMap().entries.map((entry) {
            final i = entry.key;
            final slot = entry.value;
            return Reveal(
              index: i,
              child: _SlotBlock(
                slot: slot,
                onTap: () => _isRescheduling
                    ? _rescheduleSlot(slot, trainerName)
                    : _bookSlot(slot, trainerName),
              ),
            );
          }).toList(),
        );
      },
    );
  }
}

// ── Day cell ──────────────────────────────────────────────────────────────────

class _DayCell extends StatelessWidget {
  const _DayCell({
    required this.day,
    required this.label,
    required this.isSelected,
    required this.isToday,
    required this.onTap,
  });

  final DateTime day;
  final String label;
  final bool isSelected;
  final bool isToday;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final bg = isSelected ? kVolt : kInkElevated;
    final textColor = isSelected ? kInk : kOffWhite;
    final mutedColor = isSelected ? kInk.withValues(alpha: 0.7) : kMutedDark;

    Border? border;
    if (isSelected) {
      border = null; // no separate border when filled volt
    } else if (isToday) {
      border = Border.all(color: kVolt, width: 1.5);
    } else {
      border = Border.all(color: kLineDark, width: 1);
    }

    return GestureDetector(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
        child: Transform(
          transform: isSelected ? Matrix4.skewX(-0.06) : Matrix4.identity(),
          alignment: Alignment.center,
          child: Container(
            width: 56,
            height: 64,
            decoration: BoxDecoration(
              color: bg,
              border: border,
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  label.toUpperCase(),
                  style: GoogleFonts.interTight(
                    color: mutedColor,
                    fontSize: 10,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 1.2,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${day.day}',
                  style: GoogleFonts.archivoBlack(
                    color: textColor,
                    fontSize: 26,
                    height: 1.0,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ── Slot block ────────────────────────────────────────────────────────────────

class _SlotBlock extends StatelessWidget {
  const _SlotBlock({required this.slot, required this.onTap});

  final Slot slot;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        constraints: const BoxConstraints(minWidth: 80, minHeight: 56),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: kInkElevated,
          border: Border.all(color: kVolt, width: 1.5),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              slot.start,
              style: GoogleFonts.archivoBlack(
                color: kVolt,
                fontSize: 18,
                height: 1.1,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              '–${slot.end}',
              style: GoogleFonts.interTight(
                color: kMutedDark,
                fontSize: 11,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
