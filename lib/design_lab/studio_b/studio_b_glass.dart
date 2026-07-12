import 'dart:ui' show ImageFilter;

import 'package:flutter/material.dart';

import 'studio_b_tokens.dart';

/// Frosted-glass panel: blur pozadine, bela providna ploha, 1px bela ivica
/// i meka violet senka. Osnovna gradivna jedinica Studija B.
class StudioBGlass extends StatelessWidget {
  const StudioBGlass({
    super.key,
    required this.child,
    this.radius = 28,
    this.opacity = 0.62,
    this.blur = 22,
    this.padding = const EdgeInsets.all(20),
    this.tint,
    this.shadow = true,
    this.onTap,
  });

  final Widget child;
  final double radius;
  final double opacity;
  final double blur;
  final EdgeInsetsGeometry padding;

  /// Boja koja se utapa u belu plohu (npr. violet za „moje" poruke).
  final Color? tint;
  final bool shadow;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final surface = tint == null
        ? Colors.white.withValues(alpha: opacity)
        : Color.alphaBlend(tint!, Colors.white).withValues(alpha: opacity);

    return DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(radius),
        boxShadow: shadow
            ? [
                BoxShadow(
                  color: StudioBTokens.violet.withValues(alpha: 0.10),
                  blurRadius: 30,
                  offset: const Offset(0, 14),
                ),
              ]
            : null,
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(radius),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: blur, sigmaY: blur),
          child: Material(
            color: surface,
            child: InkWell(
              onTap: onTap,
              splashColor: StudioBTokens.violet.withValues(alpha: 0.08),
              highlightColor: StudioBTokens.violet.withValues(alpha: 0.05),
              child: Container(
                padding: padding,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(radius),
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.40),
                  ),
                ),
                child: child,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Primarno pill dugme — violet gradijent, pritisak blago skalira nadole.
class StudioBPillButton extends StatefulWidget {
  const StudioBPillButton({
    super.key,
    required this.label,
    this.onPressed,
    this.icon,
    this.busy = false,
    this.height = 56,
  });

  final String label;
  final VoidCallback? onPressed;
  final IconData? icon;
  final bool busy;
  final double height;

  @override
  State<StudioBPillButton> createState() => _StudioBPillButtonState();
}

class _StudioBPillButtonState extends State<StudioBPillButton> {
  bool _down = false;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: widget.label,
      child: GestureDetector(
        onTapDown: (_) => setState(() => _down = true),
        onTapUp: (_) => setState(() => _down = false),
        onTapCancel: () => setState(() => _down = false),
        onTap: widget.busy ? null : widget.onPressed,
        child: AnimatedScale(
          scale: _down ? 0.965 : 1.0,
          duration: const Duration(milliseconds: 240),
          curve: Curves.easeOutCubic,
          child: Container(
            height: widget.height,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: StudioBTokens.ctaGradient,
              ),
              borderRadius: BorderRadius.circular(999),
              boxShadow: [
                BoxShadow(
                  color: StudioBTokens.violet.withValues(alpha: 0.35),
                  blurRadius: 22,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: widget.busy
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2.2,
                      color: Colors.white,
                    ),
                  )
                : Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (widget.icon != null) ...[
                        Icon(widget.icon, size: 19, color: Colors.white),
                        const SizedBox(width: 8),
                      ],
                      Text(
                        widget.label,
                        style: StudioBTokens.display(
                          size: 15.5,
                          weight: FontWeight.w600,
                          color: Colors.white,
                          spacing: 0.2,
                        ),
                      ),
                    ],
                  ),
          ),
        ),
      ),
    );
  }
}

/// Sekundarno „ghost" dugme — providna violet ploha, bez senke.
class StudioBGhostButton extends StatelessWidget {
  const StudioBGhostButton({
    super.key,
    required this.label,
    this.onPressed,
    this.icon,
    this.height = 48,
  });

