import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sportin_clone/app/kinetic.dart';
import 'package:sportin_clone/app/theme.dart';
import 'package:sportin_clone/core/models/app_user.dart';
import 'package:sportin_clone/features/auth/application/auth_providers.dart';
import 'package:sportin_clone/features/packages/application/packages_providers.dart';
import 'package:sportin_clone/features/packages/domain/package_type.dart';
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

  Future<void> _assignPackage(
      BuildContext context, WidgetRef ref, List<PackageType> types) async {
    final l10n = AppLocalizations.of(context);
    final messenger = ScaffoldMessenger.of(context);

    if (types.isEmpty) {
      messenger.showSnackBar(
        SnackBar(content: Text(l10n.noPackageTypesYet)),
      );
      return;
    }

    final userName =
        user.displayName.isEmpty ? user.email : user.displayName;

    final selectedType = await showDialog<PackageType>(
      context: context,
      builder: (ctx) => _AssignPackageDialog(
        types: types,
        userName: userName,
      ),
    );

    if (selectedType == null) return;

    final ok = await ref
        .read(packageAdminControllerProvider.notifier)
        .assign(
          clientUid: user.uid,
          type: selectedType,
          assignedByUid: me.uid,
        );

    if (!context.mounted) return;
    messenger.showSnackBar(
      SnackBar(content: Text(ok ? l10n.packageAssigned : l10n.errorGeneric)),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);

    // Pre-load active types so they are available when the assign button is tapped.
    final activeTypes =
        ref.watch(packageTypesProvider(true)).asData?.value ?? [];

    final Widget roleControl;
    if (user.isAdmin) {
      roleControl = VoltBadge(l10n.roleAdmin);
    } else {
      roleControl = Row(
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
          roleControl,
          // Assign package icon button (available for all non-admin users).
          if (!user.isAdmin) ...[
            const SizedBox(width: 4),
            IconButton(
              icon: const Icon(Icons.card_membership_outlined, size: 20),
              tooltip: l10n.assignPackage,
              onPressed: () => _assignPackage(context, ref, activeTypes),
              padding: const EdgeInsets.all(8),
              constraints: const BoxConstraints(minWidth: 40, minHeight: 40),
            ),
          ],
        ],
      ),
    );
  }
}

// ── Assign package dialog ─────────────────────────────────────────────────────

class _AssignPackageDialog extends StatefulWidget {
  const _AssignPackageDialog({
    required this.types,
    required this.userName,
  });

  final List<PackageType> types;
  final String userName;

  @override
  State<_AssignPackageDialog> createState() => _AssignPackageDialogState();
}

class _AssignPackageDialogState extends State<_AssignPackageDialog> {
  late PackageType _selected;

  @override
  void initState() {
    super.initState();
    _selected = widget.types.first;
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return AlertDialog(
      title: Text(l10n.assignPackageTitle),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(l10n.assignPackageBody(_selected.name, widget.userName)),
          const SizedBox(height: 16),
          DropdownButton<PackageType>(
            value: _selected,
            isExpanded: true,
            items: widget.types
                .map((t) => DropdownMenuItem(
                      value: t,
                      child: Text(t.name),
                    ))
                .toList(),
            onChanged: (t) {
              if (t != null) setState(() => _selected = t);
            },
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(l10n.cancel),
        ),
        FilledButton(
          onPressed: () => Navigator.of(context).pop(_selected),
          child: Text(l10n.assignPackage),
        ),
      ],
    );
  }
}
