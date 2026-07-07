import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
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
    // On success, the router redirect navigates to /home automatically.
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final isLoading = ref.watch(authControllerProvider).isLoading;
    return Scaffold(
      key: const Key('login-screen'),
      appBar: AppBar(title: Text(l10n.loginTitle)),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.fitness_center,
                    size: 64, color: Theme.of(context).colorScheme.primary),
                const SizedBox(height: 24),
                TextFormField(
                  controller: _email,
                  keyboardType: TextInputType.emailAddress,
                  autofillHints: const [AutofillHints.email],
                  decoration: InputDecoration(
                    labelText: l10n.emailLabel,
                    border: const OutlineInputBorder(),
                  ),
                  validator: (v) =>
                      isValidEmail(v) ? null : l10n.validationEmailInvalid,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _password,
                  obscureText: true,
                  decoration: InputDecoration(
                    labelText: l10n.passwordLabel,
                    border: const OutlineInputBorder(),
                  ),
                  validator: (v) => (v == null || v.isEmpty)
                      ? l10n.validationRequired
                      : null,
                ),
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: isLoading ? null : () => context.go('/reset'),
                    child: Text(l10n.forgotPassword),
                  ),
                ),
                const SizedBox(height: 8),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton(
                    onPressed: isLoading ? null : _submit,
                    child: isLoading
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : Text(l10n.loginButton),
                  ),
                ),
                const SizedBox(height: 8),
                TextButton(
                  onPressed: isLoading ? null : () => context.go('/signup'),
                  child: Text(l10n.noAccountPrompt),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
