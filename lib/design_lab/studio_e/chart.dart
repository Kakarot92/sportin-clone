import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'theme.dart';

/// Neon area-chart merenja: linija sa glow-om, gradijent fill koji bledi
/// u transparentno, tačke na podacima i tooltip na dodir.
///
/// Prva pojava: draw-in linije (easeOutQuint). Promena serije: morph —
/// vrednosti se interpoliraju između stare i nove serije (easeInOutCubic).
class StudioEProgressChart extends StatefulWidget {
  const StudioEProgressChart({
    super.key,
    required this.values,
    required this.unit,
    this.height = 220,
  });

  /// Serija vrednosti; prosleđuj ISTU instancu liste za istu metriku
  /// (promena instance pokreće morph animaciju).
  final List<double> values;
  final String unit;
  final double height;

  @override
  State<StudioEProgressChart> createState() => _StudioEProgressChartState();
}

class _StudioEProgressChartState extends State<StudioEProgressChart>
    with SingleTickerProviderStateMixin {
  late final AnimationController _anim = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1300),
  );

  late List<double> _from = widget.values;
  bool _revealed = false;
  int? _selected;

  @override
  void initState() {
    super.initState();
    _anim.addStatusListener((status) {
      if (status == AnimationStatus.completed) _revealed = true;
    });
    _anim.forward();
  }

  @override
  void didUpdateWidget(covariant StudioEProgressChart oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!identical(oldWidget.values, widget.values)) {
      _from = oldWidget.values;
      _selected = null;
      _anim
        ..duration = const Duration(milliseconds: 650)
        ..forward(from: 0);
    }
  }

  @override
  void dispose() {
    _anim.dispose();
    super.dispose();
  }

  void _pick(Offset local, double width) {
    const pad = _StudioEChartPainter.pad;
    final plotW = width - pad.left - pad.right;
    if (plotW <= 0) return;
    final rel = ((local.dx - pad.left) / plotW).clamp(0.0, 1.0);
    final idx = (rel * (widget.values.length - 1)).round();
    setState(() => _selected = _selected == idx ? null : idx);
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        return GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTapDown: (d) => _pick(d.localPosition, width),
          child: SizedBox(
            height: widget.height,
            width: double.infinity,
            child: RepaintBoundary(
              child: AnimatedBuilder(
                animation: _anim,
                builder: (context, _) {
                  final reveal = !_revealed;
                  final curve =
                      reveal ? Curves.easeOutQuint : Curves.easeInOutCubic;
                  return CustomPaint(
                    painter: _StudioEChartPainter(
                      from: _from,
                      to: widget.values,
                      t: curve.transform(_anim.value),
                      reveal: reveal,
                      selected: _selected,
                      unit: widget.unit,
                    ),
                  );
                },
              ),
            ),
          ),
        );
      },
    );
  }
}

class _StudioEChartPainter extends CustomPainter {
  _StudioEChartPainter({
    required this.from,
    required this.to,
    required this.t,
    required this.reveal,
    required this.selected,
    required this.unit,
  });

  final List<double> from;
  final List<double> to;
  final double t;
  final bool reveal;
  final int? selected;
  final String unit;

  static const EdgeInsets pad = EdgeInsets.fromLTRB(10, 14, 10, 26);

