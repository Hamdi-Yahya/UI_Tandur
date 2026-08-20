import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:tandur/core/theme/app_colors.dart';
import 'package:tandur/core/theme/app_spacing.dart';
import 'package:tandur/core/theme/app_typography.dart';
import 'package:tandur/features/kelas/data/learning_repository.dart';

/// Hasil latihan.
///
/// Catatan kontrak: `score` dari backend adalah **persentase 0-100**
/// (assessment.service.ts: `Math.round(correctCount / totalCount * 100)`),
/// bukan jumlah jawaban benar. Jumlah benar ada di `correctCount`. Layar ini
/// memakai keduanya secara terpisah supaya kalimat "x dari y" tetap benar.
class ExerciseResultScreen extends StatelessWidget {
  final String id;

  /// Jumlah jawaban benar (`correctCount`).
  final int correctCount;

  /// Jumlah soal (`totalCount`).
  final int total;

  /// Nilai dalam persen (`score`), 0-100.
  final int scorePercent;

  /// XP yang benar-benar didapat dari backend (`xpEarned`).
  final int xpEarned;

  /// Pembahasan per soal, dipakai untuk bagian "Pembahasan".
  final List<ExerciseAnswerResult> results;

  const ExerciseResultScreen({
    super.key,
    required this.id,
    required this.correctCount,
    required this.total,
    required this.scorePercent,
    this.xpEarned = 0,
    this.results = const [],
  });

  bool get _isPassed => scorePercent >= 70;

  @override
  Widget build(BuildContext context) {
    final wrongAnswers = results.where((r) => !r.correct).toList();

    return Scaffold(
      backgroundColor: AppColors.embun,
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(AppSpacing.xl),
          children: [
            const SizedBox(height: AppSpacing.xl),
            Center(
              child: Container(
                padding: const EdgeInsets.all(AppSpacing.xl),
                decoration: BoxDecoration(
                  color: _isPassed ? AppColors.daunSamar : AppColors.cabaiSamar,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  _isPassed ? Icons.emoji_events : Icons.refresh,
                  size: 64,
                  color: _isPassed ? AppColors.daun : AppColors.cabai,
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.xl),

            Text(
              _isPassed ? 'Luar Biasa!' : 'Coba Lagi',
              textAlign: TextAlign.center,
              style: AppTypography.judul.copyWith(
                color: _isPassed ? AppColors.daun : AppColors.cabai,
                fontSize: 28,
              ),
            ),
            const SizedBox(height: AppSpacing.m),

            Text(
              'Kamu menjawab benar $correctCount dari $total soal ($scorePercent%).',
              textAlign: TextAlign.center,
              style: AppTypography.isiBesar.copyWith(
                color: AppColors.tanahLemah,
              ),
            ),

            if (xpEarned > 0) ...[
              const SizedBox(height: AppSpacing.xl),
              Center(
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.l,
                    vertical: AppSpacing.s,
                  ),
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
                        style: AppTypography.isiTebal.copyWith(
                          color: AppColors.padi,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],

            // Pembahasan soal yang salah. Kurikulum baru menyertakan
            // `explanation` di tiap butir; tanpa ini pengguna hanya tahu
            // salah tanpa tahu kenapa.
            if (wrongAnswers.isNotEmpty) ...[
              const SizedBox(height: AppSpacing.xxl),
              Text(
                'Pembahasan',
                style: AppTypography.judul.copyWith(color: AppColors.tanah),
              ),
              const SizedBox(height: AppSpacing.m),
              for (final answer in wrongAnswers)
                Padding(
                  padding: const EdgeInsets.only(bottom: AppSpacing.m),
                  child: _PembahasanKartu(answer: answer),
                ),
            ],

            const SizedBox(height: AppSpacing.xxl),

            ElevatedButton(
              onPressed: () => context.go('/kelas'),
              style: ElevatedButton.styleFrom(
                backgroundColor: _isPassed ? AppColors.daun : AppColors.garis,
                foregroundColor: _isPassed ? AppColors.kertas : AppColors.tanah,
                minimumSize: const Size.fromHeight(48),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppRadius.penuh),
                ),
              ),
              child: Text(
                _isPassed ? 'Lanjut' : 'Kembali ke Kelas',
                style: AppTypography.isiTebal,
              ),
            ),

            if (!_isPassed) ...[
              const SizedBox(height: AppSpacing.m),
              TextButton(
                onPressed: () => context.pushReplacement('/kelas/latihan/$id'),
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
    );
  }
}

class _PembahasanKartu extends StatelessWidget {
  const _PembahasanKartu({required this.answer});

  final ExerciseAnswerResult answer;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.l),
      decoration: BoxDecoration(
        color: AppColors.kertas,
        borderRadius: BorderRadius.circular(AppRadius.sedang),
        border: Border.all(color: AppColors.garis),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.close_rounded, size: 18, color: AppColors.cabai),
              const SizedBox(width: AppSpacing.xs),
              Text(
                'Jawaban benar: ${answer.correctAnswer}',
                style: AppTypography.isiTebal.copyWith(color: AppColors.tanah),
              ),
            ],
          ),
          if (answer.explanation != null && answer.explanation!.isNotEmpty) ...[
            const SizedBox(height: AppSpacing.s),
            Text(
              answer.explanation!,
              style: AppTypography.isi.copyWith(color: AppColors.tanahLemah),
            ),
          ],
        ],
      ),
    );
  }
}
