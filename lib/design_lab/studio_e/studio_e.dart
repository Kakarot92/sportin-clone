import 'package:flutter/material.dart';

import 'login_screen.dart';
import 'shell.dart';
import 'theme.dart';

/// Studio E — „Dubina" (neon cinema).
///
/// Kinematski dark UI: slojevi ugljena za dubinu, neon cyan/violet kao začin,
/// parallax pozadina i animirani hero-orb. Sopstveni [MaterialApp] sa svojom
/// temom; `onExit` vraća u galeriju (poziva se iz Profila).
class StudioEApp extends StatelessWidget {
  const StudioEApp({super.key, this.onExit});

  /// Poziva se iz diskretnog dugmeta za povratak u galeriju.
  final VoidCallback? onExit;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Studio — Dubina',
      theme: StudioETheme.build(),
      home: _StudioERoot(onExit: onExit),
    );
  }
}

class _StudioERoot extends StatefulWidget {
  const _StudioERoot({this.onExit});

  final VoidCallback? onExit;

  @override
  State<_StudioERoot> createState() => _StudioERootState();
}

class _StudioERootState extends State<_StudioERoot> {
  bool _loggedIn = false;

  void _login() => setState(() => _loggedIn = true);
  void _logout() => setState(() => _loggedIn = false);

  @override
  Widget build(BuildContext context) {
    // Fade-through između Prijave i shell-a (kinematski rez).
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 620),
      switchInCurve: Curves.easeOutQuint,
      switchOutCurve: Curves.easeInCubic,
      transitionBuilder: (child, animation) => FadeTransition(
        opacity: animation,
        child: ScaleTransition(
          scale: Tween<double>(begin: 1.03, end: 1).animate(animation),
          child: child,
        ),
      ),
      child: _loggedIn
          ? StudioEShell(
              key: const ValueKey('shell'),
              onLogout: _logout,
              onExit: widget.onExit,
            )
          : StudioELoginScreen(
              key: const ValueKey('login'),
              onLogin: _login,
            ),
    );
  }
}
