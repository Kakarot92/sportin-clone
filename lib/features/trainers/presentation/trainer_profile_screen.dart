import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sportin_clone/app/kinetic.dart';
import 'package:sportin_clone/app/theme.dart';
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
      appBar: AppBar(),
      body: profileAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text(l10n.errorGeneric)),
        data: (t) {
          if (t == null) {
            return Center(child: Text(l10n.errorGeneric));
          }
          final initial = t.displayName.isNotEmpty
              ? t.displayName.characters.first.toUpperCase()
              : '?';
          return ListView(
            padding: const EdgeInsets.fromLTRB(24, 0, 24, 32),
            children: [
              Container(
                width: 96,
                height: 96,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  border: Border.all(color: kVolt, width: 2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(initial, style: theme.textTheme.displaySmall),
              ),
              const SizedBox(height: 20),
              const Eyebrow('Trener'),
              const SizedBox(height: 8),
              Text(t.displayName.isEmpty ? '—' : t.displayName,
                  style: theme.textTheme.headlineMedium),
              const SizedBox(height: 28),
              SectionHeader(l10n.trainerBio),
              const SizedBox(height: 12),
              Text(t.bio.isEmpty ? l10n.emptyBio : t.bio,
                  style: theme.textTheme.bodyLarge),
            ],
          );
        },
      ),
    );
  }
}
