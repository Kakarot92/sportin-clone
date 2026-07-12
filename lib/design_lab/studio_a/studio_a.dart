import 'package:flutter/material.dart';

import 'screens/login.dart';
import 'theme.dart';

/// Studio A — „Kinetik".
///
/// Atletska energija: oversized condensed tipografija (Archivo Black),
/// volt #CCFF00 na skoro-crnom, dijagonalni rezovi, brojevi kao heroji.
/// Ulaz: Prijava (mock) → shell sa 5 tabova.
class StudioAApp extends StatelessWidget {
  const StudioAApp({super.key, this.onExit});

  /// Poziva se iz diskretnog dugmeta za povratak u galeriju
  /// (vrh Prijave i vrh Profila).
  final VoidCallback? onExit;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Studio — Kinetik',
      theme: StudioATheme.theme(),
      home: StudioALoginScreen(onExit: onExit),
    );
  }
}
