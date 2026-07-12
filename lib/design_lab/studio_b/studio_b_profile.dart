import 'dart:math' as math;
import 'dart:ui' show ImageFilter;

import 'package:flutter/material.dart';

import '../mock_data.dart';
import 'studio_b_glass.dart';
import 'studio_b_tokens.dart';

/// Profil — korisnik, članarina kao glass „boarding pass" sa perforacijom i
/// prstenom preostalih treninga, podešavanja i diskretan izlaz (`onExit`).
class StudioBProfileTab extends StatelessWidget {
  const StudioBProfileTab({super.key, required this.onLogout, this.onExit});

  final VoidCallback onLogout;
  final VoidCallback? onExit;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 520),
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 14, 20, 120),
          children: [
            StudioBReveal(child: _header()),
            const SizedBox(height: 22),
            StudioBReveal(delayMs: 90, child: const _BoardingPass()),
            const SizedBox(height: 24),
            const StudioBSectionHeader(title: 'Nalog'),
            StudioBReveal(delayMs: 170, child: _accountCard(context)),
            const SizedBox(height: 24),
            const StudioBSectionHeader(title: 'Izgled'),
            StudioBReveal(delayMs: 240, child: const _AppearanceCard()),
            const SizedBox(height: 24),
            StudioBReveal(
              delayMs: 300,
              child: _logoutCard(context),
            ),
            const SizedBox(height: 18),
            if (onExit != null)
              StudioBReveal(delayMs: 340, child: _exitRow(context)),
          ],
        ),
      ),
    );
  }

  Widget _header() {
    return Row(
      children: [
        StudioBAvatar(name: mockUser.name, size: 66),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                mockUser.name,
                style: StudioBTokens.display(
                  size: 24,
                  weight: FontWeight.w700,
                  spacing: -0.5,
                ),
              ),
              const SizedBox(height: 4),
              Row(
                children: [
                  StudioBChip(
                    label: mockUser.role,
                    icon: Icons.verified_user_rounded,
                    background: StudioBTokens.violet.withValues(alpha: 0.12),
                    foreground: StudioBTokens.violetDeep,
                  ),
                  const SizedBox(width: 8),
                  Flexible(
                    child: Text(
                      'član od ${mockUser.memberSince}',
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
      ],
    );
  }

  Widget _accountCard(BuildContext context) {
    return StudioBGlass(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Column(
        children: [
          _SettingRow(
            icon: Icons.person_outline_rounded,
            label: 'Izmeni profil',
            subtitle: mockUser.goal,
            onTap: () => studioBShowSnack(
              context,
              'Izmena profila je van dometa demoa.',
            ),
          ),
          const _RowDivider(),
          _SettingRow(
            icon: Icons.flag_outlined,
            label: 'Cilj',
            subtitle: mockUser.goal,
            onTap: () => studioBShowSnack(context, 'Cilj: ${mockUser.goal}.'),
          ),
          const _RowDivider(),
          _SettingRow(
            icon: Icons.notifications_none_rounded,
            label: 'Podsetnici za termine',
            trailing: const _MiniToggle(value: true),
            onTap: () =>
                studioBShowSnack(context, 'Podsetnici su uključeni.'),
          ),
        ],
      ),
    );
  }

  Widget _logoutCard(BuildContext context) {
    return StudioBGlass(
      onTap: () => _confirmLogout(context),
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: StudioBTokens.rose.withValues(alpha: 0.12),
            ),
            child: const Icon(
              Icons.logout_rounded,
              size: 20,
              color: StudioBTokens.rose,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Text(
              'Odjavi se',
              style: StudioBTokens.display(
                size: 15.5,
                weight: FontWeight.w600,
                color: StudioBTokens.rose,
              ),
            ),
          ),
          Icon(
            Icons.chevron_right_rounded,
            color: StudioBTokens.rose.withValues(alpha: 0.7),
          ),
        ],
      ),
    );
  }

  Widget _exitRow(BuildContext context) {
    return Center(
      child: TextButton.icon(
        onPressed: onExit,
        style: TextButton.styleFrom(
          minimumSize: const Size(48, 48),
          foregroundColor: StudioBTokens.inkSoft,
        ),
        icon: const Icon(Icons.grid_view_rounded, size: 16),
        label: Text(
          'Nazad u galeriju studija',
          style: StudioBTokens.label(size: 12, color: StudioBTokens.inkSoft),
        ),
      ),
    );
  }

  void _confirmLogout(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) => Padding(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(28),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 22, sigmaY: 22),
            child: Container(
              padding: const EdgeInsets.fromLTRB(22, 20, 22, 20),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.86),
                borderRadius: BorderRadius.circular(28),
                border: Border.all(color: Colors.white.withValues(alpha: 0.5)),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Center(
                    child: Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: StudioBTokens.inkSoft.withValues(alpha: 0.3),
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                  ),
                  const SizedBox(height: 18),
                  Text(
                    'Odjava',
                    textAlign: TextAlign.center,
                    style: StudioBTokens.display(
                      size: 19,
                      weight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Sigurno želiš da se odjaviš iz Studija?',
                    textAlign: TextAlign.center,
                    style: StudioBTokens.body(
                      size: 14,
                      color: StudioBTokens.inkSoft,
                      height: 1.5,
                    ),
                  ),
                  const SizedBox(height: 20),
                  StudioBPillButton(
                    label: 'Odjavi se',
                    icon: Icons.logout_rounded,
                    height: 52,
                    onPressed: () {
                      Navigator.of(sheetContext).pop();
                      onLogout();
                    },
                  ),
                  const SizedBox(height: 8),
                  TextButton(
                    onPressed: () => Navigator.of(sheetContext).pop(),
                    style: TextButton.styleFrom(
                      minimumSize: const Size(48, 48),
                    ),
                    child: Text(
                      'Otkaži',
                      style: StudioBTokens.label(
                        size: 13,
                        color: StudioBTokens.inkSoft,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Članarina kao „boarding pass": levi glavni deo + perforacija + desni
/// otcepni deo sa prstenom preostalih treninga. Preko karte sporo prelazi
/// specular sjaj — signature „premium" detalj (pass 1 upgrade).
class _BoardingPass extends StatefulWidget {
  const _BoardingPass();

  @override
  State<_BoardingPass> createState() => _BoardingPassState();
}

class _BoardingPassState extends State<_BoardingPass>
    with SingleTickerProviderStateMixin {
  late final AnimationController _sheen = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 5200),
  )..repeat();

  @override
  void dispose() {
    _sheen.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final m = mockMembership;
    final ratio = m.remaining / m.total;

    return DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: StudioBTokens.violet.withValues(alpha: 0.16),
            blurRadius: 30,
            offset: const Offset(0, 14),
          ),
        ],
      ),
      child: ClipPath(
        clipper: _TicketClipper(),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
          child: DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  StudioBTokens.violet.withValues(alpha: 0.92),
                  StudioBTokens.violetDark.withValues(alpha: 0.96),
                ],
              ),
            ),
            child: Stack(
              children: [
                Positioned.fill(
                  child: IgnorePointer(
                    child: AnimatedBuilder(
                      animation: _sheen,
                      builder: (_, _) =>
                          CustomPaint(painter: _SheenPainter(_sheen.value)),
                    ),
                  ),
                ),
                Row(
              children: [
                // Glavni deo.
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 20, 16, 20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Icon(
                              Icons.confirmation_number_rounded,
                              size: 16,
                              color: Colors.white,
                            ),
                            const SizedBox(width: 6),
                            Text(
                              'ČLANARINA',
                              style: StudioBTokens.label(
                                size: 11,
                                color: Colors.white.withValues(alpha: 0.85),
                                spacing: 1.5,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Text(
                          m.name,
                          style: StudioBTokens.display(
                            size: 18,
                            weight: FontWeight.w600,
                            color: Colors.white,
                            height: 1.25,
                          ),
                        ),
                        const SizedBox(height: 16),
                        FittedBox(
                          fit: BoxFit.scaleDown,
                          alignment: Alignment.centerLeft,
                          child: Row(
                            children: [
                              _PassField(
                                label: 'Iskorišćeno',
                                value:
                                    '${m.total - m.remaining} / ${m.total}',
                              ),
                              const SizedBox(width: 20),
                              _PassField(
                                label: 'Obnova',
                                value: m.renewsOn,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                // Otcepni deo sa prstenom.
                SizedBox(
                  width: 104,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 14),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        SizedBox(
                          width: 72,
                          height: 72,
                          child: CustomPaint(
                            painter: _RemainingRingPainter(ratio),
                            child: Center(
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    '${m.remaining}',
                                    style: StudioBTokens.display(
                                      size: 26,
                                      weight: FontWeight.w700,
                                      color: Colors.white,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'preostalo',
                          style: StudioBTokens.label(
                            size: 10.5,
                            color: Colors.white.withValues(alpha: 0.85),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _PassField extends StatelessWidget {
  const _PassField({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label.toUpperCase(),
          style: StudioBTokens.label(
            size: 9.5,
            color: Colors.white.withValues(alpha: 0.7),
            spacing: 0.8,
          ),
        ),
        const SizedBox(height: 3),
        Text(
          value,
          style: StudioBTokens.body(
            size: 13.5,
            weight: FontWeight.w700,
            color: Colors.white,
          ),
        ),
      ],
    );
  }
}

/// Iseca notch-eve i time gradi perforaciju „karte".
class _TicketClipper extends CustomClipper<Path> {
  static const double _tearX = 104; // širina desnog dela
  static const double _notch = 9;

  @override
  Path getClip(Size size) {
    final r = 28.0;
    final tearCx = size.width - _tearX;

    final outer = Path()
      ..addRRect(
        RRect.fromRectAndRadius(Offset.zero & size, Radius.circular(r)),
      );

    final notches = Path()
      ..addOval(
        Rect.fromCircle(center: Offset(tearCx, 0), radius: _notch),
      )
      ..addOval(
        Rect.fromCircle(center: Offset(tearCx, size.height), radius: _notch),
      );

    return Path.combine(PathOperation.difference, outer, notches);
  }

  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) => false;
}

/// Dijagonalni specular sjaj koji sporo prelazi preko karte. Sweep zauzima
/// prvih ~45% petlje, ostatak je mirovanje — suptilno, ne cirkus.
class _SheenPainter extends CustomPainter {
  const _SheenPainter(this.tRaw);

  final double tRaw;

  @override
  void paint(Canvas canvas, Size size) {
    // Sweep u prvih 45% petlje (easeInOutSine), zatim miruje van platna.
    final phase = (tRaw / 0.45).clamp(0.0, 1.0);
    final eased = 0.5 - 0.5 * math.cos(phase * math.pi);
    final t = -0.35 + 1.7 * eased;

    final cx = t * size.width;
    final bandW = size.width * 0.22;
    final rect = Rect.fromLTWH(
      cx - bandW,
      -size.height,
      bandW * 2,
      size.height * 3,
    );

    canvas.save();
    canvas.translate(cx, size.height / 2);
    canvas.rotate(-0.38);
    canvas.translate(-cx, -size.height / 2);
    canvas.drawRect(
      rect,
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
          colors: [
            Colors.white.withValues(alpha: 0.0),
            Colors.white.withValues(alpha: 0.16),
            Colors.white.withValues(alpha: 0.0),
          ],
          stops: const [0.0, 0.5, 1.0],
        ).createShader(rect),
    );
    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant _SheenPainter oldDelegate) {
    return oldDelegate.tRaw != tRaw;
  }
}

class _RemainingRingPainter extends CustomPainter {
  const _RemainingRingPainter(this.ratio);

  final double ratio;

  @override
  void paint(Canvas canvas, Size size) {
    final center = size.center(Offset.zero);
    final radius = size.shortestSide / 2 - 5;
    const stroke = 6.0;

    canvas.drawCircle(
      center,
      radius,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = stroke
        ..color = Colors.white.withValues(alpha: 0.25),
    );
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -3.1415926535 / 2,
      2 * 3.1415926535 * ratio.clamp(0.0, 1.0),
      false,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = stroke
        ..strokeCap = StrokeCap.round
        ..color = Colors.white,
    );
  }

  @override
  bool shouldRepaint(covariant _RemainingRingPainter oldDelegate) {
    return oldDelegate.ratio != ratio;
  }
}

class _AppearanceCard extends StatelessWidget {
  const _AppearanceCard();

  @override
  Widget build(BuildContext context) {
    return StudioBGlass(
      padding: const EdgeInsets.fromLTRB(18, 16, 18, 16),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: StudioBTokens.violet.withValues(alpha: 0.12),
            ),
            child: const Icon(
              Icons.palette_outlined,
              size: 20,
              color: StudioBTokens.violetDeep,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Tema',
                  style: StudioBTokens.body(
                    size: 14.5,
                    weight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'Aurora — svetla',
                  style: StudioBTokens.label(size: 11.5),
                ),
              ],
            ),
          ),
          _segment(),
        ],
      ),
    );
  }

  Widget _segment() {
    return Container(
      padding: const EdgeInsets.all(3),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: StudioBTokens.violet,
              borderRadius: BorderRadius.circular(999),
            ),
            child: Icon(
              Icons.light_mode_rounded,
              size: 15,
              color: Colors.white,
            ),
          ),
          const SizedBox(width: 2),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            child: Icon(
              Icons.dark_mode_outlined,
              size: 15,
              color: StudioBTokens.inkSoft,
            ),
          ),
        ],
      ),
    );
  }
}

