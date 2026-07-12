import 'package:flutter/material.dart';

import 'login_screen.dart';
import 'theme.dart';
import 'widgets.dart';

/// Studio C — „Editorial Noir".
///
/// Premium boutique magazin: bone papir, ink tekst, serif display (Fraunces),
/// Inter za UI, terakota kao jedina tačka boje. Hairline grid, veliki vazduh,
/// numerisane sekcije. Luksuz kroz suzdržanost.
///
/// Ulazna klasa Design Lab galerije — ime i potpis konstruktora su fiksni.
class StudioCApp extends StatelessWidget {
  const StudioCApp({super.key, this.onExit});

  /// Poziva se iz diskretne fusnote u Profilu (kolofon) za povratak u galeriju.
  final VoidCallback? onExit;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Studio — Editorial Noir',
      theme: StudioCTheme.build(),
      builder: (context, child) {
        // Papirno zrno preko cele scene + čvrst opseg skaliranja teksta.
        final media = MediaQuery.of(context);
        return MediaQuery(
          data: media.copyWith(
            textScaler: media.textScaler.clamp(
              minScaleFactor: 0.9,
              maxScaleFactor: 1.25,
            ),
          ),
          child: StudioCStage(child: child ?? const SizedBox.shrink()),
        );
      },
      home: StudioCLoginScreen(onExit: onExit),
    );
  }
}
