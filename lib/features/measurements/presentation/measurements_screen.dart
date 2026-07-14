import 'dart:math' as math;

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:sportin_clone/app/kinetic.dart';
import 'package:sportin_clone/app/kinetic_effects.dart';
import 'package:sportin_clone/app/theme.dart';
import 'package:sportin_clone/features/auth/application/auth_providers.dart';
import 'package:sportin_clone/features/measurements/application/measurements_providers.dart';
import 'package:sportin_clone/features/measurements/domain/measurement_entry.dart';
import 'package:sportin_clone/features/scheduling/domain/date_utils.dart';
import 'package:sportin_clone/l10n/app_localizations.dart';

/// Tab-landing screen for the Measurements tab — no AppBar.
///
/// Clients can view their measurement history (chart + list) and
/// add / edit / delete entries. Guard: appUserProvider null → loading.
class MeasurementsScreen extends ConsumerWidget {
  const MeasurementsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final me = ref.watch(appUserProvider).asData?.value;

    // Mirror my_bookings_screen.dart null-guard pattern.
    if (me == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return _MeasurementsScaffold(uid: me.uid);
  }
}

// ── Top-level scaffold ────────────────────────────────────────────────────────

class _MeasurementsScaffold extends ConsumerWidget {
  const _MeasurementsScaffold({required this.uid});
  final String uid;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final entriesAsync = ref.watch(clientMeasurementsProvider(uid));

    return Scaffold(
      body: Stack(
        children: [
          // Faint speed-lines backdrop — mirrors trainer_directory_screen.dart.
          const Positioned.fill(
            child: SpeedLines(density: 14, seed: 5, opacity: 0.12),
          ),
          SafeArea(
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 560),
                child: entriesAsync.when(
                  loading: () =>
                      const Center(child: CircularProgressIndicator()),
                  error: (_, _) => Center(child: Text(l10n.errorGeneric)),
                  data: (entries) =>
                      _MeasurementsContent(uid: uid, entries: entries),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Scrollable content ────────────────────────────────────────────────────────

class _MeasurementsContent extends StatelessWidget {
  const _MeasurementsContent({
    required this.uid,
    required this.entries,
  });

  final String uid;
  final List<MeasurementEntry> entries;

  // Chart uses oldest-first, non-null weight entries.
  List<MeasurementEntry> get _chartEntries =>
      entries.reversed.where((e) => e.weightKg != null).toList();

  bool get _showChart => _chartEntries.length >= 2;

  Widget _buildWeightHero(List<MeasurementEntry> entries) {
    final latestWeight = entries.last.weightKg!;
    final hasDelta = entries.length >= 2;
    final delta = hasDelta ? latestWeight - entries.first.weightKg! : 0.0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              kDec(latestWeight),
              style: GoogleFonts.archivoBlack(
                fontSize: 64,
                height: 0.9,
                color: kOffWhite,
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(bottom: 6, left: 6),
              child: Text(
                'KG',
                style: GoogleFonts.archivoBlack(
                  fontSize: 20,
                  color: kMutedDark,
                ),
              ),
            ),
          ],
        ),
        if (hasDelta) ...[
          const SizedBox(height: 6),
          Text(
            '${delta >= 0 ? '+' : ''}${kDec(delta)} kg od početka',
            style: GoogleFonts.interTight(
              fontWeight: FontWeight.w700,
              color: kVolt,
              fontSize: 13,
              letterSpacing: 0.5,
            ),
          ),
        ],
      ],
    );
  }

  void _openAddDialog(BuildContext context) {
    showDialog<void>(
      context: context,
      builder: (_) => _MeasurementDialog(uid: uid),
    );
  }

  void _openEditDialog(BuildContext context, MeasurementEntry entry) {
    showDialog<void>(
      context: context,
      builder: (_) => _MeasurementDialog(uid: uid, existing: entry),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);

    // Dynamic reveal indices that shift depending on chart presence.
    var ri = 0;

    return CustomScrollView(
      slivers: [
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(24, 20, 24, 0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Reveal(
                  index: ri++,
                  child: Eyebrow(l10n.navMeasurements),
                ),
                const SizedBox(height: 6),
                Reveal(
                  index: ri++,
                  child: DisplayTitle(l10n.measurementsTitle, size: 38),
                ),
                const SizedBox(height: 20),
                // Hero weight number — appears before the chart when at
                // least one entry has a weight value.
                if (_chartEntries.isNotEmpty) ...[
                  Reveal(
                    index: ri++,
                    child: _buildWeightHero(_chartEntries),
                  ),
                  const SizedBox(height: 20),
                ],
                if (_showChart) ...[
                  Reveal(
                    index: ri++,
                    child: _WeightChart(entries: _chartEntries),
                  ),
                  const SizedBox(height: 20),
                ],
                Reveal(
                  index: ri++,
                  child: VoltButton(
                    label: l10n.addMeasurement,
                    icon: Icons.add,
                    onPressed: () => _openAddDialog(context),
                  ),
                ),
                const SizedBox(height: 20),
                Reveal(
                  index: ri++,
                  child: SectionHeader(l10n.measurementsTitle),
                ),
                const SizedBox(height: 12),
              ],
            ),
          ),
        ),

        // Empty state.
        if (entries.isEmpty)
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Text(
                l10n.noMeasurementsYet,
                style: theme.textTheme.bodyMedium,
              ),
            ),
          )
        else
          SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, i) => Padding(
                padding: const EdgeInsets.fromLTRB(24, 0, 24, 10),
                child: Reveal(
                  index: ri + i,
                  child: _MeasurementCard(
                    entry: entries[i],
                    onEdit: () => _openEditDialog(context, entries[i]),
                  ),
                ),
              ),
              childCount: entries.length,
            ),
          ),

        const SliverPadding(padding: EdgeInsets.only(bottom: 40)),
      ],
    );
  }
}

