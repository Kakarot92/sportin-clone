import 'package:flutter/material.dart';

import '../mock_data.dart';
import 'studio_d_theme.dart';

/// Početna — trenerska tabla: pozdrav + streak sticker, žuti blok sledećeg
/// treninga (hazard pruge), mono brojači, crni blok napretka, prečice.
class StudioDHomeScreen extends StatelessWidget {
  const StudioDHomeScreen({super.key, required this.onGoToTab});

  final ValueChanged<int> onGoToTab;

  @override
  Widget build(BuildContext context) {
    final first = mockMeasurements.first;
    final last = mockMeasurements.last;
    final weightDelta = last.weightKg - first.weightKg;

    return StudioDPage(
      children: [
        StudioDStagger(index: 0, child: _buildHeader()),
        const SizedBox(height: 6),
        StudioDStagger(
          index: 0,
          child: Text(
            'Zakazujte treninge, pratite napredak i dopisujte se sa trenerom.',
            style: StudioDType.grotesk(
              size: 13,
              color: StudioDColors.inkSoft,
              height: 1.4,
            ),
          ),
        ),
        const SizedBox(height: 22),
        StudioDStagger(
          index: 1,
          child: StudioDSectionLabel(
            'Sledeći trening',
            trailing: StudioDTag(
              '${mockNextSession.weekday} ${mockNextSession.date}',
              fill: StudioDColors.paper,
            ),
          ),
        ),
        StudioDStagger(index: 1, child: _buildNextSession(context)),
        const SizedBox(height: 22),
        StudioDStagger(
          index: 2,
          child: const StudioDSectionLabel('Ova nedelja'),
        ),
        StudioDStagger(index: 2, child: _buildStatsRow()),
        const SizedBox(height: 22),
        StudioDStagger(
          index: 3,
          child: StudioDSectionLabel(
            'Napredak',
            trailing: const StudioDTag('12 nedelja', fill: StudioDColors.paper),
          ),
        ),
        StudioDStagger(
          index: 3,
          child: _buildProgressBlock(context, last.weightKg, weightDelta),
        ),
        const SizedBox(height: 22),
        StudioDStagger(index: 4, child: const StudioDSectionLabel('Prečice')),
        StudioDStagger(index: 4, child: _buildShortcuts()),
      ],
    );
  }

