import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sportin_clone/app/kinetic_effects.dart';
import 'package:sportin_clone/app/theme.dart';

class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kInk,
      body: Stack(
        children: [
          // ── Speed-lines texture ──────────────────────────────────────
          const Positioned.fill(
            child: SpeedLines(density: 20, opacity: 0.55),
          ),
          // ── Centered brand identity ──────────────────────────────────
          Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'ĐOLE',
                  style: GoogleFonts.archivoBlack(
                    fontSize: 48,
                    color: kOffWhite,
                    letterSpacing: -1,
                    height: 0.9,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  'STUDIO',
                  style: GoogleFonts.interTight(
                    fontSize: 11,
                    color: kVolt,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 3.5,
                  ),
                ),
                const SizedBox(height: 28),
                const PulseDot(size: 10),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
