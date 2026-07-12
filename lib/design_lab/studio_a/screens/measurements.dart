import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../mock_data.dart';
import '../theme.dart';
import '../widgets/effects.dart';

/// Metrika koja se prikazuje na grafikonu.
enum _Metric { weight, fat, waist }

extension on _Metric {
  String get title => switch (this) {
        _Metric.weight => 'TEŽINA',
        _Metric.fat => '% MASTI',
        _Metric.waist => 'STRUK',
      };

  String get unit => switch (this) {
        _Metric.weight => 'kg',
        _Metric.fat => '%',
        _Metric.waist => 'cm',
      };

  double valueAt(MockMeasurement m) => switch (this) {
        _Metric.weight => m.weightKg,
        _Metric.fat => m.bodyFatPct,
        _Metric.waist => m.waistCm,
      };
}

/// Merenja — trenutna kilaža je NAJVEĆI element ekrana; grafikon je
/// CustomPainter linija sa volt glow tačkama i scrub interakcijom.
class StudioAMeasurementsScreen extends StatefulWidget {
  const StudioAMeasurementsScreen({super.key});

  @override
  State<StudioAMeasurementsScreen> createState() =>
      _StudioAMeasurementsScreenState();
}

class _StudioAMeasurementsScreenState extends State<StudioAMeasurementsScreen> {
  _Metric _metric = _Metric.weight;
  int _week = mockMeasurements.length - 1;

  List<double> get _values =>
      [for (final m in mockMeasurements) _metric.valueAt(m)];

  void _selectWeek(int i) {
    final clamped = i.clamp(0, mockMeasurements.length - 1);
    if (clamped == _week) return;
    HapticFeedback.selectionClick();
    setState(() => _week = clamped);
  }

  void _selectMetric(_Metric m) {
    if (m == _metric) return;
    HapticFeedback.selectionClick();
    setState(() => _metric = m);
  }

