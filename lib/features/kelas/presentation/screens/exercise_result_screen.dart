import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:tandur/core/theme/app_colors.dart';
import 'package:tandur/core/theme/app_spacing.dart';
import 'package:tandur/core/theme/app_typography.dart';

class ExerciseResultScreen extends StatelessWidget {
  final int score;
  final int total;
  final String id;

  const ExerciseResultScreen({
    super.key, 
    required this.id,
    required this.score,
    required this.total,
  });

  @override
  Widget build(BuildContext context) {
    final double percentage = total > 0 ? (score / total) : 0;
    final bool isPassed = percentage >= 0.7; // Asumsi lulus jika >= 70%

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
                  color: isPassed ? AppColors.daunSamar : AppColors.cabaiSamar,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  isPassed ? Icons.emoji_events : Icons.refresh,
                  size: 64,
                  color: isPassed ? AppColors.daun : AppColors.cabai,
                ),
              ),
              const SizedBox(height: AppSpacing.xxl),
              
              Text(
                isPassed ? 'Luar Biasa!' : 'Coba Lagi',
                style: AppTypography.judul.copyWith(
                  color: isPassed ? AppColors.daun : AppColors.cabai,
                  fontSize: 28,
                ),
              ),
              const SizedBox(height: AppSpacing.m),
              
              Text(
                'Kamu berhasil menjawab $score dari $total pertanyaan dengan benar.',
                textAlign: TextAlign.center,
                style: AppTypography.isiBesar.copyWith(color: AppColors.tanahLemah),
              ),
              
              const SizedBox(height: AppSpacing.xxl),
              
              // XP Reward
              if (isPassed)
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
                        '+20 XP',
                        style: AppTypography.isiTebal.copyWith(color: AppColors.padi),
                      ),
                    ],
                  ),
                ),
              
              const Spacer(),
              
              ElevatedButton(
                onPressed: () {
                  // Kembali ke detail unit (mundur 2 langkah karena replace)
                  // atau kembali ke halaman sebelumnya yang masuk akal
                  context.go('/kelas'); 
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: isPassed ? AppColors.daun : AppColors.garis,
                  foregroundColor: isPassed ? AppColors.kertas : AppColors.tanah,
                  minimumSize: const Size.fromHeight(48),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppRadius.penuh),
                  ),
                ),
                child: Text(
                  isPassed ? 'Lanjut' : 'Kembali ke Kelas', 
                  style: AppTypography.isiTebal,
                ),
              ),
              
              if (!isPassed) ...[
                const SizedBox(height: AppSpacing.m),
                TextButton(
                  onPressed: () {
                    // Ulangi latihan
                    context.pushReplacement('/kelas/latihan/$id');
                  },
                  style: TextButton.styleFrom(
                    foregroundColor: AppColors.daun,
                    minimumSize: const Size.fromHeight(48),
                  ),
                  child: Text('Ulangi Latihan', style: AppTypography.isiTebal),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
