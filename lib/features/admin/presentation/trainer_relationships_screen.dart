import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sportin_clone/app/kinetic.dart';
import 'package:sportin_clone/app/theme.dart';
import 'package:sportin_clone/features/auth/application/auth_providers.dart';
import 'package:sportin_clone/features/measurements/application/measurements_providers.dart';
import 'package:sportin_clone/features/measurements/domain/trainer_client_ref.dart';
import 'package:sportin_clone/features/trainers/application/trainers_providers.dart';
import 'package:sportin_clone/l10n/app_localizations.dart';

/// Admin screen: shows all trainer–client relationships, grouped by trainer.
///
/// Route: /profile/admin-relationships
/// Guard: admin-only (AS-087, AS-091).
class TrainerRelationshipsScreen extends ConsumerWidget {
  const TrainerRelationshipsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final me = ref.watch(appUserProvider).asData?.value;

    if (me == null || !me.isAdmin) {
      return Scaffold(
        appBar: AppBar(),
        body: Center(child: Text(l10n.notAuthorized)),
      );
    }

    final relationshipsAsync = ref.watch(allTrainerClientRelationshipsProvider);

    return Scaffold(
      appBar: AppBar(),
      body: relationshipsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text(l10n.errorGeneric)),
        data: (refs) {
          if (refs.isEmpty) {
            return _EmptyRelationships(l10n: l10n);
          }
          return _RelationshipsBody(refs: refs, l10n: l10n, ref: ref);
        },
      ),
    );
  }
}

// ── Empty state ───────────────────────────────────────────────────────────────

class _EmptyRelationships extends StatelessWidget {
  const _EmptyRelationships({required this.l10n});

  final AppLocalizations l10n;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(24, 0, 24, 32),
      children: [
        const Eyebrow('Admin'),
        const SizedBox(height: 10),
        DisplayTitle(l10n.trainerClientRelationships),
        const SizedBox(height: 48),
        Center(
          child: Text(
            l10n.noRelationshipsYet,
            style: Theme.of(context).textTheme.bodyMedium,
            textAlign: TextAlign.center,
          ),
        ),
      ],
    );
  }
}

// ── Body (grouped list) ───────────────────────────────────────────────────────

class _RelationshipsBody extends ConsumerWidget {
  const _RelationshipsBody({
    required this.refs,
    required this.l10n,
    required this.ref,
  });

  final List<TrainerClientRef> refs;
  final AppLocalizations l10n;
  final WidgetRef ref;

  @override
  Widget build(BuildContext context, WidgetRef widgetRef) {
    // Group by trainerUid.
    final Map<String, List<TrainerClientRef>> grouped = {};
    for (final r in refs) {
      grouped.putIfAbsent(r.trainerUid, () => []).add(r);
    }

    final trainerUids = grouped.keys.toList();

    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(24, 0, 24, 32),
      itemCount: trainerUids.length + 1, // +1 for header
      itemBuilder: (context, i) {
        if (i == 0) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Eyebrow('Admin'),
              const SizedBox(height: 10),
              DisplayTitle(l10n.trainerClientRelationships),
              const SizedBox(height: 24),
            ],
          );
        }
        final trainerUid = trainerUids[i - 1];
        final clients = grouped[trainerUid]!;
        return _TrainerSection(
          trainerUid: trainerUid,
          clients: clients,
        );
      },
    );
  }
}

// ── Per-trainer section ───────────────────────────────────────────────────────

class _TrainerSection extends ConsumerWidget {
  const _TrainerSection({
    required this.trainerUid,
    required this.clients,
  });

  final String trainerUid;
  final List<TrainerClientRef> clients;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final trainerAsync = ref.watch(trainerProvider(trainerUid));
    final trainerName = trainerAsync.asData?.value?.displayName ?? trainerUid;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 4),
        SectionHeader(trainerName),
        const SizedBox(height: 8),
        ...clients.map(
          (c) => Container(
            margin: const EdgeInsets.only(bottom: 8),
            padding: const EdgeInsets.fromLTRB(16, 11, 16, 11),
            decoration: BoxDecoration(
              color: kInkElevated,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Theme.of(context).dividerColor),
            ),
            child: Row(
              children: [
                const Icon(Icons.person_outline, size: 16, color: kMutedDark),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    c.clientDisplayName.isEmpty ? c.clientUid : c.clientDisplayName,
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 12),
      ],
    );
  }
}