  @override
  Widget build(BuildContext context) {
    final first = mockMeasurements.first;
    final last = mockMeasurements.last;
    final lostKg = first.weightKg - last.weightKg;
    final selected = mockMeasurements[_week];

    return SafeArea(
      bottom: false,
      child: SingleChildScrollView(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 560),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 20),
                  StudioAReveal(
                    index: 0,
                    child: Text(
                      'NAPREDAK — 12 NEDELJA',
                      style: StudioATheme.label(
                        color: StudioATheme.volt,
                        size: 10.5,
                        tracking: 3,
                      ),
                    ),
                  ),
                  const SizedBox(height: 6),
                  StudioAReveal(
                    index: 1,
                    child:
                        Text('MERENJA', style: StudioATheme.display(size: 38)),
                  ),
                  const SizedBox(height: 18),
                  // Hero broj: trenutna kilaža „topi se" od početne vrednosti.
                  StudioAReveal(
                    index: 2,
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Flexible(
                          child: FittedBox(
                            fit: BoxFit.scaleDown,
                            alignment: Alignment.centerLeft,
                            child: StudioACountUp(
                              value: last.weightKg,
                              from: first.weightKg,
                              decimals: 1,
                              duration: const Duration(milliseconds: 1600),
                              style: StudioATheme.display(size: 96),
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(bottom: 14, left: 8),
                          child: Text(
                            'KG',
                            style: StudioATheme.display(
                              size: 22,
                              color: StudioATheme.inkDim,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 10),
                  StudioAReveal(
                    index: 3,
                    child: Row(
                      children: [
                        _DeltaChip(text: '−${studioADec(lostKg)} KG OD POČETKA'),
                        const SizedBox(width: 10),
                        Text(
                          'CILJ: ${mockUser.goal.toUpperCase()}',
                          style: StudioATheme.label(
                            size: 8.5,
                            tracking: 1.6,
                            color: StudioATheme.inkDim,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  StudioAReveal(index: 4, child: _metricTabs()),
                  const SizedBox(height: 16),
                  // Readout izabrane nedelje.
                  StudioAReveal(
                    index: 5,
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          'NEDELJA ${selected.week}',
                          style: StudioATheme.label(
                            size: 10,
                            color: StudioATheme.volt,
                            tracking: 2.4,
                          ),
                        ),
                        const Spacer(),
                        Text(
                          '${studioADec(_metric.valueAt(selected))} ${_metric.unit}',
                          style: StudioATheme.display(size: 20),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 8),
                  StudioAReveal(
                    index: 6,
                    child: _Chart(
                      key: ValueKey(_metric),
                      values: _values,
                      selected: _week,
                      onScrub: _selectWeek,
                    ),
                  ),
                  const SizedBox(height: 6),
                  StudioAReveal(
                    index: 7,
                    child: Text(
                      'Prevuci prstom preko grafikona za pregled po nedeljama.',
                      style: StudioATheme.body(
                        size: 11.5,
                        color: StudioATheme.inkDim,
                      ),
                    ),
                  ),
                  const SizedBox(height: 22),
                  const StudioAReveal(
                    index: 8,
                    child: StudioASectionLabel('Ostale metrike'),
                  ),
                  const SizedBox(height: 14),
                  StudioAReveal(
                    index: 9,
                    child: Row(
                      children: [
                        Expanded(
                          child: _MetricTile(
                            label: '% MASTI',
                            value: last.bodyFatPct,
                            delta: last.bodyFatPct - first.bodyFatPct,
                            unit: '%',
                            active: _metric == _Metric.fat,
                            onTap: () => _selectMetric(_Metric.fat),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _MetricTile(
                            label: 'STRUK',
                            value: last.waistCm,
                            delta: last.waistCm - first.waistCm,
                            unit: 'cm',
                            active: _metric == _Metric.waist,
                            onTap: () => _selectMetric(_Metric.waist),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 32),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _metricTabs() {
    return Row(
      children: [
        for (final m in _Metric.values) ...[
          _MetricTab(
            label: m.title,
            active: m == _metric,
            onTap: () => _selectMetric(m),
          ),
          if (m != _Metric.values.last) const SizedBox(width: 6),
        ],
      ],
    );
  }
}

class _MetricTab extends StatelessWidget {
  const _MetricTab({
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
      selected: active,
      button: true,
      child: InkWell(
        onTap: onTap,
        child: TweenAnimationBuilder<double>(
          tween: Tween(begin: 0, end: active ? 1 : 0),
          duration: const Duration(milliseconds: 240),
          curve: Curves.easeOutCubic,
          builder: (context, t, _) {
            return Container(
              padding: const EdgeInsets.symmetric(horizontal: 14),
              height: 48,
              alignment: Alignment.center,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    label,
                    style: StudioATheme.label(
                      size: 10.5,
                      tracking: 2,
                      color: Color.lerp(
                        StudioATheme.inkDim,
                        StudioATheme.volt,
                        t,
                      )!,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Transform(
                    transform: Matrix4.skewX(-0.5),
                    alignment: Alignment.center,
                    child: Container(
                      height: 3,
                      width: 28 * t,
                      color: StudioATheme.volt.withValues(alpha: t),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}

class _DeltaChip extends StatelessWidget {
  const _DeltaChip({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Transform(
      transform: Matrix4.skewX(-0.10),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        color: StudioATheme.volt,
        child: Transform(
          transform: Matrix4.skewX(0.10),
          child: Text(
            text,
            style: GoogleFonts.archivoBlack(
              fontSize: 10,
              color: StudioATheme.bg,
              letterSpacing: 1.2,
            ),
          ),
        ),
      ),
    );
  }
}

// ── Grafikon ─────────────────────────────────────────────────────────────

class _Chart extends StatelessWidget {
  const _Chart({
    super.key,
    required this.values,
    required this.selected,
    required this.onScrub,
  });

  final List<double> values;
  final int selected;
  final ValueChanged<int> onScrub;

  void _handle(Offset local, double width) {
    const padL = _ChartPainter.padLeft;
    const padR = _ChartPainter.padRight;
    final plotW = width - padL - padR;
    if (plotW <= 0) return;
    final t = ((local.dx - padL) / plotW).clamp(0.0, 1.0);
    onScrub((t * (values.length - 1)).round());
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        return GestureDetector(
          onTapDown: (d) => _handle(d.localPosition, width),
          onHorizontalDragStart: (d) => _handle(d.localPosition, width),
          onHorizontalDragUpdate: (d) => _handle(d.localPosition, width),
          child: TweenAnimationBuilder<double>(
            tween: Tween(begin: 0, end: 1),
            duration: const Duration(milliseconds: 1300),
            curve: Curves.easeOutCubic,
            builder: (context, progress, _) {
              return CustomPaint(
                painter: _ChartPainter(
                  values: values,
                  progress: progress,
                  selected: selected,
                ),
                size: Size(width, 216),
              );
            },
          ),
        );
      },
    );
  }
}

class _ChartPainter extends CustomPainter {
  _ChartPainter({
    required this.values,
    required this.progress,
    required this.selected,
  });

  static const double padLeft = 8;
  static const double padRight = 44;
  static const double padTop = 16;
  static const double padBottom = 26;

  final List<double> values;
  final double progress;
  final int selected;

  @override
  void paint(Canvas canvas, Size size) {
    final n = values.length;
    if (n < 2) return;

    final plotW = size.width - padLeft - padRight;
    final plotH = size.height - padTop - padBottom;
    var min = values.reduce((a, b) => a < b ? a : b);
    var max = values.reduce((a, b) => a > b ? a : b);
    final pad = (max - min) * 0.14 + 0.001;
    min -= pad;
    max += pad;

    Offset point(int i) {
      final x = padLeft + plotW * i / (n - 1);
      final y = padTop + plotH * (1 - (values[i] - min) / (max - min));
      return Offset(x, y);
    }

    // Mreža — 4 hairline linije + vrednosti min/max desno.
    final grid = Paint()
      ..color = StudioATheme.line.withValues(alpha: 0.8)
      ..strokeWidth = 1;
    for (var g = 0; g < 4; g++) {
      final y = padTop + plotH * g / 3;
      canvas.drawLine(Offset(padLeft, y), Offset(size.width - padRight, y), grid);
    }
    _text(
      canvas,
      studioADec(values.reduce((a, b) => a > b ? a : b)),
      Offset(size.width - padRight + 6, padTop - 5),
      StudioATheme.inkDim,
    );
    _text(
      canvas,
      studioADec(values.reduce((a, b) => a < b ? a : b)),
      Offset(size.width - padRight + 6, padTop + plotH - 5),
      StudioATheme.inkDim,
    );

    // Putanja kroz tačke — glatka (kvadratne krive kroz sredine segmenata).
    final path = Path()..moveTo(point(0).dx, point(0).dy);
    for (var i = 1; i < n; i++) {
      final prev = point(i - 1);
      final curr = point(i);
      final mid = Offset((prev.dx + curr.dx) / 2, (prev.dy + curr.dy) / 2);
      path.quadraticBezierTo(prev.dx, prev.dy, mid.dx, mid.dy);
    }
    path.lineTo(point(n - 1).dx, point(n - 1).dy);

    // Delimično iscrtavanje po progressu (PathMetric).
    final metric = path.computeMetrics().first;
    final partial = metric.extractPath(0, metric.length * progress);

    // Volt fill ispod linije — clip na otkriveni deo.
    final revealX = padLeft + plotW * progress;
    canvas.save();
    canvas.clipRect(Rect.fromLTRB(0, 0, revealX, size.height));
    final fillPath = Path.from(path)
      ..lineTo(point(n - 1).dx, padTop + plotH)
      ..lineTo(point(0).dx, padTop + plotH)
      ..close();
    canvas.drawPath(
      fillPath,
      Paint()
        ..shader = ui.Gradient.linear(
          Offset(0, padTop),
          Offset(0, padTop + plotH),
          [
            StudioATheme.volt.withValues(alpha: 0.14),
            StudioATheme.volt.withValues(alpha: 0.0),
          ],
        ),
    );
    canvas.restore();

    // Glow ispod linije, pa oštra volt linija.
    canvas.drawPath(
      partial,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 7
        ..strokeCap = StrokeCap.round
        ..color = StudioATheme.volt.withValues(alpha: 0.30)
        ..maskFilter = const ui.MaskFilter.blur(ui.BlurStyle.normal, 6),
    );
    canvas.drawPath(
      partial,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.4
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round
        ..color = StudioATheme.volt,
    );

    // Tačke — pojavljuju se kako linija stiže do njih.
    for (var i = 0; i < n; i++) {
      if (i / (n - 1) > progress + 0.001) continue;
      final p = point(i);
      final isSel = i == selected;
      if (isSel) {
        // Vertikalni vodič + glow prsten na izabranoj nedelji.
        final guide = Paint()
          ..color = StudioATheme.volt.withValues(alpha: 0.35)
          ..strokeWidth = 1;
        canvas.drawLine(
          Offset(p.dx, padTop),
          Offset(p.dx, padTop + plotH),
          guide,
        );
        canvas.drawCircle(
          p,
          10,
          Paint()
            ..color = StudioATheme.volt.withValues(alpha: 0.20)
            ..maskFilter = const ui.MaskFilter.blur(ui.BlurStyle.normal, 6),
        );
        canvas.drawCircle(
          p,
          5.5,
          Paint()
            ..style = PaintingStyle.stroke
            ..strokeWidth = 1.6
            ..color = StudioATheme.volt,
        );
        canvas.drawCircle(p, 3, Paint()..color = StudioATheme.volt);
      } else {
        canvas.drawCircle(
          p,
          2.4,
          Paint()..color = StudioATheme.volt.withValues(alpha: 0.85),
        );
      }
    }

    // X ose: N1, N4, N8, N12 + izabrana.
    for (final i in {0, 3, 7, n - 1, selected}) {
      final p = point(i);
      _text(
        canvas,
        'N${i + 1}',
        Offset(p.dx - 8, padTop + plotH + 10),
        i == selected ? StudioATheme.volt : StudioATheme.inkDim,
        bold: i == selected,
      );
    }
  }

  void _text(Canvas canvas, String s, Offset at, Color color,
      {bool bold = false}) {
    final tp = TextPainter(
      text: TextSpan(
        text: s,
        style: GoogleFonts.interTight(
          fontSize: 9.5,
          color: color,
          fontWeight: bold ? FontWeight.w800 : FontWeight.w600,
          letterSpacing: 0.6,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    tp.paint(canvas, at);
    tp.dispose();
  }

  @override
  bool shouldRepaint(_ChartPainter oldDelegate) =>
      oldDelegate.progress != progress ||
      oldDelegate.selected != selected ||
      oldDelegate.values != values;
}

// ── Sekundarne metrike ───────────────────────────────────────────────────

class _MetricTile extends StatelessWidget {
  const _MetricTile({
    required this.label,
    required this.value,
    required this.delta,
    required this.unit,
    required this.active,
    required this.onTap,
  });

  final String label;
  final double value;
  final double delta;
  final String unit;
  final bool active;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      selected: active,
      child: InkWell(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 240),
          curve: Curves.easeOutCubic,
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
          decoration: BoxDecoration(
            color: StudioATheme.surface,
            border: Border(
              left: BorderSide(
                color: active ? StudioATheme.volt : StudioATheme.line,
                width: active ? 3 : 1,
              ),
              top: const BorderSide(color: StudioATheme.line),
              right: const BorderSide(color: StudioATheme.line),
              bottom: const BorderSide(color: StudioATheme.line),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: StudioATheme.label(
                  size: 9.5,
                  tracking: 2,
                  color: active ? StudioATheme.volt : StudioATheme.inkDim,
                ),
              ),
              const SizedBox(height: 8),
              FittedBox(
                fit: BoxFit.scaleDown,
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    StudioACountUp(
                      value: value,
                      decimals: 1,
                      style: StudioATheme.display(size: 28),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(left: 4, bottom: 3),
                      child: Text(
                        unit,
                        style: StudioATheme.label(
                          size: 10,
                          color: StudioATheme.inkDim,
                          tracking: 1,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 6),
              Text(
                '${delta > 0 ? '+' : '−'}${studioADec(delta.abs())} $unit / 12 ned.',
                style: StudioATheme.body(
                  size: 11.5,
                  color: StudioATheme.volt,
                  weight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
