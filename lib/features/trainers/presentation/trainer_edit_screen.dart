import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
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
        appBar: AppBar(title: Text(l10n.editTrainerProfile)),
        body: Center(child: Text(l10n.notAuthorized)),
      );
    }

    // Seed the bio field once from the existing public profile.
    final profile = ref.watch(trainerProvider(user.uid)).asData?.value;
    if (!_loaded && profile != null) {
      _bio.text = profile.bio;
      _loaded = true;
    }

    return Scaffold(
      appBar: AppBar(title: Text(l10n.editTrainerProfile)),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text(user.displayName, style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 16),
          TextField(
            controller: _bio,
            maxLines: 5,
            decoration: InputDecoration(
              labelText: l10n.trainerBio,
              border: const OutlineInputBorder(),
              alignLabelWithHint: true,
            ),
          ),
          const SizedBox(height: 16),
          FilledButton(
            onPressed: _saving ? null : () => _save(user.uid, user.displayName),
            child: _saving
                ? const SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(strokeWidth: 2))
                : Text(l10n.save),
          ),
        ],
      ),
    );
  }
}
