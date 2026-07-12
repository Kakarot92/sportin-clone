import 'package:flutter/material.dart';

import '../mock_data.dart';
import 'studio_d_theme.dart';

/// Poruke — lista razgovora kao dosije-redovi (monogram + pretpregled +
/// mono vreme). Tap → thread (push) sa kupon-bubble porukama.
class StudioDMessagesScreen extends StatelessWidget {
  const StudioDMessagesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return StudioDPage(
      children: [
        StudioDStagger(
          index: 0,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Expanded(
                child: Text(
                  'PORUKE',
                  style: StudioDType.grotesk(
                    size: 30,
                    weight: FontWeight.w700,
                    spacing: 1.5,
                  ),
                ),
              ),
              StudioDTag(
                '${mockThreads.length} razgovora',
                fill: StudioDColors.paper,
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),
        for (var i = 0; i < mockThreads.length; i++)
          StudioDStagger(
            index: i + 1,
            child: Padding(
              padding: const EdgeInsets.only(bottom: 14),
              child: _StudioDThreadRow(thread: mockThreads[i], index: i),
            ),
          ),
      ],
    );
  }
}

class _StudioDThreadRow extends StatelessWidget {
  const _StudioDThreadRow({required this.thread, required this.index});

  final MockThread thread;
  final int index;

