import 'dart:math' as math;

import 'package:flutter/material.dart';

import 'theme.dart';

/// Hairline linija od 1px — osnovna gradivna jedinica grida.
class StudioCHairline extends StatelessWidget {
  const StudioCHairline({super.key, this.thickness = 1, this.color});

  final double thickness;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: thickness,
      color: color ?? StudioCTokens.hairline,
    );
  }
}

/// „Dvostruko pravilo" — deblja ink linija + hairline ispod (novinski rez).
class StudioCDoubleRule extends StatelessWidget {
  const StudioCDoubleRule({super.key});

  @override
  Widget build(BuildContext context) {
    return const Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        StudioCHairline(thickness: 2.5, color: StudioCTokens.ink),
        SizedBox(height: 3),
        StudioCHairline(),
      ],
    );
  }
}

/// Numerisani kicker: hairline iznad, terakota redni broj, uppercase labela,
/// opciona meta beleška uz desnu ivicu.
class StudioCKicker extends StatelessWidget {
  const StudioCKicker({
    super.key,
    required this.label,
    this.index,
    this.trailing,
    this.withRule = true,
  });

  /// Redni broj sekcije, npr. „01".
  final String? index;
  final String label;
  final String? trailing;
  final bool withRule;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (withRule) ...[
          const StudioCHairline(),
          const SizedBox(height: 10),
        ],
        Row(
          crossAxisAlignment: CrossAxisAlignment.baseline,
          textBaseline: TextBaseline.alphabetic,
          children: [
            if (index != null) ...[
              Text(
                index!,
                style: StudioCType.numeral(
                  12,
                  color: StudioCTokens.terracotta,
                ),
              ),
              Text(
                '  —  ',
                style: StudioCType.kicker(size: 10, letterSpacing: 0),
              ),
            ],
            Expanded(
              child: Text(
                label.toUpperCase(),
                style: StudioCType.kicker(color: StudioCTokens.ink),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            if (trailing != null)
              Text(
                trailing!.toUpperCase(),
                style: StudioCType.meta(),
                textAlign: TextAlign.right,
              ),
          ],
        ),
      ],
    );
  }
}

/// Ulazna režija: fade + blagi translate, ~320ms, easeOutQuart,
/// stagger po rednom broju.
class StudioCReveal extends StatefulWidget {
  const StudioCReveal({
    super.key,
    required this.child,
    this.order = 0,
    this.dy = 14,
  });

  final Widget child;
  final int order;
  final double dy;

  @override
  State<StudioCReveal> createState() => _StudioCRevealState();
}

class _StudioCRevealState extends State<StudioCReveal>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: StudioCTokens.beat,
  );
  late final CurvedAnimation _t = CurvedAnimation(
    parent: _controller,
    curve: StudioCTokens.ease,
  );

  @override
  void initState() {
    super.initState();
    Future.delayed(Duration(milliseconds: 45 * widget.order), () {
      if (mounted) _controller.forward();
    });
  }

  @override
  void dispose() {
    _t.dispose();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _t,
      child: widget.child,
      builder: (context, child) {
        return Opacity(
          opacity: _t.value,
          child: Transform.translate(
            offset: Offset(0, (1 - _t.value) * widget.dy),
            child: child,
          ),
        );
      },
    );
  }
}

/// Push tranzicija studija: fade + blagi vertikalni pomak. Ništa ne skače.
class StudioCRoute<T> extends PageRouteBuilder<T> {
  StudioCRoute({required WidgetBuilder builder})
      : super(
          transitionDuration: StudioCTokens.beat,
          reverseTransitionDuration: const Duration(milliseconds: 260),
          pageBuilder: (context, animation, secondaryAnimation) =>
              builder(context),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            final t = CurvedAnimation(
              parent: animation,
              curve: StudioCTokens.ease,
              reverseCurve: Curves.easeInQuart,
            );
            return FadeTransition(
              opacity: t,
              child: SlideTransition(
                position: Tween<Offset>(
                  begin: const Offset(0, 0.025),
                  end: Offset.zero,
                ).animate(t),
                child: child,
              ),
            );
          },
        );
}

/// Primarno dugme — puna ink traka, bone uppercase tekst, oštre ivice.
class StudioCPrimaryButton extends StatelessWidget {
  const StudioCPrimaryButton({
    super.key,
    required this.label,
    this.onTap,
    this.arrow = true,
  });

