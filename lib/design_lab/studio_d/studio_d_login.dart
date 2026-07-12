import 'package:flutter/material.dart';

import 'studio_d_theme.dart';

/// Prijava — formular-karton: obrazac sa zavodnim brojem, pečat „OVERENO",
/// polja kao rubrike formulara. Mock: dugme ulazi u app bez backend-a.
class StudioDLoginScreen extends StatefulWidget {
  const StudioDLoginScreen({super.key, required this.onLogin});

  final VoidCallback onLogin;

  @override
  State<StudioDLoginScreen> createState() => _StudioDLoginScreenState();
}

class _StudioDLoginScreenState extends State<StudioDLoginScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: StudioDGridPaper(
        child: SafeArea(
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 440),
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(20, 28, 20, 28),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _buildMasthead(),
                    const SizedBox(height: 22),
                    _buildFormCard(context),
                    const SizedBox(height: 18),
                    Center(
                      child: Text(
                        'STUDIO © 2026 — SVA PRAVA ZADRŽANA',
                        style: StudioDType.mono(
                          size: 9,
                          weight: FontWeight.w700,
                          color: StudioDColors.inkSoft,
                          spacing: 0.6,
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

  Widget _buildMasthead() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: StudioDColors.ink,
            boxShadow: studioDShadow(4),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(width: 12, height: 12, color: StudioDColors.yellow),
              const SizedBox(width: 8),
              Text(
                'STUDIO',
                style: StudioDType.grotesk(
                  size: 24,
                  weight: FontWeight.w700,
                  color: StudioDColors.paper,
                  spacing: 3,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 10),
        const Flexible(
          child: Align(
            alignment: Alignment.centerRight,
            child: StudioDTag('Obr. 01/26', fill: StudioDColors.paper),
          ),
        ),
      ],
    );
  }

  Widget _buildFormCard(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        StudioDPanel(
          shadow: 6,
          padding: const EdgeInsets.fromLTRB(18, 20, 18, 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'PRIJAVA',
                style: StudioDType.grotesk(
                  size: 26,
                  weight: FontWeight.w700,
                  spacing: 1.5,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Dobrodošli u vaš studio',
                style: StudioDType.grotesk(
                  size: 13.5,
                  color: StudioDColors.inkSoft,
                ),
              ),
              const SizedBox(height: 14),
              Container(height: 2, color: StudioDColors.ink),
              const SizedBox(height: 16),
              const _StudioDLoginField(
                label: 'Email',
                hint: 'ime@primer.rs',
                keyboardType: TextInputType.emailAddress,
              ),
              const SizedBox(height: 14),
              const _StudioDLoginField(
                label: 'Lozinka',
                hint: '••••••••',
                obscure: true,
              ),
              const SizedBox(height: 10),
              Align(
                alignment: Alignment.centerRight,
                child: GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: () => studioDToast(
                    context,
                    'Ako je taj email registrovan, poslali smo link za reset.',
                  ),
                  child: Container(
                    alignment: Alignment.centerRight,
                    constraints: const BoxConstraints(minHeight: 48),
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    child: Text(
                      'Zaboravljena lozinka?',
                      style: StudioDType.mono(
                        size: 10.5,
                        weight: FontWeight.w700,
                      ).copyWith(
                        decoration: TextDecoration.underline,
                        decorationThickness: 2,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 6),
              StudioDPressable(
                color: StudioDColors.yellow,
                shadow: 5,
                padding: const EdgeInsets.symmetric(vertical: 16),
                onTap: widget.onLogin,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'PRIJAVI SE',
                      style: StudioDType.grotesk(
                        size: 16,
                        weight: FontWeight.w700,
                        spacing: 1.2,
                      ),
                    ),
                    const SizedBox(width: 8),
                    const Icon(
                      Icons.arrow_forward_sharp,
                      size: 20,
                      color: StudioDColors.ink,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: () =>
                    studioDToast(context, 'Za demo: samo „Prijavi se".'),
                child: Container(
                  alignment: Alignment.center,
                  constraints: const BoxConstraints(minHeight: 48),
                  child: Text(
                    'Nemaš nalog? Napravi ga',
                    textAlign: TextAlign.center,
                    style: StudioDType.mono(
                      size: 11,
                      weight: FontWeight.w700,
                    ).copyWith(
                      decoration: TextDecoration.underline,
                      decorationThickness: 2,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        const Positioned(top: -16, right: -6, child: _StudioDStamp()),
      ],
    );
  }
}

/// Rubrika formulara: tag-etiketa + polje u 2px okviru.
/// Fokus = žuta etiketa i žuta tvrda senka ispod polja.
class _StudioDLoginField extends StatefulWidget {
  const _StudioDLoginField({
    required this.label,
    required this.hint,
    this.obscure = false,
    this.keyboardType,
  });

  final String label;
  final String hint;
  final bool obscure;
  final TextInputType? keyboardType;

  @override
  State<_StudioDLoginField> createState() => _StudioDLoginFieldState();
}

class _StudioDLoginFieldState extends State<_StudioDLoginField> {
  bool _focused = false;
  late bool _hidden = widget.obscure;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        StudioDTag(
          widget.label,
          fill: _focused ? StudioDColors.yellow : StudioDColors.white,
        ),
        const SizedBox(height: 6),
        Focus(
          onFocusChange: (f) => setState(() => _focused = f),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 150),
            curve: Curves.easeOutCubic,
            decoration: BoxDecoration(
              color: StudioDColors.white,
              border: Border.all(color: StudioDColors.ink, width: 2),
              boxShadow: _focused
                  ? const [
                      BoxShadow(
                        color: StudioDColors.yellow,
                        offset: Offset(4, 4),
                      ),
                    ]
                  : null,
            ),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    obscureText: _hidden,
                    keyboardType: widget.keyboardType,
                    style: StudioDType.mono(size: 13.5),
                    cursorWidth: 6,
                    decoration: InputDecoration(
                      border: InputBorder.none,
                      isDense: true,
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 15,
                      ),
                      hintText: widget.hint,
                      hintStyle: StudioDType.mono(
                        size: 13.5,
                        color: StudioDColors.inkSoft,
                      ),
                    ),
                  ),
                ),
                if (widget.obscure)
                  GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onTap: () => setState(() => _hidden = !_hidden),
                    child: SizedBox(
                      width: 48,
                      height: 48,
                      child: Icon(
                        _hidden
                            ? Icons.visibility_sharp
                            : Icons.visibility_off_sharp,
                        size: 20,
                        color: StudioDColors.ink,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

/// Pečat-badge: dupli crveni okvir, rotiran. Svaki dodir ga „prelupi" —
/// zavrti se za još koji stepen (easter egg sa porukom na 5. dodir).
class _StudioDStamp extends StatefulWidget {
  const _StudioDStamp();

  @override
  State<_StudioDStamp> createState() => _StudioDStampState();
}

class _StudioDStampState extends State<_StudioDStamp> {
  int _taps = 0;

  @override
  Widget build(BuildContext context) {
    final turns = (-8 + (_taps % 6) * 5) / 360;
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () {
        setState(() => _taps++);
        if (_taps == 5) {
          studioDToast(context, 'Pečat je već overen. Ne lupaj dvaput.');
        }
      },
      child: AnimatedRotation(
        turns: turns,
        duration: const Duration(milliseconds: 320),
        curve: Curves.easeOutBack,
        child: Container(
          padding: const EdgeInsets.all(4),
          decoration: BoxDecoration(
            color: StudioDColors.paper,
            border: Border.all(color: StudioDColors.red, width: 3),
          ),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              border: Border.all(color: StudioDColors.red, width: 1.5),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'STUDIO',
                  style: StudioDType.grotesk(
                    size: 19,
                    weight: FontWeight.w700,
                    color: StudioDColors.red,
                    spacing: 2.5,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  '* OVERENO *',
                  style: StudioDType.mono(
                    size: 9,
                    weight: FontWeight.w700,
                    color: StudioDColors.red,
                    spacing: 1,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
