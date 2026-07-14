import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sportin_clone/app/kinetic.dart';
import 'package:sportin_clone/app/kinetic_effects.dart';
import 'package:sportin_clone/app/theme.dart';
import 'package:sportin_clone/features/auth/application/auth_providers.dart';
import 'package:sportin_clone/features/packages/application/packages_providers.dart';
import 'package:sportin_clone/features/packages/domain/package_type.dart';
import 'package:sportin_clone/l10n/app_localizations.dart';

/// Admin screen to create and view all package types.
///
/// Route: /profile/package-types
/// Guard: admin-only
class PackageTypesScreen extends ConsumerStatefulWidget {
  const PackageTypesScreen({super.key});

  @override
  ConsumerState<PackageTypesScreen> createState() =>
      _PackageTypesScreenState();
}

class _PackageTypesScreenState extends ConsumerState<PackageTypesScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _validityController = TextEditingController();
  final _creditCountController = TextEditingController();
  PackageKind _kind = PackageKind.duration;
  bool _submitting = false;

  @override
  void dispose() {
    _nameController.dispose();
    _validityController.dispose();
    _creditCountController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    final l10n = AppLocalizations.of(context);
    final messenger = ScaffoldMessenger.of(context);

    final name = _nameController.text.trim();
    final validity = int.tryParse(_validityController.text.trim()) ?? 0;
    final creditCount = _kind == PackageKind.credits
        ? int.tryParse(_creditCountController.text.trim())
        : null;

    setState(() => _submitting = true);
    final ok = await ref
        .read(packageAdminControllerProvider.notifier)
        .createType(PackageType(
          id: '',
          name: name,
          kind: _kind,
          validityDays: validity,
          creditCount: creditCount,
        ));
    if (!mounted) return;
    setState(() => _submitting = false);

    if (ok) {
      _nameController.clear();
      _validityController.clear();
      _creditCountController.clear();
      setState(() => _kind = PackageKind.duration);
      messenger.showSnackBar(
        SnackBar(content: Text('${l10n.addPackageType}: $name')),
      );
    } else {
      messenger.showSnackBar(SnackBar(content: Text(l10n.errorGeneric)));
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final me = ref.watch(appUserProvider).asData?.value;

    if (me == null || !me.isAdmin) {
      return Scaffold(
        appBar: AppBar(),
        body: Center(child: Text(l10n.notAuthorized)),
      );
    }

    final typesAsync = ref.watch(packageTypesProvider(false));

    return Scaffold(
      appBar: AppBar(),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(24, 0, 24, 32),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Eyebrow('Admin'),
            const SizedBox(height: 10),
            DisplayTitle(l10n.packageTypesTitle),
            const SizedBox(height: 28),

            // ── Add type form ────────────────────────────────────────────
            _AddTypeForm(
              formKey: _formKey,
              nameController: _nameController,
              validityController: _validityController,
              creditCountController: _creditCountController,
              kind: _kind,
              onKindChanged: (k) {
                if (k != null) setState(() => _kind = k);
              },
              onSubmit: _submitting ? null : _submit,
              submitting: _submitting,
            ),
            const SizedBox(height: 32),

            // ── All types list ───────────────────────────────────────────
            SectionHeader(l10n.packageTypesTitle),
            const SizedBox(height: 16),
            typesAsync.when(
              loading: () =>
                  const Center(child: CircularProgressIndicator()),
              error: (_, _) => Text(l10n.errorGeneric,
                  style: Theme.of(context).textTheme.bodyMedium),
              data: (types) {
                if (types.isEmpty) {
                  return Text(
                    l10n.noPackageTypesYet,
                    style: Theme.of(context).textTheme.bodyMedium,
                  );
                }
                return Column(
                  children: types.asMap().entries.map((e) {
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: Reveal(
                        index: e.key,
                        child: _PackageTypeCard(type: e.value),
                      ),
                    );
                  }).toList(),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

// ── Add type form card ────────────────────────────────────────────────────────

class _AddTypeForm extends StatelessWidget {
  const _AddTypeForm({
    required this.formKey,
    required this.nameController,
    required this.validityController,
    required this.creditCountController,
    required this.kind,
    required this.onKindChanged,
    required this.onSubmit,
    required this.submitting,
  });

  final GlobalKey<FormState> formKey;
  final TextEditingController nameController;
  final TextEditingController validityController;
  final TextEditingController creditCountController;
  final PackageKind kind;
  final ValueChanged<PackageKind?> onKindChanged;
  final VoidCallback? onSubmit;
  final bool submitting;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final isCredits = kind == PackageKind.credits;

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: kInkElevated,
        border: Border.all(color: kLineDark),
      ),
      child: Form(
        key: formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Kind selector
            Text(
              l10n.packageKind.toUpperCase(),
              style: GoogleFonts.interTight(
                color: kMutedDark,
                fontSize: 11,
                fontWeight: FontWeight.w700,
                letterSpacing: 1.6,
              ),
            ),
            const SizedBox(height: 8),
            SegmentedButton<PackageKind>(
              segments: [
                ButtonSegment(
                  value: PackageKind.duration,
                  label: Text(l10n.packageKindDuration),
                ),
                ButtonSegment(
                  value: PackageKind.credits,
                  label: Text(l10n.packageKindCredits),
                ),
              ],
              selected: {kind},
              onSelectionChanged: (s) => onKindChanged(s.first),
            ),
            const SizedBox(height: 16),

            // Package name
            KineticField(
              label: l10n.packageName,
              controller: nameController,
              textCapitalization: TextCapitalization.words,
              validator: (v) => (v == null || v.trim().isEmpty)
                  ? l10n.validationRequired
                  : null,
            ),
            const SizedBox(height: 16),

            // Validity days
            KineticField(
              label: l10n.validityDays,
              controller: validityController,
              keyboardType: TextInputType.number,
              validator: (v) {
                if (v == null || v.trim().isEmpty) {
                  return l10n.validationRequired;
                }
                final n = int.tryParse(v.trim());
                if (n == null || n <= 0) return l10n.validationRequired;
                return null;
              },
            ),

            // Credit count — only shown for credits kind
            if (isCredits) ...[
              const SizedBox(height: 16),
              KineticField(
                label: l10n.creditCount,
                controller: creditCountController,
                keyboardType: TextInputType.number,
                validator: (v) {
                  if (!isCredits) return null;
                  if (v == null || v.trim().isEmpty) {
                    return l10n.validationRequired;
                  }
                  final n = int.tryParse(v.trim());
                  if (n == null || n <= 0) return l10n.validationRequired;
                  return null;
                },
              ),
            ],

            const SizedBox(height: 24),
            VoltButton(
              label: l10n.addPackageType,
              icon: Icons.add,
              loading: submitting,
              onPressed: onSubmit,
            ),
          ],
        ),
      ),
    );
  }
}

// ── Package type card ─────────────────────────────────────────────────────────

class _PackageTypeCard extends StatelessWidget {
  const _PackageTypeCard({required this.type});

  final PackageType type;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final isCredits = type.kind == PackageKind.credits;
    final kindLabel =
        isCredits ? l10n.packageKindCredits : l10n.packageKindDuration;

    return Container(
      padding: const EdgeInsets.fromLTRB(16, 14, 12, 14),
      decoration: BoxDecoration(
        color: kInkElevated,
        border: Border.all(color: theme.dividerColor),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  type.name,
                  style: GoogleFonts.archivoBlack(
                    color: kOffWhite,
                    fontSize: 15,
                    height: 1.1,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  '${l10n.validityDays}: ${type.validityDays}'
                  '${isCredits && type.creditCount != null ? '  ·  ${l10n.creditCount}: ${type.creditCount}' : ''}',
                  style: theme.textTheme.bodyMedium,
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              VoltBadge(kindLabel, filled: type.active),
              if (!type.active) ...[
                const SizedBox(height: 4),
                Text(
                  'inactive',
                  style: GoogleFonts.interTight(
                    color: kMutedDark,
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 1.0,
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }
}
