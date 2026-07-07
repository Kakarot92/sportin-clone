import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:sportin_clone/l10n/app_localizations.dart';

import '../application/trainers_providers.dart';

class TrainerDirectoryScreen extends ConsumerWidget {
  const TrainerDirectoryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final trainersAsync = ref.watch(trainersListProvider);

    return Scaffold(
      appBar: AppBar(title: Text(l10n.chooseTrainer)),
      body: trainersAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text(l10n.errorGeneric)),
        data: (trainers) {
          if (trainers.isEmpty) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Text(l10n.noTrainers, textAlign: TextAlign.center),
              ),
            );
          }
          return ListView.separated(
            padding: const EdgeInsets.all(8),
            itemCount: trainers.length,
            separatorBuilder: (_, _) => const Divider(height: 1),
            itemBuilder: (context, i) {
              final t = trainers[i];
              return ListTile(
                leading: CircleAvatar(
                  child: Text(t.displayName.isNotEmpty
                      ? t.displayName.characters.first.toUpperCase()
                      : '?'),
                ),
                title: Text(t.displayName.isEmpty ? '—' : t.displayName),
                subtitle: t.bio.isEmpty
                    ? null
                    : Text(t.bio, maxLines: 1, overflow: TextOverflow.ellipsis),
                trailing: const Icon(Icons.chevron_right),
                onTap: () => context.push('/schedule/trainer/${t.uid}'),
              );
            },
          );
        },
      ),
    );
  }
}
