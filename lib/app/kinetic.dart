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

/// Volt tick + uppercase label + trailing hairline.
class SectionHeader extends StatelessWidget {
  const SectionHeader(this.text, {super.key});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(width: 14, height: 14, color: kVolt),
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

/// Full-width volt button with black bold text, optional icon and a soft glow.
class VoltButton extends StatelessWidget {
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
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        boxShadow: onPressed == null
            ? null
            : [
                BoxShadow(
                  color: kVolt.withValues(alpha: 0.35),
                  blurRadius: 26,
                  spreadRadius: -6,
                ),
              ],
      ),
      child: FilledButton(
        onPressed: loading ? null : onPressed,
        child: loading
            ? const SizedBox(
                height: 20,
                width: 20,
                child: CircularProgressIndicator(strokeWidth: 2, color: kInk),
              )
            : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (icon != null) ...[
                    Icon(icon, size: 20),
                    const SizedBox(width: 10),
                  ],
                  Text(label.toUpperCase()),
                ],
              ),
      ),
    );
  }
}
