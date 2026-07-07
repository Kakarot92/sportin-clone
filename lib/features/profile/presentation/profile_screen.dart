import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sportin_clone/app/providers.dart';
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
    final theme = Theme.of(context);
    final themeMode = ref.watch(themeModeProvider);
    final locale = ref.watch(localeProvider);
    final userAsync = ref.watch(appUserProvider);
    final user = userAsync.asData?.value;

    return Scaffold(
      appBar: AppBar(title: Text(l10n.profileTitle)),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text(l10n.accountSection, style: theme.textTheme.titleMedium),
          const SizedBox(height: 8),
          userAsync.when(
            loading: () => const Padding(
              padding: EdgeInsets.symmetric(vertical: 24),
              child: Center(child: CircularProgressIndicator()),
            ),
            error: (e, _) => Text(l10n.errorGeneric),
            data: (u) => _AccountCard(
              user: u,
              roleLabel: u == null ? '' : _roleLabel(l10n, u.role),
            ),
          ),
          if (user != null) ...[
            const SizedBox(height: 8),
            OutlinedButton.icon(
              onPressed: () => showDialog<void>(
                context: context,
                builder: (_) => _EditProfileDialog(user: user),
              ),
              icon: const Icon(Icons.edit_outlined),
              label: Text(l10n.editProfile),
            ),
          ],
          const Divider(height: 40),
          Text(l10n.settingsAppearance, style: theme.textTheme.titleMedium),
          const SizedBox(height: 12),
          Text(l10n.settingsTheme, style: theme.textTheme.bodyMedium),
          const SizedBox(height: 8),
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
          const Divider(height: 40),
          Text(l10n.settingsLanguage, style: theme.textTheme.titleMedium),
          const SizedBox(height: 12),
          SegmentedButton<String>(
            segments: [
              ButtonSegment(value: 'sr', label: Text(l10n.languageSerbian)),
              ButtonSegment(value: 'en', label: Text(l10n.languageEnglish)),
            ],
            selected: {locale.languageCode},
            onSelectionChanged: (s) =>
                ref.read(localeProvider.notifier).set(Locale(s.first)),
          ),
          const Divider(height: 40),
          FilledButton.tonalIcon(
            onPressed: () =>
                ref.read(authControllerProvider.notifier).signOut(),
            icon: const Icon(Icons.logout),
            label: Text(l10n.logout),
          ),
        ],
      ),
    );
  }
}

class _AccountCard extends StatelessWidget {
  const _AccountCard({required this.user, required this.roleLabel});

  final AppUser? user;
  final String roleLabel;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    if (user == null) {
      return const SizedBox.shrink();
    }
    final u = user!;
    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (u.displayName.isNotEmpty)
              Text(u.displayName,
                  style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 4),
            _row(context, Icons.email_outlined, u.email),
            if (u.phone.isNotEmpty)
              _row(context, Icons.phone_outlined, u.phone),
            const SizedBox(height: 8),
            Row(
              children: [
                Text('${l10n.profileRole}: '),
                Chip(label: Text(roleLabel)),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _row(BuildContext context, IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        children: [
          Icon(icon, size: 18, color: Theme.of(context).colorScheme.outline),
          const SizedBox(width: 8),
          Expanded(child: Text(text)),
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
