import 'package:flutter/material.dart';

import '../mock_data.dart';
import 'studio_b_glass.dart';
import 'studio_b_tokens.dart';

/// Početna — pozdrav, „disajuća" kartica sledećeg treninga, nedeljni ritam
/// (traka dana + statistike) i prečice ka ostalim tabovima.
class StudioBHomeTab extends StatelessWidget {
  const StudioBHomeTab({super.key, required this.onQuickNav});

  /// Prebacuje školjku na traženi tab (1 = Termini, 2 = Merenja, 3 = Poruke).
  final ValueChanged<int> onQuickNav;

  @override
  Widget build(BuildContext context) {
    final weights = [for (final m in mockMeasurements) m.weightKg];
    final weightDelta = weights.last - weights.first;

    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 520),
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 14, 20, 120),
          children: [
            StudioBReveal(child: _header()),
            const SizedBox(height: 20),
            StudioBReveal(
              delayMs: 90,
              child: StudioBBreathing(child: _nextSessionCard()),
            ),
            const SizedBox(height: 24),
            const StudioBSectionHeader(title: 'Ova nedelja'),
            StudioBReveal(delayMs: 180, child: const _WeekCard()),
            const SizedBox(height: 24),
            const StudioBSectionHeader(title: 'Prečice'),
            StudioBReveal(delayMs: 260, child: _shortcuts(context)),
            const SizedBox(height: 24),
            const StudioBSectionHeader(title: 'Napredak'),
            StudioBReveal(
              delayMs: 340,
              child: _progressTeaser(weights, weightDelta),
            ),
          ],
        ),
      ),
    );
  }

  Widget _header() {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'utorak, 8. jul',
                style: StudioBTokens.label(size: 12.5, spacing: 0.3),
              ),
              const SizedBox(height: 4),
              Text(
                'Zdravo, ${mockUser.name}',
                style: StudioBTokens.display(
                  size: 27,
                  weight: FontWeight.w700,
                  spacing: -0.5,
                ),
              ),
              const SizedBox(height: 3),
              Text(
                'Dobrodošli u vaš studio',
                style: StudioBTokens.body(
                  size: 13.5,
                  weight: FontWeight.w600,
                  color: StudioBTokens.inkSoft,
                ),
              ),
            ],
          ),
        ),
        StudioBAvatar(name: mockUser.name, size: 50),
      ],
    );
  }

  Widget _nextSessionCard() {
    return StudioBGlass(
      opacity: 0.66,
      padding: const EdgeInsets.fromLTRB(22, 20, 22, 18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  'Sledeći trening',
                  style: StudioBTokens.label(size: 12, spacing: 0.4),
                ),
              ),
              StudioBChip(
                label: 'sutra',
                icon: Icons.wb_twilight_rounded,
                background: StudioBTokens.mint.withValues(alpha: 0.14),
                foreground: StudioBTokens.mintDeep,
              ),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    mockNextSession.time,
                    style: StudioBTokens.display(
                      size: 34,
                      weight: FontWeight.w700,
                      spacing: -1,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '${mockNextSession.weekday}, ${mockNextSession.date}',
                    style: StudioBTokens.body(
                      size: 12.5,
                      weight: FontWeight.w600,
                      color: StudioBTokens.inkSoft,
                    ),
                  ),
                ],
              ),
              const SizedBox(width: 18),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      mockNextSession.type,
                      style: StudioBTokens.display(
                        size: 16,
                        weight: FontWeight.w600,
                        height: 1.3,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        StudioBAvatar(name: mockNextSession.trainer, size: 24),
                        const SizedBox(width: 7),
                        Flexible(
                          child: Text(
                            mockNextSession.trainer,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: StudioBTokens.body(
                              size: 12.5,
                              weight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        const Icon(
                          Icons.place_rounded,
                          size: 14,
                          color: StudioBTokens.inkSoft,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          mockNextSession.location,
                          style: StudioBTokens.body(
                            size: 12.5,
                            weight: FontWeight.w600,
                            color: StudioBTokens.inkSoft,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          Row(
            children: [
              Expanded(
                child: StudioBGhostButton(
                  label: 'Poruka treneru',
                  icon: Icons.chat_bubble_outline_rounded,
                  onPressed: () => onQuickNav(3),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: StudioBGhostButton(
                  label: 'Svi termini',
                  icon: Icons.calendar_month_rounded,
                  onPressed: () => onQuickNav(1),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _shortcuts(BuildContext context) {
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            child: _ShortcutTile(
              icon: Icons.event_available_rounded,
              label: 'Zakaži trening',
              onTap: () => onQuickNav(1),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _ShortcutTile(
              icon: Icons.straighten_rounded,
              label: 'Unesi merenje',
              onTap: () => onQuickNav(2),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _ShortcutTile(
              icon: Icons.chat_bubble_outline_rounded,
              label: 'Piši treneru',
              onTap: () => onQuickNav(3),
            ),
          ),
        ],
      ),
    );
  }

  Widget _progressTeaser(List<double> weights, double delta) {
    return StudioBGlass(
      onTap: () => onQuickNav(2),
      padding: const EdgeInsets.fromLTRB(20, 18, 16, 18),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Težina — 12 nedelja',
                  style: StudioBTokens.label(size: 12, spacing: 0.3),
                ),
                const SizedBox(height: 6),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      '${studioBDecimal(weights.last)} kg',
                      style: StudioBTokens.display(
                        size: 21,
                        weight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Padding(
                      padding: const EdgeInsets.only(bottom: 2),
                      child: Text(
                        '${studioBDelta(delta)} kg',
                        style: StudioBTokens.label(
                          size: 13,
                          color: StudioBTokens.mintDeep,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          CustomPaint(
            size: const Size(104, 44),
            painter: _SparklinePainter(values: weights),
          ),
          const SizedBox(width: 6),
          const Icon(
            Icons.chevron_right_rounded,
            color: StudioBTokens.inkSoft,
          ),
        ],
      ),
    );
  }
}

class _ShortcutTile extends StatelessWidget {
  const _ShortcutTile({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return StudioBGlass(
      onTap: onTap,
      opacity: 0.64,
      radius: 24,
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 16),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: StudioBTokens.violet.withValues(alpha: 0.12),
            ),
            child: Icon(icon, size: 21, color: StudioBTokens.violetDeep),
          ),
          const SizedBox(height: 10),
          Text(
            label,
            textAlign: TextAlign.center,
            style: StudioBTokens.label(size: 12, color: StudioBTokens.ink),
          ),
        ],
      ),
    );
  }
}

/// Nedeljni ritam: traka dana (odrađeno / sledeći / u planu) + tri statistike.
class _WeekCard extends StatelessWidget {
  const _WeekCard();

  static const _days = ['P', 'U', 'S', 'Č', 'P', 'S', 'N'];

  // 3 treninga ove nedelje: pon i uto odrađeni, sreda je sledeći.
  static const _done = {0, 1};
  static const _next = 2;
  static const _planned = {4};

  @override
  Widget build(BuildContext context) {
    return StudioBGlass(
      padding: const EdgeInsets.fromLTRB(20, 18, 20, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              for (var i = 0; i < _days.length; i++)
                _DayDot(
                  label: _days[i],
                  state: _done.contains(i)
                      ? _DayState.done
                      : i == _next
                          ? _DayState.next
                          : _planned.contains(i)
                              ? _DayState.planned
                              : _DayState.rest,
                ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const _LegendDot(color: StudioBTokens.mint, filled: true),
              const SizedBox(width: 4),
              Text('odrađeno', style: StudioBTokens.label(size: 10.5)),
              const SizedBox(width: 12),
              const _LegendDot(color: StudioBTokens.violet, filled: false),
              const SizedBox(width: 4),
              Text('sledeći', style: StudioBTokens.label(size: 10.5)),
              const SizedBox(width: 12),
              const _LegendDot(color: StudioBTokens.mintDeep, filled: false),
              const SizedBox(width: 4),
              Text('u planu', style: StudioBTokens.label(size: 10.5)),
            ],
          ),
          const SizedBox(height: 14),
          Container(height: 1, color: StudioBTokens.ink.withValues(alpha: 0.06)),
          const SizedBox(height: 14),
          Row(
            children: [
              _Stat(
                value: '${mockWeekStats.trainingsThisWeek}',
                caption: 'ove nedelje',
              ),
              _divider(),
              _Stat(
                value: '${mockWeekStats.trainingsThisMonth}',
                caption: 'ovog meseca',
              ),
              _divider(),
              _Stat(
                value: '${mockWeekStats.streakWeeks}',
                caption: 'nedelja zaredom',
                icon: Icons.local_fire_department_rounded,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _divider() {
    return Container(
      width: 1,
      height: 30,
      color: StudioBTokens.ink.withValues(alpha: 0.08),
    );
  }
}

enum _DayState { done, next, planned, rest }

class _DayDot extends StatelessWidget {
  const _DayDot({required this.label, required this.state});

  final String label;
  final _DayState state;

  @override
  Widget build(BuildContext context) {
    final Color bg;
    final Color fg;
    final Border? border;
    switch (state) {
      case _DayState.done:
        bg = StudioBTokens.mint;
        fg = Colors.white;
        border = null;
      case _DayState.next:
        bg = StudioBTokens.violet.withValues(alpha: 0.12);
        fg = StudioBTokens.violetDeep;
        border = Border.all(color: StudioBTokens.violet, width: 1.6);
      case _DayState.planned:
        bg = Colors.transparent;
        fg = StudioBTokens.mintDeep;
        border = Border.all(color: StudioBTokens.mint, width: 1.4);
      case _DayState.rest:
        bg = Colors.white.withValues(alpha: 0.45);
        fg = StudioBTokens.inkSoft;
        border = Border.all(color: Colors.white.withValues(alpha: 0.55));
    }

    return Container(
      width: 36,
      height: 36,
      alignment: Alignment.center,
      decoration: BoxDecoration(shape: BoxShape.circle, color: bg, border: border),
      child: state == _DayState.done
          ? const Icon(Icons.check_rounded, size: 17, color: Colors.white)
          : Text(
              label,
              style: StudioBTokens.label(size: 12.5, color: fg),
            ),
    );
  }
}

class _LegendDot extends StatelessWidget {
  const _LegendDot({required this.color, required this.filled});

  final Color color;
  final bool filled;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 8,
      height: 8,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: filled ? color : Colors.transparent,
        border: filled ? null : Border.all(color: color, width: 1.4),
      ),
    );
  }
}

class _Stat extends StatelessWidget {
  const _Stat({required this.value, required this.caption, this.icon});

  final String value;
  final String caption;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              if (icon != null) ...[
                Icon(icon, size: 17, color: StudioBTokens.mintDeep),
                const SizedBox(width: 3),
              ],
              Text(
                value,
                style: StudioBTokens.display(size: 21, weight: FontWeight.w700),
              ),
            ],
          ),
          const SizedBox(height: 2),
          Text(
            caption,
            textAlign: TextAlign.center,
            style: StudioBTokens.label(size: 10.5),
          ),
        ],
      ),
    );
  }
}

/// Mini sparkline težine — glatka linija sa gradijent ispunom.
class _SparklinePainter extends CustomPainter {
  const _SparklinePainter({required this.values});

  final List<double> values;

  @override
  void paint(Canvas canvas, Size size) {
    if (values.length < 2) {
      return;
    }
    final minV = values.reduce((a, b) => a < b ? a : b);
    final maxV = values.reduce((a, b) => a > b ? a : b);
    final span = (maxV - minV) == 0 ? 1.0 : maxV - minV;

    final pts = <Offset>[
      for (var i = 0; i < values.length; i++)
        Offset(
          i / (values.length - 1) * size.width,
          size.height - ((values[i] - minV) / span) * (size.height - 8) - 4,
        ),
    ];

    final path = Path()..moveTo(pts.first.dx, pts.first.dy);
    for (var i = 0; i < pts.length - 1; i++) {
      final p0 = i > 0 ? pts[i - 1] : pts[i];
      final p1 = pts[i];
      final p2 = pts[i + 1];
      final p3 = i + 2 < pts.length ? pts[i + 2] : p2;
      final c1 = p1 + (p2 - p0) / 6;
      final c2 = p2 - (p3 - p1) / 6;
      path.cubicTo(c1.dx, c1.dy, c2.dx, c2.dy, p2.dx, p2.dy);
    }

    final fill = Path.from(path)
      ..lineTo(size.width, size.height)
      ..lineTo(0, size.height)
      ..close();
    canvas.drawPath(
      fill,
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            StudioBTokens.violet.withValues(alpha: 0.18),
            StudioBTokens.violet.withValues(alpha: 0.0),
          ],
        ).createShader(Offset.zero & size),
    );

    canvas.drawPath(
      path,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.4
        ..strokeCap = StrokeCap.round
        ..shader = const LinearGradient(
          colors: [StudioBTokens.violet, StudioBTokens.mint],
        ).createShader(Offset.zero & size),
    );

    // Poslednja tačka.
    canvas.drawCircle(pts.last, 4, Paint()..color = Colors.white);
    canvas.drawCircle(
      pts.last,
      4,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2
        ..color = StudioBTokens.mint,
    );
  }

  @override
  bool shouldRepaint(covariant _SparklinePainter oldDelegate) {
    return oldDelegate.values != values;
  }
}
