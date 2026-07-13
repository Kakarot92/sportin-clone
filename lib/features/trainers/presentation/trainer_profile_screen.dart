import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sportin_clone/app/kinetic.dart';
import 'package:sportin_clone/app/kinetic_effects.dart';
import 'package:sportin_clone/app/theme.dart';
import 'package:sportin_clone/l10n/app_localizations.dart';

import '../application/trainers_providers.dart';

class TrainerProfileScreen extends ConsumerWidget {
  const TrainerProfileScreen({super.key, required this.uid});

  final String uid;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final profileAsync = ref.watch(trainerProvider(uid));

    return Scaffold(
      body: SafeArea(
        bottom: false,
        child: profileAsync.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, _) => Center(child: Text(l10n.errorGeneric)),
          data: (t) {
            if (t == null) {
              return Center(child: Text(l10n.errorGeneric));
            }

            final initial = t.displayName.isNotEmpty
                ? t.displayName[0].toUpperCase()
                : '?';
            final nameParts = t.displayName.isEmpty
                ? <String>['—']
                : t.displayName
                    .split(' ')
                    .where((p) => p.isNotEmpty)
                    .toList();
            final nameForInitials =
                t.displayName.isEmpty ? '?' : t.displayName;

            return Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 560),
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // ── Hero stack ──────────────────────────────────────
                      Stack(
                        children: [
                          const Positioned.fill(
                            child: SpeedLines(
                              density: 20,
                              seed: 9,
                              opacity: 0.8,
                            ),
                          ),
                          Positioned(
                            right: -10,
                            top: -18,
                            child: GhostText(
                              initial,
                              size: 150,
                              color: kLineDark,
                            ),
                          ),
                          Padding(
                            padding:
                                const EdgeInsets.fromLTRB(24, 12, 24, 20),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Back button row.
                                Reveal(
                                  index: 0,
                                  dy: -12,
                                  child: Row(
                                    children: [
                                      IconButton(
                                        icon: const Icon(
                                          Icons.arrow_back_rounded,
                                          color: kOffWhite,
                                        ),
                                        tooltip: 'Nazad',
                                        onPressed: () => context.pop(),
                                        padding: EdgeInsets.zero,
                                        constraints:
                                            const BoxConstraints.tightFor(
                                          width: 40,
                                          height: 40,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(height: 12),
                                // Initials avatar.
                                Reveal(
                                  index: 1,
                                  child: KineticInitials(
                                    nameForInitials,
                                    size: 64,
                                    fontSize: 20,
                                  ),
                                ),
                                const SizedBox(height: 14),
                                // Name — each word on its own line.
                                for (var i = 0;
                                    i < nameParts.length;
                                    i++) ...[
                                  Reveal(
                                    index: 2 + i,
                                    dx: -22,
                                    dy: 0,
                                    child: FittedBox(
                                      fit: BoxFit.scaleDown,
                                      alignment: Alignment.centerLeft,
                                      child: Text(
                                        nameParts[i].toUpperCase(),
                                        style: GoogleFonts.archivoBlack(
                                          fontSize: 46,
                                          color:
                                              i == 0 ? kOffWhite : kVolt,
                                          height: 0.9,
                                          letterSpacing: -1,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          ),
                        ],
                      ),
                      // ── Bio + CTA ────────────────────────────────────────
                      Padding(
                        padding:
                            const EdgeInsets.fromLTRB(24, 24, 24, 32),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Reveal(
                              index: 2 + nameParts.length,
                              child: SectionHeader(l10n.trainerBio),
                            ),
                            const SizedBox(height: 12),
                            Reveal(
                              index: 3 + nameParts.length,
                              child: Text(
                                t.bio.isEmpty ? l10n.emptyBio : t.bio,
                                style: Theme.of(context).textTheme.bodyLarge,
                              ),
                            ),
                            const SizedBox(height: 28),
                            Reveal(
                              index: 4 + nameParts.length,
                              child: VoltButton(
                                label: l10n.availableSlots,
                                icon: Icons.event_available,
                                onPressed: () => context
                                    .push('/schedule/trainer/$uid/slots'),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
