import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:sportin_clone/app/kinetic.dart';
import 'package:sportin_clone/app/theme.dart';
import 'package:sportin_clone/features/auth/application/auth_providers.dart';
import 'package:sportin_clone/l10n/app_localizations.dart';

/// Admin screen: navigation hub for studio settings.
///
/// Links to:
///  - Studio closed days  → /profile/studio
///  - Package types       → /profile/package-types
///
/// Route: /profile/admin-settings
/// Guard: admin-only (AS-090, AS-091).
class StudioSettingsHubScreen extends ConsumerWidget {
  const StudioSettingsHubScreen({super.key});

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

    return Scaffold(
      appBar: AppBar(),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(24, 0, 24, 32),
        children: [
          const Eyebrow('Admin'),
          const SizedBox(height: 10),
          DisplayTitle(l10n.studioSettingsHub),
          const SizedBox(height: 28),

          // ── Closed days ──────────────────────────────────────────────────
          _SettingsNavRow(
            icon: Icons.store_outlined,
            label: l10n.studioClosedDays,
            onTap: () => context.push('/profile/studio'),
          ),
          const SizedBox(height: 12),

          // ── Package types ────────────────────────────────────────────────
          _SettingsNavRow(
            icon: Icons.inventory_2_outlined,
            label: l10n.packageTypesTitle,
            onTap: () => context.push('/profile/package-types'),
          ),
        ],
      ),
    );
  }
}

// ── Nav row widget ────────────────────────────────────────────────────────────

class _SettingsNavRow extends StatelessWidget {
  const _SettingsNavRow({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: kInkElevated,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
        side: BorderSide(color: Theme.of(context).dividerColor),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(8),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          child: Row(
            children: [
              Icon(icon, size: 22, color: kVolt),
              const SizedBox(width: 14),
              Expanded(
                child: Text(
                  label,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ),
              const Icon(Icons.arrow_forward_ios_rounded,
                  size: 14, color: kMutedDark),
            ],
          ),
        ),
      ),
    );
  }
}
