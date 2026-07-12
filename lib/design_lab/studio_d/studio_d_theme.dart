import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Studio D — „Blok". Zajednički vizuelni rečnik: paleta, tipografija,
/// hard-shadow paneli, taktilna dugmad, tagovi, stikeri, perforacije.
///
/// Pravila bloka: 2px ink okvir, senka (4,4) bez blura, nula zaobljenja,
/// Space Grotesk za reči, Space Mono za brojeve. Haos samo u rotaciji stikera.
abstract final class StudioDColors {
  static const paper = Color(0xFFF2F0EB);
  static const ink = Color(0xFF111111);
  static const white = Color(0xFFFFFFFF);
  static const yellow = Color(0xFFFFD02F);
  static const blue = Color(0xFF2B5BFF);
  static const red = Color(0xFFFF4D2E);
  static const green = Color(0xFF27AE60);

  /// Zebra pruga za tabele — papir spušten za nijansu.
  static const zebra = Color(0xFFE8E5DD);

  /// Sekundarni tekst na belom/papiru (kontrast ≥ 4.5:1).
  static const inkSoft = Color(0xFF5C5A55);
}

/// Tipografska kasa Studija D.
///
/// NAPOMENA: Space Mono postoji samo u 400 i 700 — ne tražiti druge težine.
abstract final class StudioDType {
  static TextStyle grotesk({
    double size = 14,
    FontWeight weight = FontWeight.w500,
    Color color = StudioDColors.ink,
    double? height,
    double? spacing,
  }) {
    return GoogleFonts.spaceGrotesk(
      fontSize: size,
      fontWeight: weight,
      color: color,
      height: height,
      letterSpacing: spacing,
    );
  }

  static TextStyle mono({
    double size = 12,
    FontWeight weight = FontWeight.w400,
    Color color = StudioDColors.ink,
    double? height,
    double? spacing,
  }) {
    return GoogleFonts.spaceMono(
      fontSize: size,
      fontWeight: weight,
      color: color,
      height: height,
      letterSpacing: spacing,
    );
  }
}

/// Čvrsta senka bloka: offset bez blura. Jedina dozvoljena senka u studiju.
List<BoxShadow> studioDShadow([double offset = 4]) {
  return [
    BoxShadow(color: StudioDColors.ink, offset: Offset(offset, offset)),
  ];
}

/// „2.500" iz 2500 — tačka kao separator hiljada.
String studioDRsd(int value) {
  final digits = value.toString();
  final buf = StringBuffer();
  for (var i = 0; i < digits.length; i++) {
    buf.write(digits[i]);
    final fromEnd = digits.length - 1 - i;
    if (fromEnd > 0 && fromEnd % 3 == 0) {
      buf.write('.');
    }
  }
  return buf.toString();
}

/// Delta sa predznakom: -5.6 → „-5.6", +0.4 → „+0.4".
String studioDDelta(double d) {
  if (d.abs() < 0.05) return '0.0';
  final body = d.abs().toStringAsFixed(1);
  return d < 0 ? '-$body' : '+$body';
}

/// Statični panel: beli blok, 2px okvir, tvrda senka.
class StudioDPanel extends StatelessWidget {
  const StudioDPanel({
    super.key,
    required this.child,
    this.color = StudioDColors.white,
    this.shadow = 4,
    this.padding,
    this.borderWidth = 2,
  });

  final Widget child;
  final Color color;
  final double shadow;
  final EdgeInsetsGeometry? padding;
  final double borderWidth;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: padding,
      decoration: BoxDecoration(
        color: color,
        border: Border.all(color: StudioDColors.ink, width: borderWidth),
        boxShadow: shadow > 0 ? studioDShadow(shadow) : null,
      ),
      child: child,
    );
  }
}

/// Taktilno dugme-blok: na pritisak klizi u sopstvenu senku
/// (translate + senka se skrati) — signature feedback studija.
class StudioDPressable extends StatefulWidget {
  const StudioDPressable({
    super.key,
    required this.onTap,
    required this.child,
    this.color = StudioDColors.white,
    this.shadow = 4,
    this.padding = EdgeInsets.zero,
    this.borderWidth = 2,
  });

  final VoidCallback onTap;
  final Widget child;
  final Color color;
  final double shadow;
  final EdgeInsetsGeometry padding;
  final double borderWidth;

  @override
  State<StudioDPressable> createState() => _StudioDPressableState();
}

class _StudioDPressableState extends State<StudioDPressable> {
  bool _down = false;

