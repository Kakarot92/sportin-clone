import 'package:flutter/material.dart';

import 'studio_b_aurora.dart';
import 'studio_b_glass.dart';
import 'studio_b_tokens.dart';

/// Prijava — aurora preko celog ekrana, plutajuća glass forma i tipografski
/// logo sa „disajućim" oreolom. Mock: dugme ulazi u aplikaciju.
class StudioBLoginScreen extends StatefulWidget {
  const StudioBLoginScreen({super.key, required this.onLogin});

  final VoidCallback onLogin;

  @override
  State<StudioBLoginScreen> createState() => _StudioBLoginScreenState();
}

class _StudioBLoginScreenState extends State<StudioBLoginScreen> {
  bool _busy = false;
  bool _obscure = true;

  Future<void> _submit() async {
    if (_busy) {
      return;
    }
    setState(() => _busy = true);
    await Future<void>.delayed(const Duration(milliseconds: 650));
    if (!mounted) {
      return;
    }
    widget.onLogin();
  }

  InputDecoration _field(String label, IconData icon, {Widget? suffix}) {
    OutlineInputBorder border(Color color, [double width = 1]) {
      return OutlineInputBorder(
        borderRadius: BorderRadius.circular(18),
        borderSide: BorderSide(color: color, width: width),
      );
    }

    return InputDecoration(
      labelText: label,
      labelStyle: StudioBTokens.body(size: 14, color: StudioBTokens.inkSoft),
      floatingLabelStyle:
          StudioBTokens.body(size: 13, color: StudioBTokens.violetDeep),
      prefixIcon: Icon(icon, size: 20, color: StudioBTokens.inkSoft),
      suffixIcon: suffix,
      filled: true,
      fillColor: Colors.white.withValues(alpha: 0.55),
      contentPadding:
          const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
      enabledBorder: border(Colors.white.withValues(alpha: 0.60)),
      focusedBorder: border(StudioBTokens.violet, 1.4),
      border: border(Colors.white.withValues(alpha: 0.60)),
    );
  }

  Widget _logo() {
    return Column(
      children: [
        StudioBBreathing(
          child: Stack(
            alignment: Alignment.center,
            children: [
              const CustomPaint(
                size: Size(190, 132),
                painter: _HaloPainter(),
              ),
              Column(
                children: [
                  ShaderMask(
                    blendMode: BlendMode.srcIn,
                    shaderCallback: (bounds) => const LinearGradient(
                      colors: [
                        StudioBTokens.violetDeep,
                        StudioBTokens.violet,
                        StudioBTokens.mintDeep,
                      ],
                    ).createShader(bounds),
                    child: Text(
                      'Studio',
                      style: StudioBTokens.display(
                        size: 44,
                        weight: FontWeight.w700,
                        color: Colors.white,
                        spacing: -1,
                      ),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Dobrodošli u vaš studio',
                    style: StudioBTokens.body(
                      size: 14.5,
                      weight: FontWeight.w600,
                      color: StudioBTokens.inkSoft,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: StudioBAuroraBackground(
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(24, 32, 24, 32),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 420),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    StudioBReveal(child: _logo()),
                    const SizedBox(height: 34),
                    StudioBReveal(
                      delayMs: 120,
                      child: StudioBGlass(
                        padding: const EdgeInsets.fromLTRB(22, 26, 22, 24),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Text(
                              'Prijava',
                              style: StudioBTokens.display(
                                size: 20,
                                weight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 18),
                            TextField(
                              keyboardType: TextInputType.emailAddress,
                              textInputAction: TextInputAction.next,
                              style: StudioBTokens.body(size: 14.5),
                              decoration: _field(
                                'Email',
                                Icons.alternate_email_rounded,
                              ),
                            ),
                            const SizedBox(height: 14),
                            TextField(
                              obscureText: _obscure,
                              textInputAction: TextInputAction.done,
                              onSubmitted: (_) => _submit(),
                              style: StudioBTokens.body(size: 14.5),
                              decoration: _field(
                                'Lozinka',
                                Icons.lock_rounded,
                                suffix: IconButton(
                                  tooltip: _obscure
                                      ? 'Prikaži lozinku'
                                      : 'Sakrij lozinku',
                                  onPressed: () =>
                                      setState(() => _obscure = !_obscure),
                                  icon: Icon(
                                    _obscure
                                        ? Icons.visibility_rounded
                                        : Icons.visibility_off_rounded,
                                    size: 20,
                                    color: StudioBTokens.inkSoft,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(height: 6),
                            Align(
                              alignment: Alignment.centerRight,
                              child: TextButton(
                                onPressed: () => studioBShowSnack(
                                  context,
                                  'Ako je taj email registrovan, poslali smo '
                                  'link za reset.',
                                  icon: Icons.mark_email_read_outlined,
                                ),
                                style: TextButton.styleFrom(
                                  minimumSize: const Size(48, 48),
                                ),
                                child: Text(
                                  'Zaboravljena lozinka?',
                                  style: StudioBTokens.label(
                                    size: 12.5,
                                    color: StudioBTokens.violetDeep,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(height: 10),
                            StudioBPillButton(
                              label: 'Prijavi se',
                              busy: _busy,
                              onPressed: _submit,
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 14),
                    StudioBReveal(
                      delayMs: 240,
                      child: Center(
                        child: TextButton(
                          onPressed: () => studioBShowSnack(
                            context,
                            'Za demo nije potreban nalog — uđi preko '
                            '„Prijavi se".',
                          ),
                          style: TextButton.styleFrom(
                            minimumSize: const Size(48, 48),
                          ),
                          child: Text(
                            'Nemaš nalog? Napravi ga',
                            style: StudioBTokens.label(
                              size: 13,
                              color: StudioBTokens.inkSoft,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Meki koncentrični oreol iza logotipa — violet prsten koji „diše" zajedno
/// sa logom (spoljni [StudioBBreathing] skalira i tekst i oreol).
class _HaloPainter extends CustomPainter {
  const _HaloPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2 - 8);

    final glow = Paint()
      ..shader = RadialGradient(
        colors: [
          StudioBTokens.violet.withValues(alpha: 0.18),
          StudioBTokens.violet.withValues(alpha: 0.0),
        ],
      ).createShader(Rect.fromCircle(center: center, radius: 84));
    canvas.drawCircle(center, 84, glow);

    final alphas = [0.20, 0.12, 0.06];
    for (var i = 0; i < alphas.length; i++) {
      final ring = Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.4
        ..color = StudioBTokens.violet.withValues(alpha: alphas[i]);
      canvas.drawCircle(center, 46.0 + i * 16, ring);
    }
  }

  @override
  bool shouldRepaint(covariant _HaloPainter oldDelegate) => false;
}
