import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:tandur/core/theme/app_colors.dart';
import 'package:tandur/core/theme/app_spacing.dart';
import 'package:tandur/core/theme/app_typography.dart';
import 'package:tandur/features/auth/presentation/widgets/auth_widgets.dart';

/// Mock service untuk simulasi reset password.
/// Kontrak mengikuti API_DOCS.md:
///   POST /api/auth/reset-password
///   Request: { "token": "...", "newPassword": "...", "confirmPassword": "..." }
///   Success: { "msg": "Password diubah. Silakan masuk." }
///   Error token: { "msg": { "token": ["Tautan tidak valid atau kedaluwarsa."] } }
///   Error mismatch: { "msg": { "confirmPassword": ["Konfirmasi tidak cocok."] } }
class _MockResetService {
  static Future<Map<String, dynamic>> reset({
    required String token,
    required String newPassword,
    required String confirmPassword,
  }) async {
    await Future.delayed(const Duration(milliseconds: 1200));

    // Simulasi token kedaluwarsa
    if (token == 'expired') {
      return {
        'success': false,
        'errors': {'token': 'Tautan tidak valid atau kedaluwarsa.'},
      };
    }

    // Simulasi mismatch (normalnya dicek di client, tapi server juga menjaganya)
    if (newPassword != confirmPassword) {
      return {
        'success': false,
        'errors': {'confirmPassword': 'Konfirmasi tidak cocok.'},
      };
    }

    return {'success': true, 'msg': 'Password diubah. Silakan masuk.'};
  }
}

/// Screen 10 — Atur Ulang Password.
/// Endpoint: POST /api/auth/reset-password
/// Request: { "token": "...", "newPassword": "...", "confirmPassword": "..." }
///
/// Token diterima via deep link / URL param (simulasi dengan field input untuk demo).
class AturUlangPasswordScreen extends StatefulWidget {
  /// Token dari deep link (opsional, di preview diisi manual).
  final String? token;

  const AturUlangPasswordScreen({super.key, this.token});

  @override
  State<AturUlangPasswordScreen> createState() => _AturUlangPasswordScreenState();
}

class _AturUlangPasswordScreenState extends State<AturUlangPasswordScreen> {
  final _passwordController = TextEditingController();
  final _konfirmasiController = TextEditingController();
  final _konfirmasiFocus = FocusNode();

  bool _isLoading = false;
  bool _berhasil = false;

  String? _passwordError;
  String? _konfirmasiError;
  String? _tokenError;   // Token tidak valid / kedaluwarsa
  String? _serverError;

  @override
  void dispose() {
    _passwordController.dispose();
    _konfirmasiController.dispose();
    _konfirmasiFocus.dispose();
    super.dispose();
  }

  /// Validasi sisi klien:
  /// - minimal 8 karakter (sesuai aturan signup yang sama)
  /// - konfirmasi harus cocok
  bool _validateFields() {
    bool valid = true;
    setState(() {
      _passwordError = null;
      _konfirmasiError = null;
      _tokenError = null;
      _serverError = null;
    });

    if (_passwordController.text.length < 8) {
      setState(() => _passwordError = 'Password minimal 8 karakter.');
      valid = false;
    }

    if (_konfirmasiController.text != _passwordController.text) {
      setState(() => _konfirmasiError = 'Konfirmasi tidak cocok.');
      valid = false;
    }

    return valid;
  }

