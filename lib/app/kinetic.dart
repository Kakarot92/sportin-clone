import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'theme.dart';

/// Small volt, uppercase, letter-spaced label used above headlines.
class Eyebrow extends StatelessWidget {
  const Eyebrow(this.text, {super.key, this.color = kVolt});

  final String text;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Text(
      text.toUpperCase(),
      style: GoogleFonts.interTight(
        color: color,
        fontSize: 12,
        fontWeight: FontWeight.w800,
        letterSpacing: 2.2,
      ),
    );
  }
}

/// Big Archivo Black uppercase headline.
class DisplayTitle extends StatelessWidget {
  const DisplayTitle(this.text, {super.key, this.size});

  final String text;
  final double? size;

  @override
  Widget build(BuildContext context) {
    final style = Theme.of(context).textTheme.headlineLarge!;
    return Text(
      text.toUpperCase(),
      style: size == null ? style : style.copyWith(fontSize: size),
    );
  }
}

/// Volt tick (skewed) + uppercase label + trailing hairline.
class SectionHeader extends StatelessWidget {
  const SectionHeader(this.text, {super.key});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Transform(
          transform: Matrix4.skewX(-0.35),
          alignment: Alignment.center,
          child: Container(width: 14, height: 14, color: kVolt),
        ),
        const SizedBox(width: 10),
        Text(
          text.toUpperCase(),
          style: GoogleFonts.interTight(
            fontWeight: FontWeight.w800,
            letterSpacing: 1.5,
            fontSize: 13,
            color: Theme.of(context).colorScheme.onSurface,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(child: Container(height: 1, color: Theme.of(context).dividerColor)),
      ],
    );
  }
}

/// Skewed volt badge (filled) or volt-outline badge.
class VoltBadge extends StatelessWidget {
  const VoltBadge(this.text, {super.key, this.filled = true});

  final String text;
  final bool filled;

  @override
  Widget build(BuildContext context) {
    final label = Text(
      text.toUpperCase(),
      style: GoogleFonts.interTight(
        color: filled ? kInk : kVolt,
        fontWeight: FontWeight.w800,
        fontSize: 11,
        letterSpacing: 1,
      ),
    );
    return Transform(
      transform: Matrix4.skewX(-0.2),
      alignment: Alignment.center,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        decoration: BoxDecoration(
          color: filled ? kVolt : Colors.transparent,
          border: filled ? null : Border.all(color: kVolt, width: 1.5),
        ),
        child: Transform(
          transform: Matrix4.skewX(0.2),
          alignment: Alignment.center,
          child: label,
        ),
      ),
    );
  }
}

/// Labeled dark input field (uppercase muted label above the field).
class KineticField extends StatelessWidget {
  const KineticField({
    super.key,
    required this.label,
    required this.controller,
    this.hint,
    this.obscure = false,
    this.keyboardType,
    this.validator,
    this.textCapitalization = TextCapitalization.none,
  });

  final String label;
  final TextEditingController controller;
  final String? hint;
  final bool obscure;
  final TextInputType? keyboardType;
  final String? Function(String?)? validator;
  final TextCapitalization textCapitalization;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label.toUpperCase(),
          style: GoogleFonts.interTight(
            color: kMutedDark,
            fontSize: 11,
            fontWeight: FontWeight.w700,
            letterSpacing: 1.6,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          obscureText: obscure,
          keyboardType: keyboardType,
          textCapitalization: textCapitalization,
          validator: validator,
          decoration: InputDecoration(hintText: hint),
        ),
      ],
    );
  }
}

/// Full-width skewed volt button with black bold text, optional icon and a
/// soft glow. Uses the Kinetik skew technique: Matrix4.skewX(-0.10) on the
/// container, counter-skew on the label so text stays upright.
/// Public API is identical to the old VoltButton — all existing callers work.
class VoltButton extends StatefulWidget {
  const VoltButton({
    super.key,
    required this.label,
    this.icon,
    this.onPressed,
    this.loading = false,
  });

  final String label;
  final IconData? icon;
  final VoidCallback? onPressed;
  final bool loading;

  @override
  State<VoltButton> createState() => _VoltButtonState();
}

class _VoltButtonState extends State<VoltButton> {
  bool _pressed = false;

  bool get _enabled => widget.onPressed != null && !widget.loading;

  @override
  Widget build(BuildContext context) {
    const skew = -0.10;
    return Semantics(
      button: true,
      label: widget.label,
      enabled: _enabled,
      child: GestureDetector(
        onTapDown: _enabled ? (_) => setState(() => _pressed = true) : null,
        onTapCancel: _enabled ? () => setState(() => _pressed = false) : null,
        onTapUp: _enabled
            ? (_) {
                setState(() => _pressed = false);
                widget.onPressed!();
              }
            : null,
        child: AnimatedScale(
          scale: _pressed ? 0.965 : 1.0,
          duration: const Duration(milliseconds: 140),
          curve: Curves.easeOutCubic,
          child: Transform(
            transform: Matrix4.skewX(skew),
            alignment: Alignment.center,
            child: Container(
              height: 56,
              decoration: BoxDecoration(
                color: _enabled ? kVolt : kVolt.withValues(alpha: 0.4),
                boxShadow: _enabled
                    ? [
                        BoxShadow(
                          color: kVolt.withValues(
                              alpha: _pressed ? 0.14 : 0.28),
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
                  child: widget.loading
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: kInk,
                          ),
                        )
                      : Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            if (widget.icon != null) ...[
                              Icon(widget.icon, size: 20, color: kInk),
                              const SizedBox(width: 10),
                            ],
                            Text(
                              widget.label.toUpperCase(),
                              style: GoogleFonts.archivoBlack(
                                fontSize: 14,
                                color: kInk,
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
