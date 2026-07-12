import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Dizajn tokeni Studija A — „Kinetik".
///
/// Atletska energija: volt na skoro-crnom, Archivo Black za display,
/// Inter Tight za UI. JEDAN akcenat — volt #CCFF00.
abstract final class StudioATheme {
  // ── Paleta ────────────────────────────────────────────────────────────
  static const Color bg = Color(0xFF0B0B0C);
  static const Color surface = Color(0xFF131316);
  static const Color surfaceRaised = Color(0xFF1A1A1F);
  static const Color volt = Color(0xFFCCFF00);
  static const Color ink = Color(0xFFF5F5F2);
  static const Color inkDim = Color(0xFF8A8A90);
  static const Color line = Color(0xFF26262B);

  /// Nagib „kinetičkih" elemenata (−2°) — dijagonalni identitet studija.
  static const double tilt = -0.0349; // radijani

  // ── Tipografija ───────────────────────────────────────────────────────
  /// Display — Archivo Black, uppercase, tesno.
  static TextStyle display({
    double size = 40,
    Color color = ink,
    double height = 0.96,
    double tracking = 0.0,
  }) {
    return GoogleFonts.archivoBlack(
      fontSize: size,
      color: color,
      height: height,
      letterSpacing: tracking,
    );
  }

  /// Mikro-labela — uppercase, širok tracking.
  static TextStyle label({
    double size = 10.5,
    Color color = inkDim,
    double tracking = 2.2,
    FontWeight weight = FontWeight.w700,
  }) {
    return GoogleFonts.interTight(
      fontSize: size,
      color: color,
      fontWeight: weight,
      letterSpacing: tracking,
      height: 1.2,
    );
  }

  /// Body — Inter Tight.
  static TextStyle body({
    double size = 14.5,
    Color color = ink,
    double height = 1.5,
    FontWeight weight = FontWeight.w500,
    double tracking = 0.1,
  }) {
    return GoogleFonts.interTight(
      fontSize: size,
      color: color,
      height: height,
      fontWeight: weight,
      letterSpacing: tracking,
    );
  }

  // ── ThemeData ─────────────────────────────────────────────────────────
  static ThemeData theme() {
    final base = ThemeData(
      brightness: Brightness.dark,
      useMaterial3: true,
      scaffoldBackgroundColor: bg,
    );
    return base.copyWith(
      colorScheme: const ColorScheme.dark(
        primary: volt,
        onPrimary: Color(0xFF0B0B0C),
        secondary: volt,
        onSecondary: Color(0xFF0B0B0C),
        surface: surface,
        onSurface: ink,
        outline: line,
        error: Color(0xFFFF5A5A),
      ),
      textTheme: GoogleFonts.interTightTextTheme(base.textTheme),
      dividerColor: line,
      splashColor: volt.withValues(alpha: 0.08),
      highlightColor: volt.withValues(alpha: 0.05),
      hoverColor: volt.withValues(alpha: 0.04),
      focusColor: volt.withValues(alpha: 0.12),
      textSelectionTheme: TextSelectionThemeData(
        cursorColor: volt,
        selectionColor: volt.withValues(alpha: 0.28),
        selectionHandleColor: volt,
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: surfaceRaised,
        behavior: SnackBarBehavior.floating,
        contentTextStyle: body(size: 13.5),
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(2)),
          side: BorderSide(color: line),
        ),
      ),
      tooltipTheme: TooltipThemeData(
        decoration: const BoxDecoration(
          color: surfaceRaised,
          borderRadius: BorderRadius.all(Radius.circular(2)),
          border: Border.fromBorderSide(BorderSide(color: line)),
        ),
        textStyle: body(size: 12),
      ),
    );
  }
}

/// Formatira cenu u RSD sa tačkom kao separatorom hiljada: 2500 → „2.500".
String studioARsd(int value) {
  final digits = value.toString();
  final out = StringBuffer();
  for (var i = 0; i < digits.length; i++) {
    final fromEnd = digits.length - i;
    out.write(digits[i]);
    if (fromEnd > 1 && fromEnd % 3 == 1) out.write('.');
  }
  return out.toString();
}

/// Decimalni broj u srpskom zapisu: 4.9 → „4,9".
String studioADec(double value, {int decimals = 1}) {
  return value.toStringAsFixed(decimals).replaceAll('.', ',');
}