  Future<void> _simpan() async {
    if (!_validateFields()) return;
    setState(() => _isLoading = true);

    // Gunakan token dari deep link jika ada, atau 'demo-token' untuk preview
    final token = widget.token ?? 'demo-token';

    final result = await _MockResetService.reset(
      token: token,
      newPassword: _passwordController.text,
      confirmPassword: _konfirmasiController.text,
    );

    if (!mounted) return;
    setState(() => _isLoading = false);

    if (result['success'] == true) {
      setState(() => _berhasil = true);
    } else {
      final errors = result['errors'] as Map<String, dynamic>?;
      setState(() {
        _tokenError = errors?['token'] as String?;
        _konfirmasiError = errors?['confirmPassword'] as String?;
        if (_tokenError == null && _konfirmasiError == null) {
          _serverError = 'Terjadi masalah. Coba lagi dalam beberapa saat.';
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
                  child: _berhasil
                      ? _SuccessState(onMasuk: () => context.go('/masuk'))
                      : _FormState(
                          tokenError: _tokenError,
                          passwordController: _passwordController,
                          konfirmasiController: _konfirmasiController,
                          konfirmasiFocus: _konfirmasiFocus,
                          passwordError: _passwordError,
                          konfirmasiError: _konfirmasiError,
                          serverError: _serverError,
                          isLoading: _isLoading,
                          onSimpan: _simpan,
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

/// State form reset password.
class _FormState extends StatelessWidget {
  final String? tokenError;
  final TextEditingController passwordController;
  final TextEditingController konfirmasiController;
  final FocusNode konfirmasiFocus;
  final String? passwordError;
  final String? konfirmasiError;
  final String? serverError;
  final bool isLoading;
  final VoidCallback onSimpan;

  const _FormState({
    required this.tokenError,
    required this.passwordController,
    required this.konfirmasiController,
    required this.konfirmasiFocus,
    required this.passwordError,
    required this.konfirmasiError,
    required this.serverError,
    required this.isLoading,
    required this.onSimpan,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      key: const ValueKey('form'),
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const AuthHeader(
          title: 'Buat password baru.',
          subtitle: 'Pastikan passwordmu kuat dan mudah diingat.',
        ),
        const SizedBox(height: AppSpacing.xxl),

        // Error token — ditampilkan paling atas karena memblokir seluruh form
        if (tokenError != null) ...[
          FormErrorMessage(message: tokenError!),
          const SizedBox(height: AppSpacing.l),
          SecondaryButton(
            label: 'Minta tautan baru',
            onPressed: () => context.go('/lupa-password'),
          ),
        ] else ...[
          // Password baru
          PasswordField(
            label: 'Password Baru',
            hint: 'Minimal 8 karakter',
            controller: passwordController,
            errorText: passwordError,
            textInputAction: TextInputAction.next,
            onSubmitted: () => konfirmasiFocus.requestFocus(),
          ),
          const SizedBox(height: AppSpacing.l),

          // Konfirmasi password
          PasswordField(
            label: 'Konfirmasi Password',
            hint: 'Ulangi password baru',
            controller: konfirmasiController,
            errorText: konfirmasiError,
            focusNode: konfirmasiFocus,
            textInputAction: TextInputAction.done,
            onSubmitted: onSimpan,
          ),
          const SizedBox(height: AppSpacing.xl),

          if (serverError != null) ...[
            FormErrorMessage(message: serverError!),
            const SizedBox(height: AppSpacing.l),
          ],

          PrimaryButton(
            label: 'Simpan Password',
            onPressed: onSimpan,
            isLoading: isLoading,
          ),
        ],
      ],
    );
  }
}

/// State sukses — pesan dari API: "Password diubah. Silakan masuk."
class _SuccessState extends StatelessWidget {
  final VoidCallback onMasuk;
  const _SuccessState({required this.onMasuk});

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
          child: const Icon(Icons.lock_reset_outlined, color: AppColors.daun, size: 28),
        ),
        const SizedBox(height: AppSpacing.l),
        Text(
          'Password berhasil diubah.',
          style: AppTypography.tampilanSedang.copyWith(color: AppColors.tanah),
        ),
        const SizedBox(height: AppSpacing.s),
        // Sesuai pesan API: "Password diubah. Silakan masuk."
        Text(
          'Silakan masuk dengan password barumu.',
          style: AppTypography.isi.copyWith(color: AppColors.tanahLemah),
        ),
        const SizedBox(height: AppSpacing.xxl),
        PrimaryButton(label: 'Masuk Sekarang', onPressed: onMasuk),
      ],
    );
  }
}
