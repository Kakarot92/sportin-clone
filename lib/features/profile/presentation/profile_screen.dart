import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:sportin_clone/app/kinetic.dart';
import 'package:sportin_clone/app/providers.dart';
import 'package:sportin_clone/app/theme.dart';
import 'package:sportin_clone/core/models/app_user.dart';
import 'package:sportin_clone/features/auth/application/auth_providers.dart';
import 'package:sportin_clone/l10n/app_localizations.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  String _roleLabel(AppLocalizations l10n, AppRole role) {
    switch (role) {
      case AppRole.admin:
        return l10n.roleAdmin;
      case AppRole.trainer:
        return l10n.roleTrainer;
      case AppRole.client:
        return l10n.roleClient;
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final themeMode = ref.watch(themeModeProvider);
    final locale = ref.watch(localeProvider);
    final user = ref.watch(appUserProvider).asData?.value;

    return Scaffold(
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(24, 24, 24, 32),
          children: [
            Eyebrow(l10n.accountSection),
            const SizedBox(height: 10),
            DisplayTitle(l10n.profileTitle),
            const SizedBox(height: 24),
            if (user != null) ...[
              _AccountCard(user: user, roleLabel: _roleLabel(l10n, user.role)),
              const SizedBox(height: 14),
              OutlinedButton.icon(
                onPressed: () => showDialog<void>(
                  context: context,
                  builder: (_) => _EditProfileDialog(user: user),
                ),
                icon: const Icon(Icons.edit_outlined),
                label: Text(l10n.editProfile),
              ),
              if (user.isTrainer)
                OutlinedButton.icon(
                  onPressed: () => context.push('/profile/trainer-edit'),
                  icon: const Icon(Icons.badge_outlined),
                  label: Text(l10n.editTrainerProfile),
                ),
              if (user.isAdmin)
                OutlinedButton.icon(
                  onPressed: () => context.push('/profile/admin-users'),
                  icon: const Icon(Icons.admin_panel_settings_outlined),
                  label: Text(l10n.manageRoles),
                ),
            ],
            const SizedBox(height: 28),
            SectionHeader(l10n.settingsAppearance),
            const SizedBox(height: 14),
            SegmentedButton<ThemeMode>(
              segments: [
                ButtonSegment(
                    value: ThemeMode.system, label: Text(l10n.themeSystem)),
                ButtonSegment(
                    value: ThemeMode.light, label: Text(l10n.themeLight)),
                ButtonSegment(value: ThemeMode.dark, label: Text(l10n.themeDark)),
              ],
              selected: {themeMode},
              onSelectionChanged: (s) =>
                  ref.read(themeModeProvider.notifier).set(s.first),
            ),
            const SizedBox(height: 24),
            SectionHeader(l10n.settingsLanguage),
            const SizedBox(height: 14),
            SegmentedButton<String>(
              segments: [
                ButtonSegment(value: 'sr', label: Text(l10n.languageSerbian)),
                ButtonSegment(value: 'en', label: Text(l10n.languageEnglish)),
              ],
              selected: {locale.languageCode},
              onSelectionChanged: (s) =>
                  ref.read(localeProvider.notifier).set(Locale(s.first)),
            ),
            const SizedBox(height: 32),
            OutlinedButton.icon(
              onPressed: () =>
                  ref.read(authControllerProvider.notifier).signOut(),
              icon: const Icon(Icons.logout),
              label: Text(l10n.logout),
            ),
          ],
        ),
      ),
    );
  }
}

class _AccountCard extends StatelessWidget {
  const _AccountCard({required this.user, required this.roleLabel});

  final AppUser user;
  final String roleLabel;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final initial = user.displayName.isNotEmpty
        ? user.displayName.characters.first.toUpperCase()
        : (user.email.isNotEmpty ? user.email.characters.first.toUpperCase() : '?');
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: kInkElevated,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: theme.dividerColor),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 64,
            height: 64,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              border: Border.all(color: kVolt, width: 2),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Text(initial, style: theme.textTheme.headlineSmall),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (user.displayName.isNotEmpty)
                  Text(user.displayName, style: theme.textTheme.titleLarge),
                const SizedBox(height: 6),
                Align(
                  alignment: Alignment.centerLeft,
                  child: VoltBadge(roleLabel),
                ),
                const SizedBox(height: 10),
                Text(user.email, style: theme.textTheme.bodyMedium),
                if (user.phone.isNotEmpty)
                  Text(user.phone, style: theme.textTheme.bodyMedium),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _EditProfileDialog extends ConsumerStatefulWidget {
  const _EditProfileDialog({required this.user});

  final AppUser user;

  @override
  ConsumerState<_EditProfileDialog> createState() => _EditProfileDialogState();
}

class _EditProfileDialogState extends ConsumerState<_EditProfileDialog> {
  late final TextEditingController _name =
      TextEditingController(text: widget.user.displayName);
  late final TextEditingController _phone =
      TextEditingController(text: widget.user.phone);

  @override
  void dispose() {
    _name.dispose();
    _phone.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final l10n = AppLocalizations.of(context);
    final messenger = ScaffoldMessenger.of(context);
    final navigator = Navigator.of(context);
    final ok = await ref.read(authControllerProvider.notifier).updateProfile(
          uid: widget.user.uid,
          displayName: _name.text.trim(),
          phone: _phone.text.trim(),
        );
    if (!mounted) return;
    navigator.pop();
    messenger.showSnackBar(
      SnackBar(content: Text(ok ? l10n.profileSaved : l10n.errorGeneric)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final isLoading = ref.watch(authControllerProvider).isLoading;
    return AlertDialog(
      title: Text(l10n.editProfile),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: _name,
            decoration: InputDecoration(labelText: l10n.displayNameLabel),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _phone,
            keyboardType: TextInputType.phone,
            decoration: InputDecoration(labelText: l10n.phoneLabel),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: isLoading ? null : () => Navigator.of(context).pop(),
          child: Text(l10n.cancel),
        ),
        FilledButton(
          onPressed: isLoading ? null : _save,
          child: Text(l10n.save),
        ),
      ],
    );
  }
}
