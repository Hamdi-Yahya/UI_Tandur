import 'package:flutter/material.dart';
import 'package:tandur/core/theme/app_colors.dart';
import 'package:tandur/core/theme/app_spacing.dart';
import 'package:tandur/core/theme/app_typography.dart';
import 'package:tandur/core/theme/app_motion.dart';

/// Widget reusable: Scaffold utama untuk layar onboarding 1-4.
/// Mengatur layout, scroll, dan aksesibilitas konsisten antar layar.
class OnboardingScaffold extends StatelessWidget {
  final Widget illustration;
  final String title;
  final String subtitle;
  final int currentPage;
  final int totalPages;
  final VoidCallback onNext;
  final VoidCallback onSkip;
  final String nextLabel;

  const OnboardingScaffold({
    super.key,
    required this.illustration,
    required this.title,
    required this.subtitle,
    required this.currentPage,
    required this.totalPages,
    required this.onNext,
    required this.onSkip,
    this.nextLabel = 'Lanjut',
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.embun,
      body: SafeArea(
        child: Column(
          children: [
            // Tombol Lewati di pojok kanan atas
            Align(
              alignment: Alignment.centerRight,
              child: Semantics(
                label: 'Lewati perkenalan',
                child: TextButton(
                  onPressed: onSkip,
                  style: TextButton.styleFrom(
                    minimumSize: const Size(48, 48), // touch target 48dp
                    foregroundColor: AppColors.tanahLemah,
                  ),
                  child: Text(
                    'Lewati',
                    style: AppTypography.isi.copyWith(color: AppColors.tanahLemah),
                  ),
                ),
              ),
            ),

            // Area ilustrasi
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
                child: illustration,
              ),
            ),

            // Area teks dan navigasi
            Padding(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.l,
                AppSpacing.xl,
                AppSpacing.l,
                AppSpacing.xxl,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Judul: Bricolage Grotesque 26
                  Text(
                    title,
                    style: AppTypography.tampilanSedang.copyWith(
                      color: AppColors.tanah,
                    ),
                    semanticsLabel: title,
                  ),
                  const SizedBox(height: AppSpacing.m),

                  // Subjudul: Plus Jakarta Sans 16
                  Text(
                    subtitle,
                    style: AppTypography.isiBesar.copyWith(
                      color: AppColors.tanahLemah,
                    ),
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: AppSpacing.xl),

                  // Indikator halaman
                  OnboardingProgress(
                    current: currentPage,
                    total: totalPages,
                  ),
                  const SizedBox(height: AppSpacing.xl),

                  // Tombol Lanjut: hijau penuh, tinggi 52
                  _NextButton(label: nextLabel, onPressed: onNext),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Widget indikator titik halaman (1/4, 2/4, dst).
class OnboardingProgress extends StatelessWidget {
  final int current; // 0-indexed
  final int total;

  const OnboardingProgress({
    super.key,
    required this.current,
    required this.total,
  });

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: 'Halaman ${current + 1} dari $total',
      child: Row(
        children: List.generate(total, (index) {
          final bool isActive = index == current;
          return AnimatedContainer(
            duration: AppMotion.umpanBalik,
            curve: AppMotion.kurvaUmpanBalik,
            margin: const EdgeInsets.only(right: AppSpacing.s),
            width: isActive ? 20.0 : 8.0,
            height: 8.0,
            decoration: BoxDecoration(
              color: isActive ? AppColors.daun : AppColors.garis,
              borderRadius: BorderRadius.circular(AppSpacing.s),
            ),
          );
        }),
      ),
    );
  }
}

/// Tombol utama onboarding: hijau daun, sudut penuh, tinggi 52dp.
class _NextButton extends StatelessWidget {
  final String label;
  final VoidCallback onPressed;

  const _NextButton({required this.label, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 52,
      child: Semantics(
        label: label,
        button: true,
        child: ElevatedButton(
          onPressed: onPressed,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.daun,
            foregroundColor: AppColors.kertas,
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(999),
            ),
          ),
          child: Text(
            label,
            style: AppTypography.isiTebal.copyWith(color: AppColors.kertas),
          ),
        ),
      ),
    );
  }
}

/// Widget placeholder ilustrasi onboarding.
/// Aspect ratio 4:3. Mudah diganti aset final tanpa mengubah layout.
class OnboardingIllustrationPlaceholder extends StatelessWidget {
  final String label;
  final Color color;

  const OnboardingIllustrationPlaceholder({
    super.key,
    required this.label,
    this.color = AppColors.daunSamar,
  });

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: 'Ilustrasi: $label',
      image: true,
      child: AspectRatio(
        aspectRatio: 4 / 3,
        child: Container(
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: AppColors.garis),
          ),
          child: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.image_outlined,
                  size: 48,
                  color: AppColors.tanahSamar,
                  semanticLabel: label,
                ),
                const SizedBox(height: AppSpacing.s),
                Text(
                  '[ILLUSTRATION_PLACEHOLDER]',
                  style: AppTypography.kecil.copyWith(
                    color: AppColors.tanahSamar,
                  ),
                ),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  label,
                  style: AppTypography.label.copyWith(
                    color: AppColors.tanahLemah,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
