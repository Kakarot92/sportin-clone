import 'package:flutter/material.dart';

import '../mock_data.dart';
import 'studio_b_aurora.dart';
import 'studio_b_glass.dart';
import 'studio_b_tokens.dart';

/// Termini — direktorijum trenera. Ocena je iscrtana kao mint luk oko
/// avatara (signature detalj), tap vodi na detalj sa Hero tranzicijom.
class StudioBScheduleTab extends StatelessWidget {
  const StudioBScheduleTab({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 520),
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 14, 20, 120),
          children: [
            StudioBReveal(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Termini',
                          style: StudioBTokens.display(
                            size: 27,
                            weight: FontWeight.w700,
                            spacing: -0.5,
                          ),
                        ),
                        const SizedBox(height: 3),
                        Text(
                          'Izaberi trenera i zakaži trening',
                          style: StudioBTokens.body(
                            size: 13.5,
                            weight: FontWeight.w600,
                            color: StudioBTokens.inkSoft,
                          ),
                        ),
                      ],
                    ),
                  ),
                  StudioBChip(
                    label: '${mockTrainers.length} trenera',
                    icon: Icons.fitness_center_rounded,
                    background: StudioBTokens.violet.withValues(alpha: 0.12),
                    foreground: StudioBTokens.violetDeep,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            for (var i = 0; i < mockTrainers.length; i++) ...[
              StudioBReveal(
                delayMs: 100 + i * 80,
                child: _TrainerCard(trainer: mockTrainers[i]),
              ),
              if (i < mockTrainers.length - 1) const SizedBox(height: 14),
            ],
          ],
        ),
      ),
    );
  }
}

class _TrainerCard extends StatelessWidget {
  const _TrainerCard({required this.trainer});

  final MockTrainer trainer;

