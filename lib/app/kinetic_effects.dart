import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'theme.dart';

// ═══════════════════════════════════════════════════════════════════════
//  Kinetik effects library — speed-lines, marquee, count-up, reveal,
//  diagonal clip, ghost outline text, pulse dot, initials avatar.
//  All procedural, no assets. Ported from design_lab/studio_a/widgets/effects.dart.
// ═══════════════════════════════════════════════════════════════════════

/// Tilt angle for kinetic elements (−2°).
const double kTilt = -0.0349; // radians

// ── Screen transition ────────────────────────────────────────────────────

/// Directed screen transition: slide + fade, easeOutCubic / easeInCubic.
Route<T> kineticRoute<T>(Widget page) {
  return PageRouteBuilder<T>(
    transitionDuration: const Duration(milliseconds: 420),
    reverseTransitionDuration: const Duration(milliseconds: 300),
    pageBuilder: (context, animation, secondaryAnimation) => page,
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      final curved = CurvedAnimation(
        parent: animation,
        curve: Curves.easeOutCubic,
        reverseCurve: Curves.easeInCubic,
      );
      return FadeTransition(
        opacity: curved,
        child: SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(0.08, 0),
            end: Offset.zero,
          ).animate(curved),
          child: child,
        ),
      );
    },
  );
}

// ── Speed-lines background ───────────────────────────────────────────────

/// Sparse thin lines in the direction of motion — procedural speed texture.
class SpeedLines extends StatelessWidget {
  const SpeedLines({
    super.key,
    this.density = 26,
    this.seed = 7,
    this.opacity = 1.0,
    this.voltShare = 0.14,
  });

  /// Number of lines.
  final int density;
  final int seed;
  final double opacity;

  /// Fraction of lines drawn in volt colour (rest are in line colour).
  final double voltShare;

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: CustomPaint(
        painter: _SpeedLinesPainter(
          density: density,
          seed: seed,
          opacity: opacity,
          voltShare: voltShare,
        ),
        size: Size.infinite,
      ),
    );
  }
}

class _SpeedLinesPainter extends CustomPainter {
  _SpeedLinesPainter({
    required this.density,
    required this.seed,
    required this.opacity,
    required this.voltShare,
  });

  final int density;
  final int seed;
  final double opacity;
  final double voltShare;

