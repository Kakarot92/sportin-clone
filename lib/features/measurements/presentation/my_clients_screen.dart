import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sportin_clone/app/kinetic.dart';
import 'package:sportin_clone/app/kinetic_effects.dart';
import 'package:sportin_clone/app/theme.dart';
import 'package:sportin_clone/features/auth/application/auth_providers.dart';
import 'package:sportin_clone/features/measurements/application/measurements_providers.dart';
import 'package:sportin_clone/features/measurements/domain/trainer_client_ref.dart';
import 'package:sportin_clone/l10n/app_localizations.dart';

/// Trainer-only screen listing all clients who have booked them.
///
/// Route: /profile/clients
/// Guard: trainer-only — mirrors /profile/availability pattern.
class MyClientsScreen extends ConsumerWidget {
  const MyClientsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final me = ref.watch(appUserProvider).asData?.value;

    // Trainer-only guard — same pattern as availability_editor_screen.dart.
    if (me == null || !me.isTrainer) {
      return Scaffold(
        appBar: AppBar(),
        body: Center(child: Text(l10n.notAuthorized)),
      );
    }

    final clientsAsync = ref.watch(myClientsProvider(me.uid));

    return Scaffold(
      appBar: AppBar(),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(24, 0, 24, 32),
        children: [
          const Eyebrow('Trener'),
          const SizedBox(height: 10),
          DisplayTitle(l10n.myClients),
          const SizedBox(height: 24),
          clientsAsync.when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (_, _) => Text(l10n.errorGeneric),
            data: (clients) {
              if (clients.isEmpty) {
                return Text(
                  l10n.noClientsYet,
                  style: Theme.of(context).textTheme.bodyMedium,
                );
              }
              return Column(
                children: clients
                    .asMap()
                    .entries
                    .map(
                      (e) => Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: Reveal(
                          index: e.key,
                          child: _ClientCard(client: e.value),
                        ),
                      ),
                    )
                    .toList(),
              );
            },
          ),
        ],
      ),
    );
  }
}

// ── Client card — mirrors _TrainerCard from trainer_directory_screen.dart ──────

class _ClientCard extends StatelessWidget {
  const _ClientCard({required this.client});

  final TrainerClientRef client;

  @override
  Widget build(BuildContext context) {
    final name = client.clientDisplayName.isEmpty
        ? client.clientUid
        : client.clientDisplayName;

    return Material(
      color: kInkElevated,
      shape: const RoundedRectangleBorder(
        side: BorderSide(color: kLineDark),
      ),
      child: InkWell(
        onTap: () => context.push(
          '/profile/clients/${client.clientUid}',
          extra: client.clientDisplayName,
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          child: Row(
            children: [
              KineticInitials(name, size: 48, fontSize: 15),
              const SizedBox(width: 14),
              Expanded(
                child: Text(
                  name.toUpperCase(),
                  style: GoogleFonts.archivoBlack(
                    fontSize: 16,
                    color: kOffWhite,
                    height: 1.05,
                  ),
                  overflow: TextOverflow.ellipsis,
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
