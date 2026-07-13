import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:sportin_clone/app/kinetic.dart';
import 'package:sportin_clone/app/theme.dart';
import 'package:sportin_clone/features/auth/application/auth_providers.dart';
import 'package:sportin_clone/features/scheduling/application/scheduling_providers.dart';
import 'package:sportin_clone/features/scheduling/domain/availability_exception.dart';
import 'package:sportin_clone/features/scheduling/domain/time_range.dart';
import 'package:sportin_clone/features/scheduling/domain/weekly_availability.dart';
import 'package:sportin_clone/l10n/app_localizations.dart';

/// Screen for trainers to edit their weekly availability template and exceptions.
///
/// Route: /profile/availability
/// Guard: trainer-only
class AvailabilityEditorScreen extends ConsumerStatefulWidget {
  const AvailabilityEditorScreen({super.key});

  @override
  ConsumerState<AvailabilityEditorScreen> createState() =>
      _AvailabilityEditorScreenState();
}

class _AvailabilityEditorScreenState
    extends ConsumerState<AvailabilityEditorScreen> {
  // Local state for the template being edited.
  WeeklyAvailability? _localTemplate;
  bool _loaded = false;
  bool _saving = false;

  // Sorted weekday numbers 1..7 with l10n labels.
  static const _weekdays = [1, 2, 3, 4, 5, 6, 7];

  /// Returns the l10n weekday label for a 1-indexed weekday.
  String _weekdayLabel(AppLocalizations l10n, int day) {
    switch (day) {
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
        return '$day';
    }
  }

  /// Formats a TimeOfDay as zero-padded "HH:mm".
  String _formatTime(TimeOfDay t) {
    final h = t.hour.toString().padLeft(2, '0');
    final m = t.minute.toString().padLeft(2, '0');
    return '$h:$m';
  }

  /// Opens time pickers to add a new TimeRange to the given weekday.
  Future<void> _addTimeRange(AppLocalizations l10n, int weekday) async {
    final start = await showTimePicker(
      context: context,
      initialTime: const TimeOfDay(hour: 9, minute: 0),
      helpText: l10n.from.toUpperCase(),
    );
    if (start == null || !mounted) return;

    final end = await showTimePicker(
      context: context,
      initialTime: TimeOfDay(hour: start.hour + 1, minute: start.minute),
      helpText: l10n.to.toUpperCase(),
    );
    if (end == null || !mounted) return;

    final startStr = _formatTime(start);
    final endStr = _formatTime(end);
    setState(() {
      final current = Map<int, List<TimeRange>>.from(
          _localTemplate!.weekly.map((k, v) => MapEntry(k, List<TimeRange>.from(v))));
      current[weekday] = [
        ...(current[weekday] ?? []),
        TimeRange(start: startStr, end: endStr),
      ];
      _localTemplate = _localTemplate!.copyWith(weekly: current);
    });
  }

  /// Removes a TimeRange from the given weekday by index.
  void _removeTimeRange(int weekday, int index) {
    setState(() {
      final current = Map<int, List<TimeRange>>.from(
          _localTemplate!.weekly.map((k, v) => MapEntry(k, List<TimeRange>.from(v))));
      final list = List<TimeRange>.from(current[weekday] ?? []);
      list.removeAt(index);
      if (list.isEmpty) {
        current.remove(weekday);
      } else {
        current[weekday] = list;
      }
      _localTemplate = _localTemplate!.copyWith(weekly: current);
    });
  }

  /// Saves the weekly template to Firestore.
  Future<void> _saveTemplate(String uid) async {
    final l10n = AppLocalizations.of(context);
    final messenger = ScaffoldMessenger.of(context);
    setState(() => _saving = true);
    try {
      await ref
          .read(availabilityRepositoryProvider)
          .saveTemplate(_localTemplate!);
      if (!mounted) return;
      messenger.showSnackBar(SnackBar(content: Text(l10n.profileSaved)));
    } catch (_) {
      if (!mounted) return;
      messenger.showSnackBar(SnackBar(content: Text(l10n.errorGeneric)));
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  /// Opens date/time pickers to add a new exception.
  Future<void> _addException(AppLocalizations l10n, String uid) async {
    final today = DateTime.now();
    final date = await showDatePicker(
      context: context,
      initialDate: today,
      firstDate: today,
      lastDate: today.add(const Duration(days: 90)),
    );
    if (date == null || !mounted) return;

    bool allDay = true;
    String? startStr;
    String? endStr;

    // Show a dialog to configure exception details.
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => _ExceptionDialog(
        date: date,
        onConfirm: (a, s, e) {
          allDay = a;
          startStr = s;
          endStr = e;
        },
      ),
    );
    if (confirmed != true || !mounted) return;

    final messenger = ScaffoldMessenger.of(context);
    try {
      await ref.read(availabilityRepositoryProvider).addException(
            AvailabilityException(
              id: '',
              trainerUid: uid,
              date: date,
              allDay: allDay,
              start: allDay ? null : startStr,
              end: allDay ? null : endStr,
            ),
          );
    } catch (_) {
      if (!mounted) return;
      messenger.showSnackBar(SnackBar(content: Text(l10n.errorGeneric)));
    }
  }

  /// Removes an exception by its Firestore id.
  Future<void> _removeException(String id) async {
    try {
      await ref.read(availabilityRepositoryProvider).removeException(id);
    } catch (_) {
      if (!mounted) return;
      final l10n = AppLocalizations.of(context);
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(l10n.errorGeneric)));
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final user = ref.watch(appUserProvider).asData?.value;

    // Guard: trainer-only.
    if (user == null || !user.isTrainer) {
      return Scaffold(
        appBar: AppBar(),
        body: Center(child: Text(l10n.notAuthorized)),
      );
    }

    final uid = user.uid;

    // Load initial template into local state.
    final templateAsync = ref.watch(weeklyTemplateProvider(uid));
    if (!_loaded && templateAsync.asData != null) {
      _localTemplate =
          templateAsync.asData!.value ?? WeeklyAvailability.empty(uid);
      _loaded = true;
    }
    // Show loading until we have the template once.
    if (_localTemplate == null) {
      return Scaffold(
        appBar: AppBar(),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    final exceptionsAsync = ref.watch(trainerExceptionsProvider(uid));
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(24, 0, 24, 32),
        children: [
          const Eyebrow('Trener'),
          const SizedBox(height: 10),
          DisplayTitle(l10n.weeklyAvailability),
          const SizedBox(height: 24),

          // ── Slot duration selector — skewed volt chips ──
          Text(
            l10n.slotDuration.toUpperCase(),
            style: GoogleFonts.interTight(
              color: kMutedDark,
              fontSize: 11,
              fontWeight: FontWeight.w700,
              letterSpacing: 1.6,
            ),
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [30, 45, 60, 90].map((m) {
              final selected = _localTemplate!.slotMinutes == m;
              return GestureDetector(
                onTap: () {
                  setState(() {
                    _localTemplate =
                        _localTemplate!.copyWith(slotMinutes: m);
                  });
                },
                child: Transform(
                  transform: Matrix4.skewX(-0.10),
                  alignment: Alignment.center,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 10),
                    decoration: BoxDecoration(
                      color: selected ? kVolt : Colors.transparent,
                      border: Border.all(
                        color: selected ? kVolt : kLineDark,
                        width: selected ? 0 : 1.5,
                      ),
                    ),
                    child: Transform(
                      transform: Matrix4.skewX(0.10),
                      alignment: Alignment.center,
                      child: Text(
                        '$m ${l10n.minutesShort}'.toUpperCase(),
                        style: GoogleFonts.interTight(
                          color: selected ? kInk : kOffWhite,
                          fontWeight: FontWeight.w800,
                          fontSize: 12,
                          letterSpacing: 1.2,
                        ),
                      ),
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 28),

          // ── Weekly template ──
          ..._weekdays.expand((day) {
            final ranges =
                List<TimeRange>.from(_localTemplate!.weekly[day] ?? []);
            return [
              // Kinetik section marker: skewed volt bar + uppercase day name.
              _WeekdayHeader(label: _weekdayLabel(l10n, day)),
              const SizedBox(height: 8),
              if (ranges.isEmpty)
                Padding(
                  padding: const EdgeInsets.only(bottom: 4),
                  child: Text(
                    '—',
                    style: theme.textTheme.bodyMedium,
                  ),
                ),
              ...ranges.asMap().entries.map((entry) {
                final i = entry.key;
                final r = entry.value;
                return _TimeRangeRow(
                  range: r,
                  onDelete: () => _removeTimeRange(day, i),
                );
              }),
              // "+ Dodaj interval" affordance
              TextButton.icon(
                onPressed: () => _addTimeRange(l10n, day),
                icon: const Icon(Icons.add, size: 18, color: kVolt),
                label: Text(
                  l10n.addTimeRange,
                  style: GoogleFonts.interTight(
                    color: kVolt,
                    fontWeight: FontWeight.w700,
                    fontSize: 13,
                  ),
                ),
              ),
              const SizedBox(height: 8),
            ];
          }),

          const SizedBox(height: 16),
          VoltButton(
            label: l10n.save,
            icon: Icons.check,
            loading: _saving,
            onPressed: () => _saveTemplate(uid),
          ),

          const SizedBox(height: 32),

          // ── Exceptions section ──
          SectionHeader(l10n.exceptions),
          const SizedBox(height: 12),
          exceptionsAsync.when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (_, _) => Text(l10n.errorGeneric),
            data: (exceptions) {
              if (exceptions.isEmpty) {
                return Text(l10n.noExceptions,
                    style: theme.textTheme.bodyMedium);
              }
              return Column(
                children: exceptions
                    .map((ex) => _ExceptionRow(
                          exception: ex,
                          onDelete: () => _removeException(ex.id),
                        ))
                    .toList(),
              );
            },
          ),
          const SizedBox(height: 8),
          TextButton.icon(
            onPressed: () => _addException(l10n, uid),
            icon: const Icon(Icons.add, size: 18, color: kVolt),
            label: Text(
              l10n.addException,
              style: GoogleFonts.interTight(
                color: kVolt,
                fontWeight: FontWeight.w700,
                fontSize: 13,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Helper widgets ─────────────────────────────────────────────────────────

/// Kinetik weekday section header: skewed volt marker + uppercase day name.
class _WeekdayHeader extends StatelessWidget {
  const _WeekdayHeader({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Transform(
          transform: Matrix4.skewX(-0.35),
          alignment: Alignment.center,
          child: Container(width: 10, height: 20, color: kVolt),
        ),
        const SizedBox(width: 10),
        Text(
          label.toUpperCase(),
          style: GoogleFonts.interTight(
            color: kOffWhite,
            fontWeight: FontWeight.w800,
            fontSize: 13,
            letterSpacing: 1.6,
          ),
        ),
      ],
    );
  }
}

class _TimeRangeRow extends StatelessWidget {
  const _TimeRangeRow({required this.range, required this.onDelete});

  final TimeRange range;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 4),
      padding: const EdgeInsets.fromLTRB(14, 10, 4, 10),
      decoration: BoxDecoration(
        color: kInkElevated,
        border: Border.all(color: kLineDark, width: 1),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              '${range.start} – ${range.end}',
              style: GoogleFonts.archivoBlack(
                color: kOffWhite,
                fontSize: 15,
              ),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.delete_outline, color: kDanger, size: 20),
            onPressed: onDelete,
            tooltip: 'Ukloni',
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(minWidth: 40, minHeight: 40),
          ),
        ],
      ),
    );
  }
}

class _ExceptionRow extends StatelessWidget {
  const _ExceptionRow({required this.exception, required this.onDelete});

  final AvailabilityException exception;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final dateLabel = DateFormat.yMMMEd('sr').format(exception.date);
    final timeLabel = exception.allDay
        ? l10n.blockWholeDay
        : '${exception.start ?? ''} – ${exception.end ?? ''}';

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 4),
      padding: const EdgeInsets.fromLTRB(14, 10, 4, 10),
      decoration: BoxDecoration(
        color: kInkElevated,
        border: Border.all(color: kLineDark, width: 1),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(dateLabel, style: theme.textTheme.bodyLarge),
                const SizedBox(height: 2),
                Text(timeLabel, style: theme.textTheme.bodyMedium),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.delete_outline, color: kDanger, size: 20),
            onPressed: onDelete,
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(minWidth: 40, minHeight: 40),
          ),
        ],
      ),
    );
  }
}

