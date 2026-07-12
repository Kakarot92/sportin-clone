import 'dart:math' as math;

import 'package:flutter/material.dart';

import 'studio_b_tokens.dart';

/// Živa aurora pozadina — četiri mekana bloba na sporom (~20 s) besšavnom
/// lupu. Frekvencije kretanja su celobrojne, pa se petlja spaja bez skoka.
class StudioBAuroraBackground extends StatefulWidget {
  const StudioBAuroraBackground({
    super.key,
    required this.child,
    this.veil = 0.0,
    this.drift = 0.0,
  });

  final Widget child;

  /// Dodatni beli veo (0–1) preko mesha — pojačava čitljivost gustih ekrana.
  final double veil;

  /// Fazni pomak petlje — školjka ga menja po tabu, pa se „nebo" tiho
  /// prekomponuje dok korisnik šeta kroz aplikaciju.
  final double drift;

  @override
  State<StudioBAuroraBackground> createState() =>
      _StudioBAuroraBackgroundState();
}

class _StudioBAuroraBackgroundState extends State<StudioBAuroraBackground>
    with SingleTickerProviderStateMixin {
  late final AnimationController _loop = AnimationController(
    vsync: this,
    duration: const Duration(seconds: 20),
  )..repeat();

  @override
  void dispose() {
    _loop.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        IgnorePointer(
          child: RepaintBoundary(
            child: AnimatedBuilder(
              animation: _loop,
              builder: (_, _) => CustomPaint(
                painter:
                    StudioBAuroraPainter(t: _loop.value + widget.drift),
                size: Size.infinite,
              ),
            ),
          ),
        ),
        if (widget.veil > 0)
          IgnorePointer(
            child: ColoredBox(
              color: Colors.white.withValues(alpha: widget.veil),
            ),
          ),
        widget.child,
      ],
    );
  }
}

class _AuroraBlob {
  const _AuroraBlob({
    required this.color,
    required this.cx,
    required this.cy,
    required this.ax,
    required this.ay,
    required this.radius,
    required this.phase,
    this.kx = 1,
    this.ky = 1,
  });

  final Color color;
  final double cx, cy; // bazni centar (frakcije ekrana)
  final double ax, ay; // amplitude lutanja
  final double radius; // frakcija kraće strane
  final double phase;
  final int kx, ky; // celobrojne frekvencije → besšavni loop
}

/// Painter aurora mesha: bazni dijagonalni gradijent + radijalni blobovi.
class StudioBAuroraPainter extends CustomPainter {
  const StudioBAuroraPainter({required this.t});

  /// Vreme petlje — koristi se kroz sin/cos sa celobrojnim frekvencijama,
  /// pa vrednosti van [0,1] samo pomeraju fazu.
  final double t;

  static const List<_AuroraBlob> _blobs = [
    _AuroraBlob(
      color: StudioBTokens.blobBlue,
      cx: 0.18, cy: 0.14, ax: 0.12, ay: 0.10, radius: 0.62, phase: 0.00,
    ),
    _AuroraBlob(
      color: StudioBTokens.blobPink,
      cx: 0.88, cy: 0.26, ax: 0.14, ay: 0.12, radius: 0.66, phase: 0.35,
      ky: 2,
    ),
    _AuroraBlob(
      color: StudioBTokens.blobMint,
      cx: 0.22, cy: 0.86, ax: 0.13, ay: 0.10, radius: 0.64, phase: 0.60,
      kx: 2,
    ),
    _AuroraBlob(
      color: StudioBTokens.blobViolet,
      cx: 0.84, cy: 0.88, ax: 0.11, ay: 0.12, radius: 0.55, phase: 0.15,
    ),
  ];

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;

    // Bazni pastelni gradijent.
    final base = Paint()
      ..shader = const LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          StudioBTokens.bgBlue,
          StudioBTokens.bgPink,
          StudioBTokens.bgMint,
        ],
      ).createShader(rect);
    canvas.drawRect(rect, base);

    // Blobovi koji sporo lutaju.
    final short = size.shortestSide;
    for (final b in _blobs) {
      final angX = 2 * math.pi * (b.kx * t + b.phase);
      final angY = 2 * math.pi * (b.ky * t + b.phase * 1.7);
      final cx = (b.cx + b.ax * math.sin(angX)) * size.width;
      final cy = (b.cy + b.ay * math.cos(angY)) * size.height;
      final pulse = 1 + 0.05 * math.sin(2 * math.pi * (t + b.phase));
      final r = b.radius * short * pulse;

      final paint = Paint()
        ..shader = RadialGradient(
          colors: [
            b.color.withValues(alpha: 0.55),
            b.color.withValues(alpha: 0.0),
          ],
        ).createShader(Rect.fromCircle(center: Offset(cx, cy), radius: r));
      canvas.drawCircle(Offset(cx, cy), r, paint);
    }

    // Blagi beli veo pri vrhu — smiruje zonu statusne trake i naslova.
    final veil = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          Colors.white.withValues(alpha: 0.28),
          Colors.white.withValues(alpha: 0.0),
        ],
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height * 0.28));
    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height * 0.28), veil);
  }

  @override
  bool shouldRepaint(covariant StudioBAuroraPainter oldDelegate) {
    return oldDelegate.t != t;
  }
}
