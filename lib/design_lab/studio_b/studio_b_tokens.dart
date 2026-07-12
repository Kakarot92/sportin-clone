import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Dizajn tokeni Studija B — „Aurora": paleta, tipografija i formatiranje.
///
/// Kontrast (na belom / glass panelu ~belom):
/// - [StudioBTokens.ink]        ≈ 14.0 : 1
/// - [StudioBTokens.inkSoft]    ≈  5.5 : 1
/// - [StudioBTokens.violetDeep] ≈  6.8 : 1
/// - [StudioBTokens.mintDeep]   ≈  5.0 : 1
/// - belo na [StudioBTokens.violet] ≈ 4.7 : 1 (CTA)
abstract final class StudioBTokens {
  // ── Aurora pozadina ──────────────────────────────────────────────
  static const Color bgBlue = Color(0xFFE9F1FF);
  static const Color bgPink = Color(0xFFFCE9F5);
  static const Color bgMint = Color(0xFFE7FBF2);

  /// Blobovi mesha — zasićenije pastele da pozadina „diše".
  static const Color blobBlue = Color(0xFFB9D4FF);
  static const Color blobPink = Color(0xFFF9C9E6);
  static const Color blobMint = Color(0xFFBCEEDB);
  static const Color blobViolet = Color(0xFFD8CFFF);

  // ── Tekst ────────────────────────────────────────────────────────
  static const Color ink = Color(0xFF1C2733);
  static const Color inkSoft = Color(0xFF5A6B7C);

  // ── Akcenti ──────────────────────────────────────────────────────
  static const Color violet = Color(0xFF6F5FE6);
  static const Color violetDark = Color(0xFF5B4BD6);
  static const Color violetDeep = Color(0xFF5646C4);
  static const Color mint = Color(0xFF2FB593);
  static const Color mintDeep = Color(0xFF177E63);
  static const Color rose = Color(0xFFB03A52);
  static const Color star = Color(0xFFE8A33D);

  /// Gradijenti za avatare — biraju se deterministički, hešom imena.
  static const List<List<Color>> avatarGradients = [
    [Color(0xFF7B6CF6), Color(0xFF4F3ECC)],
    [Color(0xFF37B893), Color(0xFF1B7C68)],
    [Color(0xFFE87BB4), Color(0xFFB84A86)],
    [Color(0xFF5A8DEE), Color(0xFF3B5FC7)],
  ];

  /// CTA gradijent — obe boje drže ≥ 4.5:1 sa belim tekstom.
  static const List<Color> ctaGradient = [violet, violetDark];

  // ── Tipografija ──────────────────────────────────────────────────
  /// Sora — display / naslovi.
  static TextStyle display({
    double size = 24,
    FontWeight weight = FontWeight.w600,
    Color color = ink,
    double? height,
    double? spacing,
  }) {
    return GoogleFonts.sora(
      fontSize: size,
      fontWeight: weight,
      color: color,
      height: height,
      letterSpacing: spacing,
    );
  }

  /// Manrope — body tekst.
  static TextStyle body({
    double size = 14,
    FontWeight weight = FontWeight.w500,
    Color color = ink,
    double? height,
  }) {
    return GoogleFonts.manrope(
      fontSize: size,
      fontWeight: weight,
      color: color,
      height: height,
    );
  }

  /// Manrope — sitne etikete i natpisi.
  static TextStyle label({
    double size = 12,
    FontWeight weight = FontWeight.w700,
    Color color = inkSoft,
    double? spacing,
  }) {
    return GoogleFonts.manrope(
      fontSize: size,
      fontWeight: weight,
      color: color,
      letterSpacing: spacing,
    );
  }
}

/// „88,6" — decimalni zapis sa zarezom (srpska notacija).
String studioBDecimal(double v, {int decimals = 1}) {
  return v.toStringAsFixed(decimals).replaceAll('.', ',');
}

/// „2.500 RSD" — cena sa tačkom kao separatorom hiljada.
String studioBPrice(int rsd) {
  final s = rsd.toString();
  final b = StringBuffer();
  for (var i = 0; i < s.length; i++) {
    b.write(s[i]);
    final remaining = s.length - 1 - i;
    if (remaining > 0 && remaining % 3 == 0) {
      b.write('.');
    }
  }
  return '$b RSD';
}

/// Potpisana promena: „−5,6" / „+1,2".
String studioBDelta(double v, {int decimals = 1}) {
  final sign = v > 0 ? '+' : (v < 0 ? '−' : '±');
  return '$sign${studioBDecimal(v.abs(), decimals: decimals)}';
}
