import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'studio_b_login.dart';
import 'studio_b_shell.dart';
import 'studio_b_tokens.dart';

/// Studio B — „Aurora". Sopstveni MaterialApp: svetla wellness tema, animirani
/// aurora mesh, frosted-glass paneli, Sora + Manrope tipografija.
///
/// Tok: Prijava (mock) → školjka sa 5 tabova. `onExit` se poziva iz diskretnog
/// dugmeta u Profilu (povratak u galeriju studija).
class StudioBApp extends StatelessWidget {
  const StudioBApp({super.key, this.onExit});

  /// Poziva se iz diskretnog dugmeta za povratak u galeriju.
  final VoidCallback? onExit;

  @override
  Widget build(BuildContext context) {
    final textTheme = GoogleFonts.manropeTextTheme();

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Studio — Aurora',
      theme: ThemeData(
        useMaterial3: true,
        scaffoldBackgroundColor: StudioBTokens.bgBlue,
        colorScheme: ColorScheme.fromSeed(
          seedColor: StudioBTokens.violet,
          primary: StudioBTokens.violet,
          secondary: StudioBTokens.mint,
          surface: Colors.white,
          onSurface: StudioBTokens.ink,
        ),
        textTheme: textTheme.apply(
          bodyColor: StudioBTokens.ink,
          displayColor: StudioBTokens.ink,
        ),
        splashFactory: InkRipple.splashFactory,
        textSelectionTheme: const TextSelectionThemeData(
          cursorColor: StudioBTokens.violet,
          selectionColor: Color(0x336F5FE6),
          selectionHandleColor: StudioBTokens.violet,
        ),
      ),
      home: StudioBRoot(onExit: onExit),
    );
  }
}

/// Drži stanje prijave i prebacuje između Prijave i školjke sa mekim
/// fade+scale prelazom.
class StudioBRoot extends StatefulWidget {
  const StudioBRoot({super.key, this.onExit});

  final VoidCallback? onExit;

  @override
  State<StudioBRoot> createState() => _StudioBRootState();
}

class _StudioBRootState extends State<StudioBRoot> {
  bool _loggedIn = false;

  @override
  Widget build(BuildContext context) {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 620),
      switchInCurve: Curves.easeOutCubic,
      switchOutCurve: Curves.easeInCubic,
      transitionBuilder: (child, animation) => FadeTransition(
        opacity: animation,
        child: ScaleTransition(
          scale: Tween<double>(begin: 0.98, end: 1).animate(animation),
          child: child,
        ),
      ),
      child: _loggedIn
          ? StudioBShell(
              key: const ValueKey('shell'),
              onLogout: () => setState(() => _loggedIn = false),
              onExit: widget.onExit,
            )
          : StudioBLoginScreen(
              key: const ValueKey('login'),
              onLogin: () => setState(() => _loggedIn = true),
            ),
    );
  }
}
