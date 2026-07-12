import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../theme.dart';

// ═══════════════════════════════════════════════════════════════════════
//  Kinetički efekti Studija A — speed-lines, marquee, count-up, reveal,
//  dijagonalni rez, volt dugme. Sve proceduralno, bez asseta.
// ═══════════════════════════════════════════════════════════════════════

/// Režirana tranzicija ekrana: slide + fade, easeOutCubic / easeInCubic.
Route<T> studioARoute<T>(Widget page) {
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

// ── Speed-lines pozadina ─────────────────────────────────────────────────

/// Retke tanke linije u pravcu kretanja — proceduralna tekstura brzine.
class StudioASpeedLines extends StatelessWidget {
  const StudioASpeedLines({
    super.key,
    this.density = 26,
    this.seed = 7,
    this.opacity = 1.0,
    this.voltShare = 0.14,
  });

  /// Broj linija.
  final int density;
  final int seed;
  final double opacity;

  /// Udeo linija u volt boji (ostale su u boji linija).
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
    // Blagi nagib nadole-udesno: utisak kretanja napred.
    const slope = -0.07;
    for (var i = 0; i < density; i++) {
      final y = rnd.nextDouble() * size.height;
      final x = rnd.nextDouble() * size.width;
      final len = 30.0 + rnd.nextDouble() * 130.0;
      final isVolt = rnd.nextDouble() < voltShare;
      final alpha =
          (isVolt ? 0.20 + rnd.nextDouble() * 0.25 : 0.5 + rnd.nextDouble() * 0.5) *
              opacity;
      final paint = Paint()
        ..color = (isVolt ? StudioATheme.volt : StudioATheme.line)
            .withValues(alpha: alpha)
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

// ── Marquee traka ────────────────────────────────────────────────────────

/// Beskonačna horizontalna traka — separator sekcija.
/// Reči se smenjuju: pune (ink) i konturne (volt stroke).
class StudioAMarquee extends StatefulWidget {
  const StudioAMarquee({
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
  State<StudioAMarquee> createState() => _StudioAMarqueeState();
}

class _StudioAMarqueeState extends State<StudioAMarquee>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  TextPainter? _painter;

  @override
  void initState() {
    super.initState();
    // Konstantna brzina je fizika trake (transporter), ne tranzicija —
    // controller.repeat() bez krive je namerna režija.
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
      color: StudioATheme.ink.withValues(alpha: 0.9),
      letterSpacing: 1.2,
    );
    final stroked = GoogleFonts.archivoBlack(
      fontSize: widget.fontSize,
      letterSpacing: 1.2,
      foreground: Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1
        ..color = StudioATheme.volt.withValues(alpha: 0.85),
    );
    final dot = GoogleFonts.archivoBlack(
      fontSize: widget.fontSize,
      color: StudioATheme.volt,
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
    // Hairline ivice trake.
    final border = Paint()
      ..color = StudioATheme.line
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

// ── Count-up broj ────────────────────────────────────────────────────────

/// Broj koji „utrčava" do vrednosti — Curves.easeOutExpo.
class StudioACountUp extends StatelessWidget {
  const StudioACountUp({
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
            : studioADec(v, decimals: decimals);
        return Text('$prefix$text$suffix', style: style);
      },
    );
  }
}

// ── Staggered ulaz ───────────────────────────────────────────────────────

/// Slide-up + fade ulaz sa intervalom po indeksu (52 ms), easeOutCubic.
class StudioAReveal extends StatefulWidget {
  const StudioAReveal({
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
  State<StudioAReveal> createState() => _StudioARevealState();
}

class _StudioARevealState extends State<StudioAReveal>
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

// ── Dijagonalni rez ──────────────────────────────────────────────────────

/// Isečena gornja/donja ivica — blagi uspon udesno (pravac kretanja).
class StudioADiagonalClipper extends CustomClipper<Path> {
  const StudioADiagonalClipper({
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
  bool shouldReclip(StudioADiagonalClipper oldClipper) =>
      oldClipper.cutTop != cutTop ||
      oldClipper.cutBottom != cutBottom ||
      oldClipper.depth != depth;
}

// ── Volt CTA dugme ───────────────────────────────────────────────────────

/// Ukošeno volt dugme sa crnim uppercase tekstom — glavni CTA studija.
class StudioAVoltButton extends StatefulWidget {
  const StudioAVoltButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.height = 56,
    this.filled = true,
    this.icon,
  });

  final String label;
  final VoidCallback onPressed;
  final double height;

  /// `false` = konturna (outline) varijanta.
  final bool filled;
  final IconData? icon;

  @override
  State<StudioAVoltButton> createState() => _StudioAVoltButtonState();
}

class _StudioAVoltButtonState extends State<StudioAVoltButton> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    const skew = -0.10;
    final fg = widget.filled ? StudioATheme.bg : StudioATheme.volt;
    return Semantics(
      button: true,
      label: widget.label,
      child: GestureDetector(
        onTapDown: (_) => setState(() => _pressed = true),
        onTapCancel: () => setState(() => _pressed = false),
        onTapUp: (_) {
          setState(() => _pressed = false);
          widget.onPressed();
        },
        child: AnimatedScale(
          scale: _pressed ? 0.965 : 1.0,
          duration: const Duration(milliseconds: 140),
          curve: Curves.easeOutCubic,
          child: Transform(
            transform: Matrix4.skewX(skew),
            alignment: Alignment.center,
            child: Container(
              height: widget.height,
              decoration: BoxDecoration(
                color: widget.filled ? StudioATheme.volt : Colors.transparent,
                border: widget.filled
                    ? null
                    : Border.all(color: StudioATheme.volt, width: 1.5),
                boxShadow: widget.filled
                    ? [
                        BoxShadow(
                          color: StudioATheme.volt.withValues(alpha: 0.28),
                          blurRadius: _pressed ? 10 : 22,
                          offset: const Offset(0, 4),
                        ),
                      ]
                    : null,
              ),
              child: Transform(
                transform: Matrix4.skewX(-skew),
                alignment: Alignment.center,
                child: Center(
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (widget.icon != null) ...[
                        Icon(widget.icon, size: 18, color: fg),
                        const SizedBox(width: 8),
                      ],
                      Text(
                        widget.label.toUpperCase(),
                        style: GoogleFonts.archivoBlack(
                          fontSize: 14,
                          color: fg,
                          letterSpacing: 1.6,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ── Sekcijska labela ─────────────────────────────────────────────────────

/// Volt marker + uppercase labela + hairline do kraja reda.
class StudioASectionLabel extends StatelessWidget {
  const StudioASectionLabel(this.text, {super.key});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Transform(
          transform: Matrix4.skewX(-0.35),
          child: Container(width: 8, height: 8, color: StudioATheme.volt),
        ),
        const SizedBox(width: 10),
        Text(
          text.toUpperCase(),
          style: StudioATheme.label(color: StudioATheme.ink),
        ),
        const SizedBox(width: 14),
        const Expanded(child: Divider(height: 1, color: StudioATheme.line)),
      ],
    );
  }
}

// ── Ghost tekst (samo kontura) ───────────────────────────────────────────

/// Ogromni konturni tekst za pozadinske slojeve.
class StudioAGhostText extends StatelessWidget {
  const StudioAGhostText(
    this.text, {
    super.key,
    this.size = 96,
    this.color = StudioATheme.line,
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

/// Volt tačka koja pulsira kao metronom — „kreće se i dok stoji".
/// Proceduralni prsten se širi i bledi u ritmu (easeInOut, beskonačno).
class StudioAPulseDot extends StatefulWidget {
  const StudioAPulseDot({
    super.key,
    this.size = 9,
    this.period = const Duration(milliseconds: 1400),
  });

  final double size;
  final Duration period;

  @override
  State<StudioAPulseDot> createState() => _StudioAPulseDotState();
}

class _StudioAPulseDotState extends State<StudioAPulseDot>
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
          // Dva talasa u fazi razmaka 0.5 — kontinuiran puls.
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
          ..color = StudioATheme.volt.withValues(alpha: alpha),
      );
    }
    canvas.drawCircle(center, core / 2, Paint()..color = StudioATheme.volt);
  }

  @override
  bool shouldRepaint(_PulsePainter oldDelegate) => oldDelegate.t != t;
}

// ── Kvadrat sa inicijalima ───────────────────────────────────────────────

/// Oštri kvadrat sa inicijalima — avatar studija (bez slika, proceduralno).
class StudioAInitials extends StatelessWidget {
  const StudioAInitials(
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
        color: StudioATheme.surface,
        border: Border.all(
          color: voltBorder ? StudioATheme.volt : StudioATheme.line,
          width: 1.2,
        ),
      ),
      alignment: Alignment.center,
      child: Text(
        _initials,
        style: GoogleFonts.archivoBlack(
          fontSize: fontSize,
          color: StudioATheme.ink,
          letterSpacing: 0.5,
        ),
      ),
    );
  }
}

// ── Oštro ikoničko dugme (48dp tap-target) ───────────────────────────────

/// Kvadratno ikoničko dugme sa hairline okvirom — back/exit akcije.
class StudioAIconButton extends StatelessWidget {
  const StudioAIconButton({
    super.key,
    required this.icon,
    required this.onPressed,
    this.tooltip,
    this.voltIcon = false,
  });

  final IconData icon;
  final VoidCallback onPressed;
  final String? tooltip;
  final bool voltIcon;

  @override
  Widget build(BuildContext context) {
    final button = Material(
      color: StudioATheme.surface,
      shape: const RoundedRectangleBorder(
        side: BorderSide(color: StudioATheme.line),
      ),
      child: InkWell(
        onTap: onPressed,
        child: SizedBox(
          width: 48,
          height: 48,
          child: Icon(
            icon,
            size: 20,
            color: voltIcon ? StudioATheme.volt : StudioATheme.ink,
          ),
        ),
      ),
    );
    if (tooltip == null) return button;
    return Tooltip(message: tooltip!, child: button);
  }
}
