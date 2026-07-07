import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sportin_clone/core/models/app_user.dart';
import 'package:sportin_clone/features/auth/application/auth_providers.dart';
import 'package:sportin_clone/l10n/app_localizations.dart';

import '../application/admin_providers.dart';

class AdminUsersScreen extends ConsumerWidget {
  const AdminUsersScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final me = ref.watch(appUserProvider).asData?.value;

    if (me == null || !me.isAdmin) {
      return Scaffold(
        appBar: AppBar(title: Text(l10n.manageRoles)),
        body: Center(child: Text(l10n.notAuthorized)),
      );
    }

    final usersAsync = ref.watch(allUsersProvider);
    return Scaffold(
      appBar: AppBar(title: Text(l10n.usersTitle)),
      body: usersAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text(l10n.errorGeneric)),
        data: (users) => ListView.separated(
          itemCount: users.length,
          separatorBuilder: (_, _) => const Divider(height: 1),
          itemBuilder: (context, i) => _UserRow(user: users[i], me: me),
        ),
      ),
    );
  }
}

class _UserRow extends ConsumerWidget {
  const _UserRow({required this.user, required this.me});

  final AppUser user;
  final AppUser me;

  Future<void> _toggle(
      BuildContext context, WidgetRef ref, bool value) async {
    final l10n = AppLocalizations.of(context);
    final messenger = ScaffoldMessenger.of(context);
    try {
      await ref
          .read(adminRepositoryProvider)
          .setTrainer(user, isTrainer: value);
      messenger.showSnackBar(SnackBar(content: Text(l10n.roleUpdated)));
    } catch (_) {
      messenger.showSnackBar(SnackBar(content: Text(l10n.errorGeneric)));
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);

    // Admins (and yourself) are shown as a non-editable chip.
    final Widget trailing;
    if (user.isAdmin) {
      trailing = Chip(label: Text(l10n.roleAdmin));
    } else {
      trailing = Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(l10n.roleTrainerSwitch),
          Switch(
            value: user.isTrainer,
            onChanged: (v) => _toggle(context, ref, v),
          ),
        ],
      );
    }

    return ListTile(
      title: Text(user.displayName.isEmpty ? user.email : user.displayName),
      subtitle: Text(user.email),
      trailing: trailing,
    );
  }
}
