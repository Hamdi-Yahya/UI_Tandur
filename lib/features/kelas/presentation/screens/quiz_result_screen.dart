import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:tandur/core/theme/app_colors.dart';
import 'package:tandur/core/theme/app_spacing.dart';
import 'package:tandur/core/theme/app_typography.dart';

class QuizResultScreen extends StatelessWidget {
  /// Nilai persen 0-100 dari backend (field `score`), bukan jumlah benar.
  final int scorePercent;

  /// Jumlah jawaban benar (field `correctCount`).
  final int correctCount;

  /// Jumlah soal (field `totalCount`).
  final int total;

  /// XP yang benar-benar diberikan backend (field `xpEarned`).
  final int xpEarned;

  final String id;
  final bool passed;

  const QuizResultScreen({
    super.key,
    required this.id,
    required this.scorePercent,
    required this.correctCount,
    required this.total,
    required this.passed,
    this.xpEarned = 0,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.embun,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.xl),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Spacer(),
              
              // Icon Status
              Container(
                padding: const EdgeInsets.all(AppSpacing.xl),
                decoration: BoxDecoration(
                  color: passed ? AppColors.daunSamar : AppColors.cabaiSamar,
                  shape: BoxShape.circle,
                ),
                child: Text(
                  passed ? '🏆' : '🍂',
                  style: const TextStyle(
                    fontSize: 64,
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.xxl),
              
              Text(
                passed ? 'Ujian Lulus!' : 'Kehabisan Nyawa',
                style: AppTypography.judul.copyWith(
                  color: passed ? AppColors.daun : AppColors.cabai,
                  fontSize: 28,
                ),
              ),
              const SizedBox(height: AppSpacing.m),
              
              Text(
                passed 
                    ? 'Selamat! Kamu telah menguasai materi ini dengan baik.'
                    : 'Jangan menyerah. Pelajari lagi materinya dan coba lagi besok.',
                textAlign: TextAlign.center,
                style: AppTypography.isiBesar.copyWith(color: AppColors.tanahLemah),
              ),
              const SizedBox(height: AppSpacing.m),

              Text(
                'Skor $scorePercent% — $correctCount dari $total soal benar.',
                textAlign: TextAlign.center,
                style: AppTypography.isi.copyWith(color: AppColors.tanahSamar),
              ),

              const SizedBox(height: AppSpacing.xxl),

              // XP: nilainya datang dari backend, jangan dikeraskan di UI.
              if (xpEarned > 0)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: AppSpacing.l, vertical: AppSpacing.s),
                  decoration: BoxDecoration(
                    color: AppColors.padiSamar,
                    borderRadius: BorderRadius.circular(AppRadius.penuh),
                    border: Border.all(color: AppColors.padi),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text('⚡', style: TextStyle(fontSize: 20)),
                      const SizedBox(width: AppSpacing.xs),
                      Text(
                        '+$xpEarned XP',
                        style: AppTypography.isiTebal.copyWith(color: AppColors.padi),
                      ),
                    ],
                  ),
                ),
              
              const Spacer(),
              
              ElevatedButton(
                onPressed: () {
                  context.go('/kelas'); 
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: passed ? AppColors.daun : AppColors.garis,
                  foregroundColor: passed ? AppColors.kertas : AppColors.tanah,
                  minimumSize: const Size.fromHeight(48),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppRadius.penuh),
                  ),
                ),
                child: Text(
                  passed ? 'Selesai' : 'Kembali ke Kelas', 
                  style: AppTypography.isiTebal,
                ),
              ),
              
              if (!passed) ...[
                const SizedBox(height: AppSpacing.m),
                TextButton(
                  onPressed: () {
                    context.pushReplacement('/kelas/ujian-unit/$id');
                  },
                  style: TextButton.styleFrom(
                    foregroundColor: AppColors.daun,
                    minimumSize: const Size.fromHeight(48),
                  ),
                  child: Text('Coba Lagi', style: AppTypography.isiTebal),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
