import 'package:flutter/material.dart';

import '../mock_data.dart';
import 'studio_d_theme.dart';

/// Termini — direktorijum trenera kao trading-card kartice:
/// monogram, ocena-sticker u uglu, mono spec-traka. Tap → dosije (push).
class StudioDTrainersScreen extends StatelessWidget {
  const StudioDTrainersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return StudioDPage(
      children: [
        StudioDStagger(
          index: 0,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Expanded(
                child: Text(
                  'TERMINI',
                  style: StudioDType.grotesk(
                    size: 30,
                    weight: FontWeight.w700,
                    spacing: 1.5,
                  ),
                ),
              ),
              StudioDTag(
                '${mockTrainers.length} trenera',
                fill: StudioDColors.paper,
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        StudioDStagger(
          index: 0,
          child: StudioDPanel(
            color: StudioDColors.blue,
            shadow: 3,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            child: Row(
              children: [
                const Icon(
                  Icons.info_sharp,
                  size: 16,
                  color: StudioDColors.white,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'Izaberi trenera i zakaži svoj sledeći trening.',
                    style: StudioDType.grotesk(
                      size: 13,
                      weight: FontWeight.w500,
                      color: StudioDColors.white,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 24),
        for (var i = 0; i < mockTrainers.length; i++)
          StudioDStagger(
            index: i + 1,
            child: Padding(
              padding: const EdgeInsets.only(bottom: 22),
              child: _StudioDTrainerCard(trainer: mockTrainers[i], index: i),
            ),
          ),
      ],
    );
  }
}

class _StudioDTrainerCard extends StatelessWidget {
  const _StudioDTrainerCard({required this.trainer, required this.index});

  final MockTrainer trainer;
  final int index;

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        StudioDPressable(
          shadow: 4,
          padding: const EdgeInsets.fromLTRB(14, 14, 14, 12),
          onTap: () => Navigator.of(context).push(
            studioDRoute(
              StudioDTrainerDetailScreen(trainer: trainer, index: index),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  StudioDMonogram(trainer.name, size: 58, paletteIndex: index),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          // Prostor za ocenu-sticker u gornjem desnom uglu.
                          padding: const EdgeInsets.only(right: 64),
                          child: Text(
                            trainer.name,
                            style: StudioDType.grotesk(
                              size: 17,
                              weight: FontWeight.w700,
                            ),
                          ),
                        ),
                        const SizedBox(height: 6),
                        StudioDTag(trainer.specialty,
                            fill: StudioDColors.paper),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                trainer.bio,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: StudioDType.grotesk(
                  size: 13,
                  color: StudioDColors.inkSoft,
                  height: 1.45,
                ),
              ),
              const SizedBox(height: 12),
              Container(height: 2, color: StudioDColors.ink),
              const SizedBox(height: 10),
              Row(
                children: [
                  _StudioDSpecCell(
                    label: 'ISKUSTVO',
                    value: '${trainer.years} GOD',
                  ),
                  _divider(),
                  _StudioDSpecCell(
                    label: 'KLIJENATA',
                    value: '${trainer.clients}',
                  ),
                  _divider(),
                  _StudioDSpecCell(
                    label: 'CENA',
                    value: '${studioDRsd(trainer.priceRsd)} RSD',
                  ),
                ],
              ),
            ],
          ),
        ),
        Positioned(
          top: -10,
          right: 12,
          child: StudioDSticker(
            trainer.rating.toStringAsFixed(1),
            icon: Icons.star_sharp,
            color: StudioDColors.yellow,
            angleDeg: index.isEven ? 2.5 : -2.5,
          ),
        ),
      ],
    );
  }

  Widget _divider() {
    return Container(
      width: 2,
      height: 26,
      color: StudioDColors.ink,
      margin: const EdgeInsets.symmetric(horizontal: 4),
    );
  }
}

class _StudioDSpecCell extends StatelessWidget {
  const _StudioDSpecCell({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        children: [
          Text(
            label,
            style: StudioDType.mono(
              size: 8,
              weight: FontWeight.w700,
              color: StudioDColors.inkSoft,
              spacing: 0.5,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: StudioDType.mono(size: 12, weight: FontWeight.w700),
          ),
        ],
      ),
    );
  }
}

/// Dosije trenera (push): monogram + ime, zebra spec-sheet tabela,
/// biografija, CTA „Izaberi trenera".
class StudioDTrainerDetailScreen extends StatelessWidget {
  const StudioDTrainerDetailScreen({
    super.key,
    required this.trainer,
    required this.index,
  });