  @override
  void paint(Canvas canvas, Size size) {
    final rnd = math.Random(seed);
    // Gentle downward-right slope: impression of forward motion.
    const slope = -0.07;
    for (var i = 0; i < density; i++) {
      final y = rnd.nextDouble() * size.height;
      final x = rnd.nextDouble() * size.width;
      final len = 30.0 + rnd.nextDouble() * 130.0;
      final isVolt = rnd.nextDouble() < voltShare;
      final alpha =
          (isVolt
                  ? 0.20 + rnd.nextDouble() * 0.25
                  : 0.5 + rnd.nextDouble() * 0.5) *
              opacity;
      final paint = Paint()
        ..color = (isVolt ? kVolt : kLineDark).withValues(alpha: alpha)
        ..strokeWidth = isVolt ? 1.4 : 1.0
        ..strokeCap = StrokeCap.round;
      canvas.drawLine(
        Offset(x, y),
        Offset(x + len, y + len * slope),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(_SpeedLinesPainter oldDelegate) =>
      oldDelegate.density != density ||
      oldDelegate.seed != seed ||
      oldDelegate.opacity != opacity ||
      oldDelegate.voltShare != voltShare;
}

// ── Marquee strip ────────────────────────────────────────────────────────

/// Infinite horizontal strip — section separator.
/// Words alternate: filled (off-white) and outlined (volt stroke).
class Marquee extends StatefulWidget {
  const Marquee({
    super.key,
    required this.words,
    this.height = 44,
    this.fontSize = 15,
    this.duration = const Duration(seconds: 18),
    this.reverse = false,
  });

  final List<String> words;
  final double height;
  final double fontSize;
  final Duration duration;
  final bool reverse;

  @override
  State<Marquee> createState() => _MarqueeState();
}

class _MarqueeState extends State<Marquee>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  TextPainter? _painter;

  @override
  void initState() {
    super.initState();
    // Constant speed is physics of the strip (conveyor), not a transition —
    // controller.repeat() without a curve is intentional.
    _controller = AnimationController(vsync: this, duration: widget.duration)
      ..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    _painter?.dispose();
    super.dispose();
  }

  TextPainter _buildPainter() {
    final filled = GoogleFonts.archivoBlack(
      fontSize: widget.fontSize,
      color: kOffWhite.withValues(alpha: 0.9),
      letterSpacing: 1.2,
    );
    final stroked = GoogleFonts.archivoBlack(
      fontSize: widget.fontSize,
      letterSpacing: 1.2,
      foreground: Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1
        ..color = kVolt.withValues(alpha: 0.85),
    );
    final dot = GoogleFonts.archivoBlack(
      fontSize: widget.fontSize,
      color: kVolt,
      letterSpacing: 1.2,
    );
    final spans = <TextSpan>[];
    for (var i = 0; i < widget.words.length; i++) {
      spans.add(TextSpan(
        text: widget.words[i].toUpperCase(),
        style: i.isEven ? filled : stroked,
      ));
      spans.add(TextSpan(text: '   •   ', style: dot));
    }
    final tp = TextPainter(
      text: TextSpan(children: spans),
      textDirection: TextDirection.ltr,
      maxLines: 1,
    )..layout();
    return tp;
  }

  @override
  Widget build(BuildContext context) {
    _painter ??= _buildPainter();
    return Semantics(
      label: widget.words.join(', '),
      child: SizedBox(
        height: widget.height,
        width: double.infinity,
        child: ClipRect(
          child: AnimatedBuilder(
            animation: _controller,
            builder: (context, _) {
              return CustomPaint(
                painter: _MarqueePainter(
                  textPainter: _painter!,
                  progress: _controller.value,
                  reverse: widget.reverse,
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}

class _MarqueePainter extends CustomPainter {
  _MarqueePainter({
    required this.textPainter,
    required this.progress,
    required this.reverse,
  });

  final TextPainter textPainter;
  final double progress;
  final bool reverse;

  @override
  void paint(Canvas canvas, Size size) {
    final w = textPainter.width;
    if (w <= 0) return;
    final t = reverse ? 1 - progress : progress;
    var dx = -((t * w) % w);
    final y = (size.height - textPainter.height) / 2;
    while (dx < size.width) {
      textPainter.paint(canvas, Offset(dx, y));
      dx += w;
    }
    // Hairline edges on the strip.
    final border = Paint()
      ..color = kLineDark
      ..strokeWidth = 1;
    canvas.drawLine(Offset.zero, Offset(size.width, 0), border);
    canvas.drawLine(
        Offset(0, size.height), Offset(size.width, size.height), border);
  }

  @override
  bool shouldRepaint(_MarqueePainter oldDelegate) =>
      oldDelegate.progress != progress ||
      oldDelegate.textPainter != textPainter;
}

// ── Count-up number ──────────────────────────────────────────────────────

/// Number that "runs up" to a value — Curves.easeOutExpo.
class CountUp extends StatelessWidget {
  const CountUp({
    super.key,
    required this.value,
    required this.style,
    this.from = 0,
    this.decimals = 0,
    this.duration = const Duration(milliseconds: 1100),
    this.prefix = '',
    this.suffix = '',
  });

  final double value;
  final double from;
  final int decimals;
  final TextStyle style;
  final Duration duration;
  final String prefix;
  final String suffix;

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: from, end: value),
      duration: duration,
      curve: Curves.easeOutExpo,
      builder: (context, v, _) {
        final text = decimals == 0
            ? v.round().toString()
            : kDec(v, decimals: decimals);
        return Text('$prefix$text$suffix', style: style);
      },
    );
  }
}

// ── Staggered reveal ─────────────────────────────────────────────────────

/// Slide-up + fade entrance with per-index interval (52 ms), easeOutCubic.
class Reveal extends StatefulWidget {
  const Reveal({
    super.key,
    required this.index,
    required this.child,
    this.dy = 26,
    this.dx = 0,
  });

  final int index;
  final Widget child;
  final double dy;
  final double dx;

  @override
  State<Reveal> createState() => _RevealState();
}

class _RevealState extends State<Reveal>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final CurvedAnimation _curve;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 460),
    );
    _curve = CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic);
    Future.delayed(Duration(milliseconds: 40 + widget.index * 52), () {
      if (mounted) _controller.forward();
    });
  }

  @override
  void dispose() {
    _curve.dispose();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _curve,
      builder: (context, child) {
        final t = _curve.value;
        return Opacity(
          opacity: t,
          child: Transform.translate(
            offset: Offset(widget.dx * (1 - t), widget.dy * (1 - t)),
            child: child,
          ),
        );
      },
      child: widget.child,
    );
  }
}

// ── Diagonal clipper ─────────────────────────────────────────────────────

/// Clipped top/bottom edge — gentle rise to the right (direction of motion).
class DiagonalClipper extends CustomClipper<Path> {
  const DiagonalClipper({
    this.cutTop = true,
    this.cutBottom = true,
    this.depth = 14,
  });

