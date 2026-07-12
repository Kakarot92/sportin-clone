import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../mock_data.dart';
import '../theme.dart';
import '../widgets/effects.dart';
import 'login.dart';

/// Profil — korisnik, članarina kao member-card sa dijagonalnim rezom,
/// odjava + diskretno dugme za izlaz u galeriju (onExit).
class StudioAProfileScreen extends StatelessWidget {
  const StudioAProfileScreen({super.key, this.onExit});

  final VoidCallback? onExit;

  void _logout(BuildContext context) {
    Navigator.of(context).pushAndRemoveUntil(
      studioARoute(StudioALoginScreen(onExit: onExit)),
      (route) => false,
    );
  }

  void _demoInfo(BuildContext context, String text) {
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(text)),
    );
  }

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
                    dy: -10,
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(
                            'TVOJ NALOG',
                            style: StudioATheme.label(
                              color: StudioATheme.volt,
                              size: 10.5,
                              tracking: 3,
                            ),
                          ),
                        ),
                        // Diskretni izlaz u galeriju Design Lab-a.
                        if (onExit != null)
                          StudioAIconButton(
                            icon: Icons.grid_view_rounded,
                            tooltip: 'Nazad u galeriju',
                            onPressed: onExit!,
                          ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 6),
                  StudioAReveal(
                    index: 1,
                    child:
                        Text('PROFIL', style: StudioATheme.display(size: 38)),
                  ),
                  const SizedBox(height: 20),
                  StudioAReveal(index: 2, child: _identity()),
                  const SizedBox(height: 24),
                  const StudioAReveal(
                    index: 3,
                    child: StudioASectionLabel('Članarina'),
                  ),
                  const SizedBox(height: 16),
                  const StudioAReveal(index: 4, child: _MemberCard()),
                  const SizedBox(height: 26),
                  const StudioAReveal(
                    index: 5,
                    child: StudioASectionLabel('Podešavanja'),
                  ),
                  const SizedBox(height: 6),
                  StudioAReveal(
                    index: 6,
                    child: _SettingsRow(
                      icon: Icons.edit_rounded,
                      label: 'IZMENI PROFIL',
                      value: '',
                      onTap: () => _demoInfo(
                        context,
                        'Demo prikaz — izmena profila nije povezana.',
                      ),
                    ),
                  ),
                  StudioAReveal(
                    index: 7,
                    child: _SettingsRow(
                      icon: Icons.dark_mode_rounded,
                      label: 'TEMA',
                      value: 'TAMNA',
                      onTap: () => _demoInfo(
                        context,
                        'Kinetik živi u tamnoj temi — volt na skoro-crnom.',
                      ),
                    ),
                  ),
                  StudioAReveal(
                    index: 8,
                    child: _SettingsRow(
                      icon: Icons.language_rounded,
                      label: 'JEZIK',
                      value: 'SRPSKI',
                      onTap: () => _demoInfo(
                        context,
                        'Demo prikaz — dostupan je srpski jezik.',
                      ),
                    ),
                  ),
                  const SizedBox(height: 26),
                  StudioAReveal(
                    index: 9,
                    child: SizedBox(
                      width: double.infinity,
                      child: StudioAVoltButton(
                        label: 'Odjavi se',
                        icon: Icons.logout_rounded,
                        filled: false,
                        height: 52,
                        onPressed: () => _logout(context),
                      ),
                    ),
                  ),
                  const SizedBox(height: 18),
                  StudioAReveal(
                    index: 10,
                    child: Center(
                      child: Text(
                        'STUDIO A — KINETIK • DESIGN LAB',
                        style: StudioATheme.label(
                          size: 8.5,
                          tracking: 2.6,
                          color: StudioATheme.inkDim,
                        ),
                      ),
                    ),
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

  Widget _identity() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        StudioAInitials(mockUser.name, size: 64, fontSize: 22),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                mockUser.name.toUpperCase(),
                style: GoogleFonts.archivoBlack(
                  fontSize: 20,
                  color: StudioATheme.ink,
                ),
              ),
              const SizedBox(height: 6),
              Wrap(
                spacing: 8,
                runSpacing: 6,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  Transform(
                    transform: Matrix4.skewX(-0.2),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 3,
                      ),
                      decoration: BoxDecoration(
                        border: Border.all(color: StudioATheme.volt),
                      ),
                      child: Text(
                        mockUser.role.toUpperCase(),
                        style: StudioATheme.label(
                          size: 8.5,
                          color: StudioATheme.volt,
                          tracking: 2,
                        ),
                      ),
                    ),
                  ),
                  Text(
                    'ČLAN OD: ${mockUser.memberSince.toUpperCase()}',
                    style: StudioATheme.label(
                      size: 8.5,
                      tracking: 1.6,
                      color: StudioATheme.inkDim,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                'Cilj: ${mockUser.goal}',
                style: StudioATheme.body(
                  size: 13,
                  color: StudioATheme.inkDim,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

// ── Member kartica ───────────────────────────────────────────────────────

class _MemberCard extends StatefulWidget {
  const _MemberCard();

  @override
  State<_MemberCard> createState() => _MemberCardState();
}

class _MemberCardState extends State<_MemberCard>
    with SingleTickerProviderStateMixin {
  late final AnimationController _shine;

  @override
  void initState() {
    super.initState();
    _shine = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );
    // Uvodni sjaj pri prvom prikazu kartice.
    Future.delayed(const Duration(milliseconds: 600), () {
      if (mounted) _shine.forward();
    });
  }

  @override
  void dispose() {
    _shine.dispose();
    super.dispose();
  }

  void _replayShine() {
    HapticFeedback.selectionClick();
    _shine.forward(from: 0);
  }

  @override
  Widget build(BuildContext context) {
    const m = mockMembership;
    return GestureDetector(
      onTap: _replayShine,
      child: Transform.rotate(
        angle: StudioATheme.tilt * 0.6,
        child: ClipPath(
          clipper: const StudioADiagonalClipper(depth: 14),
          child: Container(
            width: double.infinity,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [StudioATheme.surfaceRaised, StudioATheme.surface],
              ),
            ),
            child: Stack(
              children: [
                const Positioned.fill(
                  child: StudioASpeedLines(
                    density: 16,
                    seed: 21,
                    opacity: 0.7,
                  ),
                ),
                Positioned(
                  right: -14,
                  bottom: -6,
                  child: StudioAGhostText(
                    'STUDIO',
                    size: 54,
                    color: StudioATheme.line,
                  ),
                ),
                // Sjaj koji prelazi preko kartice (tap = ponovi).
                Positioned.fill(
                  child: IgnorePointer(
                    child: AnimatedBuilder(
                      animation: _shine,
                      builder: (context, _) {
                        final t = Curves.easeOutCubic.transform(_shine.value);
                        return CustomPaint(
                          painter: _ShinePainter(progress: t),
                        );
                      },
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 24, 20, 26),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              'ČLANSKA KARTA',
                              style: StudioATheme.label(
                                size: 9.5,
                                color: StudioATheme.inkDim,
                                tracking: 2.6,
                              ),
                            ),
                          ),
                          Transform(
                            transform: Matrix4.skewX(-0.35),
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 3,
                              ),
                              color: StudioATheme.volt,
                              child: Text(
                                'AKTIVNA',
                                style: GoogleFonts.archivoBlack(
                                  fontSize: 8.5,
                                  color: StudioATheme.bg,
                                  letterSpacing: 1.4,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 14),
                      Text(
                        m.name.toUpperCase(),
                        style: GoogleFonts.archivoBlack(
                          fontSize: 17,
                          color: StudioATheme.ink,
                          height: 1.1,
                        ),
                      ),
                      const SizedBox(height: 18),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          StudioACountUp(
                            value: m.remaining.toDouble(),
                            style: StudioATheme.display(
                              size: 44,
                              color: StudioATheme.volt,
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(bottom: 6, left: 6),
                            child: Text(
                              '/ ${m.total} TRENINGA PREOSTALO',
                              style: StudioATheme.label(
                                size: 9.5,
                                tracking: 1.8,
                                color: StudioATheme.inkDim,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      _SegmentBar(filled: m.remaining, total: m.total),
                      const SizedBox(height: 16),
                      Text(
                        'OBNAVLJA SE: ${m.renewsOn.toUpperCase()}',
                        style: StudioATheme.label(
                          size: 9,
                          tracking: 1.8,
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
      ),
    );
  }
}

/// Dijagonalni svetlosni sweep preko member kartice.
class _ShinePainter extends CustomPainter {
  _ShinePainter({required this.progress});

  final double progress;

  @override
  void paint(Canvas canvas, Size size) {
    if (progress <= 0 || progress >= 1) return;
    final x = size.width * (progress * 1.6 - 0.3);
    final band = Path()
      ..moveTo(x - 30, size.height)
      ..lineTo(x + 30, 0)
      ..lineTo(x + 78, 0)
      ..lineTo(x + 18, size.height)
      ..close();
    final opacity = math.sin(progress * math.pi) * 0.12;
    canvas.drawPath(
      band,
      Paint()..color = StudioATheme.volt.withValues(alpha: opacity),
    );
  }

  @override
  bool shouldRepaint(_ShinePainter oldDelegate) =>
      oldDelegate.progress != progress;
}

/// Ukošeni segmenti članarine — preostali treninzi se pale jedan po jedan.
class _SegmentBar extends StatelessWidget {
  const _SegmentBar({required this.filled, required this.total});

  final int filled;
  final int total;

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: filled.toDouble()),
      duration: const Duration(milliseconds: 1000),
      curve: Curves.easeOutCubic,
      builder: (context, v, _) {
        return Row(
          children: [
            for (var i = 0; i < total; i++) ...[
              Expanded(
                child: Transform(
                  transform: Matrix4.skewX(-0.35),
                  child: Container(
                    height: 9,
                    decoration: BoxDecoration(
                      color: StudioATheme.volt.withValues(
                        alpha: (v - i).clamp(0.0, 1.0),
                      ),
                      border: Border.all(
                        color: i < filled
                            ? StudioATheme.volt
                            : StudioATheme.line,
                        width: 1,
                      ),
                    ),
                  ),
                ),
              ),
              if (i < total - 1) const SizedBox(width: 5),
            ],
          ],
        );
      },
    );
  }
}

// ── Red podešavanja ──────────────────────────────────────────────────────

class _SettingsRow extends StatelessWidget {
  const _SettingsRow({
    required this.icon,
    required this.label,
    required this.value,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final String value;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        decoration: const BoxDecoration(
          border: Border(bottom: BorderSide(color: StudioATheme.line)),
        ),
        constraints: const BoxConstraints(minHeight: 48),
        padding: const EdgeInsets.symmetric(vertical: 16),
        child: Row(
          children: [
            Icon(icon, size: 16, color: StudioATheme.volt),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                label,
                style: StudioATheme.label(
                  size: 10.5,
                  color: StudioATheme.ink,
                  tracking: 2,
                ),
              ),
            ),
            if (value.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(right: 10),
                child: Text(
                  value,
                  style: StudioATheme.label(
                    size: 10,
                    color: StudioATheme.inkDim,
                    tracking: 1.6,
                  ),
                ),
              ),
            const Icon(
              Icons.arrow_forward_rounded,
              size: 16,
              color: StudioATheme.inkDim,
            ),
          ],
        ),
      ),
    );
  }
}
