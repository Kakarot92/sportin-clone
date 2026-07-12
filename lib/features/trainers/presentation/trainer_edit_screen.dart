import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sportin_clone/app/kinetic.dart';
import 'package:sportin_clone/core/models/trainer_profile.dart';
import 'package:sportin_clone/features/auth/application/auth_providers.dart';
import 'package:sportin_clone/l10n/app_localizations.dart';

import '../application/trainers_providers.dart';

class TrainerEditScreen extends ConsumerStatefulWidget {
  const TrainerEditScreen({super.key});

  @override
  ConsumerState<TrainerEditScreen> createState() => _TrainerEditScreenState();
}

class _TrainerEditScreenState extends ConsumerState<TrainerEditScreen> {
  final _bio = TextEditingController();
  bool _loaded = false;
  bool _saving = false;

  @override
  void dispose() {
    _bio.dispose();
    super.dispose();
  }

  Future<void> _save(String uid, String displayName) async {
    final l10n = AppLocalizations.of(context);
    final messenger = ScaffoldMessenger.of(context);
    final navigator = Navigator.of(context);
    setState(() => _saving = true);
    try {
      await ref.read(trainersRepositoryProvider).upsert(
            TrainerProfile(
              uid: uid,
              displayName: displayName,
              bio: _bio.text.trim(),
            ),
          );
      if (!mounted) return;
      messenger.showSnackBar(SnackBar(content: Text(l10n.profileSaved)));
      navigator.pop();
    } catch (_) {
      if (!mounted) return;
      messenger.showSnackBar(SnackBar(content: Text(l10n.errorGeneric)));
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final user = ref.watch(appUserProvider).asData?.value;

    if (user == null || !user.isTrainer) {
      return Scaffold(
        appBar: AppBar(),
        body: Center(child: Text(l10n.notAuthorized)),
      );
    }

    final profile = ref.watch(trainerProvider(user.uid)).asData?.value;
    if (!_loaded && profile != null) {
      _bio.text = profile.bio;
      _loaded = true;
    }

    return Scaffold(
      appBar: AppBar(),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(24, 0, 24, 32),
        children: [
          const Eyebrow('Trener'),
          const SizedBox(height: 10),
          DisplayTitle(l10n.editTrainerProfile),
          const SizedBox(height: 24),
          KineticField(
            label: l10n.trainerBio,
            controller: _bio,
          ),
          const SizedBox(height: 24),
          VoltButton(
            label: l10n.save,
            icon: Icons.check,
            loading: _saving,
            onPressed: () => _save(user.uid, user.displayName),
          ),
        ],
      ),
    );
  }
}