  final bool cutTop;
  final bool cutBottom;
  final double depth;

  @override
  Path getClip(Size size) {
    return Path()
      ..moveTo(0, cutTop ? depth : 0)
      ..lineTo(size.width, 0)
      ..lineTo(size.width, size.height - (cutBottom ? depth : 0))
      ..lineTo(0, size.height)
      ..close();
  }

  @override
  bool shouldReclip(DiagonalClipper oldClipper) =>
      oldClipper.cutTop != cutTop ||
      oldClipper.cutBottom != cutBottom ||
      oldClipper.depth != depth;
}

// ── Ghost text (outline only) ────────────────────────────────────────────

/// Huge outline text for background depth layers.
class GhostText extends StatelessWidget {
  const GhostText(
    this.text, {
    super.key,
    this.size = 96,
    this.color = kLineDark,
    this.strokeWidth = 1.2,
  });

  final String text;
  final double size;
  final Color color;
  final double strokeWidth;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: GoogleFonts.archivoBlack(
        fontSize: size,
        height: 0.94,
        foreground: Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = strokeWidth
          ..color = color,
      ),
    );
  }
}

// ── Tempo pulse dot ──────────────────────────────────────────────────────

/// Volt dot that pulses like a metronome — "moves even when standing still".
/// Procedural ring expands and fades in rhythm (easeInOut, infinite).
class PulseDot extends StatefulWidget {
  const PulseDot({
    super.key,
    this.size = 9,
    this.period = const Duration(milliseconds: 1400),
  });

  final double size;
  final Duration period;

  @override
  State<PulseDot> createState() => _PulseDotState();
}

class _PulseDotState extends State<PulseDot>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: widget.period)
      ..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final ring = widget.size * 2.6;
    return SizedBox(
      width: ring,
      height: ring,
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, _) {
          // Two waves offset by 0.5 phase — continuous pulse.
          final t = _controller.value;
          return CustomPaint(
            painter: _PulsePainter(t: t, core: widget.size),
          );
        },
      ),
    );
  }
}

class _PulsePainter extends CustomPainter {
  _PulsePainter({required this.t, required this.core});

  final double t;
  final double core;

  @override
  void paint(Canvas canvas, Size size) {
    final center = size.center(Offset.zero);
    for (final phase in [0.0, 0.5]) {
      final p = (t + phase) % 1.0;
      final eased = Curves.easeOutCubic.transform(p);
      final radius = core * 0.6 + eased * (size.width / 2 - core * 0.6);
      final alpha = (1 - eased) * 0.5;
      canvas.drawCircle(
        center,
        radius,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.4
          ..color = kVolt.withValues(alpha: alpha),
      );
    }
    canvas.drawCircle(center, core / 2, Paint()..color = kVolt);
  }

  @override
  bool shouldRepaint(_PulsePainter oldDelegate) => oldDelegate.t != t;
}

// ── Initials square ──────────────────────────────────────────────────────

/// Sharp square with initials — studio avatar (no images, procedural).
class KineticInitials extends StatelessWidget {
  const KineticInitials(
    this.name, {
    super.key,
    this.size = 48,
    this.fontSize = 15,
    this.voltBorder = true,
  });

  final String name;
  final double size;
  final double fontSize;
  final bool voltBorder;

  String get _initials {
    final parts = name.trim().split(RegExp(r'\s+'));
    if (parts.length == 1) return parts.first.substring(0, 1).toUpperCase();
    return (parts.first.substring(0, 1) + parts.last.substring(0, 1))
        .toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: kInkElevated,
        border: Border.all(
          color: voltBorder ? kVolt : kLineDark,
          width: 1.2,
        ),
      ),
      alignment: Alignment.center,
      child: Text(
        _initials,
        style: GoogleFonts.archivoBlack(
          fontSize: fontSize,
          color: kOffWhite,
          letterSpacing: 0.5,
        ),
      ),
    );
  }
}