  void _release() {
    Future.delayed(const Duration(milliseconds: 90), () {
      if (mounted) setState(() => _down = false);
    });
  }

  @override
  Widget build(BuildContext context) {
    final rest = widget.shadow;
    final travel = rest > 0 ? rest - 1 : 1.5;
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTapDown: (_) => setState(() => _down = true),
      onTapUp: (_) => _release(),
      onTapCancel: () => setState(() => _down = false),
      onTap: widget.onTap,
      child: TweenAnimationBuilder<double>(
        tween: Tween(begin: 0, end: _down ? 1 : 0),
        duration: const Duration(milliseconds: 90),
        curve: Curves.easeOutQuad,
        builder: (context, t, child) {
          return Transform.translate(
            offset: Offset(travel * t, travel * t),
            child: Container(
              padding: widget.padding,
              decoration: BoxDecoration(
                color: widget.color,
                border: Border.all(
                  color: StudioDColors.ink,
                  width: widget.borderWidth,
                ),
                boxShadow: rest > 0
                    ? [
                        BoxShadow(
                          color: StudioDColors.ink,
                          offset: Offset(rest - travel * t, rest - travel * t),
                        ),
                      ]
                    : null,
              ),
              child: child,
            ),
          );
        },
        child: widget.child,
      ),
    );
  }
}

/// Mala uppercase mono etiketa u okviru — „tag" blok.
class StudioDTag extends StatelessWidget {
  const StudioDTag(
    this.text, {
    super.key,
    this.fill = StudioDColors.white,
    this.textColor = StudioDColors.ink,
    this.size = 9.5,
    this.padding = const EdgeInsets.symmetric(horizontal: 7, vertical: 4),
  });

  final String text;
  final Color fill;
  final Color textColor;
  final double size;
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: padding,
      decoration: BoxDecoration(
        color: fill,
        border: Border.all(color: StudioDColors.ink, width: 1.5),
      ),
      child: Text(
        text.toUpperCase(),
        style: StudioDType.mono(
          size: size,
          weight: FontWeight.w700,
          color: textColor,
          spacing: 0.4,
        ),
      ),
    );
  }
}

/// Rotirani sticker-badge. Rotacija je JEDINI dozvoljeni haos — retko i namerno.
class StudioDSticker extends StatelessWidget {
  const StudioDSticker(
    this.text, {
    super.key,
    this.color = StudioDColors.yellow,
    this.textColor = StudioDColors.ink,
    this.angleDeg = -3,
    this.size = 10.5,
    this.icon,
  });

  final String text;
  final Color color;
  final Color textColor;
  final double angleDeg;
  final double size;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    return Transform.rotate(
      angle: angleDeg * math.pi / 180,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
        decoration: BoxDecoration(
          color: color,
          border: Border.all(color: StudioDColors.ink, width: 2),
          boxShadow: studioDShadow(2),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon != null) ...[
              Icon(icon, size: size + 2, color: textColor),
              const SizedBox(width: 4),
            ],
            Text(
              text.toUpperCase(),
              textAlign: TextAlign.center,
              style: StudioDType.mono(
                size: size,
                weight: FontWeight.w700,
                color: textColor,
                height: 1.25,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Blok-monogram: inicijali u obojenom kvadratu (bez fotografija — proceduralno).
class StudioDMonogram extends StatelessWidget {
  const StudioDMonogram(
    this.name, {
    super.key,
    this.size = 56,
    this.paletteIndex = 0,
  });

  final String name;
  final double size;
  final int paletteIndex;

  static const _fills = [
    StudioDColors.yellow,
    StudioDColors.blue,
    StudioDColors.red,
    StudioDColors.green,
  ];

  String get _initials {
    final parts =
        name.trim().split(RegExp(r'\s+')).where((p) => p.isNotEmpty).toList();
    if (parts.isEmpty) return '?';
    if (parts.length == 1) return parts.first[0].toUpperCase();
    return (parts[0][0] + parts[1][0]).toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    final fill = _fills[paletteIndex % _fills.length];
    final fg =
        fill == StudioDColors.blue ? StudioDColors.white : StudioDColors.ink;
    return Container(
      width: size,
      height: size,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: fill,
        border: Border.all(color: StudioDColors.ink, width: 2),
        boxShadow: studioDShadow(3),
      ),
      child: Text(
        _initials,
        style: StudioDType.grotesk(
          size: size * 0.36,
          weight: FontWeight.w700,
          color: fg,
        ),
      ),
    );
  }
}

/// Milimetarski papir ispod svega — grid koji drži haos.
class StudioDGridPaper extends StatelessWidget {
  const StudioDGridPaper({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return CustomPaint(painter: const _StudioDGridPainter(), child: child);
  }
}

class _StudioDGridPainter extends CustomPainter {
  const _StudioDGridPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final bg = Paint()..color = StudioDColors.paper;
    canvas.drawRect(Offset.zero & size, bg);
    final line = Paint()
      ..color = StudioDColors.ink.withValues(alpha: 0.05)
      ..strokeWidth = 1;
    const step = 26.0;
    for (var x = step; x < size.width; x += step) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), line);
    }
    for (var y = step; y < size.height; y += step) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), line);
    }
  }

  @override
  bool shouldRepaint(covariant _StudioDGridPainter oldDelegate) => false;
}

