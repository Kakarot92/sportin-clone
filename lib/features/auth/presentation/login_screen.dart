import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:sportin_clone/app/kinetic.dart';
import 'package:sportin_clone/l10n/app_localizations.dart';

import '../application/auth_providers.dart';
import 'auth_error.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _email = TextEditingController();
  final _password = TextEditingController();

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final l10n = AppLocalizations.of(context);
    final messenger = ScaffoldMessenger.of(context);
    if (!_formKey.currentState!.validate()) return;
    await ref.read(authControllerProvider.notifier).signIn(
          email: _email.text.trim(),
          password: _password.text,
        );
    final state = ref.read(authControllerProvider);
    if (state.hasError && mounted) {
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
      key: const Key('login-screen'),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(24, 48, 24, 32),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Eyebrow('Prijava'),
                const SizedBox(height: 12),
                const DisplayTitle('Tvoj trening.\nTvoj tempo.'),
                const SizedBox(height: 14),
                Text(l10n.homeSubtitle,
                    style: Theme.of(context).textTheme.bodyMedium),
                const SizedBox(height: 36),
                KineticField(
                  label: l10n.emailLabel,
                  controller: _email,
                  hint: 'ime@primer.rs',
                  keyboardType: TextInputType.emailAddress,
                  validator: (v) =>
                      isValidEmail(v) ? null : l10n.validationEmailInvalid,
                ),
                const SizedBox(height: 20),
                KineticField(
                  label: l10n.passwordLabel,
                  controller: _password,
                  obscure: true,
                  validator: (v) => (v == null || v.isEmpty)
                      ? l10n.validationRequired
                      : null,
                ),
                const SizedBox(height: 8),
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: isLoading ? null : () => context.go('/reset'),
                    child: Text(l10n.forgotPassword),
                  ),
                ),
                const SizedBox(height: 16),
                VoltButton(
                  label: l10n.loginButton,
                  icon: Icons.bolt,
                  loading: isLoading,
                  onPressed: _submit,
                ),
                const SizedBox(height: 18),
                Center(
                  child: TextButton(
                    onPressed: isLoading ? null : () => context.go('/signup'),
                    child: Text(
                      l10n.noAccountPrompt,
                      style: const TextStyle(fontWeight: FontWeight.w800),
                    ),
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
