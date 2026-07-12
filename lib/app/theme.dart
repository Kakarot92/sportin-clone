import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

// --- Kinetik palette ---
const Color kVolt = Color(0xFFCCFF00); // volt-yellow accent
const Color kInk = Color(0xFF0B0B0C); // near-black background
const Color kInkElevated = Color(0xFF16171A); // cards
const Color kField = Color(0xFF1C1D21); // inputs
const Color kOffWhite = Color(0xFFF5F5F2);
const Color kMutedDark = Color(0xFF8C8C84);
const Color kLineDark = Color(0xFF2A2B2E);
const Color kDanger = Color(0xFFFF5C5C);

ThemeData buildDarkTheme() => _kinetik(Brightness.dark);
ThemeData buildLightTheme() => _kinetik(Brightness.light);

ThemeData _kinetik(Brightness brightness) {
  final isDark = brightness == Brightness.dark;
  final bg = isDark ? kInk : kOffWhite;
  final surface = isDark ? kInkElevated : Colors.white;
  final field = isDark ? kField : const Color(0xFFEAEAE4);
  final onBg = isDark ? kOffWhite : kInk;
  final muted = isDark ? kMutedDark : const Color(0xFF6C6C64);
  final line = isDark ? kLineDark : const Color(0xFFDEDCD6);

  final scheme = ColorScheme(
    brightness: brightness,
    primary: kVolt,
    onPrimary: kInk,
    secondary: kVolt,
    onSecondary: kInk,
    surface: bg,
    onSurface: onBg,
    surfaceContainerHighest: field,
    outline: line,
    error: kDanger,
    onError: kInk,
  );

  return ThemeData(
    useMaterial3: true,
    colorScheme: scheme,
    scaffoldBackgroundColor: bg,
    textTheme: _textTheme(onBg, muted),
    appBarTheme: AppBarTheme(
      backgroundColor: bg,
      foregroundColor: onBg,
      centerTitle: false,
      elevation: 0,
      scrolledUnderElevation: 0,
      titleTextStyle:
          GoogleFonts.archivoBlack(fontSize: 22, color: onBg, letterSpacing: -0.5),
    ),
    cardTheme: CardThemeData(
      color: surface,
      elevation: 0,
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
        side: BorderSide(color: line),
      ),
    ),
    dividerTheme: DividerThemeData(color: line, thickness: 1, space: 1),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: field,
      hintStyle: TextStyle(color: muted),
      contentPadding:
          const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
      border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide.none),
      enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide.none),
      focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: kVolt, width: 2)),
      errorStyle: const TextStyle(color: kDanger),
    ),
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        backgroundColor: kVolt,
        foregroundColor: kInk,
        disabledBackgroundColor: kVolt.withValues(alpha: 0.4),
        minimumSize: const Size.fromHeight(56),
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        textStyle: GoogleFonts.interTight(
            fontWeight: FontWeight.w800, fontSize: 15, letterSpacing: 1.4),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: kVolt,
        minimumSize: const Size.fromHeight(52),
        side: const BorderSide(color: kVolt, width: 1.5),
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        textStyle: GoogleFonts.interTight(
            fontWeight: FontWeight.w800, fontSize: 14, letterSpacing: 1.2),
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: onBg,
        textStyle:
            GoogleFonts.interTight(fontWeight: FontWeight.w700, fontSize: 14),
      ),
    ),
    navigationBarTheme: NavigationBarThemeData(
      backgroundColor: bg,
      elevation: 0,
      height: 68,
      indicatorColor: Colors.transparent,
      labelTextStyle: WidgetStateProperty.resolveWith(
        (states) => GoogleFonts.interTight(
          fontSize: 10.5,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.8,
          color: states.contains(WidgetState.selected) ? kVolt : muted,
        ),
      ),
      iconTheme: WidgetStateProperty.resolveWith(
        (states) => IconThemeData(
          color: states.contains(WidgetState.selected) ? kVolt : muted,
          size: 24,
        ),
      ),
    ),
    snackBarTheme: SnackBarThemeData(
      backgroundColor: surface,
      contentTextStyle: TextStyle(color: onBg),
      behavior: SnackBarBehavior.floating,
      shape:
          RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
    ),
    switchTheme: SwitchThemeData(
      thumbColor: WidgetStateProperty.resolveWith((s) =>
          s.contains(WidgetState.selected) ? kInk : null),
      trackColor: WidgetStateProperty.resolveWith((s) =>
          s.contains(WidgetState.selected) ? kVolt : null),
    ),
  );
}

TextTheme _textTheme(Color onBg, Color muted) {
  TextStyle display(double size, {double h = 0.9, double ls = -1}) =>
      GoogleFonts.archivoBlack(
          fontSize: size, height: h, letterSpacing: ls, color: onBg);

  final body = GoogleFonts.interTightTextTheme();
  return body
      .copyWith(
        displayLarge: display(56),
        displayMedium: display(46),
        displaySmall: display(38),
        headlineLarge: display(40, h: 0.92),
        headlineMedium: display(32, h: 0.92),
        headlineSmall: display(25, h: 0.95, ls: -0.5),
        titleLarge: GoogleFonts.interTight(
            fontSize: 20, fontWeight: FontWeight.w800, color: onBg),
        titleMedium: GoogleFonts.interTight(
            fontSize: 15, fontWeight: FontWeight.w700, color: onBg),
        bodyLarge: GoogleFonts.interTight(fontSize: 15, color: onBg),
        bodyMedium: GoogleFonts.interTight(fontSize: 14, color: muted),
      )
      .apply(bodyColor: onBg, displayColor: onBg);
}
