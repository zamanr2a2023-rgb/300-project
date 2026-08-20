import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/constants/app_spacing.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/mesh_background.dart';
import '../../../../core/widgets/paned_logo.dart';
import '../../../../router/routes.dart';
import '../view_models/auth_view_model.dart';
import '../widgets/auth_form_widgets.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _email = TextEditingController();
  final _password = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  Future<void> _submit(AuthViewModel vm) async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    FocusScope.of(context).unfocus();
    await vm.signInWithEmail(_email.text, _password.text);
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authViewModelProvider);
    final vm = ref.read(authViewModelProvider.notifier);
    final busy = authState.isLoading;

    ref.listen<AuthState>(authViewModelProvider, (_, next) {
      if (next.hasError) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(next.errorMessage!),
            backgroundColor: AppColors.accent,
            behavior: SnackBarBehavior.floating,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
        );
        vm.clearError();
      }
    });

    return Scaffold(
      backgroundColor: AppColors.background,
      body: MeshBackground(
        child: SafeArea(
          child: SingleChildScrollView(
            keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.lg,
              AppSpacing.sm,
              AppSpacing.lg,
              AppSpacing.lg,
            ),
            child: Form(
                  key: _formKey,
                  child: AutofillGroup(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        const Align(
                          alignment: Alignment.centerLeft,
                          child: PanedLogo(size: 56),
                        ),
                        const SizedBox(height: 20),
                        Text(
                          'Welcome back!\nTime for a cuppa.',
                          style: GoogleFonts.playfairDisplay(
                            fontSize: 32,
                            fontWeight: FontWeight.w900,
                            color: AppColors.foreground,
                            height: 1.15,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          'Sign in to continue your streak.',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 13,
                            color: AppColors.mutedFg,
                          ),
                        ),
                        const SizedBox(height: AppSpacing.lg),
                        const AuthFieldLabel('Email'),
                        const SizedBox(height: 6),
                        AuthTextField(
                          controller: _email,
                          hint: 'you@example.com',
                          keyboardType: TextInputType.emailAddress,
                          autofillHints: const [AutofillHints.email],
                          validator: (v) {
                            final value = v?.trim() ?? '';
                            if (value.isEmpty) return 'Enter your email';
                            if (!value.contains('@') || !value.contains('.')) {
                              return 'Enter a valid email';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: AppSpacing.sm),
                        const AuthFieldLabel('Password'),
                        const SizedBox(height: 6),
                        AuthTextField(
                          controller: _password,
                          hint: 'Your password',
                          obscureText: true,
                          autofillHints: const [AutofillHints.password],
                          validator: (v) {
                            if (v == null || v.isEmpty) {
                              return 'Enter your password';
                            }
                            if (v.length < 6) return 'Min 6 characters';
                            return null;
                          },
                        ),
                        const SizedBox(height: AppSpacing.md),
                        AuthPrimaryButton(
                          label: 'Log in',
                          busy: busy,
                          onPressed: busy ? null : () => _submit(vm),
                        ),
                        Padding(
                          padding:
                              const EdgeInsets.symmetric(vertical: AppSpacing.lg),
                          child: Center(
                            child: AuthToggleText(
                              prefix: 'New here? ',
                              action: 'Create account',
                              onTap: busy ? () {} : () => context.push(AppRoute.signup),
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
    );
  }
}
