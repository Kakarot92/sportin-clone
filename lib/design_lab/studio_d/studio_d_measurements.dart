import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../mock_data.dart';
import 'studio_d_theme.dart';

/// Merenja — STAR EKRAN. Tri metrike (težina/mast/struk) prebacive tab-blokom,
/// delta badge-ovi, blok bar-chart bez zaobljenja, mono tabela 12 nedelja
/// sa zebra prugama i po-redno delta kolonom.
class StudioDMeasurementsScreen extends StatefulWidget {
  const StudioDMeasurementsScreen({super.key});

  @override
  State<StudioDMeasurementsScreen> createState() =>
      _StudioDMeasurementsScreenState();
}

enum _Metric { weight, fat, waist }

class _StudioDMeasurementsScreenState extends State<StudioDMeasurementsScreen> {
  _Metric _metric = _Metric.weight;

  double _valueOf(MockMeasurement m) {
    switch (_metric) {
      case _Metric.weight:
        return m.weightKg;
      case _Metric.fat:
        return m.bodyFatPct;
      case _Metric.waist:
        return m.waistCm;
    }
  }

  String get _unit {
    switch (_metric) {
      case _Metric.weight:
        return 'KG';
      case _Metric.fat:
        return '%';
      case _Metric.waist:
        return 'CM';
    }
  }

  String get _metricTitle {
    switch (_metric) {
      case _Metric.weight:
        return 'TEŽINA';
      case _Metric.fat:
        return 'TELESNA MAST';
      case _Metric.waist:
        return 'OBIM STRUKA';
    }
  }

  Color get _accent {
    switch (_metric) {
      case _Metric.weight:
        return StudioDColors.yellow;
      case _Metric.fat:
        return StudioDColors.red;
      case _Metric.waist:
        return StudioDColors.blue;
    }
  }

