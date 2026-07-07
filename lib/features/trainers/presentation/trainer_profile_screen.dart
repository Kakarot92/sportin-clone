import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sportin_clone/l10n/app_localizations.dart';

import '../application/trainers_providers.dart';

class TrainerProfileScreen extends ConsumerWidget {
  const TrainerProfileScreen({super.key, required this.uid});

  final String uid;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final profileAsync = ref.watch(trainerProvider(uid));

    return Scaffold(
      appBar: AppBar(title: Text(l10n.trainersTitle)),
      body: profileAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text(l10n.errorGeneric)),
        data: (t) {
          if (t == null) {
            return Center(child: Text(l10n.errorGeneric));
          }
          return ListView(
            padding: const EdgeInsets.all(24),
            children: [
              Center(
                child: CircleAvatar(
                  radius: 44,
                  child: Text(
                    t.displayName.isNotEmpty
                        ? t.displayName.characters.first.toUpperCase()
                        : '?',
                    style: theme.textTheme.headlineMedium,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Center(
                child: Text(
                  t.displayName.isEmpty ? '—' : t.displayName,
                  style: theme.textTheme.headlineSmall,
                ),
              ),
              const SizedBox(height: 24),
              Text(l10n.trainerBio, style: theme.textTheme.titleMedium),
              const SizedBox(height: 8),
              Text(t.bio.isEmpty ? l10n.emptyBio : t.bio),
            ],
          );
        },
      ),
    );
  }
}
