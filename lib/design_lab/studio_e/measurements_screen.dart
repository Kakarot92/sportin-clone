import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../mock_data.dart';
import 'chart.dart';
import 'theme.dart';
import 'widgets.dart';

/// Merenja — count-up trenutnih brojeva + neon area-chart napretka
/// kroz 12 nedelja. Prekidač bira metriku (težina / masnoća / struk),
/// chart morfuje na promenu.
enum _Metric {
  weight('Težina', 'kg'),
  bodyFat('Masnoća', '%'),
  waist('Struk', 'cm');

  const _Metric(this.label, this.unit);
  final String label;
  final String unit;
}

class StudioEMeasurementsScreen extends StatefulWidget {
  const StudioEMeasurementsScreen({super.key});

  @override
  State<StudioEMeasurementsScreen> createState() =>
      _StudioEMeasurementsScreenState();
}

class _StudioEMeasurementsScreenState extends State<StudioEMeasurementsScreen> {
  final ScrollController _scroll = ScrollController();
  _Metric _metric = _Metric.weight;

  // Stabilne instance serija — promena instance pokreće morph u chartu.
  static final List<double> _weight = [
    for (final m in mockMeasurements) m.weightKg
  ];
  static final List<double> _bodyFat = [
    for (final m in mockMeasurements) m.bodyFatPct
  ];
  static final List<double> _waist = [
    for (final m in mockMeasurements) m.waistCm
  ];

  @override
  void dispose() {
    _scroll.dispose();
    super.dispose();
  }

