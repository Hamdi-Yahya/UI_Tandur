import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:tandur/core/network/api_exception.dart';
import 'package:tandur/core/theme/app_colors.dart';
import 'package:tandur/core/theme/app_spacing.dart';
import 'package:tandur/core/theme/app_typography.dart';
import 'package:tandur/features/auth/data/auth_repository.dart';
import 'package:tandur/features/auth/presentation/widgets/auth_widgets.dart';

/// Screen 9 — Lupa Password.
/// Endpoint: POST /api/auth/forgot-password
/// Request: { "email": "..." }
/// Catatan: API tidak mengungkap apakah email terdaftar (sesuai API_DOCS).
class LupaPasswordScreen extends ConsumerStatefulWidget {
  const LupaPasswordScreen({super.key});

  @override
  ConsumerState<LupaPasswordScreen> createState() => _LupaPasswordScreenState();
}

class _LupaPasswordScreenState extends ConsumerState<LupaPasswordScreen> {
  final _emailController = TextEditingController();

  bool _isLoading = false;
  bool _berhasilTerkirim = false;
  String? _emailError;
  String? _serverError;

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  bool _validateEmail() {
    final email = _emailController.text.trim();
    setState(() => _emailError = null);

    if (email.isEmpty) {
      setState(() => _emailError = 'Email wajib diisi.');
      return false;
    }
    if (!RegExp(r'^[\w.+-]+@[\w-]+\.[a-z]{2,}$').hasMatch(email)) {
      setState(() => _emailError = 'Format email tidak valid.');
      return false;
    }
    return true;
  }

  Future<void> _kirimTautan() async {
    if (!_validateEmail()) return;
    setState(() {
      _isLoading = true;
      _serverError = null;
    });

    try {
      await ref.read(authRepositoryProvider).forgotPassword(
            email: _emailController.text.trim(),
          );
      if (!mounted) return;
      setState(() {
        _isLoading = false;
        _berhasilTerkirim = true;
      });
    } on ApiException catch (e) {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
        _emailError = e.fieldErrors?['email']?.join('\n');
        if (_emailError == null) {
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
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 300),
                  child: _berhasilTerkirim
                      ? _SuccessState(email: _emailController.text.trim())
                      : _FormState(
                          emailController: _emailController,
                          emailError: _emailError,
                          serverError: _serverError,
                          isLoading: _isLoading,
                          onKirim: _kirimTautan,
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

/// State form — input email dan tombol kirim tautan.
class _FormState extends StatelessWidget {
  final TextEditingController emailController;
  final String? emailError;
  final String? serverError;
  final bool isLoading;
  final VoidCallback onKirim;

  const _FormState({
    required this.emailController,
    required this.emailError,
    required this.serverError,
    required this.isLoading,
    required this.onKirim,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      key: const ValueKey('form'),
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const AuthHeader(
          title: 'Lupa password?',
          subtitle: 'Masukkan emailmu, kami kirimkan tautan untuk mengaturnya ulang.',
        ),
        const SizedBox(height: AppSpacing.xxl),

        AuthTextField(
          label: 'Email',
          hint: 'reza@mail.com',
          controller: emailController,
          keyboardType: TextInputType.emailAddress,
          errorText: emailError,
          textInputAction: TextInputAction.done,
          onSubmitted: onKirim,
        ),
        const SizedBox(height: AppSpacing.xl),

        if (serverError != null) ...[
          FormErrorMessage(message: serverError!),
          const SizedBox(height: AppSpacing.l),
        ],

        PrimaryButton(
          label: 'Kirim Tautan',
          onPressed: onKirim,
          isLoading: isLoading,
        ),
      ],
    );
  }
}

/// State sukses — menampilkan konfirmasi tanpa mengungkap apakah email terdaftar.
/// Sesuai respons API: "Kalau email terdaftar, kami kirim tautan reset."
class _SuccessState extends StatelessWidget {
  final String email;
  const _SuccessState({required this.email});

  @override
  Widget build(BuildContext context) {
    return Column(
      key: const ValueKey('success'),
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 52,
          height: 52,
          decoration: BoxDecoration(
            color: AppColors.daunSamar,
            borderRadius: BorderRadius.circular(AppRadius.kecil),
          ),
          child: const Icon(Icons.mark_email_read_outlined, color: AppColors.daun, size: 28),
        ),
        const SizedBox(height: AppSpacing.l),
        Text(
          'Cek emailmu.',
          style: AppTypography.tampilanSedang.copyWith(color: AppColors.tanah),
        ),
        const SizedBox(height: AppSpacing.s),
        // Sesuai pesan API: tidak menyebutkan apakah email terdaftar
        Text(
          'Kalau $email terdaftar, kami sudah kirimkan tautan untuk mengatur ulang passwordmu.',
          style: AppTypography.isi.copyWith(color: AppColors.tanahLemah),
        ),
        const SizedBox(height: AppSpacing.xl),
        Text(
          'Tidak menerima email? Periksa folder spam atau tunggu beberapa menit.',
          style: AppTypography.kecil.copyWith(color: AppColors.tanahSamar),
        ),
        const SizedBox(height: AppSpacing.xxl),
        SecondaryButton(
          label: 'Kembali ke Masuk',
          onPressed: () => context.go('/masuk'),
        ),
      ],
    );
  }
}
