import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../mock_data.dart';
import '../theme.dart';
import '../widgets/effects.dart';

/// Početna — sledeći trening kao poster-blok, nedeljni statovi na
/// track-lane linijama, marquee separator, prečice.
class StudioAHomeScreen extends StatelessWidget {
  const StudioAHomeScreen({super.key, required this.onQuickNav});

  /// Prebacivanje na drugi tab iz prečica (1 = Termini, 2 = Merenja, 3 = Poruke).
  final ValueChanged<int> onQuickNav;

  @override
  Widget build(BuildContext context) {
    final lost = mockMeasurements.first.weightKg - mockMeasurements.last.weightKg;
    return SafeArea(
      bottom: false,
      child: SingleChildScrollView(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 560),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(24, 20, 24, 0),
                  child: _greeting(),
                ),
                const SizedBox(height: 22),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: StudioAReveal(index: 2, child: const _SessionPoster()),
                ),
                const SizedBox(height: 26),
                StudioAReveal(
                  index: 3,
                  child: const StudioAMarquee(
                    words: [
                      'SNAGA',
                      'KONDICIJA',
                      'DISCIPLINA',
                      'FOKUS',
                      'TEMPO',
                      'IZDRŽLJIVOST',
                    ],
                  ),
                ),
                const SizedBox(height: 26),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      StudioAReveal(
                        index: 4,
                        child: const StudioASectionLabel('Ova nedelja'),
                      ),
                      const SizedBox(height: 6),
                      StudioAReveal(
                        index: 5,
                        child: _StatLane(
                          value: mockWeekStats.trainingsThisWeek,
                          lane: 1,
                          label: 'TRENINGA\nOVE NEDELJE',
                        ),
                      ),
                      StudioAReveal(
                        index: 6,
                        child: _StatLane(
                          value: mockWeekStats.trainingsThisMonth,
                          lane: 2,
                          label: 'TRENINGA\nOVOG MESECA',
                        ),
                      ),
                      StudioAReveal(
                        index: 7,
                        child: _StatLane(
                          value: mockWeekStats.streakWeeks,
                          lane: 3,
                          label: 'NEDELJA\nU NIZU',
                          highlight: true,
                        ),
                      ),
                      const SizedBox(height: 26),
                      StudioAReveal(
                        index: 8,
                        child: const StudioASectionLabel('Prečice'),
                      ),
                      const SizedBox(height: 14),
                      StudioAReveal(
                        index: 9,
                        child: _QuickAction(
                          title: 'ZAKAŽI TERMIN',
                          sub: 'Startna lista — ${mockTrainers.length} trenera',
                          onTap: () => onQuickNav(1),
                        ),
                      ),
                      const SizedBox(height: 10),
                      StudioAReveal(
                        index: 10,
                        child: _QuickAction(
                          title: 'MERENJA I NAPREDAK',
                          sub: '−${studioADec(lost)} kg za 12 nedelja',
                          onTap: () => onQuickNav(2),
                        ),
                      ),
                      const SizedBox(height: 10),
                      StudioAReveal(
                        index: 11,
                        child: _QuickAction(
                          title: 'PIŠI TRENERU',
                          sub: mockNextSession.trainer,
                          onTap: () => onQuickNav(3),
                        ),
                      ),
                      const SizedBox(height: 32),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _greeting() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        StudioAReveal(
          index: 0,
          child: Text(
            'DOBRODOŠLI U VAŠ STUDIO',
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
          child: Text(
            'ZDRAVO,\n${mockUser.name.toUpperCase()}.',
            style: StudioATheme.display(size: 38),
          ),
        ),
      ],
    );
  }
}

// ── Poster sledećeg treninga ─────────────────────────────────────────────

class _SessionPoster extends StatelessWidget {
  const _SessionPoster();