// ── Weight line chart (AS-061) ────────────────────────────────────────────────

class _WeightChart extends StatelessWidget {
  const _WeightChart({required this.entries});

  // Entries are oldest-first; all have non-null weightKg.
  final List<MeasurementEntry> entries;

  @override
  Widget build(BuildContext context) {
    final spots = entries.asMap().entries.map((e) {
      return FlSpot(e.key.toDouble(), e.value.weightKg!);
    }).toList();

    final weights = entries.map((e) => e.weightKg!);
    final minY = weights.reduce(math.min) - 3;
    final maxY = weights.reduce(math.max) + 3;

    return Container(
      height: 180,
      padding: const EdgeInsets.only(right: 8, top: 8, bottom: 4),
      decoration: BoxDecoration(
        color: kInkElevated,
        border: Border.all(color: kLineDark),
      ),
      child: LineChart(
        LineChartData(
          minY: minY,
          maxY: maxY,
          lineBarsData: [
            LineChartBarData(
              spots: spots,
              isCurved: true,
              color: kVolt,
              barWidth: 2,
              dotData: const FlDotData(show: true),
              belowBarData: BarAreaData(
                show: true,
                color: kVolt.withValues(alpha: 0.07),
              ),
            ),
          ],
          gridData: FlGridData(
            show: true,
            drawVerticalLine: false,
            getDrawingHorizontalLine: (v) => const FlLine(
              color: kLineDark,
              strokeWidth: 1,
            ),
          ),
          titlesData: FlTitlesData(
            topTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
            rightTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
            bottomTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 36,
                getTitlesWidget: (v, meta) => Text(
                  v.round().toString(),
                  style: GoogleFonts.interTight(
                    fontSize: 10,
                    color: kMutedDark,
                  ),
                  textAlign: TextAlign.right,
                ),
              ),
            ),
          ),
          borderData: FlBorderData(show: false),
          lineTouchData: LineTouchData(
            touchTooltipData: LineTouchTooltipData(
              getTooltipColor: (_) => kInkElevated,
              getTooltipItems: (touchedSpots) => touchedSpots
                  .map(
                    (s) => LineTooltipItem(
                      '${kDec(s.y)} kg',
                      GoogleFonts.interTight(
                        color: kOffWhite,
                        fontWeight: FontWeight.w700,
                        fontSize: 12,
                      ),
                    ),
                  )
                  .toList(),
            ),
          ),
        ),
      ),
    );
  }
}

