import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sportin_clone/app/kinetic.dart';
import 'package:sportin_clone/app/kinetic_effects.dart';
import 'package:sportin_clone/app/theme.dart';
import 'package:sportin_clone/core/models/trainer_profile.dart';
import 'package:sportin_clone/l10n/app_localizations.dart';

import '../application/trainers_providers.dart';

class TrainerDirectoryScreen extends ConsumerWidget {
  const TrainerDirectoryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final trainersAsync = ref.watch(trainersListProvider);

    return Scaffold(
      body: Stack(
        children: [
          // Faint speed-lines backdrop.
          const Positioned.fill(
            child: SpeedLines(density: 14, seed: 2, opacity: 0.18),
          ),
          SafeArea(
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 560),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.fromLTRB(24, 20, 24, 0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Reveal(
                            index: 0,
                            child: Eyebrow(l10n.navSchedule),
                          ),
                          const SizedBox(height: 6),
                          Reveal(
                            index: 1,
                            child: DisplayTitle(l10n.chooseTrainer, size: 38),
                          ),
                          const SizedBox(height: 12),
                          Reveal(
                            index: 2,
                            child: OutlinedButton.icon(
                              onPressed: () =>
                                  context.push('/schedule/group-classes'),
                              icon: const Icon(
                                Icons.groups_outlined,
                                color: kVolt,
                              ),
                              label: Text(l10n.groupClasses),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),
                    Expanded(
                      child: trainersAsync.when(
                        loading: () =>
                            const Center(child: CircularProgressIndicator()),
                        error: (e, _) =>
                            Center(child: Text(l10n.errorGeneric)),
                        data: (trainers) {
                          if (trainers.isEmpty) {
                            return Center(
                              child: Text(
                                l10n.noTrainers,
                                textAlign: TextAlign.center,
                                style: Theme.of(context).textTheme.bodyMedium,
                              ),
                            );
                          }
                          return ListView.separated(
                            padding: const EdgeInsets.fromLTRB(24, 0, 24, 32),
                            itemCount: trainers.length,
                            separatorBuilder: (_, _) =>
                                const SizedBox(height: 8),
                            itemBuilder: (context, i) => Reveal(
                              index: 3 + i,
                              child: _TrainerCard(
                                trainer: trainers[i],
                              ),
                            ),
                          );
                        },
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

class _TrainerCard extends StatelessWidget {
  const _TrainerCard({required this.trainer});

  final TrainerProfile trainer;

  @override
  Widget build(BuildContext context) {
    final name =
        trainer.displayName.isEmpty ? '?' : trainer.displayName;
    return Material(
      color: kInkElevated,
      shape: const RoundedRectangleBorder(
        side: BorderSide(color: kLineDark),
      ),
      child: InkWell(
        onTap: () => context.push('/schedule/trainer/${trainer.uid}'),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          child: Row(
            children: [
              KineticInitials(name, size: 48, fontSize: 15),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name.toUpperCase(),
                      style: GoogleFonts.archivoBlack(
                        fontSize: 16,
                        color: kOffWhite,
                        height: 1.05,
                      ),
                    ),
                    if (trainer.bio.isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Text(
                        trainer.bio,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.interTight(
                          fontSize: 13,
                          color: kMutedDark,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(width: 10),
              const Icon(
                Icons.chevron_right_rounded,
                size: 20,
                color: kVolt,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
