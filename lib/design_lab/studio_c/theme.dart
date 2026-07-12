import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Studio C — „Editorial Noir": dizajn-tokeni.
///
/// Bone papir, ink tekst, terakota isključivo za male naglaske (broj, linija,
/// CTA tekst), hairline linije od 1px. Luksuz kroz suzdržanost.
abstract final class StudioCTokens {
  // Paleta
  static const Color bone = Color(0xFFF4EFE6);
  static const Color ink = Color(0xFF17140F);

  /// Sekundarni tekst — 6,1:1 na bone podlozi.
  static const Color inkSoft = Color(0xFF5C554A);
  static const Color terracotta = Color(0xFFC4572E);
  static const Color hairline = Color(0xFFD8D0C0);

  /// Standardna horizontalna margina „strane".
  static const double margin = 24;

  /// Maksimalna širina kolone — magazin, ne razvučen web.
  static const double pageWidth = 640;

  // Režija animacija
  static const Duration beat = Duration(milliseconds: 320);
  static const Curve ease = Curves.easeOutQuart;
}

/// Tipografska skala Studija C.
///
/// Display: Fraunces (italik dozvoljen za numerale).
/// UI/body: Inter, kickeri uppercase sa širokim letterSpacing-om.
abstract final class StudioCType {
  /// Serif display — naslovi, imena, veliki brojevi.
  static TextStyle display(
    double size, {
    FontWeight weight = FontWeight.w600,
    FontStyle style = FontStyle.normal,
    Color color = StudioCTokens.ink,
    double? height,
    double? letterSpacing,
  }) {
    return GoogleFonts.fraunces(
      fontSize: size,
      fontWeight: weight,
      fontStyle: style,
      color: color,
      height: height ?? 1.08,
      letterSpacing: letterSpacing ?? (size >= 28 ? -0.5 : 0),
    );
  }

  /// Serif numeral sa tabularnim ciframa (za velike brojeve i ose).
  static TextStyle numeral(
    double size, {
    FontWeight weight = FontWeight.w500,
    FontStyle style = FontStyle.italic,
    Color color = StudioCTokens.ink,
  }) {
    return GoogleFonts.fraunces(
      fontSize: size,
      fontWeight: weight,
      fontStyle: style,
      color: color,
      height: 1.0,
      fontFeatures: const [FontFeature.tabularFigures()],
    );
  }

  /// Uppercase kicker labela — poziv sa `.toUpperCase()` na sadržaju.
  static TextStyle kicker({
    double size = 10.5,
    Color color = StudioCTokens.inkSoft,
    FontWeight weight = FontWeight.w600,
    double letterSpacing = 1.6,
  }) {
    return GoogleFonts.inter(
      fontSize: size,
      fontWeight: weight,
      letterSpacing: letterSpacing,
      color: color,
      height: 1.35,
    );
  }

  /// Body tekst.
  static TextStyle body({
    double size = 14.5,
    Color color = StudioCTokens.ink,
    FontWeight weight = FontWeight.w400,
    double height = 1.55,
    FontStyle style = FontStyle.normal,
  }) {
    return GoogleFonts.inter(
      fontSize: size,
      color: color,
      fontWeight: weight,
      height: height,
      fontStyle: style,
    );
  }

  /// Sitna meta beleška (vreme, folio, marginalija).
  static TextStyle meta({
    double size = 10,
    Color color = StudioCTokens.inkSoft,
    double letterSpacing = 1.2,
    FontWeight weight = FontWeight.w500,
  }) {
    return GoogleFonts.inter(
      fontSize: size,
      color: color,
      letterSpacing: letterSpacing,
      fontWeight: weight,
      height: 1.3,
      fontFeatures: const [FontFeature.tabularFigures()],
    );
  }

  /// Tabularni Inter za ledger kolone.
  static TextStyle tabular({
    double size = 12.5,
    Color color = StudioCTokens.ink,
    FontWeight weight = FontWeight.w400,
  }) {
    return GoogleFonts.inter(
      fontSize: size,
      color: color,
      fontWeight: weight,
      height: 1.2,
      fontFeatures: const [FontFeature.tabularFigures()],
    );
  }
}

/// Formatiranje brojeva po srpskoj konvenciji (zarez, tačka za hiljade).
abstract final class StudioCFmt {
  /// 94.2 → „94,2"
  static String dec(double v, {int digits = 1}) =>
      v.toStringAsFixed(digits).replaceAll('.', ',');

  /// 2500 → „2.500"
  static String thousands(int v) {
    final s = v.toString();
    final out = StringBuffer();
    for (var i = 0; i < s.length; i++) {
      if (i > 0 && (s.length - i) % 3 == 0) out.write('.');
      out.write(s[i]);
    }
    return out.toString();
  }

  /// 3 → „03"
  static String two(int v) => v.toString().padLeft(2, '0');

  /// Delta sa pravim minusom (U+2212): -5.6 → „−5,6"
  static String delta(double v, {int digits = 1}) {
    final sign = v < 0 ? '−' : '+';
    return '$sign${dec(v.abs(), digits: digits)}';
  }
}

/// Tema Studija C — jedan MaterialApp, jedna štampa.
abstract final class StudioCTheme {
  static ThemeData build() {
    final base = ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      scaffoldBackgroundColor: StudioCTokens.bone,
      colorScheme: const ColorScheme.light(
        primary: StudioCTokens.ink,
        onPrimary: StudioCTokens.bone,
        secondary: StudioCTokens.terracotta,
        onSecondary: StudioCTokens.bone,
        surface: StudioCTokens.bone,
        onSurface: StudioCTokens.ink,
        outline: StudioCTokens.hairline,
        error: StudioCTokens.terracotta,
        onError: StudioCTokens.bone,
      ),
      splashFactory: NoSplash.splashFactory,
      highlightColor: StudioCTokens.ink.withValues(alpha: 0.05),
      hoverColor: StudioCTokens.ink.withValues(alpha: 0.03),
      focusColor: StudioCTokens.ink.withValues(alpha: 0.06),
      dividerColor: StudioCTokens.hairline,
    );
    return base.copyWith(
      textTheme: GoogleFonts.interTextTheme(base.textTheme).apply(
        bodyColor: StudioCTokens.ink,
        displayColor: StudioCTokens.ink,
      ),
      textSelectionTheme: TextSelectionThemeData(
        cursorColor: StudioCTokens.ink,
        selectionColor: StudioCTokens.terracotta.withValues(alpha: 0.22),
        selectionHandleColor: StudioCTokens.terracotta,
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: StudioCTokens.ink,
        contentTextStyle: GoogleFonts.inter(
          fontSize: 13,
          color: StudioCTokens.bone,
          height: 1.4,
        ),
        behavior: SnackBarBehavior.floating,
        shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
        elevation: 0,
      ),
    );
  }
}
