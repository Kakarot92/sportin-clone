import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../mock_data.dart';
import 'orb.dart';
import 'theme.dart';
import 'widgets.dart';

/// Početna — tri plana dubine: parallax blob-ovi pozadi, sadržaj u sredini,
/// neon akcenti (orb, indikatori) napred.
class StudioEHomeScreen extends StatefulWidget {
  const StudioEHomeScreen({super.key, required this.onGoToTab});

  final ValueChanged<int> onGoToTab;

  @override
  State<StudioEHomeScreen> createState() => _StudioEHomeScreenState();
}

class _StudioEHomeScreenState extends State<StudioEHomeScreen> {
  final ScrollController _scroll = ScrollController();

  @override
  void dispose() {
    _scroll.dispose();
    super.dispose();
  }

  String get _greeting {
    final h = DateTime.now().hour;
    if (h >= 5 && h < 12) return 'Dobro jutro';
    if (h >= 12 && h < 18) return 'Dobar dan';
    return 'Dobro veče';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context).textTheme;
    final width = MediaQuery.sizeOf(context).width;
    final orbSize = (width - 56).clamp(240.0, 330.0).toDouble();
    final lostKg =
        mockMeasurements.first.weightKg - mockMeasurements.last.weightKg;

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
                      child: Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  '$_greeting,',
                                  style: theme.bodyMedium!.copyWith(
                                    color: StudioEColors.textDim,
                                  ),
                                ),
                                StudioEGradientText(
                                  mockUser.name,
                                  style: theme.displaySmall!,
                                ),
                              ],
                            ),
                          ),
                          Semantics(
                            button: true,
                            label: 'Profil',
                            child: GestureDetector(
                              onTap: () => widget.onGoToTab(4),
                              child: StudioEAvatar(
                                name: mockUser.name,
                                size: 48,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: StudioESpace.xl),

                    // Hero: orb sa sledećim treningom u centru.
                    StudioEEntrance(
                      delayMs: 90,
                      child: Center(
                        child: StudioEOrb(
                          size: orbSize,
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                'SLEDEĆI TRENING',
                                style: theme.labelSmall,
                              ),
                              const SizedBox(height: StudioESpace.s),
                              Text(
                                mockNextSession.time,
                                style: GoogleFonts.syne(
                                  fontSize: 44,
                                  fontWeight: FontWeight.w800,
                                  color: StudioEColors.text,
                                  height: 1,
                                ),
                              ),
                              const SizedBox(height: StudioESpace.xs),
                              Text(
                                '${mockNextSession.weekday}, '
                                '${mockNextSession.date}',
                                style: theme.titleMedium,
                              ),
                              const SizedBox(height: StudioESpace.s),
                              Text(
                                mockNextSession.type,
                                textAlign: TextAlign.center,
                                style: GoogleFonts.ibmPlexSans(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                  color: StudioEColors.cyan,
                                ),
                              ),
                              const SizedBox(height: StudioESpace.xs),
                              Text(
                                '${mockNextSession.trainer} · '
                                '${mockNextSession.location}',
                                textAlign: TextAlign.center,
                                style: theme.bodySmall,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: StudioESpace.l),

                    // Nedeljne statistike u depth karticama.
                    StudioEEntrance(
                      delayMs: 170,
                      child: Row(
                        children: [
                          Expanded(
                            child: _StatCard(
                              value: mockWeekStats.trainingsThisWeek,
                              label: 'ove nedelje',
                            ),
                          ),
                          const SizedBox(width: StudioESpace.m - 2),
                          Expanded(
                            child: _StatCard(
                              value: mockWeekStats.trainingsThisMonth,
                              label: 'ovog meseca',
                            ),
                          ),
                          const SizedBox(width: StudioESpace.m - 2),
                          Expanded(
                            child: _StatCard(
                              value: mockWeekStats.streakWeeks,
                              label: 'nedelja niza',
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: StudioESpace.section),

                    const StudioEEntrance(
                      delayMs: 230,
                      child: StudioESectionLabel('Tvoj cilj'),
                    ),
                    const SizedBox(height: StudioESpace.m),
                    StudioEEntrance(
                      delayMs: 270,
                      child: StudioEDepthCard(
                        onTap: () => widget.onGoToTab(2),
                        child: Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    mockUser.goal,
                                    style: theme.titleMedium,
                                  ),
                                  const SizedBox(height: StudioESpace.xs + 2),
                                  Text(
                                    '−${StudioEFmt.decimal(lostKg)} kg za '
                                    '${mockMeasurements.length} nedelja',
                                    style: GoogleFonts.ibmPlexSans(
                                      fontSize: 12.5,
                                      fontWeight: FontWeight.w600,
                                      color: StudioEColors.cyan,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: StudioESpace.m),
                            const SizedBox(
                              width: 92,
                              height: 42,
                              child: CustomPaint(
                                painter: _SparklinePainter(),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: StudioESpace.section),

                    const StudioEEntrance(
                      delayMs: 330,
                      child: StudioESectionLabel('Prečice'),
                    ),
                    const SizedBox(height: StudioESpace.m),
                    StudioEEntrance(
                      delayMs: 370,
                      child: Row(
                        children: [
                          Expanded(
                            child: _ShortcutTile(
                              icon: Icons.event_available_rounded,
                              iconColor: StudioEColors.cyan,
                              label: 'Zakaži trening',
                              onTap: () => widget.onGoToTab(1),
                            ),
                          ),
                          const SizedBox(width: StudioESpace.m - 2),
                          Expanded(
                            child: _ShortcutTile(
                              icon: Icons.monitor_weight_rounded,
                              iconColor: StudioEColors.violet,
                              label: 'Moja merenja',
                              onTap: () => widget.onGoToTab(2),
                            ),
                          ),
                          const SizedBox(width: StudioESpace.m - 2),
                          Expanded(
                            child: _ShortcutTile(
                              icon: Icons.chat_bubble_outline_rounded,
                              iconColor: StudioEColors.cyan,
                              label: 'Piši treneru',
                              onTap: () => widget.onGoToTab(3),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: StudioESpace.section),

                    const StudioEEntrance(
                      delayMs: 430,
                      child: StudioESectionLabel('Poslednja poruka'),
                    ),
                    const SizedBox(height: StudioESpace.m),
                    StudioEEntrance(
                      delayMs: 470,
                      child: StudioEDepthCard(
                        onTap: () => widget.onGoToTab(3),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            StudioEAvatar(
                              name: mockThreads.first.trainerName,
                              size: 44,
                            ),
                            const SizedBox(width: StudioESpace.m),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Expanded(
                                        child: Text(
                                          mockThreads.first.trainerName,
                                          style: theme.titleMedium,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                      Text(
                                        mockThreads.first.lastTime,
                                        style: theme.bodySmall,
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: StudioESpace.xs),
                                  Text(
                                    mockThreads.first.messages.last.text,
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                    style: theme.bodySmall,
                                  ),
                                ],
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
          ),
        ],
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  const _StatCard({required this.value, required this.label});

  final int value;
  final String label;

  @override
  Widget build(BuildContext context) {
    return StudioEDepthCard(
      padding: const EdgeInsets.symmetric(
        horizontal: StudioESpace.m,
        vertical: StudioESpace.l,
      ),
      child: Column(
        children: [
          StudioECountUp(
            value: value.toDouble(),
            style: GoogleFonts.syne(
              fontSize: 26,
              fontWeight: FontWeight.w800,
              color: StudioEColors.text,
              height: 1,
            ),
          ),
          const SizedBox(height: StudioESpace.s - 2),
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              label.toUpperCase(),
              maxLines: 1,
              style: GoogleFonts.ibmPlexSans(
                fontSize: 9.5,
                fontWeight: FontWeight.w600,
                letterSpacing: 1.1,
                color: StudioEColors.textDim,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ShortcutTile extends StatelessWidget {
  const _ShortcutTile({
    required this.icon,
    required this.iconColor,
    required this.label,
    required this.onTap,
  });

  final IconData icon;
  final Color iconColor;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return StudioEDepthCard(
      onTap: onTap,
      padding: const EdgeInsets.symmetric(
        horizontal: StudioESpace.s,
        vertical: StudioESpace.l,
      ),
      child: SizedBox(
        height: 78,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: StudioEColors.layer2,
                border: Border.all(
                  color: iconColor.withValues(alpha: 0.35),
                ),
              ),
              child: Icon(icon, size: 19, color: iconColor),
            ),
            const SizedBox(height: StudioESpace.s + 2),
            Text(
              label,
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: GoogleFonts.ibmPlexSans(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                height: 1.25,
                color: StudioEColors.text,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Mini sparkline težine u kartici cilja — statičan, bez glow-a.
class _SparklinePainter extends CustomPainter {
  const _SparklinePainter();

  @override
  void paint(Canvas canvas, Size size) {
    final values = [for (final m in mockMeasurements) m.weightKg];
    var lo = values.first;
    var hi = values.first;
    for (final v in values) {
      lo = math.min(lo, v);
      hi = math.max(hi, v);
    }
    final span = (hi - lo).abs() < 0.001 ? 1.0 : hi - lo;

    double x(int i) => size.width * i / (values.length - 1);
    double y(double v) =>
        size.height - 3 - (v - lo) / span * (size.height - 6);

    final line = Path()..moveTo(x(0), y(values[0]));
    for (var i = 0; i < values.length - 1; i++) {
      final cx = (x(i) + x(i + 1)) / 2;
      line.cubicTo(cx, y(values[i]), cx, y(values[i + 1]), x(i + 1),
          y(values[i + 1]));
    }

    final fill = Path.from(line)
      ..lineTo(x(values.length - 1), size.height)
      ..lineTo(0, size.height)
      ..close();
    canvas.drawPath(
      fill,
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            StudioEColors.cyan.withValues(alpha: 0.14),
            StudioEColors.cyan.withValues(alpha: 0),
          ],
        ).createShader(Offset.zero & size),
    );
    canvas.drawPath(
      line,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.6
        ..strokeCap = StrokeCap.round
        ..shader = const LinearGradient(
          colors: [StudioEColors.cyan, StudioEColors.violet],
        ).createShader(Offset.zero & size),
    );
    canvas.drawCircle(
      Offset(x(values.length - 1), y(values.last)),
      2.4,
      Paint()..color = StudioEColors.violet,
    );
  }

  @override
  bool shouldRepaint(covariant _SparklinePainter oldDelegate) => false;
}
