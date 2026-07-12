import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:sportin_clone/app/kinetic.dart';
import 'package:sportin_clone/l10n/app_localizations.dart';

import '../application/auth_providers.dart';
import 'auth_error.dart';

class ResetPasswordScreen extends ConsumerStatefulWidget {
  const ResetPasswordScreen({super.key});

  @override
  ConsumerState<ResetPasswordScreen> createState() =>
      _ResetPasswordScreenState();
}

class _ResetPasswordScreenState extends ConsumerState<ResetPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _email = TextEditingController();

  @override
  void dispose() {
    _email.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final l10n = AppLocalizations.of(context);
    final messenger = ScaffoldMessenger.of(context);
    final router = GoRouter.of(context);
    if (!_formKey.currentState!.validate()) return;
    final ok = await ref
        .read(authControllerProvider.notifier)
        .sendPasswordReset(_email.text.trim());
    if (!mounted) return;
    if (ok) {
      messenger.showSnackBar(SnackBar(content: Text(l10n.resetSent)));
      router.go('/login');
    } else {
      final state = ref.read(authControllerProvider);
      messenger.showSnackBar(
        SnackBar(content: Text(authErrorMessage(l10n, state.error))),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final isLoading = ref.watch(authControllerProvider).isLoading;
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(24, 48, 24, 32),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Eyebrow(l10n.resetTitle),
                const SizedBox(height: 12),
                const DisplayTitle('Reset\nlozinke.'),
                const SizedBox(height: 32),
                KineticField(
                  label: l10n.emailLabel,
                  controller: _email,
                  hint: 'ime@primer.rs',
                  keyboardType: TextInputType.emailAddress,
                  validator: (v) =>
                      isValidEmail(v) ? null : l10n.validationEmailInvalid,
                ),
                const SizedBox(height: 20),
                VoltButton(
                  label: l10n.resetButton,
                  icon: Icons.send,
                  loading: isLoading,
                  onPressed: _submit,
                ),
                const SizedBox(height: 14),
                Center(
                  child: TextButton(
                    onPressed: isLoading ? null : () => context.go('/login'),
                    child: Text(l10n.haveAccountPrompt,
                        style: const TextStyle(fontWeight: FontWeight.w800)),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