  final String label;
  final VoidCallback? onPressed;
  final IconData? icon;
  final double height;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: StudioBTokens.violet.withValues(alpha: 0.11),
      borderRadius: BorderRadius.circular(999),
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(999),
        splashColor: StudioBTokens.violet.withValues(alpha: 0.12),
        child: Container(
          height: height,
          alignment: Alignment.center,
          padding: const EdgeInsets.symmetric(horizontal: 14),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (icon != null) ...[
                Icon(icon, size: 17, color: StudioBTokens.violetDeep),
                const SizedBox(width: 7),
              ],
              Flexible(
                child: Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: StudioBTokens.label(
                    size: 13,
                    color: StudioBTokens.violetDeep,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Mali pill čip sa opcionalnom ikonicom.
class StudioBChip extends StatelessWidget {
  const StudioBChip({
    super.key,
    required this.label,
    this.icon,
    this.background,
    this.foreground = StudioBTokens.inkSoft,
  });

  final String label;
  final IconData? icon;
  final Color? background;
  final Color foreground;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
      decoration: BoxDecoration(
        color: background ?? Colors.white.withValues(alpha: 0.55),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: Colors.white.withValues(alpha: 0.50)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 14, color: foreground),
            const SizedBox(width: 5),
          ],
          Text(
            label,
            style: StudioBTokens.label(size: 12, color: foreground),
          ),
        ],
      ),
    );
  }
}

/// Gradijent avatar sa inicijalima; opcioni prsten prikazuje vrednost 0–1
/// (npr. ocenu trenera kao luk oko avatara).
class StudioBAvatar extends StatelessWidget {
  const StudioBAvatar({
    super.key,
    required this.name,
    this.size = 56,
    this.ring,
    this.heroTag,
  });

  final String name;
  final double size;
  final double? ring;
  final Object? heroTag;

  String get _initials {
    final parts =
        name.split(' ').where((p) => p.trim().isNotEmpty).take(2).toList();
    return parts.map((p) => p[0].toUpperCase()).join();
  }

  List<Color> get _gradient {
    var sum = 0;
    for (final c in name.codeUnits) {
      sum += c;
    }
    return StudioBTokens.avatarGradients[
        sum % StudioBTokens.avatarGradients.length];
  }

  @override
  Widget build(BuildContext context) {
    final pad = ring != null ? size * 0.10 : 0.0;
    final inner = size - pad * 2;

    Widget circle = Container(
      width: inner,
      height: inner,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: _gradient,
        ),
        boxShadow: [
          BoxShadow(
            color: _gradient.last.withValues(alpha: 0.30),
            blurRadius: 12,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Text(
        _initials,
        style: StudioBTokens.display(
          size: inner * 0.34,
          weight: FontWeight.w600,
          color: Colors.white,
        ),
      ),
    );

    if (heroTag != null) {
      circle = Hero(tag: heroTag!, child: circle);
    }

    if (ring == null) {
      return SizedBox(width: size, height: size, child: Center(child: circle));
    }

    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Positioned.fill(
            child: CustomPaint(painter: _RatingRingPainter(value: ring!)),
          ),
          circle,
        ],
      ),
    );
  }
}

class _RatingRingPainter extends CustomPainter {
  const _RatingRingPainter({required this.value});

  final double value;

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    final stroke = size.shortestSide * 0.05;
    final arcRect = rect.deflate(stroke / 2 + 0.5);

    final track = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = stroke
      ..color = Colors.white.withValues(alpha: 0.65);
    canvas.drawArc(arcRect, 0, 2 * 3.1415926535, false, track);

    final arc = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = stroke
      ..strokeCap = StrokeCap.round
      ..color = StudioBTokens.mint;
    canvas.drawArc(
      arcRect,
      -3.1415926535 / 2,
      2 * 3.1415926535 * value.clamp(0.0, 1.0),
      false,
      arc,
    );
  }

  @override
  bool shouldRepaint(covariant _RatingRingPainter oldDelegate) {
    return oldDelegate.value != value;
  }
}

