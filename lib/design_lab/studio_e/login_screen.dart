import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'orb.dart';
import 'theme.dart';
import 'widgets.dart';

/// Prijava — mock: dugme „Prijavi se" ulazi u aplikaciju.
/// Orb iznad forme; input polja dobijaju glow na fokus.
class StudioELoginScreen extends StatelessWidget {
  const StudioELoginScreen({super.key, required this.onLogin});

  final VoidCallback onLogin;

  void _snack(BuildContext context, String text) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(text)));
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context).textTheme;
    return Scaffold(
      body: Stack(
        children: [
          const StudioEParallaxBackdrop(),
          SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(
                  horizontal: StudioESpace.xxl,
                  vertical: StudioESpace.section,
                ),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 400),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      StudioEEntrance(
                        child: Center(
                          child: StudioEOrb(
                            size: 168,
                            child: FittedBox(
                              fit: BoxFit.scaleDown,
                              child: StudioEGradientText(
                                'S',
                                style: GoogleFonts.syne(
                                  fontSize: 46,
                                  fontWeight: FontWeight.w800,
                                  color: StudioEColors.text,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: StudioESpace.xl),
                      StudioEEntrance(
                        delayMs: 80,
                        child: Center(
                          child: StudioEGradientText(
                            'Studio',
                            style: theme.displayMedium!,
                          ),
                        ),
                      ),
                      const SizedBox(height: StudioESpace.s),
                      StudioEEntrance(
                        delayMs: 140,
                        child: Text(
                          'Dobrodošli u vaš studio',
                          textAlign: TextAlign.center,
                          style: theme.bodyMedium!
                              .copyWith(color: StudioEColors.textDim),
                        ),
                      ),
                      const SizedBox(height: StudioESpace.section + 6),
                      const StudioEEntrance(
                        delayMs: 200,
                        child: StudioESectionLabel('Prijava'),
                      ),
                      const SizedBox(height: StudioESpace.m),
                      const StudioEEntrance(
                        delayMs: 240,
                        child: _StudioEGlowField(
                          label: 'Email',
                          icon: Icons.alternate_email_rounded,
                          keyboardType: TextInputType.emailAddress,
                        ),
                      ),
                      const SizedBox(height: StudioESpace.m + 2),
                      const StudioEEntrance(
                        delayMs: 300,
                        child: _StudioEGlowField(
                          label: 'Lozinka',
                          icon: Icons.lock_outline_rounded,
                          obscure: true,
                        ),
                      ),
                      const SizedBox(height: StudioESpace.xs),
                      StudioEEntrance(
                        delayMs: 340,
                        child: Align(
                          alignment: Alignment.centerRight,
                          child: TextButton(
                            onPressed: () => _snack(
                              context,
                              'Ako je taj email registrovan, poslali smo '
                              'link za reset.',
                            ),
                            child: const Text('Zaboravljena lozinka?'),
                          ),
                        ),
                      ),
                      const SizedBox(height: StudioESpace.l),
                      StudioEEntrance(
                        delayMs: 380,
                        child: StudioEGlowButton(
                          label: 'Prijavi se',
                          onPressed: onLogin,
                        ),
                      ),
                      const SizedBox(height: StudioESpace.m),
                      StudioEEntrance(
                        delayMs: 440,
                        child: Center(
                          child: TextButton(
                            onPressed: () => _snack(
                              context,
                              'Registracija je trenutno moguća samo u '
                              'studiju — pitaj svog trenera.',
                            ),
                            style: TextButton.styleFrom(
                              foregroundColor: StudioEColors.textDim,
                            ),
                            child: const Text('Nemaš nalog? Napravi ga'),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Input polje sa glow fokusom: ivica i senka ožive kada polje dobije fokus.
class _StudioEGlowField extends StatefulWidget {
  const _StudioEGlowField({
    required this.label,
    required this.icon,
    this.obscure = false,
    this.keyboardType,
  });

  final String label;
  final IconData icon;
  final bool obscure;
  final TextInputType? keyboardType;

  @override
  State<_StudioEGlowField> createState() => _StudioEGlowFieldState();
}

class _StudioEGlowFieldState extends State<_StudioEGlowField> {
  final FocusNode _focus = FocusNode();
  bool _hide = true;

  @override
  void initState() {
    super.initState();
    _focus.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _focus.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final focused = _focus.hasFocus;
    return AnimatedContainer(
      duration: const Duration(milliseconds: 260),
      curve: Curves.easeOutCubic,
      decoration: BoxDecoration(
        color: StudioEColors.layer1,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: focused
              ? StudioEColors.cyan.withValues(alpha: 0.8)
              : StudioEColors.hairline,
        ),
        boxShadow: focused
            ? [
                BoxShadow(
                  color: StudioEColors.cyan.withValues(alpha: 0.25),
                  blurRadius: 22,
                  spreadRadius: -2,
                ),
              ]
            : const [],
      ),
      child: TextField(
        focusNode: _focus,
        obscureText: widget.obscure && _hide,
        keyboardType: widget.keyboardType,
        textInputAction:
            widget.obscure ? TextInputAction.done : TextInputAction.next,
        style: Theme.of(context).textTheme.bodyLarge,
        decoration: InputDecoration(
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: StudioESpace.l,
            vertical: StudioESpace.l,
          ),
          labelText: widget.label,
          labelStyle: Theme.of(context)
              .textTheme
              .bodyMedium!
              .copyWith(color: StudioEColors.textDim),
          floatingLabelStyle: Theme.of(context)
              .textTheme
              .bodySmall!
              .copyWith(color: StudioEColors.cyan),
          prefixIcon: Icon(
            widget.icon,
            size: 20,
            color: focused ? StudioEColors.cyan : StudioEColors.textDim,
          ),
          suffixIcon: widget.obscure
              ? IconButton(
                  onPressed: () => setState(() => _hide = !_hide),
                  tooltip: _hide ? 'Prikaži lozinku' : 'Sakrij lozinku',
                  icon: Icon(
                    _hide
                        ? Icons.visibility_off_rounded
                        : Icons.visibility_rounded,
                    size: 20,
                    color: StudioEColors.textDim,
                  ),
                )
              : null,
        ),
      ),
    );
  }
}
