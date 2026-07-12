import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'shell.dart';
import 'theme.dart';
import 'widgets.dart';

/// Prijava — naslovna strana izdanja. „Studio" kao masthead,
/// forma kao impressum: underline polja, bez kutija.
class StudioCLoginScreen extends StatefulWidget {
  const StudioCLoginScreen({super.key, this.onExit});

  final VoidCallback? onExit;

  @override
  State<StudioCLoginScreen> createState() => _StudioCLoginScreenState();
}

class _StudioCLoginScreenState extends State<StudioCLoginScreen> {
  final _email = TextEditingController();
  final _password = TextEditingController();
  bool _showPassword = false;

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  void _enter() {
    Navigator.of(context).pushReplacement(
      StudioCRoute(builder: (_) => StudioCShell(onExit: widget.onExit)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.dark.copyWith(
        statusBarColor: Colors.transparent,
      ),
      child: Scaffold(
        body: SafeArea(
          child: StudioCPageColumn(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(
                horizontal: StudioCTokens.margin,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(height: 18),
                  // Dateline red — godina izdanja levo, mesto i mesec desno.
                  StudioCReveal(
                    order: 0,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Row(
                          children: [
                            Text('GODIŠTE I · BROJ 2', style: StudioCType.meta()),
                            const Spacer(),
                            Text(
                              'BEOGRAD · JUL 2026.',
                              style: StudioCType.meta(),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        const StudioCHairline(),
                      ],
                    ),
                  ),
                  const SizedBox(height: 44),
                  // Masthead.
                  StudioCReveal(
                    order: 1,
                    child: Column(
                      children: [
                        FittedBox(
                          fit: BoxFit.scaleDown,
                          child: Padding(
                            // Kompenzacija letterSpacing-a poslednjeg glifa.
                            padding: const EdgeInsets.only(left: 14),
                            child: Text(
                              'STUDIO',
                              style: StudioCType.display(
                                84,
                                weight: FontWeight.w500,
                                letterSpacing: 14,
                                height: 1.0,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 14),
                        Text.rich(
                          TextSpan(
                            style: StudioCType.meta(letterSpacing: 2),
                            children: [
                              const TextSpan(text: 'TRENING'),
                              TextSpan(
                                text: '  ·  ',
                                style: StudioCType.meta(
                                  color: StudioCTokens.terracotta,
                                ),
                              ),
                              const TextSpan(text: 'MERENJA'),
                              TextSpan(
                                text: '  ·  ',
                                style: StudioCType.meta(
                                  color: StudioCTokens.terracotta,
                                ),
                              ),
                              const TextSpan(text: 'PORUKE'),
                            ],
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 22),
                  const StudioCReveal(order: 2, child: StudioCDoubleRule()),
                  const SizedBox(height: 40),
                  // Forma kao impressum.
                  StudioCReveal(
                    order: 3,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const StudioCKicker(
                          index: '№ 1',
                          label: 'Prijava',
                          withRule: false,
                        ),
                        const SizedBox(height: 12),
                        Text(
                          'Dobrodošli u vaš studio',
                          style: StudioCType.display(30),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          'Zakazujte treninge, pratite napredak i dopisujte se '
                          'sa trenerom.',
                          style: StudioCType.body(
                            color: StudioCTokens.inkSoft,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 30),
                  StudioCReveal(
                    order: 4,
                    child: StudioCField(
                      label: 'Email',
                      hint: 'ime@primer.rs',
                      controller: _email,
                      keyboardType: TextInputType.emailAddress,
                    ),
                  ),
                  const SizedBox(height: 22),
                  StudioCReveal(
                    order: 5,
                    child: StudioCField(
                      label: 'Lozinka',
                      hint: '••••••••',
                      controller: _password,
                      obscure: !_showPassword,
                      suffix: InkWell(
                        onTap: () =>
                            setState(() => _showPassword = !_showPassword),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 16,
                          ),
                          child: Text(
                            _showPassword ? 'SAKRIJ' : 'PRIKAŽI',
                            style: StudioCType.meta(
                              size: 9.5,
                              letterSpacing: 1.6,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 6),
                  StudioCReveal(
                    order: 6,
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: InkWell(
                        onTap: () => StudioCNote.show(
                          context,
                          'Ako je taj email registrovan, poslali smo link '
                          'za reset.',
                        ),
                        child: Container(
                          height: 48,
                          alignment: Alignment.centerLeft,
                          child: Text(
                            'Zaboravljena lozinka?',
                            style: StudioCType.body(
                              size: 13,
                              color: StudioCTokens.inkSoft,
                            ).copyWith(
                              decoration: TextDecoration.underline,
                              decorationColor: StudioCTokens.hairline,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 14),
                  StudioCReveal(
                    order: 7,
                    child: StudioCPrimaryButton(
                      label: 'Prijavi se',
                      onTap: _enter,
                    ),
                  ),
                  const SizedBox(height: 6),
                  StudioCReveal(
                    order: 8,
                    child: InkWell(
                      onTap: () => StudioCNote.show(
                        context,
                        'Kreiranje naloga je dostupno u punom izdanju.',
                      ),
                      child: Container(
                        height: 48,
                        alignment: Alignment.center,
                        child: Text.rich(
                          TextSpan(
                            style: StudioCType.body(
                              size: 13,
                              color: StudioCTokens.inkSoft,
                            ),
                            children: [
                              const TextSpan(text: 'Nemaš nalog? '),
                              TextSpan(
                                text: 'Napravi ga',
                                style: StudioCType.body(
                                  size: 13,
                                  color: StudioCTokens.terracotta,
                                  weight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 34),
                  StudioCReveal(
                    order: 9,
                    child: Column(
                      children: [
                        const StudioCHairline(),
                        const SizedBox(height: 12),
                        Text(
                          'SVA PRAVA ZADRŽANA · MMXXVI',
                          style: StudioCType.meta(
                            size: 8.5,
                            letterSpacing: 2.4,
                            color:
                                StudioCTokens.inkSoft.withValues(alpha: 0.7),
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
