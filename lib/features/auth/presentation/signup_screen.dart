import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:sportin_clone/l10n/app_localizations.dart';

import '../application/auth_providers.dart';
import 'auth_error.dart';

class SignupScreen extends ConsumerStatefulWidget {
  const SignupScreen({super.key});

  @override
  ConsumerState<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends ConsumerState<SignupScreen> {
  final _formKey = GlobalKey<FormState>();
  final _name = TextEditingController();
  final _email = TextEditingController();
  final _phone = TextEditingController();
  final _password = TextEditingController();
  bool _consent = false;

  @override
  void dispose() {
    _name.dispose();
    _email.dispose();
    _phone.dispose();
    _password.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final l10n = AppLocalizations.of(context);
    final messenger = ScaffoldMessenger.of(context);
    if (!_formKey.currentState!.validate()) return;
    if (!_consent) {
      messenger.showSnackBar(
        SnackBar(content: Text(l10n.consentRequired)),
      );
      return;
    }
    await ref.read(authControllerProvider.notifier).signUp(
          email: _email.text.trim(),
          password: _password.text,
          displayName: _name.text.trim(),
          phone: _phone.text.trim(),
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
      key: const Key('signup-screen'),
      appBar: AppBar(title: Text(l10n.signupTitle)),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: _name,
                  textCapitalization: TextCapitalization.words,
                  decoration: InputDecoration(
                    labelText: l10n.displayNameLabel,
                    border: const OutlineInputBorder(),
                  ),
                  validator: (v) => (v == null || v.trim().isEmpty)
                      ? l10n.validationRequired
                      : null,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _email,
                  keyboardType: TextInputType.emailAddress,
                  decoration: InputDecoration(
                    labelText: l10n.emailLabel,
                    border: const OutlineInputBorder(),
                  ),
                  validator: (v) =>
                      isValidEmail(v) ? null : l10n.validationEmailInvalid,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _phone,
                  keyboardType: TextInputType.phone,
                  decoration: InputDecoration(
                    labelText: l10n.phoneLabel,
                    border: const OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _password,
                  obscureText: true,
                  decoration: InputDecoration(
                    labelText: l10n.passwordLabel,
                    border: const OutlineInputBorder(),
                  ),
                  validator: (v) => (v == null || v.length < 6)
                      ? l10n.validationPasswordShort
                      : null,
                ),
                const SizedBox(height: 8),
                CheckboxListTile(
                  value: _consent,
                  onChanged: isLoading
                      ? null
                      : (v) => setState(() => _consent = v ?? false),
                  controlAffinity: ListTileControlAffinity.leading,
                  contentPadding: EdgeInsets.zero,
                  title: Text(l10n.consentLabel,
                      style: Theme.of(context).textTheme.bodySmall),
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
                        : Text(l10n.signupButton),
                  ),
                ),
                const SizedBox(height: 8),
                TextButton(
                  onPressed: isLoading ? null : () => context.go('/login'),
                  child: Text(l10n.haveAccountPrompt),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
