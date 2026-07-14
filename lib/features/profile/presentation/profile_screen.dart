import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sportin_clone/app/kinetic.dart';
import 'package:sportin_clone/app/kinetic_effects.dart';
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

    // Sequential reveal index — incremented inline so every visible item
    // gets a unique stagger slot regardless of conditional rendering.
    var ri = 0;

    return Scaffold(
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(24, 24, 24, 32),
          children: [
            // ── Header ────────────────────────────────────────────────────
            Reveal(index: ri++, child: Eyebrow(l10n.accountSection)),
            const SizedBox(height: 10),
            Reveal(index: ri++, child: DisplayTitle(l10n.profileTitle)),
            const SizedBox(height: 24),

            // ── Identity card + action buttons ────────────────────────────
            if (user != null) ...[
              Reveal(
                index: ri++,
                child: _AccountCard(
                  user: user,
                  roleLabel: _roleLabel(l10n, user.role),
                ),
              ),
              const SizedBox(height: 16),

              // Primary action — skewed volt button.
              Reveal(
                index: ri++,
                child: VoltButton(
                  label: l10n.editProfile,
                  icon: Icons.edit_outlined,
                  onPressed: () => showDialog<void>(
                    context: context,
                    builder: (_) => _EditProfileDialog(user: user),
                  ),
                ),
              ),
              const SizedBox(height: 8),

              // Trainer-only secondary actions.
              if (user.isTrainer) ...[
                Reveal(
                  index: ri++,
                  child: OutlinedButton.icon(
                    onPressed: () => context.push('/profile/trainer-edit'),
                    icon: const Icon(Icons.badge_outlined),
                    label: Text(l10n.editTrainerProfile),
                  ),
                ),
                Reveal(
                  index: ri++,
                  child: OutlinedButton.icon(
                    onPressed: () => context.push('/profile/availability'),
                    icon: const Icon(Icons.calendar_today_outlined),
                    label: Text(l10n.weeklyAvailability),
                  ),
                ),
              ],

              // Admin-only secondary actions.
              if (user.isAdmin) ...[
                Reveal(
                  index: ri++,
                  child: OutlinedButton.icon(
                    onPressed: () => context.push('/profile/admin-users'),
                    icon: const Icon(Icons.admin_panel_settings_outlined),
                    label: Text(l10n.manageRoles),
                  ),
                ),
                Reveal(
                  index: ri++,
                  child: OutlinedButton.icon(
                    onPressed: () => context.push('/profile/studio'),
                    icon: const Icon(Icons.store_outlined),
                    label: Text(l10n.studioClosedDays),
                  ),
                ),
                Reveal(
                  index: ri++,
                  child: OutlinedButton.icon(
                    onPressed: () => context.push('/profile/package-types'),
                    icon: const Icon(Icons.inventory_2_outlined),
                    label: Text(l10n.packageTypesTitle),
                  ),
                ),
              ],

              // All signed-in users: my package shortcut.
              Reveal(
                index: ri++,
                child: OutlinedButton.icon(
                  onPressed: () => context.push('/profile/package'),
                  icon: const Icon(Icons.card_membership_outlined),
                  label: Text(l10n.myPackage),
                ),
              ),

              // All-roles booking shortcut.
              Reveal(
                index: ri++,
                child: OutlinedButton.icon(
                  onPressed: () => context.push('/profile/bookings'),
                  icon: const Icon(Icons.event_outlined),
                  label: Text(l10n.myBookings),
                ),
              ),

              // Trainer-only sessions view.
              if (user.isTrainer)
                Reveal(
                  index: ri++,
                  child: OutlinedButton.icon(
                    onPressed: () => context.push('/profile/sessions'),
                    icon: const Icon(Icons.people_outline),
                    label: Text(l10n.mySessions),
                  ),
                ),

              // Trainer-only group classes management.
              if (user.isTrainer)
                Reveal(
                  index: ri++,
                  child: OutlinedButton.icon(
                    onPressed: () => context.push('/profile/group-classes'),
                    icon: const Icon(Icons.groups_outlined),
                    label: Text(l10n.myGroupClasses),
                  ),
                ),
            ],

            // ── Appearance settings ───────────────────────────────────────
            const SizedBox(height: 28),
            Reveal(index: ri++, child: SectionHeader(l10n.settingsAppearance)),
            const SizedBox(height: 14),
            Reveal(
              index: ri++,
              child: SegmentedButton<ThemeMode>(
                segments: [
                  ButtonSegment(
                      value: ThemeMode.system, label: Text(l10n.themeSystem)),
                  ButtonSegment(
                      value: ThemeMode.light, label: Text(l10n.themeLight)),
                  ButtonSegment(
                      value: ThemeMode.dark, label: Text(l10n.themeDark)),
                ],
                selected: {themeMode},
                onSelectionChanged: (s) =>
                    ref.read(themeModeProvider.notifier).set(s.first),
              ),
            ),

            // ── Language settings ─────────────────────────────────────────
            const SizedBox(height: 24),
            Reveal(index: ri++, child: SectionHeader(l10n.settingsLanguage)),
            const SizedBox(height: 14),
            Reveal(
              index: ri++,
              child: SegmentedButton<String>(
                segments: [
                  ButtonSegment(
                      value: 'sr', label: Text(l10n.languageSerbian)),
                  ButtonSegment(
                      value: 'en', label: Text(l10n.languageEnglish)),
                ],
                selected: {locale.languageCode},
                onSelectionChanged: (s) =>
                    ref.read(localeProvider.notifier).set(Locale(s.first)),
              ),
            ),

            // ── Sign-out ─────────────────────────────────────────────────
            const SizedBox(height: 32),
            Reveal(
              index: ri++,
              child: OutlinedButton.icon(
                onPressed: () =>
                    ref.read(authControllerProvider.notifier).signOut(),
                icon: const Icon(Icons.logout),
                label: Text(l10n.logout),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Account identity card ────────────────────────────────────────────────────

class _AccountCard extends StatelessWidget {
  const _AccountCard({required this.user, required this.roleLabel});

  final AppUser user;
  final String roleLabel;

  String get _displayName =>
      user.displayName.isNotEmpty ? user.displayName : user.email;

  @override
  Widget build(BuildContext context) {
    final ghost =
        _displayName.isNotEmpty ? _displayName[0].toUpperCase() : '?';

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: kInkElevated,
        border: Border.all(color: kLineDark),
      ),
      child: Stack(
        clipBehavior: Clip.hardEdge,
        children: [
          // Ghost initial watermark for depth — clipped to card bounds.
          Positioned(
            right: -16,
            top: -12,
            child: GhostText(
              ghost,
              size: 96,
              color: kLineDark,
              strokeWidth: 1.0,
            ),
          ),
          // Identity row on top.
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              KineticInitials(
                _displayName,
                size: 64,
                fontSize: 22,
                voltBorder: true,
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (user.displayName.isNotEmpty) ...[
                      Text(
                        user.displayName.toUpperCase(),
                        style: GoogleFonts.archivoBlack(
                          fontSize: 17,
                          color: kOffWhite,
                          height: 1.1,
                        ),
                        overflow: TextOverflow.ellipsis,
                        maxLines: 2,
                      ),
                      const SizedBox(height: 6),
                    ],
                    VoltBadge(roleLabel),
                    const SizedBox(height: 8),
                    Text(
                      user.email,
                      style: Theme.of(context).textTheme.bodyMedium,
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (user.phone.isNotEmpty) ...[
                      const SizedBox(height: 2),
                      Text(
                        user.phone,
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ── Edit-profile dialog ─────────────────────────────────────────────────────

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
