import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../mock_data.dart';
import 'theme.dart';
import 'widgets.dart';

/// Detalj trenera (push): glow avatar, bio, statistike, cyan CTA
/// „Izaberi trenera". Tri plana: parallax pozadi, kartice sadržaja,
/// glow avatar + CTA napred.
class StudioETrainerDetailScreen extends StatefulWidget {
  const StudioETrainerDetailScreen({super.key, required this.trainer});

  final MockTrainer trainer;

  @override
  State<StudioETrainerDetailScreen> createState() =>
      _StudioETrainerDetailScreenState();
}

class _StudioETrainerDetailScreenState
    extends State<StudioETrainerDetailScreen> {
  final ScrollController _scroll = ScrollController();

  @override
  void dispose() {
    _scroll.dispose();
    super.dispose();
  }

  void _choose() {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(
            '${widget.trainer.name} je tvoj trener. Javićemo mu se za termin.',
          ),
        ),
      );
  }

  @override
  Widget build(BuildContext context) {
    final t = widget.trainer;
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
                child: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.fromLTRB(
                        StudioESpace.l,
                        StudioESpace.s,
                        StudioESpace.l,
                        0,
                      ),
                      child: Row(
                        children: [
                          const StudioEBackButton(),
                          const SizedBox(width: StudioESpace.m),
                          Text('Profil trenera', style: theme.titleMedium),
                        ],
                      ),
                    ),
                    Expanded(
                      child: ListView(
                        controller: _scroll,
                        padding: const EdgeInsets.fromLTRB(
                          StudioESpace.xl,
                          StudioESpace.l,
                          StudioESpace.xl,
                          StudioESpace.section,
                        ),
                        children: [
                          Center(
                            child: StudioEAvatar(
                              name: t.name,
                              size: 108,
                              glow: true,
                              heroTag: 'studio_e_trainer_${t.name}',
                            ),
                          ),
                          const SizedBox(height: StudioESpace.l),
                          Center(
                            child: StudioEGradientText(
                              t.name,
                              style: theme.headlineMedium!,
                              textAlign: TextAlign.center,
                            ),
                          ),
                          const SizedBox(height: StudioESpace.xs),
                          Center(
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: StudioESpace.m,
                                vertical: 5,
                              ),
                              decoration: BoxDecoration(
                                color: StudioEColors.layer2,
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(
                                  color:
                                      StudioEColors.violet.withValues(alpha: 0.4),
                                ),
                              ),
                              child: Text(
                                t.specialty,
                                style: GoogleFonts.ibmPlexSans(
                                  fontSize: 12.5,
                                  fontWeight: FontWeight.w600,
                                  color: StudioEColors.violet,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: StudioESpace.xl),

                          StudioEEntrance(
                            child: Row(
                              children: [
                                Expanded(
                                  child: _MetricTile(
                                    value: StudioEFmt.decimal(t.rating),
                                    label: 'ocena',
                                    icon: Icons.star_rounded,
                                  ),
                                ),
                                const SizedBox(width: StudioESpace.m - 2),
                                Expanded(
                                  child: _MetricTile(
                                    value: '${t.years}',
                                    label: 'god. iskustva',
                                    icon: Icons.workspace_premium_rounded,
                                  ),
                                ),
                                const SizedBox(width: StudioESpace.m - 2),
                                Expanded(
                                  child: _MetricTile(
                                    value: '${t.clients}',
                                    label: 'klijenata',
                                    icon: Icons.groups_rounded,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: StudioESpace.section),

                          const StudioESectionLabel('Biografija'),
                          const SizedBox(height: StudioESpace.m),
                          StudioEDepthCard(
                            child: Text(
                              t.bio,
                              style: theme.bodyMedium!.copyWith(height: 1.6),
                            ),
                          ),
                          const SizedBox(height: StudioESpace.section),

                          StudioEDepthCard(
                            padding: const EdgeInsets.symmetric(
                              horizontal: StudioESpace.l,
                              vertical: StudioESpace.l,
                            ),
                            child: Row(
                              children: [
                                Column(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.start,
                                  children: [
                                    Text('CENA TRENINGA',
                                        style: theme.labelSmall),
                                    const SizedBox(height: StudioESpace.xs),
                                    Text(
                                      '${StudioEFmt.thousands(t.priceRsd)} RSD',
                                      style: GoogleFonts.syne(
                                        fontSize: 24,
                                        fontWeight: FontWeight.w800,
                                        color: StudioEColors.text,
                                      ),
                                    ),
                                  ],
                                ),
                                const Spacer(),
                                Text('60 min · 1 na 1', style: theme.bodySmall),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    // CTA zakačen za dno — cyan, glow.
                    Container(
                      padding: EdgeInsets.fromLTRB(
                        StudioESpace.xl,
                        StudioESpace.m,
                        StudioESpace.xl,
                        MediaQuery.paddingOf(context).bottom + StudioESpace.m,
                      ),
                      decoration: const BoxDecoration(
                        color: StudioEColors.bg,
                        border: Border(
                          top: BorderSide(color: StudioEColors.hairline),
                        ),
                      ),
                      child: StudioEGlowButton(
                        label: 'Izaberi trenera',
                        icon: Icons.check_circle_outline_rounded,
                        onPressed: _choose,
                      ),
                    ),
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

class _MetricTile extends StatelessWidget {
  const _MetricTile({
    required this.value,
    required this.label,
    required this.icon,
  });

  final String value;
  final String label;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return StudioEDepthCard(
      padding: const EdgeInsets.symmetric(
        horizontal: StudioESpace.s,
        vertical: StudioESpace.l,
      ),
      child: Column(
        children: [
          Icon(icon, size: 18, color: StudioEColors.cyan),
          const SizedBox(height: StudioESpace.s),
          Text(
            value,
            style: GoogleFonts.syne(
              fontSize: 20,
              fontWeight: FontWeight.w800,
              color: StudioEColors.text,
              height: 1,
            ),
          ),
          const SizedBox(height: StudioESpace.xs),
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              label.toUpperCase(),
              maxLines: 1,
              style: GoogleFonts.ibmPlexSans(
                fontSize: 9,
                fontWeight: FontWeight.w600,
                letterSpacing: 0.9,
                color: StudioEColors.textDim,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
