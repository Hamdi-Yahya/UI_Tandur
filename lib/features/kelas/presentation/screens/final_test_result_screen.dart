import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:tandur/core/theme/app_colors.dart';
import 'package:tandur/core/theme/app_spacing.dart';
import 'package:tandur/core/theme/app_typography.dart';

class FinalTestResultScreen extends StatefulWidget {
  /// Nilai persen 0-100 dari backend (field `score`), bukan jumlah benar.
  final int scorePercent;

  /// Jumlah jawaban benar (field `correctCount`).
  final int correctCount;

  /// Jumlah soal (field `totalCount`).
  final int total;

  /// XP yang benar-benar diberikan backend (field `xpEarned`).
  final int xpEarned;

  /// Bintang petak yang diraih (0-3).
  final int stars;

  final String id;
  final bool passed;

  const FinalTestResultScreen({
    super.key,
    required this.id,
    required this.scorePercent,
    required this.correctCount,
    required this.total,
    required this.passed,
    this.xpEarned = 0,
    this.stars = 0,
  });

  @override
  State<FinalTestResultScreen> createState() => _FinalTestResultScreenState();
}

class _FinalTestResultScreenState extends State<FinalTestResultScreen> with SingleTickerProviderStateMixin {
  bool _startAnimation = false;

  @override
  void initState() {
    super.initState();
    if (widget.passed) {
      Future.delayed(const Duration(milliseconds: 300), () {
        if (mounted) {
          setState(() {
            _startAnimation = true;
          });
        }
      });
    }
  }

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
              
              if (widget.passed) ...[
                // Animasi Pengairan Petak (Simulasi)
                Stack(
                  alignment: Alignment.bottomCenter,
                  children: [
                    Container(
                      width: 160,
                      height: 160,
                      decoration: BoxDecoration(
                        color: AppColors.kertas,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: AppColors.tanah),
                      ),
                      child: Center(
                        child: Text(
                          'Petak 1',
                          style: AppTypography.judul.copyWith(color: AppColors.tanahSamar),
                        ),
                      ),
                    ),
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 1400), // Sesuai PRD
                      curve: Curves.easeInOut,
                      width: 160,
                      height: _startAnimation ? 160 : 0,
                      decoration: BoxDecoration(
                        color: const Color(0xFF64B5F6).withValues(alpha: 0.8), // Warna air mengalir
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                    if (_startAnimation)
                      const Positioned(
                        top: 60,
                        child: Icon(Icons.water_drop, color: Colors.white, size: 48),
                      ),
                  ],
                ),
                const SizedBox(height: AppSpacing.xxl),
              ] else ...[
                // Icon Gagal
                Container(
                  padding: const EdgeInsets.all(AppSpacing.xl),
                  decoration: const BoxDecoration(
                    color: AppColors.cabaiSamar,
                    shape: BoxShape.circle,
                  ),
                  child: Text(
                    widget.passed ? '🏆' : '🍂',
                    style: const TextStyle(
                      fontSize: 64,
                    ),
                  ),
                ),
                const SizedBox(height: AppSpacing.xxl),
              ],
              
              Text(
                widget.passed ? 'Petak Berhasil Dialiri!' : 'Ujian Gagal',
                style: AppTypography.judul.copyWith(
                  color: widget.passed ? AppColors.daun : AppColors.cabai,
                  fontSize: 28,
                ),
              ),
              const SizedBox(height: AppSpacing.m),
              
              Text(
                widget.passed 
                    ? 'Selamat! Kamu telah menyelesaikan petak ini dan memenangkan hadiah utama.'
                    : 'Jangan menyerah. Pelajari lagi materinya dan coba lagi.',
                textAlign: TextAlign.center,
                style: AppTypography.isiBesar.copyWith(color: AppColors.tanahLemah),
              ),
              const SizedBox(height: AppSpacing.m),

              Text(
                'Skor ${widget.scorePercent}% — ${widget.correctCount} dari '
                '${widget.total} soal benar.',
                textAlign: TextAlign.center,
                style: AppTypography.isi.copyWith(color: AppColors.tanahSamar),
              ),

              if (widget.stars > 0) ...[
                const SizedBox(height: AppSpacing.m),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    for (var i = 0; i < 3; i++)
                      Icon(
                        i < widget.stars ? Icons.star : Icons.star_border,
                        color: AppColors.padi,
                        size: 28,
                      ),
                  ],
                ),
              ],

              const SizedBox(height: AppSpacing.xxl),

              // XP: nilainya datang dari backend, jangan dikeraskan di UI.
              if (widget.xpEarned > 0)
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
                        '+${widget.xpEarned} XP',
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
                  backgroundColor: widget.passed ? AppColors.daun : AppColors.garis,
                  foregroundColor: widget.passed ? AppColors.kertas : AppColors.tanah,
                  minimumSize: const Size.fromHeight(48),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppRadius.penuh),
                  ),
                ),
                child: Text(
                  widget.passed ? 'Selesai' : 'Kembali ke Kelas', 
                  style: AppTypography.isiTebal,
                ),
              ),
              
              if (!widget.passed) ...[
                const SizedBox(height: AppSpacing.m),
                TextButton(
                  onPressed: () {
                    context.pushReplacement('/kelas/ujian/${widget.id}');
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