/// Isprekidana linija (perforacija) — horizontalna ili vertikalna.
class StudioDDashedLine extends StatelessWidget {
  const StudioDDashedLine({
    super.key,
    this.axis = Axis.horizontal,
    this.color = StudioDColors.ink,
    this.thickness = 2,
    this.dash = 6,
    this.gap = 5,
  });

  final Axis axis;
  final Color color;
  final double thickness;
  final double dash;
  final double gap;

  @override
  Widget build(BuildContext context) {
    final painter = _StudioDDashPainter(
      axis: axis,
      color: color,
      thickness: thickness,
      dash: dash,
      gap: gap,
    );
    if (axis == Axis.horizontal) {
      return SizedBox(
        height: thickness,
        width: double.infinity,
        child: CustomPaint(painter: painter),
      );
    }
    return SizedBox(
      width: thickness,
      child: CustomPaint(painter: painter),
    );
  }
}

class _StudioDDashPainter extends CustomPainter {
  const _StudioDDashPainter({
    required this.axis,
    required this.color,
    required this.thickness,
    required this.dash,
    required this.gap,
  });

  final Axis axis;
  final Color color;
  final double thickness;
  final double dash;
  final double gap;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = color;
    if (axis == Axis.horizontal) {
      var x = 0.0;
      while (x < size.width) {
        canvas.drawRect(
          Rect.fromLTWH(x, 0, math.min(dash, size.width - x), thickness),
          paint,
        );
        x += dash + gap;
      }
    } else {
      var y = 0.0;
      while (y < size.height) {
        canvas.drawRect(
          Rect.fromLTWH(0, y, thickness, math.min(dash, size.height - y)),
          paint,
        );
        y += dash + gap;
      }
    }
  }

  @override
  bool shouldRepaint(covariant _StudioDDashPainter oldDelegate) {
    return oldDelegate.axis != axis ||
        oldDelegate.color != color ||
        oldDelegate.thickness != thickness;
  }
}

/// Proceduralni barkod — deterministički raspored traka, nula asseta.
class StudioDBarcode extends StatelessWidget {
  const StudioDBarcode({super.key, this.width = 68, this.height = 30});

  final double width;
  final double height;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      height: height,
      child: const CustomPaint(painter: _StudioDBarcodePainter()),
    );
  }
}

class _StudioDBarcodePainter extends CustomPainter {
  const _StudioDBarcodePainter();

  // Šara: naizmenično traka/razmak, širine u jedinicama.
  static const _pattern = [
    3, 1, 1, 2, 2, 1, 1, 1, 3, 2, 1, 1, 2, 1, 1, 3, 1, 2, //
    1, 1, 2, 2, 1, 1, 3, 1, 1, 2, 1, 1, 2, 3, 1, 1,
  ];

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = StudioDColors.ink;
    final totalUnits = _pattern.fold<int>(0, (a, b) => a + b);
    final unit = size.width / totalUnits;
    var x = 0.0;
    for (var i = 0; i < _pattern.length; i++) {
      final w = _pattern[i] * unit;
      if (i.isEven) {
        canvas.drawRect(Rect.fromLTWH(x, 0, w, size.height), paint);
      }
      x += w;
    }
  }

  @override
  bool shouldRepaint(covariant _StudioDBarcodePainter oldDelegate) => false;
}

/// Naslov sekcije: žuti kvadratić + uppercase naslov + opcioni tag desno.
class StudioDSectionLabel extends StatelessWidget {
  const StudioDSectionLabel(this.title, {super.key, this.trailing});

