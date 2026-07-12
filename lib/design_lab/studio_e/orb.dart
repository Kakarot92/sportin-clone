import 'dart:math' as math;

import 'package:flutter/material.dart';

import 'theme.dart';

/// Hero orb Studija E: koncentrični neonski arc-ovi koji rotiraju
/// različitim brzinama, smerovima i nagibima elipse (pseudo-3D dubina).
/// Spor i hipnotičan — pun krug najbržeg prstena traje ~13 sekundi.
class StudioEOrb extends StatefulWidget {
  const StudioEOrb({super.key, this.size = 300, this.child});

  final double size;
  final Widget? child;

  @override
  State<StudioEOrb> createState() => _StudioEOrbState();
}

class _StudioEOrbState extends State<StudioEOrb>
    with SingleTickerProviderStateMixin {
  late final AnimationController _spin = AnimationController(
    vsync: this,
    duration: const Duration(seconds: 36),
  )..repeat();

  @override
  void dispose() {
    _spin.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: SizedBox(
        width: widget.size,
        height: widget.size,
        child: CustomPaint(
          painter: _StudioEOrbPainter(_spin),
          child: widget.child == null
              ? null
              : Center(
                  child: Padding(
                    padding: EdgeInsets.all(widget.size * 0.18),
                    child: widget.child,
                  ),
                ),
        ),
      ),
    );
  }
}

class _StudioEOrbPainter extends CustomPainter {
  _StudioEOrbPainter(this.t) : super(repaint: t);

  final Animation<double> t;

  /// Prstenovi: poluprečnik, debljina, luk (rad), brzina (obrtaja po ciklusu),
  /// vertikalna skala elipse (nagib), mešavina cyan→violet, alfa.
  static const List<_Ring> _rings = [
    _Ring(0.98, 1.4, 4.6, 1.0, 0.42, 0.0, 0.50),
    _Ring(0.86, 2.2, 3.4, -1.6, 0.62, 0.35, 0.75),
    _Ring(0.74, 2.8, 2.6, 2.2, 0.86, 0.70, 0.90),
    _Ring(0.62, 1.6, 5.2, -2.8, 1.00, 1.00, 0.55),
  ];

  @override
  void paint(Canvas canvas, Size size) {
    final center = size.center(Offset.zero);
    final r = size.shortestSide / 2;
    final phase = t.value * 2 * math.pi;
    // Spori „dah" jezgra — dva udaha po ciklusu rotacije.
    final breath = 0.5 + 0.5 * math.sin(phase * 2);

    // Najdublji plan: radijalni sjaj u jezgru.
    final corePaint = Paint()
      ..shader = RadialGradient(
        colors: [
          StudioEColors.cyan.withValues(alpha: 0.10 + 0.05 * breath),
          StudioEColors.violet.withValues(alpha: 0.05),
          StudioEColors.violet.withValues(alpha: 0),
        ],
        stops: const [0.0, 0.55, 1.0],
      ).createShader(Rect.fromCircle(center: center, radius: r * 0.72));
    canvas.drawCircle(center, r * 0.72, corePaint);

    // Statični strukturni prsten — mirna referenca za oko.
    final structure = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1
      ..color = StudioEColors.hairline;
    canvas.drawCircle(center, r * 0.68, structure);

    for (var i = 0; i < _rings.length; i++) {
      final ring = _rings[i];
      final ringR = r * ring.radius;
      final color =
          Color.lerp(StudioEColors.cyan, StudioEColors.violet, ring.mix)!;
      final start = phase * ring.speed + i * 1.7;

      canvas.save();
      canvas.translate(center.dx, center.dy);
      canvas.rotate(i * 0.5 - 0.35); // nagib ose elipse po prstenu
      canvas.scale(1, ring.tilt);

      final rect = Rect.fromCircle(center: Offset.zero, radius: ringR);
      final arcPaint = Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = ring.stroke
        ..strokeCap = StrokeCap.round
        ..shader = SweepGradient(
          endAngle: ring.sweep,
          colors: [
            color.withValues(alpha: 0),
            color.withValues(alpha: ring.alpha),
          ],
          transform: GradientRotation(start),
        ).createShader(rect);
      canvas.drawArc(rect, start, ring.sweep, false, arcPaint);

      // Glow trag i svetla „glava" samo na dva unutrašnja prstena
      // (glow disciplina).
      if (i == 1 || i == 2) {
        final glowPaint = Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = ring.stroke + 6
          ..strokeCap = StrokeCap.round
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8)
          ..color = color.withValues(alpha: 0.30);
        canvas.drawArc(rect, start + ring.sweep - 0.9, 0.9, false, glowPaint);

        final headAngle = start + ring.sweep;
        final head = Offset(
          math.cos(headAngle) * ringR,
          math.sin(headAngle) * ringR,
        );
        canvas.drawCircle(
          head,
          ring.stroke + 1.2,
          Paint()..color = color.withValues(alpha: 0.95),
        );
      }
      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(covariant _StudioEOrbPainter oldDelegate) => false;
}

class _Ring {
  const _Ring(
    this.radius,
    this.stroke,
    this.sweep,
    this.speed,
    this.tilt,
    this.mix,
    this.alpha,
  );

  final double radius;
  final double stroke;
  final double sweep;
  final double speed;
  final double tilt;
  final double mix;
  final double alpha;
}
