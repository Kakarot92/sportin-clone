import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'theme.dart';

/// Naslov sa suptilnim cyan→violet gradijentom (ShaderMask preko teksta).
class StudioEGradientText extends StatelessWidget {
  const StudioEGradientText(
    this.text, {
    super.key,
    required this.style,
    this.textAlign,
  });

  final String text;
  final TextStyle style;
  final TextAlign? textAlign;

  @override
  Widget build(BuildContext context) {
    return ShaderMask(
      blendMode: BlendMode.srcIn,
      shaderCallback: (bounds) => const LinearGradient(
        colors: [StudioEColors.text, StudioEColors.cyan, StudioEColors.violet],
        stops: [0.35, 0.75, 1.0],
      ).createShader(bounds),
      child: Text(text, style: style, textAlign: textAlign),
    );
  }
}

/// Mala sekcijska etiketa: neon crtica + naslov u kapitalama.
class StudioESectionLabel extends StatelessWidget {
  const StudioESectionLabel(this.text, {super.key});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 16,
          height: 2,
          decoration: BoxDecoration(
            gradient: StudioEColors.neon,
            borderRadius: BorderRadius.circular(1),
          ),
        ),
        const SizedBox(width: StudioESpace.s),
        Text(
          text.toUpperCase(),
          style: Theme.of(context).textTheme.labelSmall,
        ),
      ],
    );
  }
}

/// Depth kartica: 1px gradient ivica (cyan→violet) preko tamnijeg
/// unutrašnjeg sloja. [emphasis] pojačava ivicu i dodaje glow — koristi se
/// najviše jednom-dva puta po ekranu (glow je začin).
class StudioEDepthCard extends StatelessWidget {
  const StudioEDepthCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(18),
    this.radius = 20,
    this.emphasis = false,
    this.color = StudioEColors.layer1,
    this.glowColor,
    this.onTap,
  });

  final Widget child;
  final EdgeInsetsGeometry padding;
  final double radius;
  final bool emphasis;
  final Color color;
  final Color? glowColor;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final glow = glowColor ?? StudioEColors.cyan;
    final borderAlpha = emphasis ? 0.85 : 0.28;
    final innerRadius = BorderRadius.circular(radius - 1);

    Widget inner;
    if (onTap != null) {
      inner = Material(
        color: color,
        borderRadius: innerRadius,
        child: InkWell(
          onTap: onTap,
          borderRadius: innerRadius,
          child: Padding(padding: padding, child: child),
        ),
      );
    } else {
      inner = Container(
        decoration: BoxDecoration(color: color, borderRadius: innerRadius),
        padding: padding,
        child: child,
      );
    }

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(radius),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            StudioEColors.cyan.withValues(alpha: borderAlpha),
            StudioEColors.hairline.withValues(alpha: emphasis ? 0.9 : 0.75),
            StudioEColors.violet.withValues(alpha: borderAlpha),
          ],
          stops: const [0.0, 0.5, 1.0],
        ),
        boxShadow: emphasis
            ? [
                BoxShadow(
                  color: glow.withValues(alpha: 0.30),
                  blurRadius: 26,
                  spreadRadius: -4,
                ),
              ]
            : null,
      ),
      padding: const EdgeInsets.all(1),
      child: inner,
    );
  }
}

/// Primarni CTA: cyan površina, tamni tekst, glow senka, skala na pritisak.
class StudioEGlowButton extends StatefulWidget {
  const StudioEGlowButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.icon,
  });

  final String label;
  final VoidCallback onPressed;
  final IconData? icon;

  @override
  State<StudioEGlowButton> createState() => _StudioEGlowButtonState();
}

