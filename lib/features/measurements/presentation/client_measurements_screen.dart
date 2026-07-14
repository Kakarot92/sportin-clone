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
import 'package:sportin_clone/l10n/app_localizations.dart';

/// Trainer read-only view of a client's measurements.
///
/// Route: /profile/clients/:clientUid
/// Guard: trainer-only (AS-063, AS-064 — trainers may read, never write).
///
/// [clientDisplayName] is passed via GoRouter [state.extra] so the title
/// can be shown without a Firestore join.
class ClientMeasurementsScreen extends ConsumerWidget {
  const ClientMeasurementsScreen({
    super.key,
    required this.clientUid,
    this.clientDisplayName,
  });

  final String clientUid;
  final String? clientDisplayName;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final me = ref.watch(appUserProvider).asData?.value;

    // Trainer-only guard.
    if (me == null || !me.isTrainer) {
      return Scaffold(
        appBar: AppBar(),
        body: Center(child: Text(l10n.notAuthorized)),
      );
    }

    final entriesAsync = ref.watch(clientMeasurementsProvider(clientUid));

    return Scaffold(
      appBar: AppBar(),
      body: Stack(
        children: [
          const Positioned.fill(
            child: SpeedLines(density: 14, seed: 8, opacity: 0.10),
          ),
          ListView(
            padding: const EdgeInsets.fromLTRB(24, 0, 24, 32),
            children: [
              const Eyebrow('Trener'),
              const SizedBox(height: 10),
              DisplayTitle(l10n.clientMeasurements),
              if (clientDisplayName != null && clientDisplayName!.isNotEmpty) ...[
                const SizedBox(height: 4),
                Text(
                  clientDisplayName!.toUpperCase(),
                  style: GoogleFonts.interTight(
                    fontSize: 13,
                    color: kMutedDark,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 1.4,
                  ),
                ),
              ],
              const SizedBox(height: 24),
              entriesAsync.when(
                loading: () =>
                    const Center(child: CircularProgressIndicator()),
                error: (_, _) => Text(l10n.errorGeneric),
                data: (entries) =>
                    _ReadOnlyMeasurementsContent(entries: entries),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ── Read-only content shared with client view ─────────────────────────────────

class _ReadOnlyMeasurementsContent extends StatelessWidget {
  const _ReadOnlyMeasurementsContent({required this.entries});

  final List<MeasurementEntry> entries;

  List<MeasurementEntry> get _chartEntries =>
      entries.reversed.where((e) => e.weightKg != null).toList();

  bool get _showChart => _chartEntries.length >= 2;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);

    if (entries.isEmpty) {
      return Text(l10n.noMeasurementsYet, style: theme.textTheme.bodyMedium);
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (_showChart) ...[
          _WeightChartReadOnly(entries: _chartEntries),
          const SizedBox(height: 20),
        ],
        SectionHeader(l10n.measurementsTitle),
        const SizedBox(height: 12),
        ...entries.asMap().entries.map(
              (e) => Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: Reveal(
                  index: e.key,
                  child: _ReadOnlyMeasurementCard(entry: e.value),
                ),
              ),
            ),
      ],
    );
  }
}

// ── Chart widget (duplicated ~30 lines per spec; shared logic via same impl) ───

class _WeightChartReadOnly extends StatelessWidget {
  const _WeightChartReadOnly({required this.entries});

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

// ── Read-only card (no edit/delete — AS-063/AS-064) ───────────────────────────

class _ReadOnlyMeasurementCard extends StatelessWidget {
  const _ReadOnlyMeasurementCard({required this.entry});

  final MeasurementEntry entry;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    String dateLabel = entry.date;
    try {
      final dt = DateTime.parse(entry.date);
      dateLabel = DateFormat.yMMMEd('sr_Latn').format(dt);
    } catch (_) {}

    final fields = <String>[];
    if (entry.weightKg != null) fields.add('${kDec(entry.weightKg!)} kg');
    if (entry.bodyFatPercent != null) {
      fields.add('${kDec(entry.bodyFatPercent!)}% masti');
    }
    if (entry.waistCm != null) fields.add('struk ${entry.waistCm!.round()} cm');
    if (entry.chestCm != null) fields.add('grudi ${entry.chestCm!.round()} cm');
    if (entry.hipsCm != null) fields.add('kukovi ${entry.hipsCm!.round()} cm');

    return Container(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
      decoration: BoxDecoration(
        color: kInkElevated,
        border: Border.all(color: kLineDark),
      ),
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
    );
  }
}