  @override
  Widget build(BuildContext context) {
    final first = _valueOf(mockMeasurements.first);
    final last = _valueOf(mockMeasurements.last);
    final delta = last - first;
    final pct = first == 0 ? 0.0 : (delta / first) * 100;

    return StudioDPage(
      children: [
        StudioDStagger(
          index: 0,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Expanded(
                child: Text(
                  'MERENJA',
                  style: StudioDType.grotesk(
                    size: 30,
                    weight: FontWeight.w700,
                    spacing: 1.5,
                  ),
                ),
              ),
              const StudioDTag('12 nedelja', fill: StudioDColors.paper),
            ],
          ),
        ),
        const SizedBox(height: 6),
        StudioDStagger(
          index: 0,
          child: Text(
            'Napredak od 1. do 12. nedelje. Manje je bolje.',
            style: StudioDType.grotesk(
              size: 13,
              color: StudioDColors.inkSoft,
            ),
          ),
        ),
        const SizedBox(height: 18),
        StudioDStagger(index: 1, child: _buildMetricTabs()),
        const SizedBox(height: 16),
        StudioDStagger(
          index: 2,
          child: _buildHeadline(first, last, delta, pct),
        ),
        const SizedBox(height: 22),
        StudioDStagger(
          index: 3,
          child: StudioDSectionLabel(
            'Grafikon — $_metricTitle',
            trailing: StudioDTag(_unit, fill: _accent),
          ),
        ),
        StudioDStagger(index: 3, child: _buildChart()),
        const SizedBox(height: 22),
        StudioDStagger(
          index: 4,
          child: StudioDSectionLabel(
            'Tabela — sve nedelje',
            trailing: const StudioDTag('Mono', fill: StudioDColors.paper),
          ),
        ),
        StudioDStagger(index: 4, child: _buildTable()),
      ],
    );
  }

  Widget _buildMetricTabs() {
    final items = [
      (_Metric.weight, 'TEŽINA'),
      (_Metric.fat, 'MAST'),
      (_Metric.waist, 'STRUK'),
    ];
    return Row(
      children: [
        for (var i = 0; i < items.length; i++) ...[
          Expanded(
            child: StudioDPressable(
              color: _metric == items[i].$1
                  ? StudioDColors.ink
                  : StudioDColors.white,
              shadow: _metric == items[i].$1 ? 4 : 3,
              padding: const EdgeInsets.symmetric(vertical: 12),
              onTap: () => setState(() => _metric = items[i].$1),
              child: Center(
                child: Text(
                  items[i].$2,
                  style: StudioDType.grotesk(
                    size: 13,
                    weight: FontWeight.w700,
                    spacing: 0.8,
                    color: _metric == items[i].$1
                        ? StudioDColors.paper
                        : StudioDColors.ink,
                  ),
                ),
              ),
            ),
          ),
          if (i < items.length - 1) const SizedBox(width: 10),
        ],
      ],
    );
  }

  Widget _buildHeadline(double first, double last, double delta, double pct) {
    final down = delta < 0;
    // Za sve tri metrike pad je napredak → zeleno kad je delta < 0.
    final deltaColor = down ? StudioDColors.green : StudioDColors.red;
    return StudioDPanel(
      shadow: 5,
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
      child: Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _bigStat('POČETAK', first.toStringAsFixed(1)),
              _arrow(),
              _bigStat('SADA', last.toStringAsFixed(1), accent: true),
            ],
          ),
          const SizedBox(height: 14),
          Container(height: 2, color: StudioDColors.ink),
          const SizedBox(height: 12),
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: deltaColor,
                  border: Border.all(color: StudioDColors.ink, width: 2),
                  boxShadow: studioDShadow(3),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      down
                          ? Icons.arrow_downward_sharp
                          : Icons.arrow_upward_sharp,
                      size: 18,
                      color: StudioDColors.ink,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      '${studioDDelta(delta)} $_unit',
                      style: StudioDType.mono(
                        size: 17,
                        weight: FontWeight.w700,
                        color: StudioDColors.ink,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'PROMENA ZA 12 NEDELJA',
                      style: StudioDType.mono(
                        size: 8.5,
                        weight: FontWeight.w700,
                        color: StudioDColors.inkSoft,
                        spacing: 0.5,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Row(
                      children: [
                        Container(
                          width: 11,
                          height: 11,
                          margin: const EdgeInsets.only(right: 6),
                          decoration: BoxDecoration(
                            color: deltaColor,
                            border:
                                Border.all(color: StudioDColors.ink, width: 1.5),
                          ),
                        ),
                        Text(
                          '${studioDDelta(pct)} %',
                          style: StudioDType.mono(
                            size: 15,
                            weight: FontWeight.w700,
                            color: StudioDColors.ink,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _bigStat(String label, String value, {bool accent = false}) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: StudioDType.mono(
              size: 9,
              weight: FontWeight.w700,
              color: StudioDColors.inkSoft,
              spacing: 1,
            ),
          ),
          const SizedBox(height: 4),
          Container(
            padding: accent
                ? const EdgeInsets.symmetric(horizontal: 6, vertical: 2)
                : EdgeInsets.zero,
            decoration: accent
                ? BoxDecoration(
                    color: _accent,
                    border: Border.all(color: StudioDColors.ink, width: 2),
                  )
                : null,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  value,
                  style: StudioDType.mono(
                    size: 26,
                    weight: FontWeight.w700,
                    height: 1,
                  ),
                ),
                const SizedBox(width: 3),
                Padding(
                  padding: const EdgeInsets.only(bottom: 2),
                  child: Text(
                    _unit,
                    style: StudioDType.mono(
                      size: 10,
                      weight: FontWeight.w700,
                      color: StudioDColors.inkSoft,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _arrow() {
    return const Padding(
      padding: EdgeInsets.only(top: 18, left: 4, right: 4),
      child: Icon(Icons.east_sharp, size: 20, color: StudioDColors.ink),
    );
  }

  Widget _buildChart() {
    final values = mockMeasurements.map(_valueOf).toList();
    final maxV = values.reduce(math.max);
    final minV = values.reduce(math.min);
    final range = (maxV - minV) == 0 ? 1.0 : (maxV - minV);
    // Normalizacija: min → 18% visine, max → 100%.
    final factors = <double>[
      for (final v in values) 0.18 + 0.82 * ((v - minV) / range),
    ];
    final count = values.length;
    return StudioDPanel(
      shadow: 5,
      padding: const EdgeInsets.fromLTRB(12, 16, 12, 10),
      child: LayoutBuilder(
        builder: (context, constraints) {
          const bandHeight = 150.0;
          const topPad = 24.0; // prostor za trend-čvor + vrednost iznad
          const maxBar = bandHeight - topPad;
          final width = constraints.maxWidth;
          final slot = width / count;
          final barWidth = math.min(slot - 6, 20.0);
          return Column(
            children: [
              SizedBox(
                height: bandHeight,
                width: width,
                child: TweenAnimationBuilder<double>(
                  tween: Tween(begin: 0, end: 1),
                  duration: const Duration(milliseconds: 1100),
                  curve: Curves.easeOutCubic,
                  builder: (context, t, _) {
                    return Stack(
                      children: [
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            for (var i = 0; i < count; i++)
                              Expanded(
                                child: Align(
                                  alignment: Alignment.bottomCenter,
                                  child: Container(
                                    width: barWidth,
                                    height: maxBar *
                                        factors[i] *
                                        _studioDBarGrow(t, i, count),
                                    decoration: BoxDecoration(
                                      color: i == count - 1
                                          ? _accent
                                          : StudioDColors.ink,
                                      border: Border.all(
                                        color: StudioDColors.ink,
                                        width: 1.5,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                          ],
                        ),
                        Positioned.fill(
                          child: IgnorePointer(
                            child: CustomPaint(
                              painter: _StudioDTrendPainter(
                                factors: factors,
                                lastValue: values.last,
                                maxBar: maxBar,
                                bandHeight: bandHeight,
                                slot: slot,
                                accent: _accent,
                                progress: t,
                              ),
                            ),
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ),
              const SizedBox(height: 6),
              // Oznake nedelja — zasebni red, poravnat sa trakama.
              Row(
                children: [
                  for (var i = 0; i < count; i++)
                    Expanded(
                      child: Center(
                        child: Text(
                          mockMeasurements[i].week.toString().padLeft(2, '0'),
                          style: StudioDType.mono(
                            size: 7.5,
                            weight: FontWeight.w700,
                            color: StudioDColors.inkSoft,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 6),
              Container(height: 2, color: StudioDColors.ink),
              const SizedBox(height: 6),
              Row(
                children: [
                  Text(
                    'TREND',
                    style: StudioDType.mono(
                      size: 9,
                      weight: FontWeight.w700,
                      color: StudioDColors.inkSoft,
                      spacing: 0.5,
                    ),
                  ),
                  const Spacer(),
                  Text(
                    'MAX ${maxV.toStringAsFixed(1)} · MIN ${minV.toStringAsFixed(1)}',
                    style: StudioDType.mono(
                      size: 9,
                      weight: FontWeight.w700,
                      color: StudioDColors.inkSoft,
                    ),
                  ),
                ],
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildTable() {
    return StudioDPanel(
      padding: EdgeInsets.zero,
      child: Column(
        children: [
          // Zaglavlje
          Container(
            color: StudioDColors.ink,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
            child: Row(
              children: [
                _th('NED', flex: 12, color: StudioDColors.paper),
                _th('KG', flex: 20, color: StudioDColors.paper),
                _th('MAST%', flex: 22, color: StudioDColors.paper),
                _th('STRUK', flex: 22, color: StudioDColors.paper),
                _th('± KG', flex: 24, color: StudioDColors.yellow, right: true),
              ],
            ),
          ),
          for (var i = 0; i < mockMeasurements.length; i++)
            _buildTableRow(i),
        ],
      ),
    );
  }

  Widget _buildTableRow(int i) {
    final m = mockMeasurements[i];
    final prev = i == 0 ? null : mockMeasurements[i - 1];
    final dWeek = prev == null ? 0.0 : m.weightKg - prev.weightKg;
    final isLast = i == mockMeasurements.length - 1;
    final bg = isLast
        ? StudioDColors.yellow
        : (i.isEven ? StudioDColors.white : StudioDColors.zebra);
    return Container(
      color: bg,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
      child: Row(
        children: [
          _td(
            m.week.toString().padLeft(2, '0'),
            flex: 12,
            weight: FontWeight.w700,
          ),
          _td(m.weightKg.toStringAsFixed(1), flex: 20),
          _td(m.bodyFatPct.toStringAsFixed(1), flex: 22),
          _td(m.waistCm.toStringAsFixed(0), flex: 22),
          Expanded(
            flex: 24,
            child: Align(
              alignment: Alignment.centerRight,
              child: i == 0
                  ? Text(
                      '—',
                      style: StudioDType.mono(
                        size: 11.5,
                        weight: FontWeight.w700,
                        color: StudioDColors.inkSoft,
                      ),
                    )
                  : _deltaChip(dWeek),
            ),
          ),
        ],
      ),
    );
  }

  Widget _deltaChip(double d) {
    final down = d < 0;
    final color = down ? StudioDColors.green : StudioDColors.red;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: color,
        border: Border.all(color: StudioDColors.ink, width: 1.5),
      ),
      child: Text(
        studioDDelta(d),
        style: StudioDType.mono(
          size: 11,
          weight: FontWeight.w700,
          color: StudioDColors.ink,
        ),
      ),
    );
  }

  Widget _th(String t, {required int flex, required Color color, bool right = false}) {
    return Expanded(
      flex: flex,
      child: Text(
        t,
        textAlign: right ? TextAlign.right : TextAlign.left,
        style: StudioDType.mono(
          size: 9.5,
          weight: FontWeight.w700,
          color: color,
          spacing: 0.4,
        ),
      ),
    );
  }

  Widget _td(String t, {required int flex, FontWeight weight = FontWeight.w400}) {
    return Expanded(
      flex: flex,
      child: Text(
        t,
        style: StudioDType.mono(size: 12, weight: weight),
      ),
    );
  }
}

/// Kaskadni rast trake: stub i po indeksu kreće malo kasnije (levo → desno),
/// tako da trend-linija „raste" zajedno sa blokovima. Deljena i sa painterom
/// da geometrija vrhova bude identična.
double _studioDBarGrow(double progress, int i, int count) {
  final start = (i / count) * 0.5;
  final local = ((progress - start) / (1 - start)).clamp(0.0, 1.0);
  return Curves.easeOutCubic.transform(local);
}

/// Deljeni upgrade (Pass 1): trend-polilinija preko vrhova blokova —
/// isprekidana ink linija + kvadratni čvorovi (poslednji u akcentnoj boji),
/// sa mono vrednošću iznad poslednjeg čvora. Prati animaciju rasta traka.
class _StudioDTrendPainter extends CustomPainter {
  const _StudioDTrendPainter({
    required this.factors,
    required this.lastValue,
    required this.maxBar,
    required this.bandHeight,
    required this.slot,
    required this.accent,
    required this.progress,
  });

  final List<double> factors;
  final double lastValue;
  final double maxBar;
  final double bandHeight;
  final double slot;
  final Color accent;
  final double progress;

  @override
  void paint(Canvas canvas, Size size) {
    final count = factors.length;
    final pts = <Offset>[];
    for (var i = 0; i < count; i++) {
      final grow = _studioDBarGrow(progress, i, count);
      final barH = maxBar * factors[i] * grow;
      pts.add(Offset(slot * (i + 0.5), bandHeight - barH));
    }

    final linePaint = Paint()
      ..color = StudioDColors.ink
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;
    for (var i = 0; i < count - 1; i++) {
      if (_studioDBarGrow(progress, i + 1, count) <= 0.02) continue;
      _dash(canvas, pts[i], pts[i + 1], linePaint);
    }

    for (var i = 0; i < count; i++) {
      if (_studioDBarGrow(progress, i, count) <= 0.02) continue;
      final isLast = i == count - 1;
      final r = isLast ? 4.0 : 2.6;
      final rect = Rect.fromCenter(center: pts[i], width: r * 2, height: r * 2);
      canvas.drawRect(
        rect,
        Paint()..color = isLast ? accent : StudioDColors.paper,
      );
      canvas.drawRect(
        rect,
        Paint()
          ..color = StudioDColors.ink
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.5,
      );
    }

    // Mono vrednost iznad poslednjeg (akcentnog) čvora.
    if (_studioDBarGrow(progress, count - 1, count) > 0.35) {
      final tp = TextPainter(
        text: TextSpan(
          text: lastValue.toStringAsFixed(1),
          style: StudioDType.mono(size: 10, weight: FontWeight.w700),
        ),
        textDirection: TextDirection.ltr,
      )..layout();
      var dx = pts.last.dx - tp.width / 2;
      dx = dx.clamp(0.0, size.width - tp.width);
      final dy = (pts.last.dy - tp.height - 9).clamp(0.0, bandHeight);
      tp.paint(canvas, Offset(dx, dy));
    }
  }

  void _dash(Canvas canvas, Offset a, Offset b, Paint paint) {
    const dash = 5.0;
    const gap = 3.5;
    final total = (b - a).distance;
    if (total == 0) return;
    final dir = (b - a) / total;
    var d = 0.0;
    while (d < total) {
      final start = a + dir * d;
      final end = a + dir * math.min(d + dash, total);
      canvas.drawLine(start, end, paint);
      d += dash + gap;
    }
  }

  @override
  bool shouldRepaint(covariant _StudioDTrendPainter oldDelegate) {
    return oldDelegate.progress != progress || oldDelegate.accent != accent;
  }
}
