import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../mock_data.dart';
import '../theme.dart';
import '../widgets/effects.dart';

/// Termini — treneri kao startna lista trke: veliki redni broj uz ime,
/// specijalnost uppercase. Tap → detalj trenera (push).
class StudioATrainersScreen extends StatelessWidget {
  const StudioATrainersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      bottom: false,
      child: SingleChildScrollView(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 560),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 20),
                  StudioAReveal(
                    index: 0,
                    child: Text(
                      'STARTNA LISTA — ${mockTrainers.length} TRENERA',
                      style: StudioATheme.label(
                        color: StudioATheme.volt,
                        size: 10.5,
                        tracking: 3,
                      ),
                    ),
                  ),
                  const SizedBox(height: 6),
                  StudioAReveal(
                    index: 1,
                    child:
                        Text('TERMINI', style: StudioATheme.display(size: 38)),
                  ),
                  const SizedBox(height: 8),
                  StudioAReveal(
                    index: 2,
                    child: Text(
                      'Izaberi trenera i zakaži svoj sledeći trening.',
                      style: StudioATheme.body(
                        size: 14,
                        color: StudioATheme.inkDim,
                      ),
                    ),
                  ),
                  const SizedBox(height: 18),
                  const StudioAReveal(index: 3, child: _NextSessionStrip()),
                  const SizedBox(height: 10),
                  for (var i = 0; i < mockTrainers.length; i++)
                    StudioAReveal(
                      index: 4 + i,
                      child: _TrainerRow(trainer: mockTrainers[i], index: i),
                    ),
                  const SizedBox(height: 32),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _NextSessionStrip extends StatelessWidget {
  const _NextSessionStrip();

  @override
  Widget build(BuildContext context) {
    const s = mockNextSession;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
      decoration: const BoxDecoration(
        color: StudioATheme.surface,
        border: Border(
          left: BorderSide(color: StudioATheme.volt, width: 3),
          top: BorderSide(color: StudioATheme.line),
          right: BorderSide(color: StudioATheme.line),
          bottom: BorderSide(color: StudioATheme.line),
        ),
      ),
      child: Row(
        children: [
          const Icon(Icons.schedule_rounded,
              size: 14, color: StudioATheme.volt),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              'TVOJ TERMIN — ${s.weekday.toUpperCase()} ${s.time} • ${s.location.toUpperCase()}',
              style: StudioATheme.label(
                size: 10,
                color: StudioATheme.ink,
                tracking: 1.6,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}

class _TrainerRow extends StatelessWidget {
  const _TrainerRow({required this.trainer, required this.index});

  final MockTrainer trainer;
  final int index;

  @override
  Widget build(BuildContext context) {
    final ordinal = (index + 1).toString().padLeft(2, '0');
    return InkWell(
      onTap: () {
        HapticFeedback.selectionClick();
        Navigator.of(context).push(
          studioARoute(
            StudioATrainerDetailScreen(trainer: trainer, index: index),
          ),
        );
      },
      child: Container(
        decoration: const BoxDecoration(
          border: Border(bottom: BorderSide(color: StudioATheme.line)),
        ),
        padding: const EdgeInsets.symmetric(vertical: 18),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Veliki redni broj — startni broj takmičara.
            SizedBox(
              width: 64,
              child: StudioAGhostText(
                ordinal,
                size: 44,
                color:
                    index == 0 ? StudioATheme.volt : const Color(0xFF3A3A42),
                strokeWidth: 1.3,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    trainer.name.toUpperCase(),
                    style: GoogleFonts.archivoBlack(
                      fontSize: 16,
                      color: StudioATheme.ink,
                      height: 1.05,
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    trainer.specialty.toUpperCase(),
                    style: StudioATheme.label(
                      size: 9.5,
                      color: StudioATheme.volt,
                      tracking: 2.2,
                    ),
                  ),
                  const SizedBox(height: 7),
                  Row(
                    children: [
                      const Icon(Icons.star_rounded,
                          size: 13, color: StudioATheme.volt),
                      const SizedBox(width: 3),
                      Text(
                        studioADec(trainer.rating),
                        style: StudioATheme.body(
                          size: 12,
                          color: StudioATheme.ink,
                          weight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Flexible(
                        child: Text(
                          '${trainer.years} GOD • ${studioARsd(trainer.priceRsd)} RSD',
                          style: StudioATheme.label(
                            size: 9.5,
                            color: StudioATheme.inkDim,
                            tracking: 1.4,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            const Icon(
              Icons.arrow_forward_rounded,
              size: 18,
              color: StudioATheme.inkDim,
            ),
          ],
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════
//  Detalj trenera — hero ime preko 2 reda, statovi u koloni, volt CTA.
// ═══════════════════════════════════════════════════════════════════════

class StudioATrainerDetailScreen extends StatefulWidget {
  const StudioATrainerDetailScreen({
    super.key,
    required this.trainer,
    required this.index,
  });

  final MockTrainer trainer;
  final int index;

  @override
  State<StudioATrainerDetailScreen> createState() =>
      _StudioATrainerDetailScreenState();
}

class _StudioATrainerDetailScreenState
    extends State<StudioATrainerDetailScreen> {
  bool _chosen = false;

  void _choose() {
    if (_chosen) return;
    HapticFeedback.mediumImpact();
    setState(() => _chosen = true);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${widget.trainer.name} je tvoj novi trener.'),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final t = widget.trainer;
    final names = t.name.split(' ');
    final ordinal = (widget.index + 1).toString().padLeft(2, '0');
    return Scaffold(
      body: SafeArea(
        bottom: false,
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 560),
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(24, 12, 24, 0),
                    child: StudioAReveal(
                      index: 0,
                      dy: -12,
                      child: Row(
                        children: [
                          StudioAIconButton(
                            icon: Icons.arrow_back_rounded,
                            tooltip: 'Nazad',
                            onPressed: () => Navigator.of(context).pop(),
                          ),
                          const Spacer(),
                          Text(
                            'TRENER $ordinal/${mockTrainers.length.toString().padLeft(2, '0')}',
                            style:
                                StudioATheme.label(size: 9.5, tracking: 2.6),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 18),
                  // Hero — ime preko dva reda, ghost broj i speed-lines iza.
                  Stack(
                    children: [
                      const Positioned.fill(
                        child: StudioASpeedLines(
                          density: 20,
                          seed: 9,
                          opacity: 0.8,
                        ),
                      ),
                      Positioned(
                        right: -10,
                        top: -18,
                        child: StudioAGhostText(
                          ordinal,
                          size: 150,
                          color: StudioATheme.line,
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.fromLTRB(24, 10, 24, 8),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            for (var i = 0; i < names.length; i++)
                              StudioAReveal(
                                index: 1 + i,
                                dx: -22,
                                dy: 0,
                                child: FittedBox(
                                  fit: BoxFit.scaleDown,
                                  alignment: Alignment.centerLeft,
                                  child: Text(
                                    names[i].toUpperCase(),
                                    style: StudioATheme.display(
                                      size: 46,
                                      color: i == 0
                                          ? StudioATheme.ink
                                          : StudioATheme.volt,
                                    ),
                                  ),
                                ),
                              ),
                            const SizedBox(height: 10),
                            StudioAReveal(
                              index: 3,
                              child: Text(
                                t.specialty.toUpperCase(),
                                style: StudioATheme.label(
                                  size: 11,
                                  color: StudioATheme.ink,
                                  tracking: 3,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 22),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const StudioAReveal(
                          index: 4,
                          child: StudioASectionLabel('Statistika'),
                        ),
                        const SizedBox(height: 4),
                        StudioAReveal(
                          index: 5,
                          child: _StatRow(
                            value: t.rating,
                            decimals: 1,
                            label: 'OCENA KLIJENATA',
                            icon: Icons.star_rounded,
                          ),
                        ),
                        StudioAReveal(
                          index: 6,
                          child: _StatRow(
                            value: t.years.toDouble(),
                            label: 'GODINA ISKUSTVA',
                            icon: Icons.timeline_rounded,
                          ),
                        ),
                        StudioAReveal(
                          index: 7,
                          child: _StatRow(
                            value: t.clients.toDouble(),
                            label: 'AKTIVNIH KLIJENATA',
                            icon: Icons.groups_rounded,
                          ),
                        ),
                        StudioAReveal(
                          index: 8,
                          child: _StatRow(
                            value: t.priceRsd.toDouble(),
                            label: 'RSD PO TRENINGU',
                            icon: Icons.payments_rounded,
                            formatAsRsd: true,
                          ),
                        ),
                        const SizedBox(height: 24),
                        const StudioAReveal(
                          index: 9,
                          child: StudioASectionLabel('Biografija'),
                        ),
                        const SizedBox(height: 12),
                        StudioAReveal(
                          index: 10,
                          child: Text(
                            t.bio,
                            style: StudioATheme.body(size: 15, height: 1.6),
                          ),
                        ),
                        const SizedBox(height: 28),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
      bottomNavigationBar: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 8, 24, 16),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 512),
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 320),
                switchInCurve: Curves.easeOutCubic,
                switchOutCurve: Curves.easeInCubic,
                transitionBuilder: (child, animation) => FadeTransition(
                  opacity: animation,
                  child: ScaleTransition(scale: animation, child: child),
                ),
                child: SizedBox(
                  key: ValueKey(_chosen),
                  width: double.infinity,
                  child: StudioAVoltButton(
                    label: _chosen ? 'Trener izabran' : 'Izaberi trenera',
                    icon: _chosen ? Icons.check_rounded : Icons.bolt_rounded,
                    filled: !_chosen,
                    onPressed: _choose,
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _StatRow extends StatelessWidget {
  const _StatRow({
    required this.value,
    required this.label,
    required this.icon,
    this.decimals = 0,
    this.formatAsRsd = false,
  });

  final double value;
  final String label;
  final IconData icon;
  final int decimals;
  final bool formatAsRsd;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: StudioATheme.line)),
      ),
      padding: const EdgeInsets.symmetric(vertical: 14),
      child: Row(
        children: [
          Icon(icon, size: 16, color: StudioATheme.volt),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              label,
              style: StudioATheme.label(
                size: 10,
                color: StudioATheme.inkDim,
                tracking: 2,
              ),
            ),
          ),
          if (formatAsRsd)
            _RsdCountUp(value: value.round())
          else
            StudioACountUp(
              value: value,
              decimals: decimals,
              style: StudioATheme.display(size: 26),
            ),
        ],
      ),
    );
  }
}

/// Count-up sa RSD formatiranjem hiljada (2.500).
class _RsdCountUp extends StatelessWidget {
  const _RsdCountUp({required this.value});

  final int value;

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: value.toDouble()),
      duration: const Duration(milliseconds: 1100),
      curve: Curves.easeOutExpo,
      builder: (context, v, _) => Text(
        studioARsd(v.round()),
        style: StudioATheme.display(size: 26),
      ),
    );
  }
}
