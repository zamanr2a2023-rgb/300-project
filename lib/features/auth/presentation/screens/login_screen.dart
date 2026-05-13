import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/constants/app_spacing.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/mesh_background.dart';
import '../../../../core/widgets/paned_logo.dart';
import '../../../../core/widgets/paned_status_bar.dart';
import '../view_models/auth_view_model.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _email = TextEditingController();
  final _password = TextEditingController();
  final _name = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  var _mode = _AuthMode.login;

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    _name.dispose();
    super.dispose();
  }

  Future<void> _submit(AuthViewModel vm) async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    FocusScope.of(context).unfocus();
    if (_mode == _AuthMode.login) {
      await vm.signInWithEmail(_email.text, _password.text);
    } else {
      await vm.signUpWithEmail(_email.text, _password.text, _name.text.trim());
    }
  }

  void _toggleMode(AuthViewModel vm) {
    vm.clearError();
    setState(() {
      _mode = _mode == _AuthMode.login ? _AuthMode.signup : _AuthMode.login;
    });
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
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
        );
        vm.clearError();
      }
    });

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: MeshBackground(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const PanedStatusBar(),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(AppSpacing.lg, 8, AppSpacing.lg, AppSpacing.lg),
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
                  // Headline
                  Text(
                    _mode == _AuthMode.login
                        ? 'Welcome back!\nTime for a cuppa.'
                        : 'Welcome!\nLet\'s build a habit.',
                    style: GoogleFonts.playfairDisplay(
                      fontSize: 32,
                      fontWeight: FontWeight.w900,
                      color: AppColors.foreground,
                      height: 1.15,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    _mode == _AuthMode.login
                        ? 'Sign in to continue your streak.'
                        : 'Create an account to save your progress.',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 13,
                      color: AppColors.mutedFg,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.lg),

                  // Name field (signup only)
                  if (_mode == _AuthMode.signup) ...[
                    _FieldLabel('Name'),
                    const SizedBox(height: 6),
                    _PanedTextField(
                      controller: _name,
                      hint: 'Alex',
                      autofillHints: const [AutofillHints.name],
                      validator: (v) =>
                          (v == null || v.trim().length < 2) ? 'At least 2 characters' : null,
                    ),
                    const SizedBox(height: AppSpacing.sm),
                  ],

                  _FieldLabel('Email'),
                  const SizedBox(height: 6),
                  _PanedTextField(
                    controller: _email,
                    hint: 'you@example.com',
                    keyboardType: TextInputType.emailAddress,
                    autofillHints: const [AutofillHints.email],
                    validator: (v) =>
                        (v == null || !v.contains('@')) ? 'Enter a valid email' : null,
                  ),
                  const SizedBox(height: AppSpacing.sm),

                  _FieldLabel('Password'),
                  const SizedBox(height: 6),
                  _PanedTextField(
                    controller: _password,
                    hint: 'At least 6 characters',
                    obscureText: true,
                    autofillHints: const [AutofillHints.password],
                    validator: (v) =>
                        (v == null || v.length < 6) ? 'Min 6 characters' : null,
                  ),
                  const SizedBox(height: AppSpacing.md),

                  // Primary button
                  _PanedButton(
                    label: _mode == _AuthMode.login ? 'Log in' : 'Create account',
                    busy: busy,
                    onPressed: busy ? null : () => _submit(vm),
                  ),
                  const SizedBox(height: AppSpacing.md),

                  // OR divider
                  Row(
                    children: [
                      const Expanded(child: Divider()),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        child: Text(
                          'OR CONTINUE WITH',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                            color: AppColors.mutedFg,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ),
                      const Expanded(child: Divider()),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.md),

                  // Google button
                  _GoogleButton(
                    busy: busy,
                    onPressed: busy ? null : () => vm.signInWithGoogle(),
                  ),

                  // Toggle mode
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: AppSpacing.lg),
                    child: Center(
                      child: _mode == _AuthMode.login
                          ? _ToggleText(
                              prefix: 'New here? ',
                              action: 'Create account',
                              onTap: () => _toggleMode(vm),
                            )
                          : _ToggleText(
                              prefix: 'Already have an account? ',
                              action: 'Log in',
                              onTap: () => _toggleMode(vm),
                            ),
                    ),
                  ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

enum _AuthMode { login, signup }

class _FieldLabel extends StatelessWidget {
  const _FieldLabel(this.text);
  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(
      text.toUpperCase(),
      style: GoogleFonts.plusJakartaSans(
        fontSize: 10,
        fontWeight: FontWeight.w800,
        color: AppColors.mutedFg,
        letterSpacing: 1.2,
      ),
    );
  }
}

class _PanedTextField extends StatelessWidget {
  const _PanedTextField({
    required this.controller,
    required this.hint,
    this.obscureText = false,
    this.keyboardType,
    this.autofillHints,
    this.validator,
  });

  final TextEditingController controller;
  final String hint;
  final bool obscureText;
  final TextInputType? keyboardType;
  final Iterable<String>? autofillHints;
  final FormFieldValidator<String>? validator;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      obscureText: obscureText,
      keyboardType: keyboardType,
      autofillHints: autofillHints,
      validator: validator,
      style: GoogleFonts.plusJakartaSans(
        fontSize: 14,
        color: AppColors.foreground,
      ),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: GoogleFonts.plusJakartaSans(
          fontSize: 14,
          color: AppColors.mutedFg,
        ),
        filled: true,
        fillColor: AppColors.card,
        contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(100),
          borderSide: BorderSide(color: AppColors.leaf.withValues(alpha: 0.35), width: 1),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(100),
          borderSide: BorderSide(color: AppColors.leaf.withValues(alpha: 0.35), width: 1),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(100),
          borderSide: BorderSide(color: AppColors.primary, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(100),
          borderSide: const BorderSide(color: Color(0xFFC94A1E), width: 1.5),
        ),
      ),
    );
  }
}

class _PanedButton extends StatelessWidget {
  const _PanedButton({
    required this.label,
    required this.busy,
    this.onPressed,
  });

  final String label;
  final bool busy;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 52,
      child: FilledButton(
        onPressed: onPressed,
        style: FilledButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: AppColors.onPrimary,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(100)),
          elevation: 0,
        ),
        child: busy
            ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
              )
            : Text(
                label,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                ),
              ),
      ),
    );
  }
}

class _GoogleButton extends StatelessWidget {
  const _GoogleButton({required this.busy, this.onPressed});
  final bool busy;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 52,
      child: OutlinedButton.icon(
        onPressed: onPressed,
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.foreground,
          backgroundColor: AppColors.card,
          side: BorderSide(color: AppColors.leaf.withValues(alpha: 0.25), width: 1.5),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(100)),
        ),
        icon: Icon(Icons.mail_outlined, size: 18, color: AppColors.foreground),
        label: Text(
          'Continue with Google',
          style: GoogleFonts.plusJakartaSans(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: AppColors.foreground,
          ),
        ),
      ),
    );
  }
}

class _ToggleText extends StatelessWidget {
  const _ToggleText({
    required this.prefix,
    required this.action,
    required this.onTap,
  });

  final String prefix;
  final String action;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: RichText(
        text: TextSpan(
          style: GoogleFonts.plusJakartaSans(
            fontSize: 13,
            color: AppColors.mutedFg,
          ),
          children: [
            TextSpan(text: prefix),
            TextSpan(
              text: action,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: AppColors.primary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
