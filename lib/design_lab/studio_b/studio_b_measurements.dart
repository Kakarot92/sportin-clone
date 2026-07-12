import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../mock_data.dart';
import 'studio_b_glass.dart';
import 'studio_b_tokens.dart';

/// Merenja — data-viz momenat studija. Veliki progres-prsten (koliko je
/// pređeno ka ciljnoj težini) i glatka area-chart linija napretka kroz 12
/// nedelja, obe animirane pri ulasku.
class StudioBMeasurementsTab extends StatefulWidget {
  const StudioBMeasurementsTab({super.key});

  @override
  State<StudioBMeasurementsTab> createState() =>
      _StudioBMeasurementsTabState();
}

class _StudioBMeasurementsTabState extends State<StudioBMeasurementsTab>
    with TickerProviderStateMixin {
  late final AnimationController _draw = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1400),
  );
  late final Animation<double> _t =
      CurvedAnimation(parent: _draw, curve: Curves.easeOutCubic);

  // Interaktivni izbor tačke na grafikonu (počinje na poslednjoj nedelji).
  int _selected = mockMeasurements.length - 1;

  static const double _goalWeight = 86.0;

  @override
  void initState() {
    super.initState();
    _draw.forward();
  }

  @override
  void dispose() {
    _draw.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final first = mockMeasurements.first;
    final last = mockMeasurements.last;
    final lostKg = first.weightKg - last.weightKg;
    final totalGoal = first.weightKg - _goalWeight;
    final progress = (lostKg / totalGoal).clamp(0.0, 1.0);
    final sel = mockMeasurements[_selected];

    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 520),
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 14, 20, 120),
          children: [
            StudioBReveal(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Merenja',
                    style: StudioBTokens.display(
                      size: 27,
                      weight: FontWeight.w700,
                      spacing: -0.5,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    mockUser.goal,
                    style: StudioBTokens.body(
                      size: 13.5,
                      weight: FontWeight.w600,
                      color: StudioBTokens.inkSoft,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            StudioBReveal(
              delayMs: 90,
              child: _ringCard(first.weightKg, last.weightKg, lostKg, progress),
            ),
            const SizedBox(height: 16),
            StudioBReveal(delayMs: 170, child: _metricsRow(first, last)),
            const SizedBox(height: 24),
            StudioBSectionHeader(
              title: 'Težina kroz 12 nedelja',
              trailing: StudioBChip(
                label: 'nedelja ${sel.week}',
                background: StudioBTokens.violet.withValues(alpha: 0.12),
                foreground: StudioBTokens.violetDeep,
              ),
            ),
            StudioBReveal(delayMs: 250, child: _chartCard(sel)),
          ],
        ),
      ),
    );
  }

  Widget _ringCard(double start, double now, double lost, double progress) {
    return StudioBGlass(
      padding: const EdgeInsets.fromLTRB(22, 22, 22, 22),
      child: Row(
        children: [
          SizedBox(
            width: 132,
            height: 132,
            child: AnimatedBuilder(
              animation: _t,
              builder: (_, _) => CustomPaint(
                painter: _ProgressRingPainter(progress * _t.value),
                child: Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        '${(progress * _t.value * 100).round()}%',
                        style: StudioBTokens.display(
                          size: 26,
                          weight: FontWeight.w700,
                        ),
                      ),
                      Text(
                        'ka cilju',
                        style: StudioBTokens.label(size: 10.5),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(width: 22),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Trenutna težina',
                  style: StudioBTokens.label(size: 11.5, spacing: 0.3),
                ),
                const SizedBox(height: 4),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      studioBDecimal(now),
                      style: StudioBTokens.display(
                        size: 34,
                        weight: FontWeight.w700,
                        spacing: -1,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Padding(
                      padding: const EdgeInsets.only(bottom: 5),
                      child: Text(
                        'kg',
                        style: StudioBTokens.body(
                          size: 15,
                          weight: FontWeight.w700,
                          color: StudioBTokens.inkSoft,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: StudioBTokens.mint.withValues(alpha: 0.14),
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.trending_down_rounded,
                        size: 15,
                        color: StudioBTokens.mintDeep,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '${studioBDecimal(lost)} kg za 12 nedelja',
                        style: StudioBTokens.label(
                          size: 11.5,
                          color: StudioBTokens.mintDeep,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Start ${studioBDecimal(start)} · cilj '
                  '${studioBDecimal(_goalWeight)} kg',
                  style: StudioBTokens.label(size: 11),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _metricsRow(MockMeasurement first, MockMeasurement last) {
    return Row(
      children: [
        Expanded(
          child: _MetricCard(
            label: 'Masnoće',
            value: '${studioBDecimal(last.bodyFatPct)}%',
            delta: studioBDelta(last.bodyFatPct - first.bodyFatPct),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _MetricCard(
            label: 'Struk',
            value: '${studioBDecimal(last.waistCm, decimals: 0)} cm',
            delta: studioBDelta(last.waistCm - first.waistCm, decimals: 0),
          ),
        ),
      ],
    );
  }

  Widget _chartCard(MockMeasurement sel) {
    return StudioBGlass(
      padding: const EdgeInsets.fromLTRB(14, 18, 14, 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Očitavanje izabrane tačke.
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 6),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  studioBDecimal(sel.weightKg),
                  style: StudioBTokens.display(
                    size: 24,
                    weight: FontWeight.w700,
                  ),
                ),
                const SizedBox(width: 3),
                Padding(
                  padding: const EdgeInsets.only(bottom: 3),
                  child: Text(
                    'kg',
                    style: StudioBTokens.body(
                      size: 13,
                      weight: FontWeight.w700,
                      color: StudioBTokens.inkSoft,
                    ),
                  ),
                ),
                const Spacer(),
                Text(
                  'masnoće ${studioBDecimal(sel.bodyFatPct)}%',
                  style: StudioBTokens.label(size: 11.5),
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),
          LayoutBuilder(
            builder: (context, constraints) {
              final width = constraints.maxWidth;
              const height = 150.0;
              return GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTapDown: (d) => _pick(d.localPosition.dx, width),
                onHorizontalDragUpdate: (d) =>
                    _pick(d.localPosition.dx, width),
                child: AnimatedBuilder(
                  animation: _t,
                  builder: (_, _) => CustomPaint(
                    size: Size(width, height),
                    painter: _AreaChartPainter(
                      values: [for (final m in mockMeasurements) m.weightKg],
                      progress: _t.value,
                      selected: _selected,
                    ),
                  ),
                ),
              );
            },
          ),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('ned. 1', style: StudioBTokens.label(size: 10)),
                Text('ned. 6', style: StudioBTokens.label(size: 10)),
                Text('ned. 12', style: StudioBTokens.label(size: 10)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _pick(double dx, double width) {
    final n = mockMeasurements.length;
    final idx = ((dx / width) * (n - 1)).round().clamp(0, n - 1);
    if (idx != _selected) {
      setState(() => _selected = idx);
    }
  }
}

class _MetricCard extends StatelessWidget {
  const _MetricCard({
    required this.label,
    required this.value,
    required this.delta,
  });

  final String label;
  final String value;
  final String delta;

  @override
  Widget build(BuildContext context) {
    return StudioBGlass(
      radius: 24,
      opacity: 0.64,
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: StudioBTokens.label(size: 11.5, spacing: 0.3)),
          const SizedBox(height: 6),
          Text(
            value,
            style: StudioBTokens.display(size: 22, weight: FontWeight.w700),
          ),
          const SizedBox(height: 6),
          Row(
            children: [
              const Icon(
                Icons.arrow_downward_rounded,
                size: 13,
                color: StudioBTokens.mintDeep,
              ),
              const SizedBox(width: 2),
              Text(
                delta,
                style: StudioBTokens.label(
                  size: 12,
                  color: StudioBTokens.mintDeep,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// Progres-prsten: track + gradijent luk (violet→mint), sa tačkom na kraju.
class _ProgressRingPainter extends CustomPainter {
  const _ProgressRingPainter(this.value);

  final double value;

  @override
  void paint(Canvas canvas, Size size) {
    final center = size.center(Offset.zero);
    final stroke = 13.0;
    final radius = size.shortestSide / 2 - stroke / 2 - 2;
    final rect = Rect.fromCircle(center: center, radius: radius);
    const start = -math.pi / 2;
    final sweep = 2 * math.pi * value.clamp(0.0, 1.0);

    canvas.drawCircle(
      center,
      radius,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = stroke
        ..color = Colors.white.withValues(alpha: 0.55),
    );

    if (value <= 0) {
      return;
    }

    canvas.drawArc(
      rect,
      start,
      sweep,
      false,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = stroke
        ..strokeCap = StrokeCap.round
        ..shader = const SweepGradient(
          startAngle: 0,
          endAngle: 2 * math.pi,
          colors: [
            StudioBTokens.violet,
            StudioBTokens.mint,
            StudioBTokens.violet,
          ],
          transform: GradientRotation(-math.pi / 2),
        ).createShader(rect),
    );

    // Tačka na vrhu luka.
    final end = start + sweep;
    final dot = Offset(
      center.dx + radius * math.cos(end),
      center.dy + radius * math.sin(end),
    );
    canvas.drawCircle(dot, stroke / 2 + 1.5, Paint()..color = Colors.white);
    canvas.drawCircle(dot, stroke / 2 - 1.5, Paint()..color = StudioBTokens.mint);
  }

  @override
  bool shouldRepaint(covariant _ProgressRingPainter oldDelegate) {
    return oldDelegate.value != value;
  }
}

/// Glatka area-chart linija (Catmull-Rom → Bézier) sa gradijent ispunom,
/// horizontalnim mrežnim linijama i markerom izabrane nedelje.
class _AreaChartPainter extends CustomPainter {
  const _AreaChartPainter({
    required this.values,
    required this.progress,
    required this.selected,
  });

  final List<double> values;
  final double progress;
  final int selected;

  @override
  void paint(Canvas canvas, Size size) {
    if (values.length < 2) {
      return;
    }
    const padTop = 10.0;
    const padBottom = 6.0;
    final chartH = size.height - padTop - padBottom;

    final minV = values.reduce(math.min) - 0.6;
    final maxV = values.reduce(math.max) + 0.6;
    final span = (maxV - minV) == 0 ? 1.0 : maxV - minV;

    double xAt(int i) => i / (values.length - 1) * size.width;
    double yAt(double v) => padTop + (1 - (v - minV) / span) * chartH;

    // Mrežne linije.
    final grid = Paint()
      ..color = StudioBTokens.ink.withValues(alpha: 0.06)
      ..strokeWidth = 1;
    for (var i = 0; i < 4; i++) {
      final y = padTop + chartH * i / 3;
      canvas.drawLine(Offset(0, y), Offset(size.width, y), grid);
    }

    final pts = <Offset>[
      for (var i = 0; i < values.length; i++) Offset(xAt(i), yAt(values[i])),
    ];

    // Glatka putanja.
    final line = Path()..moveTo(pts.first.dx, pts.first.dy);
    for (var i = 0; i < pts.length - 1; i++) {
      final p0 = i > 0 ? pts[i - 1] : pts[i];
      final p1 = pts[i];
      final p2 = pts[i + 1];
      final p3 = i + 2 < pts.length ? pts[i + 2] : p2;
      final c1 = p1 + (p2 - p0) / 6;
      final c2 = p2 - (p3 - p1) / 6;
      line.cubicTo(c1.dx, c1.dy, c2.dx, c2.dy, p2.dx, p2.dy);
    }

    // Progresivno otkrivanje po širini (clip po x).
    final revealW = size.width * progress.clamp(0.0, 1.0);
    canvas.save();
    canvas.clipRect(Rect.fromLTWH(0, 0, revealW, size.height));

    // Ispuna ispod linije.
    final fill = Path.from(line)
      ..lineTo(pts.last.dx, size.height)
      ..lineTo(pts.first.dx, size.height)
      ..close();
    canvas.drawPath(
      fill,
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            StudioBTokens.violet.withValues(alpha: 0.26),
            StudioBTokens.mint.withValues(alpha: 0.04),
          ],
        ).createShader(Offset.zero & size),
    );

    canvas.drawPath(
      line,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round
        ..shader = const LinearGradient(
          colors: [StudioBTokens.violet, StudioBTokens.mint],
        ).createShader(Offset.zero & size),
    );
    canvas.restore();

    // Marker izabrane nedelje (samo kad ga je otkrivanje dostiglo).
    if (progress > 0.98) {
      final mp = pts[selected.clamp(0, pts.length - 1)];
      final guide = Paint()
        ..color = StudioBTokens.violet.withValues(alpha: 0.30)
        ..strokeWidth = 1.4;
      canvas.drawLine(
        Offset(mp.dx, padTop),
        Offset(mp.dx, size.height - padBottom),
        guide,
      );
      canvas.drawCircle(mp, 7, Paint()..color = Colors.white);
      canvas.drawCircle(
        mp,
        7,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 3
          ..color = StudioBTokens.violet,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _AreaChartPainter oldDelegate) {
    return oldDelegate.progress != progress ||
        oldDelegate.selected != selected;
  }
}