class _SettingRow extends StatelessWidget {
  const _SettingRow({
    required this.icon,
    required this.label,
    this.subtitle,
    this.trailing,
    this.onTap,
  });

  final IconData icon;
  final String label;
  final String? subtitle;
  final Widget? trailing;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: StudioBTokens.violet.withValues(alpha: 0.10),
              ),
              child: Icon(icon, size: 19, color: StudioBTokens.violetDeep),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: StudioBTokens.body(
                      size: 14.5,
                      weight: FontWeight.w700,
                    ),
                  ),
                  if (subtitle != null) ...[
                    const SizedBox(height: 2),
                    Text(
                      subtitle!,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: StudioBTokens.label(size: 11.5),
                    ),
                  ],
                ],
              ),
            ),
            trailing ??
                const Icon(
                  Icons.chevron_right_rounded,
                  color: StudioBTokens.inkSoft,
                ),
          ],
        ),
      ),
    );
  }
}

class _RowDivider extends StatelessWidget {
  const _RowDivider();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 70, right: 16),
      child: Container(
        height: 1,
        color: StudioBTokens.ink.withValues(alpha: 0.06),
      ),
    );
  }
}

class _MiniToggle extends StatelessWidget {
  const _MiniToggle({required this.value});

  final bool value;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 44,
      height: 26,
      padding: const EdgeInsets.all(3),
      alignment: value ? Alignment.centerRight : Alignment.centerLeft,
      decoration: BoxDecoration(
        color: value
            ? StudioBTokens.mint
            : StudioBTokens.inkSoft.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Container(
        width: 20,
        height: 20,
        decoration: const BoxDecoration(
          shape: BoxShape.circle,
          color: Colors.white,
        ),
      ),
    );
  }
}