/// Ulazna koreografija: fade + blagi lift, sa zadrškom za stagger.
class StudioBReveal extends StatefulWidget {
  const StudioBReveal({
    super.key,
    required this.child,
    this.delayMs = 0,
    this.dy = 18,
  });

  final Widget child;
  final int delayMs;
  final double dy;

  @override
  State<StudioBReveal> createState() => _StudioBRevealState();
}

class _StudioBRevealState extends State<StudioBReveal>
    with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 620),
  );
  late final CurvedAnimation _a =
      CurvedAnimation(parent: _c, curve: Curves.easeOutCubic);

  @override
  void initState() {
    super.initState();
    if (widget.delayMs <= 0) {
      _c.forward();
    } else {
      Future<void>.delayed(Duration(milliseconds: widget.delayMs), () {
        if (mounted) {
          _c.forward();
        }
      });
    }
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _a,
      child: widget.child,
      builder: (_, child) => Opacity(
        opacity: _a.value,
        child: Transform.translate(
          offset: Offset(0, (1 - _a.value) * widget.dy),
          child: child,
        ),
      ),
    );
  }
}

/// „Disanje" hero elementa: scale 1,0 → 1,02, ~4 s, easeInOutSine.
class StudioBBreathing extends StatefulWidget {
  const StudioBBreathing({super.key, required this.child});

  final Widget child;

  @override
  State<StudioBBreathing> createState() => _StudioBBreathingState();
}

class _StudioBBreathingState extends State<StudioBBreathing>
    with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(
    vsync: this,
    duration: const Duration(seconds: 4),
  )..repeat(reverse: true);
  late final Animation<double> _scale = Tween<double>(begin: 1.0, end: 1.02)
      .animate(CurvedAnimation(parent: _c, curve: Curves.easeInOutSine));

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ScaleTransition(scale: _scale, child: widget.child);
  }
}

/// Naslov sekcije (Sora) sa opcionim sadržajem uz desnu ivicu.
class StudioBSectionHeader extends StatelessWidget {
  const StudioBSectionHeader({super.key, required this.title, this.trailing});

  final String title;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, right: 4, bottom: 12),
      child: Row(
        children: [
          Expanded(
            child: Text(
              title,
              style: StudioBTokens.display(size: 18, weight: FontWeight.w600),
            ),
          ),
          ?trailing,
        ],
      ),
    );
  }
}

/// Push ruta studija: fade + blagi lift, easeOutCubic / easeInCubic.
Route<T> studioBRoute<T>(Widget page) {
  return PageRouteBuilder<T>(
    transitionDuration: const Duration(milliseconds: 520),
    reverseTransitionDuration: const Duration(milliseconds: 400),
    pageBuilder: (_, _, _) => page,
    transitionsBuilder: (_, animation, _, child) {
      final curved = CurvedAnimation(
        parent: animation,
        curve: Curves.easeOutCubic,
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

/// Glass snackbar u tonu studija.
void studioBShowSnack(
  BuildContext context,
  String message, {
  IconData icon = Icons.info_outline_rounded,
}) {
  ScaffoldMessenger.of(context)
    ..hideCurrentSnackBar()
    ..showSnackBar(
      SnackBar(
        behavior: SnackBarBehavior.floating,
        elevation: 0,
        backgroundColor: Colors.white.withValues(alpha: 0.94),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(18),
          side: BorderSide(
            color: StudioBTokens.violet.withValues(alpha: 0.25),
          ),
        ),
        margin: const EdgeInsets.fromLTRB(20, 0, 20, 100),
        content: Row(
          children: [
            Icon(icon, size: 20, color: StudioBTokens.violetDeep),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                message,
                style: StudioBTokens.body(
                  size: 13.5,
                  weight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
}
