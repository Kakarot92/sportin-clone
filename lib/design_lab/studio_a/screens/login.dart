import 'package:flutter/material.dart';

import '../theme.dart';
import '../widgets/effects.dart';
import 'shell.dart';

/// Prijava — mock forma; giant vertikalno „STUDIO" preko celog ekrana,
/// minimalna forma pri dnu, volt CTA.
class StudioALoginScreen extends StatefulWidget {
  const StudioALoginScreen({super.key, this.onExit});

  final VoidCallback? onExit;

  @override
  State<StudioALoginScreen> createState() => _StudioALoginScreenState();
}

class _StudioALoginScreenState extends State<StudioALoginScreen> {
  final _email = TextEditingController();
  final _password = TextEditingController();

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  void _enter() {
    Navigator.of(context).pushReplacement(
      studioARoute(StudioAShell(onExit: widget.onExit)),
    );
  }

  void _mockInfo() {
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Demo prikaz — dugme „Prijavi se" te vodi u aplikaciju.'),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Speed-lines tekstura preko cele pozadine.
          const Positioned.fill(
            child: StudioASpeedLines(density: 34, seed: 12, opacity: 0.8),
          ),
          // Giant vertikalno „STUDIO" — čita se odozdo nagore, uz desnu ivicu.
          Positioned(
            top: 0,
            bottom: 0,
            right: -6,
            child: IgnorePointer(
              child: StudioAReveal(
                index: 0,
                dy: 0,
                dx: 48,
                child: RotatedBox(
                  quarterTurns: 3,
                  child: FittedBox(
                    fit: BoxFit.contain,
                    child: ShaderMask(
                      shaderCallback: (rect) => LinearGradient(
                        begin: Alignment.centerLeft,
                        end: Alignment.centerRight,
                        colors: [
                          StudioATheme.volt.withValues(alpha: 0.05),
                          StudioATheme.volt.withValues(alpha: 0.55),
                        ],
                      ).createShader(rect),
                      child: const StudioAGhostText(
                        'STUDIO',
                        size: 140,
                        color: Colors.white,
                        strokeWidth: 1.6,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
          SafeArea(
            child: LayoutBuilder(
              builder: (context, constraints) {
                return SingleChildScrollView(
                  child: ConstrainedBox(
                    constraints: BoxConstraints(minHeight: constraints.maxHeight),
                    child: Center(
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 520),
                        child: Padding(
                          padding: const EdgeInsets.fromLTRB(24, 12, 24, 0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _topBar(),
                              SizedBox(
                                height: constraints.maxHeight > 700 ? 120 : 40,
                              ),
                              _form(),
                              const SizedBox(height: 20),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _topBar() {
    return StudioAReveal(
      index: 1,
      dy: -14,
      child: Row(
        children: [
          if (widget.onExit != null)
            StudioAIconButton(
              icon: Icons.grid_view_rounded,
              tooltip: 'Nazad u galeriju',
              onPressed: widget.onExit!,
            ),
          const Spacer(),
          Text(
            'KINETIK — DESIGN LAB',
            style: StudioATheme.label(size: 9.5, tracking: 2.8),
          ),
        ],
      ),
    );
  }

  Widget _form() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        StudioAReveal(
          index: 2,
          child: Text(
            'PRIJAVA',
            style: StudioATheme.label(
              color: StudioATheme.volt,
              size: 11,
              tracking: 3.2,
            ),
          ),
        ),
        const SizedBox(height: 10),
        StudioAReveal(
          index: 3,
          child: FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            // Namerni prelom naslova preko 2 reda.
            child: Text(
              'TVOJ TRENING.\nTVOJ TEMPO.',
              style: StudioATheme.display(size: 34),
            ),
          ),
        ),
        const SizedBox(height: 8),
        StudioAReveal(
          index: 4,
          child: Text(
            'Zakazuj treninge, prati napredak i dopisuj se sa trenerom.',
            style: StudioATheme.body(size: 14, color: StudioATheme.inkDim),
          ),
        ),
        const SizedBox(height: 28),
        StudioAReveal(
          index: 5,
          child: _field(
            controller: _email,
            label: 'EMAIL',
            hint: 'ime@primer.rs',
            keyboardType: TextInputType.emailAddress,
          ),
        ),
        const SizedBox(height: 14),
        StudioAReveal(
          index: 6,
          child: _field(
            controller: _password,
            label: 'LOZINKA',
            hint: '••••••••',
            obscure: true,
          ),
        ),
        const SizedBox(height: 10),
        StudioAReveal(
          index: 7,
          child: Align(
            alignment: Alignment.centerRight,
            child: TextButton(
              onPressed: _mockInfo,
              style: TextButton.styleFrom(
                minimumSize: const Size(48, 48),
                foregroundColor: StudioATheme.inkDim,
              ),
              child: Text(
                'Zaboravljena lozinka?',
                style: StudioATheme.body(
                  size: 13,
                  color: StudioATheme.inkDim,
                ),
              ),
            ),
          ),
        ),
        const SizedBox(height: 12),
        StudioAReveal(
          index: 8,
          child: SizedBox(
            width: double.infinity,
            child: StudioAVoltButton(
              label: 'Prijavi se',
              icon: Icons.bolt_rounded,
              onPressed: _enter,
            ),
          ),
        ),
        const SizedBox(height: 6),
        StudioAReveal(
          index: 9,
          child: Center(
            child: TextButton(
              onPressed: _mockInfo,
              style: TextButton.styleFrom(minimumSize: const Size(48, 48)),
              child: Text(
                'Nemaš nalog? Napravi ga',
                style: StudioATheme.body(size: 13.5, color: StudioATheme.ink),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _field({
    required TextEditingController controller,
    required String label,
    required String hint,
    bool obscure = false,
    TextInputType? keyboardType,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: StudioATheme.label(size: 10, tracking: 2.6)),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          obscureText: obscure,
          keyboardType: keyboardType,
          style: StudioATheme.body(size: 15),
          cursorWidth: 2,
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: StudioATheme.body(
              size: 15,
              color: StudioATheme.inkDim.withValues(alpha: 0.55),
            ),
            filled: true,
            fillColor: StudioATheme.surface,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 15,
            ),
            enabledBorder: const OutlineInputBorder(
              borderRadius: BorderRadius.all(Radius.circular(2)),
              borderSide: BorderSide(color: StudioATheme.line),
            ),
            focusedBorder: const OutlineInputBorder(
              borderRadius: BorderRadius.all(Radius.circular(2)),
              borderSide: BorderSide(color: StudioATheme.volt, width: 1.5),
            ),
          ),
        ),
      ],
    );
  }
}