  final MockTrainer trainer;
  final int index;

  @override
  Widget build(BuildContext context) {
    final specs = <(String, String)>[
      ('SPECIJALNOST', trainer.specialty),
      ('OCENA', '${trainer.rating.toStringAsFixed(1)} / 5.0'),
      ('ISKUSTVO', '${trainer.years} GODINA'),
      ('KLIJENATA', '${trainer.clients}'),
      ('CENA', '${studioDRsd(trainer.priceRsd)} RSD'),
    ];

    return Scaffold(
      body: StudioDGridPaper(
        child: SafeArea(
          bottom: false,
          child: Column(
            children: [
              StudioDTopBar(
                title: 'Dosije trenera',
                trailing: StudioDTag(
                  'ID 0${index + 1}',
                  fill: StudioDColors.yellow,
                ),
              ),
              Expanded(
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 560),
                    child: ListView(
                      padding: const EdgeInsets.fromLTRB(16, 20, 16, 24),
                      children: [
                        _buildHeaderCard(),
                        const SizedBox(height: 22),
                        StudioDSectionLabel(
                          'Spec-sheet',
                          trailing: const StudioDTag(
                            'Podaci',
                            fill: StudioDColors.paper,
                          ),
                        ),
                        _buildSpecTable(specs),
                        const SizedBox(height: 22),
                        const StudioDSectionLabel('Biografija'),
                        StudioDPanel(
                          padding: const EdgeInsets.all(14),
                          child: Text(
                            trainer.bio,
                            style: StudioDType.grotesk(
                              size: 14,
                              height: 1.55,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          color: StudioDColors.white,
          border: Border(top: BorderSide(color: StudioDColors.ink, width: 2)),
        ),
        child: SafeArea(
          top: false,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 560),
                child: StudioDPressable(
                  color: StudioDColors.yellow,
                  shadow: 5,
                  padding: const EdgeInsets.symmetric(vertical: 15),
                  onTap: () => studioDToast(
                    context,
                    'Zahtev poslat — ${trainer.name}',
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'IZABERI TRENERA',
                        style: StudioDType.grotesk(
                          size: 15,
                          weight: FontWeight.w700,
                          spacing: 1.2,
                        ),
                      ),
                      const SizedBox(width: 8),
                      const Icon(
                        Icons.arrow_forward_sharp,
                        size: 18,
                        color: StudioDColors.ink,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeaderCard() {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        StudioDPanel(
          shadow: 5,
          padding: const EdgeInsets.all(14),
          child: Row(
            children: [
              StudioDMonogram(trainer.name, size: 76, paletteIndex: index),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(right: 56),
                      child: Text(
                        trainer.name,
                        style: StudioDType.grotesk(
                          size: 21,
                          weight: FontWeight.w700,
                          height: 1.1,
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    StudioDTag(trainer.specialty, fill: StudioDColors.paper),
                  ],
                ),
              ),
            ],
          ),
        ),
        Positioned(
          top: -12,
          right: 10,
          child: StudioDSticker(
            trainer.rating.toStringAsFixed(1),
            icon: Icons.star_sharp,
            color: StudioDColors.yellow,
            angleDeg: 3,
          ),
        ),
      ],
    );
  }

  Widget _buildSpecTable(List<(String, String)> specs) {
    return StudioDPanel(
      padding: EdgeInsets.zero,
      child: Column(
        children: [
          for (var i = 0; i < specs.length; i++)
            Container(
              color: i.isEven ? StudioDColors.white : StudioDColors.zebra,
              padding: const EdgeInsets.symmetric(
                horizontal: 14,
                vertical: 11,
              ),
              child: Row(
                children: [
                  Text(
                    specs[i].$1,
                    style: StudioDType.mono(
                      size: 10,
                      weight: FontWeight.w700,
                      color: StudioDColors.inkSoft,
                      spacing: 0.8,
                    ),
                  ),
                  const Spacer(),
                  Flexible(
                    child: Text(
                      specs[i].$2.toUpperCase(),
                      textAlign: TextAlign.right,
                      style:
                          StudioDType.mono(size: 12.5, weight: FontWeight.w700),
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}