class _StudioEGlowButtonState extends State<StudioEGlowButton> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: widget.label,
      child: GestureDetector(
        onTapDown: (_) => setState(() => _pressed = true),
        onTapCancel: () => setState(() => _pressed = false),
        onTapUp: (_) => setState(() => _pressed = false),
        onTap: widget.onPressed,
        child: AnimatedScale(
          scale: _pressed ? 0.97 : 1,
          duration: const Duration(milliseconds: 160),
          curve: Curves.easeOutCubic,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 160),
            curve: Curves.easeOutCubic,
            height: 56,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(18),
              gradient: const LinearGradient(
                colors: [StudioEColors.cyan, Color(0xFF7BEFE0)],
              ),
              boxShadow: [
                BoxShadow(
                  color: StudioEColors.cyan
                      .withValues(alpha: _pressed ? 0.18 : 0.35),
                  blurRadius: 26,
                  spreadRadius: -2,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: Center(
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (widget.icon != null) ...[
                    Icon(widget.icon, size: 20, color: StudioEColors.onCyan),
                    const SizedBox(width: StudioESpace.s),
                  ],
                  Text(
                    widget.label,
                    style: GoogleFonts.ibmPlexSans(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: StudioEColors.onCyan,
                      letterSpacing: 0.2,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Avatar sa inicijalima i neon prstenom; [glow] samo na hero mestima.
class StudioEAvatar extends StatelessWidget {
  const StudioEAvatar({
    super.key,
    required this.name,
    this.size = 52,
    this.glow = false,
    this.heroTag,
  });

  final String name;
  final double size;
  final bool glow;
  final String? heroTag;

  String get _initials {
    final parts = name.split(' ').where((p) => p.isNotEmpty).toList();
    if (parts.isEmpty) return '?';
    if (parts.length == 1) return parts.first.substring(0, 1);
    return parts.first.substring(0, 1) + parts.last.substring(0, 1);
  }

  @override
  Widget build(BuildContext context) {
    Widget avatar = Container(
      width: size,
      height: size,
      padding: const EdgeInsets.all(2),
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [StudioEColors.cyan, StudioEColors.violet],
        ),
        boxShadow: glow
            ? [
                BoxShadow(
                  color: StudioEColors.cyan.withValues(alpha: 0.30),
                  blurRadius: 30,
                  spreadRadius: 2,
                ),
              ]
            : null,
      ),
      child: DecoratedBox(
        decoration: const BoxDecoration(
          shape: BoxShape.circle,
          color: StudioEColors.layer2,
        ),
        child: Center(
          child: Text(
            _initials,
            style: GoogleFonts.syne(
              fontSize: size * 0.32,
              fontWeight: FontWeight.w700,
              color: StudioEColors.text,
              letterSpacing: 0.5,
            ),
          ),
        ),
      ),
    );
    if (heroTag != null) {
      avatar = Hero(tag: heroTag!, child: avatar);
    }
    return avatar;
  }
}

/// Pozadinski glow blob — najdublji plan scene.
class StudioEBlob extends StatelessWidget {
  const StudioEBlob({
    super.key,
    required this.color,
    required this.size,
    this.opacity = 0.16,
  });

  final Color color;
  final double size;
  final double opacity;

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: RadialGradient(
            colors: [
              color.withValues(alpha: opacity),
              color.withValues(alpha: 0),
            ],
          ),
        ),
      ),
    );
  }
}

/// Parallax pozadina: blob-ovi se pomeraju sporije od sadržaja
/// (scroll listener) I nezavisno sporo dišu na sopstvenom tikeru — tako i
/// ekrani bez skrola (Prijava, Chat) zadrže živu kinematsku dubinu.
/// Drugi plan scene; izolovan u [RepaintBoundary].
class StudioEParallaxBackdrop extends StatefulWidget {
  const StudioEParallaxBackdrop({super.key, this.controller});

  final ScrollController? controller;

  @override
  State<StudioEParallaxBackdrop> createState() =>
      _StudioEParallaxBackdropState();
}