  final String title;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        children: [
          Container(
            width: 10,
            height: 10,
            decoration: BoxDecoration(
              color: StudioDColors.yellow,
              border: Border.all(color: StudioDColors.ink, width: 2),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              title.toUpperCase(),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: StudioDType.grotesk(
                size: 13.5,
                weight: FontWeight.w700,
                spacing: 1.1,
              ),
            ),
          ),
          ?trailing,
        ],
      ),
    );
  }
}

/// Gornja traka za push ekrane: blok-strelica nazad + naslov + opcioni tag.
class StudioDTopBar extends StatelessWidget {
  const StudioDTopBar({super.key, required this.title, this.trailing});

  final String title;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 10),
      decoration: const BoxDecoration(
        color: StudioDColors.paper,
        border: Border(
          bottom: BorderSide(color: StudioDColors.ink, width: 2),
        ),
      ),
      child: Row(
        children: [
          StudioDPressable(
            shadow: 3,
            padding: const EdgeInsets.all(14),
            onTap: () => Navigator.of(context).maybePop(),
            child: const Icon(
              Icons.arrow_back_sharp,
              size: 20,
              color: StudioDColors.ink,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              title.toUpperCase(),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: StudioDType.grotesk(
                size: 16,
                weight: FontWeight.w700,
                spacing: 1,
              ),
            ),
          ),
          ?trailing,
        ],
      ),
    );
  }
}

/// Standardna stranica taba: grid-papir + centrirana kolona (max 560).
class StudioDPage extends StatelessWidget {
  const StudioDPage({
    super.key,
    required this.children,
    this.padding = const EdgeInsets.fromLTRB(16, 18, 16, 28),
  });

  final List<Widget> children;
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) {
    return StudioDGridPaper(
      child: SafeArea(
        bottom: false,
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 560),
            child: ListView(padding: padding, children: children),
          ),
        ),
      ),
    );
  }
}

/// Ulazna animacija liste: pad + klizanje, kaskadno po indeksu.
/// Kriva: easeOutCubic kroz Interval — nikad linearno.
class StudioDStagger extends StatelessWidget {
  const StudioDStagger({super.key, required this.index, required this.child});

  final int index;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final start = math.min(index * 0.12, 0.55);
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: const Duration(milliseconds: 640),
      builder: (context, raw, child) {
        final t = Interval(start, 1, curve: Curves.easeOutCubic).transform(raw);
        return Opacity(
          opacity: t,
          child: Transform.translate(
            offset: Offset(0, 18 * (1 - t)),
            child: child,
          ),
        );
      },
      child: child,
    );
  }
}

/// Push tranzicija studija: ulaz klizi zdesna (easeOutQuart),
/// stari ekran paralaksno beži ulevo.
Route<T> studioDRoute<T>(Widget page) {
  return PageRouteBuilder<T>(
    transitionDuration: const Duration(milliseconds: 340),
    reverseTransitionDuration: const Duration(milliseconds: 280),
    pageBuilder: (context, animation, secondaryAnimation) => page,
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      final slideIn = Tween<Offset>(
        begin: const Offset(1, 0),
        end: Offset.zero,
      ).animate(
        CurvedAnimation(
          parent: animation,
          curve: Curves.easeOutQuart,
          reverseCurve: Curves.easeInQuart,
        ),
      );
      final parallax = Tween<Offset>(
        begin: Offset.zero,
        end: const Offset(-0.16, 0),
      ).animate(
        CurvedAnimation(
          parent: secondaryAnimation,
          curve: Curves.easeInOutCubic,
        ),
      );
      return SlideTransition(
        position: parallax,
        child: SlideTransition(position: slideIn, child: child),
      );
    },
  );
}

/// Crni toster sa žutim mono tekstom — jedina „poruka sistema" u studiju.
void studioDToast(
  BuildContext context,
  String message, {
  Color accent = StudioDColors.yellow,
}) {
  final width = math.min(420.0, MediaQuery.sizeOf(context).width - 32);
  ScaffoldMessenger.of(context)
    ..hideCurrentSnackBar()
    ..showSnackBar(
      SnackBar(
        width: width,
        behavior: SnackBarBehavior.floating,
        backgroundColor: StudioDColors.ink,
        shape: const RoundedRectangleBorder(),
        duration: const Duration(milliseconds: 2600),
        content: Text(
          message.toUpperCase(),
          style: StudioDType.mono(
            size: 11,
            weight: FontWeight.w700,
            color: accent,
            height: 1.35,
          ),
        ),
      ),
    );
}