/// Dialog to configure a new exception (all-day vs time range).
class _ExceptionDialog extends StatefulWidget {
  const _ExceptionDialog({required this.date, required this.onConfirm});

  final DateTime date;
  final void Function(bool allDay, String? start, String? end) onConfirm;

  @override
  State<_ExceptionDialog> createState() => _ExceptionDialogState();
}

class _ExceptionDialogState extends State<_ExceptionDialog> {
  bool _allDay = true;
  String? _start;
  String? _end;

  String _fmt(TimeOfDay t) {
    return '${t.hour.toString().padLeft(2, '0')}:${t.minute.toString().padLeft(2, '0')}';
  }

  Future<void> _pickStart() async {
    final t = await showTimePicker(
      context: context,
      initialTime: const TimeOfDay(hour: 9, minute: 0),
    );
    if (t != null) setState(() => _start = _fmt(t));
  }

  Future<void> _pickEnd() async {
    final t = await showTimePicker(
      context: context,
      initialTime: const TimeOfDay(hour: 10, minute: 0),
    );
    if (t != null) setState(() => _end = _fmt(t));
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final dateLabel = DateFormat.yMMMEd('sr').format(widget.date);

    return AlertDialog(
      title: Text(l10n.addException),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(dateLabel),
          const SizedBox(height: 12),
          Row(
            children: [
              Text(l10n.blockWholeDay),
              const Spacer(),
              Switch(
                value: _allDay,
                onChanged: (v) => setState(() => _allDay = v),
              ),
            ],
          ),
          if (!_allDay) ...[
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: _pickStart,
                    child: Text(_start ?? l10n.from),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: OutlinedButton(
                    onPressed: _pickEnd,
                    child: Text(_end ?? l10n.to),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(false),
          child: Text(l10n.cancel),
        ),
        FilledButton(
          onPressed: () {
            widget.onConfirm(_allDay, _start, _end);
            Navigator.of(context).pop(true);
          },
          child: Text(l10n.save),
        ),
      ],
    );
  }
}
