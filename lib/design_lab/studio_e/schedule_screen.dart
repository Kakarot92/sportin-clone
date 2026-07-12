import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../mock_data.dart';
import 'theme.dart';
import 'trainer_detail_screen.dart';
import 'widgets.dart';

/// Termini — zakazani trening + direktorijum trenera (noćne kartice
/// sa neon ivicom). Tap na trenera gura detalj ekran.
class StudioEScheduleScreen extends StatefulWidget {
  const StudioEScheduleScreen({super.key});

  @override
  State<StudioEScheduleScreen> createState() => _StudioEScheduleScreenState();
}

class _StudioEScheduleScreenState extends State<StudioEScheduleScreen> {
  final ScrollController _scroll = ScrollController();

  @override
  void dispose() {
    _scroll.dispose();
    super.dispose();
  }

  void _openTrainer(MockTrainer trainer) {
    Navigator.of(context).push(
      StudioEPageRoute<void>(
        builder: (_) => StudioETrainerDetailScreen(trainer: trainer),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context).textTheme;
    return Scaffold(
      body: Stack(
        children: [
          StudioEParallaxBackdrop(controller: _scroll),
          SafeArea(
            bottom: false,
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 560),
                child: ListView(
                  controller: _scroll,
                  padding: const EdgeInsets.fromLTRB(
                    StudioESpace.xl,
                    StudioESpace.l,
                    StudioESpace.xl,
                    StudioESpace.section,
                  ),
                  children: [
                    StudioEEntrance(
                      child: StudioEGradientText(
                        'Termini',
                        style: theme.displaySmall!,
                      ),
                    ),
                    const SizedBox(height: StudioESpace.xs + 2),
                    StudioEEntrance(
                      delayMs: 60,
                      child: Text(
                        'Izaberi trenera i zakaži svoj sledeći trening.',
                        style: theme.bodyMedium!
                            .copyWith(color: StudioEColors.textDim),
                      ),
                    ),
                    const SizedBox(height: StudioESpace.xl),

                    // Zakazani termin — jedina glow kartica na ekranu.
                    StudioEEntrance(
                      delayMs: 120,
                      child: StudioEDepthCard(
                        emphasis: true,
                        child: Row(
                          children: [
                            Container(
                              width: 62,
                              height: 58,
                              decoration: BoxDecoration(
                                color: StudioEColors.layer2,
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(
                                  color: StudioEColors.hairline,
                                ),
                              ),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    mockNextSession.time,
                                    style: GoogleFonts.syne(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w700,
                                      color: StudioEColors.cyan,
                                      height: 1.1,
                                    ),
                                  ),
                                  Text(
                                    mockNextSession.weekday,
                                    style: GoogleFonts.ibmPlexSans(
                                      fontSize: 10.5,
                                      fontWeight: FontWeight.w500,
                                      color: StudioEColors.textDim,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: StudioESpace.l - 2),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('ZAKAZANO', style: theme.labelSmall),
                                  const SizedBox(height: StudioESpace.xs),
                                  Text(
                                    mockNextSession.type,
                                    style: theme.titleMedium,
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    '${mockNextSession.trainer} · '
                                    '${mockNextSession.location} · '
                                    '${mockNextSession.date}',
                                    style: theme.bodySmall,
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: StudioESpace.section),

                    const StudioEEntrance(
                      delayMs: 180,
                      child: StudioESectionLabel('Treneri'),
                    ),
                    const SizedBox(height: StudioESpace.m),
                    for (var i = 0; i < mockTrainers.length; i++) ...[
                      StudioEEntrance(
                        delayMs: 220 + i * 70,
                        child: _TrainerCard(
                          trainer: mockTrainers[i],
                          onTap: () => _openTrainer(mockTrainers[i]),
                        ),
                      ),
                      if (i < mockTrainers.length - 1)
                        const SizedBox(height: StudioESpace.m),
                    ],
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _TrainerCard extends StatelessWidget {
  const _TrainerCard({required this.trainer, required this.onTap});

  final MockTrainer trainer;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context).textTheme;
    return StudioEDepthCard(
      onTap: onTap,
      child: Row(
        children: [
          StudioEAvatar(
            name: trainer.name,
            size: 54,
            heroTag: 'studio_e_trainer_${trainer.name}',
          ),
          const SizedBox(width: StudioESpace.l - 2),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  trainer.name,
                  style: theme.headlineSmall,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  trainer.specialty,
                  style: theme.bodySmall,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: StudioESpace.s),
                Row(
                  children: [
                    const Icon(
                      Icons.star_rounded,
                      size: 15,
                      color: StudioEColors.cyan,
                    ),
                    const SizedBox(width: 3),
                    Text(
                      StudioEFmt.decimal(trainer.rating),
                      style: GoogleFonts.ibmPlexSans(
                        fontSize: 12.5,
                        fontWeight: FontWeight.w600,
                        color: StudioEColors.text,
                      ),
                    ),
                    const SizedBox(width: StudioESpace.m),
                    Flexible(
                      child: Text(
                        '${trainer.years} god. iskustva',
                        style: theme.bodySmall,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(width: StudioESpace.s),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '${StudioEFmt.thousands(trainer.priceRsd)} RSD',
                style: GoogleFonts.ibmPlexSans(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: StudioEColors.cyan,
                ),
              ),
              Text('po treningu', style: theme.bodySmall),
            ],
          ),
          const SizedBox(width: StudioESpace.xs),
          const Icon(
            Icons.chevron_right_rounded,
            size: 20,
            color: StudioEColors.textDim,
          ),
        ],
      ),
    );
  }
}
