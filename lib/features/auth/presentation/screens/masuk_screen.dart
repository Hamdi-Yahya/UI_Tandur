import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:tandur/core/theme/app_colors.dart';
import 'package:tandur/core/theme/app_spacing.dart';
import 'package:tandur/core/theme/app_typography.dart';
import 'package:tandur/features/auth/presentation/widgets/auth_widgets.dart';

/// Mock service untuk simulasi signin.
/// Kontrak mengikuti API_DOCS.md:
///   POST /api/auth/signin
///   Error: { "msg": "Email atau password salah." }
class _MockSigninService {
  static Future<Map<String, dynamic>> signin({
    required String email,
    required String password,
  }) async {
    await Future.delayed(const Duration(milliseconds: 1000));

    // Simulasi: kredensial yang dikenal untuk preview
    if (email.trim().toLowerCase() == 'demo@tandur.id' && password == 'Demo1234') {
      return {'success': true};
    }
    // Semua kredensial lain: "Email atau password salah." (sesuai API_DOCS.md)
    return {'success': false, 'msg': 'Email atau password salah.'};
  }
}

/// Screen 8 — Masuk (Sign In).
/// Endpoint: POST /api/auth/signin
/// Request: { "email": "...", "password": "..." }
class MasukScreen extends StatefulWidget {
  const MasukScreen({super.key});

  @override
  State<MasukScreen> createState() => _MasukScreenState();
}

class _MasukScreenState extends State<MasukScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _passwordFocus = FocusNode();

  bool _isLoading = false;
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
    setState(() => _isLoading = true);

    final result = await _MockSigninService.signin(
      email: _emailController.text.trim(),
      password: _passwordController.text,
    );

    if (!mounted) return;
    setState(() => _isLoading = false);

    if (result['success'] == true) {
      context.go('/kelas');
    } else {
      setState(() => _credentialError = result['msg'] as String?);
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
                      isLoading: _isLoading,
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
                    _PreviewHint(),
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

/// Widget hint untuk demo — ditampilkan selama mock service aktif.
/// Dihapus setelah koneksi API production tersedia.
class _PreviewHint extends StatelessWidget {
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
            'MODE PREVIEW',
            style: AppTypography.label.copyWith(color: AppColors.padi),
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            'Gunakan: demo@tandur.id / Demo1234',
            style: AppTypography.kecil.copyWith(color: AppColors.tanahLemah),
          ),
        ],
      ),
    );
  }
}
