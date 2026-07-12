import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sportin_clone/app/kinetic.dart';
import 'package:sportin_clone/app/theme.dart';
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
        appBar: AppBar(),
        body: Center(child: Text(l10n.notAuthorized)),
      );
    }

    final usersAsync = ref.watch(allUsersProvider);
    return Scaffold(
      appBar: AppBar(),
      body: usersAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text(l10n.errorGeneric)),
        data: (users) => ListView.separated(
          padding: const EdgeInsets.fromLTRB(24, 0, 24, 32),
          itemCount: users.length + 1,
          separatorBuilder: (_, i) =>
              SizedBox(height: i == 0 ? 24 : 12),
          itemBuilder: (context, i) {
            if (i == 0) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Eyebrow('Admin'),
                  const SizedBox(height: 10),
                  DisplayTitle(l10n.usersTitle),
                ],
              );
            }
            return _UserRow(user: users[i - 1], me: me);
          },
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
    final theme = Theme.of(context);

    final Widget trailing;
    if (user.isAdmin) {
      trailing = VoltBadge(l10n.roleAdmin);
    } else {
      trailing = Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(l10n.roleTrainerSwitch,
              style: theme.textTheme.bodyMedium),
          Switch(
            value: user.isTrainer,
            onChanged: (v) => _toggle(context, ref, v),
          ),
        ],
      );
    }

    return Container(
      padding: const EdgeInsets.fromLTRB(16, 12, 12, 12),
      decoration: BoxDecoration(
        color: kInkElevated,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: theme.dividerColor),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  user.displayName.isEmpty ? user.email : user.displayName,
                  style: theme.textTheme.titleMedium,
                ),
                Text(user.email, style: theme.textTheme.bodyMedium),
              ],
            ),
          ),
          trailing,
        ],
      ),
    );
  }
}
