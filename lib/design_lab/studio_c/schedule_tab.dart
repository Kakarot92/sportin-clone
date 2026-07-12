import 'package:flutter/material.dart';

import '../mock_data.dart';
import 'theme.dart';
import 'trainer_detail_screen.dart';
import 'widgets.dart';

/// Termini — direktorijum trenera kao imenik: serif imena,
/// hairline redovi, folio numerali, cena uz desnu marginu.
class StudioCScheduleTab extends StatelessWidget {
  const StudioCScheduleTab({super.key});

  void _openTrainer(BuildContext context, int index) {
    Navigator.of(context).push(
      StudioCRoute(
        builder: (_) => StudioCTrainerDetailScreen(index: index),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
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
                child: StudioCKicker(
                  index: '02',
                  label: 'Termini',
                  trailing: '${mockTrainers.length} TRENERA',
                ),
              ),
              const SizedBox(height: 18),
              StudioCReveal(
                order: 1,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Imenik trenera', style: StudioCType.display(32)),
                    const SizedBox(height: 10),
                    Text(
                      'Izaberite trenera i zakažite termin — svaki profil je '
                      'zaseban članak.',
                      style: StudioCType.body(color: StudioCTokens.inkSoft),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 22),
              const StudioCReveal(order: 2, child: StudioCDoubleRule()),
              for (var i = 0; i < mockTrainers.length; i++)
                StudioCReveal(
                  order: 3 + i,
                  child: _TrainerRow(
                    index: i,
                    trainer: mockTrainers[i],
                    onTap: () => _openTrainer(context, i),
                  ),
                ),
              const StudioCReveal(
                order: 8,
                child: StudioCHairline(),
              ),
              const SizedBox(height: 12),
              StudioCReveal(
                order: 9,
                child: Text(
                  'CENE PO INDIVIDUALNOM TRENINGU · OCENE IZ KNJIGE UTISAKA',
                  style: StudioCType.meta(
                    size: 8.5,
                    letterSpacing: 1.8,
                    color: StudioCTokens.inkSoft.withValues(alpha: 0.75),
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _TrainerRow extends StatelessWidget {
  const _TrainerRow({
    required this.index,
    required this.trainer,
    required this.onTap,
  });

  final int index;
  final MockTrainer trainer;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (index > 0) const StudioCHairline(),
        InkWell(
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 20),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.only(top: 4),
                  child: Text(
                    StudioCFmt.two(index + 1),
                    style: StudioCType.numeral(
                      12,
                      color: StudioCTokens.inkSoft,
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        trainer.name,
                        style: StudioCType.display(
                          22,
                          weight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        trainer.specialty.toUpperCase(),
                        style: StudioCType.meta(size: 9),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'OCENA ${StudioCFmt.dec(trainer.rating)} / 5 · '
                        '${trainer.years} GOD. ISKUSTVA',
                        style: StudioCType.meta(
                          size: 8.5,
                          color: StudioCTokens.inkSoft.withValues(alpha: 0.8),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      '${StudioCFmt.thousands(trainer.priceRsd)} RSD',
                      style: StudioCType.numeral(
                        15,
                        style: FontStyle.normal,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text('PO TRENINGU', style: StudioCType.meta(size: 7.5)),
                    const SizedBox(height: 10),
                    Text(
                      '→',
                      style: StudioCType.body(
                        size: 15,
                        color: StudioCTokens.terracotta,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
