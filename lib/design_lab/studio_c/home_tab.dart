import 'package:flutter/material.dart';

import '../mock_data.dart';
import 'theme.dart';
import 'widgets.dart';

/// Početna — „današnje izdanje": sledeći trening kao naslovni članak,
/// statistike kao standfirst red, pregled sekcija kao sadržaj sa leaderima.
class StudioCHomeTab extends StatelessWidget {
  const StudioCHomeTab({super.key, required this.onOpenSection});

  /// Otvara tab po indeksu (1 = Termini, 2 = Merenja, 3 = Poruke, 4 = Profil).
  final ValueChanged<int> onOpenSection;

  @override
  Widget build(BuildContext context) {
    final s = mockNextSession;
    final firstM = mockMeasurements.first;
    final lastM = mockMeasurements.last;
    final weightDelta = lastM.weightKg - firstM.weightKg;
    int minPrice = mockTrainers.first.priceRsd;
    for (final t in mockTrainers) {
      if (t.priceRsd < minPrice) minPrice = t.priceRsd;
    }

    return ListView(
      padding: const EdgeInsets.fromLTRB(
        StudioCTokens.margin,
        14,
        StudioCTokens.margin,
        28,
      ),
      children: [
        StudioCPageColumn(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              StudioCReveal(
                order: 0,
                child: const StudioCKicker(
                  index: '01',
                  label: 'Današnje izdanje',
                  trailing: 'UTORAK, 8. JUL 2026.',
                ),
              ),
              const SizedBox(height: 18),
              StudioCReveal(
                order: 1,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Dobrodošli u vaš studio',
                      style: StudioCType.display(32),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      'Zakazujte treninge, pratite napredak i dopisujte se '
                      'sa trenerom.',
                      style: StudioCType.body(color: StudioCTokens.inkSoft),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'ČITALAC: ${mockUser.name.toUpperCase()}',
                      style: StudioCType.meta(size: 9),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 26),
              // Naslovni članak — sledeći trening.
              StudioCReveal(
                order: 2,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const StudioCKicker(
                      index: '№ 1',
                      label: 'Sledeći trening',
                      trailing: 'SALA 2',
                    ),
                    const SizedBox(height: 18),
                    IntrinsicHeight(
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          SizedBox(
                            width: 104,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  s.weekday.toUpperCase(),
                                  style: StudioCType.meta(size: 9.5),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  s.time,
                                  style: StudioCType.numeral(36),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  s.date.toUpperCase(),
                                  style: StudioCType.meta(size: 9.5),
                                ),
                              ],
                            ),
                          ),
                          Container(width: 1, color: StudioCTokens.hairline),
                          const SizedBox(width: 18),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  s.type,
                                  style: StudioCType.display(23),
                                ),
                                const SizedBox(height: 10),
                                Text(
                                  'VODI: ${s.trainer.toUpperCase()}',
                                  style: StudioCType.meta(
                                    size: 9.5,
                                    color: StudioCTokens.ink,
                                    weight: FontWeight.w600,
                                  ),
                                ),
                                const SizedBox(height: 12),
                                const SizedBox(
                                  width: 32,
                                  child: StudioCHairline(),
                                ),
                                const SizedBox(height: 12),
                                Text(
                                  '„Ponesi. Radićemo bench, teže serije.“',
                                  style: StudioCType.body(
                                    size: 13,
                                    color: StudioCTokens.inkSoft,
                                    style: FontStyle.italic,
                                  ),
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  'IZ PREPISKE · 17:45',
                                  style: StudioCType.meta(size: 8.5),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 26),
              // Standfirst red statistika.
              StudioCReveal(
                order: 3,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const StudioCHairline(),
                    IntrinsicHeight(
                      child: Row(
                        children: [
                          _StatCell(
                            value: '${mockWeekStats.trainingsThisWeek}',
                            label: 'OVE NEDELJE',
                          ),
                          Container(width: 1, color: StudioCTokens.hairline),
                          _StatCell(
                            value: '${mockWeekStats.trainingsThisMonth}',
                            label: 'OVOG MESECA',
                          ),
                          Container(width: 1, color: StudioCTokens.hairline),
                          _StatCell(
                            value: '${mockWeekStats.streakWeeks}',
                            label: 'NEDELJA U NIZU',
                          ),
                        ],
                      ),
                    ),
                    const StudioCHairline(),
                  ],
                ),
              ),
              const SizedBox(height: 26),
              // Izvod — cilj čitaoca kao pull quote.
              StudioCReveal(
                order: 4,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('VAŠ CILJ', style: StudioCType.meta(size: 9)),
                    const SizedBox(height: 10),
                    Text(
                      '„${mockUser.goal}“',
                      style: StudioCType.display(
                        21,
                        weight: FontWeight.w500,
                        style: FontStyle.italic,
                        height: 1.25,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'ZAPISANO: ${mockUser.memberSince.toUpperCase()}',
                      style: StudioCType.meta(size: 8.5),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 26),
              // Pregled — sadržaj izdanja sa leader tačkama.
              StudioCReveal(
                order: 5,
                child: const StudioCKicker(index: '№ 2', label: 'Pregled'),
              ),
              const SizedBox(height: 6),
              StudioCReveal(
                order: 6,
                child: _TocRow(
                  numeral: '02',
                  title: 'Termini',
                  subtitle: '${mockTrainers.length} TRENERA · OD '
                      '${StudioCFmt.thousands(minPrice)} RSD',
                  onTap: () => onOpenSection(1),
                ),
              ),
              StudioCReveal(
                order: 7,
                child: _TocRow(
                  numeral: '03',
                  title: 'Merenja',
                  subtitle: '${mockMeasurements.length} NEDELJA · '
                      '${StudioCFmt.delta(weightDelta)} KG',
                  onTap: () => onOpenSection(2),
                ),
              ),
              StudioCReveal(
                order: 8,
                child: _TocRow(
                  numeral: '04',
                  title: 'Poruke',
                  subtitle: '${mockThreads.length} RAZGOVORA · POSLEDNJA U '
                      '${mockThreads.first.lastTime}',
                  onTap: () => onOpenSection(3),
                ),
              ),
              StudioCReveal(
                order: 9,
                child: _TocRow(
                  numeral: '05',
                  title: 'Profil',
                  subtitle: 'ČLANARINA · PREOSTALO ${mockMembership.remaining} '
                      'OD ${mockMembership.total}',
                  onTap: () => onOpenSection(4),
                  withRuleBelow: true,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _StatCell extends StatelessWidget {
  const _StatCell({required this.value, required this.label});

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
            Text(value, style: StudioCType.display(30, weight: FontWeight.w500)),
            const SizedBox(height: 6),
            FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(label, style: StudioCType.meta(size: 8.5)),
            ),
          ],
        ),
      ),
    );
  }
}

class _TocRow extends StatelessWidget {
  const _TocRow({
    required this.numeral,
    required this.title,
    required this.subtitle,
    required this.onTap,
    this.withRuleBelow = false,
  });

  final String numeral;
  final String title;
  final String subtitle;
  final VoidCallback onTap;
  final bool withRuleBelow;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        InkWell(
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 14),
            child: Row(
              children: [
                Text(
                  numeral,
                  style: StudioCType.numeral(
                    12,
                    color: StudioCTokens.terracotta,
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            title,
                            style: StudioCType.display(
                              18,
                              weight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(width: 12),
                          const Expanded(child: StudioCLeader()),
                          const SizedBox(width: 12),
                          Text(
                            'STR. $numeral',
                            style: StudioCType.meta(size: 8.5),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(subtitle, style: StudioCType.meta(size: 8.5)),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        if (withRuleBelow) const StudioCHairline(),
      ],
    );
  }
}
