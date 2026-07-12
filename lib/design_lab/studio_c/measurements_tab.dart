import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../mock_data.dart';
import 'theme.dart';
import 'widgets.dart';

/// Merenja — data-viz momenat studija: trenutni brojevi kao standfirst,
/// tanka ink linija napretka sa terakota tačkom na poslednjem merenju,
/// ledger tabela od 12 nedelja sa serif tabularnim numeralima.
class StudioCMeasurementsTab extends StatelessWidget {
  const StudioCMeasurementsTab({super.key});

  @override
  Widget build(BuildContext context) {
    final first = mockMeasurements.first;
    final last = mockMeasurements.last;
    final weightDelta = last.weightKg - first.weightKg;
    final fatDelta = last.bodyFatPct - first.bodyFatPct;
    final waistDelta = last.waistCm - first.waistCm;

    return ListView(
      padding: const EdgeInsets.fromLTRB(
        StudioCTokens.margin,
        14,
        StudioCTokens.margin,
        28,
      ),
      children: [
        StudioCPageColumn(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              StudioCReveal(
                order: 0,
                child: StudioCKicker(
                  index: '03',
                  label: 'Merenja',
                  trailing: '${mockMeasurements.length} NEDELJA',
                ),
              ),
              const SizedBox(height: 18),
              StudioCReveal(
                order: 1,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Napredak', style: StudioCType.display(32)),
                    const SizedBox(height: 10),
                    Text(
                      'Dvanaest nedelja, tri broja. Grafikon je jedna linija — '
                      'ostalo je tabela.',
                      style: StudioCType.body(color: StudioCTokens.inkSoft),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              // Trenutni brojevi.
              StudioCReveal(
                order: 2,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const StudioCHairline(),
                    IntrinsicHeight(
                      child: Row(
                        children: [
                          _NowCell(
                            value: StudioCFmt.dec(last.weightKg),
                            unit: 'KG',
                            label: 'TEŽINA',
                            delta: StudioCFmt.delta(weightDelta),
                          ),
                          Container(width: 1, color: StudioCTokens.hairline),
                          _NowCell(
                            value: StudioCFmt.dec(last.bodyFatPct),
                            unit: '%',
                            label: 'MASNOĆA',
                            delta: StudioCFmt.delta(fatDelta),
                          ),
                          Container(width: 1, color: StudioCTokens.hairline),
                          _NowCell(
                            value: StudioCFmt.dec(last.waistCm, digits: 0),
                            unit: 'CM',
                            label: 'STRUK',
                            delta: StudioCFmt.delta(waistDelta, digits: 0),
                          ),
                        ],
                      ),
                    ),
                    const StudioCHairline(),
                  ],
                ),
              ),
              const SizedBox(height: 28),
              // Grafikon — jedna ink linija.
              StudioCReveal(
                order: 3,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Row(
                      children: [
                        Text(
                          'TEŽINA · KG',
                          style: StudioCType.meta(size: 9),
                        ),
                        const Spacer(),
                        Text(
                          'NEDELJA 01 — ${StudioCFmt.two(mockMeasurements.length)}',
                          style: StudioCType.meta(size: 9),
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),
                    SizedBox(
                      height: 172,
                      child: _WeightChart(data: mockMeasurements),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 30),
              // Ledger tabela.
              StudioCReveal(
                order: 4,
                child: const StudioCKicker(
                  index: '№ 3',
                  label: 'Knjiga merenja',
                ),
              ),
              const SizedBox(height: 12),
              StudioCReveal(
                order: 5,
                child: const _LedgerHeader(),
              ),
              const StudioCHairline(),
              for (var i = 0; i < mockMeasurements.length; i++)
                StudioCReveal(
                  order: 6 + math.min(i, 5),
                  child: _LedgerRow(
                    m: mockMeasurements[i],
                    isLast: i == mockMeasurements.length - 1,
                    zebra: i.isOdd,
                  ),
                ),
              const StudioCHairline(thickness: 2.5, color: StudioCTokens.ink),
              const SizedBox(height: 12),
              StudioCReveal(
                order: 12,
                child: Text(
                  '● POSLEDNJE MERENJE OZNAČENO TERAKOTA TAČKOM',
                  style: StudioCType.meta(
                    size: 8.5,
                    color: StudioCTokens.terracotta,
                    letterSpacing: 1.4,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _NowCell extends StatelessWidget {
  const _NowCell({
    required this.value,
    required this.unit,
    required this.label,
    required this.delta,
  });

  final String value;
  final String unit;
  final String label;
  final String delta;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            FittedBox(
              fit: BoxFit.scaleDown,
              alignment: Alignment.centerLeft,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.baseline,
                textBaseline: TextBaseline.alphabetic,
                children: [
                  Text(
                    value,
                    style: StudioCType.numeral(30, style: FontStyle.normal),
                  ),
                  const SizedBox(width: 3),
                  Text(unit, style: StudioCType.meta(size: 9)),
                ],
              ),
            ),
            const SizedBox(height: 8),
            FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(label, style: StudioCType.meta(size: 8.5)),
            ),
            const SizedBox(height: 4),
            Text(
              delta,
              style: StudioCType.meta(
                size: 9,
                color: StudioCTokens.terracotta,
                letterSpacing: 0.5,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _LedgerHeader extends StatelessWidget {
  const _LedgerHeader();

  @override
  Widget build(BuildContext context) {
    Widget cell(String t, int flex, TextAlign align) => Expanded(
          flex: flex,
          child: Text(
            t,
            textAlign: align,
            style: StudioCType.meta(size: 8.5),
          ),
        );
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          cell('NED.', 3, TextAlign.left),
          cell('TEŽINA', 4, TextAlign.right),
          cell('MASN.', 4, TextAlign.right),
          cell('STRUK', 4, TextAlign.right),
        ],
      ),
    );
  }
}

class _LedgerRow extends StatelessWidget {
  const _LedgerRow({
    required this.m,
    required this.isLast,
    required this.zebra,
  });

  final MockMeasurement m;
  final bool isLast;
  final bool zebra;

  @override
  Widget build(BuildContext context) {
    final weightStyle = StudioCType.tabular(
      size: 13,
      weight: isLast ? FontWeight.w600 : FontWeight.w400,
      color: StudioCTokens.ink,
    );
    Widget num(String t, int flex, TextStyle style) => Expanded(
          flex: flex,
          child: Text(t, textAlign: TextAlign.right, style: style),
        );
    return Container(
      color: zebra
          ? StudioCTokens.ink.withValues(alpha: 0.018)
          : Colors.transparent,
      padding: const EdgeInsets.symmetric(vertical: 11),
      child: Row(
        children: [
          Expanded(
            flex: 3,
            child: Row(
              children: [
                SizedBox(
                  width: 8,
                  child: isLast
                      ? const _TerracottaDot()
                      : const SizedBox.shrink(),
                ),
                const SizedBox(width: 6),
                Text(
                  StudioCFmt.two(m.week),
                  style: StudioCType.numeral(
                    14,
                    style: FontStyle.italic,
                    color: isLast
                        ? StudioCTokens.terracotta
                        : StudioCTokens.inkSoft,
                  ),
                ),
              ],
            ),
          ),
          num('${StudioCFmt.dec(m.weightKg)} kg', 4, weightStyle),
          num(
            '${StudioCFmt.dec(m.bodyFatPct)} %',
            4,
            StudioCType.tabular(size: 12.5, color: StudioCTokens.inkSoft),
          ),
          num(
            '${StudioCFmt.dec(m.waistCm, digits: 0)} cm',
            4,
            StudioCType.tabular(size: 12.5, color: StudioCTokens.inkSoft),
          ),
        ],
      ),
    );
  }
}

class _TerracottaDot extends StatelessWidget {
  const _TerracottaDot();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        width: 6,
        height: 6,
        decoration: const BoxDecoration(
          color: StudioCTokens.terracotta,
          shape: BoxShape.circle,
        ),
      ),
    );
  }
}

/// Linijski grafikon težine — tanka ink linija, hairline osnovna linija,
/// terakota marker na poslednjoj tački. Bez ispune, bez senke.
class _WeightChart extends StatelessWidget {
  const _WeightChart({required this.data});

  final List<MockMeasurement> data;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return CustomPaint(
          size: Size(constraints.maxWidth, constraints.maxHeight),
          painter: _WeightChartPainter(data),
        );
      },
    );
  }
}

class _WeightChartPainter extends CustomPainter {
  _WeightChartPainter(this.data);

  final List<MockMeasurement> data;

  @override
  void paint(Canvas canvas, Size size) {
    if (data.isEmpty) return;
    const leftPad = 4.0;
    const rightPad = 10.0;
    const topPad = 14.0;
    const bottomPad = 22.0;
    final chartW = size.width - leftPad - rightPad;
    final chartH = size.height - topPad - bottomPad;

    var minV = data.first.weightKg;
    var maxV = data.first.weightKg;
    for (final m in data) {
      minV = math.min(minV, m.weightKg);
      maxV = math.max(maxV, m.weightKg);
    }
    final range = (maxV - minV) == 0 ? 1 : (maxV - minV);

    Offset pointAt(int i) {
      final x = leftPad + chartW * (i / (data.length - 1));
      final norm = (data[i].weightKg - minV) / range;
      final y = topPad + chartH * (1 - norm);
      return Offset(x, y);
    }

    final hairPaint = Paint()
      ..color = StudioCTokens.hairline
      ..strokeWidth = 1;

    // Osnovna i gornja hairline linija.
    canvas.drawLine(
      Offset(leftPad, topPad),
      Offset(size.width - rightPad, topPad),
      hairPaint,
    );
    canvas.drawLine(
      Offset(leftPad, topPad + chartH),
      Offset(size.width - rightPad, topPad + chartH),
      hairPaint,
    );

    // Vertikalni tick markeri (svake 3 nedelje) — tanke ink crtice.
    final tickPaint = Paint()
      ..color = StudioCTokens.inkSoft.withValues(alpha: 0.35)
      ..strokeWidth = 1;
    final labelStyleColor = StudioCTokens.inkSoft;
    for (var i = 0; i < data.length; i += 3) {
      final p = pointAt(i);
      canvas.drawLine(
        Offset(p.dx, topPad + chartH),
        Offset(p.dx, topPad + chartH + 4),
        tickPaint,
      );
      final tp = TextPainter(
        text: TextSpan(
          text: StudioCFmt.two(data[i].week),
          style: StudioCType.meta(size: 8, color: labelStyleColor),
        ),
        textDirection: TextDirection.ltr,
      )..layout();
      tp.paint(
        canvas,
        Offset(p.dx - tp.width / 2, topPad + chartH + 8),
      );
    }

    // Linija napretka.
    final path = Path();
    for (var i = 0; i < data.length; i++) {
      final p = pointAt(i);
      if (i == 0) {
        path.moveTo(p.dx, p.dy);
      } else {
        path.lineTo(p.dx, p.dy);
      }
    }
    final linePaint = Paint()
      ..color = StudioCTokens.ink
      ..strokeWidth = 1.6
      ..style = PaintingStyle.stroke
      ..strokeJoin = StrokeJoin.round
      ..strokeCap = StrokeCap.round;
    canvas.drawPath(path, linePaint);

    // Bele tačke na svakom čvoru (rez linije).
    final nodeFill = Paint()..color = StudioCTokens.bone;
    final nodeStroke = Paint()
      ..color = StudioCTokens.ink
      ..strokeWidth = 1.2
      ..style = PaintingStyle.stroke;
    for (var i = 0; i < data.length; i++) {
      final p = pointAt(i);
      canvas.drawCircle(p, 2.4, nodeFill);
      canvas.drawCircle(p, 2.4, nodeStroke);
    }

    // Prva tačka je najviša (početna, najveća težina) — labela ide ISPOD nje
    // da ne izađe iznad platna.
    final firstP = pointAt(0);
    final firstLabel = TextPainter(
      text: TextSpan(
        text: StudioCFmt.dec(data.first.weightKg),
        style: StudioCType.meta(size: 8.5, color: StudioCTokens.inkSoft),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    firstLabel.paint(
      canvas,
      Offset(firstP.dx + 4, firstP.dy + 6),
    );

    // Poslednja tačka — terakota marker + prsten + vrednost.
    final lastP = pointAt(data.length - 1);
    final ringPaint = Paint()
      ..color = StudioCTokens.terracotta.withValues(alpha: 0.28)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;
    canvas.drawCircle(lastP, 6, ringPaint);
    canvas.drawCircle(lastP, 3.4, Paint()..color = StudioCTokens.terracotta);

    final lastLabel = TextPainter(
      text: TextSpan(
        text: StudioCFmt.dec(data.last.weightKg),
        style: StudioCType.numeral(
          13,
          style: FontStyle.normal,
          color: StudioCTokens.terracotta,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    lastLabel.paint(
      canvas,
      Offset(lastP.dx - lastLabel.width, lastP.dy - 18),
    );
  }

  @override
  bool shouldRepaint(covariant _WeightChartPainter oldDelegate) =>
      oldDelegate.data != data;
}
