import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:tandur/core/network/api_exception.dart';
import 'package:tandur/core/theme/app_colors.dart';
import 'package:tandur/core/theme/app_spacing.dart';
import 'package:tandur/core/theme/app_typography.dart';
import 'package:tandur/features/auth/presentation/auth_controller.dart';
import 'package:tandur/features/auth/presentation/widgets/auth_widgets.dart';

/// Screen 8 — Masuk (Sign In).
/// Endpoint: POST /api/auth/signin
/// Request: { "email": "...", "password": "..." }
class MasukScreen extends ConsumerStatefulWidget {
  const MasukScreen({super.key});

  @override
  ConsumerState<MasukScreen> createState() => _MasukScreenState();
}

class _MasukScreenState extends ConsumerState<MasukScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _passwordFocus = FocusNode();

  String? _emailError;
  String? _credentialError; // "Email atau password salah."

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _passwordFocus.dispose();
    super.dispose();
  }

  /// Validasi minimal sebelum mengirim ke server.
  bool _validateFields() {
    bool valid = true;
    setState(() {
      _emailError = null;
      _credentialError = null;
    });

    final email = _emailController.text.trim();
    if (email.isEmpty) {
      setState(() => _emailError = 'Email wajib diisi.');
      valid = false;
    } else if (!RegExp(r'^[\w.+-]+@[\w-]+\.[a-z]{2,}$').hasMatch(email)) {
      setState(() => _emailError = 'Format email tidak valid.');
      valid = false;
    }

    if (_passwordController.text.isEmpty) {
      setState(() => _credentialError = 'Password wajib diisi.');
      valid = false;
    }

    return valid;
  }

  Future<void> _masuk() async {
    if (!_validateFields()) return;

    final auth = ref.read(authControllerProvider.notifier);
    final authState = ref.read(authControllerProvider);
    if (authState.isLoading) return;

    setState(() => _credentialError = null);
    try {
      await auth.signin(
        email: _emailController.text.trim(),
        password: _passwordController.text,
      );
      if (!mounted) return;
      final isNewUser = ref.read(authControllerProvider).isNewUser;
      context.go(isNewUser ? '/onboarding' : '/kelas');
    } on ApiException catch (e) {
      if (!mounted) return;
      setState(() {
        if (e.isValidation && e.fieldErrors?['email'] != null) {
          _emailError = e.fieldErrors!['email']!.join('\n');
        } else {
          _credentialError = e.message;
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.embun,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.s,
                vertical: AppSpacing.xs,
              ),
              child: Align(
                alignment: Alignment.centerLeft,
                child: IconButton(
                  icon: const Icon(Icons.arrow_back),
                  color: AppColors.tanah,
                  onPressed: () => context.pop(),
                  tooltip: 'Kembali',
                  padding: const EdgeInsets.all(12),
                  constraints: const BoxConstraints(minWidth: 48, minHeight: 48),
                ),
              ),
            ),

            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.l, AppSpacing.m, AppSpacing.l, AppSpacing.xxl,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const AuthHeader(
                      title: 'Selamat datang kembali.',
                      subtitle: 'Masuk untuk melanjutkan progresmu.',
                    ),
                    const SizedBox(height: AppSpacing.xxl),

                    // Email
                    AuthTextField(
                      label: 'Email',
                      hint: 'reza@mail.com',
                      controller: _emailController,
                      keyboardType: TextInputType.emailAddress,
                      errorText: _emailError,
                      textInputAction: TextInputAction.next,
                      onSubmitted: () => _passwordFocus.requestFocus(),
                    ),
                    const SizedBox(height: AppSpacing.l),

                    // Password
                    PasswordField(
                      label: 'Password',
                      hint: 'Masukkan passwordmu',
                      controller: _passwordController,
                      focusNode: _passwordFocus,
                      textInputAction: TextInputAction.done,
                      onSubmitted: _masuk,
                    ),
                    const SizedBox(height: AppSpacing.s),

                    // Lupa password
                    Align(
                      alignment: Alignment.centerRight,
                      child: TextButton(
                        onPressed: () => context.go('/lupa-password'),
                        style: TextButton.styleFrom(
                          minimumSize: const Size(48, 44),
                          foregroundColor: AppColors.daun,
                        ),
                        child: Text(
                          'Lupa password?',
                          style: AppTypography.kecil.copyWith(color: AppColors.daun),
                        ),
                      ),
                    ),
                    const SizedBox(height: AppSpacing.l),

                    // Error kredensial (dari API: "Email atau password salah.")
                    if (_credentialError != null) ...[
                      FormErrorMessage(message: _credentialError!),
                      const SizedBox(height: AppSpacing.l),
                    ],

                    // Tombol masuk
                    PrimaryButton(
                      label: 'Masuk',
                      onPressed: _masuk,
                      isLoading: ref.watch(authControllerProvider).isLoading,
                    ),
                    const SizedBox(height: AppSpacing.l),

                    // Link ke daftar
                    Center(
                      child: TextButton(
                        onPressed: () => context.go('/daftar'),
                        style: TextButton.styleFrom(minimumSize: const Size(48, 48)),
                        child: RichText(
                          text: TextSpan(
                            style: AppTypography.isi.copyWith(color: AppColors.tanahLemah),
                            children: [
                              const TextSpan(text: 'Belum punya akun? '),
                              TextSpan(
                                text: 'Daftar',
                                style: AppTypography.isiTebal.copyWith(color: AppColors.daun),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),

                    // Hint preview (hanya untuk development)
                    const SizedBox(height: AppSpacing.xl),
                    const _PreviewHint(),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Widget hint untuk demo — ditampilkan selama mode development.
class _PreviewHint extends StatelessWidget {
  const _PreviewHint();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.m),
      decoration: BoxDecoration(
        color: AppColors.padiSamar,
        borderRadius: BorderRadius.circular(AppRadius.kecil),
        border: Border.all(color: AppColors.padi.withValues(alpha: 0.4)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'BACKEND TANDUR',
            style: AppTypography.label.copyWith(color: AppColors.padi),
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            'Masuk memakai akun dari POST /api/auth/signin. Pastikan backend berjalan.',
            style: AppTypography.kecil.copyWith(color: AppColors.tanahLemah),
          ),
        ],
      ),
    );
  }
}