  final String label;
  final VoidCallback? onTap;
  final bool arrow;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: StudioCTokens.ink,
      child: InkWell(
        onTap: onTap,
        highlightColor: Colors.white.withValues(alpha: 0.08),
        child: Container(
          height: 56,
          alignment: Alignment.center,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                label.toUpperCase(),
                style: StudioCType.kicker(
                  size: 12,
                  color: StudioCTokens.bone,
                  letterSpacing: 2.2,
                  weight: FontWeight.w600,
                ),
              ),
              if (arrow) ...[
                const SizedBox(width: 10),
                Text(
                  '→',
                  style: StudioCType.body(
                    size: 15,
                    color: StudioCTokens.bone,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

/// Sekundarno dugme — hairline okvir, ink tekst.
class StudioCGhostButton extends StatelessWidget {
  const StudioCGhostButton({super.key, required this.label, this.onTap});

  final String label;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        child: Container(
          height: 56,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            border: Border.all(color: StudioCTokens.ink, width: 1),
          ),
          child: Text(
            label.toUpperCase(),
            style: StudioCType.kicker(
              size: 12,
              color: StudioCTokens.ink,
              letterSpacing: 2.2,
            ),
          ),
        ),
      ),
    );
  }
}

/// Editorial snack beleška — ink traka sa bone tekstom.
abstract final class StudioCNote {
  static void show(BuildContext context, String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }
}

/// Underline polje za unos — bez kutije, samo hairline pravilo.
class StudioCField extends StatelessWidget {
  const StudioCField({
    super.key,
    required this.label,
    this.hint,
    this.controller,
    this.obscure = false,
    this.suffix,
    this.keyboardType,
  });

  final String label;
  final String? hint;
  final TextEditingController? controller;
  final bool obscure;
  final Widget? suffix;
  final TextInputType? keyboardType;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label.toUpperCase(), style: StudioCType.kicker()),
        TextField(
          controller: controller,
          obscureText: obscure,
          keyboardType: keyboardType,
          cursorWidth: 1.4,
          style: StudioCType.body(size: 15),
          decoration: InputDecoration(
            isDense: true,
            hintText: hint,
            hintStyle: StudioCType.body(
              size: 15,
              color: StudioCTokens.inkSoft.withValues(alpha: 0.75),
            ),
            contentPadding: const EdgeInsets.symmetric(vertical: 14),
            enabledBorder: const UnderlineInputBorder(
              borderSide: BorderSide(color: StudioCTokens.hairline),
            ),
            focusedBorder: const UnderlineInputBorder(
              borderSide: BorderSide(color: StudioCTokens.ink, width: 1.2),
            ),
            suffixIcon: suffix,
            suffixIconConstraints: const BoxConstraints(
              minWidth: 64,
              minHeight: 48,
            ),
          ),
        ),
      ],
    );
  }
}

/// Papirno zrno — proceduralna tekstura preko cele scene (fiksni seed).
class StudioCStage extends StatelessWidget {
  const StudioCStage({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Stack(
      textDirection: TextDirection.ltr,
      children: [
        child,
        const Positioned.fill(
          child: IgnorePointer(
            child: RepaintBoundary(
              child: CustomPaint(painter: _GrainPainter()),
            ),
          ),
        ),
      ],
    );
  }
}

class _GrainPainter extends CustomPainter {
  const _GrainPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final rnd = math.Random(7);
    final paint = Paint()
      ..color = StudioCTokens.ink.withValues(alpha: 0.028);
    final count =
        (size.width * size.height / 700).clamp(240, 3200).toInt();
    for (var i = 0; i < count; i++) {
      canvas.drawRect(
        Rect.fromLTWH(
          rnd.nextDouble() * size.width,
          rnd.nextDouble() * size.height,
          1,
          1,
        ),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _GrainPainter oldDelegate) => false;
}

/// Centrirana magazin-kolona: puna širina na telefonu, ograničena na desktopu.
class StudioCPageColumn extends StatelessWidget {
  const StudioCPageColumn({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.topCenter,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: StudioCTokens.pageWidth),
        child: child,
      ),
    );
  }
}

/// Vertikalna marginalija uz desnu ivicu strane.
class StudioCMarginalia extends StatelessWidget {
  const StudioCMarginalia({super.key, required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: Align(
        alignment: Alignment.centerRight,
        child: Padding(
          padding: const EdgeInsets.only(right: 5),
          child: RotatedBox(
            quarterTurns: 1,
            child: Text(
              text.toUpperCase(),
              style: StudioCType.meta(
                size: 8.5,
                letterSpacing: 2.6,
                color: StudioCTokens.inkSoft.withValues(alpha: 0.55),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Tačkasti „leader" — vodi oko između naslova i folia u sadržaju.
class StudioCLeader extends StatelessWidget {
  const StudioCLeader({super.key});

  @override
  Widget build(BuildContext context) {
    return const SizedBox(
      height: 2,
      child: CustomPaint(
        painter: _LeaderPainter(),
        size: Size(double.infinity, 2),
      ),
    );
  }
}

class _LeaderPainter extends CustomPainter {
  const _LeaderPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = StudioCTokens.inkSoft.withValues(alpha: 0.45);
    for (double x = 0; x < size.width; x += 6) {
      canvas.drawCircle(Offset(x, size.height / 2), 0.9, paint);
    }
  }

  @override
  bool shouldRepaint(covariant _LeaderPainter oldDelegate) => false;
}