  @override
  Widget build(BuildContext context) {
    return StudioBGlass(
      onTap: () => Navigator.of(context).push(
        studioBRoute<void>(StudioBTrainerDetailScreen(trainer: trainer)),
      ),
      padding: const EdgeInsets.fromLTRB(16, 16, 14, 16),
      child: Row(
        children: [
          StudioBAvatar(
            name: trainer.name,
            size: 64,
            ring: trainer.rating / 5,
            heroTag: 'sb-trainer-${trainer.name}',
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  trainer.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: StudioBTokens.display(
                    size: 16,
                    weight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  trainer.specialty,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: StudioBTokens.body(
                    size: 13,
                    weight: FontWeight.w600,
                    color: StudioBTokens.inkSoft,
                  ),
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    const Icon(
                      Icons.star_rounded,
                      size: 15,
                      color: StudioBTokens.star,
                    ),
                    const SizedBox(width: 3),
                    Text(
                      studioBDecimal(trainer.rating),
                      style: StudioBTokens.label(
                        size: 12,
                        color: StudioBTokens.ink,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Flexible(
                      child: Text(
                        '· ${trainer.years} god. iskustva',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: StudioBTokens.label(size: 11.5),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(width: 10),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                studioBPrice(trainer.priceRsd),
                style: StudioBTokens.display(
                  size: 14.5,
                  weight: FontWeight.w700,
                  color: StudioBTokens.violetDeep,
                ),
              ),
              const SizedBox(height: 2),
              Text('po treningu', style: StudioBTokens.label(size: 10.5)),
            ],
          ),
          const Icon(
            Icons.chevron_right_rounded,
            color: StudioBTokens.inkSoft,
          ),
        ],
      ),
    );
  }
}

/// Detalj trenera — Hero avatar, frosted stat-šina, biografija i CTA
/// „Izaberi trenera" sa animiranom potvrdom.
class StudioBTrainerDetailScreen extends StatelessWidget {
  const StudioBTrainerDetailScreen({super.key, required this.trainer});

  final MockTrainer trainer;

  void _confirm(BuildContext context) {
    showGeneralDialog<void>(
      context: context,
      barrierDismissible: true,
      barrierLabel: 'Zatvori',
      barrierColor: StudioBTokens.ink.withValues(alpha: 0.25),
      transitionDuration: const Duration(milliseconds: 420),
      pageBuilder: (_, _, _) => const SizedBox.shrink(),
      transitionBuilder: (dialogContext, animation, _, _) {
        final curved = CurvedAnimation(
          parent: animation,
          curve: Curves.easeOutBack,
          reverseCurve: Curves.easeInCubic,
        );
        return Center(
          child: FadeTransition(
            opacity: animation,
            child: ScaleTransition(
              scale: Tween<double>(begin: 0.85, end: 1).animate(curved),
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 330),
                  child: StudioBGlass(
                    opacity: 0.86,
                    padding: const EdgeInsets.fromLTRB(24, 28, 24, 22),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Center(
                          child: Container(
                            width: 64,
                            height: 64,
                            decoration: const BoxDecoration(
                              shape: BoxShape.circle,
                              gradient: LinearGradient(
                                colors: [
                                  StudioBTokens.mint,
                                  StudioBTokens.mintDeep,
                                ],
                              ),
                            ),
                            child: const Icon(
                              Icons.check_rounded,
                              size: 34,
                              color: Colors.white,
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Zahtev poslat',
                          textAlign: TextAlign.center,
                          style: StudioBTokens.display(
                            size: 20,
                            weight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          '${trainer.name} će ti potvrditi prvi termin '
                          'u porukama.',
                          textAlign: TextAlign.center,
                          style: StudioBTokens.body(
                            size: 13.5,
                            color: StudioBTokens.inkSoft,
                            height: 1.5,
                          ),
                        ),
                        const SizedBox(height: 20),
                        StudioBPillButton(
                          label: 'U redu',
                          height: 50,
                          onPressed: () => Navigator.of(dialogContext).pop(),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final bottomSafe = MediaQuery.paddingOf(context).bottom;

    return Scaffold(
      body: StudioBAuroraBackground(
        veil: 0.05,
        child: Stack(
          children: [
            Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 520),
                child: ListView(
                  padding: EdgeInsets.fromLTRB(
                    20,
                    MediaQuery.paddingOf(context).top + 18,
                    20,
                    120 + bottomSafe,
                  ),
                  children: [
                    Center(
                      child: StudioBAvatar(
                        name: trainer.name,
                        size: 108,
                        ring: trainer.rating / 5,
                        heroTag: 'sb-trainer-${trainer.name}',
                      ),
                    ),
                    const SizedBox(height: 16),
                    StudioBReveal(
                      delayMs: 60,
                      child: Column(
                        children: [
                          Text(
                            trainer.name,
                            textAlign: TextAlign.center,
                            style: StudioBTokens.display(
                              size: 25,
                              weight: FontWeight.w700,
                              spacing: -0.5,
                            ),
                          ),
                          const SizedBox(height: 10),
                          StudioBChip(
                            label: trainer.specialty,
                            icon: Icons.fitness_center_rounded,
                            background:
                                StudioBTokens.violet.withValues(alpha: 0.12),
                            foreground: StudioBTokens.violetDeep,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 22),
                    StudioBReveal(
                      delayMs: 140,
                      child: StudioBGlass(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 16,
                        ),
                        child: Row(
                          children: [
                            _RailStat(
                              value: studioBDecimal(trainer.rating),
                              caption: 'ocena',
                              icon: Icons.star_rounded,
                              iconColor: StudioBTokens.star,
                            ),
                            _railDivider(),
                            _RailStat(
                              value: '${trainer.years}',
                              caption: 'god. iskustva',
                            ),
                            _railDivider(),
                            _RailStat(
                              value: '${trainer.clients}',
                              caption: 'klijenata',
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 22),
                    StudioBReveal(
                      delayMs: 220,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          const StudioBSectionHeader(title: 'Biografija'),
                          StudioBGlass(
                            child: Text(
                              trainer.bio,
                              style: StudioBTokens.body(
                                size: 14.5,
                                height: 1.65,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    StudioBReveal(
                      delayMs: 300,
                      child: StudioBGlass(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 16,
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child: Text(
                                'Cena treninga',
                                style: StudioBTokens.body(
                                  size: 13.5,
                                  weight: FontWeight.w600,
                                  color: StudioBTokens.inkSoft,
                                ),
                              ),
                            ),
                            Text(
                              studioBPrice(trainer.priceRsd),
                              style: StudioBTokens.display(
                                size: 18,
                                weight: FontWeight.w700,
                                color: StudioBTokens.violetDeep,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            // Nazad — glass krug, pinovan uz gornju ivicu.
            Positioned(
              top: MediaQuery.paddingOf(context).top + 12,
              left: 16,
              child: const _GlassBackButton(),
            ),
            // CTA pinovan pri dnu.
            Positioned(
              left: 20,
              right: 20,
              bottom: bottomSafe + 18,
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 480),
                  child: StudioBPillButton(
                    label: 'Izaberi trenera',
                    icon: Icons.event_available_rounded,
                    onPressed: () => _confirm(context),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _railDivider() {
    return Container(
      width: 1,
      height: 34,
      color: StudioBTokens.ink.withValues(alpha: 0.08),
    );
  }
}

class _RailStat extends StatelessWidget {
  const _RailStat({
    required this.value,
    required this.caption,
    this.icon,
    this.iconColor,
  });

  final String value;
  final String caption;
  final IconData? icon;
  final Color? iconColor;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (icon != null) ...[
                Icon(icon, size: 18, color: iconColor),
                const SizedBox(width: 3),
              ],
              Text(
                value,
                style: StudioBTokens.display(size: 20, weight: FontWeight.w700),
              ),
            ],
          ),
          const SizedBox(height: 2),
          Text(caption, style: StudioBTokens.label(size: 10.5)),
        ],
      ),
    );
  }
}

class _GlassBackButton extends StatelessWidget {
  const _GlassBackButton();

  @override
  Widget build(BuildContext context) {
    return StudioBGlass(
      radius: 24,
      opacity: 0.65,
      blur: 18,
      padding: EdgeInsets.zero,
      onTap: () => Navigator.of(context).maybePop(),
      child: const SizedBox(
        width: 48,
        height: 48,
        child: Icon(
          Icons.arrow_back_rounded,
          size: 22,
          color: StudioBTokens.ink,
        ),
      ),
    );
  }
}
