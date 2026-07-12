import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:sportin_clone/app/kinetic.dart';
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
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 24, 24, 0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Eyebrow(l10n.navSchedule),
              const SizedBox(height: 10),
              DisplayTitle(l10n.chooseTrainer),
              const SizedBox(height: 24),
              Expanded(
                child: trainersAsync.when(
                  loading: () =>
                      const Center(child: CircularProgressIndicator()),
                  error: (e, _) => Center(child: Text(l10n.errorGeneric)),
                  data: (trainers) {
                    if (trainers.isEmpty) {
                      return Center(
                        child: Text(l10n.noTrainers,
                            textAlign: TextAlign.center,
                            style: Theme.of(context).textTheme.bodyMedium),
                      );
                    }
                    return ListView.separated(
                      padding: const EdgeInsets.only(bottom: 24),
                      itemCount: trainers.length,
                      separatorBuilder: (_, _) => const SizedBox(height: 12),
                      itemBuilder: (context, i) =>
                          _TrainerCard(trainer: trainers[i]),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _TrainerCard extends StatelessWidget {
  const _TrainerCard({required this.trainer});

  final TrainerProfile trainer;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final initial = trainer.displayName.isNotEmpty
        ? trainer.displayName.characters.first.toUpperCase()
        : '?';
    return InkWell(
      onTap: () => context.push('/schedule/trainer/${trainer.uid}'),
      borderRadius: BorderRadius.circular(10),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: kInkElevated,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: theme.dividerColor),
        ),
        child: Row(
          children: [
            Container(
              width: 52,
              height: 52,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                border: Border.all(color: kVolt, width: 2),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(initial, style: theme.textTheme.titleLarge),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    trainer.displayName.isEmpty ? '—' : trainer.displayName,
                    style: theme.textTheme.titleMedium,
                  ),
                  if (trainer.bio.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Text(trainer.bio,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.bodyMedium),
                  ],
                ],
              ),
            ),
            const Icon(Icons.chevron_right, color: kVolt),
          ],
        ),
      ),
    );
  }
}
