import 'package:flutter/material.dart';

import '../mock_data.dart';
import 'theme.dart';
import 'widgets.dart';

/// Detalj trenera — profil-članak: drop cap biografija, panel činjenica
/// sa serif numeralima, vertikalna marginalija uz ivicu strane.
class StudioCTrainerDetailScreen extends StatefulWidget {
  const StudioCTrainerDetailScreen({super.key, required this.index});

  /// Pozicija trenera u imeniku (za folio „01/04").
  final int index;

  @override
  State<StudioCTrainerDetailScreen> createState() =>
      _StudioCTrainerDetailScreenState();
}

class _StudioCTrainerDetailScreenState
    extends State<StudioCTrainerDetailScreen> {
  bool _chosen = false;

  MockTrainer get _trainer => mockTrainers[widget.index];

  @override
  Widget build(BuildContext context) {
    final t = _trainer;
    final folio =
        '${StudioCFmt.two(widget.index + 1)}/${StudioCFmt.two(mockTrainers.length)}';

    return Scaffold(
      body: SafeArea(
        child: Stack(
          children: [
            StudioCPageColumn(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(
                  StudioCTokens.margin,
                  8,
                  StudioCTokens.margin + 8,
                  32,
                ),
                children: [
                  // Povratak u imenik.
                  StudioCReveal(
                    order: 0,
                    child: Row(
                      children: [
                        InkWell(
                          onTap: () => Navigator.of(context).pop(),
                          child: Container(
                            height: 48,
                            alignment: Alignment.centerLeft,
                            child: Text(
                              '←  IMENIK TRENERA',
                              style: StudioCType.kicker(
                                size: 10,
                                color: StudioCTokens.ink,
                              ),
                            ),
                          ),
                        ),
                        const Spacer(),
                        Text('PROFIL $folio', style: StudioCType.meta()),
                      ],
                    ),
                  ),
                  const SizedBox(height: 10),
                  const StudioCReveal(order: 1, child: StudioCDoubleRule()),
                  const SizedBox(height: 26),
                  StudioCReveal(
                    order: 2,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          t.specialty.toUpperCase(),
                          style: StudioCType.kicker(
                            size: 10,
                            color: StudioCTokens.terracotta,
                            letterSpacing: 2,
                          ),
                        ),
                        const SizedBox(height: 10),
                        Text(t.name, style: StudioCType.display(36)),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  // Panel činjenica.
                  StudioCReveal(
                    order: 3,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        const StudioCHairline(),
                        IntrinsicHeight(
                          child: Row(
                            children: [
                              _FactCell(
                                value: '${t.years}',
                                label: 'GODINA ISKUSTVA',
                              ),
                              Container(
                                width: 1,
                                color: StudioCTokens.hairline,
                              ),
                              _FactCell(
                                value: '${t.clients}',
                                label: 'KLIJENATA',
                              ),
                              Container(
                                width: 1,
                                color: StudioCTokens.hairline,
                              ),
                              _FactCell(
                                value: StudioCFmt.dec(t.rating),
                                label: 'OCENA / 5',
                              ),
                            ],
                          ),
                        ),
                        const StudioCHairline(),
                      ],
                    ),
                  ),
                  const SizedBox(height: 26),
                  // Biografija sa drop cap inicijalom.
                  StudioCReveal(
                    order: 4,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('BIOGRAFIJA', style: StudioCType.meta(size: 9)),
                        const SizedBox(height: 14),
                        _DropCapParagraph(text: t.bio),
                      ],
                    ),
                  ),
                  const SizedBox(height: 26),
                  // Cena i poziv.
                  StudioCReveal(
                    order: 5,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        const StudioCHairline(),
                        const SizedBox(height: 16),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.baseline,
                          textBaseline: TextBaseline.alphabetic,
                          children: [
                            Text(
                              StudioCFmt.thousands(t.priceRsd),
                              style: StudioCType.numeral(
                                30,
                                style: FontStyle.normal,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text('RSD', style: StudioCType.meta(size: 10)),
                            const Spacer(),
                            Text(
                              'PO INDIVIDUALNOM TRENINGU',
                              style: StudioCType.meta(size: 8.5),
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),
                        AnimatedSwitcher(
                          duration: StudioCTokens.beat,
                          switchInCurve: StudioCTokens.ease,
                          switchOutCurve: StudioCTokens.ease,
                          transitionBuilder: (child, animation) {
                            return FadeTransition(
                              opacity: animation,
                              child: SlideTransition(
                                position: Tween<Offset>(
                                  begin: const Offset(0, 0.06),
                                  end: Offset.zero,
                                ).animate(animation),
                                child: child,
                              ),
                            );
                          },
                          child: _chosen
                              ? Column(
                                  key: const ValueKey('chosen'),
                                  crossAxisAlignment:
                                      CrossAxisAlignment.stretch,
                                  children: [
                                    const StudioCPrimaryButton(
                                      label: 'Izabran trener',
                                      arrow: false,
                                    ),
                                    const SizedBox(height: 12),
                                    Text(
                                      'ZAHTEV JE POSLAT — TRENER POTVRĐUJE '
                                      'PRVI TERMIN.',
                                      style: StudioCType.meta(
                                        size: 8.5,
                                        color: StudioCTokens.terracotta,
                                        letterSpacing: 1.6,
                                      ),
                                      textAlign: TextAlign.center,
                                    ),
                                  ],
                                )
                              : StudioCGhostButton(
                                  key: const ValueKey('choose'),
                                  label: 'Izaberi trenera',
                                  onTap: () =>
                                      setState(() => _chosen = true),
                                ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            StudioCMarginalia(
              text: 'STUDIO · IMENIK TRENERA · PROFIL $folio · MMXXVI',
            ),
          ],
        ),
      ),
    );
  }
}

class _FactCell extends StatelessWidget {
  const _FactCell({required this.value, required this.label});

  final String value;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              value,
              style: StudioCType.numeral(26, style: FontStyle.normal),
            ),
            const SizedBox(height: 6),
            FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(label, style: StudioCType.meta(size: 8)),
            ),
          ],
        ),
      ),
    );
  }
}

