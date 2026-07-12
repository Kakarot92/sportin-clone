import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Dizajn-tokeni Studija E — „Dubina" (neon cinema).
///
/// Dubina se gradi svetlinom sloja, ne senkama: [bg] je najdublji plan,
/// [layer1] i [layer2] su bliži gledaocu. Neon je začin, ne supa —
/// cyan je primarni akcenat, violet sekundarni.
abstract final class StudioEColors {
  static const Color bg = Color(0xFF0C0F14);
  static const Color layer1 = Color(0xFF121722);
  static const Color layer2 = Color(0xFF1A2130);
  static const Color hairline = Color(0xFF232B3D);

  static const Color cyan = Color(0xFF53E8D4);
  static const Color violet = Color(0xFFB26BFF);

  static const Color text = Color(0xFFEDF1F7);
  static const Color textDim = Color(0xFF8D97A8);

  /// Tamni tekst preko cyan CTA površina (kontrast > 10:1).
  static const Color onCyan = Color(0xFF06241F);

  static const LinearGradient neon = LinearGradient(
    colors: [cyan, violet],
  );
}

/// Spacing skala Studija E (4pt grid).
abstract final class StudioESpace {
  static const double xs = 4;
  static const double s = 8;
  static const double m = 12;
  static const double l = 16;
  static const double xl = 20;
  static const double xxl = 28;

  /// Vertikalni ritam između sekcija ekrana.
  static const double section = 28;
}

/// Formatiranje brojeva po srpskoj konvenciji.
abstract final class StudioEFmt {
  /// `94.2` → `94,2` (decimalni zarez).
  static String decimal(double v, {int digits = 1}) =>
      v.toStringAsFixed(digits).replaceAll('.', ',');

  /// `2500` → `2.500` (tačka kao hiljadarski separator).
  static String thousands(int value) {
    final s = value.toString();
    final b = StringBuffer();
    for (var i = 0; i < s.length; i++) {
      if (i > 0 && (s.length - i) % 3 == 0) b.write('.');
      b.write(s[i]);
    }
    return b.toString();
  }

  /// `-5.6` → `−5,6` (pravi minus, U+2212).
  static String signed(double v, {int digits = 1}) {
    final sign = v < 0 ? '−' : '+';
    return '$sign${decimal(v.abs(), digits: digits)}';
  }
}

/// Tema Studija E: Syne za display, IBM Plex Sans za body.
abstract final class StudioETheme {
  static ThemeData build() {
    final base = ThemeData(brightness: Brightness.dark, useMaterial3: true);
    final textTheme = GoogleFonts.ibmPlexSansTextTheme(base.textTheme)
        .apply(bodyColor: StudioEColors.text, displayColor: StudioEColors.text)
        .copyWith(
          displayMedium: GoogleFonts.syne(
            fontSize: 40,
            fontWeight: FontWeight.w800,
            color: StudioEColors.text,
            height: 1.05,
            letterSpacing: -0.5,
          ),
          displaySmall: GoogleFonts.syne(
            fontSize: 30,
            fontWeight: FontWeight.w800,
            color: StudioEColors.text,
            height: 1.1,
            letterSpacing: -0.3,
          ),
          headlineMedium: GoogleFonts.syne(
            fontSize: 24,
            fontWeight: FontWeight.w700,
            color: StudioEColors.text,
            height: 1.15,
          ),
          headlineSmall: GoogleFonts.syne(
            fontSize: 19,
            fontWeight: FontWeight.w700,
            color: StudioEColors.text,
            height: 1.2,
          ),
          titleMedium: GoogleFonts.ibmPlexSans(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: StudioEColors.text,
            height: 1.3,
          ),
          bodyLarge: GoogleFonts.ibmPlexSans(
            fontSize: 16,
            fontWeight: FontWeight.w400,
            color: StudioEColors.text,
            height: 1.5,
          ),
          bodyMedium: GoogleFonts.ibmPlexSans(
            fontSize: 14.5,
            fontWeight: FontWeight.w400,
            color: StudioEColors.text,
            height: 1.5,
          ),
          bodySmall: GoogleFonts.ibmPlexSans(
            fontSize: 12.5,
            fontWeight: FontWeight.w400,
            color: StudioEColors.textDim,
            height: 1.4,
          ),
          labelLarge: GoogleFonts.ibmPlexSans(
            fontSize: 15,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.2,
            color: StudioEColors.text,
          ),
          labelSmall: GoogleFonts.ibmPlexSans(
            fontSize: 11,
            fontWeight: FontWeight.w600,
            letterSpacing: 1.6,
            color: StudioEColors.textDim,
          ),
        );

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: StudioEColors.bg,
      colorScheme: const ColorScheme.dark(
        primary: StudioEColors.cyan,
        onPrimary: StudioEColors.onCyan,
        secondary: StudioEColors.violet,
        onSecondary: Color(0xFF1C0A33),
        surface: StudioEColors.layer1,
        onSurface: StudioEColors.text,
        onSurfaceVariant: StudioEColors.textDim,
        outline: StudioEColors.hairline,
        error: Color(0xFFFF7A8A),
        onError: Color(0xFF33060C),
      ),
      textTheme: textTheme,
      dividerColor: StudioEColors.hairline,
      splashColor: StudioEColors.cyan.withValues(alpha: 0.08),
      highlightColor: StudioEColors.cyan.withValues(alpha: 0.05),
      hoverColor: StudioEColors.cyan.withValues(alpha: 0.04),
      textSelectionTheme: TextSelectionThemeData(
        cursorColor: StudioEColors.cyan,
        selectionColor: StudioEColors.cyan.withValues(alpha: 0.25),
        selectionHandleColor: StudioEColors.cyan,
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: StudioEColors.cyan,
          minimumSize: const Size(48, 48),
          textStyle: GoogleFonts.ibmPlexSans(
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: StudioEColors.layer2,
        behavior: SnackBarBehavior.floating,
        contentTextStyle: GoogleFonts.ibmPlexSans(
          fontSize: 14,
          color: StudioEColors.text,
          height: 1.4,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
          side: const BorderSide(color: StudioEColors.hairline),
        ),
      ),
    );
  }
}
