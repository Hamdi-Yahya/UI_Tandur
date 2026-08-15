import 'package:flutter/material.dart';
import 'package:tandur/core/theme/app_colors.dart';
import 'package:tandur/core/theme/app_spacing.dart';
import 'package:tandur/core/theme/app_typography.dart';
import 'package:tandur/core/theme/app_motion.dart';

/// Tombol utama Tandur — tinggi 52, sudut penuh, warna daun.
/// Mendukung state loading (spinner mengganti teks) dan disabled.
class PrimaryButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final bool isLoading;

  const PrimaryButton({
    super.key,
    required this.label,
    this.onPressed,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 52,
      child: Semantics(
        label: isLoading ? 'Memproses...' : label,
        button: true,
        child: ElevatedButton(
          onPressed: isLoading ? null : onPressed,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.daun,
            disabledBackgroundColor: AppColors.garis,
            foregroundColor: AppColors.kertas,
            disabledForegroundColor: AppColors.tanahSamar,
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppRadius.penuh),
            ),
          ),
          child: AnimatedSwitcher(
            duration: AppMotion.umpanBalik,
            child: isLoading
                ? const SizedBox(
                    key: ValueKey('loading'),
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(AppColors.kertas),
                    ),
                  )
                : Text(
                    key: const ValueKey('label'),
                    label,
                    style: AppTypography.isiTebal.copyWith(color: AppColors.kertas),
                  ),
          ),
        ),
      ),
    );
  }
}

/// Tombol kedua Tandur — hanya border, latar transparan.
class SecondaryButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;

  const SecondaryButton({super.key, required this.label, this.onPressed});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 52,
      child: OutlinedButton(
        onPressed: onPressed,
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.tanah,
          side: const BorderSide(color: AppColors.garis, width: 1.5),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadius.penuh),
          ),
        ),
        child: Text(
          label,
          style: AppTypography.isiTebal.copyWith(color: AppColors.tanah),
        ),
      ),
    );
  }
}

/// Field teks untuk form autentikasi.
/// Mendukung: label, hint, keyboard type, error, dan aksi submit.
class AuthTextField extends StatelessWidget {
  final String label;
  final String hint;
  final TextEditingController controller;
  final TextInputType keyboardType;
  final String? errorText;
  final TextInputAction textInputAction;
  final VoidCallback? onSubmitted;
  final FocusNode? focusNode;

  const AuthTextField({
    super.key,
    required this.label,
    required this.hint,
    required this.controller,
    this.keyboardType = TextInputType.text,
    this.errorText,
    this.textInputAction = TextInputAction.next,
    this.onSubmitted,
    this.focusNode,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: AppTypography.isiTebal.copyWith(color: AppColors.tanah),
        ),
        const SizedBox(height: AppSpacing.s),
        TextFormField(
          controller: controller,
          focusNode: focusNode,
          keyboardType: keyboardType,
          textInputAction: textInputAction,
          onFieldSubmitted: (_) => onSubmitted?.call(),
          style: AppTypography.isi.copyWith(color: AppColors.tanah),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: AppTypography.isi.copyWith(color: AppColors.tanahSamar),
            errorText: errorText,
            errorStyle: AppTypography.kecil.copyWith(color: AppColors.cabai),
            filled: true,
            fillColor: AppColors.kertas,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.l,
              vertical: AppSpacing.m,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppRadius.sedang),
              borderSide: const BorderSide(color: AppColors.garis),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppRadius.sedang),
              borderSide: const BorderSide(color: AppColors.garis),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppRadius.sedang),
              borderSide: const BorderSide(color: AppColors.daun, width: 2),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppRadius.sedang),
              borderSide: const BorderSide(color: AppColors.cabai, width: 1.5),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppRadius.sedang),
              borderSide: const BorderSide(color: AppColors.cabai, width: 2),
            ),
          ),
        ),
      ],
    );
  }
}

/// Field password dengan toggle show/hide.
class PasswordField extends StatefulWidget {
  final String label;
  final String hint;
  final TextEditingController controller;
  final String? errorText;
  final TextInputAction textInputAction;
  final VoidCallback? onSubmitted;
  final FocusNode? focusNode;

  const PasswordField({
    super.key,
    required this.label,
    required this.hint,
    required this.controller,
    this.errorText,
    this.textInputAction = TextInputAction.done,
    this.onSubmitted,
    this.focusNode,
  });

  @override
  State<PasswordField> createState() => _PasswordFieldState();
}

class _PasswordFieldState extends State<PasswordField> {
  bool _obscure = true;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          widget.label,
          style: AppTypography.isiTebal.copyWith(color: AppColors.tanah),
        ),
        const SizedBox(height: AppSpacing.s),
        TextFormField(
          controller: widget.controller,
          focusNode: widget.focusNode,
          obscureText: _obscure,
          textInputAction: widget.textInputAction,
          onFieldSubmitted: (_) => widget.onSubmitted?.call(),
          style: AppTypography.isi.copyWith(color: AppColors.tanah),
          decoration: InputDecoration(
            hintText: widget.hint,
            hintStyle: AppTypography.isi.copyWith(color: AppColors.tanahSamar),
            errorText: widget.errorText,
            errorStyle: AppTypography.kecil.copyWith(color: AppColors.cabai),
            filled: true,
            fillColor: AppColors.kertas,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.l,
              vertical: AppSpacing.m,
            ),
            suffixIcon: IconButton(
              icon: Icon(
                _obscure ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                color: AppColors.tanahSamar,
                size: 20,
              ),
              onPressed: () => setState(() => _obscure = !_obscure),
              tooltip: _obscure ? 'Tampilkan password' : 'Sembunyikan password',
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppRadius.sedang),
              borderSide: const BorderSide(color: AppColors.garis),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppRadius.sedang),
              borderSide: const BorderSide(color: AppColors.garis),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppRadius.sedang),
              borderSide: const BorderSide(color: AppColors.daun, width: 2),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppRadius.sedang),
              borderSide: const BorderSide(color: AppColors.cabai, width: 1.5),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppRadius.sedang),
              borderSide: const BorderSide(color: AppColors.cabai, width: 2),
            ),
          ),
        ),
      ],
    );
  }
}

/// Pesan error server (di bawah form).
class FormErrorMessage extends StatelessWidget {
  final String message;

  const FormErrorMessage({super.key, required this.message});

  @override
  Widget build(BuildContext context) {
    return Semantics(
      liveRegion: true,
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.m),
        decoration: BoxDecoration(
          color: AppColors.cabaiSamar,
          borderRadius: BorderRadius.circular(AppRadius.kecil),
          border: Border.all(color: AppColors.cabai.withValues(alpha: 0.3)),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Icon(Icons.info_outline, color: AppColors.cabai, size: 16),
            const SizedBox(width: AppSpacing.s),
            Expanded(
              child: Text(
                message,
                style: AppTypography.kecil.copyWith(color: AppColors.cabai),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Header layar autentikasi — ikon kembali dan judul.
class AuthHeader extends StatelessWidget {
  final String title;
  final String? subtitle;

  const AuthHeader({super.key, required this.title, this.subtitle});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: AppTypography.tampilanSedang.copyWith(color: AppColors.tanah),
        ),
        if (subtitle != null) ...[
          const SizedBox(height: AppSpacing.s),
          Text(
            subtitle!,
            style: AppTypography.isi.copyWith(color: AppColors.tanahLemah),
          ),
        ],
      ],
    );
  }
}

