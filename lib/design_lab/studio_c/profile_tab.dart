import 'package:flutter/material.dart';

import '../mock_data.dart';
import 'theme.dart';
import 'widgets.dart';

/// Profil — „kolofon" izdanja: podaci o čitaocu, članarina kao pretplata,
/// odjava, i diskretna fusnota koja poziva `onExit` (povratak u galeriju).
class StudioCProfileTab extends StatelessWidget {
  const StudioCProfileTab({super.key, this.onExit});

  final VoidCallback? onExit;

  @override
  Widget build(BuildContext context) {
    final u = mockUser;
    final m = mockMembership;
    final used = m.total - m.remaining;

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
              const StudioCReveal(
                order: 0,
                child: StudioCKicker(
                  index: '05',
                  label: 'Profil',
                  trailing: 'KOLOFON',
                ),
              ),
              const SizedBox(height: 18),
              StudioCReveal(
                order: 1,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(u.name, style: StudioCType.display(38)),
                    const SizedBox(height: 8),
                    Text.rich(
                      TextSpan(
                        style: StudioCType.meta(size: 9.5),
                        children: [
                          TextSpan(text: u.role.toUpperCase()),
                          TextSpan(
                            text: '  ·  ',
                            style: StudioCType.meta(
                              size: 9.5,
                              color: StudioCTokens.terracotta,
                            ),
                          ),
                          TextSpan(
                            text: 'ČLAN OD ${u.memberSince.toUpperCase()}',
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 26),
              // Kolofon — impressum redovi.
              StudioCReveal(
                order: 2,
                child: const StudioCKicker(index: '№ 1', label: 'Impresum'),
              ),
              const SizedBox(height: 4),
              StudioCReveal(
                order: 3,
                child: _ColophonRow(label: 'Ime i prezime', value: u.name),
              ),
              StudioCReveal(
                order: 4,
                child: _ColophonRow(label: 'Uloga', value: u.role),
              ),
              StudioCReveal(
                order: 5,
                child: _ColophonRow(label: 'Član od', value: u.memberSince),
              ),
              StudioCReveal(
                order: 6,
                child: _ColophonRow(
                  label: 'Cilj',
                  value: u.goal,
                  isLast: true,
                ),
              ),
              const SizedBox(height: 28),
              // Članarina — pretplata na izdanje.
              StudioCReveal(
                order: 7,
                child: const StudioCKicker(
                  index: '№ 2',
                  label: 'Pretplata',
                ),
              ),
              const SizedBox(height: 16),
              StudioCReveal(
                order: 8,
                child: _MembershipPanel(
                  m: m,
                  used: used,
                ),
              ),
              const SizedBox(height: 28),
              // Radnje.
              StudioCReveal(
                order: 9,
                child: StudioCGhostButton(
                  label: 'Odjavi se',
                  onTap: () => StudioCNote.show(
                    context,
                    'Odjava je dostupna u punom izdanju.',
                  ),
                ),
              ),
              const SizedBox(height: 34),
              // Fusnota / izlaz u galeriju.
              StudioCReveal(
                order: 10,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const StudioCHairline(),
                    const SizedBox(height: 14),
                    Text(
                      'STUDIO — EDITORIAL NOIR',
                      style: StudioCType.meta(
                        size: 8.5,
                        letterSpacing: 2.2,
                        color: StudioCTokens.ink,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Slog: Fraunces & Inter · Bone, ink, terakota · '
                      'Postavljeno u Beogradu, MMXXVI',
                      style: StudioCType.meta(
                        size: 8.5,
                        letterSpacing: 1,
                        color: StudioCTokens.inkSoft.withValues(alpha: 0.8),
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),
                    // Diskretna fusnota — poziva onExit.
                    Center(
                      child: InkWell(
                        onTap: onExit,
                        child: Container(
                          height: 48,
                          alignment: Alignment.center,
                          padding: const EdgeInsets.symmetric(horizontal: 8),
                          child: Text(
                            '⟵ nazad u galeriju studija',
                            style: StudioCType.body(
                              size: 12,
                              color: StudioCTokens.inkSoft,
                            ).copyWith(
                              decoration: TextDecoration.underline,
                              decorationColor: StudioCTokens.hairline,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _ColophonRow extends StatelessWidget {
  const _ColophonRow({
    required this.label,
    required this.value,
    this.isLast = false,
  });

  final String label;
  final String value;
  final bool isLast;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const StudioCHairline(),
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 14),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                width: 108,
                child: Text(
                  label.toUpperCase(),
                  style: StudioCType.meta(size: 9),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  value,
                  style: StudioCType.body(size: 14.5),
                  textAlign: TextAlign.right,
                ),
              ),
            ],
          ),
        ),
        if (isLast) const StudioCHairline(),
      ],
    );
  }
}

class _MembershipPanel extends StatelessWidget {
  const _MembershipPanel({required this.m, required this.used});

  final MockMembership m;
  final int used;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(m.name, style: StudioCType.display(20, weight: FontWeight.w500)),
        const SizedBox(height: 16),
        // Tick-marker skala iskorišćenih/preostalih treninga.
        _SessionTicks(total: m.total, remaining: m.remaining),
        const SizedBox(height: 14),
        Row(
          crossAxisAlignment: CrossAxisAlignment.baseline,
          textBaseline: TextBaseline.alphabetic,
          children: [
            Text(
              StudioCFmt.two(m.remaining),
              style: StudioCType.numeral(
                26,
                style: FontStyle.normal,
                color: StudioCTokens.terracotta,
              ),
            ),
            const SizedBox(width: 8),
            Text(
              'PREOSTALO OD ${StudioCFmt.two(m.total)} TRENINGA',
              style: StudioCType.meta(size: 9),
            ),
            const Spacer(),
            Text('ISKORIŠĆENO $used', style: StudioCType.meta(size: 9)),
          ],
        ),
        const SizedBox(height: 16),
        const StudioCHairline(),
        const SizedBox(height: 12),
        Row(
          children: [
            Text('OBNAVLJANJE', style: StudioCType.meta(size: 9)),
            const Spacer(),
            Text(
              m.renewsOn.toUpperCase(),
              style: StudioCType.meta(
                size: 9,
                color: StudioCTokens.ink,
                weight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

/// Skala treninga kao niz tick-markera: puni (iskorišćeni) i prazni
/// (preostali). Editorial alternativa progress-baru.
class _SessionTicks extends StatelessWidget {
  const _SessionTicks({required this.total, required this.remaining});

  final int total;
  final int remaining;

  @override
  Widget build(BuildContext context) {
    final used = total - remaining;
    return SizedBox(
      height: 26,
      child: Row(
        children: [
          for (var i = 0; i < total; i++) ...[
            Expanded(
              child: _Tick(filled: i < used),
            ),
            if (i < total - 1) const SizedBox(width: 6),
          ],
        ],
      ),
    );
  }
}

class _Tick extends StatelessWidget {
  const _Tick({required this.filled});

  final bool filled;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 26,
      decoration: BoxDecoration(
        color: filled ? StudioCTokens.ink : Colors.transparent,
        border: Border.all(color: StudioCTokens.ink, width: 1),
      ),
    );
  }
}
