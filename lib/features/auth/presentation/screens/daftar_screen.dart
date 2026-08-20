import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:tandur/core/network/api_exception.dart';
import 'package:tandur/core/theme/app_colors.dart';
import 'package:tandur/core/theme/app_spacing.dart';
import 'package:tandur/core/theme/app_typography.dart';
import 'package:tandur/features/auth/presentation/auth_controller.dart';
import 'package:tandur/features/auth/presentation/widgets/auth_widgets.dart';

import 'package:tandur/features/onboarding/data/onboarding_repository.dart';

/// Screen 7 — Daftar Akun (Registrasi Progresif).
/// Endpoint: POST /api/auth/signup
/// Request: { "fullName": "...", "email": "...", "password": "..." }
class DaftarScreen extends ConsumerStatefulWidget {
  const DaftarScreen({super.key});

  @override
  ConsumerState<DaftarScreen> createState() => _DaftarScreenState();
}

class _DaftarScreenState extends ConsumerState<DaftarScreen> {
  final _formKey = GlobalKey<FormState>();
  final _namaController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  final _emailFocus = FocusNode();
  final _passwordFocus = FocusNode();

  String? _serverError;

  // Field-level errors (dari validasi API)
  String? _namaError;
  String? _emailError;
  String? _passwordError;

  @override
  void dispose() {
    _namaController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _emailFocus.dispose();
    _passwordFocus.dispose();
    super.dispose();
  }

  /// Validasi sisi klien sesuai API_DOCS.md:
  /// - fullName: wajib ada
  /// - email: format valid
  /// - password: minimal 8 karakter
  bool _validateFields() {
    bool valid = true;
    setState(() {
      _namaError = null;
      _emailError = null;
      _passwordError = null;
      _serverError = null;
    });

    if (_namaController.text.trim().isEmpty) {
      setState(() => _namaError = 'Nama lengkap wajib diisi.');
      valid = false;
    }

    final email = _emailController.text.trim();
    if (email.isEmpty) {
      setState(() => _emailError = 'Email wajib diisi.');
      valid = false;
    } else if (!RegExp(r'^[\w.+-]+@[\w-]+\.[a-z]{2,}$').hasMatch(email)) {
      setState(() => _emailError = 'Format email tidak valid.');
      valid = false;
    }

    if (_passwordController.text.length < 8) {
      setState(() => _passwordError = 'Password minimal 8 karakter.');
      valid = false;
    }

    return valid;
  }

  /// Kirim form signup ke backend.
  Future<void> _daftar() async {
    if (!_validateFields()) return;

    final auth = ref.read(authControllerProvider.notifier);
    if (ref.read(authControllerProvider).isLoading) return;

    setState(() => _serverError = null);
    try {
      await auth.signup(
        fullName: _namaController.text.trim(),
        email: _emailController.text.trim(),
        password: _passwordController.text,
      );
      if (!mounted) return;

      // Cek apakah ada preferensi dari Onboarding
      final extra = GoRouterState.of(context).extra as Map<String, dynamic>?;
      if (extra != null && extra.containsKey('commodities')) {
        final commodities =
            (extra['commodities'] as List<dynamic>?)?.cast<String>() ?? [];
        final hasFarmed = extra['hasFarmed'] as bool? ?? false;
        try {
          final result = await ref
              .read(onboardingRepositoryProvider)
              .completeOnboarding(
                commodities: commodities,
                hasFarmed: hasFarmed,
              );
          if (!mounted) return;
          context.go(result.startRoute.isNotEmpty ? result.startRoute : '/kelas');
          return;
        } catch (_) {
          // Abaikan jika gagal simpan, tetap lanjut
        }
      }

      context.go('/kelas');
    } on ApiException catch (e) {
      if (!mounted) return;
      setState(() {
        if (e.isValidation && e.fieldErrors != null) {
          _namaError = e.fieldErrors!['fullName']?.join('\n');
          _emailError = e.fieldErrors!['email']?.join('\n');
          _passwordError = e.fieldErrors!['password']?.join('\n');
        }
        if (_namaError == null && _emailError == null && _passwordError == null) {
          _serverError = e.message;
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
            // Navigasi kembali
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
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const AuthHeader(
                        title: 'Buat akun Tandur.',
                        subtitle: 'Simpan progresmu dan lanjutkan kapan saja.',
                      ),
                      const SizedBox(height: AppSpacing.xxl),

                      // Nama lengkap
                      AuthTextField(
                        label: 'Nama Lengkap',
                        hint: 'Contoh: Reza Pratama',
                        controller: _namaController,
                        keyboardType: TextInputType.name,
                        errorText: _namaError,
                        textInputAction: TextInputAction.next,
                        onSubmitted: () => _emailFocus.requestFocus(),
                      ),
                      const SizedBox(height: AppSpacing.l),

                      // Email
                      AuthTextField(
                        label: 'Email',
                        hint: 'reza@mail.com',
                        controller: _emailController,
                        keyboardType: TextInputType.emailAddress,
                        errorText: _emailError,
                        focusNode: _emailFocus,
                        textInputAction: TextInputAction.next,
                        onSubmitted: () => _passwordFocus.requestFocus(),
                      ),
                      const SizedBox(height: AppSpacing.l),

                      // Password
                      PasswordField(
                        label: 'Password',
                        hint: 'Minimal 8 karakter',
                        controller: _passwordController,
                        errorText: _passwordError,
                        focusNode: _passwordFocus,
                        textInputAction: TextInputAction.done,
                        onSubmitted: _daftar,
                      ),
                      const SizedBox(height: AppSpacing.xl),

                      // Error server
                      if (_serverError != null) ...[
                        FormErrorMessage(message: _serverError!),
                        const SizedBox(height: AppSpacing.l),
                      ],

                      // Tombol daftar
                      PrimaryButton(
                        label: 'Daftar',
                        onPressed: _daftar,
                        isLoading: ref.watch(authControllerProvider).isLoading,
                      ),
                      const SizedBox(height: AppSpacing.l),

                      // Link masuk
                      Center(
                        child: TextButton(
                          onPressed: () {
                            final extra = GoRouterState.of(context).extra;
                            context.go('/masuk', extra: extra);
                          },
                          style: TextButton.styleFrom(
                            minimumSize: const Size(48, 48),
                          ),
                          child: RichText(
                            text: TextSpan(
                              style: AppTypography.isi.copyWith(
                                color: AppColors.tanahLemah,
                              ),
                              children: [
                                const TextSpan(text: 'Sudah punya akun? '),
                                TextSpan(
                                  text: 'Masuk',
                                  style: AppTypography.isiTebal.copyWith(
                                    color: AppColors.daun,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
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