/// Lettrine biografije: oversized serif inicijal (hanging initial) uz koji
/// stoji pasus, a prve dve reči posle inicijala postavljene su razmaknutim
/// verzalom — klasičan magazinski otvor sloga.
class _DropCapParagraph extends StatelessWidget {
  const _DropCapParagraph({required this.text});

  final String text;

  /// Deli tekst na: inicijal, uvodni verzalni run (~2 reči), i ostatak.
  static (String cap, String lead, String rest) _split(String text) {
    if (text.isEmpty) return ('', '', '');
    final cap = text.substring(0, 1);
    final body = text.substring(1);
    // Uhvati prve dve reči za verzalni otvor.
    final match = RegExp(r'^(\S*\s+\S*)(\s+)(.*)$', dotAll: true).firstMatch(body);
    if (match == null) return (cap, body, '');
    return (cap, match.group(1)!, match.group(3)!);
  }

  @override
  Widget build(BuildContext context) {
    final (cap, lead, rest) = _split(text);
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(top: 2, right: 14),
          child: Text(
            cap,
            style: StudioCType.display(
              56,
              weight: FontWeight.w500,
              height: 0.9,
            ),
          ),
        ),
        Expanded(
          child: Text.rich(
            TextSpan(
              style: StudioCType.body(size: 14.5, height: 1.65),
              children: [
                TextSpan(
                  text: lead.toUpperCase(),
                  style: StudioCType.body(
                    size: 12.5,
                    height: 1.65,
                    weight: FontWeight.w600,
                  ).copyWith(letterSpacing: 1.0),
                ),
                TextSpan(text: rest.isEmpty ? '' : ' $rest'),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
