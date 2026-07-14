import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:sportin_clone/app/kinetic.dart';
import 'package:sportin_clone/app/kinetic_effects.dart';
import 'package:sportin_clone/app/theme.dart';
import 'package:sportin_clone/features/auth/application/auth_providers.dart';
import 'package:sportin_clone/features/group_classes/application/group_class_providers.dart';
import 'package:sportin_clone/features/group_classes/domain/group_class.dart';
import 'package:sportin_clone/features/scheduling/domain/date_utils.dart';
import 'package:sportin_clone/l10n/app_localizations.dart';

/// Trainer's screen to create and view their own group classes.
///
/// Route: /profile/group-classes
/// Guard: trainer-only
class TrainerGroupClassesScreen extends ConsumerStatefulWidget {
  const TrainerGroupClassesScreen({super.key});

  @override
  ConsumerState<TrainerGroupClassesScreen> createState() =>
      _TrainerGroupClassesScreenState();
}

class _TrainerGroupClassesScreenState
    extends ConsumerState<TrainerGroupClassesScreen> {
  // Form state
  final _titleController = TextEditingController();
  final _capacityController = TextEditingController();
  DateTime? _pickedDate;
  TimeOfDay? _startTime;
  TimeOfDay? _endTime;
  bool _submitting = false;

  @override
  void dispose() {
    _titleController.dispose();
    _capacityController.dispose();
    super.dispose();
  }

  /// Formats a [TimeOfDay] as zero-padded "HH:mm" — mirrors
  /// `availability_editor_screen.dart`'s `_formatTime`.
  String _formatTime(TimeOfDay t) {
    final h = t.hour.toString().padLeft(2, '0');
    final m = t.minute.toString().padLeft(2, '0');
    return '$h:$m';
  }

  Future<void> _pickDate() async {
    final today = DateTime.now();
    final date = await showDatePicker(
      context: context,
      initialDate: today,
      firstDate: today,
      lastDate: today.add(const Duration(days: 90)),
    );
    if (date != null && mounted) setState(() => _pickedDate = date);
  }

  Future<void> _pickStartTime() async {
    final t = await showTimePicker(
      context: context,
      initialTime: const TimeOfDay(hour: 9, minute: 0),
    );
    if (t != null && mounted) setState(() => _startTime = t);
  }

  Future<void> _pickEndTime() async {
    final t = await showTimePicker(
      context: context,
      initialTime: const TimeOfDay(hour: 10, minute: 0),
    );
    if (t != null && mounted) setState(() => _endTime = t);
  }

  Future<void> _createClass(String trainerUid) async {
    final l10n = AppLocalizations.of(context);
    final messenger = ScaffoldMessenger.of(context);

    final title = _titleController.text.trim();
    final capacityStr = _capacityController.text.trim();

    // Validate all fields are filled.
    if (title.isEmpty ||
        _pickedDate == null ||
        _startTime == null ||
        _endTime == null ||
        capacityStr.isEmpty) {
      messenger.showSnackBar(SnackBar(content: Text(l10n.errorGeneric)));
      return;
    }
    final capacity = int.tryParse(capacityStr);
    if (capacity == null || capacity <= 0) {
      messenger.showSnackBar(SnackBar(content: Text(l10n.errorGeneric)));
      return;
    }

    setState(() => _submitting = true);

    final gc = GroupClass(
      id: '',
      trainerUid: trainerUid,
      title: title,
      date: ymd(_pickedDate!),
      start: _formatTime(_startTime!),
      end: _formatTime(_endTime!),
      capacity: capacity,
    );

    final ok = await ref
        .read(groupClassControllerProvider.notifier)
        .createClass(gc);

    if (!mounted) return;
    setState(() => _submitting = false);

    if (ok) {
      messenger.showSnackBar(SnackBar(content: Text(l10n.classCreated)));
      // Clear the form on success.
      _titleController.clear();
      _capacityController.clear();
      setState(() {
        _pickedDate = null;
        _startTime = null;
        _endTime = null;
      });
    } else {
      messenger.showSnackBar(SnackBar(content: Text(l10n.errorGeneric)));
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final me = ref.watch(appUserProvider).asData?.value;

    // Guard: trainer-only (mirrors availability_editor_screen.dart).
    if (me == null || !me.isTrainer) {
      return Scaffold(
        appBar: AppBar(),
        body: Center(child: Text(l10n.notAuthorized)),
      );
    }

    final classesAsync = ref.watch(trainerGroupClassesProvider(me.uid));
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(24, 0, 24, 32),
        children: [
          const Eyebrow('Trener'),
          const SizedBox(height: 10),
          DisplayTitle(l10n.myGroupClasses),
          const SizedBox(height: 24),

          // ── Creation form (inline card) ──────────────────────────────────
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: kInkElevated,
              border: Border.all(color: kLineDark),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Class title
                KineticField(
                  label: l10n.classTitle,
                  controller: _titleController,
                  textCapitalization: TextCapitalization.sentences,
                ),
                const SizedBox(height: 16),

                // Date picker
                _PickerLabel(l10n.classDate),
                const SizedBox(height: 8),
                OutlinedButton(
                  onPressed: _pickDate,
                  style: OutlinedButton.styleFrom(
                    foregroundColor: kOffWhite,
                    side: const BorderSide(color: kLineDark),
                    minimumSize: const Size(double.infinity, 48),
                    alignment: Alignment.centerLeft,
                    shape: const RoundedRectangleBorder(),
                    padding: const EdgeInsets.symmetric(horizontal: 14),
                  ),
                  child: Text(
                    _pickedDate != null
                        ? DateFormat.yMMMEd('sr_Latn').format(_pickedDate!)
                        : l10n.classDate,
                    style: GoogleFonts.interTight(
                      color: _pickedDate != null ? kOffWhite : kMutedDark,
                      fontSize: 14,
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // Start + end time pickers
                _PickerLabel(l10n.classTime),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: _pickStartTime,
                        style: OutlinedButton.styleFrom(
                          foregroundColor: kOffWhite,
                          side: const BorderSide(color: kLineDark),
                          minimumSize: const Size(0, 48),
                          shape: const RoundedRectangleBorder(),
                        ),
                        child: Text(
                          _startTime != null
                              ? _formatTime(_startTime!)
                              : 'Start',
                          style: GoogleFonts.interTight(
                            color:
                                _startTime != null ? kOffWhite : kMutedDark,
                            fontSize: 14,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: OutlinedButton(
                        onPressed: _pickEndTime,
                        style: OutlinedButton.styleFrom(
                          foregroundColor: kOffWhite,
                          side: const BorderSide(color: kLineDark),
                          minimumSize: const Size(0, 48),
                          shape: const RoundedRectangleBorder(),
                        ),
                        child: Text(
                          _endTime != null ? _formatTime(_endTime!) : 'End',
                          style: GoogleFonts.interTight(
                            color: _endTime != null ? kOffWhite : kMutedDark,
                            fontSize: 14,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Capacity field — numeric keyboard
                KineticField(
                  label: l10n.classCapacity,
                  controller: _capacityController,
                  keyboardType: TextInputType.number,
                ),
                const SizedBox(height: 20),

                // Submit button
                VoltButton(
                  label: l10n.createGroupClass,
                  loading: _submitting,
                  onPressed: _submitting ? null : () => _createClass(me.uid),
                ),
              ],
            ),
          ),

          const SizedBox(height: 28),

          // ── Trainer's own classes list ────────────────────────────────────
          SectionHeader(l10n.myGroupClasses),
          const SizedBox(height: 12),
          classesAsync.when(
            loading: () =>
                const Center(child: CircularProgressIndicator()),
            error: (_, _) =>
                Text(l10n.errorGeneric, style: theme.textTheme.bodyMedium),
            data: (classes) {
              if (classes.isEmpty) {
                return Text(
                  l10n.noGroupClassesYet,
                  style: theme.textTheme.bodyMedium,
                );
              }
              return Column(
                children: classes
                    .asMap()
                    .entries
                    .map(
                      (entry) => Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: Reveal(
                          index: entry.key,
                          child: _TrainerClassCard(groupClass: entry.value),
                        ),
                      ),
                    )
                    .toList(),
              );
            },
          ),
        ],
      ),
    );
  }
}

// ─── Trainer class card ───────────────────────────────────────────────────────

/// Read-only card showing a trainer's own group class with roster count.
class _TrainerClassCard extends StatelessWidget {
  const _TrainerClassCard({required this.groupClass});

  final GroupClass groupClass;

  @override
  Widget build(BuildContext context) {
    final gc = groupClass;

    String formattedDate = gc.date;
    try {
      final dt = DateTime.parse(gc.date);
      formattedDate = DateFormat.yMMMEd('sr_Latn').format(dt);
    } catch (_) {
      // fall back to raw string
    }

    return Container(
      padding: const EdgeInsets.fromLTRB(16, 14, 12, 14),
      decoration: BoxDecoration(
        color: kInkElevated,
        border: Border.all(color: kLineDark),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  gc.title,
                  style: GoogleFonts.archivoBlack(
                    color: kOffWhite,
                    fontSize: 16,
                    height: 1.1,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '$formattedDate · ${gc.start}–${gc.end}',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          // Roster count badge — e.g. "3/10"
          Text(
            '${gc.joinedCount}/${gc.capacity}',
            style: GoogleFonts.archivoBlack(
              color: kVolt,
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Helper ───────────────────────────────────────────────────────────────────

/// Uppercase muted label above a picker button — mirrors [KineticField]'s label
/// style without a text field underneath.
class _PickerLabel extends StatelessWidget {
  const _PickerLabel(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(
      text.toUpperCase(),
      style: GoogleFonts.interTight(
        color: kMutedDark,
        fontSize: 11,
        fontWeight: FontWeight.w700,
        letterSpacing: 1.6,
      ),
    );
  }
}