  List<double> get _series => switch (_metric) {
        _Metric.weight => _weight,
        _Metric.bodyFat => _bodyFat,
        _Metric.waist => _waist,
      };

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context).textTheme;
    final first = mockMeasurements.first;
    final last = mockMeasurements.last;

    return Scaffold(
      body: Stack(
        children: [
          StudioEParallaxBackdrop(controller: _scroll),
          SafeArea(
            bottom: false,
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 560),
                child: ListView(
                  controller: _scroll,
                  padding: const EdgeInsets.fromLTRB(
                    StudioESpace.xl,
                    StudioESpace.l,
                    StudioESpace.xl,
                    StudioESpace.section,
                  ),
                  children: [
                    StudioEEntrance(
                      child: StudioEGradientText(
                        'Merenja',
                        style: theme.displaySmall!,
                      ),
                    ),
                    const SizedBox(height: StudioESpace.xs + 2),
                    StudioEEntrance(
                      delayMs: 60,
                      child: Text(
                        '12 nedelja napretka — od ${StudioEFmt.decimal(first.weightKg)} '
                        'do ${StudioEFmt.decimal(last.weightKg)} kg.',
                        style: theme.bodyMedium!
                            .copyWith(color: StudioEColors.textDim),
                      ),
                    ),
                    const SizedBox(height: StudioESpace.xl),

                    // Trenutni brojevi.
                    StudioEEntrance(
                      delayMs: 120,
                      child: Row(
                        children: [
                          Expanded(
                            child: _CurrentCard(
                              value: last.weightKg,
                              unit: 'kg',
                              label: 'Težina',
                              delta: last.weightKg - first.weightKg,
                              emphasis: true,
                            ),
                          ),
                          const SizedBox(width: StudioESpace.m - 2),
                          Expanded(
                            child: _CurrentCard(
                              value: last.bodyFatPct,
                              unit: '%',
                              label: 'Masnoća',
                              delta: last.bodyFatPct - first.bodyFatPct,
                            ),
                          ),
                          const SizedBox(width: StudioESpace.m - 2),
                          Expanded(
                            child: _CurrentCard(
                              value: last.waistCm,
                              unit: 'cm',
                              label: 'Struk',
                              delta: last.waistCm - first.waistCm,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: StudioESpace.section),

                    StudioEEntrance(
                      delayMs: 180,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const StudioESectionLabel('Napredak'),
                          Text(
                            'Dodirni tačku za detalj',
                            style: theme.bodySmall,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: StudioESpace.m),

                    // Prekidač metrike.
                    StudioEEntrance(
                      delayMs: 210,
                      child: _MetricSwitch(
                        selected: _metric,
                        onSelect: (m) => setState(() => _metric = m),
                      ),
                    ),
                    const SizedBox(height: StudioESpace.l),

                    StudioEEntrance(
                      delayMs: 250,
                      child: StudioEDepthCard(
                        padding: const EdgeInsets.fromLTRB(6, 14, 6, 6),
                        child: StudioEProgressChart(
                          values: _series,
                          unit: _metric.unit,
                        ),
                      ),
                    ),
                    const SizedBox(height: StudioESpace.section),

                    const StudioEEntrance(
                      delayMs: 300,
                      child: StudioESectionLabel('Nedelja po nedelja'),
                    ),
                    const SizedBox(height: StudioESpace.m),
                    StudioEEntrance(
                      delayMs: 340,
                      child: _WeeklyBreakdown(metric: _metric),
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

class _CurrentCard extends StatelessWidget {
  const _CurrentCard({
    required this.value,
    required this.unit,
    required this.label,
    required this.delta,
    this.emphasis = false,
  });

  final double value;
  final String unit;
  final String label;
  final double delta;
  final bool emphasis;

  @override
  Widget build(BuildContext context) {
    // Za sve tri metrike pad je napredak → zelenkasti cyan; rast bi bio crven.
    final good = delta <= 0;
    final deltaColor = good ? StudioEColors.cyan : const Color(0xFFFF7A8A);
    return StudioEDepthCard(
      emphasis: emphasis,
      padding: const EdgeInsets.symmetric(
        horizontal: StudioESpace.s + 2,
        vertical: StudioESpace.l,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Flexible(
                child: StudioECountUp(
                  value: value,
                  format: (v) => StudioEFmt.decimal(v),
                  style: GoogleFonts.syne(
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                    color: StudioEColors.text,
                    height: 1,
                  ),
                ),
              ),
              const SizedBox(width: 2),
              Text(
                unit,
                style: GoogleFonts.ibmPlexSans(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: StudioEColors.textDim,
                ),
              ),
            ],
          ),
          const SizedBox(height: StudioESpace.xs),
          Text(
            label.toUpperCase(),
            style: GoogleFonts.ibmPlexSans(
              fontSize: 9.5,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.9,
              color: StudioEColors.textDim,
            ),
          ),
          const SizedBox(height: StudioESpace.s),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
            decoration: BoxDecoration(
              color: deltaColor.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              '${StudioEFmt.signed(delta)} $unit',
              style: GoogleFonts.ibmPlexSans(
                fontSize: 10.5,
                fontWeight: FontWeight.w700,
                color: deltaColor,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _MetricSwitch extends StatelessWidget {
  const _MetricSwitch({required this.selected, required this.onSelect});

  final _Metric selected;
  final ValueChanged<_Metric> onSelect;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: StudioEColors.layer1,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: StudioEColors.hairline),
      ),
      child: Row(
        children: [
          for (final m in _Metric.values)
            Expanded(
              child: _SwitchTab(
                label: m.label,
                active: m == selected,
                onTap: () => onSelect(m),
              ),
            ),
        ],
      ),
    );
  }
}

class _SwitchTab extends StatelessWidget {
  const _SwitchTab({
    required this.label,
    required this.active,
    required this.onTap,
  });

  final String label;
  final bool active;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      selected: active,
      label: label,
      child: GestureDetector(
        onTap: onTap,
        behavior: HitTestBehavior.opaque,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 280),
          curve: Curves.easeOutCubic,
          height: 48,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(11),
            gradient: active
                ? const LinearGradient(
                    colors: [
                      Color(0x3353E8D4),
                      Color(0x33B26BFF),
                    ],
                  )
                : null,
            border: Border.all(
              color: active
                  ? StudioEColors.cyan.withValues(alpha: 0.6)
                  : Colors.transparent,
            ),
          ),
          child: Text(
            label,
            style: GoogleFonts.ibmPlexSans(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: active ? StudioEColors.text : StudioEColors.textDim,
            ),
          ),
        ),
      ),
    );
  }
}

/// Kompaktan pregled po nedeljama za izabranu metriku (bez glow-a).
class _WeeklyBreakdown extends StatelessWidget {
  const _WeeklyBreakdown({required this.metric});

  final _Metric metric;

  double _value(MockMeasurement m) => switch (metric) {
        _Metric.weight => m.weightKg,
        _Metric.bodyFat => m.bodyFatPct,
        _Metric.waist => m.waistCm,
      };

  @override
  Widget build(BuildContext context) {
    return StudioEDepthCard(
      padding: const EdgeInsets.symmetric(
        horizontal: StudioESpace.l,
        vertical: StudioESpace.s,
      ),
      child: Column(
        children: [
          for (var i = 0; i < mockMeasurements.length; i++) ...[
            _WeekRow(
              week: mockMeasurements[i].week,
              value: _value(mockMeasurements[i]),
              unit: metric.unit,
              delta: i == 0
                  ? null
                  : _value(mockMeasurements[i]) -
                      _value(mockMeasurements[i - 1]),
            ),
            if (i < mockMeasurements.length - 1)
              const Divider(
                height: 1,
                thickness: 1,
                color: StudioEColors.hairline,
              ),
          ],
        ],
      ),
    );
  }
}

class _WeekRow extends StatelessWidget {
  const _WeekRow({
    required this.week,
    required this.value,
    required this.unit,
    required this.delta,
  });

  final int week;
  final double value;
  final String unit;
  final double? delta;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context).textTheme;
    final d = delta;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: StudioESpace.m - 1),
      child: Row(
        children: [
          SizedBox(
            width: 34,
            child: Text(
              'N$week',
              style: GoogleFonts.syne(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: StudioEColors.textDim,
              ),
            ),
          ),
          const SizedBox(width: StudioESpace.m),
          Text(
            '${StudioEFmt.decimal(value)} $unit',
            style: theme.titleMedium,
          ),
          const Spacer(),
          if (d != null)
            Text(
              '${StudioEFmt.signed(d)} $unit',
              style: GoogleFonts.ibmPlexSans(
                fontSize: 12.5,
                fontWeight: FontWeight.w600,
                color: d <= 0 ? StudioEColors.cyan : const Color(0xFFFF7A8A),
              ),
            )
          else
            Text('polazna', style: theme.bodySmall),
        ],
      ),
    );
  }
}
