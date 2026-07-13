import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:sportin_clone/app/kinetic.dart';
import 'package:sportin_clone/app/kinetic_effects.dart';
import 'package:sportin_clone/app/theme.dart';
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
      messenger.showSnackBar(SnackBar(content: Text(l10n.consentRequired)));
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
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final isLoading = ref.watch(authControllerProvider).isLoading;
    return Scaffold(
      key: const Key('signup-screen'),
      backgroundColor: kInk,
      body: Stack(
        children: [
          // ── Speed-lines texture ──────────────────────────────────────
          const Positioned.fill(
            child: SpeedLines(density: 14, opacity: 0.45),
          ),
          // ── Ghost brand word ─────────────────────────────────────────
          Positioned(
            top: -20,
            right: -16,
            child: IgnorePointer(
              child: ShaderMask(
                shaderCallback: (rect) => LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    kVolt.withValues(alpha: 0.06),
                    kVolt.withValues(alpha: 0.30),
                  ],
                ).createShader(rect),
                child: const GhostText(
                  'NALOG',
                  size: 100,
                  color: Colors.white,
                  strokeWidth: 1.4,
                ),
              ),
            ),
          ),
          // ── Form content ─────────────────────────────────────────────
          SafeArea(
            child: SingleChildScrollView(
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 520),
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          // Back button row
                          Reveal(
                            index: 0,
                            dy: -14,
                            child: Align(
                              alignment: Alignment.centerLeft,
                              child: IconButton(
                                icon: const Icon(Icons.arrow_back),
                                onPressed: () => context.go('/login'),
                              ),
                            ),
                          ),
                          const SizedBox(height: 8),
                          Reveal(
                            index: 1,
                            child: const Eyebrow('Registracija'),
                          ),
                          const SizedBox(height: 12),
                          Reveal(
                            index: 2,
                            child: const DisplayTitle('Napravi\nnalog.'),
                          ),
                          const SizedBox(height: 32),
                          Reveal(
                            index: 3,
                            child: KineticField(
                              label: l10n.displayNameLabel,
                              controller: _name,
                              textCapitalization: TextCapitalization.words,
                              validator: (v) => (v == null || v.trim().isEmpty)
                                  ? l10n.validationRequired
                                  : null,
                            ),
                          ),
                          const SizedBox(height: 18),
                          Reveal(
                            index: 4,
                            child: KineticField(
                              label: l10n.emailLabel,
                              controller: _email,
                              hint: 'ime@primer.rs',
                              keyboardType: TextInputType.emailAddress,
                              validator: (v) => isValidEmail(v)
                                  ? null
                                  : l10n.validationEmailInvalid,
                            ),
                          ),
                          const SizedBox(height: 18),
                          Reveal(
                            index: 5,
                            child: KineticField(
                              label: l10n.phoneLabel,
                              controller: _phone,
                              keyboardType: TextInputType.phone,
                            ),
                          ),
                          const SizedBox(height: 18),
                          Reveal(
                            index: 6,
                            child: KineticField(
                              label: l10n.passwordLabel,
                              controller: _password,
                              obscure: true,
                              validator: (v) => (v == null || v.length < 6)
                                  ? l10n.validationPasswordShort
                                  : null,
                            ),
                          ),
                          const SizedBox(height: 16),
                          Reveal(
                            index: 7,
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Checkbox(
                                  value: _consent,
                                  activeColor: kVolt,
                                  checkColor: kInk,
                                  onChanged: isLoading
                                      ? null
                                      : (v) =>
                                          setState(() => _consent = v ?? false),
                                ),
                                Expanded(
                                  child: Padding(
                                    padding: const EdgeInsets.only(top: 12),
                                    child: Text(
                                      l10n.consentLabel,
                                      style: Theme.of(context)
                                          .textTheme
                                          .bodyMedium,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 16),
                          Reveal(
                            index: 8,
                            child: VoltButton(
                              label: l10n.signupButton,
                              icon: Icons.bolt,
                              loading: isLoading,
                              onPressed: _submit,
                            ),
                          ),
                          const SizedBox(height: 14),
                          Reveal(
                            index: 9,
                            child: Center(
                              child: TextButton(
                                onPressed:
                                    isLoading ? null : () => context.go('/login'),
                                child: Text(
                                  l10n.haveAccountPrompt,
                                  style: const TextStyle(
                                      fontWeight: FontWeight.w800),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