  @override
  void paint(Canvas canvas, Size size) {
    final plot = Rect.fromLTRB(
      pad.left,
      pad.top,
      size.width - pad.right,
      size.height - pad.bottom,
    );
    final n = to.length;
    if (n < 2) return;

    var lo = double.infinity;
    var hi = double.negativeInfinity;
    for (final v in from) {
      lo = math.min(lo, v);
      hi = math.max(hi, v);
    }
    for (final v in to) {
      lo = math.min(lo, v);
      hi = math.max(hi, v);
    }
    final span = (hi - lo).abs() < 0.001 ? 1.0 : hi - lo;
    lo -= span * 0.10;
    hi += span * 0.10;

    double x(int i) => plot.left + plot.width * i / (n - 1);
    double y(double v) => plot.bottom - (v - lo) / (hi - lo) * plot.height;
    double vAt(int i) => reveal ? to[i] : from[i] + (to[i] - from[i]) * t;

    final labelStyle = GoogleFonts.ibmPlexSans(
      fontSize: 10,
      fontWeight: FontWeight.w500,
      color: StudioEColors.textDim,
    );

    // Mreža (drugi plan) + vrednosti uz linije.
    final gridPaint = Paint()
      ..color = StudioEColors.hairline.withValues(alpha: 0.55)
      ..strokeWidth = 1;
    for (var g = 0; g < 3; g++) {
      final gy = plot.top + plot.height * g / 2;
      canvas.drawLine(Offset(plot.left, gy), Offset(plot.right, gy), gridPaint);
      final val = hi - (hi - lo) * g / 2;
      final tp = TextPainter(
        text: TextSpan(text: StudioEFmt.decimal(val), style: labelStyle),
        textDirection: TextDirection.ltr,
      )..layout();
      tp.paint(canvas, Offset(plot.left, gy - tp.height - 3));
    }

    // Oznake nedelja na x-osi.
    for (final i in const [0, 3, 7, 11]) {
      if (i >= n) continue;
      final tp = TextPainter(
        text: TextSpan(text: 'N${i + 1}', style: labelStyle),
        textDirection: TextDirection.ltr,
      )..layout();
      tp.paint(canvas, Offset(x(i) - tp.width / 2, plot.bottom + 8));
    }

    // Glatka linija kroz tačke (horizontalne tangente — bez prebačaja).
    final line = Path()..moveTo(x(0), y(vAt(0)));
    for (var i = 0; i < n - 1; i++) {
      final x1 = x(i);
      final y2 = y(vAt(i + 1));
      final x2 = x(i + 1);
      final cx = (x1 + x2) / 2;
      line.cubicTo(cx, y(vAt(i)), cx, y2, x2, y2);
    }

    final revealT = reveal ? t : 1.0;

    // Fill koji bledi u transparentno, klipovan na otkriveni deo.
    final fill = Path.from(line)
      ..lineTo(x(n - 1), plot.bottom)
      ..lineTo(x(0), plot.bottom)
      ..close();
    canvas.save();
    canvas.clipRect(
      Rect.fromLTRB(0, 0, plot.left + plot.width * revealT + 1, size.height),
    );
    final fillPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          StudioEColors.cyan.withValues(alpha: 0.20),
          StudioEColors.cyan.withValues(alpha: 0),
        ],
      ).createShader(plot);
    canvas.drawPath(fill, fillPaint);

    // Neon: blurovan glow ispod, oštra gradient linija preko.
    final drawn = revealT >= 1 ? line : _trim(line, revealT);
    final glowPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 6
      ..strokeCap = StrokeCap.round
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 7)
      ..color = StudioEColors.cyan.withValues(alpha: 0.35);
    canvas.drawPath(drawn, glowPaint);

    final linePaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.4
      ..strokeCap = StrokeCap.round
      ..shader = const LinearGradient(
        colors: [StudioEColors.cyan, StudioEColors.violet],
      ).createShader(plot);
    canvas.drawPath(drawn, linePaint);
    canvas.restore();

    // Tačke podataka.
    final dotFill = Paint()..color = StudioEColors.bg;
    for (var i = 0; i < n; i++) {
      if (x(i) > plot.left + plot.width * revealT + 0.5) break;
      final c = Offset(x(i), y(vAt(i)));
      final col =
          Color.lerp(StudioEColors.cyan, StudioEColors.violet, i / (n - 1))!;
      canvas.drawCircle(c, 3.4, dotFill);
      canvas.drawCircle(
        c,
        3.4,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.6
          ..color = col,
      );
    }

    // Poslednja tačka nosi glow — trenutno stanje.
    if (revealT >= 1) {
      final last = Offset(x(n - 1), y(vAt(n - 1)));
      canvas.drawCircle(
        last,
        8,
        Paint()
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8)
          ..color = StudioEColors.violet.withValues(alpha: 0.55),
      );
      canvas.drawCircle(last, 3.6, Paint()..color = StudioEColors.text);
    }

    // Tooltip za izabranu nedelju.
    final sel = selected;
    if (sel != null && revealT >= 1 && sel < n) {
      _tooltip(canvas, size, plot, sel, Offset(x(sel), y(vAt(sel))));
    }
  }

  void _tooltip(Canvas canvas, Size size, Rect plot, int i, Offset p) {
    final guide = Paint()
      ..color = StudioEColors.cyan.withValues(alpha: 0.35)
      ..strokeWidth = 1;
    canvas.drawLine(Offset(p.dx, plot.top), Offset(p.dx, plot.bottom), guide);
    canvas.drawCircle(
      p,
      6,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2
        ..color = StudioEColors.cyan,
    );

    final tp = TextPainter(
      text: TextSpan(
        text: '${StudioEFmt.decimal(to[i])} $unit',
        style: GoogleFonts.ibmPlexSans(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: StudioEColors.text,
        ),
        children: [
          TextSpan(
            text: '  ·  ${i + 1}. nedelja',
            style: GoogleFonts.ibmPlexSans(
              fontSize: 11,
              fontWeight: FontWeight.w500,
              color: StudioEColors.textDim,
            ),
          ),
        ],
      ),
      textDirection: TextDirection.ltr,
    )..layout();

    final w = tp.width + 20;
    const h = 30.0;
    final left = (p.dx - w / 2).clamp(2.0, size.width - w - 2.0);
    var top = p.dy - h - 14;
    if (top < 0) top = p.dy + 14;
    final rrect = RRect.fromRectAndRadius(
      Rect.fromLTWH(left, top, w, h),
      const Radius.circular(9),
    );
    canvas.drawRRect(rrect, Paint()..color = StudioEColors.layer2);
    canvas.drawRRect(
      rrect,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1
        ..color = StudioEColors.cyan.withValues(alpha: 0.5),
    );
    tp.paint(canvas, Offset(left + 10, top + (h - tp.height) / 2));
  }

  Path _trim(Path p, double f) {
    final out = Path();
    for (final m in p.computeMetrics()) {
      out.addPath(m.extractPath(0, m.length * f), Offset.zero);
    }
    return out;
  }

  @override
  bool shouldRepaint(covariant _StudioEChartPainter old) =>
      old.t != t ||
      old.selected != selected ||
      !identical(old.to, to) ||
      !identical(old.from, from) ||
      old.reveal != reveal;
}
