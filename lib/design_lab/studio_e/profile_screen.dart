import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../mock_data.dart';
import 'theme.dart';
import 'widgets.dart';

/// Profil — članarina kao access-card sa gradient ivicom + progres iskorišćenja,
/// korisnik/uloga/cilj, odjava i diskretno dugme koje zove `onExit`.
class StudioEProfileScreen extends StatefulWidget {
  const StudioEProfileScreen({super.key, required this.onLogout, this.onExit});

  final VoidCallback onLogout;
  final VoidCallback? onExit;

  @override
  State<StudioEProfileScreen> createState() => _StudioEProfileScreenState();
}

class _StudioEProfileScreenState extends State<StudioEProfileScreen> {
  final ScrollController _scroll = ScrollController();

  @override
  void dispose() {
    _scroll.dispose();
    super.dispose();
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
                        'Profil',
                        style: theme.displaySmall!,
                      ),
                    ),
                    const SizedBox(height: StudioESpace.xl),

                    // Identitet.
                    StudioEEntrance(
                      delayMs: 70,
                      child: Row(
                        children: [
                          StudioEAvatar(
                            name: mockUser.name,
                            size: 64,
                            glow: true,
                          ),
                          const SizedBox(width: StudioESpace.l),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  mockUser.name,
                                  style: theme.headlineMedium,
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  'Član od ${mockUser.memberSince}',
                                  style: theme.bodySmall,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: StudioESpace.section),

                    // Access-card članarine.
                    const StudioEEntrance(
                      delayMs: 130,
                      child: StudioESectionLabel('Članarina'),
                    ),
                    const SizedBox(height: StudioESpace.m),
                    const StudioEEntrance(
                      delayMs: 170,
                      child: _MembershipCard(),
                    ),
                    const SizedBox(height: StudioESpace.section),

                    // Detalji naloga.
                    const StudioEEntrance(
                      delayMs: 230,
                      child: StudioESectionLabel('Nalog'),
                    ),
                    const SizedBox(height: StudioESpace.m),
                    StudioEEntrance(
                      delayMs: 270,
                      child: StudioEDepthCard(
                        padding: const EdgeInsets.symmetric(
                          horizontal: StudioESpace.l,
                          vertical: StudioESpace.xs,
                        ),
                        child: Column(
                          children: [
                            _InfoRow(
                              icon: Icons.badge_outlined,
                              label: 'Uloga',
                              value: mockUser.role,
                            ),
                            const Divider(
                              height: 1,
                              thickness: 1,
                              color: StudioEColors.hairline,
                            ),
                            _InfoRow(
                              icon: Icons.flag_outlined,
                              label: 'Cilj',
                              value: mockUser.goal,
                            ),
                            const Divider(
                              height: 1,
                              thickness: 1,
                              color: StudioEColors.hairline,
                            ),
                            _InfoRow(
                              icon: Icons.event_repeat_rounded,
                              label: 'Obnova',
                              value: mockMembership.renewsOn,
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: StudioESpace.section),

                    // Odjava.
                    StudioEEntrance(
                      delayMs: 320,
                      child: _ActionRow(
                        icon: Icons.logout_rounded,
                        label: 'Odjavi se',
                        onTap: widget.onLogout,
                      ),
                    ),

                    const SizedBox(height: StudioESpace.section + 8),

                    // Diskretan izlaz u galeriju.
                    if (widget.onExit != null)
                      Center(
                        child: TextButton.icon(
                          onPressed: widget.onExit,
                          style: TextButton.styleFrom(
                            foregroundColor: StudioEColors.textDim,
                            textStyle: GoogleFonts.ibmPlexSans(
                              fontSize: 12.5,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          icon: const Icon(
                            Icons.grid_view_rounded,
                            size: 15,
                          ),
                          label: const Text('Studio E · nazad u galeriju'),
                        ),
                      ),
                    const SizedBox(height: StudioESpace.s),
                    Center(
                      child: Text(
                        'Dubina — neon cinema',
                        style: GoogleFonts.ibmPlexSans(
                          fontSize: 10.5,
                          letterSpacing: 1.5,
                          color: StudioEColors.textDim.withValues(alpha: 0.6),
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

/// Access-card: gradient ivica, perforacije, count-up preostalih treninga,
/// proceduralni ring progres. Jedini glow element sekcije.
class _MembershipCard extends StatelessWidget {
  const _MembershipCard();

  @override
  Widget build(BuildContext context) {
    final m = mockMembership;
    final used = m.total - m.remaining;
    final progress = m.remaining / m.total;
    final theme = Theme.of(context).textTheme;

    return StudioEDepthCard(
      emphasis: true,
      glowColor: StudioEColors.violet,
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text('STUDIO ACCESS', style: theme.labelSmall),
              const Spacer(),
              Icon(
                Icons.bolt_rounded,
                size: 18,
                color: StudioEColors.cyan.withValues(alpha: 0.9),
              ),
            ],
          ),
          const SizedBox(height: StudioESpace.l),
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Ring progres preostalih treninga.
              SizedBox(
                width: 74,
                height: 74,
                child: CustomPaint(
                  painter: _RingPainter(progress),
                  child: Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        StudioECountUp(
                          value: m.remaining.toDouble(),
                          style: GoogleFonts.syne(
                            fontSize: 24,
                            fontWeight: FontWeight.w800,
                            color: StudioEColors.text,
                            height: 1,
                          ),
                        ),
                        Text(
                          'od ${m.total}',
                          style: GoogleFonts.ibmPlexSans(
                            fontSize: 9.5,
                            fontWeight: FontWeight.w500,
                            color: StudioEColors.textDim,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(width: StudioESpace.l),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(m.name, style: theme.titleMedium),
                    const SizedBox(height: StudioESpace.xs),
                    Text(
                      'Iskorišćeno $used od ${m.total} treninga',
                      style: theme.bodySmall,
                    ),
                    const SizedBox(height: StudioESpace.s),
                    Text(
                      'Obnova ${m.renewsOn}',
                      style: GoogleFonts.ibmPlexSans(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: StudioEColors.cyan,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: StudioESpace.l),
          // Perforacije — kartica-kao-ulaznica.
          Row(
            children: List.generate(
              22,
              (i) => Expanded(
                child: Container(
                  height: 1.4,
                  margin: const EdgeInsets.symmetric(horizontal: 1.5),
                  color: StudioEColors.hairline,
                ),
              ),
            ),
          ),
          const SizedBox(height: StudioESpace.m),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                mockUser.name.toUpperCase(),
                style: GoogleFonts.ibmPlexSans(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1.5,
                  color: StudioEColors.text,
                ),
              ),
              Text(
                'ČLAN OD ${mockUser.memberSince.toUpperCase()}',
                style: GoogleFonts.ibmPlexSans(
                  fontSize: 10,
                  fontWeight: FontWeight.w500,
                  letterSpacing: 0.8,
                  color: StudioEColors.textDim,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// Kružni progres sa gradient lukom i glow „glavom".
class _RingPainter extends CustomPainter {
  const _RingPainter(this.progress);

  final double progress;

  @override
  void paint(Canvas canvas, Size size) {
    final center = size.center(Offset.zero);
    final radius = size.shortestSide / 2 - 5;
    const start = -math.pi / 2;
    final sweep = 2 * math.pi * progress.clamp(0.0, 1.0);
    final rect = Rect.fromCircle(center: center, radius: radius);

    canvas.drawCircle(
      center,
      radius,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 5
        ..color = StudioEColors.hairline,
    );
    canvas.drawArc(
      rect,
      start,
      sweep,
      false,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 5
        ..strokeCap = StrokeCap.round
        ..shader = const LinearGradient(
          colors: [StudioEColors.cyan, StudioEColors.violet],
        ).createShader(rect),
    );
    final head = Offset(
      center.dx + radius * math.cos(start + sweep),
      center.dy + radius * math.sin(start + sweep),
    );
    canvas.drawCircle(
      head,
      3.4,
      Paint()
        ..color = StudioEColors.violet
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 3),
    );
  }

  @override
  bool shouldRepaint(covariant _RingPainter oldDelegate) =>
      oldDelegate.progress != progress;
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context).textTheme;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: StudioESpace.m + 2),
      child: Row(
        children: [
          Icon(icon, size: 18, color: StudioEColors.textDim),
          const SizedBox(width: StudioESpace.m),
          Text(label, style: theme.bodyMedium),
          const SizedBox(width: StudioESpace.l),
          Expanded(
            child: Text(
              value,
              textAlign: TextAlign.right,
              style: theme.bodyMedium!.copyWith(
                fontWeight: FontWeight.w600,
                color: StudioEColors.text,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}

class _ActionRow extends StatelessWidget {
  const _ActionRow({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return StudioEDepthCard(
      onTap: onTap,
      padding: const EdgeInsets.symmetric(
        horizontal: StudioESpace.l,
        vertical: StudioESpace.l - 2,
      ),
      child: Row(
        children: [
          Icon(icon, size: 20, color: StudioEColors.text),
          const SizedBox(width: StudioESpace.m),
          Text(
            label,
            style: GoogleFonts.ibmPlexSans(
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: StudioEColors.text,
            ),
          ),
          const Spacer(),
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
