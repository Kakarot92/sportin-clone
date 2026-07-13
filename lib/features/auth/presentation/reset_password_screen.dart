import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:sportin_clone/app/kinetic.dart';
import 'package:sportin_clone/app/kinetic_effects.dart';
import 'package:sportin_clone/app/theme.dart';
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
      backgroundColor: kInk,
      body: Stack(
        children: [
          // ── Speed-lines texture ──────────────────────────────────────
          const Positioned.fill(
            child: SpeedLines(density: 12, opacity: 0.4),
          ),
          // ── Ghost brand word at top-left ──────────────────────────────
          Positioned(
            top: -30,
            left: -20,
            child: IgnorePointer(
              child: ShaderMask(
                shaderCallback: (rect) => LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    kVolt.withValues(alpha: 0.25),
                    kVolt.withValues(alpha: 0.04),
                  ],
                ).createShader(rect),
                child: const GhostText(
                  'RESET',
                  size: 90,
                  color: Colors.white,
                  strokeWidth: 1.2,
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
                    padding: const EdgeInsets.fromLTRB(24, 48, 24, 32),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Reveal(
                            index: 0,
                            child: Eyebrow(l10n.resetTitle),
                          ),
                          const SizedBox(height: 12),
                          Reveal(
                            index: 1,
                            child: const DisplayTitle('Reset\nlozinke.'),
                          ),
                          const SizedBox(height: 32),
                          Reveal(
                            index: 2,
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
                          const SizedBox(height: 20),
                          Reveal(
                            index: 3,
                            child: VoltButton(
                              label: l10n.resetButton,
                              icon: Icons.send,
                              loading: isLoading,
                              onPressed: _submit,
                            ),
                          ),
                          const SizedBox(height: 14),
                          Reveal(
                            index: 4,
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
