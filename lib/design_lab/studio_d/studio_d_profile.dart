import 'package:flutter/material.dart';

import '../mock_data.dart';
import 'studio_d_theme.dart';

/// Profil — članska karta sa perforacijom (dashed linija + barkod), podaci o
/// nalogu, cilj, odjava, i mali crveni blok koji zove onExit (nazad u galeriju).
class StudioDProfileScreen extends StatelessWidget {
  const StudioDProfileScreen({super.key, this.onExit, required this.onLogout});

  final VoidCallback? onExit;
  final VoidCallback onLogout;

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
                  'PROFIL',
                  style: StudioDType.grotesk(
                    size: 30,
                    weight: FontWeight.w700,
                    spacing: 1.5,
                  ),
                ),
              ),
              StudioDTag(
                'Član od ${mockUser.memberSince}',
                fill: StudioDColors.paper,
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),
        StudioDStagger(index: 1, child: _buildIdentity()),
        const SizedBox(height: 24),
        StudioDStagger(
          index: 2,
          child: const StudioDSectionLabel('Članarina'),
        ),
        StudioDStagger(index: 2, child: _buildMembershipCard()),
        const SizedBox(height: 24),
        StudioDStagger(index: 3, child: const StudioDSectionLabel('Nalog')),
        StudioDStagger(index: 3, child: _buildAccountTable()),
        const SizedBox(height: 24),
        StudioDStagger(index: 4, child: const StudioDSectionLabel('Cilj')),
        StudioDStagger(index: 4, child: _buildGoal()),
        const SizedBox(height: 24),
        StudioDStagger(
          index: 5,
          child: StudioDPressable(
            color: StudioDColors.white,
            shadow: 4,
            padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 16),
            onTap: onLogout,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.logout_sharp,
                  size: 18,
                  color: StudioDColors.ink,
                ),
                const SizedBox(width: 8),
                Text(
                  'ODJAVI SE',
                  style: StudioDType.grotesk(
                    size: 14,
                    weight: FontWeight.w700,
                    spacing: 1,
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 28),
        StudioDStagger(index: 6, child: _buildExitBlock(context)),
        const SizedBox(height: 8),
        StudioDStagger(
          index: 6,
          child: Center(
            child: Text(
              'DESIGN LAB · STUDIO D · „BLOK"',
              style: StudioDType.mono(
                size: 9,
                weight: FontWeight.w700,
                color: StudioDColors.inkSoft,
                spacing: 0.8,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildIdentity() {
    return StudioDPanel(
      shadow: 5,
      padding: const EdgeInsets.all(14),
      child: Row(
        children: [
          StudioDMonogram(mockUser.name, size: 68, paletteIndex: 1),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  mockUser.name,
                  style: StudioDType.grotesk(
                    size: 22,
                    weight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    StudioDTag(mockUser.role, fill: StudioDColors.yellow),
                    const SizedBox(width: 6),
                    const StudioDTag('Aktivan', fill: StudioDColors.green),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMembershipCard() {
    final used = mockMembership.total - mockMembership.remaining;
    return StudioDPanel(
      color: StudioDColors.ink,
      shadow: 6,
      padding: EdgeInsets.zero,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'ČLANSKA KARTA',
                            style: StudioDType.mono(
                              size: 9,
                              weight: FontWeight.w700,
                              color: StudioDColors.yellow,
                              spacing: 1.5,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            mockMembership.name,
                            style: StudioDType.grotesk(
                              size: 16,
                              weight: FontWeight.w700,
                              color: StudioDColors.paper,
                              height: 1.2,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const StudioDSticker(
                      'VIP',
                      color: StudioDColors.yellow,
                      angleDeg: 4,
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                // Preostali treninzi kao mreža kvadratića (iskorišćen = pun).
                Wrap(
                  spacing: 7,
                  runSpacing: 7,
                  children: [
                    for (var i = 0; i < mockMembership.total; i++)
                      Container(
                        width: 26,
                        height: 26,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: i < used
                              ? StudioDColors.inkSoft
                              : StudioDColors.yellow,
                          border: Border.all(
                            color: StudioDColors.paper,
                            width: 1.5,
                          ),
                        ),
                        child: i < used
                            ? const Icon(
                                Icons.close_sharp,
                                size: 14,
                                color: StudioDColors.paper,
                              )
                            : Text(
                                '${i + 1}',
                                style: StudioDType.mono(
                                  size: 11,
                                  weight: FontWeight.w700,
                                  color: StudioDColors.ink,
                                ),
                              ),
                      ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Text(
                      '${mockMembership.remaining}',
                      style: StudioDType.mono(
                        size: 30,
                        weight: FontWeight.w700,
                        color: StudioDColors.yellow,
                        height: 1,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Padding(
                      padding: const EdgeInsets.only(bottom: 3),
                      child: Text(
                        'OD ${mockMembership.total} PREOSTALO',
                        style: StudioDType.mono(
                          size: 10,
                          weight: FontWeight.w700,
                          color: StudioDColors.paper,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          // Perforacija — otcepni deo karte.
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            child: StudioDDashedLine(color: StudioDColors.paper),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 14),
            child: Row(
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'OBNOVA',
                      style: StudioDType.mono(
                        size: 8.5,
                        weight: FontWeight.w700,
                        color: StudioDColors.paper,
                        spacing: 0.8,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      mockMembership.renewsOn,
                      style: StudioDType.mono(
                        size: 13,
                        weight: FontWeight.w700,
                        color: StudioDColors.yellow,
                      ),
                    ),
                  ],
                ),
                const Spacer(),
                const StudioDBarcode(width: 74, height: 32),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAccountTable() {
    final rows = <(String, String)>[
      ('IME I PREZIME', mockUser.name),
      ('ULOGA', mockUser.role),
      ('ČLAN OD', mockUser.memberSince),
      ('STATUS', 'AKTIVAN'),
    ];
    return StudioDPanel(
      padding: EdgeInsets.zero,
      child: Column(
        children: [
          for (var i = 0; i < rows.length; i++)
            Container(
              color: i.isEven ? StudioDColors.white : StudioDColors.zebra,
              padding: const EdgeInsets.symmetric(
                horizontal: 14,
                vertical: 12,
              ),
              child: Row(
                children: [
                  Text(
                    rows[i].$1,
                    style: StudioDType.mono(
                      size: 10,
                      weight: FontWeight.w700,
                      color: StudioDColors.inkSoft,
                      spacing: 0.6,
                    ),
                  ),
                  const Spacer(),
                  Flexible(
                    child: Text(
                      rows[i].$2.toUpperCase(),
                      textAlign: TextAlign.right,
                      style: StudioDType.mono(
                        size: 12.5,
                        weight: FontWeight.w700,
                      ),
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildGoal() {
    return StudioDPanel(
      color: StudioDColors.yellow,
      shadow: 4,
      padding: const EdgeInsets.all(14),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.flag_sharp, size: 22, color: StudioDColors.ink),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'AKTUELNI CILJ',
                  style: StudioDType.mono(
                    size: 9,
                    weight: FontWeight.w700,
                    color: StudioDColors.ink,
                    spacing: 1,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  mockUser.goal,
                  style: StudioDType.grotesk(
                    size: 16,
                    weight: FontWeight.w700,
                    height: 1.3,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildExitBlock(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Text(
            'Povratak u Design Lab galeriju:',
            style: StudioDType.mono(
              size: 10.5,
              weight: FontWeight.w700,
              color: StudioDColors.inkSoft,
              height: 1.4,
            ),
          ),
        ),
        const SizedBox(width: 12),
        StudioDPressable(
          color: StudioDColors.red,
          shadow: 3,
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
          onTap: () {
            if (onExit != null) {
              onExit!();
            } else {
              studioDToast(context, 'Izlaz nije povezan u ovom pregledu.');
            }
          },
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.exit_to_app_sharp,
                size: 16,
                color: StudioDColors.ink,
              ),
              const SizedBox(width: 7),
              Text(
                'IZLAZ',
                style: StudioDType.grotesk(
                  size: 13,
                  weight: FontWeight.w700,
                  color: StudioDColors.ink,
                  spacing: 1,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
