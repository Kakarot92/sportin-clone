import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'studio_d_login.dart';
import 'studio_d_shell.dart';
import 'studio_d_theme.dart';

/// Studio D — „Blok" (neo-brutalist data). Sopstveni MaterialApp sa temom:
/// papir pozadina, ink okviri, Space Grotesk + Space Mono.
class StudioDApp extends StatefulWidget {
  const StudioDApp({super.key, this.onExit});

  /// Poziva se iz malog crvenog bloka u Profilu — povratak u galeriju.
  final VoidCallback? onExit;

  @override
  State<StudioDApp> createState() => _StudioDAppState();
}

class _StudioDAppState extends State<StudioDApp> {
  bool _loggedIn = false;

  @override
  Widget build(BuildContext context) {
    final base = ThemeData(
      useMaterial3: true,
      scaffoldBackgroundColor: StudioDColors.paper,
      colorScheme: const ColorScheme.light(
        primary: StudioDColors.ink,
        onPrimary: StudioDColors.paper,
        secondary: StudioDColors.yellow,
        onSecondary: StudioDColors.ink,
        surface: StudioDColors.paper,
        onSurface: StudioDColors.ink,
        error: StudioDColors.red,
        onError: StudioDColors.ink,
      ),
      splashFactory: NoSplash.splashFactory,
      textSelectionTheme: const TextSelectionThemeData(
        cursorColor: StudioDColors.ink,
        selectionColor: Color(0x66FFD02F),
        selectionHandleColor: StudioDColors.ink,
      ),
    );

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Studio — Blok',
      theme: base.copyWith(
        textTheme: GoogleFonts.spaceGroteskTextTheme(base.textTheme).apply(
          bodyColor: StudioDColors.ink,
          displayColor: StudioDColors.ink,
        ),
      ),
      builder: (context, child) {
        // Blok-layouti su gusti: ograniči skaliranje teksta da tabele i
        // grafikoni ne pucaju, a da krupniji tekst i dalje bude moguć.
        final mq = MediaQuery.of(context);
        return MediaQuery(
          data: mq.copyWith(
            textScaler: mq.textScaler
                .clamp(minScaleFactor: 1, maxScaleFactor: 1.2),
          ),
          child: child ?? const SizedBox.shrink(),
        );
      },
      home: AnimatedSwitcher(
        duration: const Duration(milliseconds: 460),
        switchInCurve: Curves.easeOutCubic,
        switchOutCurve: Curves.easeInCubic,
        transitionBuilder: (child, animation) {
          final slide = Tween<Offset>(
            begin: const Offset(0, 0.06),
            end: Offset.zero,
          ).animate(animation);
          return FadeTransition(
            opacity: animation,
            child: SlideTransition(position: slide, child: child),
          );
        },
        child: _loggedIn
            ? StudioDShell(
                key: const ValueKey('studio-d-shell'),
                onExit: widget.onExit,
                onLogout: () => setState(() => _loggedIn = false),
              )
            : StudioDLoginScreen(
                key: const ValueKey('studio-d-login'),
                onLogin: () => setState(() => _loggedIn = true),
              ),
      ),
    );
  }
}