class _StudioEParallaxBackdropState extends State<StudioEParallaxBackdrop>
    with SingleTickerProviderStateMixin {
  late final AnimationController _drift = AnimationController(
    vsync: this,
    duration: const Duration(seconds: 42),
  )..repeat();

  @override
  void dispose() {
    _drift.dispose();
    super.dispose();
  }

  double get _scrollOffset {
    final c = widget.controller;
    if (c == null || !c.hasClients) return 0;
    return c.offset;
  }

  @override
  Widget build(BuildContext context) {
    final scroll = widget.controller ??
        const AlwaysStoppedAnimation<double>(0);
    return Positioned.fill(
      child: RepaintBoundary(
        child: ListenableBuilder(
          listenable: Listenable.merge([_drift, scroll]),
          builder: (context, _) {
            final o = _scrollOffset;
            final phase = _drift.value * 2 * math.pi;
            // Suptilan autonomni drift — amplituda mala (kino, ne vrtoglavica).
            final dx1 = math.sin(phase) * 20;
            final dy1 = math.cos(phase * 0.8) * 16;
            final dx2 = math.cos(phase * 0.9) * 24;
            final dy2 = math.sin(phase * 1.1) * 18;
            final dx3 = math.sin(phase * 1.3 + 1.4) * 16;
            return Stack(
              children: [
                Positioned(
                  top: -120 - o * 0.35 + dy1,
                  right: -100 + dx1,
                  child: const StudioEBlob(
                    color: StudioEColors.cyan,
                    size: 360,
                  ),
                ),
                Positioned(
                  top: 280 - o * 0.22 + dy2,
                  left: -150 + dx2,
                  child: const StudioEBlob(
                    color: StudioEColors.violet,
                    size: 420,
                    opacity: 0.13,
                  ),
                ),
                Positioned(
                  top: 680 - o * 0.12 + dy1 * 0.6,
                  right: -70 + dx3,
                  child: const StudioEBlob(
                    color: StudioEColors.cyan,
                    size: 280,
                    opacity: 0.10,
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

/// Push tranzicija Studija E: blagi slide-up + fade, `easeOutQuint`.
class StudioEPageRoute<T> extends PageRouteBuilder<T> {
  StudioEPageRoute({required WidgetBuilder builder})
      : super(
          transitionDuration: const Duration(milliseconds: 460),
          reverseTransitionDuration: const Duration(milliseconds: 300),
          pageBuilder: (context, animation, secondaryAnimation) =>
              builder(context),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            final curved = CurvedAnimation(
              parent: animation,
              curve: Curves.easeOutQuint,
              reverseCurve: Curves.easeInCubic,
            );
            return FadeTransition(
              opacity: curved,
              child: SlideTransition(
                position: Tween<Offset>(
                  begin: const Offset(0, 0.06),
                  end: Offset.zero,
                ).animate(curved),
                child: child,
              ),
            );
          },
        );
}

/// Kružno „nazad" dugme za push ekrane (48dp tap-target).
class StudioEBackButton extends StatelessWidget {
  const StudioEBackButton({super.key});

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: 'Nazad',
      child: Material(
        color: StudioEColors.layer1,
        shape: const CircleBorder(
          side: BorderSide(color: StudioEColors.hairline),
        ),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: () => Navigator.of(context).maybePop(),
          child: const SizedBox(
            width: 48,
            height: 48,
            child: Icon(
              Icons.arrow_back_rounded,
              size: 20,
              color: StudioEColors.text,
            ),
          ),
        ),
      ),
    );
  }
}

/// Count-up broj: animira od nule do ciljne vrednosti (easeOutQuint).
class StudioECountUp extends StatelessWidget {
  const StudioECountUp({
    super.key,
    required this.value,
    required this.style,
    this.format,
    this.duration = const Duration(milliseconds: 1100),
  });

  final double value;
  final TextStyle style;
  final String Function(double value)? format;
  final Duration duration;

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: value),
      duration: duration,
      curve: Curves.easeOutQuint,
      builder: (context, v, _) => Text(
        format?.call(v) ?? v.round().toString(),
        style: style,
      ),
    );
  }
}

/// Ulazna režija elementa: fade + blagi slide, sa zadrškom po indeksu.
class StudioEEntrance extends StatelessWidget {
  const StudioEEntrance({super.key, required this.child, this.delayMs = 0});

  final Widget child;
  final int delayMs;

  @override
  Widget build(BuildContext context) {
    final total = 520 + delayMs;
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: Duration(milliseconds: total),
      curve: Interval(delayMs / total, 1, curve: Curves.easeOutQuint),
      builder: (context, t, inner) => Opacity(
        opacity: t,
        child: Transform.translate(
          offset: Offset(0, 18 * (1 - t)),
          child: inner,
        ),
      ),
      child: child,
    );
  }
}