  @override
  Widget build(BuildContext context) {
    const s = mockNextSession;
    return Transform.rotate(
      angle: StudioATheme.tilt * 0.75,
      child: ClipPath(
        clipper: const StudioADiagonalClipper(depth: 16),
        child: Container(
          width: double.infinity,
          color: StudioATheme.surface,
          child: Stack(
            children: [
              const Positioned.fill(
                child: StudioASpeedLines(density: 18, seed: 4, opacity: 0.9),
              ),
              // Ghost sat u pozadini — poster dubina.
              Positioned(
                right: -8,
                bottom: 2,
                child: StudioAGhostText(
                  s.time,
                  size: 88,
                  color: StudioATheme.line,
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(22, 28, 22, 30),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const StudioAPulseDot(size: 8),
                        const SizedBox(width: 8),
                        Text(
                          'SLEDEĆI TRENING',
                          style: StudioATheme.label(
                            color: StudioATheme.volt,
                            size: 10.5,
                            tracking: 3,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    FittedBox(
                      fit: BoxFit.scaleDown,
                      alignment: Alignment.centerLeft,
                      child: Text(
                        s.weekday.toUpperCase(),
                        style: StudioATheme.display(size: 52),
                      ),
                    ),
                    FittedBox(
                      fit: BoxFit.scaleDown,
                      alignment: Alignment.centerLeft,
                      child: Text(
                        s.time,
                        style: StudioATheme.display(
                          size: 52,
                          color: StudioATheme.volt,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    const Divider(height: 1, color: StudioATheme.line),
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 14,
                      runSpacing: 6,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      children: [
                        _meta(Icons.calendar_today_rounded, s.date.toUpperCase()),
                        _meta(Icons.place_rounded, s.location.toUpperCase()),
                        _meta(Icons.fitness_center_rounded,
                            s.type.toUpperCase()),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Text(
                      'Trener: ${s.trainer}',
                      style: StudioATheme.body(
                        size: 13.5,
                        color: StudioATheme.inkDim,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _meta(IconData icon, String text) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 12, color: StudioATheme.volt),
        const SizedBox(width: 6),
        Text(
          text,
          style: StudioATheme.label(
            size: 10.5,
            color: StudioATheme.ink,
            tracking: 1.4,
          ),
        ),
      ],
    );
  }
}

// ── Track-lane stat ──────────────────────────────────────────────────────

class _StatLane extends StatelessWidget {
  const _StatLane({
    required this.value,
    required this.label,
    required this.lane,
    this.highlight = false,
  });

  final int value;
  final String label;
  final int lane;
  final bool highlight;

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _LanePainter(lane: lane),
      child: SizedBox(
        height: 76,
        width: double.infinity,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SizedBox(
              width: 86,
              child: StudioACountUp(
                value: value.toDouble(),
                style: StudioATheme.display(
                  size: 46,
                  color: highlight ? StudioATheme.volt : StudioATheme.ink,
                ),
              ),
            ),
            const SizedBox(width: 4),
            Text(
              label,
              style: StudioATheme.label(
                size: 10,
                tracking: 2,
                color: StudioATheme.inkDim,
              ),
            ),
            const Spacer(),
            Padding(
              padding: const EdgeInsets.only(right: 4),
              child: Text(
                'L$lane',
                style: StudioATheme.label(
                  size: 9,
                  tracking: 1.5,
                  color: StudioATheme.line,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Atletska staza: isprekidana linija dna + volt ševroni brzine desno.
class _LanePainter extends CustomPainter {
  _LanePainter({required this.lane});

  final int lane;

  @override
  void paint(Canvas canvas, Size size) {
    final dash = Paint()
      ..color = StudioATheme.line
      ..strokeWidth = 1;
    const dashW = 9.0;
    const gapW = 7.0;
    var x = 0.0;
    final y = size.height - 1;
    while (x < size.width) {
      canvas.drawLine(Offset(x, y), Offset(math.min(x + dashW, size.width), y), dash);
      x += dashW + gapW;
    }
    // Ševroni brzine — bledi ka desnoj ivici.
    final cx = size.width - 26;
    final cy = size.height / 2;
    for (var i = 0; i < 3; i++) {
      final chevron = Paint()
        ..color = StudioATheme.volt.withValues(alpha: 0.16 + i * 0.16)
        ..strokeWidth = 2
        ..strokeCap = StrokeCap.round
        ..style = PaintingStyle.stroke;
      final ox = cx - i * 10.0;
      final path = Path()
        ..moveTo(ox - 5, cy - 7)
        ..lineTo(ox + 2, cy)
        ..lineTo(ox - 5, cy + 7);
      canvas.drawPath(path, chevron);
    }
  }

  @override
  bool shouldRepaint(_LanePainter oldDelegate) => oldDelegate.lane != lane;
}

// ── Prečica ──────────────────────────────────────────────────────────────

class _QuickAction extends StatelessWidget {
  const _QuickAction({
    required this.title,
    required this.sub,
    required this.onTap,
  });

  final String title;
  final String sub;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: StudioATheme.surface,
      shape: const RoundedRectangleBorder(
        side: BorderSide(color: StudioATheme.line),
      ),
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: StudioATheme.label(
                        size: 11.5,
                        color: StudioATheme.ink,
                        tracking: 2,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      sub,
                      style: StudioATheme.body(
                        size: 12.5,
                        color: StudioATheme.inkDim,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              const Icon(
                Icons.arrow_outward_rounded,
                size: 18,
                color: StudioATheme.volt,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