// ── Measurement card (AS-062 edit/delete) ─────────────────────────────────────

class _MeasurementCard extends ConsumerWidget {
  const _MeasurementCard({
    required this.entry,
    required this.onEdit,
  });

  final MeasurementEntry entry;
  final VoidCallback onEdit;

  Future<void> _delete(BuildContext context, WidgetRef ref) async {
    final l10n = AppLocalizations.of(context);
    final messenger = ScaffoldMessenger.of(context);

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l10n.deleteMeasurement),
        content: Text(entry.date),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: Text(l10n.cancel),
          ),
          FilledButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: Text(l10n.deleteMeasurement),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    final ok = await ref
        .read(measurementsControllerProvider.notifier)
        .deleteEntry(entry.id);

    if (!context.mounted) return;
    messenger.showSnackBar(SnackBar(
      content: Text(ok ? l10n.measurementDeleted : l10n.errorGeneric),
    ));
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);

    String dateLabel = entry.date;
    try {
      final dt = DateTime.parse(entry.date);
      dateLabel = DateFormat.yMMMEd('sr_Latn').format(dt);
    } catch (_) {}

    final fields = <String>[];
    if (entry.weightKg != null) fields.add('${kDec(entry.weightKg!)} kg');
    if (entry.waistCm != null) fields.add('struk ${entry.waistCm!.round()} cm');
    if (entry.chestCm != null) fields.add('grudi ${entry.chestCm!.round()} cm');
    if (entry.hipsCm != null) fields.add('kukovi ${entry.hipsCm!.round()} cm');

    return Container(
      padding: const EdgeInsets.fromLTRB(16, 14, 8, 14),
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
                  dateLabel.toUpperCase(),
                  style: GoogleFonts.interTight(
                    fontSize: 11,
                    color: kVolt,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 1.4,
                  ),
                ),
                if (fields.isNotEmpty) ...[
                  const SizedBox(height: 6),
                  Text(
                    fields.join('  ·  '),
                    style: GoogleFonts.archivoBlack(
                      fontSize: 14,
                      color: kOffWhite,
                    ),
                  ),
                ],
                if (entry.note.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Text(entry.note, style: theme.textTheme.bodyMedium),
                ],
              ],
            ),
          ),
          // Edit + delete icon actions.
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                icon: const Icon(Icons.edit_outlined, color: kVolt, size: 18),
                tooltip: 'Edit',
                padding: EdgeInsets.zero,
                constraints:
                    const BoxConstraints(minWidth: 36, minHeight: 36),
                onPressed: onEdit,
              ),
              IconButton(
                icon:
                    const Icon(Icons.delete_outline, color: kDanger, size: 18),
                tooltip: 'Delete',
                padding: EdgeInsets.zero,
                constraints:
                    const BoxConstraints(minWidth: 36, minHeight: 36),
                onPressed: () => _delete(context, ref),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ── Add / Edit dialog ─────────────────────────────────────────────────────────

class _MeasurementDialog extends ConsumerStatefulWidget {
  const _MeasurementDialog({
    required this.uid,
    this.existing,
  });

  final String uid;
  final MeasurementEntry? existing;

  @override
  ConsumerState<_MeasurementDialog> createState() => _MeasurementDialogState();
}

class _MeasurementDialogState extends ConsumerState<_MeasurementDialog> {
  late DateTime _pickedDate;
  late final TextEditingController _weight;
  late final TextEditingController _waist;
  late final TextEditingController _chest;
  late final TextEditingController _hips;
  late final TextEditingController _note;
  bool _submitting = false;

  @override
  void initState() {
    super.initState();
    final e = widget.existing;
    _pickedDate = e != null
        ? (DateTime.tryParse(e.date) ?? DateTime.now())
        : DateTime.now();
    _weight = TextEditingController(
        text: e?.weightKg != null ? e!.weightKg!.toString() : '');
    _waist = TextEditingController(
        text: e?.waistCm != null ? e!.waistCm!.toString() : '');
    _chest = TextEditingController(
        text: e?.chestCm != null ? e!.chestCm!.toString() : '');
    _hips = TextEditingController(
        text: e?.hipsCm != null ? e!.hipsCm!.toString() : '');
    _note = TextEditingController(text: e?.note ?? '');
  }

  @override
  void dispose() {
    _weight.dispose();
    _waist.dispose();
    _chest.dispose();
    _hips.dispose();
    _note.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final today = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _pickedDate,
      firstDate: today.subtract(const Duration(days: 365)),
      lastDate: today,
    );
    if (picked != null && mounted) setState(() => _pickedDate = picked);
  }

  Future<void> _submit() async {
    final l10n = AppLocalizations.of(context);
    final messenger = ScaffoldMessenger.of(context);
    final navigator = Navigator.of(context);

    setState(() => _submitting = true);

    final entry = MeasurementEntry(
      id: widget.existing?.id ?? '',
      clientUid: widget.uid,
      date: ymd(_pickedDate),
      weightKg: double.tryParse(_weight.text.trim()),
      waistCm: double.tryParse(_waist.text.trim()),
      chestCm: double.tryParse(_chest.text.trim()),
      hipsCm: double.tryParse(_hips.text.trim()),
      note: _note.text.trim(),
    );

    final bool ok;
    if (widget.existing != null) {
      ok = await ref
          .read(measurementsControllerProvider.notifier)
          .updateEntry(entry);
    } else {
      ok = await ref
          .read(measurementsControllerProvider.notifier)
          .addEntry(entry);
    }

    if (!mounted) return;
    setState(() => _submitting = false);

    if (ok) {
      navigator.pop();
      messenger.showSnackBar(
        SnackBar(content: Text(l10n.measurementSaved)),
      );
    } else {
      messenger.showSnackBar(
        SnackBar(content: Text(l10n.errorGeneric)),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final isEditing = widget.existing != null;
    final dateLabel = DateFormat.yMMMEd('sr_Latn').format(_pickedDate);

    return AlertDialog(
      title: Text(isEditing ? l10n.editMeasurement : l10n.addMeasurement),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Date picker row.
            OutlinedButton.icon(
              onPressed: _pickDate,
              icon: const Icon(Icons.calendar_today_outlined, size: 16),
              label: Text(dateLabel),
            ),
            const SizedBox(height: 14),
            KineticField(
              label: l10n.weightKg,
              controller: _weight,
              keyboardType:
                  const TextInputType.numberWithOptions(decimal: true),
            ),
            const SizedBox(height: 10),
            KineticField(
              label: l10n.waistCm,
              controller: _waist,
              keyboardType:
                  const TextInputType.numberWithOptions(decimal: true),
            ),
            const SizedBox(height: 10),
            KineticField(
              label: l10n.chestCm,
              controller: _chest,
              keyboardType:
                  const TextInputType.numberWithOptions(decimal: true),
            ),
            const SizedBox(height: 10),
            KineticField(
              label: l10n.hipsCm,
              controller: _hips,
              keyboardType:
                  const TextInputType.numberWithOptions(decimal: true),
            ),
            const SizedBox(height: 10),
            KineticField(
              label: l10n.measurementNote,
              controller: _note,
              textCapitalization: TextCapitalization.sentences,
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed:
              _submitting ? null : () => Navigator.of(context).pop(),
          child: Text(l10n.cancel),
        ),
        FilledButton(
          onPressed: _submitting ? null : _submit,
          child: _submitting
              ? const SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: kInk,
                  ),
                )
              : Text(l10n.save),
        ),
      ],
    );
  }
}