  @override
  Widget build(BuildContext context) {
    final last = thread.messages.last;
    final unread = index == 0;
    return StudioDPressable(
      shadow: 4,
      padding: const EdgeInsets.all(12),
      onTap: () => Navigator.of(context).push(
        studioDRoute(StudioDThreadScreen(thread: thread, index: index)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          StudioDMonogram(thread.trainerName, size: 50, paletteIndex: index),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        thread.trainerName,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: StudioDType.grotesk(
                          size: 15,
                          weight: FontWeight.w700,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      thread.lastTime,
                      style: StudioDType.mono(
                        size: 10,
                        weight: FontWeight.w700,
                        color: StudioDColors.inkSoft,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 5),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (last.fromMe)
                      Padding(
                        padding: const EdgeInsets.only(top: 1, right: 5),
                        child: Text(
                          'TI:',
                          style: StudioDType.mono(
                            size: 10,
                            weight: FontWeight.w700,
                            color: StudioDColors.inkSoft,
                          ),
                        ),
                      ),
                    Expanded(
                      child: Text(
                        last.text,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: StudioDType.grotesk(
                          size: 13,
                          color: StudioDColors.inkSoft,
                          height: 1.4,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          if (unread)
            Container(
              margin: const EdgeInsets.only(top: 2),
              width: 12,
              height: 12,
              decoration: BoxDecoration(
                color: StudioDColors.red,
                border: Border.all(color: StudioDColors.ink, width: 2),
              ),
            )
          else
            const Padding(
              padding: EdgeInsets.only(top: 2),
              child: Icon(
                Icons.chevron_right_sharp,
                size: 20,
                color: StudioDColors.ink,
              ),
            ),
        ],
      ),
    );
  }
}

/// Thread (push): kupon-bubble poruke sa nazubljenim (perforiranim) ivicama.
/// Moje poruke = žuti kupon desno; trenerove = beli kupon levo. Vreme mono.
class StudioDThreadScreen extends StatelessWidget {
  const StudioDThreadScreen({
    super.key,
    required this.thread,
    required this.index,
  });

  final MockThread thread;
  final int index;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: StudioDGridPaper(
        child: SafeArea(
          bottom: false,
          child: Column(
            children: [
              StudioDTopBar(
                title: thread.trainerName,
                trailing: StudioDTag('Aktivan', fill: StudioDColors.green),
              ),
              Expanded(
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 560),
                    child: ListView.separated(
                      padding: const EdgeInsets.fromLTRB(16, 18, 16, 18),
                      itemCount: thread.messages.length,
                      separatorBuilder: (_, _) => const SizedBox(height: 12),
                      itemBuilder: (context, i) {
                        return StudioDStagger(
                          index: i,
                          child: _StudioDCouponBubble(
                            message: thread.messages[i],
                            trainerName: thread.trainerName,
                            paletteIndex: index,
                          ),
                        );
                      },
                    ),
                  ),
                ),
              ),
              _buildComposer(context),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildComposer(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: StudioDColors.white,
        border: Border(top: BorderSide(color: StudioDColors.ink, width: 2)),
      ),
      child: SafeArea(
        top: false,
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 560),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
              child: Row(
                children: [
                  Expanded(
                    child: Container(
                      height: 48,
                      alignment: Alignment.centerLeft,
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      decoration: BoxDecoration(
                        color: StudioDColors.paper,
                        border: Border.all(color: StudioDColors.ink, width: 2),
                      ),
                      child: Text(
                        'Napiši poruku…',
                        style: StudioDType.mono(
                          size: 12.5,
                          color: StudioDColors.inkSoft,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  StudioDPressable(
                    color: StudioDColors.yellow,
                    shadow: 4,
                    padding: const EdgeInsets.all(14),
                    onTap: () => studioDToast(
                      context,
                      'Demo — poruke se ne šalju.',
                    ),
                    child: const Icon(
                      Icons.send_sharp,
                      size: 20,
                      color: StudioDColors.ink,
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

class _StudioDCouponBubble extends StatelessWidget {
  const _StudioDCouponBubble({
    required this.message,
    required this.trainerName,
    required this.paletteIndex,
  });

  final MockMessage message;
  final String trainerName;
  final int paletteIndex;

  @override
  Widget build(BuildContext context) {
    final me = message.fromMe;
    final fill = me ? StudioDColors.yellow : StudioDColors.white;
    final author = me ? 'TI' : trainerName.split(' ').first.toUpperCase();
    final bubble = ConstrainedBox(
      constraints: BoxConstraints(
        maxWidth: MediaQuery.sizeOf(context).width * 0.78,
      ),
      child: CustomPaint(
        painter: _StudioDCouponPainter(fill: fill),
        child: Padding(
          // Dodatni levi/desni razmak zbog perforacije po ivicama kupona.
          padding: const EdgeInsets.fromLTRB(16, 11, 16, 11),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text(
                    author,
                    style: StudioDType.mono(
                      size: 8.5,
                      weight: FontWeight.w700,
                      color: StudioDColors.inkSoft,
                      spacing: 0.6,
                    ),
                  ),
                  const Spacer(),
                  Text(
                    message.time.toUpperCase(),
                    style: StudioDType.mono(
                      size: 8.5,
                      weight: FontWeight.w700,
                      color: StudioDColors.inkSoft,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 5),
              Text(
                message.text,
                style: StudioDType.grotesk(
                  size: 14,
                  weight: FontWeight.w500,
                  height: 1.4,
                ),
              ),
            ],
          ),
        ),
      ),
    );

    return Row(
      mainAxisAlignment:
          me ? MainAxisAlignment.end : MainAxisAlignment.start,
      children: [
        Flexible(child: bubble),
      ],
    );
  }
}

/// Kupon: pun 2px okvir + tvrda senka + izbušene polukružne perforacije
/// po levoj i desnoj ivici (kao odsečak karte/kupona).
class _StudioDCouponPainter extends CustomPainter {
  const _StudioDCouponPainter({required this.fill});

  final Color fill;

  @override
  void paint(Canvas canvas, Size size) {
    const notch = 3.5;
    const gap = 13.0;

    // Tvrda senka (offset blok iza).
    final shadowRect = Rect.fromLTWH(4, 4, size.width, size.height);
    canvas.drawRect(shadowRect, Paint()..color = StudioDColors.ink);

    final body = Rect.fromLTWH(0, 0, size.width, size.height);
    canvas.drawRect(body, Paint()..color = fill);

    // Okvir.
    canvas.drawRect(
      body.deflate(1),
      Paint()
        ..color = StudioDColors.ink
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2,
    );

    // Perforacije po ivicama — „izgrizu" papir do boje pozadine (papir).
    final punch = Paint()..color = StudioDColors.paper;
    final punchBorder = Paint()
      ..color = StudioDColors.ink
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;
    for (var y = gap; y < size.height - notch; y += gap) {
      canvas.drawCircle(Offset(0, y), notch, punch);
      canvas.drawCircle(Offset(0, y), notch, punchBorder);
      canvas.drawCircle(Offset(size.width, y), notch, punch);
      canvas.drawCircle(Offset(size.width, y), notch, punchBorder);
    }
  }

  @override
  bool shouldRepaint(covariant _StudioDCouponPainter oldDelegate) {
    return oldDelegate.fill != fill;
  }
}
