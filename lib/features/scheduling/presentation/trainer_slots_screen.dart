import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sportin_clone/app/kinetic.dart';
import 'package:sportin_clone/app/theme.dart';
import 'package:sportin_clone/features/auth/application/auth_providers.dart';
import 'package:sportin_clone/features/booking/application/booking_providers.dart';
import 'package:sportin_clone/features/booking/domain/booking_exceptions.dart';
import 'package:sportin_clone/features/scheduling/application/scheduling_providers.dart';
import 'package:sportin_clone/features/scheduling/domain/slot.dart';
import 'package:sportin_clone/features/trainers/application/trainers_providers.dart';
import 'package:sportin_clone/l10n/app_localizations.dart';
import 'package:table_calendar/table_calendar.dart';

/// Client-facing screen that shows available slots for a given trainer.
///
/// Route: /schedule/trainer/:uid/slots
class TrainerSlotsScreen extends ConsumerStatefulWidget {
  const TrainerSlotsScreen({super.key, required this.trainerUid});

  final String trainerUid;

  @override
  ConsumerState<TrainerSlotsScreen> createState() => _TrainerSlotsScreenState();
}

class _TrainerSlotsScreenState extends ConsumerState<TrainerSlotsScreen> {
  late DateTime _focusedDay;
  DateTime? _selectedDay;

  @override
  void initState() {
    super.initState();
    _focusedDay = DateTime.now();
  }

  /// Normalises a DateTime to midnight (date-only comparison).
  DateTime _normalise(DateTime d) => DateTime(d.year, d.month, d.day);

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
              : l10n.errorGeneric;
      messenger.showSnackBar(SnackBar(content: Text(msg)));
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final today = _normalise(DateTime.now());
    final lastDay = today.add(const Duration(days: 60));

    // Trainer name for confirm dialog.
    final trainerName = ref
            .watch(trainerProvider(widget.trainerUid))
            .asData
            ?.value
            ?.displayName ??
        '';

    // Slots for the selected day (or null when no day selected).
    final normalised = _selectedDay != null ? _normalise(_selectedDay!) : null;
    final AsyncValue<List<Slot>>? slotsValue = normalised != null
        ? ref.watch(availableSlotsProvider(
            (trainerUid: widget.trainerUid, day: normalised)))
        : null;

    return Scaffold(
      appBar: AppBar(),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(0, 0, 0, 32),
        children: [
          // ── Calendar ──
          TableCalendar(
            firstDay: today,
            lastDay: lastDay,
            focusedDay: _focusedDay,
            selectedDayPredicate: (d) =>
                _selectedDay != null && isSameDay(d, _selectedDay!),
            onDaySelected: (selected, focused) {
              setState(() {
                _selectedDay = _normalise(selected);
                _focusedDay = focused;
              });
            },
            calendarFormat: CalendarFormat.month,
            startingDayOfWeek: StartingDayOfWeek.monday,
            headerStyle: HeaderStyle(
              formatButtonVisible: false,
              titleCentered: true,
              titleTextStyle: TextStyle(
                color: Theme.of(context).colorScheme.onSurface,
                fontWeight: FontWeight.w700,
                fontSize: 16,
              ),
              leftChevronIcon: Icon(
                Icons.chevron_left,
                color: Theme.of(context).colorScheme.onSurface,
              ),
              rightChevronIcon: Icon(
                Icons.chevron_right,
                color: Theme.of(context).colorScheme.onSurface,
              ),
            ),
            calendarStyle: CalendarStyle(
              outsideDaysVisible: false,
              defaultTextStyle: TextStyle(
                color: Theme.of(context).colorScheme.onSurface,
              ),
              weekendTextStyle: const TextStyle(color: kMutedDark),
              selectedDecoration: const BoxDecoration(
                color: kVolt,
                shape: BoxShape.circle,
              ),
              selectedTextStyle: const TextStyle(
                color: kInk,
                fontWeight: FontWeight.w800,
              ),
              todayDecoration: BoxDecoration(
                border: Border.all(color: kVolt, width: 2),
                shape: BoxShape.circle,
              ),
              todayTextStyle: const TextStyle(
                color: kVolt,
                fontWeight: FontWeight.w700,
              ),
            ),
            daysOfWeekStyle: DaysOfWeekStyle(
              weekdayStyle: TextStyle(
                color: Theme.of(context).colorScheme.onSurface,
                fontWeight: FontWeight.w600,
                fontSize: 12,
              ),
              weekendStyle: const TextStyle(
                color: kMutedDark,
                fontWeight: FontWeight.w600,
                fontSize: 12,
              ),
            ),
          ),

          const SizedBox(height: 16),

          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SectionHeader(l10n.availableSlots),
                const SizedBox(height: 12),
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
    AsyncValue<List<Slot>>? slotsValue,
    String trainerName,
  ) {
    if (slotsValue == null) {
      return Center(
        child: Text(l10n.selectDay,
            style: Theme.of(context).textTheme.bodyMedium),
      );
    }
    return slotsValue.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (_, _) => Text(l10n.errorGeneric),
      data: (slots) {
        if (slots.isEmpty) {
          return Center(
            child: Text(l10n.noSlotsForDay,
                style: Theme.of(context).textTheme.bodyMedium),
          );
        }
        return Wrap(
          spacing: 8,
          runSpacing: 8,
          children: slots.map((slot) {
            final startLabel = slot.start;
            return OutlinedButton(
              onPressed: () => _bookSlot(slot, trainerName),
              style: OutlinedButton.styleFrom(
                minimumSize: const Size(80, 44),
                side: const BorderSide(color: kVolt, width: 1.5),
                foregroundColor: kVolt,
              ),
              child: Text(
                startLabel,
                style: const TextStyle(
                  fontWeight: FontWeight.w700,
                  color: kVolt,
                ),
              ),
            );
          }).toList(),
        );
      },
    );
  }
}