  Widget _buildHeader() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'ZDRAVO,',
                style: StudioDType.mono(
                  size: 12,
                  weight: FontWeight.w700,
                  spacing: 2,
                ),
              ),
              const SizedBox(height: 4),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Flexible(
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: StudioDColors.yellow,
                        border: Border.all(color: StudioDColors.ink, width: 2),
                        boxShadow: studioDShadow(3),
                      ),
                      child: Text(
                        mockUser.name.toUpperCase(),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: StudioDType.grotesk(
                          size: 30,
                          weight: FontWeight.w700,
                          spacing: 1,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(width: 12),
        Padding(
          padding: const EdgeInsets.only(bottom: 2, right: 4),
          child: StudioDSticker(
            '${mockWeekStats.streakWeeks} NEDELJA\nSTREAK',
            color: StudioDColors.green,
            angleDeg: 3,
          ),
        ),
      ],
    );
  }

  Widget _buildNextSession(BuildContext context) {
    return StudioDPressable(
      color: StudioDColors.yellow,
      shadow: 5,
      onTap: () => onGoToTab(1),
      child: IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(
              width: 12,
              child: CustomPaint(painter: _StudioDHazardPainter()),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          mockNextSession.time,
                          style: StudioDType.mono(
                            size: 34,
                            weight: FontWeight.w700,
                            height: 1,
                          ),
                        ),
                        const Spacer(),
                        StudioDTag(
                          mockNextSession.location,
                          fill: StudioDColors.white,
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      mockNextSession.type,
                      style: StudioDType.grotesk(
                        size: 17,
                        weight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        const Icon(
                          Icons.person_sharp,
                          size: 14,
                          color: StudioDColors.ink,
                        ),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            mockNextSession.trainer,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: StudioDType.grotesk(
                              size: 13,
                              weight: FontWeight.w500,
                            ),
                          ),
                        ),
                        const Icon(
                          Icons.arrow_forward_sharp,
                          size: 18,
                          color: StudioDColors.ink,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatsRow() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Expanded(
          child: _StudioDStatBlock(
            value: '${mockWeekStats.trainingsThisWeek}',
            label: 'TRENINGA\nOVE NEDELJE',
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _StudioDStatBlock(
            value: '${mockWeekStats.trainingsThisMonth}',
            label: 'TRENINGA\nOVAJ MESEC',
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _StudioDStatBlock(
            value: '${mockWeekStats.streakWeeks}',
            label: 'NEDELJA\nZAREDOM',
          ),
        ),
      ],
    );
  }

  Widget _buildProgressBlock(
    BuildContext context,
    double current,
    double delta,
  ) {
    return StudioDPressable(
      color: StudioDColors.ink,
      shadow: 5,
      padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
      onTap: () => onGoToTab(2),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'TRENUTNA TEŽINA',
                  style: StudioDType.mono(
                    size: 9,
                    weight: FontWeight.w700,
                    color: StudioDColors.paper,
                    spacing: 1,
                  ),
                ),
                const SizedBox(height: 6),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      current.toStringAsFixed(1),
                      style: StudioDType.mono(
                        size: 30,
                        weight: FontWeight.w700,
                        color: StudioDColors.yellow,
                        height: 1,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Padding(
                      padding: const EdgeInsets.only(bottom: 2),
                      child: Text(
                        'KG',
                        style: StudioDType.mono(
                          size: 12,
                          weight: FontWeight.w700,
                          color: StudioDColors.yellow,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          StudioDSticker(
            '${studioDDelta(delta)} KG',
            color: StudioDColors.green,
            angleDeg: 2.5,
          ),
          const SizedBox(width: 10),
          const Icon(
            Icons.arrow_forward_sharp,
            size: 20,
            color: StudioDColors.paper,
          ),
        ],
      ),
    );
  }

  Widget _buildShortcuts() {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _StudioDShortcut(
                label: 'Treneri',
                icon: Icons.event_available_sharp,
                color: StudioDColors.yellow,
                onTap: () => onGoToTab(1),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _StudioDShortcut(
                label: 'Merenja',
                icon: Icons.bar_chart_sharp,
                color: StudioDColors.green,
                onTap: () => onGoToTab(2),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _StudioDShortcut(
                label: 'Poruke',
                icon: Icons.chat_bubble_sharp,
                color: StudioDColors.blue,
                textColor: StudioDColors.white,
                onTap: () => onGoToTab(3),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _StudioDShortcut(
                label: 'Profil',
                icon: Icons.person_sharp,
                color: StudioDColors.white,
                onTap: () => onGoToTab(4),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _StudioDStatBlock extends StatelessWidget {
  const _StudioDStatBlock({required this.value, required this.label});

  final String value;
  final String label;

  @override
  Widget build(BuildContext context) {
    return StudioDPanel(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 6),
      child: Column(
        children: [
          Text(
            value,
            style: StudioDType.mono(
              size: 26,
              weight: FontWeight.w700,
              height: 1,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            label,
            textAlign: TextAlign.center,
            style: StudioDType.mono(
              size: 8,
              weight: FontWeight.w700,
              color: StudioDColors.inkSoft,
              height: 1.4,
              spacing: 0.3,
            ),
          ),
        ],
      ),
    );
  }
}

class _StudioDShortcut extends StatelessWidget {
  const _StudioDShortcut({
    required this.label,
    required this.icon,
    required this.color,
    required this.onTap,
    this.textColor = StudioDColors.ink,
  });

  final String label;
  final IconData icon;
  final Color color;
  final Color textColor;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return StudioDPressable(
      color: color,
      shadow: 4,
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 14),
      onTap: onTap,
      child: Row(
        children: [
          Icon(icon, size: 20, color: textColor),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              label.toUpperCase(),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: StudioDType.grotesk(
                size: 14,
                weight: FontWeight.w700,
                color: textColor,
                spacing: 0.8,
              ),
            ),
          ),
          Icon(Icons.arrow_forward_sharp, size: 16, color: textColor),
        ],
      ),
    );
  }
}

/// Kose crno-žute „hazard" pruge — industrijska traka na ivici žutog bloka.
class _StudioDHazardPainter extends CustomPainter {
  const _StudioDHazardPainter();

  @override
  void paint(Canvas canvas, Size size) {
    canvas.clipRect(Offset.zero & size);
    final paint = Paint()..color = StudioDColors.ink;
    const step = 14.0;
    for (var x = -size.height; x < size.width + size.height; x += step) {
      final path = Path()
        ..moveTo(x, size.height)
        ..lineTo(x + size.height, 0)
        ..lineTo(x + size.height + step / 2, 0)
        ..lineTo(x + step / 2, size.height)
        ..close();
      canvas.drawPath(path, paint);
    }
  }

  @override
  bool shouldRepaint(covariant _StudioDHazardPainter oldDelegate) => false;
}
